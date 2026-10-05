local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.CAM.Global.Types.ClanTypes)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Clans = {
	Rarities = {
		{
			rarity = 1,
			name = "Common",
			chance = 0.6,
			color = Color3.fromRGB(220, 228, 240)
		},
		{
			rarity = 2,
			name = "Uncommon",
			chance = 0.23,
			color = Color3.fromRGB(96, 214, 130)
		},
		{
			rarity = 3,
			name = "Rare",
			chance = 0.12,
			color = Color3.fromRGB(92, 170, 255)
		},
		{
			rarity = 5,
			name = "Legendary",
			chance = 0.04,
			color = Color3.fromRGB(240, 190, 80)
		},
		{
			rarity = 6,
			name = "Mythic",
			chance = 0.009,
			color = Color3.fromRGB(200, 120, 255)
		},
		{
			rarity = 7,
			name = "Supreme",
			chance = 0.001,
			color = Color3.fromRGB(255, 92, 120)
		}
	}
}
local Common = require(script.Common)
local Uncommon = require(script.Uncommon)
local Rare = require(script.Rare)
local Legendary = require(script.Legendary)
local Mythic = require(script.Mythic)
local Supreme = require(script.Supreme)
Clans.ByRarity = {
	[1] = Common,
	[2] = Uncommon,
	[3] = Rare,
	[5] = Legendary,
	[6] = Mythic,
	[7] = Supreme
}
Clans.Clans = {}

for _, rarity in Clans.Rarities do
	for k, v2 in Clans.ByRarity[rarity.rarity] do
		Clans.Clans[k] = v2
	end
end

Clans.TestClans = require(script.Test)

for k, testClan in Clans.TestClans do
	Clans.Clans[k] = testClan
end

Clans.TEST_CLAN = "Test"

function Clans.GetClan(p: string)
	return Clans.Clans[p]
end

function Clans.GetByRarity(p: number)
	return Clans.ByRarity[p]
end

function Clans.TierOf(p: string?)
	local v2

	if p ~= nil then
		v2 = Clans.GetClan(p)
	end

	if v2 == nil then
		return nil
	end

	for _, rarity in Clans.Rarities do
		if rarity.rarity == v2.rarity then
			return rarity
		end
	end

	return nil
end

function Clans.GetAll()
	return Clans.Clans
end

function Clans.HasPassive(p: string?, p2: string)
	local v2

	if p ~= nil then
		v2 = Clans.Clans[p] or nil
	end

	if v2 == nil or v2.passives == nil then
		return false
	end

	for _, passive in v2.passives do
		if passive.name == p2 then
			return true
		end
	end

	return false
end

function Clans.BurnPassive(p: string?, p2: string?)
	local v2

	if p ~= nil then
		v2 = Clans.Clans[p] or nil
	end

	if v2 == nil or v2.passives == nil or p2 == nil then
		return nil
	end

	for _, passive in v2.passives do
		if passive.burns ~= nil and table.find(passive.burns, p2) ~= nil then
			return passive.name
		end
	end

	return nil
end

function Clans.IsImmune(p: string?, items)
	if typeof(items) == "table" then
		for _, item in items do
			if Clans.IsImmune(p, item) then
				return true
			end
		end

		return false
	else
		local v2

		if p ~= nil then
			v2 = Clans.Clans[p] or nil
		end

		if v2 == nil or v2.passives == nil then
			return false
		end

		for _, passive in v2.passives do
			local immunities = passive.immunities

			if immunities ~= nil and table.find(immunities, items) ~= nil then
				return true
			end
		end

		return Clans.Resistance(p, items) >= 1
	end
end

function Clans.Resistance(p: string?, items)
	if typeof(items) == "table" then
		local total = 0

		for _, item in items do
			total += Clans.Resistance(p, item)
		end

		return (math.clamp(total, 0, 1))
	else
		local v2

		if p ~= nil then
			v2 = Clans.Clans[p] or nil
		end

		if v2 == nil or v2.passives == nil then
			return 0
		end

		local total = 0

		for _, passive in v2.passives do
			local resistances = passive.resistances

			if resistances ~= nil and resistances[items] ~= nil then
				total += resistances[items]
			end
		end

		return (math.clamp(total, 0, 1))
	end
end

function Clans.ClanOfCharacter(instance)
	if instance == nil then
		return nil
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if playerFromCharacter == nil then
		return instance:GetAttribute("Clan")
	end

	local data = Utility.GetData(playerFromCharacter)
	local clan = data ~= nil and data:FindFirstChild("Clan") or nil
	return clan ~= nil and clan.Value or nil
end

return Clans