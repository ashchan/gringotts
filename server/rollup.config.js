import resolve from "@rollup/plugin-node-resolve";
import commonjs from "@rollup/plugin-commonjs";
import json from "@rollup/plugin-json";
import builtins from "builtin-modules";

module.exports = [
  {
    input: "src/server.js",
    output: {
      file: "build/server.js",
      format: "cjs",
      sourcemap: true
    },
    plugins: [resolve({ preferBuiltins: true }), commonjs(), json()],
    external: builtins
  }
];
