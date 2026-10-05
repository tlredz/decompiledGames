local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.modules.ABTestExperiments.ABTestTypes)
return {
	RemoteConfig = "WhiteFlashShake",
	Disabled = false,
	DefaultState = game.GameId == 7431162737 or game.GameId == 6756890519,
	States = {
		[true] = {
			Server = function(instance, _)
				instance:SetAttribute("AB_WhiteFlashShake", true)
			end
		},
		[false] = {
			Server = function(instance, _)
				instance:SetAttribute("AB_WhiteFlashShake", false)
			end
		}
	}
}