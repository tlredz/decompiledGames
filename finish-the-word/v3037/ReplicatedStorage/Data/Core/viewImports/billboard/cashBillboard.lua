local createVector = vector.create
local import = _G.import("romodel")
local import2 = _G.import("viewImports")
local basic = import2:get("basic")
local react = import2:get("react")
local import3 = _G.import("mathUtil")
local model = import.model("BillboardGui")

function model.init(p)
	return {
		Name = "CashBillboard",
		StudsOffset = createVector(0, 0, 2),
		Size = UDim2.new(6, 0, 1.3, 0),
		MaxDistance = 40
	}, {
		CashLabel = import.make(import.wrap(basic.TextLabel, react.LinkedText), {
			Size = UDim2.new(1, 0, 1, 0),
			TextColor3 = Color3.fromRGB(90, 255, 120),
			Font = Enum.Font.FredokaOne,
			StrokeWidth = 4,
			Player = p.Player,
			KeyChains = { "Statistics.Cash" },
			TextSavedChanged = function(_, p2)
				return "$" .. import3.formatNumber(p2.Statistics.Cash or 0)
			end
		})
	}
end

function model.prespawn(p)
	p.Instance:AddTag("CashBillboard")
end

return {
	CashBillboard = model
}