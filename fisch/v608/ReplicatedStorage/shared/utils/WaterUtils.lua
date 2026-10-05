local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RayVisual = require(ReplicatedStorage.shared.utils.RayVisual)
local v = {
	"VolcanicLava",
	"KillPart",
	"FreezingWater",
	"ToxicWater",
	"DangerPart"
}
local WaterUtils = {}
local random = Random.new()
local v2 = {
	Lifetime = 10
}
local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = true
raycastParams.RespectCanCollide = true
raycastParams.CollisionGroup = "Players"
raycastParams.IncludeInstances = {
	workspace:WaitForChild("world"):WaitForChild("map"),
	workspace:WaitForChild("active"):WaitForChild("boats")
}
local overlapParams = OverlapParams.new()
overlapParams.RespectCanCollide = false
overlapParams.IncludeInstances = {}
overlapParams.MaxParts = 1

function WaterUtils.NextRandomTarget(cframe: CFrame, instance, p)
	local number = random:NextNumber(45, 135)
	local v3 = cframe.Rotation * CFrame.fromOrientation(0, math.rad(number), 0)
	local v4 = v3.LookVector * (instance.Size * createVector(1, 0, 1)).Magnitude
	local closestPoint = Ray.new(cframe.Position, v4):ClosestPoint(instance:GetClosestPointOnSurface(cframe.Position + v4))
	local pointToObjectSpace = instance.CFrame:PointToObjectSpace(closestPoint)
	local halfSize = instance.Size / 2
	local pointToWorldSpace = instance.CFrame:PointToWorldSpace((Vector3.new(
		math.clamp(pointToObjectSpace.X, -halfSize.X, halfSize.X),
		math.clamp(pointToObjectSpace.Y, -halfSize.Y, halfSize.Y),
		(math.clamp(pointToObjectSpace.Z, -halfSize.Z, halfSize.Z))
	)))
	local unit = (pointToWorldSpace - cframe.Position).Unit
	local raycast = RayVisual.raycast(cframe.Position, pointToWorldSpace - cframe.Position, raycastParams, nil)
	local v6

	if raycast then
		v6 = v3 + (raycast.Position - unit * p.ModelSize / 2)
	else
		v6 = v3 + (pointToWorldSpace - unit * p.ModelSize / 2)
	end

	local Y = v6.Y

	if p.DistanceBelowSurface then
		Y = instance.Position.Y + instance.Size.Y / 2 - p.DistanceBelowSurface
	end

	return v6.Rotation + Vector3.new(v6.X, Y, v6.Z)
end

function WaterUtils.GetRandomStartingPoint(instance, p)
	local halfSize = instance.Size / 2
	local number = random:NextNumber(-halfSize.Y, halfSize.Y)

	if p.DistanceBelowSurface then
		number = instance.Position.Y + instance.Size.Y / 2 - p.DistanceBelowSurface
	end

	local cframe = CFrame.new(
		random:NextNumber(-halfSize.X, halfSize.X),
		number,
		random:NextNumber(-halfSize.Z, halfSize.Z)
	)
	return instance.CFrame * cframe * CFrame.fromOrientation(
		0,
		random:NextNumber(-3.141592653589793, 3.141592653589793),
		0
	)
end

function WaterUtils.GetRandomPath(p: number, cframe: CFrame?, p2, p3)
	local v3 = cframe or WaterUtils.GetRandomStartingPoint(p2, p3)
	local result = table.create(p)
	local v4 = v3

	for i = 1, p do
		v4 = WaterUtils.NextRandomTarget(v4, p2, p3)
		result[i] = v4
	end

	return result, v3
end

local raycastParams2 = RaycastParams.new()
raycastParams2.IgnoreWater = false
raycastParams2.RespectCanCollide = true
raycastParams2.CollisionGroup = "Players"
raycastParams2.IncludeInstances = {
	workspace:WaitForChild("world"):WaitForChild("map"),
	workspace:WaitForChild("active"):WaitForChild("boats"),
	workspace.Terrain
}

function WaterUtils.GetWaterLevelIfProbablyAboveWater(vector2: Vector3, p: number, flag: boolean?)
	local v3 = vector2 + Vector3.new(0, p / 4, 0)
	local raycast = RayVisual.raycast(v3.Position, Vector3.new(0, -p * 0.75, 0), raycastParams2, nil)

	if not raycast or raycast.Material ~= Enum.Material.Water and not raycast.Instance:HasTag("PartWater") then
		return nil
	end

	if flag or not WaterUtils.DangerCheck(raycast.Position) then
		return raycast.Position.Y
	end

	return nil
end

function WaterUtils.FindNearbyWaterSurface(vector2: Vector3, data)
	local vector3 = Vector3.new(0, -data.RayLength, 0)

	for i = data.MinRadius, data.MaxRadius, data.RadiusStep do
		local number = random:NextNumber(0, 6.283185307179586)

		for i2 = 0, 360, data.AngleStep do
			local v3 = CFrame.fromOrientation(0, math.rad(i2) + number, 0) * CFrame.new(0, data.ExtraStartHeight, i) + vector2
			local raycast = RayVisual.raycast(v3.Position, vector3, raycastParams2, data.ShowRays and v2 or nil)

			if not (raycast and (raycast.Material == Enum.Material.Water or raycast.Instance:HasTag("PartWater"))) then
				continue
			end

			if data.AllowDangerous or not WaterUtils.DangerCheck(raycast.Position) then
				return raycast.Position
			end

			if not data.SlowerDangerCheck then
				return nil
			end
		end
	end

	return nil
end

function WaterUtils.DangerCheck(vector2: Vector3)
	return #workspace:GetPartBoundsInRadius(vector2, 2.5, overlapParams) > 0
end

function WaterUtils.IsPartDangerous(instance)
	for _, tag in v do
		if instance:HasTag(tag) then
			return true
		end
	end

	return false
end

local v3 = "." .. table.concat(v, ", .")
local flag = false

local function updateDangerInstances()
	if flag then
		return
	end

	flag = true
	task.defer(function()
		flag = false
		overlapParams.IncludeInstances = workspace:QueryDescendants(v3)
	end)
end

for _, v4 in v do
	CollectionService:GetInstanceAddedSignal(v4):Connect(updateDangerInstances)
	CollectionService:GetInstanceRemovedSignal(v4):Connect(updateDangerInstances)
end

if not flag then
	flag = true
	task.defer(function()
		flag = false
		overlapParams.IncludeInstances = workspace:QueryDescendants(v3)
	end)
end

return WaterUtils