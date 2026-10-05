local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage._FRAMEWORK.Libraries.rayDebug.Types)
return {
	enabledInStudio = false,
	systemColors = {
		wallClimb = Color3.fromRGB(96, 224, 128),
		wallRide = Color3.fromRGB(96, 200, 255),
		reverseGravity = Color3.fromRGB(200, 130, 255),
		gravityController = Color3.fromRGB(255, 190, 90),
		gravityZone = Color3.fromRGB(255, 128, 132)
	},
	overrides = {
		thickness = 0.1,
		markerSize = 0.3,
		maxParts = 128
	}
}