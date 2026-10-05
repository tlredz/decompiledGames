local createVector = vector.create
local import = _G.import("romodel")
local basic = _G.import("viewImports"):get("basic")
local model = import.model(basic.TextLabel)

function model.init()
	return {
		Size = UDim2.new(1, 0, 1, 0),
		StrokeWidth = 3,
		TextColor3 = Color3.new(0.4, 0.8, 0.4)
	}
end

local model2 = import.model("BillboardGui")

function model2.init()
	return {
		StudsOffset = createVector(0, 2, 0),
		Size = UDim2.new(2.5, 0, 2.5, 0)
	}, {
		Amount = import.make(model)
	}
end

return {
	CashAmount = model2
}