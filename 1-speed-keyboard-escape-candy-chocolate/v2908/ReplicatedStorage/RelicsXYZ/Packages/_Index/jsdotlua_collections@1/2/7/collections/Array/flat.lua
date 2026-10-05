local __DEV__ = _G.__DEV__
local isArray = require(script.Parent:WaitForChild("isArray"))
require(script.Parent.Parent.Parent:WaitForChild("es7-types"))
local flat

flat = function(item, value: number?)
	if __DEV__ then
		if typeof(item) ~= "table" then
			error(string.format("Array.flat called on %s", (typeof(item))))
		end

		if value ~= nil and typeof(value) ~= "number" then
			error("depth is not a number or nil")
		end
	end

	local v = value or 1
	local result = {}

	for _, item2 in item do
		if isArray(item2) then
			if v > 1 then
				item2 = flat(item2, v - 1)
			end

			for _, v2 in item2 do
				table.insert(result, v2)
			end
		else
			table.insert(result, item2)
		end
	end

	return result
end

return flat