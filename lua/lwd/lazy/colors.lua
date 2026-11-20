local configPath = vim.fn.stdpath("config") .. "/lua/lwd/plugins/eyeease"

return {
    {
        "zenbones-theme/zenbones.nvim",
        dependencies = "rktjmp/lush.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            local cgf = require("lwd.config_tool")
            local scheme = cgf:get_settings_entry("colorscheme", "kanagawabones")
            local bg = cgf:get_settings_entry("background", "dark")

            vim.cmd.colorscheme(scheme)
            vim.opt.background = bg;
            vim.g.zenbones_darken_comments = 45
        end
    },
    { dir = configPath }
}
