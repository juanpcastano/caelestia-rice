-- Applies the caelestia colorscheme under lazy.nvim.
-- Not using lazy.nvim? Put colors/caelestia.lua on your runtimepath and call
-- vim.cmd.colorscheme("caelestia") yourself.
--
-- vim.g.caelestia_transparent = false  -- opaque background, default true

-- VimEnter so plugins shipping highlight groups have loaded first
vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    group = vim.api.nvim_create_augroup("caelestia_colorscheme", { clear = true }),
    callback = function() pcall(vim.cmd.colorscheme, "caelestia") end,
})

-- Refresh consumers after lazy.nvim has loaded their startup handlers.
vim.api.nvim_create_autocmd("User", {
    once = true,
    group = vim.api.nvim_create_augroup("caelestia_colorscheme_ready", { clear = true }),
    pattern = "VeryLazy",
    callback = function()
        if vim.g.colors_name ~= "caelestia" then return end
        pcall(vim.cmd.colorscheme, "caelestia")
        pcall(vim.api.nvim_exec_autocmds, "User", {
            pattern = "CaelestiaColorsUpdated",
            modeline = false,
        })
    end,
})

-- optional = true so this only applies if LazyVim is already installed
return {
    { "LazyVim/LazyVim", optional = true, opts = { colorscheme = "caelestia" } },
}
