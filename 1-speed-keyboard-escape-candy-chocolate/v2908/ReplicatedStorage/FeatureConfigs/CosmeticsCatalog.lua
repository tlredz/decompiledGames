local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local TrailConfig = require(script.Parent:WaitForChild("TrailConfig"))
local AuraConfig = require(script.Parent:WaitForChild("AuraConfig"))
local EventsConfig = require(ReplicatedStorage:WaitForChild("EventsConfig"))
local eventWorldCosmetics = script.Parent:WaitForChild("EventWorldCosmetics")
local CosmeticsCatalog = {}
local v = nil
local v2 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function getEventModule()
	local v3 = Config.GetEventDataKey and Config.GetEventDataKey() or nil

	if v2 ~= false and v == v3 then
		return v2
	end

	v = v3

	if not v3 then
		v2 = nil
		return nil
	end

	local child = eventWorldCosmetics:FindFirstChild(v3)
	local v4

	if child then
		v4 = require(child)
	end

	v2 = v4
	return v2
end

function CosmeticsCatalog.IsWorldEvent()
	return (Config.GetEventDataKey and Config.GetEventDataKey()) ~= nil
end

function CosmeticsCatalog.GetTrails()
	local eventModule = getEventModule() -- equivalent call inferred; original call site unknown

	if eventModule and eventModule.Trails then
		return eventModule.Trails
	end

	return TrailConfig.TRAILS
end

function CosmeticsCatalog.GetAuras()
	local eventModule = getEventModule() -- equivalent call inferred; original call site unknown

	if eventModule and eventModule.Auras then
		return eventModule.Auras
	end

	return AuraConfig.AURAS
end

function CosmeticsCatalog.GetSeasonalTrails()
	if CosmeticsCatalog.IsWorldEvent() then
		return {}
	end

	return EventsConfig.Trails or {}
end

function CosmeticsCatalog.GetTrailData(p: string)
	local trails = CosmeticsCatalog.GetTrails()

	if trails[p] then
		return trails[p]
	end

	for _, v3 in ipairs(CosmeticsCatalog.GetSeasonalTrails()) do
		if v3.Key == p then
			return v3
		end
	end

	return nil
end

function CosmeticsCatalog.GetAuraData(p: string)
	return CosmeticsCatalog.GetAuras()[p]
end

return CosmeticsCatalog