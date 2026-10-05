local SharedSignals = {}
local v = {}
local Signal = require(game.ReplicatedStorage.Modules.Util.Signal)

function _sharedSignal(p: string)
	assert(p, "No name provided for signal")

	if v[p] then
		return v[p]
	end

	local v2 = Signal.new()
	v[p] = v2
	return v2
end

function SharedSignals.TransformationChanged()
	return _sharedSignal("TransformationChanged")
end

return SharedSignals