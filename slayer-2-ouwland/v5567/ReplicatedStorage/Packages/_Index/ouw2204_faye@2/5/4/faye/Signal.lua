require(script.Parent.FayeTypes)
local name = script.Name
local FayeUtility = require(script.Parent.Misc.FayeUtility)
local Runner = require(script.Runner)
local SignalMetatable = require(script.SignalMetatable)
return function(p, callback, p2)
	if callback == nil then
		return
	end

	local v = {
		__type = name
	}
	Runner(v, p, callback)
	setmetatable(v, SignalMetatable)

	if p2 ~= nil then
		FayeUtility.AddToThread(p2, v)
	end

	return v
end