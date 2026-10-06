game:GetService("ReplicatedStorage")
local Config = require(script.Parent:WaitForChild("Config"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))
local TimeService = require(script.Parent:WaitForChild("TimeService"))

-- equivalent calls inferred from this helper; original call sites unknown
local function normalizePositiveInteger(value)
	if typeof(value) == "number" and not (value <= 0) then
		return (math.floor(value))
	end

	return nil
end

local function normalizeHour(value)
	if typeof(value) ~= "number" then
		return nil
	end

	local v = math.floor(value)

	if v >= 0 and v <= 23 then
		return v
	end

	return nil
end

local function normalizeWeekday(value)
	if typeof(value) ~= "number" then
		return nil
	end

	local v = math.floor(value)

	if v >= 1 and v <= 7 then
		return v
	end

	return nil
end

local function getConfig()
	local coinsLimit = Config.misc and Config.misc.coinsLimit

	if typeof(coinsLimit) ~= "table" then
		warn("[DuelCoinLimit] Config.misc.coinsLimit 无效，已跳过金币上限")
		return nil, nil, nil, nil, nil
	end

	local positiveInteger = normalizePositiveInteger(coinsLimit["每日金币上限"]) -- equivalent call inferred; original call site unknown
	local positiveInteger2 = normalizePositiveInteger(coinsLimit["每周金币上限"]) -- equivalent call inferred; original call site unknown
	local v3 = coinsLimit["每日重置时间"]
	local v4

	if typeof(v3) == "number" then
		v4 = math.floor(v3)

		if not (v4 >= 0 and v4 <= 23) then
			v4 = nil
		end
	end

	local v5 = coinsLimit["每周重置时间"]
	local v6

	if typeof(v5) == "number" then
		v6 = math.floor(v5)

		if not (v6 >= 0 and v6 <= 23) then
			v6 = nil
		end
	end

	local v7 = coinsLimit["每周重置日期"]
	local v8

	if typeof(v7) == "number" then
		v8 = math.floor(v7)

		if not (v8 >= 1 and v8 <= 7) then
			v8 = nil
		end
	end

	if positiveInteger and not v4 then
		warn("[DuelCoinLimit] 每日金币上限配置缺少有效的每日重置时间，已跳过日上限")
		positiveInteger = nil
	end

	if positiveInteger2 and not (v6 and v8) then
		warn("[DuelCoinLimit] 每周金币上限配置缺少有效的周重置时间或日期，已跳过周上限")
		positiveInteger2 = nil
	end

	return positiveInteger, positiveInteger2, v4, v6, v8
end

return {
	claim = function(p, value: number)
		local positiveInteger = normalizePositiveInteger(value) -- equivalent call inferred; original call site unknown

		if not positiveInteger then
			return {
				awarded = 0,
				wasCapped = false
			}
		end

		local config, v, v2, v3, v4 = getConfig()

		if not (config or v) then
			return {
				awarded = positiveInteger,
				wasCapped = false
			}
		end

		local v5

		if config and v2 then
			v5 = TimeService.getDayKey(0, v2)
		else
			v5 = nil
		end

		local v6

		if v and v3 and v4 then
			v6 = TimeService.getWeekKey(0, v3, v4)
		else
			v6 = nil
		end

		local v7 = {
			awarded = 0,
			wasCapped = false
		}
		v7.awarded = positiveInteger
		local v8 = PlayerData.server[p]

		if not v8 then
			return v7
		end

		v8.duelCoinLimit(function(p2)
			local v9 = typeof(p2) ~= "table" and {
				dailyKey = 0,
				dailyEarned = 0,
				weeklyKey = 0,
				weeklyEarned = 0
			} or p2
			local v10

			if v5 == nil then
				v10 = math.max(0, v9.dailyEarned)
			else
				v10 = v9.dailyKey ~= v5 and 0 or math.max(0, v9.dailyEarned)
			end

			local v11

			if v6 == nil then
				v11 = math.max(0, v9.weeklyEarned)
			else
				v11 = v9.weeklyKey ~= v6 and 0 or math.max(0, v9.weeklyEarned)
			end

			local awarded = positiveInteger

			if config then
				awarded = math.min(awarded, (math.max(0, config - v10)))
			end

			if v then
				awarded = math.min(awarded, (math.max(0, v - v11)))
			end

			v7 = {
				awarded = awarded,
				wasCapped = awarded < positiveInteger
			}
			return {
				dailyKey = v5 or v9.dailyKey,
				dailyEarned = v10 + awarded,
				weeklyKey = v6 or v9.weeklyKey,
				weeklyEarned = v11 + awarded
			}
		end)
		return v7
	end
}