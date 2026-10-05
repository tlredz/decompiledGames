local Workspace = game:GetService("Workspace")
local Config = {
	Range = 15,
	HitTolerance = 2,
	TargetViewSamplePadding = 0.05,
	MaximumTargetViewAge = 0.35,
	DragonEggEventHitboxScalar = 2.5,
	DragonEggEventActiveAttribute = "DragonEggEventActive"
}

function Config.GetHitboxScalar()
	if Workspace:GetAttribute(Config.DragonEggEventActiveAttribute) == true then
		return Config.DragonEggEventHitboxScalar
	end

	return 1
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
Config = require(ReplicatedStorage.Shared.Flags.BalanceConfig).Bind("Game.Balance.BatCombat", Config, {
	Range = true,
	HitTolerance = true,
	DragonEggEventHitboxScalar = true
}, false)
return Config