local __DEV__ = _G.__DEV__
local isArray = require(script.Parent:WaitForChild("isArray"))
require(script.Parent.Parent.Parent:WaitForChild("es7-types"))

local function concat(list, ...)
	local v = 0
	local clone, v2

	if isArray(list) then
		clone = table.clone(list)
		v2 = #list
	else
		v2 = v + 1
		clone = {
			[v2] = list
		}
	end

	for i = 1, select("#", ...) do
		local v3 = select(i, ...)
		local typeName = typeof(v3)

		if v3 == nil then
			continue
		end

		if typeName == "table" then
			if __DEV__ and not isArray(v3) then
				error([[
Array.concat(...) only works with array-like tables but it received an object-like table.
You can avoid this error by wrapping the object-like table into an array. Example: `concat({1, 2}, {a = true})` should be `concat({1, 2}, { {a = true} }`]])
			end

			for i2 = 1, #v3 do
				v2 += 1
				clone[v2] = v3[i2]
			end
		else
			v2 += 1
			clone[v2] = v3
		end
	end

	return clone
end

return concat