local _ = game.Players.LocalPlayer
local import = _G.import("romodel")
local import2 = _G.import("event")
local import3 = _G.import("viewImports")
local basic = import3:get("basic")
local menu = import3:get("menu")
local model = import.model(basic.EmptyElement, basic.ConstrainedElement)

function model.init()
	return {
		Position = UDim2.new(0.5, 0, 0.87, 0),
		Size = UDim2.new(0.2, 0, 0.65, 0),
		AnchorPoint = Vector2.new(0.5, 1),
		AspectRatio = 4.3
	}, {
		ReturnButton = import.make(menu.Button, {
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0,
			Text = "Return To Game",
			MouseButton1Down = function(_)
				import2.fire("teleport", "Normal")
			end
		}, {})
	}
end

return {
	MiddleBottomPanel = model
}