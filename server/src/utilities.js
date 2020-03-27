import secp256k1 from "secp256k1";
import { Reader, normalizers, validators } from "ckb-js-toolkit";
import blake2b from "blake2b";
import * as blockchain from "ckb-js-toolkit-contrib/src/blockchain";
import * as nohm from "ckb-js-toolkit-contrib/src/cell_collectors/nohm";
const { Collector } = nohm;
import * as fs from "fs";
import deep_equal from "fast-deep-equal";

export function ckbHasher() {
  return blake2b(
    32,
    null,
    null,
    new Uint8Array(Reader.fromRawString("ckb-default-hash").toArrayBuffer())
  );
}

export function ckbHash(buffer) {
  buffer = new Reader(buffer).toArrayBuffer();
  const h = ckbHasher();
  h.update(new Uint8Array(buffer));
  const out = new Uint8Array(32);
  h.digest(out);
  return new Reader(out.buffer);
}

export function publicKeyHash(privateKey) {
  const publicKey = secp256k1.publicKeyCreate(
    new Uint8Array(new Reader(privateKey).toArrayBuffer())
  );
  const h = ckbHash(publicKey.buffer);
  return new Reader(h.toArrayBuffer().slice(0, 20)).serializeJson();
}

export function secpSign(privateKey, message) {
  const { signature, recid } = secp256k1.ecdsaSign(
    new Uint8Array(new Reader(message).toArrayBuffer()),
    new Uint8Array(new Reader(privateKey).toArrayBuffer())
  );
  const array = new Uint8Array(65);
  array.set(signature, 0);
  array.set([recid], 64);
  return new Reader(array.buffer);
}

export function validateLeaseCellInfo(leaseCellInfo) {
  ["coin_hash", "holder_lock"].forEach(key => {
    if (!leaseCellInfo[key]) {
      throw new Error(`${key} does not exist!`);
    }
    const reader = new Reader(leaseCellInfo[key]);
    if (reader.length() !== 32) {
      throw new Error(`Invalid length for ${key}`);
    }
  });
  if (!leaseCellInfo.builder_pubkey_hash) {
    throw new Error("builder_pubkey_hash does not exist!");
  }
  const reader = new Reader(leaseCellInfo.builder_pubkey_hash);
  if (reader.length() !== 20) {
    throw new Error("Invalid length for builder_pubkey_hash");
  }
  ["lease_period", "overdue_period", "last_payment_time"].forEach(key => {
    if (!leaseCellInfo[key]) {
      throw Error(`${key} does not exist!`);
    }
    const i = leaseCellInfo[key];
    if (i === "0x0") {
      return;
    }
    if (!/^0x[1-9a-fA-F][0-9a-fA-F]*$/.test(i)) {
      throw new Error(`${key} must be a hex integer!`);
    }
  });
}

export function serializeLeaseCellInfo(leaseCellInfo) {
  validateLeaseCellInfo(leaseCellInfo);
  const array = new Uint8Array(108);
  array.set(
    new Uint8Array(new Reader(leaseCellInfo.holder_lock).toArrayBuffer()),
    0
  );
  array.set(
    new Uint8Array(
      new Reader(leaseCellInfo.builder_pubkey_hash).toArrayBuffer()
    ),
    32
  );
  array.set(
    new Uint8Array(new Reader(leaseCellInfo.coin_hash).toArrayBuffer()),
    52
  );
  const view = new DataView(array.buffer);
  view.setBigUint64(84, BigInt(leaseCellInfo.lease_period), true);
  view.setBigUint64(92, BigInt(leaseCellInfo.overdue_period), true);
  view.setBigUint64(100, BigInt(leaseCellInfo.last_payment_time), true);
  return new Reader(view.buffer);
}

export function deserializeLeaseCellInfo(buffer) {
  if (buffer instanceof Object && buffer.toArrayBuffer instanceof Function) {
    buffer = buffer.toArrayBuffer();
  }
  if (!(buffer instanceof ArrayBuffer)) {
    throw new Error("Input is not an array buffer!");
  }
  if (buffer.byteLength != 120) {
    throw new Error("Invalid array buffer length!");
  }
  const view = new DataView(buffer);
  return {
    holder_lock: new Reader(buffer.slice(0, 32)).serializeJson(),
    builder_lock: new Reader(buffer.slice(32, 64)).serializeJson(),
    coin_hash: new Reader(buffer.slice(64, 96)).serializeJson(),
    lease_period: "0x" + view.getBigUint64(96, true).toString(16),
    overdue_period: "0x" + view.getBigUint64(104, true).toSring(16),
    last_payment_time: "0x" + view.getBigUint64(112, true).toString(16)
  };
}

export function intToLeBuffer(i) {
  i = BigInt(i);
  const view = new DataView(new ArrayBuffer(8));
  view.setBigUint64(0, i, true);
  return view.buffer;
}

export function assembleTransaction(txTemplate) {
  const tx = {
    version: "0x0",
    cell_deps: JSON.parse(fs.readFileSync("./cell_deps.json")).cell_deps,
    header_deps: txTemplate.headers || [],
    inputs: txTemplate.inputs.map(i => {
      return {
        previous_output: i.out_point,
        since: "0x0"
      };
    }),
    outputs: txTemplate.outputs.map(o => o.cell_output),
    outputs_data: txTemplate.outputs.map(o => o.data || "0x"),
    witnesses: txTemplate.inputs.map(i => i.witness || "0x")
  };
  validators.ValidateTransaction(tx);
  const txHash = ckbHash(
    new Reader(
      blockchain.SerializeRawTransaction(
        normalizers.NormalizeRawTransaction(tx)
      )
    )
  );
  const messagesToSign = [];
  const used = txTemplate.inputs.map(_i => false);
  for (let i = 0; i < txTemplate.inputs.length; i++) {
    if (used[i]) {
      continue;
    }
    used[i] = true;
    let firstWitness = tx.witnesses[i];
    if (firstWitness === "0x") {
      firstWitness = {};
    }
    const hasher = ckbHasher();
    firstWitness.lock =
      "0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
    const serializedWitness = new Reader(
      blockchain.SerializeWitnessArgs(
        normalizers.NormalizeWitnessArgs(firstWitness)
      )
    );
    tx.witnesses[i] = serializedWitness.serializeJson();
    hasher.update(new Uint8Array(txHash.toArrayBuffer()));
    hasher.update(new Uint8Array(intToLeBuffer(serializedWitness.length())));
    hasher.update(new Uint8Array(serializedWitness.toArrayBuffer()));
    for (let j = i + 1; j < txTemplate.inputs.length; j++) {
      if (
        deep_equal(
          txTemplate.inputs[i].cell_output.lock,
          txTemplate.inputs[j].cell_output.lock
        )
      ) {
        used[j] = true;
        const w = new Reader(tx.witnesses[j]);
        hasher.update(new Uint8Array(intToLeBuffer(w.length())));
        hasher.update(new Uint8Array(w.toArrayBuffer()));
      }
    }
    const message = new Uint8Array(32);
    hasher.digest(message);
    messagesToSign.push({
      index: i,
      message: new Reader(message.buffer).serializeJson(),
      lock: txTemplate.inputs[i].cell_output.lock
    });
  }
  return { tx, messagesToSign };
}

export function fillSignatures(tx, messagesToSign, signatures) {
  if (messagesToSign.length != signatures.length) {
    throw new Error("Invalid number of signatures!");
  }
  for (let i = 0; i < messagesToSign.length; i++) {
    const witnessArgs = new blockchain.WitnessArgs(
      new Reader(tx.witnesses[messagesToSign[i].index])
    );
    const newWitnessArgs = {
      lock: signatures[i]
    };
    const inputType = witnessArgs.getInputType();
    if (inputType.hasValue()) {
      newWitnessArgs.input_type = new Reader(
        inputType.value().raw()
      ).serializeJson();
    }
    const outputType = witnessArgs.getOutputType();
    if (outputType.hasValue()) {
      newWitnessArgs.output_type = new Reader(
        outputType.value().raw()
      ).serializeJson();
    }
    tx.witnesses[messagesToSign[i].index] = new Reader(
      blockchain.SerializeWitnessArgs(
        normalizers.NormalizeWitnessArgs(newWitnessArgs)
      )
    ).serializeJson();
  }
  return tx;
}

export async function createLeaseCell(
  rpc,
  privateKey,
  leaseCellInfo,
  capacity
) {
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
  const leaseCell = {
    cell_output: {
      capacity: "0x" + BigInt(capacity).toString(16),
      lock: {
        code_hash:
          "0x3de0499b41e86df8ef3fb4a5712a9439ad42bf9dfeebcbd959daf7e1fac575bd",
        hash_type: "data",
        args: new Reader(serializeLeaseCellInfo(leaseCellInfo)).serializeJson()
      },
      type: null
    },
    data: null
  };
  const outputCells = [leaseCell];
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
  return filledTx;
}
