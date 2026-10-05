local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Common.Utils)
local FastUtils = require(ReplicatedStorage.Shared.FastUtils)
return Observers.observeTagNoAncestry("EvilElfIcePlatform", function(instance)
	local maid = Trove.new()
	local maxSize = instance:GetAttribute("MaxSize") or 3
	local duration = instance:GetAttribute("Duration") or 10
	instance.CanCollide = true
	maid:Add(FastUtils.fastTween(instance, TweenInfo.new(4.5, Enum.EasingStyle.Sine), {
		Size = maxSize * instance.Size * createVector(1, 0, 1) + createVector(0, 1, 0)
	})):Play()
	maid:Add(FastUtils.fastTween(instance, TweenInfo.new(2, Enum.EasingStyle.Sine), {
		Transparency = 0
	})):Play()
	maid:Add(task.delay(duration - 3, function()
		instance.CustomPhysicalProperties = PhysicalProperties.new(Enum.Material.Plastic)
		maid:Add(FastUtils.fastTween(instance, TweenInfo.new(3), {
			Transparency = 1
		})):Play()
	end))
	return function()
		maid:Destroy()
	end
end)