local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
return {
	BASELINE_RELEASE_VERSION = 1,
	BASELINE_MEDIA_COUNT = 246,
	CURRENT_RELEASE_VERSION = 3,
	ResolveEntryReleaseVersion = function(p: number)
		t.strict(t.intersection(t.integer, t.numberPositive))(p)
		return p
	end
}