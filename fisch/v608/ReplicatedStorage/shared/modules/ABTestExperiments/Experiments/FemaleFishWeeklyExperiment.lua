local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.modules.ABTestExperiments.ABTestTypes)
return {
	RemoteConfig = "FemaleAbV2",
	Disabled = false,
	DefaultState = false,
	States = {
		[true] = {
			Server = function(instance, _)
				instance:SetAttribute("FemaleAbV2", true)
			end
		},
		[false] = {
			Server = function(instance, _)
				instance:SetAttribute("FemaleAbV2", false)
			end
		}
	}
}