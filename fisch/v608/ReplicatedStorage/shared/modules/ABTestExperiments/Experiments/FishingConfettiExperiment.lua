local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.modules.ABTestExperiments.ABTestTypes)
return {
	RemoteConfig = "FishingConfetti",
	Disabled = false,
	DefaultState = false,
	States = {
		[true] = {
			Server = function(instance, _)
				instance:SetAttribute("AB_FishingConfetti", true)
			end,
			Client = function(_, _) end
		},
		[false] = {
			Server = function(instance, _)
				instance:SetAttribute("AB_FishingConfetti", false)
			end,
			Client = function(_, _) end
		}
	}
}