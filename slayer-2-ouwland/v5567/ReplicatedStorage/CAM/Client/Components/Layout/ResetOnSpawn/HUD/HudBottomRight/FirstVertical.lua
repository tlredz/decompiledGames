local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shiftlock = require(script.Shiftlock)
local Wen = require(script.Wen)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
return function(object, p)
	local value = object:Value(Platform_Handler.IsGamepad())
	object:Connect(Platform_Handler.Platform.Changed.Event, function()
		value:Set(Platform_Handler.IsGamepad())
	end)
	return object:Create("Frame")({
		Name = "ExpFrame",
		Size = UDim2.fromScale(0.6, 0.6),
		AnchorPoint = Vector2.new(0, 1),
		object:Create("UIAspectRatioConstraint")({}),
		Position = UDim2.fromScale(0.05, 0.65),
		BackgroundTransparency = 1,
		object:Create("UIListLayout")({
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = object:Do(function(callback)
				if callback(value) == true then
					return Enum.VerticalAlignment.Top
				end

				return Enum.VerticalAlignment.Bottom
			end),
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.Name
		}),
		object:State(function(callback, p2)
			if callback(value) == true then
				return nil
			end

			return Shiftlock(p2, p)
		end),
		Wen(object, p)
	})
end