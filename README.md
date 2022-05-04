# keys.nvim

A neovim plugin that shows keystrokes. </br>
Kind of like screen keys but internal to neovim. <br />

### Installation
```lua
use { 'tamton-aquib/keys.nvim' }
```
- To lazy-load,
```lua
use { 'tamton-aquib/keys.nvim', cmd="KeysToggle" } -- etc
```

### Usage/Configuration
- Default setup function:
```lua
require("keys").setup {
    enable_on_startup = false,
    win_opts = {
        width = 25
    },
    -- TODO: more options later
}
```

### TODO:
- [ ] Crtl and other modifier keys (maybe?).
- [ ] Backspace and some other basic ones.
- [ ] Cleanup.
- [ ] fix on_key() clear_namespace bug.

### Notes to myself
- autocmd ModeChanged
- getchar() or getcharmod()
