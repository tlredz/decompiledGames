local RunService = game:GetService("RunService")
assert(RunService:IsClient())
local ClientSignals = {}
local v = {}
local Signal = require(game.ReplicatedStorage.Modules.Util.Signal)

function _clientSignal(p: string)
	assert(p, "No name provided for signal")

	if v[p] then
		return v[p]
	end

	local v2 = Signal.new()
	v[p] = v2
	return v2
end

function ClientSignals.InventoryItemUpdated()
	return _clientSignal("InventoryItemUpdated")
end

return ClientSignals