local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local PlayerUpgradesCatalog = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("PlayerUpgradesCatalog"))

-- equivalent calls inferred from this helper; original call sites unknown
local function entryGalaxy(p)
	if p.galaxy == nil then
		return 1
	end

	return p.galaxy
end

local UpgradeMultipliers = {}

function UpgradeMultipliers.catalogGalaxy(p)
	if p.galaxy == nil then
		return 1
	end

	return p.galaxy
end

function UpgradeMultipliers.matchesActiveGalaxy(p)
	return entryGalaxy(p) == Config.GALAXY_INDEX
end

function UpgradeMultipliers.trail(p: string)
	local trailData = PlayerUpgradesCatalog.GetTrailData(p)

	if trailData and entryGalaxy(trailData) == Config.GALAXY_INDEX then
		return trailData.Multiplier
	end

	return 1
end

function UpgradeMultipliers.aura(p: string)
	local auraData = PlayerUpgradesCatalog.GetAuraData(p)

	if auraData and entryGalaxy(auraData) == Config.GALAXY_INDEX then
		return auraData.multiplier
	end

	return 1
end

return UpgradeMultipliers