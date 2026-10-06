local RunService = game:GetService("RunService")
local v

if RunService:IsStudio() then
	local player = game.Players:FindFirstChildWhichIsA("Player") or game.Players.PlayerAdded:Wait()
	local _ = player.Name == "FriesOverEverything"
	v = player.Name:match("^Player%d$") ~= nil
end

return {
	studioOnly = {
		["强制服务器"] = "默认",
		["跳过新手送球"] = false,
		["跳过每日签到"] = false,
		["发全球"] = false,
		["解锁交易等级"] = false,
		["读存档"] = false
	},
	serialRegistry = {
		maxRequestsPerMinute = 30,
		retryAttempts = 3,
		retryDelaySeconds = 30
	},
	feature = {
		["小球合成"] = true,
		["编号登记"] = true,
		["每日钻石"] = false,
		["每日纯钻石"] = true,
		["在线奖励"] = true,
		["每日签到"] = true,
		["弹保持连胜"] = false,
		["交易服"] = false,
		["全服抽奖活动"] = false,
		["消费周榜奖励"] = true
	}
}