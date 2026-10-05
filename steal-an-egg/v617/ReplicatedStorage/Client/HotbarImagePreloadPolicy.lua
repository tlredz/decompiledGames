local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuardAreaGeometry = require(ReplicatedStorage.Shared.Util.GuardAreaGeometry)
local t = require(ReplicatedStorage.Packages.t)
local strict = t.strict(t.instanceIsA("BasePart"))
local strict2 = t.strict(t.Vector3)
local strict3 = t.strict(t.number)
local strict4 = t.strict(t.optional(t.number))
local v = {
	CLAIM_PRELOAD_DISTANCE_STUDS = 50,
	GetShortestDistanceToClaimLine = function(p, vector: Vector3)
		strict(p)
		strict2(vector)
		return (math.abs((GuardAreaGeometry.SignedDistanceToLine(p, vector))))
	end,
	IsSpeedEligible = function(p: number, p2: number?)
		strict3(p)
		strict4(p2)
		return p2 ~= nil and p2 <= p
	end
}

function v.IsWithinClaimPreloadDistance(p: number)
	strict3(p)
	return p < v.CLAIM_PRELOAD_DISTANCE_STUDS
end

function v.ShouldPreloadCarriedEgg(p: number, p2: number?, p3: number?)
	strict4(p3)
	local isSpeedEligible = v.IsSpeedEligible(p, p2)

	if not isSpeedEligible then
		if p3 == nil then
			isSpeedEligible = false
		else
			isSpeedEligible = v.IsWithinClaimPreloadDistance(p3)
		end
	end

	return isSpeedEligible
end

return table.freeze(v)