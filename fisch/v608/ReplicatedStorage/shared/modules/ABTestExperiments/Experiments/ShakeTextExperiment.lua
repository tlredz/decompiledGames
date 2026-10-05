local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.modules.ABTestExperiments.ABTestTypes)
return {
	RemoteConfig = "ShakeText",
	Disabled = false,
	DefaultState = game.GameId == 6756890519,
	States = {
		[true] = {
			Server = function(instance, _)
				instance:SetAttribute("AB_ShakeText", true)
			end
		},
		[false] = {
			Server = function(instance, _)
				instance:SetAttribute("AB_ShakeText", false)
			end
		}
	}
}