local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Client.GuardTutorialPresentation)
require(script.Parent.Types.Interface)
local StepUtils = require(script.Parent.Parent.StepUtils)
local color = Color3.fromRGB(255, 255, 255)
local HatchEgg = {
	StepId = "HatchEgg",
	IsSatisfied = function(object)
		return object:HasHatchedEgg()
	end
}

function HatchEgg.Bind(p, callback)
	return StepUtils.BindOnAdapterChanged(p, HatchEgg.IsSatisfied, callback)
end

function HatchEgg.Present(object, object2)
	local function refreshPresentation()
		if HatchEgg.IsSatisfied(object2) then
			object:DropEverything()
			return
		end

		if not object2:HasHatchableEgg() then
			object:DropEverything()
			return
		end

		object:AnnounceTyped("Hatch the Egg!", color)
		local nearestHatchableEggTarget = object2:GetNearestHatchableEggTarget()

		if nearestHatchableEggTarget == nil then
			object:DropBeam()
		else
			object:RetargetBeam(nearestHatchableEggTarget)
		end
	end

	local changedConnection = object2.Changed:Connect(refreshPresentation)
	local total = 0
	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		total += dt

		if total < 0.25 then
			return
		end

		total = 0
		refreshPresentation()
	end)
	refreshPresentation()
	return function()
		changedConnection:Disconnect()
		heartbeatConnection:Disconnect()
		object:DropEverything()
	end
end

return HatchEgg