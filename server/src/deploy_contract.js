import redis from "redis";
import { Reader, normalizers, validators } from "ckb-js-toolkit";
import { RPC } from "ckb-js-toolkit";
import { Nohm } from "nohm";
import * as blockchain from "ckb-js-toolkit-contrib/src/blockchain";
import * as nohm from "ckb-js-toolkit-contrib/src/cell_collectors/nohm";
const { Collector } = nohm;
import {
  publicKeyHash,
  ckbHash,
  createLeaseCell,
  assembleTransaction,
  fillSignatures,
  secpSign
} from "./utilities";
import { argv, exit } from "process";
import * as fs from "fs";
import { inspect } from "util";

if (argv.length != 4) {
  console.log("Usage: node deploy_contract.js <private key> <contract path>");
  exit(1);
}

const rpc = new RPC("http://127.0.0.1:8114/rpc");
const client = redis.createClient();
client.on("connect", async () => {
  Nohm.setClient(client);

  let binary = fs.readFileSync(argv[3]);
  binary = new Reader(binary.buffer.slice(0, binary.length));
  const binaryHash = ckbHash(binary).serializeJson();
  const capacity =
    BigInt(binary.length()) * BigInt(100000000n) + BigInt(6100000000n);
  const privateKey = argv[2];

  const script = {
    code_hash:
      "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
    hash_type: "type",
    args: publicKeyHash(privateKey)
  };
  validators.ValidateScript(script);
  const scriptHash = ckbHash(
    blockchain.SerializeScript(normalizers.NormalizeScript(script))
  );
  const collector = new Collector(rpc, {
    [nohm.KEY_LOCK_HASH]: scriptHash.serializeJson()
  });
  // Always charge 1 CKB for fees.
  const targetCapacity = BigInt(capacity) + 100000000n;
  let currentCapacity = BigInt(0);
  let currentCells = [];
  for await (const cell of collector.collect()) {
    currentCells.push(cell);
    currentCapacity += BigInt(cell.cell_output.capacity);

    if (
      currentCapacity === targetCapacity ||
      currentCapacity > targetCapacity + 6100000000n
    ) {
      break;
    }
  }
  const binaryCell = {
    cell_output: {
      capacity: "0x" + BigInt(capacity).toString(16),
      lock: script,
      type: null
    },
    data: new Reader(binary).serializeJson()
  };
  const outputCells = [binaryCell];
  if (currentCapacity > targetCapacity) {
    outputCells.push({
      cell_output: {
        capacity: "0x" + (currentCapacity - targetCapacity).toString(16),
        lock: script,
        type: null
      },
      data: null
    });
  }
  const txTemplate = {
    inputs: currentCells,
    outputs: outputCells
  };
  const { tx, messagesToSign } = assembleTransaction(txTemplate);
  const signatures = messagesToSign.map(({ message }) => {
    return secpSign(privateKey, message);
  });
  const filledTx = fillSignatures(tx, messagesToSign, signatures);
  const result = await rpc.send_transaction(filledTx, "passthrough");

  const genesis = await rpc.get_block_by_number("0x0");
  const data = {
    cell_deps: [
      {
        dep_type: "dep_group",
        out_point: {
          tx_hash: genesis.transactions[1].hash,
          index: "0x0"
        }
      },
      {
        dep_type: "code",
        out_point: {
          tx_hash: result,
          index: "0x0"
        }
      }
    ],
    binary_hash: binaryHash
  };
  fs.writeFileSync("cell_deps.json", JSON.stringify(data));

  exit(0);
});
