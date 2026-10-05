local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.2)
local color = Color3.new(0.6, 0.6, 0.6)
local color2 = Color3.fromRGB(170, 190, 215)
return function(object, object2, callback)
	local value = object:Value(color)
	return object:Create("Frame")({
		Size = UDim2.fromScale(1, 1),
		Instance.new("UIAspectRatioConstraint"),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = object:Animation(value, info),
		object:Create("UICorner")({
			CornerRadius = UDim.new(0.35)
		}),
		object:Create("UIGradient")({
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.8) }),
			Rotation = -90
		}),
		object:Create("UIShadow")({
			BlurRadius = UDim.new(1, 0),
			Spread = UDim2.new(-0.5, 0, -0.5, 0),
			Color = object:Animation(value, info)
		}),
		object:Create("ImageLabel")({
			Name = "Icon",
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			ScaleType = Enum.ScaleType.Fit,
			Image = object:Do(function(callback2)
				if callback2(object2) then
					return BunchaIcons.Checkmark2
				end

				return BunchaIcons.EditOn
			end)
		}),
		object:Create("TextButton")({
			Size = UDim2.fromScale(1.3, 1.3),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			MouseButton1Click = function()
				ScreenEffects.CircleClick()
				local v = not object2:Compare(true)

				if not v and callback ~= nil then
					callback()
				end

				object2:Set(v)
				local v3

				if v then
					v3 = color2
				else
					v3 = color
				end

				value:Set(v3)
			end
		})
	})
end