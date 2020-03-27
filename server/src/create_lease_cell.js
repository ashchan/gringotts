import redis from "redis";
import { RPC } from "ckb-js-toolkit";
import { Nohm } from "nohm";
import * as nohm from "ckb-js-toolkit-contrib/src/cell_collectors/nohm";
import { createLeaseCell } from "./utilities";
import { inspect } from "util";
import { argv, exit } from "process";

if (argv.length != 9) {
  console.log(
    "Usage: node create_lease_cell.js <private key> <coin hash> <holder lock> <builder pubkey hash> <lease period> <overdue period> <capacity to lease>"
  );
  exit(1);
}

const rpc = new RPC("http://127.0.0.1:8114/rpc");
const client = redis.createClient();
client.on("connect", async () => {
  Nohm.setClient(client);

  const tip_number = (await rpc.get_tip_header()).number;
  const tx = await createLeaseCell(
    rpc,
    argv[2],
    {
      coin_hash: argv[3],
      holder_lock: argv[4],
      builder_pubkey_hash: argv[5],
      lease_period: "0x" + BigInt(argv[6]).toString(16),
      overdue_period: "0x" + BigInt(argv[7]).toString(16),
      last_payment_time: tip_number
    },
    BigInt(argv[8]) * BigInt(100000000n)
  );
  console.log("TX: ", inspect(tx, false, null, true));
  const result = await rpc.send_transaction(tx, "passthrough");
  console.log(`Created lease cell at ${result}@0!`);
  exit(0);
});
