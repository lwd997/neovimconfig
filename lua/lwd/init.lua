require("lwd.set")
require("lwd.util")
require("lwd.lazy_init")

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local group_highlight_yank = augroup("highlight_yank", {})
local group_lsp_attach = augroup("lsp_attach", {})

autocmd("TextYankPost", {
    group = group_highlight_yank,
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch",
            timeout = 40,
        })
    end,
})

vim.api.nvim_set_hl(0, "ColorColumn", { link = "Visual" })

autocmd("LspAttach", {
    group = group_lsp_attach,
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    end
})

autocmd("colorscheme", {
    callback = function(args)
        SetTxtConfigEntry("ColorScheme", args.match)
    end,
})

vim.api.nvim_create_user_command("Format", function(args)
    require("conform").format({
        async = true,
        lsp_fallback = true,
        range = args.count ~= -1 and {
            start = { args.line1, 0 },
            ["end"] = { args.line2, 0 },
        } or nil,
    })
end, { range = true })

vim.api.nvim_create_user_command("Camel", Camel, { range = true })
vim.api.nvim_create_user_command("Snake", Snake, { range = true })

vim.api.nvim_create_user_command("BGToggle", function()
    vim.cmd.colorscheme(GetTxtConfigEntry("ColorScheme", "kanagawabones"))

    if (vim.o.background == "light") then
        vim.opt.background = "dark"
    else
        vim.opt.background = "light"
    end

    SetTxtConfigEntry("Background", vim.o.background)
end, {})

vim.api.nvim_create_user_command("SpellAdd", function(opts)
    AddSpellFromEditor("en", { is_visual_mode = opts.count ~= -1 })
end, { range = true })

vim.api.nvim_create_user_command("SpellAddRu", function(opts)
    AddSpellFromEditor("ru", { is_visual_mode = opts.count ~= -1 })
end, { range = true })

local resizeRemapOpts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<C-4>', ':resize +1<CR>', resizeRemapOpts)
vim.api.nvim_set_keymap('n', '<C-3>', ':resize -1<CR>', resizeRemapOpts)
vim.api.nvim_set_keymap('n', '<C-2>', ':vertical resize -1<CR>', resizeRemapOpts)
vim.api.nvim_set_keymap('n', '<C-1>', ':vertical resize +1<CR>', resizeRemapOpts)

vim.api.nvim_set_keymap('n', '<M-n>', ':cnext<CR>', {})
vim.api.nvim_set_keymap('n', '<M-p>', ':cprev<CR>', {})
