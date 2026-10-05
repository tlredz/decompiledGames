local TextGrammar = {
	mapPlainSegments = function(value: string, callback)
		local v = 1
		local v2 = {}

		while true do
			local v3, v4 = string.find(value, "<[^<>]*>", v)

			if not v3 then
				break
			end

			table.insert(v2, callback((string.sub(value, v, v3 - 1))))
			table.insert(v2, (string.sub(value, v3, v4)))
			v = v4 + 1
		end

		table.insert(v2, callback((string.sub(value, v))))
		return table.concat(v2)
	end
}

local function formalSegment(value: string, flag: boolean)
	local v = {}

	for i = 1, #value do
		local v2 = string.sub(value, i, i)

		if flag or not string.match(v2, "%a") then
			if string.match(v2, "[%.!%?]") then
				flag = false
			end
		else
			v2 = string.upper(v2)
			flag = true
		end

		table.insert(v, v2)
	end

	local joined = table.concat(v)
	return string.gsub(joined, "(%f[%a])i(%f[%A])", "I"), flag
end

function TextGrammar.formal(p: string)
	local v = false
	local mapPlainSegments = TextGrammar.mapPlainSegments(p, function(p2)
		local v2, v3 = formalSegment(p2, v)
		v = v3
		return v2
	end)
	local v2 = string.gsub(mapPlainSegments, "<[^<>]*>", "")
	local v3 = string.gsub(v2, "%s+$", "")

	if v3 ~= "" and not string.match(v3, "[%.!%?\"'%)%]]$") and string.sub(v3, -3) ~= "…" then
		local v4 = string.match(mapPlainSegments, "%s*$") or ""
		mapPlainSegments = string.sub(mapPlainSegments, 1, #mapPlainSegments - #v4) .. "." .. v4
	end

	return mapPlainSegments
end

return TextGrammar