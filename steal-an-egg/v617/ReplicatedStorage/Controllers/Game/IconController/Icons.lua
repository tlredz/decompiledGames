local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local BossTokens = require(ReplicatedStorage.Data.Currency.Configs.BossTokens)
local Icons = {
	Preload = {},
	Main = {
		["boss-tokens"] = BossTokens.Icon
	}
}
Icons.All = TableUtil.Reconcile(Icons.Preload, Icons.Main)
return Icons