local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Signal = require(ReplicatedStorage.Modules.Signal)
local MonetizationLibrary = require(ReplicatedStorage.Modules.MonetizationLibrary)
local StatisticsLibrary = require(ReplicatedStorage.Modules.StatisticsLibrary)
local SettingsLibrary = require(ReplicatedStorage.Modules.SettingsLibrary)
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self:_Init()
	return self
end

function class.GetRobuxSpent(_, options, options2, options3)
	local total = 0

	for _, v in pairs(options or {}) do
		total += v.CurrencySpent or 0
	end

	for k, v in pairs(options2 or {}) do
		total += v and MonetizationLibrary.Gamepasses[k] and MonetizationLibrary.Gamepasses[k].StaticRobuxPrice or 0
	end

	for _, v in pairs(options3 or {}) do
		total += v.CurrencySpentTotal or 0
	end

	return total
end

function class:GetSetting(object, p, p2)
	assert(SettingsLibrary:DoesExist(p), p)
	return object:Get("Settings")[p2 or object:Get("SettingsProfile")][p]
end

function class:GetSettingChangedSignal(object2, p)
	assert(SettingsLibrary:DoesExist(p), p)

	if not next(object2._setting_changed_events) then
		local settingsProfile = object2:Get("SettingsProfile")

		local function update_bulk(p2)
			local settingsProfile2 = object2:Get("SettingsProfile")

			for k, _setting_changed_event in pairs(object2._setting_changed_events) do
				local setting

				if p2 then
					setting = self:GetSetting(object2, k, settingsProfile)
				end

				local setting2

				if p2 then
					setting2 = self:GetSetting(object2, k, settingsProfile2)
				end

				if p2 then
					local v

					if typeof(setting) == "number" and typeof(setting2) == "number" then
						v = math.abs(setting - setting2) < 0.001
					else
						v = setting == setting2
					end

					if v then
						continue
					end
				end

				_setting_changed_event:FireDeferred()
			end

			settingsProfile = settingsProfile2
		end

		object2:GetDataChangedSignal("SettingsProfile"):Connect(function()
			update_bulk(true)
		end)
		object2:GetDataChangedSignal("Settings"):Connect(function()
			update_bulk()
		end)
	end

	if not object2._setting_changed_events[p] then
		object2._setting_changed_events[p] = Signal.new()
	end

	return object2._setting_changed_events[p]
end

function class.SetSetting(_, object, p, p2, p3)
	assert(SettingsLibrary:DoesExist(p), p)
	local settings = object:Get("Settings")
	settings[p3 or object:Get("SettingsProfile")][p] = p2

	if object.ReplicateToClient then
		object.ReplicateToClient:Fire("SettingChanged", p, p2, p3)
	end

	if object._setting_changed_events[p] then
		object._setting_changed_events[p]:Fire(p2, p)
	end
end

function class:IsNosniyGamesTeamMemberRaw(list)
	return list and table.find(list, CONSTANTS.TEAM_GROUP_ROLE_ID)
end

function class:IsNosniyGamesTeamMember(object2)
	return self:IsNosniyGamesTeamMemberRaw(object2:Get("GroupRoleIDs"))
end

function class.GetWeaponData(_, object, p)
	for k, v in pairs(object:Get("WeaponInventory")) do
		if v.Name == p then
			return v, k
		end
	end
end

function class.HasGamepass(_, object, p)
	return object:Get("Gamepasses")[p]
end

function class.AreTasksCompleted(_, object, value)
	for _, v in pairs(object:Get(value or "Tasks")) do
		if not v.Completed then
			return false
		end
	end

	return true
end

function class.GetUnlockedWeapons(_, object, p)
	local result = {}

	for _, v in pairs(object:Get("WeaponInventory")) do
		result[v.Name] = true
	end

	if not p then
		for k in pairs(object:Get("FreeWeaponUnlockCheck")) do
			result[k] = true
		end
	end

	return result
end

function class.GetStatistic(_, object, p)
	local v = StatisticsLibrary.Info[p]
	assert(v ~= nil, p)
	return object:Get(p) or v.DefaultValue
end

function class:GetDirectoryStatistic(object, p, p2, p3, options)
	local v = StatisticsLibrary.Info[p3]
	assert(v ~= nil, p3)
	local v2 = 0

	local function add(p4)
		local v3 = object:Get(p)
		local v4 = v3[p2] and v3[p2][p4] or v.DefaultValue

		if v.ValueType == "number" then
			v4 = v2 + v4
		end

		v2 = v4
	end

	local v3 = object:Get(p)
	local v4 = v3[p2] and v3[p2][p3] or v.DefaultValue

	if v.ValueType == "number" then
		v2 += v4
	else
		v2 = v4
	end

	for _, v5 in pairs(options or {}) do
		local v6 = object:Get(p)
		local v7 = v6[p2] and v6[p2][v5] or v.DefaultValue

		if v.ValueType == "number" then
			v2 += v7
		else
			v2 = v7
		end
	end

	return v2
end

function class.GetSeasonInfo(_, object, p)
	local v = object:Get("Seasons")[p]
	local v2 = v and v.RankedPerformances[SeasonLibrary.UNIVERSAL_ELO_NAME]
	return v2 and v2.CurrentELO, v2 and v2.Metadata and v2.Metadata.FinalLeaderboardRank
end

function class:GetWeaponStatistic(p, ...)
	return self:GetDirectoryStatistic(p, "WeaponStatistics", ...)
end

function class:GetMapStatistic(p, ...)
	return self:GetDirectoryStatistic(p, "MapStatistics", ...)
end

function class:_Init() end

return class._new()