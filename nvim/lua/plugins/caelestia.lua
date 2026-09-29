-- Applies the caelestia colorscheme under lazy.nvim.
-- Not using lazy.nvim? Put colors/caelestia.lua on your runtimepath and call
-- vim.cmd.colorscheme("caelestia") yourself.
--
-- vim.g.caelestia_transparent = false  -- opaque background, default true

-- VimEnter so plugins shipping highlight groups have loaded first
vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    group = vim.api.nvim_create_augroup("caelestia_colorscheme", { clear = true }),
    callback = function()
        pcall(vim.cmd.colorscheme, "caelestia")

        -- Startup plugins and other VimEnter handlers can still adjust their
        -- highlights after the colorscheme's ColorScheme event. Refresh
        -- consumers from the final palette once startup callbacks have run.
        vim.schedule(function()
            if vim.g.colors_name ~= "caelestia" then return end
            pcall(vim.api.nvim_exec_autocmds, "User", {
                pattern = "CaelestiaColorsUpdated",
                modeline = false,
            })
        end)
    end,
})

-- optional = true so this only applies if LazyVim is already installed
return {
    { "LazyVim/LazyVim", optional = true, opts = { colorscheme = "caelestia" } },
}
