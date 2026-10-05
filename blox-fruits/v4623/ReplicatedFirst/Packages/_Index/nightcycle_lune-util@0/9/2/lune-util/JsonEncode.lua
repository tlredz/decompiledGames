local v = {
	["\\"] = "\\",
	["\""] = "\"",
	["\8"] = "b",
	["\f"] = "f",
	["\n"] = "n",
	["\r"] = "r",
	["\t"] = "t"
}
local v2 = {
	["/"] = "/"
}
local fn

for k, v3 in pairs(v) do
	v2[v3] = k
end

local function escape_char(value: string)
	return "\\" .. (v[value] or string.format("u%04x", value:byte()))
end

local function encode_nil(_: nil)
	return "null"
end

local function encode_table(list, options)
	local v3 = {}
	local v4 = options or {}
	assert(v4, "bad stack")

	if v4[list] then
		error("circular reference")
	end

	v4[list] = true

	if rawget(list, 1) == nil and next(list) ~= nil then
		for k, v5 in pairs(list) do
			if type(k) ~= "string" then
				error("invalid table: mixed or invalid key types")
			end

			table.insert(v3, fn(k, v4) .. ":" .. fn(v5, v4))
		end

		v4[list] = nil
		return "{" .. table.concat(v3, ",") .. "}"
	else
		local count = 0

		for k in pairs(list) do
			if type(k) ~= "number" then
				error("invalid table: mixed or invalid key types")
			end

			count += 1
		end

		if count ~= #list then
			error("invalid table: sparse array")
		end

		for _, v5 in ipairs(list) do
			table.insert(v3, fn(v5, v4))
		end

		v4[list] = nil
		return "[" .. table.concat(v3, ",") .. "]"
	end
end

local function encode_string(value: string)
	return (`"{value:gsub("[%z\1-\31\\\"]", escape_char)}"`)
end

local function encode_number(p: number)
	if p ~= p or p <= -1e999 or p >= 1e999 then
		error("unexpected number value '" .. tostring(p) .. "'")
	end

	if p == math.round(p) then
		return string.format("%.0f", p)
	end

	return (string.format("%.14f", p):gsub("%.?0+$", ""))
end

local v3 = {
	["nil"] = encode_nil,
	table = encode_table,
	string = encode_string,
	number = encode_number,
	boolean = tostring
}

fn = function(p, p2)
	local typeName = type(p)
	local v4 = v3[typeName]

	if v4 then
		return v4(p, p2)
	end

	error("unexpected type '" .. typeName .. "'")
end

return fn