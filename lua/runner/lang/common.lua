---@class BuildConfig
---@field single_file boolean Whether the language is a single file language
---@field root fun():string?|nil Function that returns the project root directory, or nil to use the default root detection
---@field build fun(args:table<string, any>, runargs: table<string, string>):string Function that returns the build command
---@field run fun(args:table<string, any>, runargs: table<string, string>):string Function that returns the command to run the already build project
---@field build_and_run fun(args:table<string, any>, runargs: table<string, string>):string Function that returns the command to build and run the project
---@field mappings table<string, function> Key mappings specific to this language
---@field runargs table<string, RunargSpecifier> Additional user-provided arguments, set with :Runargs

---@alias RunargSpecifier string|boolean|string[]|ComplexRunargSpecifier

---@class ComplexRunargSpecifier
---@field default string|boolean
---@field value? string|boolean
---@field complete? function(arglead:string, cmdline:string, cursorpos:number):string[]
---@field check? function(value:string):boolean
---@field map? function(value:string):string

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
    }
  end
}
