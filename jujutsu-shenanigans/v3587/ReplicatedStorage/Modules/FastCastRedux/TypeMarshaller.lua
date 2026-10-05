local typeof2 = typeof

local function typeof3(p)
	local typeName = typeof2(p)

	if typeName ~= "table" then
		return typeName
	end

	local metatable = getmetatable(p)

	if typeof2(metatable) ~= "table" then
		return typeName
	end

	local __type = metatable.__type

	if __type == nil then
		return typeName
	end

	return __type
end

return typeof3