local __DEV__ = _G.__DEV__
local isArray = require(script.Parent:WaitForChild("isArray"))
require(script.Parent.Parent.Parent:WaitForChild("es7-types"))
return function(list, ...)
	if __DEV__ and not isArray(list) then
		error(string.format("Array.unshift called on non-array %s", (typeof(list))))
	end

	local v = select("#", ...)

	if v > 0 then
		for i = v, 1, -1 do
			table.insert(list, 1, (select(i, ...)))
		end
	end

	return #list
end