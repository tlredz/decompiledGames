local FayeUtility = require(script.Parent.Misc.FayeUtility)
require(script.Parent.FayeTypes)
return function(p, list, callback, p2)
	if p == nil or list == nil or callback == nil then
		return
	end

	if FayeUtility.tof(list) ~= "table" then
		FayeUtility.Connect(p[list], function(...)
			callback(list, ...)
		end, p2)
		return
	end

	for _, v in ipairs(list) do
		local v2 = v
		FayeUtility.Connect(p[v], function(...)
			callback(v2, ...)
		end, p2)
	end
end