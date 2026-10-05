local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local faye = require(ReplicatedStorage.Packages.faye)
faye = faye.FayeTypes
return function(object, rotation: number, callback)
	local v = Platform_Handler.Platform.Value == "Mobile" and 1.2 or 1
	local v2 = false
	local value = object:Value(0.15)

	local function updIn()
		if value == nil or value.Set == nil then
			return
		end

		if v2 == true then
			value:Set(0)
		else
			value:Reset()
		end
	end

	return object:Create("TextButton")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(v, v),
		BackgroundTransparency = 1,
		object:Create("ImageLabel")({
			Rotation = rotation,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1 / v, 1 / v),
			BackgroundTransparency = 1,
			Image = "rbxassetid://10825169477",
			ImageTransparency = object:Animation(value, object.Info(0.2))
		}),
		MouseEnter = function()
			v2 = true

			if value ~= nil then
				if value.Set == nil then
					return
				end

				if v2 == true then
					value:Set(0)
				else
					value:Reset()
				end
			end
		end,
		MouseLeave = function()
			if v2 == true then
				v2 = false

				if value ~= nil then
					if value.Set == nil then
						return
					end

					if v2 == true then
						value:Set(0)
					else
						value:Reset()
					end
				end
			end
		end,
		MouseButton1Click = function()
			ScreenEffects.CircleClick()
			callback()
		end
	})
end