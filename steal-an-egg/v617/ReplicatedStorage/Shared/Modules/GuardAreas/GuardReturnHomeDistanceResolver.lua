local ReplicatedStorage = game:GetService("ReplicatedStorage")
local guardReturn = require(ReplicatedStorage.Shared.Flags.GameplayBalance).GuardReturn
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage2.Packages.t)
return {
	Resolve = function(p: string)
		t.strict(t.string)(p)
		return guardReturn.RETURN_HOME_DISTANCE_BY_AREA_ID[p] or guardReturn.DEFAULT_RETURN_HOME_DISTANCE
	end
}