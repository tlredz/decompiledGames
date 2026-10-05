local import = _G.import("event")
local import2 = _G.import("modelUtil")
local localPlayer = game.Players.LocalPlayer

local function dataLoaded()
	if import2.getAttribute(workspace, "Mode"):await() ~= "RANKED" then
		return
	end

	while localPlayer:GetAttribute("DataLoaded") ~= true do
		import.remoteFire("clientDataLoadedReady")
		task.wait(0.5)
	end
end

return {
	Priority = 1,
	Run = function()
		import.connect("dataLoaded", dataLoaded)
	end
}