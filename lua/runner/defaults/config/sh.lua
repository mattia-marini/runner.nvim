local rv = require("lua.runner.defaults.config.common").new()
rv.buildAndRun = function(args)
  return { "'" .. args.default.currFile .. "' ", args.default.args }
end
return rv
