local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Forbidden.Packages.robloxstatemachine)
require(script.Parent.ConfigHandler)
local PositionalOptimization = {}

function PositionalOptimization.GetGroundedPosition(vector2: Vector3, p, value: number?)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { p }
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.RespectCanCollide = true
	local raycastResult = workspace:Raycast(vector2, createVector(0, -1, 0) * (value or 3), raycastParams)

	if raycastResult == nil then
		return nil
	end

	if raycastResult.Instance then
		return raycastResult.Position + createVector(0, 2, 0)
	end

	return vector2
end

function PositionalOptimization.GetCollinearTargetPositionOffset(vector2: Vector3, vector3: Vector3, p: number)
	local v = vector3 - vector2

	if not (p ~= 0 and v.Magnitude ~= 0) then
		return vector2
	end

	if v.Magnitude < p then
		return vector3
	end

	return vector2 + v.Unit * p
end

function PositionalOptimization.PredictMovement(instance, p: number)
	local position = instance.CFrame.Position

	if p <= 0 or instance.AssemblyLinearVelocity.Magnitude < 0.1 then
		return position
	end

	local unit = Vector3.new(instance.AssemblyLinearVelocity.X, 0, instance.AssemblyLinearVelocity.Z).Unit

	if unit.X == unit.X then
		return position + unit * p
	end

	return position
end

return PositionalOptimization