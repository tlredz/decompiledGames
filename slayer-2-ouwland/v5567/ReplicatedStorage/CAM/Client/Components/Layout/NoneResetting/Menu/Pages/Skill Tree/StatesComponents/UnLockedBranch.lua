local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
require(script.Parent.Parent.TreeConfigurations)
local info = faye.Info(0.2)
return function(_, object, p, p2, p3, _, p4)
	return object:Create("Frame")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		object:Create("ImageLabel")({
			Name = "Outer",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.8, 0.8),
			BackgroundTransparency = 1,
			Image = "rbxassetid://119354987209145",
			ImageColor3 = object:Animation(p2, info),
			object:Create("UIGradient")({
				Rotation = -90,
				Color = ColorSequence.new(Color3.new(0.5, 0.5, 0.5), Color3.new(1, 1, 1)),
				function(p5)
					object:Reactive(function(callback)
						p5.Enabled = not callback(p4)
					end)
				end
			})
		}),
		object:Create("ImageLabel")({
			Name = "Inner",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.8, 0.8),
			BackgroundTransparency = 1,
			Image = "rbxassetid://103795352162830",
			ImageColor3 = object:Animation(p3, info)
		}),
		object:Create("ImageLabel")({
			Name = "Border",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.8, 0.8),
			BackgroundTransparency = 1,
			Image = "rbxassetid://112815471033267",
			ImageColor3 = Color3.new(),
			function(p5)
				object:Reactive(function(callback)
					p5.Visible = not callback(p4)
				end)
			end
		}),
		object:Create("ImageLabel")({
			Name = "Inner",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.8, 0.8),
			BackgroundTransparency = 1,
			Image = "rbxassetid://103795352162830",
			ZIndex = 2,
			ImageColor3 = Color3.new(),
			object:Create("UIGradient")({
				Rotation = -90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.65),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			object:Create("ImageLabel")({
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.85, 0.85),
				ZIndex = 2,
				BackgroundTransparency = 1,
				Image = "rbxassetid://139096673186074",
				object:Create("UIGradient")({
					Rotation = 45,
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.15),
						NumberSequenceKeypoint.new(1, 1)
					})
				})
			})
		}),
		object:Create("ImageLabel")({
			BackgroundTransparency = 1,
			Image = "rbxassetid://96473929850143",
			ZIndex = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.95, 0.95),
			ImageColor3 = Color3.new(0.721569, 0.615686, 0.45098),
			ImageTransparency = 0.5
		}),
		object:Create("ImageLabel")({
			Name = "Img",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = p.Icon,
			ZIndex = 3,
			ImageColor3 = Color3.new(1, 1, 1)
		})
	})
end