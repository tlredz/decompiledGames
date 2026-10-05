local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.modules.ABTestExperiments.ABTestTypes)
return {
	RemoteConfig = "NewPlayerServers",
	Disabled = false,
	DefaultState = true,
	States = {
		[true] = {
			Server = function(instance, _)
				instance:SetAttribute("ABTest_NewPlayerServers", true)
				instance:SetAttribute("ABTest_NewPlayerServersSet", true)
			end,
			Client = function(_, _) end
		},
		[false] = {
			Server = function(instance, _)
				instance:SetAttribute("ABTest_NewPlayerServers", false)
				instance:SetAttribute("ABTest_NewPlayerServersSet", true)
			end,
			Client = function(_, _) end
		}
	}
}