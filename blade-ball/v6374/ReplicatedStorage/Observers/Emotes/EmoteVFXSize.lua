local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTag("EmoteVFXSize", function(instance)
	local v = nil
	local thread = task.delay(instance:GetAttribute("WaitTime") or 0, function()
		v = TweenService:Create(
			instance,
			TweenInfo.new(instance:GetAttribute("Time") or 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				Size = instance:GetAttribute("TargetSize") or 0
			}
		)
		v:Play()
	end)
	return function()
		if v then
			v:Cancel()
			v:Destroy()
		end

		if coroutine.status(thread) == "suspended" then
			pcall(task.cancel, thread)
		end
	end
end, { workspace })