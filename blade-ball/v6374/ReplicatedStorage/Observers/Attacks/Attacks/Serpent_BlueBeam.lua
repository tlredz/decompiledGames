local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("SoundService")
game:GetService("RunService")
game:GetService("Players")
local Trove = require(ReplicatedStorage.Packages.Trove)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.ServerInfo)
local FastUtils = require(ReplicatedStorage.Shared.FastUtils)
return Observers.observeTag("Dungeons_SerpentBlueBeam", function(instance)
	local maid = Trove.new()
	maid:Add(task.spawn(function()
		for i = 1, instance:GetAttribute("TotalTargets") do
			task.wait(instance:GetAttribute((`TargetDelay{i}`)) or 0)
			local attribute = instance:GetAttribute((`TargetTime{i}`)) or 0
			maid:Add(FastUtils.fastTween(instance, TweenInfo.new(attribute, Enum.EasingStyle.Sine), {
				CFrame = instance:GetAttribute((`Target{i}`))
			}))
			task.wait(attribute)
		end
	end))
	return function()
		maid:Destroy()
	end
end, { workspace })