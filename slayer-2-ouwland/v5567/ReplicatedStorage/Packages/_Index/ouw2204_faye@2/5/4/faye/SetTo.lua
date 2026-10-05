local ValueClasses = require(script.Parent.Misc.ValueClasses)
local FayeUtility = require(script.Parent.Misc.FayeUtility)
require(script.Parent.FayeTypes)
local name = script.Name
return function(p, p2)
	if p == nil or FayeUtility.tof(p) ~= "table" or p.__type == nil or ValueClasses[p.__type] == nil then
		warn((`Pass a valid value object - {debug.traceback()}`))
		return
	end

	local v = {
		Value = p,
		__type = name
	}

	if p2 ~= nil then
		FayeUtility.AddToThread(p2, v)
	end

	return v
end