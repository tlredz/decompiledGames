local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local HealthAndStats = require(script.Parent.HudBottomLeft.HealthAndStats)
local EXP = require(script.Parent.HudBottomLeft.EXP)
local uDim = UDim2.fromScale(0.189, 0.15000000000000002)
local v = {
	Scale = 1.3,
	Down = 0.15
}
return function(object, parent)
	return object:Create("Frame")({
		Parent = parent,
		Name = "TopLeftHudPortion",
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromOffset(5, 5),
		Size = uDim,
		BackgroundTransparency = 1,
		HealthAndStats(object, parent),
		EXP(object, parent, v)
	})
end