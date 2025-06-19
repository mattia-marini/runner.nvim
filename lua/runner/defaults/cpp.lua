local rv = require("runner.defaults.common").new()
rv.buildAndRun =
    function(args)
      return {
        "cd",
        args.default.currFileDir,
        "&&", "clang++", "-std=c++17",
        args.default.currFileName,
        "&&", "./a.out",
        args.default.args
      }
    end
return rv
