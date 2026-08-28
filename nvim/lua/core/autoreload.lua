-- Real-time auto-reload using libuv fs_event watchers (inotify on Linux).
-- `autoread` + CursorHold/FocusGained only fire on user activity; this watches
-- the file's directory on disk and reloads the moment the file changes.
-- One watcher per unique directory, shared across buffers in that directory.

local dir_watchers = {} -- dirpath -> { handle, bufs = { [bufnr] = basename } }
local buf_to_dir = {} -- bufnr -> dirpath

local function untrack(bufnr)
    local dir = buf_to_dir[bufnr]
    if not dir then return end
    buf_to_dir[bufnr] = nil
    local w = dir_watchers[dir]
    if not w then return end
    w.bufs[bufnr] = nil
    if next(w.bufs) == nil then
        w.handle:stop()
        if not w.handle:is_closing() then w.handle:close() end
        dir_watchers[dir] = nil
    end
end

local function track(bufnr)
    local path = vim.api.nvim_buf_get_name(bufnr)
    if path == '' then return end
    local stat = vim.uv.fs_stat(path)
    if not stat or stat.type ~= 'file' then return end
    local dir = vim.fn.fnamemodify(path, ':h')
    local filename = vim.fn.fnamemodify(path, ':t')
    local w = dir_watchers[dir]
    if not w then
        local handle = vim.uv.new_fs_event()
        if not handle then return end
        w = { handle = handle, bufs = {} }
        handle:start(dir, { recursive = false }, function(err, fname)
            if err or not fname then return end
            vim.schedule(function()
                for b, name in pairs(w.bufs) do
                    if name == fname and vim.api.nvim_buf_is_valid(b) and not vim.bo[b].modified then
                        vim.cmd('checktime ' .. b)
                    end
                end
            end)
        end)
        dir_watchers[dir] = w
    end
    w.bufs[bufnr] = filename
    buf_to_dir[bufnr] = dir
end

vim.api.nvim_create_autocmd('BufReadPost', {
    group = vim.api.nvim_create_augroup('auto_reload_watch', { clear = true }),
    callback = function(a)
        if vim.bo[a.buf].buftype == '' then track(a.buf) end
    end,
})

vim.api.nvim_create_autocmd({ 'BufWipeout', 'BufDelete' }, {
    group = vim.api.nvim_create_augroup('auto_reload_cleanup', { clear = true }),
    callback = function(a)
        untrack(a.buf)
    end,
})
