require(script.Types)
local configs = script.Configs
local AbyssOceanBat = require(configs["Abyss Ocean Bat"])
local v = {
	["Abyss Ocean Bat"] = AbyssOceanBat,
	Bat = require(configs.Bat),
	BeeLauncher = require(configs.BeeLauncher),
	BigTrap = require(configs.BigTrap)
}
local CosmicBat = require(configs["Cosmic Bat"])
v["Cosmic Bat"] = CosmicBat
local DesertBat = require(configs["Desert Bat"])
v["Desert Bat"] = DesertBat
v.Flyswatter = require(configs.Flyswatter)
local ForestBat = require(configs["Forest Bat"])
v["Forest Bat"] = ForestBat
v.GravityDisruptor = require(configs.GravityDisruptor)
local JungleBat = require(configs["Jungle Bat"])
v["Jungle Bat"] = JungleBat
v.Katana = require(configs.Katana)
local LakeBat = require(configs["Lake Bat"])
v["Lake Bat"] = LakeBat
local LightDarkStaff = require(configs["Light Dark Staff"])
v["Light Dark Staff"] = LightDarkStaff
local PrehistoricBat = require(configs["Prehistoric Bat"])
v["Prehistoric Bat"] = PrehistoricBat
local SnowBat = require(configs["Snow Bat"])
v["Snow Bat"] = SnowBat
local TheScrambler = require(configs["The Scrambler"])
v["The Scrambler"] = TheScrambler
local TitanAxe = require(configs["Titan Axe"])
v["Titan Axe"] = TitanAxe
v.Trap = require(configs.Trap)
local VolcanoBat = require(configs["Volcano Bat"])
v["Volcano Bat"] = VolcanoBat
local frozen = table.freeze(v)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local directory = require(ReplicatedStorage.Shared.Flags.BalanceConfig).Bind("Game.Balance.Gears", frozen, {
	MoneyCost = true,
	ShopDropWeight = true,
	MinShopStockQuantity = true,
	MaxShopStockQuantity = true,
	SlapPower = true,
	MaxActiveDeployments = true,
	BatControllerData = true,
	ControllerData = true,
	COOLDOWN = true,
	MAX_RANGE = true,
	MOB_DAMAGE = true,
	RAGDOLL_DURATION = true,
	SLAP_DURATION = true,
	SLAP_FORCE = true,
	DETECTION_RANGE = true,
	LIFETIME = true,
	PULL_SPEED = true,
	PULL_DURATION = true,
	MAX_PULL_DISTANCE = true,
	DANCE_DURATION = true,
	STUN_DURATION = true,
	USE_LIMIT = true
}, true, function(items)
	for _, item in items do
		local v3

		if item.MinShopStockQuantity % 1 == 0 then
			v3 = item.MaxShopStockQuantity % 1 == 0
		else
			v3 = false
		end

		assert(v3)
		assert(item.MaxShopStockQuantity >= item.MinShopStockQuantity)

		if item.MaxActiveDeployments then
			assert(item.MaxActiveDeployments % 1 == 0)
		end
	end
end)
return table.freeze({
	Directory = directory,
	GearNameExists = function(p: string)
		if rawget(directory, p) == nil then
			return false, (`Gears name "{p}" does not exist in the Gears directory.`)
		end

		return true
	end
})