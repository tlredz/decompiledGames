local import = _G.import("romodel")
local import2 = _G.import("event")
local import3 = _G.import("signalUtil")
local itemBillboard = _G.import("viewImports"):get("itemBillboard").ItemBillboard

local function displayChair(p)
	local name = p.Name
	import.mount(import.make(itemBillboard, {
		ItemId = name
	}), p)
end

return {
	Priority = 1,
	Run = function()
		import2.connect("dataLoaded", function()
			import3.onTag("ChairDisplay", displayChair)
		end)
	end
}