-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Workaround for checkhealth hanging in nvim 0.11.5
-- Use :Health [module] instead of :checkhealth
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("config.healthcheck-fix")
  end,
})
