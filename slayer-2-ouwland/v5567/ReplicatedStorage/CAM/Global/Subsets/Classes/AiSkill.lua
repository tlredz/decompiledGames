local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local AiSkill = {}
local RandomChoice = require(ReplicatedStorage.CAM.Global.Subsets.Classes.RandomChoice)
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
local AiGetProperty = require(ServerStorage.SAM.AiThings.NpcNetwork.Central.AiGetProperty)

local function pickerEntry(value)
	if type(value) == "number" then
		return value, 1
	end

	if type(value) ~= "table" then
		return 1, 1
	end

	local selected = type(value.Max) ~= "number" and 1 or value.Max

	if type(value.CoolDown) == "number" then
		return selected, value.CoolDown
	end

	return selected, 1
end

local function pickerScale(data, p: string, p2: string?)
	local stats

	if data ~= nil then
		stats = data.Stats
	end

	local selected

	if stats ~= nil then
		selected = stats[p]
	end

	if type(selected) == "number" then
		return selected, 1
	end

	if type(selected) ~= "table" then
		return 1, 1
	end

	if type(selected.Max) == "number" or type(selected.CoolDown) == "number" then
		return pickerEntry(selected)
	end

	return pickerEntry(p2 ~= nil and selected[p2] or selected.Default)
end

local v = {
	CanPerform = function(data, data2, p: string?, flag: boolean?, value: number?)
		if data.HoldChance.Max >= 999 or data.Distance ~= nil and data.Distance.Min ~= nil and data2.Properties.Distance <= data.Distance.Min then
			return false
		end

		if data.Distance ~= nil then
			local max = data.Distance.Max

			if data.Distance.MaxStat ~= nil and data2.Stats ~= nil then
				local stat = data2.Stats[data.Distance.MaxStat]

				if type(stat) == "number" and stat > 0 then
					max = stat
				end
			end

			if max ~= nil and max < data2.Properties.Distance then
				return false
			end
		end

		if data.BlockConditions then
			for _, blockCondition in data.BlockConditions do
				local flag2 = true

				for k, v3 in blockCondition do
					if (data2.Properties[k] or AiGetProperty(k, data2)) == v3 then
						continue
					end

					flag2 = false
					break
				end

				if flag2 then
					return false
				end
			end
		end

		if not (os.clock() - data.LastPerformed >= data.CoolDown) then
			return false
		end

		if flag then
			return true
		end

		local v2 = {}
		local v3 = 1

		for k, v4 in data.HoldChance do
			v2[k] = v4
		end

		if data.HoldBoosterProperties then
			for _, holdBoosterProperty in data.HoldBoosterProperties do
				local count = 0
				local total = 0

				for k, property in holdBoosterProperty.Properties do
					local v4 = data2.Properties[k] or AiGetProperty(k, data2)

					if v4 ~= nil then
						total += v4 * property
					end

					count += 1
				end

				if total / count >= 1 then
					v3 *= holdBoosterProperty.Scale
				end
			end
		end

		v2.Max = math.max(math.round(v2.Max * v3), 1)

		if data.Name ~= nil and data2.Settings ~= nil then
			local setting = data2.Settings[data.Name]

			if setting ~= nil then
				v2.Max *= math.max(setting.HoldScale, 1) or 1
				v2.CoolDown = setting.HoldCoolDown or v2.CoolDown
			end
		end

		local v4, v5 = pickerScale(data2, "SkillPickerHoldScale", p)
		local v6 = v4 / (data2.Stats == nil and 1 or data2.Stats.SkillPaceScale or 1)
		v2.Max = math.max(math.round(v2.Max * v6 * (value or 1)), 1)
		v2.CoolDown *= v5
		local v7 = RandomChoice.Perform(v2)
		data.HoldChance.Last = v2.Last

		for k, _ in v2 do
			v2[k] = nil
		end

		return v7
	end,
	CanStopSkill = function(data, data2, p)
		local v2 = data2.Skills.HoldStarted and data2.Skills.HoldStarted[p]

		if not v2 then
			return false
		end

		local v3 = os.clock() - v2

		if data.HoldSettings.Min ~= nil and not (data.HoldSettings.Min < v3) then
			return false
		end

		if data.HoldSettings.Max ~= nil and data.HoldSettings.Max <= v3 or data.UnHoldChance.Max >= 999 then
			return data.HoldSettings.Max ~= nil and data.HoldSettings.Max <= v3
		end

		if data.UnHoldBlockConditions then
			for _, unHoldBlockCondition in data.UnHoldBlockConditions do
				local flag = true

				for k, v5 in unHoldBlockCondition do
					if (data2.Properties[k] or AiGetProperty(k, data2)) == v5 then
						continue
					end

					flag = false
					break
				end

				if flag then
					return false
				end
			end
		end

		local v4 = {}
		local v5 = 1

		for k, v6 in data.UnHoldChance do
			v4[k] = v6
		end

		if data.UnHoldBoosterProperties then
			for _, unHoldBoosterProperty in data.UnHoldBoosterProperties do
				local count = 0
				local total = 0

				for k, property in unHoldBoosterProperty.Properties do
					local v6 = data2.Properties[k] or AiGetProperty(k, data2)

					if v6 ~= nil then
						total += v6 * property
					end

					count += 1
				end

				if total / count >= 1 then
					v5 *= unHoldBoosterProperty.Scale
				end
			end
		end

		v4.Max = math.max(math.round(v4.Max * v5), 1)

		if data.Name ~= nil and data2.Settings ~= nil then
			local setting = data2.Settings[data.Name]

			if setting ~= nil then
				v4.Max *= math.max(setting.UnHoldScale, 1) or 1
				v4.CoolDown = setting.UnHoldCoolDown or v4.CoolDown
			end
		end

		local v6, v7 = pickerScale(data2, "SkillPickerUnHoldScale", p)
		v4.Max = math.max(math.round(v4.Max * v6), 1)
		v4.CoolDown *= v7
		local v8 = RandomChoice.Perform(v4)
		data.UnHoldChance.Last = v4.Last

		for k, _ in v4 do
			v4[k] = nil
		end

		return v8
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function copyChance(items)
	if typeof(items) ~= "table" then
		return items
	end

	local result = {}

	for k, item in items do
		result[k] = item
	end

	return result
end

function AiSkill.new(items)
	local result = {}

	if items ~= nil then
		for k, item in items do
			result[k] = item
		end
	end

	local holdChance = copyChance(result.HoldChance) -- equivalent call inferred; original call site unknown
	result.HoldChance = holdChance
	local unHoldChance = copyChance(result.UnHoldChance) -- equivalent call inferred; original call site unknown
	result.UnHoldChance = unHoldChance
	result.CoolDown = result.CoolDown or 1
	result.LastPerformed = result.LastPerformed or 0
	result.Priority = result.Priority or 1
	setmetatable(result, v)
	return result
end

v.__index = v
return AiSkill