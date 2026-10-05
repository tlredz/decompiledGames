local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.modules.ABTestExperiments.ABTestTypes)
return {
	RemoteConfig = "ABReturnIsland",
	Disabled = false,
	DefaultState = game.GameId == 6756890519 or game.GameId == 7431162737,
	States = {
		[true] = {
			Server = function(instance, _)
				instance:SetAttribute("ABReturnIsland", true)
			end
		},
		[false] = {
			Server = function(instance, _)
				instance:SetAttribute("ABReturnIsland", false)
			end
		}
	}
}