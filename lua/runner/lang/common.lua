---@class BuildConfig
---@field single_file boolean Whether the language is a single file language
---@field root fun():string?|nil Function that returns the project root directory, or nil to use the default root detection
---@field build fun(args:table<string, any>, runargs: table<string, string>):string Function that returns the build command
---@field run fun(args:table<string, any>, runargs: table<string, string>):string Function that returns the command to run the already build project
---@field build_and_run fun(args:table<string, any>, runargs: table<string, string>):string Function that returns the command to build and run the project
---@field mappings table<string, function> Key mappings specific to this language
---@field runargs table<string, RunargSpecifier> Additional user-provided arguments, set with :Runargs
---@field runargs_base fun():string|"root"|"buffer"  Where to store the application args set by the :Runargs command.
---buffer: store in buffer variable
---root: store based on project root
---if a function is provided, it will be called to determine where to store the args

---@alias RunargSpecifier string|boolean|string[]|ComplexRunargSpecifier

---@class ComplexRunargSpecifier
---@field value string|boolean|string[]
---@field complete? function(arglead:string, cmdline:string, cursorpos:number):string[]
---@field check? function():boolean

return {
  ---@return BuildConfig
  new = function()
    return {
      single_file = false,
      root = nil,
      build = function(args, runargs)
        return ""
      end,
      run = function(args, runargs)
        return ""
      end,
      build_and_run = function(args, runargs)
        return ""
      end,
      mappings = {},
      runargs = {},
      runargs_base = "root",
    }
  end
}
