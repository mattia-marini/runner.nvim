---@class BuildConfig
---@field supported boolean
---@field userArgs fun()
---@field build fun(args: RunnerArgs):string
---@field run fun(args: RunnerArgs):string
---@field buildAndRun fun(args: RunnerArgs):string
---@field mappings table


return {
  new = function()
    return {
      supported = true,
      userArgs = function()
      end,
      build = function(args)
        return ""
      end,
      run = function(args)
        return ""
      end,
      buildAndRun = function(args)
        return ""
      end,
      mappings = {}
    }
  end
}
