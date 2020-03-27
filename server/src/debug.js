import redis from "redis";
import { RPC } from "ckb-js-toolkit";
import { Nohm } from "nohm";
import * as nohm from "ckb-js-toolkit-contrib/src/cell_collectors/nohm";
import { createLeaseCell } from "./utilities";
import { inspect } from "util";
import { exit } from "process";

const rpc = new RPC("http://127.0.0.1:8114/rpc");
const client = redis.createClient();
client.on("connect", async () => {
  Nohm.setClient(client);

  const tx = await createLeaseCell(
    rpc,
    "0xd00c06bfd800d27397002dca6fb0993d5ba6399b4238b2f29ee9deb97593d2bc",
    {
      coin_hash: "0x0000000000000000000000000000000000000000000000000000000000000000",
      holder_lock: "0x32e555f3ff8e135cece1351a6a2971518392c1e30375c1e006ad0ce8eac07947",
      builder_pubkey_hash: "0x276f2fa3565a10c76164a5e92d4a0b699889ef48",
      lease_period: "0x" + BigInt("100").toString(16),
      overdue_period: "0x" + BigInt("100").toString(16),
      last_payment_time: "0x" + BigInt("89").toString(16),
    },
    BigInt(20000000000n)
  );
  console.log("TX: ", inspect(tx, false, null, true));
  exit(0);
});
