local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage._FRAMEWORK.Libraries.gravityController.Types)
return {
	fallKillDistance = 600,
	landingOvershoot = 50,
	unfollowedFolderNames = { "Keycaps" },
	overrides = {
		maxTravelSeconds = 0.8
	}
}