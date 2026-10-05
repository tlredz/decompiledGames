local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local HealthAndStats = require(script.HealthAndStats)
local EXP = require(script.EXP)
local PvpSwitch = require(script.Parent.PvpSwitch)
return function(object, parent)
	return object:Create("Frame")({
		Parent = parent,
		Name = "LeftHudPortion",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 5, 1, -5),
		Size = UDim2.fromScale(0.135, 0.1),
		BackgroundTransparency = 1,
		HealthAndStats(object, parent),
		EXP(object, parent),
		PvpSwitch(object, {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 0, 0, -6)
		})
	})
end