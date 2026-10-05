local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AAEventWinAward = require(ReplicatedStorage._FRAMEWORK.Libraries.AAEventWinAward)
return {
	create = function(source: string, multiplier: number?)
		assert(RunService:IsServer(), "MeleeRagdollTool.Reward.create is server-only")
		local v = AAEventWinAward.create({
			source = source,
			multiplier = multiplier
		})
		return function(p3)
			v(p3)
		end
	end
}