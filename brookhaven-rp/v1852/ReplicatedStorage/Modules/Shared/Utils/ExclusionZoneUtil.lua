local function clipAxis(p: number, p2: number, p3: number, p4: number, p5: number)
	if math.abs(p2) < 1e-9 then
		if p3 < math.abs(p) then
			return 1e999, -1e999
		end

		return p4, p5
	else
		local v = (-p3 - p) / p2
		local v2 = (p3 - p) / p2

		if v2 < v then
			v2, v = v, v2
		end

		return math.max(p4, v), (math.min(p5, v2))
	end
end

local ExclusionZoneUtil = {}
ExclusionZoneUtil.CLIENT_ZONE_TAG = "ClientExclusionZone"
ExclusionZoneUtil.DYNAMIC_ZONE_TAG = "DynamicExclusionArea"
ExclusionZoneUtil.GROUPS_ATTRIBUTE = "ExclusionGroups"

function ExclusionZoneUtil.parseGroups(value: string?)
	local result = {}

	if value == nil then
		return result
	end

	for _, v in value:split(",") do
		result[v] = true
	end

	return result
end

function ExclusionZoneUtil.getSegmentEntryDistance(cframe: CFrame, vector: Vector3, vector2: Vector3, vector3: Vector3, p: number)
	local pointToObjectSpace = cframe:PointToObjectSpace(vector2)
	local vectorToObjectSpace = cframe:VectorToObjectSpace(vector3)
	local X = pointToObjectSpace.X
	local X2 = vectorToObjectSpace.X
	local v = vector.X / 2
	local v2

	if math.abs(X2) < 1e-9 then
		if v < math.abs(X) then
			p = -1e999
			v2 = 1e999
		else
			v2 = 0
		end
	else
		local v3 = (-v - X) / X2
		local v4 = (v - X) / X2

		if v4 < v3 then
			v4, v3 = v3, v4
		end

		v2 = math.max(0, v3)
		p = math.min(p, v4)
	end

	if p < v2 then
		return nil
	end

	local Y = pointToObjectSpace.Y
	local Y2 = vectorToObjectSpace.Y
	local v3 = vector.Y / 2

	if math.abs(Y2) < 1e-9 then
		if v3 < math.abs(Y) then
			v2 = 1e999
			p = -1e999
		end
	else
		local v4 = (-v3 - Y) / Y2
		local v5 = (v3 - Y) / Y2

		if v5 < v4 then
			v5, v4 = v4, v5
		end

		v2 = math.max(v2, v4)
		p = math.min(p, v5)
	end

	if p < v2 then
		return nil
	end

	local Z = pointToObjectSpace.Z
	local Z2 = vectorToObjectSpace.Z
	local v4 = vector.Z / 2

	if math.abs(Z2) < 1e-9 then
		if v4 < math.abs(Z) then
			v2 = 1e999
			p = -1e999
		end
	else
		local v5 = (-v4 - Z) / Z2
		local v6 = (v4 - Z) / Z2

		if v6 < v5 then
			v6, v5 = v5, v6
		end

		v2 = math.max(v2, v5)
		p = math.min(p, v6)
	end

	if p < v2 then
		return nil
	end

	return v2
end

return ExclusionZoneUtil