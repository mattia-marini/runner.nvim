local rv = require("runner.defaults.common").new()
rv.buildAndRun = function(args)
  return "'"..args.default.currFile .. "' " .. args.default.args
end
return rv
