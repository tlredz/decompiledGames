local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(script.Parent.Types)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.4)
local color = Color3.fromRGB(88, 199, 108)
local color2 = Color3.fromRGB(199, 72, 72)
return function(object, data, _: number)
	local function healthColor(callback)
		return color:Lerp(color2, 1 - callback(data.HealthPercent))
	end

	return object:Create("Frame")({
		Name = "AHealthHolder",
		LayoutOrder = 2,
		Size = UDim2.fromScale(0.4, 0.1),
		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),
		object:Create("UIShadow")({
			BlurRadius = UDim.new(1),
			Transparency = 0.8
		}),
		object:Create("UIAspectRatioConstraint")({
			AspectRatio = 25
		}),
		object:Create("UIStroke")({
			Transparency = object:Animation(data.StrokeTransparency, info, {
				AlwaysFrom = 0,
				From = data.StrokeTransparency.Value
			}),
			Color = Color3.new(1, 1, 1),
			Thickness = object:Animation(data.StrokeThickness, info, {
				AlwaysFrom = 2,
				From = data.StrokeThickness.Value
			})
		}),
		object:Create("Frame")({
			Name = "bar",
			ZIndex = 2,
			BackgroundColor3 = object:Do(function(p, _, _)
				return healthColor(p)
			end),
			BackgroundTransparency = 0,
			Size = object:Lerp(data.HealthSize, 0.1),
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			object:Create("ImageLabel")({
				Name = "Inner",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = "rbxassetid://96840853773997",
				ImageColor3 = Color3.new(),
				ImageTransparency = 0.855
			})
		}),
		object:Create("Frame")({
			Name = "barwhite",
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0,
			Size = object:Lerp(data.HealthSize, 0.05),
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			})
		}),
		object:Create("TextLabel")({
			Name = "HealthText",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(1.045, 0.2),
			Size = UDim2.fromScale(0.7, 3),
			BackgroundTransparency = 1,
			Text = data.HealthText,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextScaled = true,
			Font = Enum.Font.SourceSansSemibold,
			TextColor3 = object:Do(function(callback, _, _)
				return color:Lerp(color2, 1 - callback(data.HealthPercent)):Lerp(Color3.new(1, 1, 1), 0.55)
			end),
			object:Create("UIStroke")({
				Thickness = 2,
				Transparency = 0.875
			})
		})
	})
end