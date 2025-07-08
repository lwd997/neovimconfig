local configPath = vim.fn.stdpath("config")

package.path = package.path
    .. ";" .. configPath .. "/lua/?.lua"
    .. ";" .. configPath .. "/lua/?/init.lua"

require("lwd")

