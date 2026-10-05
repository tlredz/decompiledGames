local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.modules.ABTestExperiments.ABTestTypes)
return {
	RemoteConfig = "SellTextEligible",
	Disabled = false,
	DefaultState = game.GameId == 6756890519,
	States = {
		[true] = {
			Server = function(instance, _)
				instance:SetAttribute("AB_SellTextScreenElegible", true)
			end
		},
		[false] = {
			Server = function(instance, _)
				instance:SetAttribute("AB_SellTextScreenElegible", false)
			end
		}
	}
}