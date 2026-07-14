-- Neovim configuration
-- Theme is managed by Noctalia shell via matugen.lua

-- ── Leader ───────────────────────────────────────────────────────────────────
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ── Basic Options ────────────────────────────────────────────────────────────
local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = false
opt.smartindent = true
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.termguicolors = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.updatetime = 250
opt.splitright = true
opt.splitbelow = true
opt.cursorline = true
opt.showmode = false
opt.laststatus = 3
opt.clipboard = "unnamedplus"
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- ── Theme (Noctalia) ─────────────────────────────────────────────────────────
-- Requires the base16-colorscheme plugin
-- Install with: :lazy install nvim-base16
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Base16 colorscheme (required by Noctalia matugen theme)
    {
        "RRethy/nvim-base16",
        lazy = false,
        priority = 1000,
    },
}, {
    install = { colorscheme = { "base16" } },
})

-- Load Noctalia theme
pcall(function()
    require("matugen").setup()
end)

-- ── Keymaps ──────────────────────────────────────────────────────────────────
local map = vim.keymap.set
map("n", "<leader>w", ":w<CR>", { desc = "Save" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
map("n", "<leader>bd", ":bd<CR>", { desc = "Close buffer" })
map("n", "<Esc>", ":nohlsearch<CR>", { desc = "Clear search" })
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("n", "<leader>sv", ":vsplit<CR>", { desc = "Split vertical" })
map("n", "<leader>sh", ":split<CR>", { desc = "Split horizontal" })