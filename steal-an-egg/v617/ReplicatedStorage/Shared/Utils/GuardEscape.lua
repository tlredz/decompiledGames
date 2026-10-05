local ReplicatedStorage = game:GetService("ReplicatedStorage")
local guardRequirements = require(ReplicatedStorage.Shared.Flags.GameplayBalance).GuardRequirements
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local GuardEscapePrediction = require(ReplicatedStorage2.Shared.Modules.GuardAreas.GuardEscapePrediction)
require(ReplicatedStorage2.Shared.Modules.GuardAreas.Types.Interface)
local TreadmillUtil = require(ReplicatedStorage2.Shared.Util.TreadmillUtil)
local t = require(ReplicatedStorage2.Packages.t)
local strict = t.strict(t.table)
return {
	RequiredSpeedPower = function(p)
		strict(p)
		local playerWalkSpeedRequirement = GuardEscapePrediction.ResolvePlayerWalkSpeedRequirement(
			p,
			guardRequirements.CARRY_SPEED_RATIO
		)
		return TreadmillUtil.RoundSpeedPowerRequirement(TreadmillUtil.WalkSpeedToSpeedPower(playerWalkSpeedRequirement) * guardRequirements.REQUIREMENT_MARGIN)
	end
}