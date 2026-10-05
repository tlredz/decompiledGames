local function version_tostring(p)
	return string.format("%d.%d", p.Major, p.Minor)
end

local function version_lt(p, p2)
	if p.Major == p2.Major then
		return p.Minor < p2.Minor
	end

	return p.Major < p2.Major
end

local function version_eq(p, p2)
	return p.Major == p2.Major and p.Minor == p2.Minor
end

-- equivalent calls inferred from this helper; original call sites unknown
local function double_to_int32(p: number)
	if math.clamp(tonumber(p) or 0, -2147483648, 2147483647) ~= p then
		return UDim.new(nil, p).Offset
	end

	if p <= -1 then
		return (math.ceil(p))
	end

	if p >= 1 then
		return (math.floor(p))
	end

	return 0
end

local v = {
	new = function(p: number, p2: number)
		local v2 = newproxy(true)
		local metatable = getmetatable(v2)
		local major = double_to_int32(p) -- equivalent call inferred; original call site unknown
		local minor = double_to_int32(p2) -- equivalent call inferred; original call site unknown
		metatable.__index = {
			Major = major,
			Minor = minor
		}
		metatable.__metatable = "The metatable is locked"
		metatable.__tostring = version_tostring
		metatable.__lt = version_lt
		metatable.__eq = version_eq
		table.freeze(metatable)
		return v2
	end
}
v.current = v.new(31, 1)
return table.freeze(v)