local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AppliedTicks = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.AppliedTicks)
return {
	TICK_VALUE = AppliedTicks.ByName.Poison.Value,
	POISON_DURATION = 3,
	MAX_HEALTH_RATIO = 0.02,
	MIN_DAMAGE = 1
}