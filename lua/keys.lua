local M = {}
local typed_letters = {}
local buf, win
local ns = vim.api.nvim_create_namespace("keys")
local plugin_loaded = false
local config = {
    win_opts = {
        relative="editor", style="minimal", border="shadow",
        row=1, col=1, width=25, height=3
    },
    enable_on_startup = false
}
local win_loaded = false

-- TODO: ⇧+ (for shift+), ⌥+ (for alt+) (also see: https://wincent.com/wiki/Unicode_representations_of_modifier_keys)
local spec_table = {
    [9] = " ", [13] = "⏎ ", [27] = "⎋", [32] = "␣",
    [127] = "", [8] = "⌫ ", -- Not working
}
-- local spc = { ["<BS>"] = "⌫ " } -- TODO: test stuff with replace_term_codes()

--- Get the last 5 keys
---@param as_string boolean (get it as string or list)
---@return string | list
M.current_keys = function(as_string)
    return as_string and table.concat(typed_letters) or typed_letters
end

local create_float = function()
	buf = vim.api.nvim_create_buf(false, true)
	win = vim.api.nvim_open_win(buf, false, config.win_opts)
	-- vim.api.nvim_win_set_option(win, "winhighlight", "Normal:Noice")
	vim.api.nvim_buf_set_option(buf, "filetype", "keys")
end

local render = function()
    local text = table.concat(typed_letters, ' ')
    local pad = (" "):rep(math.floor((config.win_opts.width-vim.api.nvim_strwidth(text))/2))
	local set_lines = pad .. table.concat(typed_letters, " ") .. pad
    vim.api.nvim_buf_set_lines(buf, 1, 2, false, {set_lines})
end

-- local t = function(k) return vim.api.nvim_replace_termcodes(k, true, true, true) end
local sanitize_key = function(key)
    local b = key:byte()
    for k,v in pairs(spec_table) do
        if b == k then
            return v
        end
    end
    if b <= 126 and b >= 33 then
        return key
    end
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
	vim.on_key(function(key)
        -- if not win_loaded then return end
        register_keys(key)
    end, ns)
    plugin_loaded = true
end

M.setup = function(opt)
    config = vim.tbl_deep_extend("force", config, opt or {})
    if config.enable_on_startup then start_registering() end
end

M.toggle = function()
    if win_loaded then
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_buf_delete(buf, {force=true})
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
