# Checkhealth Hanging Issue

## Problem
Running `:checkhealth` or `:LazyHealth` in neovim causes it to hang/freeze and eventually crash.

## Root Cause
The **vim.treesitter health check** hangs when trying to load treesitter parsers. Specifically at line 44 of `/opt/homebrew/Cellar/neovim/0.11.5_1/share/nvim/runtime/lua/vim/treesitter/health.lua` where it calls `ts.language.add(parser.name)` for each parser.

One of your installed parsers is causing neovim to hang when loading. This affects:
- `:checkhealth` (with no arguments - tries to run ALL health checks including vim.treesitter)
- `:LazyHealth` (also runs all checks)
- `:checkhealth vim.treesitter`
- `:checkhealth nvim-treesitter` (also hangs when checking queries)

Other specific health checks work fine (`:checkhealth lazy`, `:checkhealth nvim`, `:checkhealth provider`, etc.)

**This is NOT a configuration issue** - it's a bad/corrupted treesitter parser file.

## Workaround

**Option 1: Run specific health checks (RECOMMENDED)**
```vim
:checkhealth lazy
:checkhealth nvim  
:checkhealth provider
:checkhealth vim.lsp
" etc - just avoid vim.treesitter and nvim-treesitter
```

**Option 2: Disable treesitter health check temporarily**

Add to your config:
```lua
-- Disable treesitter health check to prevent hangs
vim.g.loaded_nvim_treesitter_health = 1
```

**Option 3: Use the bash wrapper script (works but slow)**
```bash
# Run health check for specific module (excluding treesitter)
bash ~/.config/nvim/checkhealth.sh lazy
bash ~/.config/nvim/checkhealth.sh vim.lsp
```

## Permanent Solution

**You need to identify and remove the corrupted parser:**

1. **Method 1: Delete all parsers and reinstall** (RECOMMENDED)
   ```bash
   rm -rf ~/.local/share/nvim/site/parser/
   nvim +"TSInstall bash lua vim" +qa
   # Then gradually reinstall other parsers you need
   ```

2. **Method 2: Binary search to find the bad parser**
   - Delete half the parsers from `~/.local/share/nvim/site/parser/`
   - Test `:checkhealth vim.treesitter`
   - Repeat until you find the problematic one

3. **Method 3: Update everything**
   ```vim
   :Lazy update
   :TSUpdate
   ```
   Then test if the issue is resolved.

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
