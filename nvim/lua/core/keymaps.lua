-- Set leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Disable the spacebar key's default behavior in Normal and Visual modes
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<C-Space>', '<Nop>', { silent = true })

-- For conciseness
local opts = { noremap = true, silent = true }

-- Allow moving the cursor through wrapped lines with j, k
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- clear highlights
vim.keymap.set('n', '<Esc>', ':noh<CR>', opts)

-- save file
vim.keymap.set('n', '<C-s>', '<cmd> w <CR>', vim.tbl_extend('force', opts, { desc = 'Save file' }))

-- save file without auto-formatting
vim.keymap.set('n', '<C-S-s>', '<cmd>noautocmd w <CR>', vim.tbl_extend('force', opts, { desc = 'Save file without auto-formatting' }))

-- quit file
vim.keymap.set('n', '<C-q>', '<cmd> q <CR>', vim.tbl_extend('force', opts, { desc = 'Quit' }))

-- delete single character without copying into register
vim.keymap.set('n', 'x', '"_x', vim.tbl_extend('force', opts, { desc = 'Delete character without copying' }))

-- Find and center
vim.keymap.set('n', 'n', 'nzzzv', vim.tbl_extend('force', opts, { desc = 'Next search result and center' }))
vim.keymap.set('n', 'N', 'Nzzzv', vim.tbl_extend('force', opts, { desc = 'Previous search result and center' }))

-- Resize with arrows
vim.keymap.set('n', '<Up>', ':resize -2<CR>', vim.tbl_extend('force', opts, { desc = 'Resize split up' }))
vim.keymap.set('n', '<Down>', ':resize +2<CR>', vim.tbl_extend('force', opts, { desc = 'Resize split down' }))
vim.keymap.set('n', '<Left>', ':vertical resize +2<CR>', vim.tbl_extend('force', opts, { desc = 'Resize split left' }))
vim.keymap.set('n', '<Right>', ':vertical resize -2<CR>', vim.tbl_extend('force', opts, { desc = 'Resize split right' }))

-- Buffers
vim.keymap.set('n', '<C-Tab>', ':bnext<CR>', vim.tbl_extend('force', opts, { desc = 'Next buffer' }))
vim.keymap.set('n', '<C-S-Tab>', ':bprevious<CR>', vim.tbl_extend('force', opts, { desc = 'Previous buffer' }))
vim.keymap.set('n', '<leader>bx', ':Bdelete!<CR>', vim.tbl_extend('force', opts, { desc = 'Close buffer' }))
vim.keymap.set('n', '<leader>bn', '<cmd> enew <CR>', vim.tbl_extend('force', opts, { desc = 'New buffer' }))

-- Window management
vim.keymap.set('n', '<leader>wv', '<C-w>v', vim.tbl_extend('force', opts, { desc = 'Split window vertically' }))
vim.keymap.set('n', '<leader>w-', '<C-w>v', vim.tbl_extend('force', opts, { desc = 'Split window vertically' }))
vim.keymap.set('n', '<leader>wh', '<C-w>s', vim.tbl_extend('force', opts, { desc = 'Split window horizontally' }))
vim.keymap.set('n', '<leader>w\\', '<C-w>s', vim.tbl_extend('force', opts, { desc = 'Split window horizontally' }))
vim.keymap.set('n', '<leader>we', '<C-w>=', vim.tbl_extend('force', opts, { desc = 'Make split windows equal' }))
vim.keymap.set('n', '<leader>wx', ':close<CR>', vim.tbl_extend('force', opts, { desc = 'Close split window' }))

-- Navigate between splits
vim.keymap.set('n', '<C-k>', ':wincmd k<CR>', vim.tbl_extend('force', opts, { desc = 'Navigate to split above' }))
vim.keymap.set('n', '<C-j>', ':wincmd j<CR>', vim.tbl_extend('force', opts, { desc = 'Navigate to split below' }))
vim.keymap.set('n', '<C-h>', ':wincmd h<CR>', vim.tbl_extend('force', opts, { desc = 'Navigate to split left' }))
vim.keymap.set('n', '<C-l>', ':wincmd l<CR>', vim.tbl_extend('force', opts, { desc = 'Navigate to split right' }))

-- Toggle line wrapping
vim.keymap.set('n', '<leader>tz', '<cmd>set wrap!<CR>', vim.tbl_extend('force', opts, { desc = 'Toggle line wrapping' }))

-- Stay in indent mode
vim.keymap.set('v', '<', '<gv', vim.tbl_extend('force', opts, { desc = 'Indent left' }))
vim.keymap.set('v', '>', '>gv', vim.tbl_extend('force', opts, { desc = 'Indent right' }))

-- Move text up and down
vim.keymap.set('v', '<A-j>', ":m '<1<CR>gv=gv", vim.tbl_extend('force', opts, { desc = 'Move text down' }))
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", vim.tbl_extend('force', opts, { desc = 'Move text up' }))

-- Keep last yanked when pasting
vim.keymap.set('v', 'p', '"_dP', vim.tbl_extend('force', opts, { desc = 'Paste without yanking' }))

-- Replace word under cursor
vim.keymap.set('n', '<leader>j', '*``cgn', vim.tbl_extend('force', opts, { desc = 'Replace word under cursor' }))

-- Toggle diagnostics
local diagnostics_active = true

vim.keymap.set('n', '<leader>td', function()
    diagnostics_active = not diagnostics_active

    if diagnostics_active then
        vim.diagnostic.enable(true)
    else
        vim.diagnostic.enable(false)
    end
end, { desc = 'Toggle diagnostics' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', function()
    vim.diagnostic.jump { count = -1, float = { focusable = true } }
end, { desc = 'Go to previous diagnostic message' })

vim.keymap.set('n', ']d', function()
    vim.diagnostic.jump { count = 1, float = { focusable = true } }
end, { desc = 'Go to next diagnostic message' })

vim.keymap.set('n', '<leader>d', function()
    vim.diagnostic.open_float { focusable = true }
end, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
