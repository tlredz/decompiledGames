local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = ReplicatedStorage.Packages.faye
local module = require(faye)
local info = module.Info(0.1)
return function(object, p: number, p2, object2, object3, p3: number)
	local value = object:Value(0.75)
	local value2 = object:Value(0.95)
	local value3 = object:Value(0.95)
	local image = object:Value()
	local value5 = object:Value(UDim2.fromScale(0.75, 0.75))
	local value6 = object:Value(UDim2.fromScale(1, 1))
	local value7 = object:Value(UDim2.fromScale(1.1, 1.1))
	local value8 = object:Value(1)
	local v = {
		In = false,
		Index = p2.Name,
		Type = p3
	}
	local v2 = object3:Add({
		v,
		image,
		p2,
		value,
		value2,
		value3,
		value5,
		value6,
		value7,
		value8
	}):Call():SetId((`{p3}-{p2.Name}`))
	return object:Create("Frame")({
		Size = UDim2.fromScale(1, 1),
		Instance.new("UIAspectRatioConstraint"),
		BackgroundTransparency = 1,
		Name = `{p}-{p2.Name}`,
		object:Create("TextButton")({
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			MouseEnter = function()
				v.In = true
				v2:Call()
			end,
			MouseLeave = function()
				v.In = false
				v2:Call()
			end,
			MouseButton1Up = function()
				object2:Set(p2.Name)
			end
		}),
		object:Create("Frame")({
			Name = "Holder",
			Size = UDim2.fromScale(0.8, 0.8),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			object:Create("Frame")({
				Name = "Bg",
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = object:Animation(value6, info),
				BackgroundTransparency = object:Animation(value3, info),
				object:Create("UICorner")({
					CornerRadius = UDim.new(0.15, 0)
				})
			}),
			object:Create("Frame")({
				Name = "StrokeHolder",
				Size = object:Animation(value7, info),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				object:Create("UICorner")({
					CornerRadius = UDim.new(0.15, 0)
				}),
				object:Create("UIStroke")({
					Color = Color3.new(1, 1, 1),
					Transparency = object:Animation(value2, info),
					Thickness = object:Animation(value8, info)
				})
			}),
			object:Create("ImageLabel")({
				Name = "Img",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = object:Animation(value5, info),
				Position = UDim2.fromScale(0.5, 0.5),
				ImageTransparency = object:Animation(value, info),
				BackgroundTransparency = 1,
				Image = image
			})
		})
	})
end