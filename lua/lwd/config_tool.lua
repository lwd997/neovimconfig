--- @enum (key) JsonConfigEntry
local _ = {
    colorscheme = 0,
    background = 1,
    clipboard_history_server_base_url = 2
}

--- @class CfgTool
--- @field private __base_path string
--- @field private __settings_json_path string
local CfgTool = {}
CfgTool.__base_path = vim.fn.stdpath("config") --[[@as string]] --
CfgTool.__settings_json_path = CfgTool.__base_path .. "/settings.json"

--- @return string
function CfgTool:config_dir()
    return self.__base_path
end

--- @return string
function CfgTool:settings_file()
    return self.__settings_json_path
end

--- @param cfg table
function CfgTool:rewrite_settings(cfg)
    local path = self:settings_file()
    local json = vim.json.encode(cfg)

    if not json or json == "" then
        error(vim.inspect({
            "CfgTool:rewrite_settings: bad json", cfg }))
        return
    end

    vim.fn.writefile({ json }, path, "b")
end

--- @return table
function CfgTool:get_settings()
    local path = self:settings_file()

    if vim.fn.filereadable(path) ~= 1 then
        self:rewrite_settings(vim.empty_dict())
    end

    if vim.fn.filereadable(path) ~= 1 then
        return vim.empty_dict()
    end

    local lines = vim.fn.readfile(path)

    if not lines or #lines == 0 or (#lines == 1 and lines[1] == "") then
        return vim.empty_dict()
    end

    local ok, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
    if not ok or decoded == nil then
        return vim.empty_dict()
    end

    return decoded
end

--- @param entry JsonConfigEntry
--- @param fallback string
--- @return string
function CfgTool:get_settings_entry(entry, fallback)
    local s = CfgTool:get_settings()
    if not s[entry] then
        return fallback
    end
    return s[entry]
end

--- @param entry JsonConfigEntry
--- @param value string
function CfgTool:set_settings_entry(entry, value)
    local s = self:get_settings()
    s[entry] = value
    self:rewrite_settings(s)
end

return CfgTool
