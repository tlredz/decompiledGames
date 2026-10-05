local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.modules.ABTestExperiments.ABTestTypes)
return {
	RemoteConfig = "FishingAidMobile",
	Disabled = false,
	DefaultState = false,
	States = {
		[true] = {
			Server = function(instance, _)
				instance:SetAttribute("ABTest_FishingAidMobile", true)
			end
		},
		[false] = {
			Server = function(instance, _)
				instance:SetAttribute("ABTest_FishingAidMobile", nil)
			end
		}
	}
}