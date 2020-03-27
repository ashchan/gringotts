import express from "express";
import bodyParser from "body-parser";
import redis from "redis";
import { RPC } from "ckb-js-toolkit";
import { Nohm } from "nohm";
import * as nohm from "ckb-js-toolkit-contrib/src/cell_collectors/nohm";
import * as fs from "fs";
import { deserializeLeaseCellInfo } from "./utilities";

const app = express();
app.use(bodyParser.json());
const port = 3000;
const rpc = new RPC("http://127.0.0.1:8114/rpc");
const client = redis.createClient();
const codeHash = JSON.parse(fs.readFileSync("cell_deps.json")).binary_hash;

app.get("/", async (req, res) => {
  res.send("Hello World!");
});

app.post("/holders/:holder_lock_hash/cells", async (req, res) => {
  const { holder_lock_hash } = req.params;
  const collector = new nohm.Collector(rpc, {
    [nohm.KEY_LOCK_CODE_HASH]: codeHash
  }, {
    skipCellWithContent: false
  });
  const cells = [];
  for await (const cell of collector.collect()) {
    const leaseCellInfo = deserializeLeaseCellInfo(cell.cell_output.lock.args);
    if (leaseCellInfo.holder_lock == holder_lock_hash) {
      cells.push({
        lease_info: leaseCellInfo,
        out_point: cell.out_point,
        data: cell.data
      });
    }
  }
  res.json(cells);
});

app.post("/builders/:builder_pubkey_hash/cells", async (req, res) => {
  const { builder_pubkey_hash } = req.params;
  const collector = new nohm.Collector(rpc, {
    [nohm.KEY_LOCK_CODE_HASH]: codeHash
  }, {
    skipCellWithContent: false
  });
  const cells = [];
  for await (const cell of collector.collect()) {
    const leaseCellInfo = deserializeLeaseCellInfo(cell.cell_output.lock.args);
    if (leaseCellInfo.builder_pubkey_hash == builder_pubkey_hash) {
      cells.push({
        lease_info: leaseCellInfo,
        out_point: cell.out_point,
        data: cell.data
      });
    }
  }
  res.json(cells);
});

client.on("connect", () => {
  Nohm.setClient(client);
  const indexer = new nohm.Indexer(rpc, client, {
    /* log: () => null */
  });
  indexer.start();

  app.listen(port, () => console.log(`Server started on port ${port}!`));
});
