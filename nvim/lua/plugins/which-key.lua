return {
    'folke/which-key.nvim',
    config = function()
        require('which-key').setup {}

        -- Fix: check scroll keys BEFORE node lookup.
        -- Otherwise <C-d>/<C-u> get intercepted as normal mappings
        -- (e.g. from neoscroll) in the root view, breaking scroll.
        local state = require 'which-key.state'
        local orig_check = state.check
        ---@diagnostic disable-next-line: duplicate-set-field
        state.check = function(s, key)
            local View = require 'which-key.view'
            local Config = require 'which-key.config'
            if View.valid() then
                if key == Config.keys.scroll_down then
                    View.scroll(false)
                    return s.node
                elseif key == Config.keys.scroll_up then
                    View.scroll(true)
                    return s.node
                end
            end
            return orig_check(s, key)
        end
    end,
}
