local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
return function(object, data)
	local value = object:Value(0.5)
	local value2 = object:Value(0.5)
	local info = object.Info(0.2)
	return object:Create("TextButton")({
		Name = data == nil and "Button" or data.Name or "Button",
		Size = object:Animation(UDim2.fromScale(1, 1), object.SpringInfo(0.25), {
			From = UDim2.fromScale(0.5, 0.5)
		}),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = object:Animation(value, info),
		AutoButtonColor = false,
		object:Create("UICorner")({
			CornerRadius = UDim.new(1)
		}),
		object:Create("ImageLabel")({
			Size = UDim2.fromScale(1, 0.8),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			ScaleType = Enum.ScaleType.Fit,
			Image = data.Image,
			ImageTransparency = 0,
			ImageColor3 = Color3.new()
		}),
		MouseEnter = function()
			value:Set(0)
			value2:Set(0)
		end,
		MouseLeave = function()
			value:Reset()
			value2:Reset()
		end,
		MouseButton1Click = function()
			ScreenEffects.CircleClick()

			if data.Clicked ~= nil then
				data.Clicked()
			end
		end,
		object:Create("UIStroke")({
			Color = Color3.new(1, 1, 1),
			Transparency = object:Animation(value2, data)
		}),
		object:Create("Frame")({
			Size = UDim2.new(1, 2, 1, 2),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			object:Create("UIStroke")({
				Color = Color3.new(1, 1, 1),
				Transparency = object:Animation(value2, data)
			}),
			object:Create("UICorner")({
				CornerRadius = UDim.new(1, 0)
			})
		})
	})
end