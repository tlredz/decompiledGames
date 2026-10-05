local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local EclipseOrbitAnimation = require(ReplicatedStorage.Shared.EclipseOrbitAnimation)
Observers.observeTag("EclipseOrbit", function(model)
	if model:IsA("Model") then
		return EclipseOrbitAnimation.Bind(model)
	end

	return nil
end, { workspace })