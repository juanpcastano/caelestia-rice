-- Caelestia's upstream colorscheme is shipped in this config's colors/ dir.
-- It watches scheme.json and reapplies colors after Caelestia changes the theme.

vim.g.caelestia_transparent = true

vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    group = vim.api.nvim_create_augroup("caelestia_colorscheme", { clear = true }),
    callback = function()
        pcall(vim.cmd.colorscheme, "caelestia")
    end,
})
