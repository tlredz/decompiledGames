local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
return function(parent, object, p2, p3, point: Vector2, point2: Vector2, _: number, imageTransparency)
	local position = p2.Position
	local position2 = p3.Position
	local uDim = UDim2.fromScale((position.X.Scale + position2.X.Scale) / 2, (position.Y.Scale + position2.Y.Scale) / 2)
	local v = point2.Y - point.Y
	local v2 = point2.X - point.X
	local rotation = math.deg((math.atan2(v, v2)))
	local v4 = ((v2 ^ 2 + v ^ 2) ^ 0.5 - p3.AbsoluteSize.X) / parent.AbsoluteSize.X
	object:Create("Frame")({
		Parent = parent,
		Position = uDim,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Rotation = rotation,
		Size = UDim2.new(v4, 0, 0, 70),
		BackgroundTransparency = 1,
		object:Create("ImageLabel")({
			BackgroundTransparency = 1,
			ImageTransparency = imageTransparency,
			Size = UDim2.fromScale(1, 1),
			Image = "rbxassetid://123354508377913",
			ScaleType = Enum.ScaleType.Tile,
			TileSize = UDim2.new(0, 100, 1, 0),
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.3, 0),
					NumberSequenceKeypoint.new(0.7, 0),
					NumberSequenceKeypoint.new(1, 1)
				})
			})
		})
	})
end