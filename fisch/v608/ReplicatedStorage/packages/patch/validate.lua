local v = {
	string = true,
	number = true
}
local v2 = {
	["function"] = true,
	thread = true
}

local function isTableUnsafe(list)
	local v3 = nil
	local count = 0

	for k in next, list, nil do
		local typeName = type(k)

		if v3 or not v[typeName] then
			if v3 ~= typeName then
				return true
			end
		else
			v3 = typeName
		end

		count += 1
	end

	return #list < count and v3 == "number"
end

local function validate(p, p2)
	local typeName = type(p2)
	local typeName2 = type(p)

	if v[typeName] then
		if v2[typeName2] then
			error((`Invalid value type '{typeName2}' at key '{p2}'`))
		elseif typeName2 == "table" then
			if getmetatable(p) == nil then
				if isTableUnsafe(p) then
					error(`Cannot sync tables unsupported by remote events! The value has the key '{p2}'.\n\n` .. [[
This can be for the following reasons:
1. The object is an array with non-sequential keys
2. The object is a dictionary with mixed key types (e.g. string and number)

Read more: https://create.roblox.com/docs/scripting/events/remote#argument-limitations]])
				end
			else
				error((`Cannot sync tables with metatables! Got {p} at key '{p2}'`))
			end
		end
	else
		error((`Invalid key type '{typeName}' at key '{p2}'`))
	end

	if typeName == "number" then
		if p2 == 1e999 or p2 == -1e999 then
			error("Cannot sync infinity as key")
		elseif p2 ~= math.floor(p2) then
			error("Cannot sync non-integer number as key")
		end
	end
end

return validate