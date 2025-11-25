---@type RunnerJavaArgs
local M = {}

---@class RunnerJavaArgs
---@field common RunnerCommonArgs Common args for all projects
---@field maven JavaMavenArgs Args specific to maven projects

---@class JavaMavenArgs
---@field root fun(): string? The root of the current venv-based project

---@class JavaSingleFile
---@field root fun(): string? The root directory of the current single .py file

M.common = require("runner.args.common")

M.maven = {}
function M.maven.root()
  -- Looks for 'pyproject.toml', 'requirements.txt', or 'venv' directory
  return
      vim.fs.root(0,
        {
          -- Maven
          'mvnw',
          'pom.xml',
          'gradlew',
          'settings.gradle',
          'settings.gradle.kts',
          -- Gradle
          'build.gradle',
          'build.gradle.kts',
          -- Ant
          'build.xml',
          -- Git
          '.git',
        }
      )
end

M.single_file = {}
function M.single_file.root()
  return vim.fs.dirname(vim.api.nvim_buf_get_name(0))
end

return M
