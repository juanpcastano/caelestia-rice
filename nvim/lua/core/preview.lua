-- VSCode-style preview buffers: files opened (without editing) get wiped
-- when abandoned; the first modification "pins" the buffer into the tabline.

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  group = vim.api.nvim_create_augroup('preview_buf', { clear = true }),
  callback = function(a)
    if vim.bo[a.buf].buftype == '' and not vim.bo[a.buf].modified then
      vim.bo[a.buf].bufhidden = 'wipe'
    end
  end,
})

vim.api.nvim_create_autocmd('BufModifiedSet', {
  group = vim.api.nvim_create_augroup('preview_pin', { clear = true }),
  callback = function(a)
    if vim.bo[a.buf].modified then
      vim.bo[a.buf].bufhidden = 'hide'
    end
  end,
})
