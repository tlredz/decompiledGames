local parent = script.Parent.Parent
local ConfigHandler = require(parent.AI.ConfigHandler)
local Common = require(parent.Common)
require(parent.Math)
local CommonMathRequests = require(parent.AI.CommonMathRequests)
local Debugging = require(parent.AI.Debugging)
local PositionalOptimization = require(parent.AI.PositionalOptimization)
require(script.Parent.Types)
local v = {}
local DirectMoveTo = {}

function DirectMoveTo.CanUseDirectMoveTo(instance, instance2)
	local activeConfig = ConfigHandler.GetActiveConfig(instance)

	if not activeConfig.DirectMoveTo.Enabled then
		return false
	end

	if not v[instance] then
		v[instance] = {
			LastCheckFloorFailTime = 0,
			JumpStuckTime = 0,
			JumpDebounceTime = 0
		}
	end

	if v[instance] and os.clock() < v[instance].LastCheckFloorFailTime + activeConfig.DirectMoveTo.CheckFloor.BlockDirectMoveToTimer then
		return false
	end

	local function getRes()
		if typeof(instance2) ~= "Instance" or activeConfig.DirectMoveTo.TrackingOnly and not activeConfig.Tracking.Enabled then
			return false
		end

		local basePart = Common.GetBasePart(instance2)

		if basePart == nil then
			error("NO NPC BASE")
		end

		local basePart2 = Common.GetBasePart(instance2, true, instance)

		if basePart2 == nil then
			error("NO NPC BASE")
		end

		local position = basePart.CFrame.Position
		local position2 = basePart2.CFrame.Position

		if (position - position2).Magnitude > activeConfig.DirectMoveTo.ActivationDistance or position.Y - position2.Y > activeConfig.DirectMoveTo.HeightLimit then
			return false
		end

		if activeConfig.DirectMoveTo.Raycast.Enabled and not CommonMathRequests.CanMoveToRaycast(instance, instance2) then
			Debugging.LogWithVerbosity(instance, 5, "[" .. instance:GetFullName() .. "] cannot see target.")
			return false
		end

		if activeConfig.DirectMoveTo.CheckFloor.Enabled and Common.GetDistanceFromNPCToTarget(instance, instance2) > activeConfig.DirectMoveTo.CheckFloor.DisableIfDistanceIsLessThan and not CommonMathRequests.CanCrossFloorRaycast(
			instance,
			instance2
		) then
			Debugging.Log(instance, "Failed cross floor check to target.")
			return false
		end

		if not activeConfig.DirectMoveTo.AvoidUseHook() then
			return true
		end

		Debugging.Log(instance, "DirectMoveTo was avoided by the user hook.")
		return false
	end

	local res = getRes()

	if not res then
		v[instance].LastCheckFloorFailTime = os.clock()
	end

	return res
end

function DirectMoveTo.GetDirectMoveToPosition(p, p2)
	local basePart = Common.GetBasePart(p)

	if basePart == nil then
		error("NO NPC BASE")
	end

	local basePart2 = Common.GetBasePart(p2, true, p)

	if basePart2 == nil then
		error("NO TARGET BASE")
	end

	local position = basePart.CFrame.Position
	local position2 = basePart2.CFrame.Position
	local activeConfig = ConfigHandler.GetActiveConfig(p)

	if activeConfig.Tracking.Enabled and activeConfig.Tracking.PredictionMagnitude > 0 then
		position2 = PositionalOptimization.PredictMovement(basePart2, activeConfig.Tracking.PredictionMagnitude)
	end

	return (PositionalOptimization.GetCollinearTargetPositionOffset(
		position2,
		position,
		activeConfig.Tracking.CollinearTargetPositionOffset
	))
end

function DirectMoveTo.DoJumpTick(instance, p)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoid == nil then
		return
	end

	if not v[instance] then
		v[instance] = {
			LastCheckFloorFailTime = 0,
			JumpStuckTime = 0,
			JumpDebounceTime = 0
		}
	end

	local activeConfig = ConfigHandler.GetActiveConfig(instance)

	if activeConfig.DirectMoveTo.JumpHandler.CustomJumpFunction and activeConfig.DirectMoveTo.JumpHandler.CustomJumpFunction(
		instance,
		p
	) then
		Debugging.Log(instance, "Custom jump function returned true, jumping.")
		humanoid.Jump = true
		return true
	else
		if not activeConfig.AgentInfo.AgentCanJump or not activeConfig.DirectMoveTo.TrackingOnly and activeConfig.Tracking.Enabled or not activeConfig.DirectMoveTo.JumpHandler.Enabled then
			return
		end

		local basePart = Common.GetBasePart(instance)
		local basePart2 = Common.GetBasePart(p, true, instance)

		if basePart2 == nil then
			error("This should not happen!")
		end

		local magnitude = (basePart2.CFrame.Position - basePart.CFrame.Position).Magnitude
		local v2 = basePart.AssemblyLinearVelocity.Magnitude < humanoid.WalkSpeed * 0.5
		local v3 = Vector3.new(basePart.AssemblyLinearVelocity.X, 0, basePart.AssemblyLinearVelocity.Z).Magnitude < humanoid.WalkSpeed * 0.33
		local v4 = (humanoid.WalkToPoint - basePart.CFrame.Position).Magnitude > activeConfig.DirectMoveTo.JumpHandler.DistanceFromMoveToPoint
		local v5 = not activeConfig.Tracking.Enabled or magnitude < activeConfig.Tracking.CollinearTargetPositionOffset + activeConfig.Tracking.DistanceMovedThreshold + 0.1

		if v2 and v3 and v4 and not v5 then
			if v[instance].JumpStuckTime + activeConfig.DirectMoveTo.JumpHandler.MinConditionReachedTime < os.clock() then
				if v[instance].JumpDebounceTime + activeConfig.DirectMoveTo.JumpHandler.NextJumpMinTime > os.clock() then
					return false
				end

				humanoid.Jump = true
				v[instance].JumpDebounceTime = os.clock()
				Debugging.Log(instance, "Jumping")
				return true
			end
		else
			v[instance].JumpStuckTime = os.clock()
		end

		return false
	end
end

function DirectMoveTo.TriggerCleanup(p)
	v[p] = nil
end

return DirectMoveTo