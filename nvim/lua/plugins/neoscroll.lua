return {
    'karb94/neoscroll.nvim',
    config = function()
        require('neoscroll').setup {
            mappings = { '<C-u>', '<C-d>', 'zt', 'zz', 'zb' },
            hide_cursor = true,
            stop_eof = true,
            respect_scrolloff = false,
            cursor_scrolls_alone = true,
            easing_function = 'quadratic',
            duration_multiplier = 0.5,
        }

        local ns = require 'neoscroll'
        vim.keymap.set({ 'n', 'v', 'x' }, '<C-u>', function()
            ns.ctrl_u { duration = 250 }
        end, { desc = 'Scroll up' })
        vim.keymap.set({ 'n', 'v', 'x' }, '<C-d>', function()
            ns.ctrl_d { duration = 250 }
        end, { desc = 'Scroll down' })
        vim.keymap.set({ 'n', 'v', 'x' }, 'zt', function()
            ns.zt { half_win_duration = 250 }
        end, { desc = 'Scroll cursor to top' })
        vim.keymap.set({ 'n', 'v', 'x' }, 'zz', function()
            ns.zz { half_win_duration = 250 }
        end, { desc = 'Scroll cursor to center' })
        vim.keymap.set({ 'n', 'v', 'x' }, 'zb', function()
            ns.zb { half_win_duration = 250 }
        end, { desc = 'Scroll cursor to bottom' })
    end,
}
