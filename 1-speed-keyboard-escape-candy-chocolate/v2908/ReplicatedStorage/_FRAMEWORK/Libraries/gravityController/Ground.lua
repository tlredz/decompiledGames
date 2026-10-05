local Basis = require(script.Parent.Basis)
require(script.Parent.Types)
local Ground = {}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.RespectCanCollide = true
raycastParams.IgnoreWater = true
local filterDescendantsInstances = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function applyFilter(p)
	filterDescendantsInstances[1] = p
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
end

local function castOne(p, p2: string, p3: number?, vector: Vector3, vector2: Vector3)
	local raycastResult = workspace:Raycast(vector, vector2, raycastParams)
	local onProbe = p.onProbe

	if onProbe ~= nil then
		if p3 ~= nil then
			p2 = `{p2}Ring{p3}`
		end

		onProbe(p2, vector, vector2, raycastResult)
	end

	return raycastResult
end

function Ground.probe(p, vector: Vector3, vector2: Vector3, distance: number, p3: number, p4: string, p5)
	applyFilter(p) -- equivalent call inferred; original call site unknown
	local v2 = -vector2 * distance
	local raycastResult = workspace:Raycast(vector, v2, raycastParams)
	local onProbe = p5.onProbe

	if onProbe ~= nil then
		onProbe(p4, vector, v2, raycastResult)
	end

	if raycastResult == nil then
		local anyPerpendicular = Basis.anyPerpendicular(vector2)
		local unit = vector2:Cross(anyPerpendicular).Unit

		for i = 1, p5.groundRingCount do
			local v3 = (i - 1) / p5.groundRingCount * 3.141592653589793 * 2
			local v4 = vector + (anyPerpendicular * math.cos(v3) + unit * math.sin(v3)) * p3
			local raycastResult2 = workspace:Raycast(v4, v2, raycastParams)
			local onProbe2 = p5.onProbe

			if onProbe2 ~= nil then
				local v5

				if i == nil then
					v5 = p4
				else
					v5 = `{p4}Ring{i}`
				end

				onProbe2(v5, v4, v2, raycastResult2)
			end

			if raycastResult2 ~= nil and (raycastResult == nil or raycastResult2.Distance < raycastResult.Distance) then
				raycastResult = raycastResult2
			end
		end
	end

	if raycastResult == nil then
		return {
			grounded = false,
			normal = vector2,
			point = vector + v2,
			part = nil,
			distance = distance
		}
	end

	return {
		grounded = true,
		normal = raycastResult.Normal,
		point = raycastResult.Position,
		part = raycastResult.Instance,
		distance = raycastResult.Distance
	}
end

function Ground.cast(p, vector: Vector3, vector2: Vector3, p2: string, p3)
	applyFilter(p) -- equivalent call inferred; original call site unknown
	local raycastResult = workspace:Raycast(vector, vector2, raycastParams)
	local onProbe = p3.onProbe

	if onProbe ~= nil then
		onProbe(p2, vector, vector2, raycastResult)
	end

	return raycastResult
end

function Ground.lookAhead(p, vector: Vector3, vector2: Vector3, p2: number, p3)
	applyFilter(p) -- equivalent call inferred; original call site unknown
	local v2 = -vector2 * p2
	local raycastResult = workspace:Raycast(vector, v2, raycastParams)
	local onProbe = p3.onProbe

	if onProbe ~= nil then
		onProbe("travel", vector, v2, raycastResult)
	end

	if raycastResult == nil then
		return nil
	end

	return raycastResult.Distance
end

function Ground.setCollisionGroup(collisionGroup: string)
	raycastParams.CollisionGroup = collisionGroup
end

return Ground