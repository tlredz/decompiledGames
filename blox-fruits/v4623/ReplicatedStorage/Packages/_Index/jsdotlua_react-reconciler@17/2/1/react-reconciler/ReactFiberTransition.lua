local shared = require(script.Parent.Parent:WaitForChild("shared"))
local reactCurrentBatchConfig = shared.ReactSharedInternals.ReactCurrentBatchConfig
return {
	NoTransition = 0,
	requestCurrentTransition = function()
		return reactCurrentBatchConfig.transition
	end
}