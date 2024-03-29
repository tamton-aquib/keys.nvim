local M = {}
local typed_letters = {}
local buf, win
local ns = vim.api.nvim_create_namespace("keys")
local plugin_loaded = false
local config = {
    win_opts = {
        relative = "editor",
        style = "minimal",
        border = "shadow",
        row = vim.o.lines,
        col = vim.o.columns,
        width = 25,
        height = 3
    },
    enable_on_startup = false
}
local win_loaded = false

local t = vim.keycode or function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

-- TODO: ⇧+ (for shift+), ⌥+ (for alt+) (also see: https://wincent.com/wiki/Unicode_representations_of_modifier_keys)
local spec_table = {
    [t "<tab>"] = "⇥",
    [t "<cr>"] = "⏎ ",
    [t "<esc>"] = "⎋",
    [" "] = "␣",
    [t '<S-Space>'] = '⇧󱁐',
    [t "<del>"] = "⌦",
    [t "<bs>"] = "⌫",
    [t "<up>"] = "↑",
    [t "<down>"] = "↓",
    [t "<left>"] = "←",
    [t "<right>"] = "→",
    [t "<home>"] = "⇱",
    [t "<end>"] = "⇲",
    [t "<PageUp>"] = "⇞",
    [t "<PageDown>"] = "⇟",
    [t "<insert>"] = "⎀",
    [t "<C-d>"] = "⌃d",
}

local spc = {
    ["<t_\253g>"] = " ", -- lua function key
    -- Sometimes keytrans incorrectly translates keys to <C-D>.
    -- Ctrl-d is handled in spec_table instead
    ["<C-D>"] = false,
    ["<Cmd>"] = false,
}

--- Get the last 5 keys
---@param as_string boolean (get it as string or list)
---@return string | table
M.current_keys = function(as_string)
    return as_string and table.concat(typed_letters) or typed_letters
end

local create_float = function()
    buf = vim.api.nvim_create_buf(false, true)
    win = vim.api.nvim_open_win(buf, false, config.win_opts)
    -- vim.api.nvim_win_set_option(win, "winhighlight", "Normal:KeysNormal")
    vim.api.nvim_buf_set_option(buf, "filetype", "keys")
end

local render = function()
    local text = table.concat(typed_letters, ' ')
    local pad = (" "):rep(math.floor((config.win_opts.width - vim.api.nvim_strwidth(text)) / 2))
    local set_lines = pad .. table.concat(typed_letters, " ") .. pad
    vim.api.nvim_buf_set_lines(buf, 1, 2, false, { set_lines })
end

local sanitize_key = function(key)
    for k, v in pairs(spec_table) do
        if key == k then
            return v
        end
    end
    local b = key:byte()
    if b <= 126 and b >= 33 then
        return key
    end

    local translated = vim.fn.keytrans(key)
    local special = spc[translated]
    if special ~= nil then
        return special
    end
    local match = translated:match("^<C.-(.)>$")
    if match then
        local shift = translated:match("^<C[-]S[-].>$")
        if not shift then
            match = match:lower()
        end
        return '⌃' .. match
    end

    -- Mouse events
    if translated:match('Left')
        or translated:match('Mouse')
        or translated:match('Scroll')
    then
        return "󰍽 "
    end

    return translated
end

local register_keys = function(key)
    key = sanitize_key(key)

    if key and plugin_loaded then
        if #typed_letters >= 5 then
            table.remove(typed_letters, 1)
        end
        table.insert(typed_letters, key)
        if win_loaded then render() end
    end
end

local start_registering = function()
    vim.on_key(register_keys)
    plugin_loaded = true
end

M.setup = function(opt)
    config = vim.tbl_deep_extend("force", config, opt or {})
    if config.enable_on_startup then M.toggle() end
end

M.toggle = function()
    if win_loaded then
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_buf_delete(buf, { force = true })
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    else
        create_float()
        start_registering()
    end
    win_loaded = not win_loaded
end

M.stop = function()
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

return M
