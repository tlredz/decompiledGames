local FayeUtility = require(script.Parent.Misc.FayeUtility)
require(script.Parent.FayeTypes)
local name = script.Name
return function(func, delayTime: number?, p2)
	local v = {
		func = func,
		DelayTime = delayTime,
		__type = name
	}

	if p2 ~= nil then
		FayeUtility.AddToThread(p2, v)
	end

	return v
end