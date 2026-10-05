local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.modules.ABTestExperiments.ABTestTypes)
return {
	RemoteConfig = "FirstCatchBigger",
	Disabled = false,
	DefaultState = false,
	States = {
		[true] = {
			Server = function(instance, _)
				instance:SetAttribute("AB_FirstCatchBigger", true)
			end,
			Client = function(_, _) end
		},
		[false] = {
			Server = function(instance, _)
				instance:SetAttribute("AB_FirstCatchBigger", false)
			end,
			Client = function(_, _) end
		}
	}
}