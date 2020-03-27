import express from "express";
import redis from "redis";
import { RPC } from "ckb-js-toolkit";
import { Nohm } from "nohm";
import * as nohm from "ckb-js-toolkit-contrib/src/cell_collectors/nohm";

const app = express();
const port = 3000;

app.get("/", async (req, res) => {
  res.send("Hello World!");
});

const rpc = new RPC("http://127.0.0.1:8114/rpc");
const client = redis.createClient();
client.on("connect", async () => {
  Nohm.setClient(client);
  const indexer = new nohm.Indexer(rpc, client);
  indexer.start();

  app.listen(port, () => console.log(`Server started on port ${port}!`));
});
