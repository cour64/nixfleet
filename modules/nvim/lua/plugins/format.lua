return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      python = { "ruff_fix", "ruff_format" },
      lua = { "stylua" },
      nix = { "nixfmt" },
      cs = { "csharpier" },
      -- Oxfmt file types: https://oxc.rs/docs/guide/usage/formatter/language-support.html
      javascript = { "oxfmt" },
      javascriptreact = { "oxfmt" },
      typescript = { "oxfmt" },
      typescriptreact = { "oxfmt" },
      json = { "oxfmt" },
      jsonc = { "oxfmt" },
      json5 = { "oxfmt" },
      css = { "oxfmt" },
      scss = { "oxfmt" },
      less = { "oxfmt" },
      postcss = { "oxfmt" },
      graphql = { "oxfmt" },
      toml = { "oxfmt" },
      yaml = { "oxfmt" },
      html = { "oxfmt" },
      vue = { "oxfmt" },
      svelte = { "oxfmt" },
      markdown = { "oxfmt" },
      mdx = { "oxfmt" },
      handlebars = { "oxfmt" },
      mjml = { "oxfmt" },
    },
    default_format_opts = { lsp_format = "fallback" },
    format_on_save = { timeout_ms = 2000 },
    -- Formatters come from the project, so a missing one is expected rather
    -- than an error: conform skips it and falls back to LSP formatting.
    notify_no_formatters = false,
  },
}
