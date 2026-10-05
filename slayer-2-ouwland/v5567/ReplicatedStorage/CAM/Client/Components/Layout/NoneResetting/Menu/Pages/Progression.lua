local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerInfo = require(script.PlayerInfo)
local ProgressHolder = require(script.ProgressHolder)
require(ReplicatedStorage.Packages.faye)
return function(object, _)
	return object:Create("Frame")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = object:Animation(UDim2.fromScale(0.7, 0.7), object.SpringInfo(0.35, 1, 0.65), {
			From = UDim2.fromScale(0.63, 0.63)
		}),
		Instance.new("UIAspectRatioConstraint"),
		BackgroundTransparency = 1,
		object:Create("UIListLayout")({
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0.05, 0)
		}),
		PlayerInfo(object),
		ProgressHolder(object)
	})
end