-- The plugin validates highlight groups before Caelestia applies its scheme.
vim.api.nvim_set_hl(0, 'CaelestiaIndent', { link = 'Comment', default = true })

return {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
        indent = {
            char = '▏',
            highlight = 'CaelestiaIndent',
        },
        scope = {
            highlight = 'CaelestiaIndent',
            show_start = false,
            show_end = false,
            show_exact_scope = false,
        },
        exclude = {
            filetypes = {
                'help',
                'startify',
                'dashboard',
                'packer',
                'neogitstatus',
                'NvimTree',
                'Trouble',
            },
        },
    },
    config = function(_, opts)
        local ibl = require('ibl')
        ibl.setup(opts)

        local group = vim.api.nvim_create_augroup('caelestia_ibl', { clear = true })
        local refresh_highlights = function() pcall(ibl.update, {}) end
        for _, pattern in ipairs({ 'VeryLazy', 'CaelestiaColorsUpdated' }) do
            vim.api.nvim_create_autocmd('User', {
                group = group,
                pattern = pattern,
                callback = refresh_highlights,
            })
        end
    end,
}
