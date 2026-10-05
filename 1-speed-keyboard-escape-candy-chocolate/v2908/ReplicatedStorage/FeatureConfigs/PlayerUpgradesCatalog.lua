local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local TrailConfig = require(script.Parent:WaitForChild("TrailConfig"))
local AuraConfig = require(script.Parent:WaitForChild("AuraConfig"))
local Items = require(script.Parent:WaitForChild("Items"))
local EventsConfig = require(ReplicatedStorage:WaitForChild("EventsConfig"))
local Skins = require(script.Parent:WaitForChild("PersonalTreadmill"):WaitForChild("Skins"))
local PlayerUpgradesCatalog = {}
local v = false
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function currentEventKey()
	return Config.GetEventDataKey and Config.GetEventDataKey() or nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function invalidateIfNeeded()
	local v7 = currentEventKey() -- equivalent call inferred; original call site unknown

	if not v or v2 ~= v7 then
		v = true
		v2 = v7
		v3 = nil
		v4 = nil
		v5 = nil
		v6 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isAvailable(item, p: string?)
	if (item.galaxy or 1) ~= (Config.GALAXY_INDEX or 1) then
		return false
	end

	if p then
		return item.EventKey == p
	end

	return item.EventKey == nil
end

local function filterMap(items, p: string?)
	local result = {}

	for k, item in pairs(items) do
		-- equivalent call inferred; original call site unknown
		if isAvailable(item, p) then
			result[k] = item
		end
	end

	return result
end

function PlayerUpgradesCatalog.IsWorldEvent()
	return currentEventKey() ~= nil
end

function PlayerUpgradesCatalog.GetTrails()
	invalidateIfNeeded() -- equivalent call inferred; original call site unknown

	if not v3 then
		v3 = filterMap(TrailConfig.TRAILS, v2)
	end

	return v3
end

function PlayerUpgradesCatalog.GetInventoryTrails(list)
	local clone = table.clone(PlayerUpgradesCatalog.GetTrails())

	for _, v7 in ipairs(list) do
		local v8 = TrailConfig.TRAILS[v7]

		if v8 and (v8.galaxy or 1) == (Config.GALAXY_INDEX or 1) then
			clone[v7] = v8
		end
	end

	return clone
end

function PlayerUpgradesCatalog.GetAuras()
	invalidateIfNeeded() -- equivalent call inferred; original call site unknown

	if not v4 then
		v4 = filterMap(AuraConfig.AURAS, v2)
	end

	return v4
end

function PlayerUpgradesCatalog.GetInventoryAuras(list)
	local clone = table.clone(PlayerUpgradesCatalog.GetAuras())

	for _, v7 in ipairs(list) do
		local v8 = AuraConfig.AURAS[v7]

		if v8 and (v8.galaxy or 1) == (Config.GALAXY_INDEX or 1) then
			clone[v7] = v8
		end
	end

	return clone
end

function PlayerUpgradesCatalog.GetItems()
	invalidateIfNeeded() -- equivalent call inferred; original call site unknown

	if not v5 then
		v5 = filterMap(Items.ITEMS, v2)
	end

	return v5
end

function PlayerUpgradesCatalog.GetSkins()
	invalidateIfNeeded() -- equivalent call inferred; original call site unknown

	if not v6 then
		v6 = filterMap(Skins.SKINS, v2)
	end

	return v6
end

function PlayerUpgradesCatalog.GetInventorySkins(list)
	local clone = table.clone(PlayerUpgradesCatalog.GetSkins())

	for _, v7 in ipairs(list) do
		local v8 = Skins.SKINS[v7]

		if v8 then
			clone[v7] = v8
		end
	end

	return clone
end

function PlayerUpgradesCatalog.GetSeasonalTrails()
	if PlayerUpgradesCatalog.IsWorldEvent() then
		return {}
	end

	return EventsConfig.Trails or {}
end

function PlayerUpgradesCatalog.GetTrailData(p: string)
	local trails = PlayerUpgradesCatalog.GetTrails()

	if trails[p] then
		return trails[p]
	end

	for _, v7 in ipairs(PlayerUpgradesCatalog.GetSeasonalTrails()) do
		if v7.Key == p then
			return v7
		end
	end

	local v7 = TrailConfig.TRAILS[p]

	if v7 and (v7.galaxy or 1) == (Config.GALAXY_INDEX or 1) then
		return v7
	end

	return nil
end

function PlayerUpgradesCatalog.GetAuraData(p: string)
	local v7 = PlayerUpgradesCatalog.GetAuras()[p]

	if v7 then
		return v7
	end

	local v8 = AuraConfig.AURAS[p]

	if v8 and (v8.galaxy or 1) == (Config.GALAXY_INDEX or 1) then
		return v8
	end

	return nil
end

function PlayerUpgradesCatalog.GetItemData(p: string)
	return PlayerUpgradesCatalog.GetItems()[p] or Items.ITEMS[p]
end

function PlayerUpgradesCatalog.GetSkinData(p: string)
	return PlayerUpgradesCatalog.GetSkins()[p] or Skins.SKINS[p]
end

return PlayerUpgradesCatalog