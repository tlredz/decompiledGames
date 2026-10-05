local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.modules.ABTestExperiments.ABTestTypes)
return {
	RemoteConfig = "QuickBoats",
	Disabled = false,
	DefaultState = false,
	States = {
		fast = {
			Server = function(instance, _)
				instance:SetAttribute("ABTest_QuickBoats", 3)
			end,
			Client = function(_, _) end
		},
		slow = {
			Server = function(instance, _)
				instance:SetAttribute("ABTest_QuickBoats", 7)
			end,
			Client = function(_, _) end
		},
		[false] = {
			Server = function(instance, _)
				instance:SetAttribute("ABTest_QuickBoats", false)
			end,
			Client = function(_, _) end
		}
	}
}