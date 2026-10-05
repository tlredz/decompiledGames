local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Data.Rarity)
local configs = script.Configs
local modules = {
	AngelicTreadmill = require(configs.AngelicTreadmill),
	AstralTreadmill = require(configs.AstralTreadmill),
	CelebrityTreadmill = require(configs.CelebrityTreadmill),
	DemonicTreadmill = require(configs.DemonicTreadmill),
	FlameTreadmill = require(configs.FlameTreadmill),
	GoldenTreadmill = require(configs.GoldenTreadmill),
	HackerTreadmill = require(configs.HackerTreadmill)
}
local LuckyBlockTreadmill = require(configs["Lucky BlockTreadmill"])
modules["Lucky BlockTreadmill"] = LuckyBlockTreadmill
local SciFiTreadmill = require(configs["Sci-FiTreadmill"])
modules["Sci-FiTreadmill"] = SciFiTreadmill
local TheFreezeTreadmill = require(configs["The FreezeTreadmill"])
modules["The FreezeTreadmill"] = TheFreezeTreadmill
modules.Treadmill = require(configs.Treadmill)
table.freeze(modules)
local v2 = {}
local v3 = {}

for _, v4 in pairs(modules) do
	table.insert(v2, v4)
end

table.sort(v2, function(a, b)
	return a.Price < b.Price
end)

for i, v4 in ipairs(v2) do
	v3[v4._id] = i
end

local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local directory = require(ReplicatedStorage2.Shared.Flags.BalanceConfig).Bind("Game.Balance.Treadmills", modules, {
	Price = true,
	SpeedMultiplier = true
}, true, function(items)
	for _, item in items do
		assert(item.SpeedMultiplier > 0)
	end
end)

for k, v5 in v2 do
	v2[k] = directory[v5._id]
end

table.freeze(v2)
table.freeze(v3)
return table.freeze({
	Directory = directory,
	TreadmillNameExists = function(p: string)
		if directory[p] == nil then
			return false, (`Treadmills name "{p}" does not exist in the Treadmills directory.`)
		end

		return true
	end,
	GetOrdered = function()
		return table.clone(v2)
	end,
	GetByUpgradeLevel = function(p: number)
		return v2[p]
	end,
	GetUpgradeLevel = function(p: string)
		return v3[p]
	end
})