local configPath = vim.fn.stdpath("config")
local txtConfigPath = configPath .. "/TxtConfig.txt"

---@param entry_name string
---@param fallback_value string
---@return string
function GetTxtConfigEntry(entry_name, fallback_value)
    local lines = vim.fn.readfile(txtConfigPath)

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

---@param entry_name string
---@param entry_value string
function SetTxtConfigEntry(entry_name, entry_value)
    local lines = vim.fn.readfile(configPath .. "/TxtConfig.txt")
    local updated = {}

    for _, line in ipairs(lines) do
        if line:match("^" .. entry_name) then
            line = entry_name .. ":" .. entry_value
        end
        table.insert(updated, line)
    end

    local f = io.open(txtConfigPath, "w")
    if not f then
        error("Cannot write to file: " .. txtConfigPath)
    end

    for _, updLine in ipairs(updated) do
        f:write(updLine, "\n")
    end
    f:close()
end

function GetVisualSelection()
    local selectionStart = vim.api.nvim_buf_get_mark(0, "<")
    local selectionEnd   = vim.api.nvim_buf_get_mark(0, ">")

    local startLine      = selectionStart[1] - 1
    local startCol       = selectionStart[2]
    local endLine        = selectionEnd[1] - 1
    local endCol         = selectionEnd[2]

    local lines          = vim.api.nvim_buf_get_text(0, startLine, startCol, endLine, endCol, {})
    local text           = table.concat(lines, "\n")

    return {
        text     = text,
        measures = {
            startLine = startLine,
            startCol = startCol,
            endLine = endLine,
            endCol = endCol
        }
    }
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
        s.measures.startLine,
        s.measures.startCol,
        s.measures.endLine,
        s.measures.endCol,
        Split(camel, "\n"))
end

function Snake()
    local s = GetVisualSelection()
    local snake = s.text:gsub("[A-Z]", function(match)
        return "_" .. match:lower();
    end)

    vim.api.nvim_buf_set_text(
        0,
        s.measures.startLine,
        s.measures.startCol,
        s.measures.endLine,
        s.measures.endCol,
        Split(snake, "\n"))
end
