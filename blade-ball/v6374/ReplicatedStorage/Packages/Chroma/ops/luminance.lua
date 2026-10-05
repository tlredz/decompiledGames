local Color = require(script.Parent.Parent:WaitForChild("Color"))
require(script.Parent.Parent:WaitForChild("types"):WaitForChild("interpolation-mode"))
local pow = math.pow
local rgb2luminance

function Color:luminance(value: number?, value2)
	if value == nil or type(value) ~= "number" then
		return rgb2luminance(self._rgb[1], self._rgb[2], self._rgb[3])
	end

	if value == 0 then
		return Color.new({
			0,
			0,
			0,
			self._rgb[4]
		}, "rgb")
	elseif value == 1 then
		return Color.new({
			255,
			255,
			255,
			self._rgb[4]
		}, "rgb")
	end

	local luminance = self:luminance()
	local v = value2 or "rgb"
	local v2 = 20
	local test

	test = function(object2, p)
		local interpolated = object2:interpolate(p, 0.5, v)
		local luminance2 = interpolated:luminance()
		v2 -= 1

		if math.abs(value - luminance2) < 1e-7 or v2 < 0 then
			return interpolated
		end

		if value < luminance2 then
			return (test(object2, interpolated))
		end

		return (test(interpolated, p))
	end

	local v3

	if value < luminance then
		v3 = test(Color.new({ 0, 0, 0 }), self)
	else
		v3 = test(self, Color.new({ 255, 255, 255 }))
	end

	local rgb = v3:rgb()
	return Color.new({
		rgb[1],
		rgb[2],
		rgb[2],
		self._rgb[4]
	})
end

local luminance_x

rgb2luminance = function(p: number, p2: number, p3: number)
	local v = luminance_x(p)
	local v2 = luminance_x(p2)
	local v3 = luminance_x(p3)
	return v * 0.2126 + v2 * 0.7152 + v3 * 0.0722
end

luminance_x = function(p: number)
	local v = p / 255

	if v <= 0.03928 then
		return v / 12.92
	end

	return (pow((v + 0.055) / 1.055, 2.4))
end

return nil