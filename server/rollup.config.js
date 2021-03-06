import resolve from "@rollup/plugin-node-resolve";
import commonjs from "@rollup/plugin-commonjs";
import json from "@rollup/plugin-json";
import builtins from "builtin-modules";

module.exports = [
  "server",
  "create_lease_cell",
  "deploy_contract",
  "issue_udt_token"
].map(filename => {
  return {
    input: "src/" + filename + ".js",
    output: {
      file: "build/" + filename + ".js",
      format: "cjs",
      sourcemap: true
    },
    plugins: [resolve({ preferBuiltins: true }), commonjs(), json()],
    external: builtins.concat([
      "ckb-js-toolkit",
      "nohm",
      "blake2b",
      "secp256k1",
      "express",
      "redis",
      "body-parser",
      "uuid"
    ])
  };
});
