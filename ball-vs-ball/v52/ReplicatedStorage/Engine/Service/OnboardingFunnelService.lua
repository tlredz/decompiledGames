local AnalyticsService = game:GetService("AnalyticsService")
local v = {
	"加入游戏",
	"领取新手小球",
	"成功上桌",
	"对战开始",
	"首次选择小球",
	"对局结束",
	"购买小球箱子"
}
return {
	ref = {
		Step = {
			JoinedGame = 1,
			ClaimedStarterBall = 2,
			SatAtTable = 3,
			MatchStarted = 4,
			FirstBallSelected = 5,
			MatchFinished = 6,
			PurchasedCrate = 7
		}
	},
	server = {
		log = function(p, p2: number)
			local v2 = v[p2]

			if not v2 then
				warn((`[新手漏斗] 无效步骤：{p2}`))
				return
			end

			print((`[新手漏斗] 玩家={p.Name} | Step={p2} | {v2}`))
			local success, result = pcall(function()
				AnalyticsService:LogOnboardingFunnelStepEvent(p, p2, v2)
			end)

			if not success then
				warn((`[新手漏斗] 上报失败：{p.Name} | Step={p2} | {result}`))
			end
		end
	}
}