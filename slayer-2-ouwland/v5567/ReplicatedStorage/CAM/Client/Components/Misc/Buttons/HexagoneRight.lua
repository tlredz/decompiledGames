local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
return function(object, data)
	local value = object:Value(UDim2.new())
	local value2 = object:Value(UDim2.fromScale(0.45, 0.5))
	local value3 = object:Value(UDim2.fromScale(0.5, 0.5))
	return object:Create("TextButton")({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		MouseEnter = function()
			value:Set(UDim2.fromScale(-0.1, 0))
			value2:Set(UDim2.fromScale(0.4, 0.5))
			value3:Set(UDim2.fromScale(0.3, 0.5))
		end,
		MouseLeave = function()
			value3:Reset()
			value:Reset()
			value2:Reset()
		end,
		MouseButton1Click = function()
			if data.Clicked ~= nil then
				data.Clicked()
			end

			ScreenEffects.CircleClick()
		end,
		object:Create("ImageLabel")({
			data.Props,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Position = object:Animation(value, object.SpringInfo(0.25, 1, 0.5)),
			Image = "rbxassetid://133141472680887",
			ImageColor3 = data.BgColor or Color3.new(0.156863, 0.156863, 0.156863),
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.5),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Rotation = 180
			}),
			object:Create("ImageLabel")({
				Size = UDim2.fromScale(0.8, 0.8),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = object:Animation(value2, object.Info(0.3, Enum.EasingStyle.Sine)),
				BackgroundTransparency = 1,
				Image = "rbxassetid://133141472680887",
				ImageColor3 = data.FgColor or Color3.new(0, 0, 0),
				object:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.5),
						NumberSequenceKeypoint.new(1, 1)
					}),
					Rotation = 180
				})
			}),
			object:Create("ImageLabel")({
				ZIndex = 2,
				Size = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = object:Animation(value3, object.Info(0.35, Enum.EasingStyle.Sine)),
				BackgroundTransparency = 1,
				Image = data.Image or "",
				ImageColor3 = data.ImageColor or Color3.new(1, 1, 1)
			})
		})
	})
end