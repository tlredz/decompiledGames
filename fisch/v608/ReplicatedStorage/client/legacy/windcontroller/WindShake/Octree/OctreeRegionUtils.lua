local _ = {
	{ 0.25, 0.25, -0.25 },
	{ -0.25, 0.25, -0.25 },
	{ 0.25, 0.25, 0.25 },
	{ -0.25, 0.25, 0.25 },
	{ 0.25, -0.25, -0.25 },
	{ -0.25, -0.25, -0.25 },
	{ 0.25, -0.25, 0.25 },
	{ -0.25, -0.25, 0.25 }
}
local GetNeighborsWithinRadius

GetNeighborsWithinRadius = function(subRegion, p, p2, p3, p4, p5, p6, p7, p8, p9)
	if not p7 then
		error("Missing MaxDepth.")
	end

	local v = p + 0.8660254037844386 * (subRegion.Size[1] / 2)
	local v2 = v * v + 1e-6
	local v3 = p * p

	for _, subRegion2 in next, subRegion.SubRegions, nil do
		local position = subRegion2.Position
		local v4 = position[1]
		local v5 = position[2]
		local v6 = position[3]
		local v7 = p2 - v4
		local v8 = p3 - v5
		local v9 = p4 - v6

		if not (v7 * v7 + v8 * v8 + v9 * v9 <= v2) then
			continue
		end

		if subRegion2.Depth == p7 then
			for k in next, subRegion2.Nodes, nil do
				local positionX = k.PositionX
				local positionY = k.PositionY
				local positionZ = k.PositionZ
				local v10 = positionX - p2
				local v11 = positionY - p3
				local v12 = positionZ - p4
				local v13 = v10 * v10 + v11 * v11 + v12 * v12

				if not (v13 <= v3) then
					continue
				end

				p8 += 1
				p9 += 1
				p5[p8] = k.Object
				p6[p9] = v13
			end
		else
			p8, p9 = GetNeighborsWithinRadius(subRegion2, p, p2, p3, p4, p5, p6, p7, p8, p9)
		end
	end

	return p8, p9
end

return {
	GetNeighborsWithinRadius = GetNeighborsWithinRadius
}