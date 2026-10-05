local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.modules.ABTestExperiments.ABTestTypes)
return {
	RemoteConfig = "GamepadEasyShake",
	Disabled = false,
	DefaultState = false,
	States = {
		[true] = {
			Server = function(instance, _)
				instance:SetAttribute("GamepadEasyShake", true)
			end
		},
		[false] = {
			Server = function(instance, _)
				instance:SetAttribute("GamepadEasyShake", false)
			end
		}
	}
}