local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.modules.ABTestExperiments.ABTestTypes)
return {
	RemoteConfig = "ToggleQuestsView",
	Disabled = false,
	DefaultState = game.GameId == 7431162737,
	States = {
		[true] = {
			Server = function(instance, _)
				instance:SetAttribute("AB_ToggleQuestsViewExperiment", true)
			end
		},
		[false] = {
			Server = function(instance, _)
				instance:SetAttribute("AB_ToggleQuestsViewExperiment", false)
			end
		}
	}
}