local import = _G.import("hmac")
local import2 = _G.import("sha256")
local import3 = _G.import("dictUtil")
local HttpService = game:GetService("HttpService")
local canonicalize

canonicalize = function(list)
	if type(list) ~= "table" then
		return list
	end

	if import3.isArray(list) then
		local result = table.create(#list)

		for i = 1, #list do
			result[i] = canonicalize(list[i])
		end

		return result
	else
		local v = {}

		for k in pairs(list) do
			table.insert(v, (tostring(k)))
		end

		table.sort(v)
		local result = {}

		for _, v2 in ipairs(v) do
			result[#result + 1] = { v2, canonicalize(list[v2]) }
		end

		return result
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function canonicalPayload(p)
	return HttpService:JSONEncode((canonicalize(p)))
end

local function toHex(value)
	local v = table.create(#value * 2)

	for i = 1, #value do
		v[i] = string.format("%02x", string.byte(value, i))
	end

	return table.concat(v)
end

return {
	signPayload = function(p, str)
		local v = canonicalPayload(p) -- equivalent call inferred; original call site unknown
		return (toHex(import(buffer.fromstring(v), buffer.fromstring(str), import2, 64)))
	end
}