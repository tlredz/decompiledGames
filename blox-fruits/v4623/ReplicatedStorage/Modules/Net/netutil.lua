local workspace2 = workspace
local floor = math.floor
local char = string.char
local bxor = bit32.bxor
local byte = string.byte
local next2 = next
local v = {
	["1"] = {}
}

v["1"]["1"] = function(value)
	if typeof(value) ~= "string" then
		return ""
	end

	local serverTimeNow = workspace2:GetServerTimeNow()
	local v3 = floor(serverTimeNow / 10 % 10)
	floor(serverTimeNow / 1000 % 10)
	floor(serverTimeNow / 10000 % 10)
	local v6 = ""

	for i = 1, #value do
		v6 ..= char((bxor(byte(value, i), v3 + 1)))
	end

	return v6
end

return function()
	local _1 = v["1"]
	v["1"] = nil

	for k, v2 in next2, _1, nil do
		local v3 = k
		local v4 = v2

		_1[k] = function()
			_1[v3] = nil
			return v4
		end
	end

	return _1
end