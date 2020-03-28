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
  defaultLockScript,
  packUdtAmount
} from "./utilities";
import { argv, exit } from "process";
import * as fs from "fs";
import { inspect } from "util";

if (argv.length != 5) {
  console.log(
    "Usage: node issue_udt_token.js <private key> <amount> <capacity>"
  );
  exit(1);
}

const rpc = new RPC("http://127.0.0.1:8114/rpc");
const client = redis.createClient();
client.on("connect", async () => {
  Nohm.setClient(client);

  const privateKey = argv[2];
  const script = defaultLockScript(publicKeyHash(privateKey));
  const scriptHash = ckbHash(
    blockchain.SerializeScript(normalizers.NormalizeScript(script))
  );
  const collector = new Collector(rpc, {
    [nohm.KEY_LOCK_HASH]: scriptHash.serializeJson()
  });
  // Always charge 1 CKB for fees.
  const udtCapacity = BigInt(argv[4]) * 100000000n;
  const targetCapacity = udtCapacity + 100000000n;
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
  const udtTypeScript = {
    code_hash: JSON.parse(fs.readFileSync("cell_deps.json")).udt_binary_hash,
    hash_type: "data",
    args: scriptHash.serializeJson()
  };
  const udtTypeHash = ckbHash(
    blockchain.SerializeScript(normalizers.NormalizeScript(udtTypeScript))
  );
  console.log(`UDT Type Script Hash: ${udtTypeHash.serializeJson()}`);
  const udtCell = {
    cell_output: {
      capacity: "0x" + udtCapacity.toString(16),
      lock: script,
      type: udtTypeScript
    },
    data: packUdtAmount(BigInt(argv[3])).serializeJson()
  };
  const outputCells = [udtCell];
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
  exit(0);
});
