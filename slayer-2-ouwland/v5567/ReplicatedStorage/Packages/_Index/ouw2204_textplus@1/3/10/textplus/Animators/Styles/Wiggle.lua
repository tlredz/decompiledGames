local function Bezier4(p, p2, p3, p4, p5)
	local v = 1 - p5
	local v2 = p5 * p5
	local v3 = v * v
	local v4 = v3 * v
	local v5 = v2 * p5
	return v4 * p + 3 * v3 * p5 * p2 + 3 * v * v2 * p3 + v5 * p4
end

return function(p, p2: number, _: number, _: number, _: Color3, _: Color3, _: UDim2, udim: UDim2, p3: number?, _: boolean?)
	local v = 0.2 * p3
	local scale = udim.Y.Scale
	local scale2 = p.Position.X.Scale
	local v2 = scale + v
	local v3 = scale - v
	local v4 = 1 - p2
	local v5 = p2 * p2
	local v6 = v4 * v4
	local v7 = v6 * v4
	local v8 = v5 * p2
	p.Position = UDim2.fromScale(scale2, v7 * scale + 3 * v6 * p2 * v2 + 3 * v4 * v5 * v3 + v8 * scale)
end