return {
    dir = '~/repos/caelestia-nvim',
    priority = 1000,
    lazy = false,
    config = function()
        require('caelestia').setup()
        vim.cmd.colorscheme 'caelestia'
    end,
}
