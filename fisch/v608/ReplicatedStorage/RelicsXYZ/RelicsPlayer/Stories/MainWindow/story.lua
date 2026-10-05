local parent = script.Parent.Parent
local Story = require(parent.Story)
return Story.Create(script, {
	AnchorPoint = Vector2.one / 2,
	Position = UDim2.fromScale(0.5, 0.5),
	Scale = 2
})