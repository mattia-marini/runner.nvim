---@class BuildConfig
---@field userArgs fun()
---@field build fun(args: RunnerArgs):string
---@field run fun(args: RunnerArgs):string
---@field buildAndRun fun(args: RunnerArgs):string
---@field mappings table

---@type {new: fun(nil):BuildConfig}
return {
  new = function()
    return {
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
