local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Guards = require(ReplicatedStorage.Data.Guards)
local MonsterParasite = require(ReplicatedStorage.Data.MonsterParasite)
local TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
return table.freeze({
	IsEligible = function(p: number)
		local v = Guards.Directory[MonsterParasite.EligibilityGuardId]
		return v ~= nil and TreadmillUtil.SpeedPowerToWalkSpeed(p) >= v.WalkSpeed
	end
})