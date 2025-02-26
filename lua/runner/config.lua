return {
  mappings = {
    ["<Space>r"] = require("runner.run").start,
    ["<Space>R"] = require("runner.run").stop
  },
  debug = false,
  lang = require("runner.defaults")
}
