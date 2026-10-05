local module = require("./catppuccin")
local module2 = require("../roblox_packages/vide")
local source = module2.source
local selected = source(module.moccha)
local Theme = {
	selected = selected,
	select_color = function(p)
		return function()
			return selected()[p]
		end
	end,
	ansi_pallete = {
		[0] = Color3.fromHex("#000000"),
		[1] = module.latte.red,
		[2] = module.latte.green,
		[3] = module.latte.yellow,
		[4] = module.latte.blue,
		[5] = module.latte.mauve,
		[6] = module.latte.sky,
		[7] = module.latte.base,
		[8] = module.moccha.red,
		[9] = module.moccha.green,
		[10] = module.moccha.base,
		[11] = module.moccha.yellow,
		[12] = module.moccha.blue,
		[13] = module.moccha.mauve,
		[14] = module.moccha.sky,
		[15] = Color3.fromHex("ffffff")
	},
	background = 0,
	background_transparency = 0,
	text = 0,
	text_error = 0,
	text_info = 0,
	text_warn = 0,
	text_success = 0,
	font = 0
}
local v2 = "base"

function Theme.background()
	return selected()[v2]
end

Theme.background_transparency = source(0.1)
local v3 = "text"

function Theme.text()
	return selected()[v3]
end

local v4 = "red"

function Theme.text_error()
	return selected()[v4]
end

local v5 = "blue"

function Theme.text_info()
	return selected()[v5]
end

local v6 = "peach"

function Theme.text_warn()
	return selected()[v6]
end

local v7 = "green"

function Theme.text_success()
	return selected()[v7]
end

Theme.font = source(Font.fromId(16658246179))
return Theme