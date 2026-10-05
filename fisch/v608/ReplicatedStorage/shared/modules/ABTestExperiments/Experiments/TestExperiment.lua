local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.modules.ABTestExperiments.ABTestTypes)
return {
	RemoteConfig = "Test",
	Disabled = false,
	DefaultState = false,
	States = {
		[true] = {
			Server = function(_, _) end,
			Client = function(_, _) end
		},
		[false] = {
			Server = function(_, _) end,
			Client = function(_, _) end
		}
	}
}