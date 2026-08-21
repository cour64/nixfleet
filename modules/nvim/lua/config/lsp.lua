-- Neovim configures servers natively, so nvim-lspconfig is not needed.
--
-- Every server is declared here, but vim.lsp only starts one whose cmd is on
-- PATH: it validates executability per buffer and, when the command is missing,
-- logs to the LSP log rather than notifying. Only nixd and lua_ls are installed
-- globally (this repo's own languages); projects provide the rest through
-- devenv + direnv, so a TypeScript checkout starts vtsls and never attempts the
-- C# or Python servers.
--
-- The consequence is that Neovim inherits PATH at startup: launch nvim from
-- inside the project directory so direnv has already loaded its environment.

local js_filetypes = {
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
}

local servers = {
  basedpyright = {
    cmd = { "basedpyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
    settings = {
      basedpyright = {
        analysis = {
          typeCheckingMode = "standard",
          diagnosticSeverityOverrides = {
            -- ruff owns import hygiene
            reportUnusedImport = "none",
          },
        },
      },
    },
  },

  ruff = {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
  },

  vtsls = {
    cmd = { "vtsls", "--stdio" },
    filetypes = js_filetypes,
    root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
  },

  eslint = {
    cmd = { "vscode-eslint-language-server", "--stdio" },
    filetypes = js_filetypes,
    root_markers = {
      "eslint.config.js",
      "eslint.config.mjs",
      ".eslintrc.js",
      ".eslintrc.json",
      "package.json",
    },
  },

  jsonls = {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
    init_options = { provideFormatter = true },
  },

  html = {
    cmd = { "vscode-html-language-server", "--stdio" },
    filetypes = { "html" },
    init_options = {
      configurationSection = { "html", "css", "javascript" },
      embeddedLanguages = { css = true, javascript = true },
      provideFormatter = true,
    },
  },

  cssls = {
    cmd = { "vscode-css-language-server", "--stdio" },
    filetypes = { "css", "scss", "less" },
    init_options = { provideFormatter = true },
  },

  lua_ls = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", "stylua.toml", ".git" },
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },

  nixd = {
    cmd = { "nixd" },
    filetypes = { "nix" },
    root_markers = { "flake.nix", ".git" },
  },
}

for name, cfg in pairs(servers) do
  vim.lsp.config(name, cfg)
end
vim.lsp.enable(vim.tbl_keys(servers))

-- Native LSP completion. 'complete' is buffer-local, so the omnifunc source is
-- added only where a server actually attached.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.lsp.completion.enable(true, args.data.client_id, args.buf, { autotrigger = true })
    vim.bo[args.buf].complete = ".,o"
  end,
})

-- Reports which servers the current project actually supplies.
vim.api.nvim_create_user_command("LspAvailable", function()
  local lines = {}
  for _, name in ipairs(vim.fn.sort(vim.tbl_keys(servers))) do
    local cmd = servers[name].cmd[1]
    local found = vim.fn.exepath(cmd)
    table.insert(lines, ("%-14s %s"):format(name, found ~= "" and found or "-- not on PATH"))
  end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end, { desc = "Show which language servers are on PATH" })

vim.diagnostic.config({
  virtual_text = { spacing = 2 },
  severity_sort = true,
  float = { border = "rounded", source = true },
})
