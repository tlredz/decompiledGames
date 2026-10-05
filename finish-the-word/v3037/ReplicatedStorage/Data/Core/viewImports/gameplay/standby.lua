local createVector = vector.create
local import = _G.import("romodel")
local basic = _G.import("viewImports"):get("basic")
local model = import.model(basic.TextLabel)

function model.init()
	return {
		Size = UDim2.new(1, 0, 1, 0),
		StrokeWidth = 3
	}
end

local model2 = import.model(basic.TextLabel)

function model2.init()
	return {
		Location = "Center",
		Size = UDim2.new(3, 0, 1, 0),
		StrokeWidth = 3,
		Visible = false
	}
end

local model3 = import.model("BillboardGui")

function model3.init()
	return {
		StudsOffset = createVector(0, 4, 0),
		Size = UDim2.new(3, 0, 3, 0),
		MaxDistance = 50
	}, {
		PlayerCount = import.make(model),
		Starting = import.make(model2)
	}
end

return {
	Standby = model3
}