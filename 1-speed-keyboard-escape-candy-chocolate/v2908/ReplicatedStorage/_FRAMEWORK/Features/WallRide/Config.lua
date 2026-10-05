local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage._FRAMEWORK.Libraries.wallRide.Types)
return {
	overrides = {
		speedRatio = 1,
		maxRideSpeed = 300,
		slideGrace = 0.4,
		slideAcceleration = 22,
		maxFallSpeed = 45,
		maxRideDuration = 2.5,
		minEntrySpeed = 14,
		maxHorizontalSpeed = 340,
		tiltAngle = -18
	}
}