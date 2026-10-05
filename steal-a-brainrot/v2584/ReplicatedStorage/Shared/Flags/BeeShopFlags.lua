local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local replicated = FastFlags.Replicated("Game.BeeShop.Enabled", Asserts.Boolean, true)
local replicated2 = FastFlags.Replicated("Game.BeeShop.LuckyBlockEndTimer", Asserts.IntegerPositive, 1789239600)
local replicated3 = FastFlags.Replicated("Game.BeeShop.BaseEndTimer", Asserts.IntegerPositive, 1789239600)
local replicated4 = FastFlags.Replicated("Game.BeeShop.GearEndTimer", Asserts.IntegerPositive, 1789239600)
return table.freeze({
	Enabled = replicated,
	LuckyBlockEndTimer = replicated2,
	BaseEndTimer = replicated3,
	GearEndTimer = replicated4
})