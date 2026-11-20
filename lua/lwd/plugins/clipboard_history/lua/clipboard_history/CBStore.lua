--- @class ClipboardEntry
--- @field content string
--- @field timestamp string
--- @field uuid string

--- @class Response
--- @field data? ClipboardEntry[]
--- @field messages? string[]

--- @class CurlResult
--- @field exit number
--- @field status number
--- @field headers string[]
--- @field body string

local curl = require("plenary.curl")

--- @class CBStore
--- @field private __history ClipboardEntry[]
--- @field private __history_limit number
--- @field private __history_filter string
--- @field private __base_url string
--- @field private __history_update_callback fun(h: ClipboardEntry[])
local CBStore = {}
CBStore.__history = {}
CBStore.__history_limit = 40
CBStore.__history_filter = ""

--- @param history ClipboardEntry[]
function CBStore:set_history(history)
    self.__history = history
end

--- @param url string
function CBStore:set_base_url(url)
    self.__base_url = url
end

--- @param filter string
function CBStore:set_filter(filter)
    self.__history_filter = filter
end

--- @param callback fun(h: ClipboardEntry[])
function CBStore:on_history_update(callback)
    self.__history_update_callback = callback
end

--- @return ClipboardEntry[]
function CBStore:get_saved_history()
    return self.__history
end

--- @return string
function CBStore:get_filter_value()
    return self.__history_filter
end

--- @param limit number
function CBStore:set_limit(limit)
    self.__history_limit = limit
end

--- @private
--- @param res CurlResult
function CBStore:__handle_fetch_response(res)
    if (res.status ~= 200) then
        vim.notify(
            "Failed to fetch clipboard history",
            vim.log.levels.ERROR)
        return
    end

    --- @type Response
    local response = vim.fn.json_decode(res.body)

    if response.data then
        if response.data == vim.NIL then
            response.data = {}
        end

        self:set_history(response.data)
    elseif response.messages and #response.messages > 0 then
        vim.notify(vim.inspect({
            "Failed to fetch clipboard history",
            response.messages
        }), vim.log.levels.ERROR)
    else
        vim.notify(vim.inspect({
            "Failed to process clipboard history response", res
        }), vim.log.levels.ERROR)
    end

    if self.__history_update_callback then
        self.__history_update_callback(self:get_saved_history())
    end
end

--- @private
--- @param res CurlResult
function CBStore:__handle_delete_response(res)
    if (res.status ~= 200 and res.status ~= 404) then
        vim.notify(
            vim.inspect({ "Failed to delete clipboard history entry", res }),
            vim.log.levels.ERROR)
        return
    end
    self:fetch()
end

function CBStore:fetch()
    local url = self.__base_url .. "/get-clipboard-history"
    local filter = self:get_filter_value()

    local query = {}
    query["limit"] = self.__history_limit

    if filter:len() > 0 then
        query["search"] = filter
    end

    curl.get(url, {
        headers = {
            content_type = "application/json",
        },
        query = query,
        callback = function(res)
            vim.schedule(function()
                self:__handle_fetch_response(res)
            end)
        end
    })
end

--- @param uuid string
function CBStore:delete_entry(uuid)
    local url = self.__base_url .. "/delete-clipboard-history-entry"
    curl.delete(url, {
        headers = {
            content_type = "application/json",
        },
        query = { uuid = uuid },
        callback = function(res)
            vim.schedule(function()
                self:__handle_delete_response(res)
            end)
        end
    })
end

return CBStore
