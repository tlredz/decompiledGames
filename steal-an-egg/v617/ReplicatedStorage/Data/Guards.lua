require(script.Types)
local configs = script.Configs
local AbyssOcean = require(configs["Abyss Ocean"])
local CherryBlossom = require(configs["Cherry Blossom"])
local v = {
	["Abyss Ocean"] = AbyssOcean,
	["Cherry Blossom"] = CherryBlossom,
	Cosmic = require(configs.Cosmic),
	Desert = require(configs.Desert),
	Forest = require(configs.Forest),
	Jungle = require(configs.Jungle)
}
local TitanTemple = require(configs["Titan Temple"])
v["Titan Temple"] = TitanTemple
local LightDark = require(configs["Light Dark"])
v["Light Dark"] = LightDark
local LightDarkLight = require(configs["Light Dark Light"])
v["Light Dark Light"] = LightDarkLight
local LightDarkDark = require(configs["Light Dark Dark"])
v["Light Dark Dark"] = LightDarkDark
local LightDarkMixed = require(configs["Light Dark Mixed"])
v["Light Dark Mixed"] = LightDarkMixed
v.Lake = require(configs.Lake)
v.Prehistoric = require(configs.Prehistoric)
v.Snow = require(configs.Snow)
v.Volcano = require(configs.Volcano)
local frozen = table.freeze(v)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local directory = require(ReplicatedStorage.Shared.Flags.BalanceConfig).Bind("Game.Balance.Guards", frozen, {
	WalkSpeed = true,
	FlatRadius = true,
	HitDistance = true,
	EggPickupDistance = true,
	HomeImpulseBoostDistanceXZ = true
}, true, function(items)
	for _, item in items do
		local v3

		if item.WalkSpeed > 0 and item.FlatRadius > 0 then
			v3 = item.HitDistance > 0
		else
			v3 = false
		end

		assert(v3)
	end
end)
return table.freeze({
	Directory = directory,
	GuardNameExists = function(p: string)
		if rawget(directory, p) == nil then
			return false, (`Guard name "{p}" does not exist in the Guards directory.`)
		end

		return true
	end,
	GetLowestWalkSpeed = function()
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		return require(ReplicatedStorage2.Shared.Flags.GameplayBalance).GuardMovement.MIN_REFERENCE_WALK_SPEED
	end,
	GetHighestWalkSpeed = function()
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		return require(ReplicatedStorage2.Shared.Flags.GameplayBalance).GuardMovement.MAX_REFERENCE_WALK_SPEED
	end
})