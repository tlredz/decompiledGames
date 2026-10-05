local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, false)
return function(object, p)
	return object:Create("ImageLabel")({
		Name = "Ping",
		ZIndex = p.ZIndex,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = object:Animation(UDim2.fromScale(1.8, 1.8), info, {
			From = UDim2.fromScale(1, 1)
		}),
		BackgroundTransparency = 1,
		Image = "rbxassetid://17359135613",
		ImageColor3 = p.Color,
		ImageTransparency = object:Animation(1, info, {
			From = 0.3
		})
	})
end