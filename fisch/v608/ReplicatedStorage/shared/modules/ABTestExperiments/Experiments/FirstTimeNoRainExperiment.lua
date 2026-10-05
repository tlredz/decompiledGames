local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.modules.ABTestExperiments.ABTestTypes)
return {
	RemoteConfig = "FirstTimeNoRain",
	Disabled = false,
	DefaultState = false,
	States = {
		[true] = {
			Server = function(instance, _)
				instance:SetAttribute("FirstTimeNoRainExperiment", true)
			end,
			Client = function(_, _) end
		},
		[false] = {
			Server = function(instance, _)
				instance:SetAttribute("FirstTimeNoRainExperiment", false)
			end,
			Client = function(_, _) end
		}
	}
}