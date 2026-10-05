local Color = require(script.Parent.Parent:WaitForChild("Color"))

local function rgb(p, p2, p3: number)
	local _rgb = p._rgb
	local _rgb2 = p2._rgb
	return Color.new(
		_rgb[1] + p3 * (_rgb2[1] - _rgb[1]),
		_rgb[2] + p3 * (_rgb2[2] - _rgb[2]),
		_rgb[3] + p3 * (_rgb2[3] - _rgb[3]),
		"rgb"
	)
end

local parentModule = require(script.Parent)
parentModule.rgb = rgb
return rgb