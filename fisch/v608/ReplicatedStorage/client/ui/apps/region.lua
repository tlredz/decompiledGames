local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vide = require(ReplicatedStorage.packages.vide)
local state = require(script.Parent.Parent.state)
return function()
	return vide.create("TextLabel")({
		Text = state.region,
		Size = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 0,
		Position = UDim2.fromScale(0.5, 0.5)
	})
end