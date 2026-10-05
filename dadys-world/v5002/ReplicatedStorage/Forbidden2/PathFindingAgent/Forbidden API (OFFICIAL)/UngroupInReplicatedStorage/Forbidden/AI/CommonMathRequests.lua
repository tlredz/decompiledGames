local createVector = vector.create
local CommonMathRequests = {}
local parent = script.Parent.Parent
local Common = require(parent.Common)
local Math = require(parent.Math)
local ConfigHandler = require(parent.AI.ConfigHandler)
require(parent.AI.Debugging)

function CommonMathRequests.CanMoveToRaycast(p, p2)
	local activeConfig = ConfigHandler.GetActiveConfig(p)

	if not activeConfig.DirectMoveTo.Raycast.Enabled then
		return true
	end

	local raycast = activeConfig.DirectMoveTo.Raycast
	return Math.LineOfSight(p, p2, raycast)
end

function CommonMathRequests.CanCrossFloorRaycast(instance, instance2)
	local activeConfig = ConfigHandler.GetActiveConfig(instance)
	local basePart = Common.GetBasePart(instance, true, instance)
	local basePart2 = Common.GetBasePart(instance2, true, instance)

	if basePart == nil then
		error("Cannot get BasePart in NPC: " .. instance:GetFullName())
	end

	if basePart2 == nil then
		error("Cannot get BasePart in Target: " .. instance2:GetFullName())
	end

	local v = basePart2.CFrame.Position - basePart.CFrame.Position
	local magnitude = v.Magnitude
	local unit = v.Unit

	local function ValidRaycastToGround(vector2: Vector3)
		local raycastParams = RaycastParams.new()

		if typeof(instance2) == "Instance" then
			raycastParams:AddToFilter(instance2)
		else
			raycastParams:AddToFilter(basePart2)
		end

		raycastParams.FilterDescendantsInstances = { instance }
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.RespectCanCollide = true
		return workspace:Raycast(
			vector2,
			createVector(0, -1, 0) * activeConfig.DirectMoveTo.CheckFloor.FailHeight,
			raycastParams
		) ~= nil
	end

	local function FirstRaycastValid()
		if activeConfig.DirectMoveTo.CheckFloor.AlwaysRaycastThisDistance == 0 or magnitude > activeConfig.DirectMoveTo.CheckFloor.AlwaysRaycastThisDistance then
			return true
		end

		return (ValidRaycastToGround(basePart.CFrame.Position + unit * activeConfig.DirectMoveTo.CheckFloor.AlwaysRaycastThisDistance))
	end

	if activeConfig.DirectMoveTo.CheckFloor.AlwaysRaycastThisDistance ~= 0 and not (activeConfig.DirectMoveTo.CheckFloor.AlwaysRaycastThisDistance < magnitude or ValidRaycastToGround(basePart.CFrame.Position + unit * activeConfig.DirectMoveTo.CheckFloor.AlwaysRaycastThisDistance)) then
		return false
	end

	while magnitude - activeConfig.DirectMoveTo.CheckFloor.RaycastSpacing > activeConfig.DirectMoveTo.CheckFloor.AlwaysRaycastThisDistance do
		magnitude -= activeConfig.DirectMoveTo.CheckFloor.RaycastSpacing

		if not ValidRaycastToGround(basePart.CFrame.Position + magnitude * unit) then
			return false
		end
	end

	return true
end

return CommonMathRequests