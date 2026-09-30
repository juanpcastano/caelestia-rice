-- Personal Hyprland additions, loaded after the upstream Caelestia modules.

-- Keyboard and pointer preferences not exposed by upstream variables.lua.
hl.config({
    input = {
        kb_layout          = "us",
        kb_variant         = "intl",
        kb_model           = "",
        kb_options         = "caps:escape",
        kb_rules           = "",
        numlock_by_default = true,
        follow_mouse       = 1,
        sensitivity        = 0,
        accel_profile      = "flat",
        natural_scroll     = false,
    },
    misc = {
        -- Keep the lockscreen background blurred while workspaces remain rendered.
        session_lock_blur = true,
    },
})

-- Keep the original vim-style navigation and move-window shortcuts.
for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
    hl.bind("SUPER + " .. key, hl.dsp.focus({ direction = direction }))
    hl.bind("SUPER + ALT + " .. key, hl.dsp.window.move({ direction = direction }))
end

-- Open the launcher on Super+Space release, matching the previous bindr.
hl.bind("SUPER + Space", hl.dsp.global("caelestia:launcher"), { release = true })

-- Watch Caelestia's generated Spicetify theme while Spotify is open.
hl.on("window.open", function(win)
    if type(win.class) ~= "string" or win.class:lower() ~= "spotify" then return end
    hl.exec_cmd('nohup "$HOME/.local/bin/caelestia-spicetify-watch" >/dev/null 2>&1 &')
end)

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start hyprpolkitagent.service")
    hl.exec_cmd("nohup \"$HOME/.local/bin/caelestia-watcher\" >/dev/null 2>&1 &")
end)
