local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Shared.Analytics.ABTestExperiments.ABTestTypes)
return {
	RemoteConfig = "HideTutorialUI",
	Disabled = false,
	DefaultState = false,
	States = {
		[true] = {
			Client = function(instance, aB_HideTutorialUI)
				instance:SetAttribute("AB_HideTutorialUI", aB_HideTutorialUI)
				instance:SetAttribute("TutorialFrameClosed", true)
			end
		}
	}
}