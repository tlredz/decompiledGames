local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
require(ReplicatedStorage.Packages.faye)
return function(object, data)
	local value = object:Value(0.5)
	local value2 = object:Value(0.4)
	local value3 = object:Value(0.2)
	local info = object.Info(0.2)
	return { object:Create("ImageButton")({
			Size = UDim2.fromScale(1, 1),
			Name = "Bg",
			MouseEnter = function()
				value:Set(0)
				value2:Set(0)
				value3:Set(0)
			end,
			MouseLeave = function()
				value2:Reset()
				value3:Reset()
				value:Reset()
			end,
			MouseButton1Click = function()
				ScreenEffects.CircleClick()

				if data.Clicked ~= nil then
					data.Clicked()
				end
			end,
			BackgroundTransparency = 1,
			Image = "http://www.roblox.com/asset/?id=17359135613",
			BackgroundColor3 = data.BgColor or Color3.new(1, 1, 1),
			ImageTransparency = object:Animation(value3, info),
			object:Create("Frame")({
				Name = "Stroke",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(1, 5, 1, 5),
				BackgroundTransparency = 1,
				object:Create("UICorner")({
					CornerRadius = UDim.new(1)
				}),
				object:Create("UIStroke")({
					Color = Color3.new(1, 1, 1),
					Transparency = object:Animation(value, info)
				})
			}),
			object:Create("ImageLabel")({
				ZIndex = 2,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				ImageColor3 = data.ImageColor or Color3.new(),
				Image = data.Image or "",
				Size = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				ImageTransparency = object:Animation(value2, info)
			})
		}) }
end