local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
return function(object, callback)
	local preferedFont = gameSettings.preferedFont
	return object:Create("TextLabel")({
		Name = "Refine",
		ZIndex = 3,
		Visible = object:Do(function(p)
			return (callback(p) or 0) > 0
		end),
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.new(0, 4, 0, 1),
		Size = UDim2.fromScale(0.42, 0.34),
		BackgroundTransparency = 1,
		Text = object:Do(function(p)
			return (`+{callback(p) or 0}`)
		end),
		TextXAlignment = Enum.TextXAlignment.Left,
		FontFace = Font.new(preferedFont.Family, Enum.FontWeight.Bold, Enum.FontStyle.Normal),
		TextScaled = true,
		TextColor3 = Color3.new(1, 1, 1),
		object:Create("UIStroke")({
			Thickness = 1,
			Color = Color3.fromRGB(85, 170, 255),
			object:Create("UIGradient")({
				Rotation = 90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(155, 220, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 95, 200))
				}),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.5, 0.3),
					NumberSequenceKeypoint.new(1, 0.85)
				})
			})
		})
	})
end