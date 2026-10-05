local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vide = require(ReplicatedStorage.packages.vide)
require(script.Parent.Parent.state)
require("./gui")
return function(_)
	return vide.create("ImageLabel")({
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1.02, 1.15),
		Image = "rbxassetid://16803461543",
		SliceCenter = Rect.new(12, 12, 88, 88),
		SliceScale = 0.5,
		ScaleType = Enum.ScaleType.Slice,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ImageTransparency = 0.6
	})
end