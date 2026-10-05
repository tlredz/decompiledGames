local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ExclusionZones = require(ReplicatedStorage.Modules.Shared.Exclusion.ExclusionZones)
return {
	GetRestrictedEntryDistance = ExclusionZones.GetRestrictedEntryDistance,
	IsPointRestricted = ExclusionZones.IsPointRestricted,
	FrameworkStart = function()
		ExclusionZones.start()
	end
}