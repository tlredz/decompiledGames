local collections = require(script.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("@jsdotlua"):WaitForChild("collections"))
local array = collections.Array

local function unpack(list, value: string?)
	if value == nil then
		value = nil
	end

	if list.n >= 3 then
		return { table.unpack(list, 1, list.n) }
	end

	if type(list[1]) == "table" and type((next(list[1]))) == "string" and value ~= nil and value ~= "" then
		return array.map(array.filter(string.split(value, ""), function(p)
			return list[1][p] ~= nil
		end), function(p)
			return list[1][p]
		end)
	end

	return list[1]
end

return unpack