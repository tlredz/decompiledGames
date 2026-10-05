local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local shared = ReplicatedStorage.shared
local GeneralUtils = require(shared.utils.GeneralUtils)
local base = script.Parent.Parent.Base
local owner = script.Parent.Parent.owner
local hingeConstraint = script.Parent.MainPart.HingeConstraint
RunService.Stepped:Connect(function()
	local v = base.AssemblyLinearVelocity.Magnitude * GeneralUtils.safeUnit(base.AssemblyLinearVelocity):Dot(base.CFrame.LookVector)

	if owner.Throttle < 0 then
		v = -v
	end

	if v < 0 then
		hingeConstraint.AngularVelocity = GeneralUtils.percentageBetweenRange(v, 0, -3.5, -100)
	else
		hingeConstraint.AngularVelocity = GeneralUtils.percentageBetweenRange(v, 0.5, 5, 100)
	end
end)