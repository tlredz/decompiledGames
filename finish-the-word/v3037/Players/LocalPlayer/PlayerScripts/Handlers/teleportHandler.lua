local _ = game.Players.LocalPlayer.PlayerGui
_G.import("romodel")
local import = _G.import("event")
_G.import("viewImports")

local function teleport(p)
	print("Teleporting")
	local remoteFire, v = import.remoteFire("teleport", p)
	print("Teleport Succeeded:", remoteFire, v)

	if remoteFire then
	end
end

return {
	Priority = 1,
	Run = function()
		import.connect("teleport", teleport, {
			Blocking = true
		})
	end
}