local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Common.Utils)
local FastUtils = require(ReplicatedStorage.Shared.FastUtils)
return Observers.observeTagNoAncestry("EvilElfFakeGift", function(instance)
	local maid = Trove.new()
	local cFrame = instance.CFrame
	local targetCFrame = instance:GetAttribute("TargetCFrame") or instance.CFrame * CFrame.new(0, -instance.Size.Y, 0)
	local duration = instance:GetAttribute("Duration") or 10
	maid:Add(FastUtils.fastTween(instance, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
		CFrame = targetCFrame
	})):Play()
	maid:Add(task.delay(duration - 0.5 - 0.1, function()
		maid:Add(FastUtils.fastTween(instance, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			CFrame = cFrame
		})):Play()
	end))
	return function()
		maid:Destroy()
	end
end)