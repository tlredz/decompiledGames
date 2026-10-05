local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.modules.ABTestExperiments.ABTestTypes)
return {
	RemoteConfig = "FakeTradeAB",
	Disabled = false,
	DefaultState = game.GameId == 7431162737 or game.GameId == 6756890519,
	States = {
		[true] = {
			Server = function(instance, _)
				instance:SetAttribute("FakeTradeAB", true)
			end
		},
		[false] = {
			Server = function(instance, _)
				instance:SetAttribute("FakeTradeAB", false)
			end
		}
	}
}