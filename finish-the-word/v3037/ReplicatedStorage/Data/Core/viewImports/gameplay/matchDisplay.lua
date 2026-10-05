local createVector = vector.create
local import = _G.import("romodel")
_G.import("mathUtil")
_G.import("stringUtil")
local import2 = _G.import("iconData")
local import3 = _G.import("viewImports")
local basic = import3:get("basic")
local gameplay = import3:get("gameplay")
local model = import.model(basic.TextLabel)

function model.init()
	return {
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0.2, 0),
		Scale = true,
		StrokeWidth = 3,
		Text = "Animals"
	}
end

local model_2 = import.model(basic.EmptyList)

function model_2.init()
	return {
		LayoutOrder = 0,
		Size = UDim2.new(1, 0, 0.1, 0),
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0.015, 0),
		BackgroundTransparency = 1
	}, {
		Icon = import.make(basic.ImageLabel, {
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 1, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Image = import2.Flag
		}),
		Label = import.make(basic.TextLabel, {
			LayoutOrder = 2,
			Size = UDim2.new(1.5, 0, 1, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Text = "1",
			StrokeWidth = 2,
			TextXAlignment = Enum.TextXAlignment.Left
		})
	}
end

local model2 = import.model("BillboardGui", basic.List)

function model2.init()
	return {
		Name = "MatchDisplay",
		StudsOffset = createVector(0, 4, 0),
		Size = UDim2.new(30, 0, 10, 0),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0.1, 0),
		MaxDistance = 60
	}, {
		Category = import.make(model),
		AnswerInput = import.make(gameplay.AnswerInput, {
			Size = UDim2.new(1, 0, 0.15, 0)
		})
	}
end

function model2.prespawn(p)
	p.Instance:AddTag("GameBillboard")
end

return {
	MatchDisplay = model2
}