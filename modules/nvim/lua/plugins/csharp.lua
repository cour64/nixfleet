-- roslyn.nvim drives the Roslyn language server (the engine behind the VS Code
-- C# Dev Kit) and adds solution detection that plain vim.lsp.config lacks.
--
-- The server is not installed globally; a C# project provides it (plus a dotnet
-- for restore/build) through devenv. nixpkgs' roslyn-ls installs the binary as
-- Microsoft.CodeAnalysis.LanguageServer, while other distributions use
-- roslyn-language-server, so both names are accepted.
local function server_cmd()
  for _, exe in ipairs({ "Microsoft.CodeAnalysis.LanguageServer", "roslyn-language-server" }) do
    if vim.fn.executable(exe) == 1 then
      return exe
    end
  end
end

return {
  "seblyng/roslyn.nvim",
  ft = { "cs", "razor" },
  -- Stays installed but never loads outside a project that ships the server.
  cond = function()
    return server_cmd() ~= nil
  end,
  init = function()
    vim.lsp.config("roslyn", {
      cmd = {
        server_cmd(),
        "--logLevel=Information",
        "--extensionLogDirectory=" .. vim.fs.joinpath(vim.fn.stdpath("log"), "roslyn"),
        "--stdio",
      },
      settings = {
        ["csharp|inlay_hints"] = {
          csharp_enable_inlay_hints_for_implicit_variable_types = true,
        },
        ["csharp|background_analysis"] = {
          dotnet_analyzer_diagnostics_scope = "openFiles",
          dotnet_compiler_diagnostics_scope = "openFiles",
        },
      },
    })
  end,
  opts = {
    -- Finds solutions in parent directories, which suits multi-project repos.
    broad_search = true,
  },
}
