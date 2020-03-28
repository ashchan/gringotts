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
  secpSign,
  defaultLockScript
} from "./utilities";
import { argv, exit } from "process";
import * as fs from "fs";
import { inspect } from "util";

if (argv.length < 5) {
  console.log(
    "Usage: node deploy_contract.js <private key> <contract path> <udt contract path> <true to use dep group>"
  );
  exit(1);
}

const rpc = new RPC("http://127.0.0.1:8114/rpc");
const client = redis.createClient();
client.on("connect", async () => {
  Nohm.setClient(client);

  const binary = new Reader("0x" + fs.readFileSync(argv[3], "hex"));
  const binaryHash = ckbHash(binary).serializeJson();

  const udtBinary = new Reader("0x" + fs.readFileSync(argv[4], "hex"));
  const udtBinaryHash = ckbHash(udtBinary).serializeJson();

  const capacity =
    BigInt(binary.length()) * BigInt(100000000n) + BigInt(6100000000n);
  const udtCapacity =
    BigInt(udtBinary.length()) * BigInt(100000000n) + BigInt(6100000000n);
  const privateKey = argv[2];

  const script = defaultLockScript(publicKeyHash(privateKey));
  const scriptHash = ckbHash(
    blockchain.SerializeScript(normalizers.NormalizeScript(script))
  );
  const collector = new Collector(rpc, {
    [nohm.KEY_LOCK_HASH]: scriptHash.serializeJson()
  });
  // Always charge 1 CKB for fees.
  const targetCapacity = BigInt(capacity) + BigInt(udtCapacity) + 100000000n;
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
  const udtBinaryCell = {
    cell_output: {
      capacity: "0x" + BigInt(udtCapacity).toString(16),
      lock: script,
      type: null
    },
    data: new Reader(udtBinary).serializeJson()
  };
  const outputCells = [binaryCell, udtBinaryCell];
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
  const genesis = await rpc.get_block_by_number("0x0");
  let genesisDeps;
  if (argv[5] === "true") {
    genesisDeps = [
      {
        dep_type: "dep_group",
        out_point: {
          tx_hash: genesis.transactions[1].hash,
          index: "0x0"
        }
      }
    ];
  } else {
    genesisDeps = [
      {
        dep_type: "code",
        out_point: {
          tx_hash: genesis.transactions[0].hash,
          index: "0x1"
        }
      },
      {
        dep_type: "code",
        out_point: {
          tx_hash: genesis.transactions[0].hash,
          index: "0x3"
        }
      }
    ];
  }
  const txTemplate = {
    inputs: currentCells,
    outputs: outputCells,
    cellDeps: genesisDeps
  };
  const { tx, messagesToSign } = assembleTransaction(txTemplate);
  const signatures = messagesToSign.map(({ message }) => {
    return secpSign(privateKey, message);
  });
  const filledTx = fillSignatures(tx, messagesToSign, signatures);
  console.log("TX: ", inspect(filledTx, false, null, true));
  const result = await rpc.send_transaction(filledTx, "passthrough");

  const data = {
    cell_deps: genesisDeps.concat([
      {
        dep_type: "code",
        out_point: {
          tx_hash: result,
          index: "0x0"
        }
      },
      {
        dep_type: "code",
        out_point: {
          tx_hash: result,
          index: "0x1"
        }
      }
    ]),
    binary_hash: binaryHash,
    udt_binary_hash: udtBinaryHash
  };
  fs.writeFileSync("cell_deps.json", JSON.stringify(data));

  exit(0);
});
