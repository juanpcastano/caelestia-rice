return { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSInstall lua python javascript typescript vimdoc vim regex terraform sql dockerfile toml json java go gitignore graphql yaml make cmake markdown markdown_inline bash fish tsx jsx css html astro rust',
    opts = {},
}
