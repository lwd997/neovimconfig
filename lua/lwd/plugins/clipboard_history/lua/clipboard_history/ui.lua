local Popup = require("nui.popup")
local Layout = require("nui.layout")
local Line = require("nui.line")
local Input = require("nui.input")

--- @class CustomShortcut
--- @field shortcut string
--- @field fn fun(val: ClipboardEntry)

--- @class UI
--- @field private __input NuiInput
--- @field private __picker NuiPopup
--- @field private __preview NuiPopup
--- @field private __layout NuiLayout
--- @field private __input_value string
---
--- @field private __items ClipboardEntry[]
--- @field private __on_input fun(val: string)
--- @field private __on_select fun(val: ClipboardEntry)
--- @field private __custom_shortcuts CustomShortcut[]
--- @field cursor_position number
local UI = {}
UI.cursor_position = 1
UI.__input_value = ""
UI.__custom_shortcuts = {}
UI.__items = {}

--- @param str string
--- @param sep string
--- @return string[]
local function split_keep_sep(str, sep)
    local result = {}
    local pos = 1

    local lower_str = str:lower()
    local lower_sep = sep:lower()

    while true do
        local start_pos, end_pos = lower_str:find(lower_sep, pos, true)
        if not start_pos then
            table.insert(result, str:sub(pos))
            break
        end

        table.insert(result, str:sub(pos, start_pos - 1))
        table.insert(result, str:sub(start_pos, end_pos)) -- preserve original case
        pos = end_pos + 1
    end

    return result
end

vim.api.nvim_set_hl(0, "UI_PKG_HL", { fg = "#04aef2" })

--- @param shortcut string
--- @param fn  fun(val: ClipboardEntry)
function UI:register_shortcut(shortcut, fn)
    table.insert(self.__custom_shortcuts, {
        shortcut = shortcut,
        fn = fn
    })
end

--- @param fn fun(val: string)
function UI:on_input(fn)
    self.__on_input = fn
end

--- @param fn fun(val: ClipboardEntry)
function UI:on_select(fn)
    self.__on_select = fn
end

--- @param items ClipboardEntry[]
function UI:set_items(items)
    self.__items = items
end

function UI:render_list()
    if type(UI.__picker.bufnr) ~= "number" then
        return
    end

    vim.api.nvim_buf_set_lines(UI.__picker.bufnr, 0, -1, false, {})

    if #self.__items < 1 then
        return
    end

    for i, item in ipairs(self.__items) do
        local l = Line()
        local content = item.content
            :gsub("\n", " ")
            :gsub("^%s+", "")
            :gsub("%s+$", "")

        if self.cursor_position == i then
            l:append("> ", "UI_PKG_HL")
        else
            l:append("  ")
        end

        if self.__input_value and #self.__input_value > 0 then
            for _, s in ipairs(split_keep_sep(content, self.__input_value)) do
                if s:lower() == self.__input_value:lower() then
                    l:append(s, "UI_PKG_HL")
                else
                    l:append(s)
                end
            end
        else
            l:append(content)
        end

        l:render(UI.__picker.bufnr, -1, i)
    end
end

function UI:make_ui()
    UI.__input = Input(
        {
            border = {
                style = "rounded",
                text = { top = "Type to filter" }
            }
        },
        {
            prompt = "> ",
            default_value = self.__input_value,
            on_change = function(value)
                self.__input_value = value
                if self.__on_input then
                    self.__on_input(value)
                end
            end,
            on_submit = function()
                if self.__on_select then
                    self.__on_select(self:get_entry_under_cursor())
                    self:kill_ui()
                end
            end
        }
    )

    UI.__picker = Popup({ border = "rounded" })
    UI.__preview = Popup({ border = "rounded" })
    UI.__layout = Layout(
        {
            position = "50%",
            size = {
                width = "60%",
                height = "80%"
            }
        },
        Layout.Box({
            Layout.Box({
                Layout.Box(UI.__picker, { grow = 1 }),
                Layout.Box(UI.__input, { size = "10%", }) }, { size = "40%", dir = "col" }),
            Layout.Box(UI.__preview, { size = "60%" }),
        }, { dir = "row" })
    )

    UI:make_events()
    UI.__layout:mount()
end

function UI:kill_ui()
    -- self.__input_value = ""
    self.cursor_position = 1
    self:set_items({})
    UI.__layout:unmount()
end

--- @return ClipboardEntry
function UI:get_entry_under_cursor()
    return self.__items[self.cursor_position]
end

function UI:render_preview()
    if type(UI.__preview.bufnr) ~= "number" then
        return
    end

    local entry = self:get_entry_under_cursor()
    if not entry then
        vim.api.nvim_buf_set_lines(UI.__preview.bufnr, 0, -1, false, {})
        return
    end

    --print (vim.inspect(vim.fn.split(entry.content:gsub("\n\r", "\n"), "\n")))
    vim.api.nvim_buf_set_lines(
        UI.__preview.bufnr, 0, -1, false, vim.split(entry.content, "\n", {plain = true}))
end

function UI:cursor_up()
    if self.cursor_position <= 1 then
        self.cursor_position = #self.__items
    else
        self.cursor_position = self.cursor_position - 1
    end

    self:render_list()
    self:render_preview()
end

function UI:cursor_down()
    if self.cursor_position >= #self.__items then
        self.cursor_position = 1
    else
        self.cursor_position = self.cursor_position + 1
    end

    self:render_list()
    self:render_preview()
end

function UI:make_events()
    UI.__input:map("n", "<Up>", function() self:cursor_up() end)
    UI.__input:map("i", "<Up>", function() self:cursor_up() end)

    UI.__input:map("n", "<Down>", function() self:cursor_down() end)
    UI.__input:map("i", "<Down>", function() self:cursor_down() end)

    UI.__input:map("n", "<Escape>", function() self:kill_ui() end)
    UI.__input:map("i", "<Escape>", function() self:kill_ui() end)

    for _, value in pairs(self.__custom_shortcuts) do
        UI.__input:map("n", value.shortcut, function()
            value.fn(self:get_entry_under_cursor())
        end)

        UI.__input:map("i", value.shortcut, function()
            value.fn(self:get_entry_under_cursor())
        end)
    end
end

return UI
