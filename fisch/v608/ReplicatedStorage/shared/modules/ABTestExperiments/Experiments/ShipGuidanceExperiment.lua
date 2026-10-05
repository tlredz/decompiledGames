local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.modules.ABTestExperiments.ABTestTypes)
return {
	RemoteConfig = "ShipGuidance",
	Disabled = true,
	DefaultState = false,
	States = {
		[true] = {
			Server = function(instance, _)
				instance:SetAttribute("ABShipGuidance", true)
			end
		},
		[false] = {
			Server = function(instance, _)
				instance:SetAttribute("ABShipGuidance", false)
			end
		}
	}
}