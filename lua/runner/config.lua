return {
  mappings = {
    ["<Space>r"] = require("runner.run").start,
    ["<Space>R"] = require("runner.run").stop
  },
  cpp = require("runner.defaults.cpp"),
  lua = require("runner.defaults.cpp")
}
