local signal = script.Parent.Signal
require(script.Parent.FayeTypes)
local FayeUtility = require(script.Parent.Misc.FayeUtility)
local Runner = require(signal.Runner)
local SignalMetatable = require(signal.SignalMetatable)
return function(p, callback, p2)
	if callback == nil then
		return
	end

	local v = {
		__type = "Signal",
		IsState = true
	}
	Runner(v, p, callback)
	setmetatable(v, SignalMetatable)

	if p2 ~= nil then
		FayeUtility.AddToThread(p2, v)
	end

	return v
end