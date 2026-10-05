local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local info = faye.Info(0.2)
return function(object, p, value: number, callback, p2: number?)
	local properties = p == nil and {} or p
	properties.Position = properties.Position or UDim2.fromScale(0.025, 0.5)
	local anchorPoint = properties.AnchorPoint or Vector2.new(0, 0.5)
	properties.AnchorPoint = nil
	local value2 = object:Value(0.25)

	local function press()
		ScreenEffects.CircleClick()

		if callback ~= nil then
			callback()
		end
	end

	local v2 = object:Create("ImageButton")
	local v3 = {
		Size = UDim2.fromScale(0.2, 1),
		Properties = properties,
		AnchorPoint = anchorPoint,
		object:Create("UIAspectRatioConstraint")({}),
		BackgroundTransparency = 1,
		Image = "rbxassetid://10825169477",
		Rotation = value or -90,
		ImageTransparency = object:Animation(value2, info),
		MouseEnter = function()
			value2:Set(0)
		end,
		MouseLeave = function()
			value2:Reset()
		end,
		MouseButton1Click = press
	}
	local v4 = object:Create("UIGradient")({
		Rotation = 180,
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.5) })
	})
	local v5

	if p2 ~= nil then
		v5 = object:Create("TextButton")({
			Name = "HitPad",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(p2, p2),
			BackgroundTransparency = 1,
			Text = "",
			MouseEnter = function()
				value2:Set(0)
			end,
			MouseLeave = function()
				value2:Reset()
			end,
			MouseButton1Click = press
		}) or nil
	end

	v3[2], v3[3] = v4, v5
	return v2(v3)
end