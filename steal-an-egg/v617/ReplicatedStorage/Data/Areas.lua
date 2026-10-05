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
v.Lake = require(configs.Lake)
v.Prehistoric = require(configs.Prehistoric)
v.Snow = require(configs.Snow)
v.Volcano = require(configs.Volcano)
local frozen = table.freeze(v)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local directory = require(ReplicatedStorage.Shared.Flags.BalanceConfig).Bind("Game.Balance.Areas", frozen, {
	DropTable = true
}, true, function(items)
	for _, item in items do
		local total = 0

		for _, v3 in item.DropTable do
			total += v3[2]
		end

		assert(total > 0)
	end
end)
return table.freeze({
	Directory = directory,
	AreaNameExists = function(p: string)
		if rawget(directory, p) == nil then
			return false, (`Area name "{p}" does not exist in the Areas directory.`)
		end

		return true
	end
})