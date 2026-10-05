game:GetService("RunService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local module = require("./SharedDataHelper")
local module2 = require("../utils/FischUtils")
local module3 = require("@self/Config")
local module4 = require("@self/Level")
local SharedKeeperEnchant = {
	GetPowerLevel = function(p, p2: string)
		return module.indexNewFormat(p, { "Rods", p2, "power" }) or 0
	end
}

function SharedKeeperEnchant.GetPowerLevelMultiplier(p, p2: string)
	local powerLevel = SharedKeeperEnchant.GetPowerLevel(p, p2)
	return math.map(powerLevel, 0, 100, module3.MultiplierMin, module3.MultiplierMax)
end

function SharedKeeperEnchant.IsPillarActive(p, instance)
	if not instance then
		return false
	end

	local pillarId

	if typeof(instance) == "Instance" then
		pillarId = instance:GetAttribute("PillarId")
	else
		pillarId = instance
	end

	if instance:GetAttribute("Active") then
		return true
	end

	if workspace:GetAttribute("PowerBurstActive") then
		return not (pillarId > 1 and module4.GetLevel(p) < pillarId)
	end

	return false
end

function SharedKeeperEnchant.ValidateAltarState(p, p2, flag: boolean?)
	local clone = table.clone(p2)

	for _, v in CollectionService:GetTagged("AltarRelicInput") do
		if not SharedKeeperEnchant.IsPillarActive(p, v.Parent) then
			clone[v:GetAttribute("RelicType")] = nil
		end
	end

	if clone.Enchant or not (clone.Exalted or clone.Cosmic or clone.Twisted or clone.Quest or clone.Limited) then
		if clone.Cosmic and not clone.Exalted then
			if flag then
				return false, "You must input an Exalted Relic first.", clone
			end

			return false, "You must input an Exalted Relic or remove the Cosmic Relic first.", clone
		else
			if clone.Cosmic then
				return true, "KeeperCosmic", clone
			end

			if clone.Exalted then
				return true, "KeeperExalted", clone
			end

			if clone.Enchant then
				return true, "KeeperEnchant", clone
			end

			return true, "ReplenishPower", clone
		end
	elseif flag then
		return false, "You must input an Enchant Relic first."
	else
		return false, "You must input an Enchant Relic or remove higher-tier Relics first."
	end
end

local result = nil

local function getOfferMap()
	if result ~= nil then
		return result
	end

	local module5 = require("./library/fish")
	result = {}

	for k, v in module5 do
		if not (typeof(v) == "table" and v.RelicOfferType) then
			continue
		end

		if not result[v.RelicOfferType] then
			result[v.RelicOfferType] = {}
		end

		table.insert(result[v.RelicOfferType], k)
	end

	return result
end

function SharedKeeperEnchant.GetAcceptedRelics(p: string)
	return getOfferMap()[p] or {}
end

function SharedKeeperEnchant.FindOfferRelic(p, p2: string)
	local v = assert(p or Players.LocalPlayer, "Expected a player")
	local v2 = getOfferMap()[p2]

	if v2 then
		return next((module2.FindQuestFish(v2, nil, v, 1)))
	end

	return nil
end

return SharedKeeperEnchant