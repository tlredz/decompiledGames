local Object = {}

function Object.InstanceOf(p, p2)
	local metatable = getmetatable(p)

	if metatable == p2 then
		return true
	end

	return Object.ClassInstanceOf(metatable, p2)
end

function Object.ClassInstanceOf(p, p2)
	local inherits = p.Inherits

	if inherits == nil then
		return false
	end

	for _, inherit in inherits do
		if inherit == p2 or Object.ClassInstanceOf(inherit, p2) then
			return true
		end
	end

	return false
end

function Object.Descendants(p)
	local result = {}
	local metatable = getmetatable(p)
	table.insert(result, metatable)
	local inherits = {}

	if metatable.Inherits == nil then
		return result
	end

	local v = { metatable }

	for _, inherit in metatable.Inherits do
		table.insert(inherits, inherit)

		if v[inherit] then
			continue
		end

		v[inherit] = true
		table.insert(result, inherit)
	end

	while #inherits > 0 do
		local v2 = table.remove(inherits, #inherits)

		if v2.Inherits == nil then
			continue
		end

		for _, inherit in v2.Inherits do
			table.insert(inherits, inherit)

			if v[inherit] then
				continue
			end

			v[inherit] = true
			table.insert(result, inherit)
		end
	end

	return result
end

return Object