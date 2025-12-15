# Checkhealth Hanging Issue

## Problem
Running `:checkhealth` or `:LazyHealth` in neovim causes it to hang/freeze and eventually crash.

## Root Cause
This is a known issue with **Neovim 0.11.5** when running inside **tmux** on macOS. The checkhealth command tries to render output to a buffer, but something in the terminal/tmux interaction causes it to hang indefinitely.

The issue occurs even with `nvim --clean`, indicating it's not plugin-related but rather a core nvim + terminal compatibility issue.

## Workaround

Use the provided bash wrapper script:

```bash
# Run health check for all modules
bash ~/.config/nvim/checkhealth.sh

# Run health check for specific module
bash ~/.config/nvim/checkhealth.sh lazy
bash ~/.config/nvim/checkhealth.sh vim.lsp
bash ~/.config/nvim/checkhealth.sh nvim-treesitter
```

## Permanent Solution

One of these should fix the issue:

1. **Wait for nvim update**: The issue may be fixed in a future neovim release
2. **Downgrade neovim**: Try nvim 0.10.x if this is critical
3. **Run outside tmux**: Exit tmux and run `:checkhealth` directly
4. **Use headless mode**: `nvim --headless +"checkhealth lazy" +"w health.txt" +qa` (though this also hangs for you)

## Technical Details

- Neovim version: 0.11.5
- Terminal: tmux inside terminal
- OS: macOS (Darwin)
- The hang occurs when checkhealth tries to display the buffer
- Process enters interruptible sleep state (waiting for something)
- Even `--clean` and `--noplugin` modes exhibit the issue

## Related
- Your latest commit removed `copilot-cmp` from lazy-lock.json which also needed to be restored
- That fix has been applied separately
