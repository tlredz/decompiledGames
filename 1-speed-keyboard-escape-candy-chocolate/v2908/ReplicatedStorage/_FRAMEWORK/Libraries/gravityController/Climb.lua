require(script.Parent.Types)
local Climb = {}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.RespectCanCollide = true
raycastParams.IgnoreWater = true
local filterDescendantsInstances = {}

local function cast(p, p2: string, vector: Vector3, vector2: Vector3)
	local raycastResult = workspace:Raycast(vector, vector2, raycastParams)
	local onProbe = p.onProbe

	if onProbe ~= nil then
		onProbe(p2, vector, vector2, raycastResult)
	end

	return raycastResult
end

local function isClimbable(raycastResult: RaycastResult?, vector: Vector3)
	return raycastResult ~= nil and raycastResult.Instance:IsA("TrussPart") and math.abs((raycastResult.Normal:Dot(vector))) <= 0.5
end

function Climb.find(p, vector: Vector3, vector2: Vector3, vector3: Vector3, vector4: Vector3, p2)
	filterDescendantsInstances[1] = p
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local raycastResult = workspace:Raycast(vector, vector3, raycastParams)
	local onProbe = p2.onProbe

	if onProbe ~= nil then
		onProbe("climbTorso", vector, vector3, raycastResult)
	end

	local raycastResult2 = workspace:Raycast(vector2, vector3, raycastParams)
	local onProbe2 = p2.onProbe

	if onProbe2 ~= nil then
		onProbe2("climbFeet", vector2, vector3, raycastResult2)
	end

	local v2

	if raycastResult == nil then
		v2 = false
	else
		v2 = raycastResult.Instance:IsA("TrussPart") and math.abs((raycastResult.Normal:Dot(vector4))) <= 0.5
	end

	if v2 then
		raycastResult2 = raycastResult
	else
		local v3

		if raycastResult2 == nil then
			v3 = false
		else
			v3 = raycastResult2.Instance:IsA("TrussPart") and math.abs((raycastResult2.Normal:Dot(vector4))) <= 0.5
		end

		if not v3 then
			raycastResult2 = nil
		end
	end

	if raycastResult2 == nil then
		return nil
	end

	local normal = raycastResult2.Normal
	return (normal - vector4 * normal:Dot(vector4)).Unit
end

function Climb.setCollisionGroup(collisionGroup: string)
	raycastParams.CollisionGroup = collisionGroup
end

return Climb