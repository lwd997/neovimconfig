require("lwd.util")
return {
    "zenbones-theme/zenbones.nvim",
    dependencies = "rktjmp/lush.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        local scheme = GetTxtConfigEntry("ColorScheme", "kanagawabones")
        local bg = GetTxtConfigEntry("Background", "dark")

        vim.g.zenbones_darken_comments = 45
        vim.cmd.colorscheme(scheme)
        vim.opt.background = bg
    end
}
