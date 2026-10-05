local FayeUtility = require(script.Parent.FayeUtility)
require(script.Parent.Parent.FayeTypes)
local Compile = require(script.Parent.Parent.Compile)
return function(p, p2, p3, p4)
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
		Compile(p3, v2, p4 or p3.CleanThread or p3.Thread)
	end
end