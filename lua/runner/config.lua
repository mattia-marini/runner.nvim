return {
  mappings = {
    ["<Space>r"] = require("runner.run").start,
    ["<Space>R"] = require("runner.run").stop
  },
  lang = {
    cpp        = require("runner.defaults.cpp"),
    c          = require("runner.defaults.c"),
    javascript = require("runner.defaults.javascript"),
    lua        = require("runner.defaults.lua"),
    sh         = require("runner.defaults.sh"),
    rust       = require("runner.defaults.rust")
  }
}
