function ColorMyPencils(color)
	color = color or "neobones"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return {
    "zenbones-theme/zenbones.nvim",
    dependencies = "rktjmp/lush.nvim",
    lazy = false,
    priority = 1000,
    config = function()
         vim.g.zenbones_darken_comments = 45
         vim.cmd.colorscheme("kanagawabones")
    end
}
