local rv = require("lua.runner.defaults.config.common").new()
rv.buildAndRun =
    function(args)
      return { "cargo", "run" }
    end
return rv
