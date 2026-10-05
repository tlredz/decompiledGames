local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Shared.Analytics.ABTestExperiments.ABTestTypes)
return {
	RemoteConfig = "InstantTutorial",
	Disabled = false,
	DefaultState = false,
	States = {
		[true] = {
			Server = function(instance, aB_QuickStartTutorial)
				instance:SetAttribute("AB_QuickStartTutorial", aB_QuickStartTutorial)
				instance:SetAttribute("TutorialFrameClosed", true)
			end
		}
	}
}