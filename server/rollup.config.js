import resolve from "@rollup/plugin-node-resolve";
import commonjs from "@rollup/plugin-commonjs";
import json from "@rollup/plugin-json";
import builtins from "builtin-modules";

module.exports = ["server", "debug", "deploy_contract"].map(filename => {
  return {
    input: "src/" + filename + ".js",
    output: {
      file: "build/" + filename + ".js",
      format: "cjs",
      sourcemap: true
    },
    plugins: [resolve({ preferBuiltins: true }), commonjs(), json()],
    external: builtins.concat(["ckb-js-toolkit", "nohm", "blake2b", "secp256k1", "express", "redis"])
  }
});
