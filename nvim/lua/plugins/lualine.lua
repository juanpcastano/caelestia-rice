return {
    'nvim-lualine/lualine.nvim',
    config = function()
        local mode = {
            'mode',
            fmt = function(str)
                return ' ' .. str
            end,
        }
        local filename = {
            'filename',
            file_status = true,
            path = 0,
        }
        local hide_in_width = function()
            return vim.fn.winwidth(0) > 100
        end
        local diagnostics = {
            'diagnostics',
            sources = { 'nvim_diagnostic' },
            sections = { 'error', 'warn' },
            symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
            colored = false,
            update_in_insert = false,
            always_visible = false,
            cond = hide_in_width,
        }
        local diff = {
            'diff',
            colored = false,
            symbols = { added = ' ', modified = ' ', removed = ' ' }, -- changes diff symbols
            cond = hide_in_width,
        }

        local function color_to_hex(c)
            if not c then
                return nil
            end
            if type(c) == 'string' then
                return c
            end
            return string.format('#%06x', c)
        end

        local function get_lualine_theme()
            local norm = vim.api.nvim_get_hl(0, { name = 'Normal' })
            local fg = color_to_hex(norm.fg) or '#c0c0c0'
            local surface_bg = color_to_hex(vim.api.nvim_get_hl(0, { name = 'CursorLine' }).bg)
                or color_to_hex(vim.api.nvim_get_hl(0, { name = 'NormalFloat' }).bg)
                or '#1e1e1e'
            local pmenusel = vim.api.nvim_get_hl(0, { name = 'PmenuSel' })
            local accent_bg = color_to_hex(pmenusel.bg) or '#505050'
            local accent_fg = color_to_hex(pmenusel.fg) or '#e0e0e0'

            local function mode_theme(a_bg, a_fg, b_bg, c_bg)
                return {
                    a = { fg = a_fg, bg = a_bg, gui = 'bold' },
                    b = { fg = fg, bg = b_bg },
                    c = { fg = fg, bg = c_bg },
                    x = { fg = fg, bg = c_bg },
                    y = { fg = fg, bg = b_bg },
                    z = { fg = a_fg, bg = a_bg, gui = 'bold' },
                }
            end

            local theme = {}
            for _, m in ipairs { 'normal', 'insert', 'visual', 'replace', 'command', 'terminal' } do
                theme[m] = mode_theme(accent_bg, accent_fg, surface_bg, 'NONE')
            end
            theme.inactive = mode_theme(surface_bg, fg, surface_bg, 'NONE')
            return theme
        end

        local function build_config()
            return {
                options = {
                    icons_enabled = true,
                    theme = get_lualine_theme(),
                    -- Some useful glyphs:
                    -- https://www.nerdfonts.com/cheat-sheet
                    --        
                    section_separators = { left = '', right = '' },
                    component_separators = { left = '', right = '' },
                    disabled_filetypes = { 'alpha', 'neo-tree' },
                    always_divide_middle = true,
                },
                sections = {
                    lualine_a = { mode },
                    lualine_b = { 'branch' },
                    lualine_c = { filename },
                    lualine_x = { diagnostics, diff, { 'encoding', cond = hide_in_width }, { 'filetype', cond = hide_in_width } },
                    lualine_y = { 'location' },
                    lualine_z = { 'progress' },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { { 'filename', path = 1 } },
                    lualine_x = { { 'location', padding = 0 } },
                    lualine_y = {},
                    lualine_z = {},
                },
                tabline = {},
                extensions = { 'fugitive' },
            }
        end

        require('lualine').setup(build_config())

        vim.api.nvim_create_autocmd('ColorScheme', {
            callback = function()
                pcall(require('lualine').setup, build_config())
            end,
        })
    end,
}
