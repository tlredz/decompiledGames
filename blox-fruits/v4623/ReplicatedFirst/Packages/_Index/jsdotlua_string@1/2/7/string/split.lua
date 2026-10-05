local findOr = require(script.Parent:WaitForChild("findOr"))
local slice = require(script.Parent:WaitForChild("slice"))
require(script.Parent.Parent:WaitForChild("es7-types"))
local number = require(script.Parent.Parent:WaitForChild("number"))
local MAX_SAFE_INTEGER = number.MAX_SAFE_INTEGER

local function split(value: string, value2, p: number?)
	if value2 == nil then
		return { value }
	end

	if p == 0 then
		return {}
	end

	if p == nil or p < 0 then
		p = MAX_SAFE_INTEGER
	end

	if typeof(value2) == "string" then
		if value2 == "" then
			local result = {}

			for k in value:gmatch(".") do
				table.insert(result, k)
			end

			return result
		else
			value2 = { value2 }
		end
	end

	local v, v2 = utf8.len(value)
	assert(v ~= nil, ("string `%s` has an invalid byte at position %s"):format(value, (tostring(v2))))
	local v3 = 1
	local result = {}
	local v4 = nil

	while true do
		local v5 = findOr(value, value2, v3)

		if v5 == nil then
			table.insert(result, slice(value, v3, nil))
		else
			table.insert(result, slice(value, v3, v5.index))
			local v6 = utf8.len(v5.match)
			v3 = v5.index + v6
		end

		if v5 ~= nil then
			v4 = v5
		end

		if not (v5 == nil or v < v3 or p <= #result) then
			continue
		end

		if v4 == nil then
			return result
		end

		local v6, v7 = utf8.len(v4.match)
		assert(v6 ~= nil, ("string `%s` has an invalid byte at position %s"):format(v4.match, (tostring(v7))))

		if v4.index + v6 == v + 1 then
			table.insert(result, "")
		end

		return result
	end
end

return split