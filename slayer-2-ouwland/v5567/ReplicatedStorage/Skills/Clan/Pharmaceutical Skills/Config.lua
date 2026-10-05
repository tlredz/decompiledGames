local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AppliedTicks = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.AppliedTicks)
return {
	WINDUP = 0.55,
	DURATION = 12,
	VFX_LINGER = 4,
	ZONE_SIZE = vector.create(30, 25, 30),
	HEAL_RATIO = 0.2,
	OCCUPANT_VALUE = AppliedTicks.ByName["Pharmaceutical Skills"].Value
}