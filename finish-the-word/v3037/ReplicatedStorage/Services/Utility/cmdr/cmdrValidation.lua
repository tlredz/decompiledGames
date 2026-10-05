local Players = game:GetService("Players")

-- equivalent calls inferred from this helper; original call sites unknown
local function asArray(args)
	return type(args) == "table" and args or {}
end

local CmdrValidation = {
	validateArgCount = function(p, p2)
		local array = asArray(p.Args) -- equivalent call inferred; original call site unknown
		local v2 = array[#array]
		local variadic = v2 and v2.Variadic
		local count = 0

		for _, v3 in ipairs(array) do
			if not v3.Optional then
				count += 1
			end
		end

		local count2 = #asArray(p2)

		if count2 < count then
			return false, string.format("Not enough args (%d/%d required)", count2, count)
		end

		if variadic or not (#array < count2) then
			return true
		end

		return false, string.format("Too many args (%d/%d max)", count2, #array)
	end,
	coerceArg = function(_, p, p2)
		if p == "player" then
			local child = Players:FindFirstChild((tostring(p2)))

			if child then
				return true, child
			end

			return false, string.format("Player not found: %s", (tostring(p2)))
		elseif p == "int" then
			local v = tonumber(p2)

			if not v then
				return false, string.format("Expected int, got: %s", (tostring(p2)))
			end

			local v2 = math.floor(v)

			if v2 == 0 then
				return false, "Amount cant be 0"
			end

			return true, v2
		else
			if p ~= "bool" then
				return true, p2
			end

			if p2 == "true" or p2 == "false" or p2 == true or p2 == false then
				return true, p2 == "true"
			end

			return false, string.format("Expected bool, got: %s", (tostring(p2)))
		end
	end
}

function CmdrValidation.coerceArgs(p, p2, list)
	local array = asArray(p2.Args) -- equivalent call inferred; original call site unknown
	local result = {}

	for i, v3 in ipairs(array) do
		if v3.Variadic then
			local v4 = {}

			for i2 = i, #list do
				local coerceArg, v5 = CmdrValidation.coerceArg(p, v3.Type, list[i2])

				if not coerceArg then
					return false, v5
				end

				v4[#v4 + 1] = v5
			end

			result[v3.Name] = v4
			break
		else
			local default = list[i]

			if default == nil and v3.Default ~= nil then
				default = v3.Default
			end

			if default == nil then
				result[v3.Name] = nil
			else
				local coerceArg, v4 = CmdrValidation.coerceArg(p, v3.Type, default)

				if not coerceArg then
					return false, v4
				end

				result[v3.Name] = v4
			end
		end
	end

	return true, result
end

return CmdrValidation