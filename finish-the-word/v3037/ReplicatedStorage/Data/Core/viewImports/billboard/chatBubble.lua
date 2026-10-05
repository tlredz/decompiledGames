local createVector = vector.create
local import = _G.import("romodel")
_G.import("itemModules")
local basic = _G.import("viewImports"):get("basic")
local model = import.model("BillboardGui")

function model.init(_)
	return {
		Name = "ChatBubble",
		StudsOffset = createVector(0, 5, 0),
		Size = UDim2.new(3, 0, 3, 0)
	}, {
		Frame = import.make(basic.Corner, {
			CornerRadius = UDim.new(0.15, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			Size = UDim2.new(1, 0, 0.5, 0),
			Position = UDim2.new(0.5, 0, 0.3, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center
		}, {
			TextLabel = import.make(basic.TextLabel, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				LayoutOrder = 2,
				Size = UDim2.new(0.75, 0, 0.6, 0),
				TextColor3 = Color3.new(0, 0, 0),
				Text = "..."
			})
		}),
		Triangle = import.make("ImageLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0.74, 0),
			Size = UDim2.new(0.3, 0, 0.2, 0),
			Rotation = 180,
			Image = "rbxassetid://121472607650183"
		})
	}
end

function model.setText(p, value)
	p.Frame.Size = UDim2.new(#value * 0.16 + 0.3, 0, 0.5, 0)
	p.Frame.TextLabel.Text = string.upper(value)
end

return {
	ChatBubble = model
}