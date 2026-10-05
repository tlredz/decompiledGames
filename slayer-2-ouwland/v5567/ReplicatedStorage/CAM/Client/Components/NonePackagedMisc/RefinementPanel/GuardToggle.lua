local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local Refinement = require(ReplicatedStorage.CAM.Global.Refinement)
local faye = require(ReplicatedStorage.Packages.faye)
require(script.Parent.Types)
local info = faye.Info(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local color = Color3.new(1, 0.803922, 0.305882)
local color2 = Color3.new(1, 1, 1)
return function(object, state, p: number, object2, p2: number)
	local v = p2 <= p
	local v2 = state.Mode:Get() == "Transfer"
	local item = Items[Refinement.GuardItem]
	local color3 = Rarities.Colors[item.Rarity or 1]
	local v3 = object:Create("Frame")
	local v4 = {
		Name = "GuardToggle",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = color3,
		BackgroundTransparency = v and 0.1 or 0.45
	}
	local v5 = object:Create("UICorner")({
		CornerRadius = UDim.new(1)
	})
	local state2 = object:State(function(callback, object3)
		local v6 = callback(object2)
		local v7 = object3:Create("UIStroke")
		local v8 = {
			BorderOffset = UDim.new(0, -3),
			Thickness = 1.5,
			Color = 0,
			Transparency = 0
		}
		local color4

		if v then
			if v6 then
				color4 = color
			else
				color4 = object3:Animation(color, info, {
					From = color2
				})
			end
		else
			color4 = color2
		end

		v8.Color = color4
		v8.Transparency = not v and 0.8 or v6 and 0.2 or object3:Animation(0.15, info, {
			From = 0.55
		})
		return v7(v8)
	end)
	local v6 = object:Create("Frame")({
		Name = "IconPlate",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 6, 0.5, 0),
		Size = UDim2.fromScale(0.72, 0.72),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundColor3 = color3,
		BackgroundTransparency = 0.05,
		object:Create("UICorner")({
			CornerRadius = UDim.new(1)
		}),
		object:Create("UIStroke")({
			Color = color2,
			Thickness = 1,
			Transparency = 0.7
		}),
		object:Create("ImageLabel")({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.85, 0.85),
			BackgroundTransparency = 1,
			Image = item.Icon or "",
			ImageTransparency = v and 0 or 0.5
		})
	})
	local v7 = object:Create("Frame")
	local v8 = {
		Name = "Text",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0.16, 8, 0.5, 0),
		Size = UDim2.fromScale(0.6, 0.8),
		BackgroundTransparency = 1
	}
	local v9 = object:Create("TextLabel")({
		Size = UDim2.fromScale(1, 0.5),
		BackgroundTransparency = 1,
		Text = not v2 and "Refinement guard" or `Refinement guard x{p2}`,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.SourceSansBold,
		TextColor3 = color2,
		TextTransparency = v and 0 or 0.75
	})
	local v10 = object:Create("TextLabel")
	local v11 = {
		Position = UDim2.fromScale(0, 0.52),
		Size = UDim2.fromScale(1, 0.42),
		BackgroundTransparency = 1,
		Text = 0,
		TextScaled = true,
		TextXAlignment = 0,
		Font = 0,
		TextColor3 = 0,
		TextTransparency = 0
	}
	local text

	if v then
		text = object:Do(function(callback)
			if v2 then
				if callback(object2) then
					return (`Armed, burns {p2}, cannot fail`)
				end

				return (`Tap to arm, {p2} of {p} held`)
			elseif callback(object2) then
				return "Armed, no level loss on a fail, more greats"
			else
				return (`Tap to arm, {p} held`)
			end
		end)
	else
		text = not (p > 0) and "None held, sold by the Black Marketer" or `Needs {p2}, {p} held`
	end

	v11.Text = text
	v11.TextXAlignment = Enum.TextXAlignment.Left
	v11.Font = Enum.Font.SourceSansSemibold
	local textColor

	if v then
		textColor = object:Do(function(callback)
			if callback(object2) then
				return color
			end

			return color2
		end)
	else
		textColor = color2
	end

	v11.TextColor3 = textColor
	v11.TextTransparency = not v and 0.75 or object:Do(function(callback)
		if callback(object2) then
			return 0
		end

		return 0.5
	end)
	do local _values = table.pack(v9, v10(v11)); for _k = 1, _values.n do v8[_k] = _values[_k] end end
	do local _values = table.pack(v5, state2, v6, v7(v8), object:Create("TextButton")({
	Name = "Hit",
	ZIndex = 3,
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	MouseButton1Click = function()
		if not v or state.Busy:Get() == true then
			return
		end

		ScreenEffects.CircleClick()
		state.UseGuard = not state.UseGuard
		object2:Set(state.UseGuard)
	end
})); for _k = 1, _values.n do v4[_k] = _values[_k] end end
	return v3(v4)
end