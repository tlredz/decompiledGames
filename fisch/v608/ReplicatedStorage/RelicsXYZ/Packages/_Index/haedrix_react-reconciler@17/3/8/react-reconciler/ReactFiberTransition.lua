local parent = script.Parent.Parent
local Shared = require(parent.Shared)
local reactCurrentBatchConfig = Shared.ReactSharedInternals.ReactCurrentBatchConfig
return {
	NoTransition = 0,
	requestCurrentTransition = function()
		return reactCurrentBatchConfig.transition
	end
}