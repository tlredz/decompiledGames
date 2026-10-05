local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
require(script.Parent.Parent.Types)
require(ReplicatedStorage.Packages.faye)
local color = Color3.fromRGB(88, 199, 108)
local color2 = Color3.new(0.1, 0.1, 0.1)
local color3 = Color3.fromRGB(120, 25, 25)
return function(object, data, p: number)
	local legs = data.Legs
	return object:Create("Frame")({
		Name = "Ambush" .. p,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(1, 2.2),
		Position = object:Do(function(p2, _, _)
			return UDim2.fromScale((p - 1) / legs, data.IsLive(p2, p) and 2.2 or 0.5)
		end),
		BackgroundTransparency = 1,
		Instance.new("UIAspectRatioConstraint"),
		object:Create("Frame")({
			Name = "Disc",
			Size = UDim2.fromScale(2, 2),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			object:Create("UIShadow")({
				BlurRadius = UDim.new(1),
				Transparency = 0.3,
				Spread = UDim2.fromScale(-0.2, -0.2),
				Color = object:Do(function(p2, _, _)
					if data.IsLive(p2, p) then
						return color3
					end

					return color2
				end)
			}),
			BackgroundTransparency = 0.75,
			BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			object:Create("ImageLabel")({
				Name = "Icon",
				ZIndex = 2,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = object:Do(function(p2, _, _)
					if data.IsCleared(p2, p) then
						return BunchaIcons.Checkmark
					end

					return BunchaIcons.Combat
				end),
				ImageColor3 = object:Do(function(p2, _, _)
					if data.IsCleared(p2, p) then
						return color
					end

					return (Color3.new(1, 1, 1))
				end),
				ImageTransparency = 0
			})
		})
	})
end