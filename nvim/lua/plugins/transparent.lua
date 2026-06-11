return {
    'xiyaowong/transparent.nvim',
    lazy = false,
    config = function()
        require('transparent').setup {
            groups = {
                'Normal',
                'NormalNC',
                'SignColumn',
                'FoldColumn',
                'EndOfBuffer',
                'NeoTreeNormal',
                'NeoTreeNormalNC',
                'NeoTreeEndOfBuffer',
            },
        }

        vim.api.nvim_create_autocmd('ColorScheme', {
            callback = function()
                require('transparent').clear_prefix 'lualine_transparent'
                require('transparent').clear_prefix 'BufferLine'
            end,
        })

        vim.api.nvim_create_autocmd('VimEnter', {
            callback = function()
                require('transparent').clear_prefix 'lualine_transparent'
                require('transparent').clear_prefix 'BufferLine'
            end,
        })
    end,
}
