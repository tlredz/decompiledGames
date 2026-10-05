local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Shared.MonthlyLeaderboardRewards)
local v2 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v3 = require3(ReplicatedStorage2.Shared.GetCountryFlagEmoji)
require3(ReplicatedStorage2.Common.RewardInfo)
local v4 = require3(ReplicatedStorage2.Packages.Replion)
local v5 = require3(ReplicatedStorage2.Common.Utils)
local v6 = require3(ReplicatedStorage2.Packages.Net)
local localPlayer = Players.LocalPlayer
local monthlyLeaderboardRewards = localPlayer.PlayerGui.MonthlyLeaderboardRewards
local window = monthlyLeaderboardRewards.Window
local rewardTemplate = window.RewardList.UIListLayout.RewardTemplate
local remoteEvent = v6:RemoteEvent("ReceiveMonthlyLeaderboardRewards")
local MonthlyLeaderboardRewardsController = {}

function MonthlyLeaderboardRewardsController:Open(p, p2)
	local v7 = v4.Client:WaitReplion("Data")
	local v8 = v[p]

	if not v8 then
		warn((`Failed to find MonthlyLeaderboard rewards for {p}!`))
		return
	end

	local v9 = v3(v7:GetExpect("Country"))
	window.LeaderboardName.Text = `Monthly Wins ({v9})`
	window.Placement.Text = `<stroke color="rgb(0,0,0)" joins="miter" thickness="2">You placed <font color="rgb(255,25,25)">#{v5.ValueConvertor:AddCommas(p2)}</font> and won:</stroke>`

	for _, guiObject in window.RewardList:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	for _, v10 in v8 do
		if v10.Rank < p2 then
			continue
		end

		local clone = rewardTemplate:Clone()
		clone.Icon.Image = v10.Reward.Icon
		clone.NameLabel.Text = `Top {v5.ValueConvertor:AddCommas(v10.Rank)}`
		v2:AddFromRewardInfo(clone, v10.Reward)
		clone.Parent = window.RewardList
	end

	while localPlayer.Character and localPlayer.Character.Parent == workspace.Alive do
		task.wait(1)
	end

	monthlyLeaderboardRewards.Enabled = true
end

function MonthlyLeaderboardRewardsController:Start()
	window.ClaimButton.Activated:Connect(function()
		monthlyLeaderboardRewards.Enabled = false
		SoundService.SFX.LTMSpin_ClaimSpins:Play()
	end)
	remoteEvent.OnClientEvent:Connect(function(p: string, p2: number)
		self:Open(p, p2)
	end)
end

return MonthlyLeaderboardRewardsController