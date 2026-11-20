--[[
local configPath = vim.fn.stdpath("config") .. "/lua/lwd/plugins/clipboard_history"
return {
    dir = configPath,
    ---@module 'lwd.plugins.clipboard_history.lua.clipboard_history'
    ---@type PluginOpts
    opts = {
        base_url = "http://localhost:9003",
        max_items = 25,
        open_shortcut = "<leader>z"
    },
    dependencies = { "MunifTanjim/nui.nvim" }
}
]]--
return {}
