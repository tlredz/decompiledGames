local parent = script.Parent.Parent
local parent2 = parent.Parent
local Story = require(parent.Story)
local components = parent.Components
local VirtualGrid = require(components.VirtualGrid)
local shared = parent2.Shared
local React = require(shared.React)

local function CustomStory(props)
	local children = {}

	for i = 1, props.Count do
		children[i] = React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.fromHSV(i / props.Count, 1, 1),
			LayoutOrder = i
		})
	end

	return React.createElement(VirtualGrid, {
		CellPadding = props.CellPadding,
		CellSize = props.CellSize,
		LazySort = true
	}, children)
end

return Story.Custom(CustomStory, {
	Count = 1000,
	CellSize = UDim2.new(0, 100, 0, 100),
	CellPadding = UDim2.new(0, 10, 0, 10)
})