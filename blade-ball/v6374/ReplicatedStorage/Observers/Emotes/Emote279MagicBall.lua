local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local FastUtils = require(ReplicatedStorage.Shared.FastUtils)
local Utils = require(ReplicatedStorage.Common.Utils)
return Observers.observeTagNoAncestry("Emote279MagicBall", function(p)
	local v = {}
	local threads = {}
	table.insert(v, FastUtils.fastTween(p, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
		Size = createVector(3, 3, 3)
	}))
	table.insert(threads, task.delay(2.8333333333333335, function()
		table.insert(
			v,
			FastUtils.fastTween(
				p,
				TweenInfo.new(0.3333333333333333, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
				{
					Size = createVector(0, 0, 0)
				}
			)
		)
	end))
	return function()
		for _, v2 in threads do
			Utils.Thread.SafeCancel(v2)
		end

		for _, v2 in v do
			v2:Cancel()
			v2:Destroy()
		end
	end
end)