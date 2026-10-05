require(script.Parent.Parent.Parent.TextPlusTypes)
local v = {
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(255, 165, 0),
	Color3.fromRGB(255, 255, 0),
	Color3.fromRGB(0, 128, 0),
	Color3.fromRGB(0, 255, 255),
	Color3.fromRGB(0, 0, 255),
	(Color3.fromRGB(128, 0, 128))
}

-- equivalent calls inferred from this helper; original call sites unknown
local function LerpColor(data, data2, value)
	local v2 = math.clamp(value, 0, 1)
	return Color3.new(
		data.R + (data2.R - data.R) * v2,
		data.G + (data2.G - data.G) * v2,
		data.B + (data2.B - data.B) * v2
	)
end

local floor = math.floor
return function(p, p2: number, _: number, _: number, color: Color3, _: Color3, _: UDim2, _: UDim2, _: number?, _: boolean?)
	local v3 = floor(p2 * 7)
	local v4 = (p2 - v3 * 0.125) / 0.125
	local v5 = v[v3 + 1]

	if v3 == 7 then
		v5 = color
	end

	p.TextColor3 = LerpColor(v[v3] or color, v5, v4)
end