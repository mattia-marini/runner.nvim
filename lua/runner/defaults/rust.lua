local rv = require("runner.defaults.common").new()
rv.buildAndRun =
    function(args)
      return { "cargo", "run" }
    end
return rv
