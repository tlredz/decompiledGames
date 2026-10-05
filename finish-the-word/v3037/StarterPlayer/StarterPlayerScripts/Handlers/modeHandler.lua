local import = _G.import("event")
local import2 = _G.import("modelUtil")
local StarterGui = game:GetService("StarterGui")

local function dataLoaded()
	import2.getAttribute(workspace, "Mode"):andThen(function(p)
		if p ~= "RANKED" then
			return
		end

		StarterGui:SetCore("ResetButtonCallback", false)
	end)
end

return {
	Priority = 1,
	Run = function()
		import.connect("dataLoaded", dataLoaded)
	end
}