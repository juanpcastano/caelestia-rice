return {
    'windwp/nvim-ts-autotag',
    lazy = false,
    config = function()
        require('nvim-ts-autotag').setup {
            opts = {
                enable_close = true, -- cierra tag al escribir >
                enable_rename = true, -- renombra closing tag al editar opening
                enable_close_on_slash = true, -- cierra al escribir </
            },
        }
    end,
    dependencies = 'nvim-treesitter/nvim-treesitter',
}
