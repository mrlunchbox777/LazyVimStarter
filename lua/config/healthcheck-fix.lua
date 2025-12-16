-- Workaround for :checkhealth hanging due to nvim-treesitter
-- Root cause: nvim-treesitter health check hangs when checking parser queries
--
-- TEMPORARY FIX: Disable treesitter health check
vim.g.loaded_nvim_treesitter_health = 1

-- Also provide a custom LazyHealth command that skips treesitter
vim.api.nvim_create_user_command("SafeHealth", function(opts)
  local modules = {
    "lazy",
    "nvim",
    "provider",
    "vim.lsp",
    -- Skip: vim.treesitter and nvim-treesitter as they hang
  }
  
  if opts.args ~= "" then
    -- User specified a module
    vim.cmd("checkhealth " .. opts.args)
  else
    -- Run safe subset of health checks
    for _, mod in ipairs(modules) do
      vim.cmd("checkhealth " .. mod)
    end
  end
end, {
  nargs = "?",
  desc = "Run health checks (excluding treesitter which hangs)",
})

vim.api.nvim_create_user_command("SafeLazyHealth", function()
  vim.cmd("checkhealth lazy")
end, {
  desc = "Run Lazy health check only",
})
