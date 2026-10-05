local ColorEncoder = {
	encodeColorData = function(color: Color3)
		local v = math.floor(color.R * 255 + 0.5)
		local v2 = math.floor(color.G * 255 + 0.5)
		local v3 = math.floor(color.B * 255 + 0.5)
		local _ = {
			r = 5,
			g = 3,
			b = 2
		}
		local v4 = bit32.bor(bit32.band(v, 4294967288), 5)
		local v5 = bit32.bor(bit32.band(v2, 4294967288), 3)
		local v6 = bit32.bor(bit32.band(v3, 4294967288), 2)
		return Color3.new(v4 / 255, v5 / 255, v6 / 255)
	end,
	isColorDataEncoded = function(color: Color3)
		local v = math.floor(color.R * 255 + 0.5)
		local v2 = math.floor(color.G * 255 + 0.5)
		local v3 = math.floor(color.B * 255 + 0.5)
		local v4 = bit32.band(v, 7)
		local v5 = bit32.band(v2, 7)
		local v6 = bit32.band(v3, 7)
		return v4 == 5 and v5 == 3 and v6 == 2
	end
}

function ColorEncoder.decodeColorData(data)
	if ColorEncoder.isColorDataEncoded(data) == false then
		return data
	end

	local v = math.floor(data.R * 255 + 0.5)
	local v2 = math.floor(data.G * 255 + 0.5)
	local v3 = math.floor(data.B * 255 + 0.5)
	local v4

	if v < 255 then
		v4 = v + 1
	else
		v4 = v - 1
	end

	local v5

	if v2 < 255 then
		v5 = v2 + 1
	else
		v5 = v2 - 1
	end

	local v6

	if v3 < 255 then
		v6 = v3 + 1
	else
		v6 = v3 - 1
	end

	return Color3.fromRGB(v4, v5, v6)
end

return ColorEncoder