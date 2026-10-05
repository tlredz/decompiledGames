local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local playerGui = Players.LocalPlayer.PlayerGui
local v = nil
local v2 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local v3 = require3(ReplicatedStorage2.Packages.Net)
local v4 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Signal)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v5 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
local v6 = require3(ReplicatedStorage2.Shared.Easter.EggHunt)
local v7 = require3(ReplicatedStorage2.Shared.Easter.DailyRewards)
local v8 = require3(ReplicatedStorage2.Controllers.Easter.EasterPageController)
local remoteFunction = v3:RemoteFunction("ClaimEasterDailyStreak")
local dailyRewards = playerGui:WaitForChild("EasterEvent"):WaitForChild("Overview"):WaitForChild("Views"):WaitForChild("DailyRewards")
local clonesByStreak = {}
local rewardTemplate = dailyRewards.List.RewardTemplate
rewardTemplate.Parent = nil
local EasterDailyRewardsController = {
	Init = function(_)
		v8:RegisterPage("DailyRewards", dailyRewards)
	end,
	Start = function(_)
		v = v4.Client:WaitReplion("Data")
		dailyRewards.BottomButtons.ClaimAllButton.MouseButton1Click:Connect(function()
			remoteFunction:InvokeServer()
		end)
		v:OnChange("EasterEvent", UpdateDailyRewards)
		local easterEvent = v:Get("EasterEvent")

		if easterEvent then
			UpdateDailyRewards(easterEvent)
		end

		v5(dailyRewards.BottomButtons.UnlockButton.Label, v6.PremiumRewardsProductId, "DevProduct", "Unlock :robux:%s")

		if v:Get("EasterEvent.PremiumRewardsUnlocked") then
			SetPremiumPass()
			return
		end

		local mouseButton1ClickConnection = dailyRewards.BottomButtons.UnlockButton.MouseButton1Click:Connect(function()
			v2:PromptPurchase(v6.PremiumRewardsProductId, Enum.InfoType.Product)
		end)
		local connection = nil
		connection = v:OnChange("EasterEvent.PremiumRewardsUnlocked", function(p)
			if p then
				connection:Disconnect()
				mouseButton1ClickConnection:Disconnect()
				SetPremiumPass()
			end
		end)
	end
}

function SetPremiumPass()
	for _, v9 in ipairs(CollectionService:GetTagged("EasterPremiumRewardsUnlocked")) do
		v9:Destroy()
	end

	dailyRewards.BottomButtons.UnlockButton.Visible = false
end

function UpdateDailyRewards(p)
	local premiumRewardsUnlocked = p.PremiumRewardsUnlocked or false

	for _, v9 in ipairs(v7) do
		local clone = clonesByStreak[v9.Streak]

		if not clone then
			clone = rewardTemplate:Clone()
			clone.Day.TextLabel.Text = `Day {v9.Streak}`

			if v9.FreeReward then
				clone.Free.Vector.Image = v9.FreeReward.Icon or ""
				clone.Free.Amount.Text = v9.FreeReward.DisplayName
			end

			if v9.PremiumReward then
				clone.Premium.Vector.Image = v9.PremiumReward.Icon or ""
				clone.Premium.Amount.Text = v9.PremiumReward.DisplayName
			end

			clone.LayoutOrder = v9.Streak
			clone.Parent = dailyRewards.List
			clonesByStreak[v9.Streak] = clone
		end

		if not clone then
			continue
		end

		local formatted = `Free{v9.Streak}`
		local formatted2 = `Premium{v9.Streak}`
		local easterClaimedStreak = p.EasterClaimedStreaks[formatted2]
		clone.Premium.Claimable.Visible = premiumRewardsUnlocked and not easterClaimedStreak
		clone.Premium.Claimed.Visible = premiumRewardsUnlocked and easterClaimedStreak
		clone.Premium.Check.Visible = premiumRewardsUnlocked and easterClaimedStreak
		local easterClaimedStreak2 = p.EasterClaimedStreaks[formatted]
		clone.Free.Claimable.Visible = not easterClaimedStreak2
		clone.Free.Claimed.Visible = easterClaimedStreak2
		clone.Free.Check.Visible = easterClaimedStreak2
	end
end

return EasterDailyRewardsController