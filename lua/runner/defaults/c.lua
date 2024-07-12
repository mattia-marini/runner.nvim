local rv = require("runner.defaults.common").new()
rv.buildAndRun =
    function(args)
      return "cd " .. args.default.currFileDir .. " && clang " .. args.default.currFileName .. " && ./a.out " .. args.default.args
    end
return rv
