local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
game:GetService("RunService")
game:GetService("Players")
local Net = require(ReplicatedStorage.Packages.Net)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.ServerInfo)
require(ReplicatedStorage.Common.Utils)
local FastUtils = require(ReplicatedStorage.Shared.FastUtils)
Net:RemoteEvent("RequestSelfDamage")
return Observers.observeTag("Dungeons_PurpleBallAttack", function(instance)
	local maid = Trove.new()
	local size = instance.Size
	instance.Size = createVector(0, 0, 0)
	maid:Add(FastUtils.fastTween(instance, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Size = size
	}))
	maid:Add(FastUtils.fastTween(instance, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Position = instance:GetAttribute("Target")
	}))
	maid:Add(FastUtils.fastTween(
		instance,
		TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 3),
		{
			Transparency = 1
		}
	))
	return function()
		maid:Destroy()
	end
end, { workspace })