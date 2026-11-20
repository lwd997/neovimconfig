--- @class PluginOpts
--- @field open_shortcut string
--- @field max_items number
--- @field base_url string

--- @class Clipboard
local M = {}

local cbs = require("clipboard_history.CBStore")
local ui = require("clipboard_history.ui");

local function make_debounce(fn, ms)
    local timer = vim.uv.new_timer()

    return function(...)
        local args = { ... }

        timer:stop()
        timer:start(ms, 0, function()
            vim.schedule(function()
                fn(unpack(args))
            end)
        end)
    end
end

function M:open()
    cbs:fetch()
    ui:make_ui()
    ui:set_items({})
    ui:render_list()
    ui:render_preview()
end

--- @param opts PluginOpts
M.setup = function(opts)
    opts = opts or {}

    if (type(opts.max_items) ~= "number" or opts.max_items < 1) then
        vim.notify("must pass valid max_items", vim.log.levels.ERROR)
        return
    end

    if (type(opts.base_url) ~= "string") then
        vim.notify("must pass valid base_url", vim.log.levels.ERROR)
        return
    end

    cbs:set_limit(opts.max_items)
    cbs:set_base_url(opts.base_url)

    ui:on_select(function(val)
        vim.fn.setreg("*", val.content)
        cbs:set_filter("")
    end)

    ui:register_shortcut("<S-Right>", function(val)
        cbs:delete_entry(val.uuid)
    end)

    local debounce = make_debounce(function(val)
        cbs:set_filter(val)
        cbs:fetch()
    end, 200)

    ui:on_input(debounce)

    cbs:on_history_update(function(history)
        ui:set_items(history)
        ui:render_list()
        ui:render_preview()
    end)

    vim.keymap.set("n", "<leader>z", M.open)
end

return M
