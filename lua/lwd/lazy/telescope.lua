return {
    "nvim-telescope/telescope.nvim",

    tag = "0.1.8",

    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make"
        }
    },

    config = function()
        require("telescope").setup({
            defaults = {
                file_ignore_patterns = { "node_modules" }
            }
        })

        local builtin = require("telescope.builtin")
        local finders = require("telescope.finders")
        local pickers = require("telescope.pickers")
        local sorters = require("telescope.sorters")
        local make_entry = require("telescope.make_entry")
        local config = require("telescope.config").values

        local function smart_grep(opts)
            opts = opts or {}
            opts.cwd = opts.cwd or vim.uv.cwd()

            local finder = finders.new_async_job({
                command_generator = function(input)
                    if not input or input == "" then
                        return nil
                    end

                    local input_parts = vim.split(input, " / ")
                    local cli_call = { "rg" }

                    local query = input_parts[1]
                    local extension = input_parts[2]

                    if query then
                        table.insert(cli_call, "-e")
                        table.insert(cli_call, query)
                    end

                    if extension then
                        table.insert(cli_call, "-g")
                        table.insert(cli_call, extension)
                    end

                    table.insert(cli_call, "--color=never")
                    table.insert(cli_call, "--no-heading")
                    table.insert(cli_call, "--with-filename")
                    table.insert(cli_call, "--line-number")
                    table.insert(cli_call, "--column")
                    table.insert(cli_call, "--smart-case")

                    return cli_call
                end,
                entry_maker = make_entry.gen_from_vimgrep(opts),
                cwd = opts.cwd
            })

            pickers.new(opts, {
                debounce = 150,
                prompt_title = "Grep (\" / \" to specify a file extension)",
                finder = finder,
                previewer = config.grep_previewer(opts),
                sorter = sorters.empty()
            }):find()
        end

        vim.keymap.set('n', '<C-p>', builtin.find_files, {})
        vim.keymap.set('n', '<C-o>', smart_grep, {})
    end
}
