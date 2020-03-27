import express from "express";
import bodyParser from "body-parser";
import redis from "redis";
import { RPC, Reader } from "ckb-js-toolkit";
import { Nohm } from "nohm";
import * as nohm from "ckb-js-toolkit-contrib/src/cell_collectors/nohm";
import * as fs from "fs";
import {
  deserializeLeaseCellInfo,
  collectCellForFees,
  assembleTransaction,
  fillSignatures,
  serializeLeaseCellInfo
} from "./utilities";
import { inspect } from "util";

const app = express();
app.use(bodyParser.json());
const port = 3000;
const rpc = new RPC("http://127.0.0.1:8114/rpc");
const client = redis.createClient();
const codeHash = JSON.parse(fs.readFileSync("cell_deps.json")).binary_hash;

app.get("/", async (req, res) => {
  res.send("Hello World!");
});

app.post("/holders/:holder_pubkey_hash/cells", async (req, res) => {
  const { holder_pubkey_hash } = req.params;
  const collector = new nohm.Collector(
    rpc,
    {
      [nohm.KEY_LOCK_CODE_HASH]: codeHash
    },
    {
      skipCellWithContent: false
    }
  );
  const cells = [];
  for await (const cell of collector.collect()) {
    const leaseCellInfo = deserializeLeaseCellInfo(cell.cell_output.lock.args);
    if (leaseCellInfo.holder_pubkey_hash == holder_pubkey_hash) {
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
  const collector = new nohm.Collector(
    rpc,
    {
      [nohm.KEY_LOCK_CODE_HASH]: codeHash
    },
    {
      skipCellWithContent: false
    }
  );
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

app.post(
  "/builders/:builder_pubkey_hash/cell/:tx_hash/:index/change_data",
  async (req, res) => {
    const { builder_pubkey_hash, tx_hash, index } = req.params;
    let { data } = req.body;
    if (!data.startsWith("0x")) {
      data = Reader.fromRawString(data).serializeJson();
    }
    const collector = new nohm.Collector(
      rpc,
      {
        [nohm.KEY_LOCK_CODE_HASH]: codeHash,
        [nohm.KEY_OUT_POINT]: nohm.serializeOutPoint({ tx_hash, index })
      },
      {
        skipCellWithContent: false
      }
    );
    const cells = [];
    for await (const cell of collector.collect()) {
      const leaseCellInfo = deserializeLeaseCellInfo(
        cell.cell_output.lock.args
      );
      if (leaseCellInfo.builder_pubkey_hash == builder_pubkey_hash) {
        cells.push(cell);
      }
    }
    if (cells.length === 0) {
      res.sendStatus(404);
      return;
    }
    const txTemplate = await collectCellForFees(rpc, builder_pubkey_hash);
    cells[0].data = data;
    txTemplate.inputs.push(cells[0]);
    txTemplate.outputs.push(cells[0]);
    res.json(assembleTransaction(txTemplate));
  }
);

app.post(
  "/builders/:builder_pubkey_hash/cell/:tx_hash/:index/pay",
  async (req, res) => {
    const { builder_pubkey_hash, tx_hash, index } = req.params;
    const collector = new nohm.Collector(
      rpc,
      {
        [nohm.KEY_LOCK_CODE_HASH]: codeHash,
        [nohm.KEY_OUT_POINT]: nohm.serializeOutPoint({ tx_hash, index })
      },
      {
        skipCellWithContent: false
      }
    );
    const cells = [];
    for await (const cell of collector.collect()) {
      const leaseCellInfo = deserializeLeaseCellInfo(
        cell.cell_output.lock.args
      );
      if (leaseCellInfo.builder_pubkey_hash == builder_pubkey_hash) {
        cells.push({
          cell,
          info: leaseCellInfo
        });
      }
    }
    if (cells.length === 0) {
      res.sendStatus(404);
      return;
    }
    let { cell, info: leaseCellInfo } = cells[0];
    const payAmount = BigInt(leaseCellInfo.amount_per_period);
    const txTemplate = await collectCellForFees(rpc, builder_pubkey_hash, payAmount + 100000000n);
    leaseCellInfo.last_payment_time = (await rpc.get_tip_header()).number;
    txTemplate.inputs.push(cell);
    txTemplate.outputs.push({
      cell_output: {
        capacity: cell.cell_output.capacity,
        lock: {
          code_hash: cell.cell_output.lock.code_hash,
          hash_type: cell.cell_output.lock.hash_type,
          args: serializeLeaseCellInfo(leaseCellInfo).serializeJson()
        },
        type: cell.type
      },
      data: cell.data
    });
    txTemplate.outputs.push({
      cell_output: {
        capacity: "0x" + payAmount.toString(16),
        lock: {
          code_hash: "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
          hash_type: "type",
          args: leaseCellInfo.holder_pubkey_hash
        },
        type: null
      }
    });
    console.log(inspect(txTemplate, false, null, true));
    res.json(assembleTransaction(txTemplate));
  }
);

app.post("/send_signed_transaction", async (req, res) => {
  const { tx, messagesToSign, signatures } = req.body;
  const filledTx = fillSignatures(tx, messagesToSign, signatures);
  const result = await rpc.send_transaction(filledTx, "passthrough");
  res.json({ tx_hash: result });
});

client.on("connect", () => {
  Nohm.setClient(client);
  const indexer = new nohm.Indexer(rpc, client, {
    /* log: () => null */
  });
  indexer.start();

  app.listen(port, () => console.log(`Server started on port ${port}!`));
});
