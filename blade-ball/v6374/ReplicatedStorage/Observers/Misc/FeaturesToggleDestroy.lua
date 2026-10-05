local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local featuresToggle = ReplicatedStorage.FeaturesToggle
return Observers.observeTagNoAncestry("FeaturesToggleDestroy", function(instance)
	local featureEnvironment = instance:GetAttribute("FeatureEnvironment")

	if not featureEnvironment then
		warn((`Tag with no FeatureEnvironment {instance:GetFullName()}`))
		return
	end

	local child = featuresToggle:FindFirstChild(featureEnvironment)

	if child and not child.Value then
		task.defer(instance.Destroy, instance)
	end
end)