local import = _G.import("event")
local localPlayer = game.Players.LocalPlayer

local function showCmdr()
	if not localPlayer:GetAttribute("CanOpenCmdr") or localPlayer:GetAttribute("InGame") then
		return
	end

	import.fire("openMenu", "Cmdr")
end

return {
	Priority = 1,
	Run = function()
		import.connect("showCmdr", showCmdr)
	end
}