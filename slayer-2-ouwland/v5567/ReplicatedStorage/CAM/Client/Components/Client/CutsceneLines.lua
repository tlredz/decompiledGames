local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.3, Enum.EasingStyle.Sine)
return function(parent)
	local v = faye.new()
	v:Create("Frame")({
		Parent = parent,
		Size = UDim2.fromScale(1, 0.08),
		BackgroundColor3 = Color3.new(),
		Position = v:Animation(UDim2.fromScale(0, 0), info, {
			From = UDim2.fromScale(0, -0.08)
		}),
		OnClean = function(object, p2)
			object:Configure(p2)({
				Position = object:Animation(UDim2.fromScale(0, -0.08), info)
			})
		end
	})
	v:Create("Frame")({
		BackgroundColor3 = Color3.new(),
		Parent = parent,
		Size = UDim2.fromScale(1, 0.08),
		AnchorPoint = Vector2.new(0, 1),
		Position = v:Animation(UDim2.fromScale(0, 1), info, {
			From = UDim2.fromScale(0, 1.08)
		}),
		OnClean = function(object, p2)
			object:Configure(p2)({
				Position = object:Animation(UDim2.fromScale(0, 1.08), info)
			})
		end
	})
	return function()
		v:Destroy()
	end, info.Time
end