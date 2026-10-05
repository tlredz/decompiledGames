game:GetService("ReplicatedStorage")
local faye = require(game.ReplicatedStorage.Packages.faye)
local info = faye.Info(0.25)
return function(parent, _, object)
	object:Create("Frame")({
		Parent = parent,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(25, 0.25),
		Instance.new("UIAspectRatioConstraint"),
		BackgroundTransparency = 1,
		object:Create("ImageLabel")({
			Size = UDim2.fromScale(2.5, 2.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			ImageTransparency = object:Animation(0.25, info, {
				From = 1
			}),
			Image = "rbxassetid://93437195955932",
			ImageColor3 = Color3.fromRGB(169, 206, 255),
			OnClean = function(object2)
				return {
					ImageTransparency = object2:Animation(1, info)
				}
			end,
			object:Create("ImageLabel")({
				Size = UDim2.fromScale(0.2, 0.2),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				ImageTransparency = object:Animation(0.25, info, {
					From = 1
				}),
				Image = "rbxassetid://16873598266",
				ImageColor3 = Color3.fromRGB(73, 191, 255),
				object:Create("UIStroke")({
					Color = Color3.new(1, 1, 1),
					Transparency = object:Animation(0, info, {
						From = 1
					}),
					OnClean = function(object2)
						return {
							Transparency = object2:Animation(1, info)
						}
					end
				}),
				object:Create("UICorner")({
					CornerRadius = UDim.new(1)
				}),
				OnClean = function(object2)
					return {
						ImageTransparency = object2:Animation(1, info)
					}
				end
			})
		}),
		CleanDelay = 0.5
	})
end