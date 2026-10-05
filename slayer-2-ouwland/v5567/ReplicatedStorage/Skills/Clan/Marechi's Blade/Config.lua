local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AppliedTicks = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.AppliedTicks)
return {
	SELF_DAMAGE_RATIO = 0.1,
	TICK_VALUE = AppliedTicks.ByName.Poison.Value,
	TICK_DAMAGE = 3,
	TICK_DURATION = 3
}