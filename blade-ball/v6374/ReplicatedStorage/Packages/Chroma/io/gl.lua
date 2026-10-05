local Color = require(script.Parent.Parent:WaitForChild("Color"))
local chroma = require(script.Parent.Parent:WaitForChild("chroma"))
local input = require(script.Parent:WaitForChild("input"))
local utils = require(script.Parent.Parent:WaitForChild("utils"))
local unpack2 = utils.unpack

function input.format.gl(...)
	local v = unpack2(table.pack(...), "rgba")
	v[1] *= 255
	v[2] *= 255
	v[3] *= 255
	return v
end

function chroma.gl(...)
	local v = table.pack(...)
	v[v.n + 1] = "gl"
	return Color.new(unpack(v, 1, v.n + 1))
end

function Color:gl()
	local _rgb = self._rgb
	return {
		_rgb[1] / 255,
		_rgb[2] / 255,
		_rgb[3] / 255,
		_rgb[4]
	}
end

return nil