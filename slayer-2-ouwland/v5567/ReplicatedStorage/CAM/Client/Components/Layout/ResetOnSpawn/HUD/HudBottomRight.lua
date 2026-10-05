local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local FirstVertical = require(script.FirstVertical)
local KeybindHelper = require(script.Parent.KeybindHelper)
return function(object, parent)
	local value = object:Value(Platform_Handler.KeyLabelOffset())
	object:Connect(Platform_Handler.Platform.Changed.Event, function()
		value:Set(Platform_Handler.KeyLabelOffset())
	end)
	return object:Create("Frame")({
		Parent = parent,
		Name = "HudBottomRight",
		Size = UDim2.fromScale(0.1, 0.075),
		AnchorPoint = Vector2.new(1, 1),
		Position = object:Do(function(callback)
			return UDim2.new(1, -11, 1, -callback(value))
		end),
		BackgroundTransparency = 1,
		object:Create("UIListLayout")({
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 2)
		}),
		KeybindHelper(object, {
			OnlyOn = {
				PC = true,
				Xbox = true,
				Playstation = true
			},
			LayoutOrder = -1,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			TextXAlignment = Enum.TextXAlignment.Right
		}),
		FirstVertical(object, parent)
	})
end