local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.3)
local color = Color3.new(1, 1, 1)

local function half(object, name: string, p2: number, p3: number, fn, p4, thickness, color2, p7: number)
	return object:Create("Frame")({
		Name = name,
		AnchorPoint = Vector2.new(p2, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(2, 2),
		ClipsDescendants = true,
		object:Create("Frame")({
			Name = "Content",
			Position = UDim2.fromScale(p3, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			object:Create("UIStroke")({
				Thickness = thickness,
				Color = color2,
				OnClean = {
					Transparency = object:Animation(1, info)
				},
				object:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, p7),
						NumberSequenceKeypoint.new(0.495, p7),
						NumberSequenceKeypoint.new(0.505, 1),
						NumberSequenceKeypoint.new(1, 1)
					}),
					Rotation = object:Do(function(callback)
						return fn(callback(p4))
					end)
				})
			})
		})
	})
end

return function(object, p, udim: UDim2, udim2: UDim2, p2, p3, p4: number?)
	local thickness = p2 == nil and 2 or p2

	if p3 == nil then
		p3 = color
	end

	local v2 = p4 == nil and 0.4 or p4
	return object:Create("Frame")({
		Name = "Ring",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = udim,
		Size = udim2,
		half(object, "Left", 1, 1, function(p5)
			return (math.clamp(180 - p5, 0, 180))
		end, p, thickness, p3, v2),
		half(object, "Right", 0, 0, function(p5)
			return -math.clamp(p5 - 180, 0, 180)
		end, p, thickness, p3, v2)
	})
end