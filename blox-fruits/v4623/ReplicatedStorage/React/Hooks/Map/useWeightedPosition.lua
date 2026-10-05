local createVector = vector.create
local Util = require(game.ReplicatedStorage.React.Components.Map.Util)
require(game.ReplicatedStorage.React.Components.Map.Types)
local useMapPositions = require(game.ReplicatedStorage.React.Hooks.Map.useMapPositions)
local useRedirectedPositions = require(game.ReplicatedStorage.React.Hooks.Map.useRedirectedPositions)
return function(p, vector2: Vector3, rect: Rect, point: Vector2)
	local v = useMapPositions(p, rect)
	local v2 = useRedirectedPositions(p, rect, point)
	local v3 = vector2 * createVector(1, 0, 1)

	if not (p and v and v2) then
		return v3
	end

	for _, v4 in p.TRIANGLES do
		local v5 = v4[1]
		local v6 = v4[2]
		local v7 = v4[3]
		local v8 = v5 and v[v5]
		local v9 = v6 and v[v6]
		local v10 = v7 and v[v7]
		local v11 = v5 and v2[v5]
		local v12 = v6 and v2[v6]
		local v13 = v7 and v2[v7]
		local triangleArea = Util.getTriangleArea(v3, v9, v10)
		local triangleArea2 = Util.getTriangleArea(v3, v10, v8)
		local triangleArea3 = Util.getTriangleArea(v3, v8, v9)
		local triangleArea4 = Util.getTriangleArea(v8, v9, v10)

		if not (triangleArea + triangleArea2 + triangleArea3 <= triangleArea4 + 5) then
			continue
		end

		local v14 = (v11 + v12 + v13) / 3
		local v15 = v14:Lerp(v11, triangleArea / triangleArea4) - v14
		local v16 = v14:Lerp(v12, triangleArea2 / triangleArea4) - v14
		local v17 = v14:Lerp(v13, triangleArea3 / triangleArea4) - v14
		return v14 + v15 + v16 + v17, v4
	end

	return v3
end