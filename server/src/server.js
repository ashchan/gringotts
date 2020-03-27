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
  serializeLeaseCellInfo,
  validateLeaseCellInfo
} from "./utilities";
import { inspect, promisify } from "util";
import { v4 as uuidv4 } from "uuid";

const app = express();
app.use(bodyParser.json());
const port = 3000;
const rpc = new RPC("http://127.0.0.1:8114/rpc");
const client = redis.createClient();
const codeHash = JSON.parse(fs.readFileSync("cell_deps.json")).binary_hash;
const hgetAsync = promisify(client.hget).bind(client);
const hgetallAsync = promisify(client.hgetall).bind(client);
const hsetAsync = promisify(client.hset).bind(client);
const hdelAsync = promisify(client.hdel).bind(client);

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
      skipCellWithContent: false,
      loadData: true
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
      skipCellWithContent: false,
      loadData: true
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
    const txTemplate = await collectCellForFees(
      rpc,
      builder_pubkey_hash,
      payAmount + 100000000n
    );
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
          code_hash:
            "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
          hash_type: "type",
          args: leaseCellInfo.holder_pubkey_hash
        },
        type: null
      }
    });
    res.json(assembleTransaction(txTemplate));
  }
);

app.post(
  "/holders/:holder_pubkey_hash/cell/:tx_hash/:index/claim",
  async (req, res) => {
    const { holder_pubkey_hash, tx_hash, index } = req.params;
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
      if (leaseCellInfo.holder_pubkey_hash == holder_pubkey_hash) {
        cells.push(cell);
      }
    }
    if (cells.length === 0) {
      res.sendStatus(404);
      return;
    }
    const txTemplate = await collectCellForFees(rpc, holder_pubkey_hash);
    txTemplate.inputs.push(cells[0]);
    txTemplate.outputs[0].cell_output.capacity =
      "0x" +
      (
        BigInt(txTemplate.outputs[0].cell_output.capacity) +
        BigInt(cells[0].cell_output.capacity)
      ).toString(16);
    res.json(assembleTransaction(txTemplate));
  }
);

app.post("/send_signed_transaction", async (req, res) => {
  const { tx, messagesToSign, signatures } = req.body;
  const filledTx = fillSignatures(tx, messagesToSign, signatures);
  const result = await rpc.send_transaction(filledTx, "passthrough");
  res.json({ tx_hash: result });
});

app.post("/matches/create", async (req, res) => {
  const {
    coin_hash,
    builder_pubkey_hash,
    lease_period,
    overdue_period,
    amount_per_period,
    lease_amounts
  } = req.body;
  const txTemplate = await collectCellForFees(
    rpc,
    builder_pubkey_hash,
    BigInt(amount_per_period) + 100000000n
  );
  const data = {
    status: "created",
    info: {
      coin_hash,
      builder_pubkey_hash,
      lease_period,
      overdue_period,
      amount_per_period
    },
    lease_amounts,
    tx: txTemplate
  };
  const id = uuidv4();
  await hsetAsync("MATCH_LIST", id, JSON.stringify(data));
  res.json({ id, data });
});

app.post("/matches/list", async (req, res) => {
  const matches = await hgetallAsync("MATCH_LIST");
  res.json(
    Object.keys(matches).map(id => {
      const data = JSON.parse(matches[id]);
      return { id, data };
    })
  );
});

app.post("/matches/:id/match", async (req, res) => {
  const oldData = await hgetAsync("MATCH_LIST", req.params.id);
  if (!oldData) {
    res.sendStatus(404);
    return;
  }
  const parsed = JSON.parse(oldData);
  if (parsed.status !== "created") {
    res.sendStatus(400);
    return;
  }
  const { holder_pubkey_hash } = req.body;
  parsed.info.holder_pubkey_hash = holder_pubkey_hash;
  parsed.info.last_payment_time = (await rpc.get_tip_header()).number;
  validateLeaseCellInfo(parsed.info);
  const txTemplate = await collectCellForFees(
    rpc,
    holder_pubkey_hash,
    BigInt(parsed.lease_amounts)
  );
  txTemplate.inputs = txTemplate.inputs.concat(parsed.tx.inputs);
  txTemplate.outputs = txTemplate.outputs.concat(parsed.tx.outputs);
  const { tx, messagesToSign } = assembleTransaction(txTemplate);
  const holderMessages = messagesToSign.filter(m => {
    return m.lock.args === parsed.info.holder_pubkey_hash;
  });
  const builderMessages = messagesToSign.filter(m => {
    return m.lock.args === parsed.info.builder_pubkey_hash;
  });
  const newData = {
    status: "matched",
    info: parsed.info,
    tx,
    messagesToSign: holderMessages,
    nextMessagesToSign: builderMessages
  };
  await hsetAsync("MATCH_LIST", req.params.id, JSON.stringify(newData));
  res.json({ id: req.params.id, data: newData });
});

app.post("/matches/:id/sign_match", async (req, res) => {
  const oldData = await hgetAsync("MATCH_LIST", req.params.id);
  if (!oldData) {
    res.sendStatus(404);
    return;
  }
  const parsed = JSON.parse(oldData);
  if (parsed.status !== "matched") {
    res.sendStatus(400);
    return;
  }
  const { signatures } = req.body;
  const filledTx = fillSignatures(parsed.tx, parsed.messagesToSign, signatures);
  const newData = {
    status: "sign_matched",
    info: parsed.info,
    tx: filledTx,
    messagesToSign: parsed.nextMessagesToSign
  };
  await hsetAsync("MATCH_LIST", req.params.id, JSON.stringify(newData));
  res.json({ id: req.params.id, data: newData });
});

app.post("/matches/:id/sign_confirm", async (req, res) => {
  const oldData = await hgetAsync("MATCH_LIST", req.params.id);
  if (!oldData) {
    res.sendStatus(404);
    return;
  }
  const parsed = JSON.parse(oldData);
  if (parsed.status !== "sign_matched") {
    res.sendStatus(400);
    return;
  }
  const { signatures } = req.body;
  const filledTx = fillSignatures(parsed.tx, parsed.messagesToSign, signatures);
  const result = await rpc.send_transaction(filledTx, "passthrough");
  await hdelAsync("MATCH_LIST", req.params.id);
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
