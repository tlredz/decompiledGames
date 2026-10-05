local Data = require(script.Data)
local Rolls = require(script.Rolls)
local Effects = require(script.Effects)
return table.freeze({
	GetAuras = Data.GetAuras,
	FindAura = Data.FindAura,
	Update = Effects.Update,
	BindEffect = Effects.BindEffect,
	AuraAdded = Data.AuraAdded,
	AuraRemoved = Data.AuraRemoved,
	EquipAura = Rolls.EquipAura,
	RenewRolls = Rolls.RenewRolls,
	AuraRolled = Rolls.AuraRolled,
	RollForAura = Rolls.RollForAura
})