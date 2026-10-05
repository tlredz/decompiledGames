local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GameConstants = require(ReplicatedStorage.Modules.Shared.Game.GameConstants)
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local v = game.GameId == GameConstants.GameIds.QA.QA6
return {
	isAvailable = function()
		if v then
			return true
		end

		return not (RunService:IsStudio() or GameUtil.isLiveGame())
	end
}