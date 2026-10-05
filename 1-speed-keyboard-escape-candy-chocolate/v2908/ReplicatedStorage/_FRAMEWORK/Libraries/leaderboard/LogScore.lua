local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Suffixes = require(ReplicatedStorage.Utilities.Numbers.Suffixes)

local function formatFromLog10(p: number, p2: number)
	if p ~= p or p == -1e999 then
		return "0"
	end

	if p == 1e999 then
		return "Inf"
	end

	if p < 3 then
		return (tostring((math.floor(10 ^ p + 1e-9))))
	end

	local v = "%." .. p2 .. "f"

	for _, SUFFIX in ipairs(Suffixes.SUFFIXES) do
		local v2 = math.log10(SUFFIX[1])

		if not (v2 - 1e-9 <= p) then
			continue
		end

		local v3 = p - v2

		if v3 < 3 then
			return string.format(v, 10 ^ v3):gsub("%.?0+$", "") .. SUFFIX[2]
		end
	end

	local v2 = math.floor(p + 1e-9)
	local v3 = 10 ^ math.clamp(p - v2, 0, 1)
	return string.format(v, v3):gsub("%.?0+$", "") .. "e+" .. tostring(v2)
end

local LogScore = {}

function LogScore.encode(p: number)
	if p == p and math.abs(p) ~= 1e999 and not (p <= 0) then
		return (math.floor(math.log10(p) * 1000000))
	end

	return 0
end

function LogScore.decode(p: number)
	if p <= 0 then
		return 0
	end

	if p > 308254715 then
		return p
	end

	local v = p / 1000000

	if v >= 308.25471555991675 then
		return 1.7976931348623157e308
	end

	local v2 = 10 ^ v

	if v2 == 1e999 then
		return 1.7976931348623157e308
	end

	return v2
end

function LogScore.format(p: number, value: number?)
	local v = value or 2

	if p <= 0 then
		return "0"
	end

	if p > 308254715 then
		return (formatFromLog10(math.log10(p), v))
	end

	return (formatFromLog10(p / 1000000, v))
end

return LogScore