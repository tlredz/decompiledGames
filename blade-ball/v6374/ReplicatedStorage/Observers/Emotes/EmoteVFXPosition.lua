local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTag("EmoteVFXPosition", function(instance)
	local easingDirection = instance:GetAttribute("EasingDirection") or "InOut"
	local easingStyle = instance:GetAttribute("EasingStyle") or "Linear"
	local property = instance:GetAttribute("Property") or "C0"
	local cFrame = instance:GetAttribute("CFrame") or CFrame.identity
	local time = instance:GetAttribute("Time") or 0
	local v = Enum.EasingStyle[easingStyle]
	local v2 = Enum.EasingDirection[easingDirection]
	local v3 = instance[property]
	local total = 0
	local postSimulationConnection = RunService.PostSimulation:Connect(function(dt: number)
		total += dt
		instance[property] = v3:Lerp(cFrame, (TweenService:GetValue(math.clamp(total / time, 0, 1), v, v2)))
	end)
	return function()
		postSimulationConnection:Disconnect()
	end
end, { workspace })