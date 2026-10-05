local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.modules.ABTestExperiments.ABTestTypes)
return {
	RemoteConfig = "Misclicking",
	Disabled = false,
	DefaultState = game.GameId == 6756890519,
	States = {
		[true] = {
			Server = function(instance, _)
				instance:SetAttribute("MisclickingExperiment", true)
			end
		},
		[false] = {
			Server = function(instance, _)
				instance:SetAttribute("MisclickingExperiment", false)
			end
		}
	}
}