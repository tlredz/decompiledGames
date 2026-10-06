local parent = script.Parent.Parent
require(parent.Types)
local castToState = require(parent.State.castToState)
local evaluate = require(parent.Graph.evaluate)

local function peek(p)
	local v = castToState(p)

	if v == nil then
		return p
	end

	evaluate(v, false)
	return v._EXTREMELY_DANGEROUS_usedAsValue
end

return peek