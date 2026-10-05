require(script.Parent.FayeTypes)
local FayeUtility = require(script.Parent.Misc.FayeUtility)
local name = script.Name
return function(toCompile, time: number, init, p4)
	if time == nil or toCompile == nil then
		warn((`Time or properties is missing - {debug.traceback()}`))
		return
	end

	local v = {
		Time = time,
		ToCompile = toCompile,
		Init = init,
		__type = name
	}

	if p4 ~= nil then
		FayeUtility.AddToThread(p4, v)
	end

	return v
end