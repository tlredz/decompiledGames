local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Shared.Analytics.ABTestExperiments.ABTestTypes)
return {
	RemoteConfig = "ExtraParryRange",
	Disabled = false,
	DefaultState = false,
	States = {
		[true] = {
			Server = function(instance, _)
				instance:SetAttribute("IncreasedParryRangeEnabled", true)
			end
		}
	}
}