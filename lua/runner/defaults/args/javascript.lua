local rv = require("lua.runner.defaults.config.common").new()
rv.buildAndRun =
    function(args)
      return {
        "cd", args.default.currFileDir,
        "&&",
        "node", args.default.currFileName, args.default.args
      }
    end
return rv
