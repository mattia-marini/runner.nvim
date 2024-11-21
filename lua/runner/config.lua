return {
  mappings = {
    ["<Space>r"] = require("runner.run").start,
    ["<Space>R"] = require("runner.run").stop
  },
  lang = require("runner.defaults")
}
