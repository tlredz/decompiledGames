local createVector = vector.create
local import = _G.import("romodel")
local import2 = _G.import("iconData")
local import3 = _G.import("viewImports")
local basic = import3:get("basic")
local react = import3:get("react")
local model = import.model("BillboardGui")

function model.init(p)
	return {
		Name = "StreakBillboard",
		MaxDistance = 100,
		Size = UDim2.new(1.5, 0, 1.5, 0),
		StudsOffset = createVector(0, 2.75, 0),
		Enabled = false
	}, {
		Icon = import.make(basic.ImageLabel, {
			Name = "Icon",
			BackgroundTransparency = 1,
			Location = "Center",
			Size = UDim2.fromScale(1, 1),
			Image = import2.Streak,
			ScaleType = Enum.ScaleType.Fit
		}),
		TextLabel = import.make(import.wrap(basic.TextLabel, react.LinkedText), {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.6, 0),
			Size = UDim2.new(0.65, 0, 0.65, 0),
			StrokeWidth = 2,
			KeyChains = { "Statistics.Streak" },
			Player = p.Player,
			TextSavedChanged = function(p2, p3)
				p2.Parent.Enabled = p3.Statistics.Streak > 0
				return p3.Statistics.Streak
			end
		})
	}
end

return {
	StreakBillboard = model
}