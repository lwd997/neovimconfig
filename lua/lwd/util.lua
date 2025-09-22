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
