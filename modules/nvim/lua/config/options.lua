vim.g.mapleader = " "
vim.g.maplocalleader = " "

local o = vim.o

o.number = true
o.relativenumber = true
o.cursorline = true
o.signcolumn = "yes"
o.wrap = false
o.scrolloff = 8
o.winborder = "rounded"

o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true

o.ignorecase = true
o.smartcase = true

o.splitright = true
o.splitbelow = true

o.undofile = true
o.swapfile = false
o.confirm = true
o.updatetime = 250

o.clipboard = "unnamedplus"

-- Built-in autocompletion (Neovim 0.12). 'noselect' is implied while
-- 'autocomplete' is set, so <C-y> accepts and <C-e> dismisses.
o.autocomplete = true
o.completeopt = "menu,menuone,popup,fuzzy"
