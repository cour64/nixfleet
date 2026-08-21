-- Order matters: options sets the leader before lazy loads any plugin specs,
-- and lsp runs after lazy so plugin modules are requirable.
require("config.options")
require("config.lazy")
require("config.lsp")
require("config.keymaps")
