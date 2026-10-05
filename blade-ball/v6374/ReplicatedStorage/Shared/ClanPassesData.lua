local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)(script.Parent.Parent.Common.RewardInfo)
local ClanPassesData = {
	Rewards = {
		Monthly = {
			Extra = 10,
			FirstSubscriptionBonus = { v.createClanPointsReward(90, "rbxassetid://15636184218") },
			DaysDuration = 30,
			Total = 0,
			TotalIcon = "rbxassetid://15636184218",
			ProductId = 1708274980,
			Instant = { v.createClanPointsReward(400, "rbxassetid://15636248286") },
			Daily = { v.createClanPointsReward(200, "rbxassetid://15636248286") }
		},
		Weekly = {
			Extra = 3,
			DaysDuration = 7,
			Total = 0,
			TotalIcon = "rbxassetid://15636184218",
			ProductId = 1708274791,
			Instant = { v.createClanPointsReward(200, "rbxassetid://15636248286") },
			Daily = { v.createClanPointsReward(100, "rbxassetid://15636248286") }
		}
	}
}
ClanPassesData.Rewards.Monthly.Total = ClanPassesData.Rewards.Monthly.Instant[1].Value + ClanPassesData.Rewards.Monthly.DaysDuration * ClanPassesData.Rewards.Monthly.Daily[1].Value
ClanPassesData.Rewards.Weekly.Total = ClanPassesData.Rewards.Weekly.Instant[1].Value + ClanPassesData.Rewards.Weekly.DaysDuration * ClanPassesData.Rewards.Weekly.Daily[1].Value
return ClanPassesData