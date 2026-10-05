local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage._FRAMEWORK.Libraries.wallClimb.Types)
return {
	overrides = {
		blockedStates = { Enum.HumanoidStateType.Physics },
		maxWallHeight = 60,
		heightOvershoot = 3,
		heightBoostRatio = 1,
		minBoostSpeed = 0,
		maxBoostSpeed = 0,
		wallPushSpeed = 6,
		probeDistance = 3,
		absorbImpact = true,
		absorbClearance = 1.5
	}
}