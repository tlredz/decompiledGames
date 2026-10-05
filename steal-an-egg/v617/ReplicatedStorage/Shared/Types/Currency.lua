local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local v = { "BossTokens", "Money", "SakuraCrystals" }
return table.freeze({
	AllCurrencyTypes = table.freeze({
		BossTokens = "BossTokens",
		Money = "Money",
		SakuraCrystals = "SakuraCrystals"
	}),
	AllCurrencyTypesArray = table.freeze(v),
	SchemaValidation = table.freeze({
		AllCurrencyTypes = t.valueOf(v)
	})
})