local colors_name = "eyeease"
vim.g.colors_name = colors_name

local lush = require "lush"
local hsluv = lush.hsluv
local util = require "zenbones.util"

local bg = vim.o.background

local palette
if bg == "light" then
	palette = util.palette_extend({
		bg = hsluv "#e5e8ee",
		fg = hsluv "#505766",
		rose = hsluv "#505766",
		leaf = hsluv "#505766",
		wood = hsluv "#505766",
		water = hsluv "#505766",
		blossom = hsluv "#505766",
		sky = hsluv "#505766",
	}, bg)
else
	palette = util.palette_extend({
		bg = hsluv "#1e212b",
		fg = hsluv "#b8c0c7",
		rose = hsluv "#b8c0c7",
		leaf = hsluv "#b8c0c7",
		wood = hsluv "#b8c0c7",
		water = hsluv "#b8c0c7",
		blossom = hsluv "#b8c0c7",
		sky = hsluv "#b8c0c7",
	}, bg)
end

local generator = require "zenbones.specs"
local base_specs = generator.generate(
    palette, bg, generator.get_global_config(colors_name, bg))

lush(base_specs)
require("zenbones.term").apply_colors(palette)
