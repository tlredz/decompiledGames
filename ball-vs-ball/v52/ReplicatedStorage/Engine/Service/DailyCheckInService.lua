game:GetService("ReplicatedStorage")
local CheckInService = require(script.Parent.CheckInService)
local RewardItemService = require(script.Parent.RewardItemService)
local PlayerData = require(script.Parent.PlayerData)

local function getProgress(p)
	return PlayerData.server[p].checkIn()
end

local function setProgress(p, p2)
	PlayerData.server[p].checkIn(p2)
end

local function getRewardCnId(p: number, p2)
	if p2.hasEnteredLoop then
		return (`循环七日签到{p}`)
	end

	return (`新手七日签到-{p}`)
end

local function grantReward(p, _: number, p2: string)
	return RewardItemService.grant(p, p2)
end

local function initServer()
	CheckInService.server.init({
		totalDays = 7,
		loop = true,
		getProgress = getProgress,
		setProgress = setProgress,
		getRewardCnId = getRewardCnId,
		grantReward = grantReward
	})
end

return {
	server = {
		init = initServer
	}
}