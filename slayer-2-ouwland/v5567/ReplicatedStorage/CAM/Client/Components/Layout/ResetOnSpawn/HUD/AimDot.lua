local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local Aim = require(ReplicatedStorage.CAM.Client.Components.Layout.ResetOnSpawn.Mobile.Aim)
return function(object, parent)
	object:Create("Frame")({
		Parent = parent,
		Name = "AimDotHolder",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 50,
		Active = false,
		Aim(object)
	})
end