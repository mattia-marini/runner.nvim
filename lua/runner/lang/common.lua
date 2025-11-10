---@class BuildConfig
---@field single_file boolean Whether the language is a single file language
---@field root fun():string?|nil Function that returns the project root directory, or nil to use the default root detection
---@field build fun():string Function that returns the build command
---@field run fun():string Function that returns the command to run the already build project
---@field build_and_run fun():string Function that returns the command to build and run the project
---@field mappings table<string, function> Key mappings specific to this language
---@field runargs table<string, string> Additional user-provided arguments, set with :Runargs
---@field runargs_base fun():string|"root"|"buffer"  Where to store the application args set by the :Runargs command.
---buffer: store in buffer variable
---root: store based on project root
---if a function is provided, it will be called to determine where to store the args


return {
  ---@return BuildConfig
  new = function()
    return {
      single_file = false,
      root = nil,
      build = function()
        return ""
      end,
      run = function()
        return ""
      end,
      build_and_run = function()
        return ""
      end,
      mappings = {},
      runargs = {},
      runargs_base = "root",
    }
  end
}
