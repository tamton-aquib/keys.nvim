
vim.api.nvim_create_user_command('KeysToggle', function() require("keys").toggle() end, {})
