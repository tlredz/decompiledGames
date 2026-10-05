local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ambush = require(script.Ambush)
local Leg = require(script.Leg)
require(script.Parent.Types)
local faye = require(ReplicatedStorage.Packages.faye)
faye.Info(0.2)
return function(object, data, _: number)
	if data.Legs < 1 then
		return nil
	end

	local v = object:Create("NumberValue")({
		Value = object:Lerp(data.Progress, 0.12)
	})
	return object:Create("Frame")({
		v,
		Name = "CRoute",
		LayoutOrder = 3,
		Size = UDim2.fromScale(0.75, 0.075),
		BackgroundTransparency = 1,
		object:Create("ImageLabel")({
			Name = "Bg",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1.08, 1.8),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Image = "rbxassetid://96840853773997",
			ImageColor3 = Color3.new(),
			ImageTransparency = 0.855
		}),
		object:Iterate(data.Legs, function(p, _, p2, _)
			return Leg(p2, data, p, v)
		end),
		object:Iterate(data.Ambushes, function(_, p, p2, _)
			return Ambush(p2, data, p)
		end)
	})
end