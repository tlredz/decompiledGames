local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Areas = require(ReplicatedStorage.Data.Areas)
local GuardChasePolicy = require(script.Parent.GuardChasePolicy)
local GuardEscape = require(ReplicatedStorage.Shared.Utils.GuardEscape)
local GuardEscapePrediction = require(script.Parent.GuardEscapePrediction)
local Guards = require(ReplicatedStorage.Data.Guards)
local t = require(ReplicatedStorage.Packages.t)
require(script.Parent.Types.Interface)
local v = {
	SIGN_SPEEDS_ATTRIBUTE = "GuardEscapeSpeeds",
	BuildPathParameters = function(instance, vector: Vector3, p, p2)
		t.strict(t.instanceIsA("Model"))(instance)
		t.strict(t.Vector3)(vector)
		t.strict(t.instanceIsA("BasePart"))(p)
		local v2 = Areas.Directory[instance.Name]
		local v3 = p2 or Guards.Directory[v2.GuardId]
		local bounds = instance:FindFirstChild("Bounds")
		local closestExitPoint = instance:FindFirstChild("ClosestExitPoint")
		assert(bounds ~= nil, (`{instance:GetFullName()}.Bounds is required`))
		assert(closestExitPoint ~= nil, (`{instance:GetFullName()}.ClosestExitPoint is required`))
		assert(bounds:IsA("BasePart"), (`{instance:GetFullName()}.Bounds must be a BasePart`))
		assert(closestExitPoint:IsA("BasePart"), (`{instance:GetFullName()}.ClosestExitPoint must be a BasePart`))
		local exitDirection = -p.CFrame.LookVector
		return {
			BaseGuardWalkSpeed = v3.WalkSpeed,
			ExitDirection = exitDirection,
			ExitDistance = GuardEscapePrediction.ResolveExitDistance(
				bounds.CFrame,
				bounds.Size,
				closestExitPoint.Position,
				exitDirection
			),
			FlatRadius = v3.FlatRadius,
			GuardStartPosition = vector,
			HitDistance = GuardChasePolicy.ResolveHitDistance(v3.HitDistance),
			PlayerStartPosition = closestExitPoint.Position
		}
	end
}

function v.ResolveSpeedPower(p, vector: Vector3, p2)
	return GuardEscape.RequiredSpeedPower(v.BuildPathParameters(p, vector, p2))
end

function v.PublishSign(instance, p, p2, position: Vector3?)
	if position == nil then
		local guard = instance:FindFirstChild("Guard")
		local humanoidRootPart

		if guard ~= nil then
			humanoidRootPart = guard:FindFirstChild("HumanoidRootPart")
		end

		local v2

		if humanoidRootPart == nil then
			v2 = false
		else
			v2 = humanoidRootPart:IsA("BasePart")
		end

		assert(v2, (`{instance:GetFullName()}.Guard requires a root`))
		position = humanoidRootPart.Position
	end

	local pathParameters = v.BuildPathParameters(instance, position, p, p2)
	instance:SetAttribute(
		v.SIGN_SPEEDS_ATTRIBUTE,
		Vector2.new(
			GuardEscape.RequiredSpeedPower(pathParameters),
			GuardEscapePrediction.ResolvePlayerWalkSpeedRequirement(pathParameters, 1)
		)
	)
end

return table.freeze(v)