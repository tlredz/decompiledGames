local createVector = vector.create
local import = _G.import("romodel")
local basic = _G.import("viewImports"):get("basic")
local model = import.model("BillboardGui", basic.List)

function model.init(_)
	return {
		Size = UDim2.new(17.2, 0, 2.5, 0),
		StudsOffset = createVector(0, 2, 0),
		AlwaysOnTop = true,
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0.1, 0)
	}, {
		MainLabel = import.make(import.wrap(basic.TextLabel, basic.Gradient), {
			LayoutOrder = 1,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 0.6, 0),
			StrokeWidth = 2,
			Text = "Ranked",
			GradientRotation = 90,
			GradientColor = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(47, 101, 249)),
				ColorSequenceKeypoint.new(0.185, Color3.fromRGB(255, 211, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(221, 194, 66))
			})
		}),
		Subtext = import.make(basic.TextLabel, {
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0.3, 0),
			StrokeWidth = 1,
			RichText = true,
			Text = "Earn <font color=\"rgb(230,200,60)\">GOLD</font> and climb the <font color=\"rgb(60,150,230)\">RANKS</font>!"
		})
	}
end

return {
	RankedStation = model
}