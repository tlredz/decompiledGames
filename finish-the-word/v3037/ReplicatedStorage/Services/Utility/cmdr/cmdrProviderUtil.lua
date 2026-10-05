local import = _G.import("stringUtil")
local CmdrProviderUtil = {
	matchesPrefix = function(value, p)
		if p == "" then
			return true
		end

		return import.startsWith(value:lower(), p)
	end,
	sortCaseInsensitive = function(list)
		table.sort(list, function(a, b)
			return a:lower() < b:lower()
		end)
	end,
	buildEntriesFromNames = function(list, p, callback)
		local result = {}

		for i = 1, math.min(#list, p or #list) do
			result[#result + 1] = callback(list[i])
		end

		local v

		if result[1] then
			v = result[1].Name or false
		else
			v = false
		end

		return result, v
	end
}

function CmdrProviderUtil.listFromPairsKeyString(items, p)
	local result = {}

	for k in pairs(items) do
		if CmdrProviderUtil.matchesPrefix(k, p) then
			result[#result + 1] = tostring(k)
		end
	end

	CmdrProviderUtil.sortCaseInsensitive(result)
	return result
end

function CmdrProviderUtil.listFromArray(list, p)
	local result = {}

	for i = 1, #list do
		local v = list[i]

		if CmdrProviderUtil.matchesPrefix(v, p) then
			result[#result + 1] = v
		end
	end

	CmdrProviderUtil.sortCaseInsensitive(result)
	return result
end

function CmdrProviderUtil.makeSimpleEntry(name, value)
	return {
		Name = name,
		Description = value or "",
		ArgsText = ""
	}
end

return CmdrProviderUtil