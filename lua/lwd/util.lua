local config_path = vim.fn.stdpath("config")
local txt_config_path = config_path .. "/TxtConfig.txt"

function GetConfigBasePath()
    return config_path
end

--- @param entry_name string
--- @param fallback_value string
--- @return string
function GetTxtConfigEntry(entry_name, fallback_value)
    local lines = vim.fn.readfile(txt_config_path)

    for _, line in ipairs(lines) do
        if line:match("^" .. entry_name) then
            local val = line:sub(#entry_name + 2):match("^%s*(.-)%s*$")
            if (string.len(val) > 0) then
                return val
            end
        end
    end

    return fallback_value
end

--- @param entry_name string
--- @param entry_value string
function SetTxtConfigEntry(entry_name, entry_value)
    local lines = vim.fn.readfile(config_path .. "/TxtConfig.txt")
    local updated = {}

    for _, line in ipairs(lines) do
        if line:match("^" .. entry_name) then
            line = entry_name .. ":" .. entry_value
        end
        table.insert(updated, line)
    end

    local f = io.open(txt_config_path, "w")
    if not f then
        error("Cannot write to file: " .. txt_config_path)
    end

    for _, updLine in ipairs(updated) do
        f:write(updLine, "\n")
    end
    f:close()
end

function GetVisualSelection()
    local selection_start = vim.api.nvim_buf_get_mark(0, "<")
    local selection_end   = vim.api.nvim_buf_get_mark(0, ">")

    local start_line      = selection_start[1] - 1
    local start_col       = selection_start[2]
    local end_line        = selection_end[1] - 1
    local end_col         = selection_end[2]

    local lines           = vim.api.nvim_buf_get_text(
        0,
        start_line,
        start_col,
        end_line,
        end_col,
        {})

    local text            = table.concat(lines, "\n")

    return {
        text     = text,
        measures = {
            start_line = start_line,
            start_col = start_col,
            end_line = end_line,
            end_col = end_col
        }
    }
end

function GetWordUnderCursor()
    return vim.fn.expand("<cword>")
end

--- @param str string
--- @param sep string
function Split(str, sep)
    local t = {}
    for s in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, s)
    end

    return t
end

function Camel()
    local s = GetVisualSelection()
    local camel = s.text:gsub("_[A-Za-z]", function(match)
        return match:gsub("%_", ""):upper();
    end)

    vim.api.nvim_buf_set_text(
        0,
        s.measures.start_line,
        s.measures.start_col,
        s.measures.end_line,
        s.measures.end_col,
        Split(camel, "\n"))
end

function Snake()
    local s = GetVisualSelection()
    local snake = s.text:gsub("[A-Z]", function(match)
        return "_" .. match:lower();
    end)

    vim.api.nvim_buf_set_text(
        0,
        s.measures.start_line,
        s.measures.start_col,
        s.measures.end_line,
        s.measures.end_col,
        Split(snake, "\n"))
end

--- @param lang string
--- @param entry string
function AddSpellEntry(lang, entry)
    local spell_dir_path = config_path .. "/spell"

    if vim.fn.filewritable(spell_dir_path) ~= 2 then
        vim.fn.mkdir(spell_dir_path)
    end

    local spell_file_path = spell_dir_path .. "/" .. lang .. ".utf-8.add"
    local lang_before = vim.opt.spelllang:get()
    local spell_file_before = vim.opt.spellfile

    vim.opt.spellfile = spell_file_path
    vim.opt.spelllang = { lang }

    vim.cmd("silent! spellgood " .. entry)
    vim.cmd("silent! mkspell " .. spell_file_path)

    vim.opt.spellfile = spell_file_before
    vim.opt.spelllang = lang_before

    print(entry .. " -> " .. lang)
end

--- @class AddSpellOpts
--- @field is_visual_mode boolean

--- @param lang string
--- @param opts AddSpellOpts
function AddSpellFromEditor(lang, opts)
    local spell_entry = ""

    if opts.is_visual_mode then
        spell_entry = GetVisualSelection().text
        spell_entry = vim.fn.trim(spell_entry)
    else
        spell_entry = GetWordUnderCursor()
    end

    if spell_entry == "" then
        print("Cannot add whitespace to spellfile")
        return
    end

    vim.ui.input(
        {
            prompt =
                "Add '" .. spell_entry .. "' to " .. lang .. "?\n" ..
                "Enter or 'y' to confirm, any other input to abort\n"
        },
        function(input)
            if input == "" or input == "y" then
                AddSpellEntry(lang, spell_entry)
            end
        end
    )
end
