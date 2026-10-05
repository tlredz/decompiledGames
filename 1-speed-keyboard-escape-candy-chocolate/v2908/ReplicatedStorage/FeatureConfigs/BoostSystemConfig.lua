local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Suffixes = require(ReplicatedStorage.Utilities.Numbers.Suffixes)
local v = {
	1,
	1.5,
	2,
	3,
	5,
	7,
	10
}

local function roundNice(p: number)
	if p <= 0 then
		return 0
	end

	local v2 = 10 ^ math.floor((math.log10(p)))
	local v3 = p / v2

	for _, v4 in v do
		if v3 <= v4 then
			return v4 * v2
		end
	end

	return v2 * 10
end

local BoostSystemConfig = {}
BoostSystemConfig.USE_PERCENTAGE_BOOSTS = true

function BoostSystemConfig.niceFormatNumber(p, value)
	local v2 = tonumber(p) or 0
	local v3 = "%." .. (value or 2) .. "f"

	for _, SUFFIX in ipairs(Suffixes.SUFFIXES) do
		local v4 = SUFFIX[1]
		local v5 = SUFFIX[2]

		if not (v4 <= v2) then
			continue
		end

		local v6 = v2 / v4
		local v7

		if v6 <= 0 then
			v7 = 0
		else
			local v8 = 10 ^ math.floor((math.log10(v6)))
			local v9 = v6 / v8
			local flag = true

			for _, v10 in v do
				if not (v9 <= v10) then
					continue
				end

				v7 = v10 * v8
				flag = false
				break
			end

			if flag then
				v7 = v8 * 10
			end
		end

		return string.format(v3, v7):gsub("%.?0+$", "") .. v5
	end

	local v4

	if v2 <= 0 then
		v4 = 0
	else
		local v5 = 10 ^ math.floor((math.log10(v2)))
		local v6 = v2 / v5
		local flag = true

		for _, v7 in v do
			if not (v6 <= v7) then
				continue
			end

			v4 = v7 * v5
			flag = false
			break
		end

		if flag then
			v4 = v5 * 10
		end
	end

	return (tostring(v4))
end

function BoostSystemConfig.calculSpeed(p, p2: number)
	local v2 = math.clamp(math.floor(p2 * p.Percent), p.MinAmount, Suffixes.QI * p.Percent)

	if v2 <= 0 then
		return 0
	end

	local v3 = 10 ^ math.floor((math.log10(v2)))
	local v4 = v2 / v3

	for _, v5 in v do
		if v4 <= v5 then
			return v5 * v3
		end
	end

	return v3 * 10
end

return BoostSystemConfig