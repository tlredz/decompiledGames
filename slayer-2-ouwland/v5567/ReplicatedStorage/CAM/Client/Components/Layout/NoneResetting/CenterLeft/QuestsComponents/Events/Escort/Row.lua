local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Health = require(script.Parent.Health)
local Profile = require(script.Parent.Profile)
local Route = require(script.Parent.Route)
require(script.Parent.Types)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.2)
return function(object, p, p2: number)
	return object:Create("CanvasGroup")({
		Size = UDim2.fromScale(1, 1.3),
		Name = "Holder",
		BackgroundTransparency = 1,
		GroupTransparency = object:Animation(0, info, {
			From = 1
		}),
		OnClean = function()
			return {
				GroupTransparency = object:Animation(1, info)
			}
		end,
		object:Create("Frame")({
			Name = "Actual",
			Size = UDim2.fromScale(1, 0.7692307692307692),
			BackgroundColor3 = Color3.new(),
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.4),
					NumberSequenceKeypoint.new(0.7, 0.8),
					NumberSequenceKeypoint.new(1, 0.95)
				}),
				Rotation = 90
			}),
			object:Create("UICorner")({
				CornerRadius = UDim.new(0.2)
			}),
			object:Create("Frame")({
				Name = "ActualHolder",
				Size = UDim2.fromScale(1, 1),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 4, 0.5),
				BackgroundTransparency = 1,
				object:Create("UIListLayout")({
					Name = "List",
					FillDirection = Enum.FillDirection.Vertical,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					Padding = UDim.new(0, 2)
				}),
				Profile(object, p, p2),
				Health(object, p, p2),
				Route(object, p, p2)
			})
		})
	})
end