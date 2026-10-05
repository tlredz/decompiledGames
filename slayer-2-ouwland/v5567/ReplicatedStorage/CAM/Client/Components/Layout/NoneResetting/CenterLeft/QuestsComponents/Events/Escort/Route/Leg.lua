local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(script.Parent.Parent.Types)
local faye = require(ReplicatedStorage.Packages.faye)
faye.Info(0.2)
return function(object, p, p2: number, p3)
	local legs = p.Legs
	return object:Create("Frame")({
		Name = "Leg" .. p2,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale((p2 - 1) / legs, 0.5),
		Size = UDim2.new(1 / legs, -4, 1, 0),
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 0.75,
		object:Create("UICorner")({
			CornerRadius = UDim.new(1)
		}),
		object:Create("UIShadow")({
			BlurRadius = UDim.new(1),
			Transparency = 0.85,
			Spread = UDim2.fromScale(0.2, 0.2)
		}),
		object:Create("Frame")({
			Name = "bar",
			ZIndex = 2,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0,
			Size = object:Do(function(callback, _, _)
				return UDim2.fromScale(math.clamp(callback(p3) * legs - (p2 - 1), 0, 1), 1)
			end),
			object:Create("UICorner")({
				CornerRadius = UDim.new(0.4)
			}),
			object:Create("ImageLabel")({
				Name = "Inner",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = "rbxassetid://96840853773997",
				ImageColor3 = Color3.new(),
				ImageTransparency = 0.855
			})
		})
	})
end