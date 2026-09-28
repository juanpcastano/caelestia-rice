-- Personal overrides for upstream Caelestia Hyprland Lua configuration.
-- This file is loaded by hypr/hyprland.lua after variables.lua.

local scheme = require("scheme.current")

return {
    -- Apps
    terminal = "foot",
    browser = "brave",
    editor = "nvim",
    fileExplorer = "thunar",
    audioSettings = "pavucontrol",

    -- Touchpad and gestures
    touchpadDisableTyping = true,
    touchpadScrollFactor = 0.3,
    workspaceSwipeFingers = 4,
    gestureFingers = 3,
    gestureFingersMore = 4,

    -- Appearance
    blurEnabled = false,
    blurPopups = true,
    blurInputMethods = true,
    blurSize = 4,
    blurPasses = 2,
    blurXray = true,
    shadowEnabled = true,
    shadowRange = 20,
    shadowRenderPower = 3,
    shadowColour = "rgba(" .. scheme.surfaceContainer .. "d4)",
    workspaceGaps = 20,
    windowGapsIn = 10,
    windowGapsOut = 10,
    singleWindowGapsOut = 5,
    windowOpacity = 1,
    windowRounding = 10,
    windowBorderSize = 3,
    activeWindowBorderColour = "rgba(" .. scheme.primary .. "e6)",
    inactiveWindowBorderColour = "rgba(" .. scheme.onSurfaceVariant .. "11)",

    -- Misc
    volumeStep = 5,
    cursorTheme = "Graphite-dark-nord-cursors",
    cursorSize = 16,

    -- Workspaces
    kbGoToWs = "SUPER",
    kbMoveWinToWs = "SUPER + SHIFT",
    kbMoveWinToWsNext = "SUPER + SHIFT + L",
    kbMoveWinToWsPrev = "SUPER + SHIFT + H",
    kbNextWs = "CTRL + SUPER + L",
    kbPrevWs = "CTRL + SUPER + H",

    -- Window actions
    kbMoveWindow = "SUPER + Z",
    kbResizeWindow = "SUPER + X",
    kbWindowPip = "SUPER + ALT + P",
    kbWindowFullscreen = "SUPER + F",
    kbWindowBorderedFullscreen = "SUPER + ALT + F",
    kbToggleWindowFloating = "SUPER + P",
    kbCloseWindow = "SUPER + C",
    kbCenterWindow = "CTRL + SUPER + Backslash",
    kbNormalizeWindow = "CTRL + SUPER + ALT + Backslash",

    -- Apps
    kbTerminal = "SUPER + T",
    kbBrowser = "SUPER + W",
    kbEditor = "SUPER + SHIFT + E",
    kbFileExplorer = "SUPER + E",
    kbAudioSettings = "CTRL + ALT + V",

    -- Utilities
    kbScreenshot = "Print",
    kbScreenshotFreeze = "SUPER + SHIFT + ALT + S",
    kbScreenshotRegion = "SUPER + SHIFT + S",
    kbRecord = "CTRL + ALT + R",
    kbRecordSound = "SUPER + ALT + R",
    kbRecordRegion = "SUPER + SHIFT + ALT + R",
    kbColorPicker = "SUPER + SHIFT + C",

    -- Media and system
    kbMediaToggle = "CTRL + SUPER + Space",
    kbMediaNext = "CTRL + SUPER + Equal",
    kbMediaPrev = "CTRL + SUPER + Minus",
    kbSession = "CTRL + ALT + Delete",
    kbClearNotifs = "SUPER + N",
    kbShowPanels = "SUPER + M",
    kbLock = "SUPER + B",
    kbRestoreLock = "SUPER + ALT + B",

    -- Keep upstream's extra features while avoiding collisions with this rice.
    kbLauncher = {}, -- bound in hypr-user.lua with the original release behavior
    kbSpecialWs = "SUPER + Grave",
    kbSystemMonitorWs = "CTRL + SHIFT + Escape",
    kbMusicWs = "SUPER + SHIFT + M",
    kbCommunicationWs = "SUPER + SHIFT + D",
    kbTodoWs = "SUPER + SHIFT + R",
    kbShowSidebar = "SUPER + SHIFT + N",
    kbPinWindow = "SUPER + SHIFT + P",
    kbSleep = "SUPER + SHIFT + B",
}
