local v = _G.import("collection")("Data", script)

local function lower(value)
	return string.lower((tostring(value or "")))
end

local v2 = {}

for k, v3 in pairs(v.Data) do
	local name = v3.Name

	if name then
		v2[string.lower((tostring(name or "")))] = k
	end

	local aliases = v3.Aliases

	if not aliases then
		continue
	end

	for _, alias in ipairs(aliases) do
		v2[string.lower((tostring(alias or "")))] = k
	end
end

function v.getAll(p)
	return p.Data
end

function v.getAllCommandNames(p)
	local names = {}

	for _, v3 in pairs(p.Data) do
		if v3 and v3.Name then
			names[#names + 1] = v3.Name
		end
	end

	table.sort(names)
	return names
end

function v.resolveId(_, value)
	return v2[string.lower((tostring(value or "")))]
end

return v