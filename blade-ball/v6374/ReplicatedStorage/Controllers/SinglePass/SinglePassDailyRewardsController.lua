local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("CollectionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Common.Utils.Utilities.Thread)
local v3 = require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
local v4 = require3(ReplicatedStorage2.Shared.CNYEvent.CNYEventItemData)
require3(ReplicatedStorage2.Common.MarketplaceService)
local v5 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
local v6 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local playerGui = Players.LocalPlayer.PlayerGui
local dailyRewards = v4.DailyRewards
local remoteFunction = v:RemoteFunction("CNYEvent_ClaimDailyLogin")
local frame = playerGui.SinglePass.MainFrame.Main.Pages.DailyRewards.Frame
local rewardTemplate = frame.List.RewardTemplate
rewardTemplate.Parent = nil
local clones = {}

function UpdateRewardTile(layoutOrder: number, p: number, flag: boolean, p2)
	local dailyReward = dailyRewards[layoutOrder]
	local visible = p2.Free[layoutOrder]
	local v8 = layoutOrder <= p
	local visible2 = p2.Exclusive[layoutOrder]
	local v10

	if layoutOrder <= p then
		v10 = flag
	else
		v10 = false
	end

	local clone = clones[layoutOrder]

	if not clone then
		clone = rewardTemplate:Clone()
		clone.LayoutOrder = layoutOrder
		clone.Day.TextLabel.Text = `Day {layoutOrder}`

		if not visible then
			clone.Free.Claim.Activated:Connect(function()
				if remoteFunction:InvokeServer(layoutOrder, false) then
					SoundService.SFX.LTMSpin_ClaimSpins:Play()
				end
			end)
		end

		if not visible2 then
			clone.Premium.Claim.Activated:Connect(function()
				if remoteFunction:InvokeServer(layoutOrder, true) then
					SoundService.SFX.LTMSpin_ClaimSpins:Play()
				end
			end)
		end

		if dailyReward.Reward then
			clone.Free.Vector.Image = dailyReward.Reward.Icon or ""
			clone.Free.Amount.Text = dailyReward.Reward.DisplayName
			clone.Free.Visible = true
		else
			clone.Free.Visible = false
		end

		if dailyReward.ExclusiveReward then
			clone.Premium.Vector.Image = dailyReward.ExclusiveReward.Icon or ""
			clone.Premium.Amount.Text = dailyReward.ExclusiveReward.DisplayName
			clone.Premium.Visible = true
		else
			clone.Premium.Visible = false
		end

		clone.Parent = frame.List
		table.insert(clones, clone)
	end

	if clone then
		clone.Free.Claim.Visible = not visible and v8
		clone.Free.Claimed.Visible = visible
		clone.Premium.Claim.Visible = not visible2 and v10
		clone.Premium.Claimed.Visible = visible2
		clone.Premium.LockIcon.Visible = not flag
	end
end

function UpdateFinalReward()
	local dailyReward = dailyRewards[#dailyRewards]

	if dailyReward then
		local leftReward = frame.LeftReward
		leftReward.Vector.Image = dailyReward.ExclusiveReward.Icon or ""
		leftReward.RewardLabel.Text = dailyReward.ExclusiveReward.DisplayName
	end
end

function UpdateAllRewardTiles()
	local cNYEvent = v2.Client:WaitReplion("Data"):Get("CNYEvent")

	if not cNYEvent then
		return
	end

	local dailyLoginStreak = cNYEvent.DailyLoginStreak or 1
	local claimedDailyRewards = cNYEvent.ClaimedDailyRewards or {
		Free = {},
		Exclusive = {}
	}
	local exclusiveDailyRewardBundle = cNYEvent.ExclusiveDailyRewardBundle or false

	for i = 1, #dailyRewards do
		UpdateRewardTile(i, dailyLoginStreak, exclusiveDailyRewardBundle, claimedDailyRewards)
	end

	UpdateFinalReward()
	frame.RewardsList.PremiumPass.LockedCover.Visible = not exclusiveDailyRewardBundle
	frame.BottomButtons.UnlockButton.Visible = not exclusiveDailyRewardBundle
	frame.Fade.Visible = not exclusiveDailyRewardBundle
end

return {
	Start = function(_)
		for _, guiObject in frame.List:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject:Destroy()
			end
		end

		local v7 = v2.Client:WaitReplion("Data")
		v7:OnChange("CNYEvent.ExclusiveDailyRewardBundle", UpdateAllRewardTiles)
		v7:OnChange("CNYEvent.ClaimedDailyRewards", UpdateAllRewardTiles)
		v7:OnChange("CNYEvent.DailyLoginStreak", UpdateAllRewardTiles)
		UpdateAllRewardTiles()
		local activatedConnection = nil
		activatedConnection = frame.BottomButtons.UnlockButton.Activated:Connect(function()
			if not v7:Get("CNYEvent.ExclusiveDailyRewardBundle") then
				v6:PromptPurchase(2662022702, Enum.InfoType.Product)
				return
			end

			activatedConnection:Disconnect()
			_G.SendNotification("You already purchased this!")
		end)
		v5(frame.BottomButtons.UnlockButton.Label, 2662022702, "DevProduct", "Unlock :robux:%s")
		local flag = false
		frame.BottomButtons.ClaimAllButton.Activated:Connect(function()
			if flag then
				return
			end

			flag = true
			local v8 = v7:Get("CNYEvent.ExclusiveDailyRewardBundle")
			local v9 = {}

			for i, v10 in ipairs(clones) do
				if v10.Free.Claim.Visible then
					table.insert(v9, {
						position = i,
						premium = false
					})
				end

				if v8 and v10.Premium.Claim.Visible then
					table.insert(v9, {
						position = i,
						premium = true
					})
				end
			end

			local count = 0

			for _, v10 in ipairs(v9) do
				if remoteFunction:InvokeServer(v10.position, v10.premium) then
					count += 1
				end
			end

			if count >= 1 then
				SoundService.SFX.LTMSpin_ClaimSpins:Play()
			end

			task.wait(0.5)
			flag = false
		end)
		frame.Fade.TextLabel.Text = `Get +{v3:AddCommas(v4.ExclusiveCurrencyReward)}`
	end
}