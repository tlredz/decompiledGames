local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local Archives = require(ReplicatedStorage.CAM.Client.Modules.Archives)
local WorldBosses = require(ReplicatedStorage.CAM.Client.Modules.WorldBosses)
local BossPin = require(script.Parent.BossPin)
require(script.Parent.Types)
return function(object, p)
	local value = object:Value({})
	object:Spawn(function()
		Archives.WaitLoaded()
		value:Set(WorldBosses.Get())
	end)
	return object:Create("Frame")({
		Name = "Bosses",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		object:Iterate(value, function(_, p2, p3)
			return BossPin(p3, p, p2)
		end)
	})
end