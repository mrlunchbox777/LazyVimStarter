-- Workaround for :checkhealth and :LazyHealth hanging in nvim 0.11.5
-- Root cause: checkhealth buffer rendering hangs when waiting for terminal output
-- This is a known issue with nvim 0.11.x + tmux on macOS
--
-- TEMPORARY FIX: Run checkhealth via script wrapper  
-- The issue will be with your terminal/tmux/nvim interaction.
--
-- To manually run health checks until this is fixed:
--   bash ~/.config/nvim/checkhealth.sh [module_name]
--
-- Or upgrade/downgrade nvim when a fix is available

vim.notify(
  "Note: :checkhealth and :LazyHealth may hang due to nvim 0.11.5 + tmux issue.\n" ..
  "Use: bash ~/.config/nvim/checkhealth.sh [module] as a workaround",
  vim.log.levels.WARN
)
