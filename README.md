# keys.nvim

A neovim plugin that shows keystrokes. </br>
Kind of like screen keys but inside neovim. <br />
WIP, contains bugs.

![keys nvim](https://user-images.githubusercontent.com/77913442/166695082-93e0873a-3d14-4a90-911e-fa05de670078.gif)

### Installation
```lua
use { 'tamton-aquib/keys.nvim' }
```
> Use `cmd="KeysToggle"` for lazy-loading.

### Configuration
- Default setup function:
```lua
require("keys").setup {
    enable_on_startup = false,
    win_opts = {
        width = 25
        -- etc
    },
    -- TODO: more options later
}
```

### Usage
- `KeysToggle` command.
- `require("keys").toggle()`

#### Statusline component
This plugin exposes `current_keys()` function. <br />
To use it in statusline, set the provider as:
```lua
require("keys").current_keys(true)
-- `true` implies return it as a string rather than a table
```
> ❗ Make sure to set `enable_on_startup = true` inside setup()

### TODO:
- [ ] Crtl and other modifier keys (maybe?).
- [ ] Backspace and some other basic ones.
- [ ] Cleanup.
- [ ] fix on_key() clear_namespace bug.

### Notes to myself
- autocmd ModeChanged
- getchar() or getcharmod()
