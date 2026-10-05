local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.modules.ABTestExperiments.ABTestTypes)
return {
	RemoteConfig = "NewDialogueUI",
	Disabled = false,
	DefaultState = false,
	States = {
		[true] = {
			Client = function(instance, _)
				instance:SetAttribute("UseNewDialogueUI", true)
			end
		},
		[false] = {
			Client = function(instance, _)
				instance:SetAttribute("UseNewDialogueUI", false)
			end
		}
	}
}