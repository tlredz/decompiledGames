local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local color = Color3.fromRGB(255, 200, 80)
local color2 = Color3.fromRGB(120, 80, 10)
return function(object, p: number)
	local preferedFont = gameSettings.preferedFont
	return object:Create("TextLabel")({
		Name = "Tier",
		ZIndex = 3,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -4, 0, 1),
		Size = UDim2.fromScale(0.42, 0.34),
		BackgroundTransparency = 1,
		Text = `T{p}`,
		TextXAlignment = Enum.TextXAlignment.Right,
		FontFace = Font.new(preferedFont.Family, Enum.FontWeight.Bold, Enum.FontStyle.Normal),
		TextScaled = true,
		TextColor3 = color,
		object:Create("UIStroke")({
			Thickness = 1,
			Color = color2,
			Transparency = 0.3
		})
	})
end