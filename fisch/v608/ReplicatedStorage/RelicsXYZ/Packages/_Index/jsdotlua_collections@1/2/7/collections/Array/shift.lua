local __DEV__ = _G.__DEV__
local isArray = require(script.Parent:WaitForChild("isArray"))
require(script.Parent.Parent.Parent:WaitForChild("es7-types"))
return function(list)
	if __DEV__ and not isArray(list) then
		error(string.format("Array.shift called on non-array %s", (typeof(list))))
	end

	if #list > 0 then
		return table.remove(list, 1)
	end

	return nil
end