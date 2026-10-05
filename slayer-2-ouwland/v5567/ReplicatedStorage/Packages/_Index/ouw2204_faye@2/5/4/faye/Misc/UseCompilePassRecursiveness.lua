local FayeUtility = require(script.Parent.FayeUtility)
require(script.Parent.Parent.FayeTypes)
return function(callback, p, p2, p3, p4)
	if p == nil and p2 == nil then
		return
	end

	local v = nil
	local v2

	if p2 == nil and p ~= nil then
		v2 = (FayeUtility.tof(p) ~= FayeUtility.tabletxt or p.__type ~= nil or not p) and { p } or p
	else
		v2 = p ~= nil and p2 ~= nil and {
			[p] = p2
		} or v
	end

	if v2 ~= nil then
		callback(p3, v2, p4 or p3.CleanThread or p3.Thread)
	end
end