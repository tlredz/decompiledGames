local import = _G.import("event")
local import2 = _G.import("global")
local import3 = _G.import("dictUtil")

local function getReplicatedState(p, p2)
	local v, v2, v3 = import2.get(p, p2)

	while not v do
		task.wait(0.1)
		v, v2, v3 = import2.get(p, p2)
	end

	return v, v2, v3
end

local function playerAdded(p)
	local replicatedState, v, v2 = getReplicatedState("playerSave", p)
	local replicatedState2, v3, v4 = getReplicatedState("playerSession", p)
	local playerSave = v2(v(p, replicatedState))
	local playerSession = v4(import3.fillDict(v3(p, playerSave), replicatedState2))
	_G.playerSave = playerSave
	_G.playerSession = playerSession
	import.fire("dataLoaded", playerSave, playerSession)
end

return {
	Priority = 3,
	Run = function()
		task.spawn(playerAdded, game.Players.LocalPlayer)
	end
}