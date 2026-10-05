local FormatTable

FormatTable = function(item, count, p)
	local v = count or 0
	local v2 = "" .. (p and "\n" or "")
	local v3 = string.rep("  ", v)
	local v4 = v2 .. v3 .. "{\n"

	for k, item2 in item do
		local v5 = string.rep("  ", v + 1) .. tostring(k) .. " = "

		if typeof(item2) == "table" then
			if #item2 == 0 then
				v4 ..= v5 .. "{},\n"
			else
				v4 ..= v5 .. FormatTable(item2, v + 1)
			end
		else
			v4 ..= v5 .. tostring(item2) .. ",\n"
		end
	end

	return v4 .. v3 .. "},\n"
end

return FormatTable