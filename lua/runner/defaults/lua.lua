local rv = require("runner.defaults.common").new()
rv.buildAndRun =
    function(args)
      return "lua " .. args.default.currFile .. " " .. args.default.args
    end
return rv
