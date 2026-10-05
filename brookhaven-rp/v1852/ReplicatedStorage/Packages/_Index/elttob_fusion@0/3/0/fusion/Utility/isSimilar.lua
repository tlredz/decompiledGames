local function isSimilar(list, p)
	local typeName = typeof(list)
	local v = typeName == "table"
	local v2 = typeName == "userdata"

	if v or v2 then
		if typeName == typeof(p) and (v2 or table.isfrozen(list) or getmetatable(list) ~= nil) then
			return list == p
		end
	else
		if list == p then
			return true
		end

		if list ~= list then
			return p ~= p
		end
	end

	return false
end

return isSimilar