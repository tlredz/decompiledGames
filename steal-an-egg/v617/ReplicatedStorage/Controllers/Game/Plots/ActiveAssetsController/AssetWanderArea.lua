local AssetWanderArea = {
	HalfExtents = function(p)
		local size = p.Size
		return math.max(size.X * 0.5 - 1.75, 0), (math.max(size.Z * 0.5 - 1.75, 0))
	end
}

function AssetWanderArea.ClampedPointToward(p, vector: Vector3)
	local halfExtents, v = AssetWanderArea.HalfExtents(p)
	local pointToObjectSpace = p.CFrame:PointToObjectSpace(vector)
	local v2 = math.clamp(pointToObjectSpace.X, -halfExtents, halfExtents)
	local v3 = math.clamp(pointToObjectSpace.Z, -v, v)
	return (p.CFrame * CFrame.new(v2, 0, v3)).Position
end

function AssetWanderArea.RandomPoint(p, object)
	local halfExtents, v = AssetWanderArea.HalfExtents(p)
	local number = object:NextNumber(-halfExtents, halfExtents)
	local number2 = object:NextNumber(-v, v)
	return (p.CFrame * CFrame.new(number, 0, number2)).Position
end

function AssetWanderArea.IsPositionInside(p, vector: Vector3)
	local halfExtents, v = AssetWanderArea.HalfExtents(p)
	local pointToObjectSpace = p.CFrame:PointToObjectSpace(vector)
	return math.abs(pointToObjectSpace.X) <= halfExtents and math.abs(pointToObjectSpace.Z) <= v
end

function AssetWanderArea.PointNearOwner(p, vector: Vector3, vector2: Vector3)
	return AssetWanderArea.ClampedPointToward(p, vector + vector2)
end

return AssetWanderArea