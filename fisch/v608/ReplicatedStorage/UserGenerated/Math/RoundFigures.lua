local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StableExp10 = require(ReplicatedStorage.UserGenerated.Math.StableExp10)

local function RoundFigures(value: number, value2: number?, value3: number?, callback)
	assert(type(value) == "number")
	assert(value2 == nil or type(value2) == "number")
	assert(value3 == nil or type(value3) == "number")
	assert(callback == nil or type(callback) == "function")

	if value ~= value or value == 1e999 or value == -1e999 then
		return value
	end

	local v2 = value3 or 1
	local v3 = callback or math.round
	local v4 = math.sign(value)

	if v4 == 0 then
		return 0
	end

	local v5 = value * v4
	local v6 = math.floor((math.log10(v5))) - (value2 or 3) + 1

	if v2 ~= 1 then
		v5 /= v2
	end

	return StableExp10(v3((StableExp10(v5, -v6))) * v2, v6) * v4
end

return RoundFigures