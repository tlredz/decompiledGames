local v = {
	perm = true,
	permanent = true,
	forever = true
}
local v2 = {
	s = 1,
	m = 60,
	h = 3600,
	d = 86400,
	w = 604800
}

local function parseDuration(value)
	if value == nil or value == "" then
		return nil
	end

	local v3 = string.lower(value)

	if v[v3] then
		return -1
	end

	if string.gsub(v3, "(%d+)([smhdw])", "") ~= "" then
		return nil
	end

	local total = 0

	for k, v4 in string.gmatch(v3, "(%d+)([smhdw])") do
		total += tonumber(k) * v2[v4]
	end

	if total <= 0 or total > 3153600000 then
		return nil
	end

	return total
end

local v3 = {
	DisplayName = "Ban Duration",
	Transform = function(p)
		return p, (parseDuration(p))
	end,
	Validate = function(_, p)
		return p ~= nil, "Use a length like 30m, 12h, 7d, 2w, 1d12h, or perm."
	end,
	Autocomplete = function(value)
		local v4 = string.lower(value)

		if #v4 > 0 and string.sub("permanent", 1, #v4) == v4 then
			return { "perm" }
		end

		return {}
	end,
	Parse = function(_, p)
		return p
	end
}
return function(registry)
	registry:RegisterType("banDuration", v3)
end