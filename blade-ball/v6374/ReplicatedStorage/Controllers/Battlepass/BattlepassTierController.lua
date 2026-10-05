local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Packages.Signal)
require3(ReplicatedStorage2.Packages.Observers)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Packages.Net)
local v4 = require3(ReplicatedStorage2.Packages.Charm)
local v5 = require3(ReplicatedStorage2.Controllers.Battlepass.BattlepassViewController)
local v6 = require3(ReplicatedStorage2.Controllers.GiftingController)
local v7 = require3(ReplicatedStorage2.Controllers.UI.GlobalMessageController)
require3(ReplicatedStorage2.Shared.BattlepassUIType)
local v8 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v9 = require3("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local v10 = require3("./Components/VirtualHorizontalScroll")
local v11 = require3("@game/ReplicatedStorage/Shared/ReplionUtils")
local v12 = require3(ReplicatedStorage2.Shared.Battlepass.BattlepassSelectionCrate)
local v13 = require3(ReplicatedStorage2.Shared.SeasonPassData)
require3(ReplicatedStorage2.Shared.SeasonPassSkip)
local v14 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
require3(ReplicatedStorage2.Controllers.ShowRoomController)
require3(ReplicatedStorage2.Common.MarketplaceService)
local v15 = require3(ReplicatedStorage2.Common.Utils)
local v16 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local v17 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v18 = require3(ReplicatedStorage2.Controllers.Trading.IndexController)
local v19 = require3(ReplicatedStorage2.Shared.BattlepassUIType)
local v20 = require3(script.PurchaseLevelContainer)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local background = playerGui:WaitForChild("Battlepass").Main.Background
local bottomProgress

if v19 ~= "Window" then
	bottomProgress = background.BottomProgress
end

if v19 ~= "Window" then
	local _ = bottomProgress.Page
end

if v19 ~= "Window" then
	local _ = bottomProgress.PageCounter
end

if v19 ~= "Window" then
	local _ = bottomProgress.NextPage
end

if v19 ~= "Window" then
	local _ = bottomProgress.PreviousPage
end

local battlepassBuyLevels = playerGui:WaitForChild("BattlepassBuyLevels")
local battlepassPremium = playerGui:WaitForChild("BattlepassPremium")
local _ = v.TouchEnabled
local v21 = nil
local seasonData = v9.SeasonData
local _ = workspace.CurrentCamera
return {
	Start = function(self)
		v21 = v2.Client:WaitReplion("Data")
		v20:SetFrame(battlepassBuyLevels.BuyLevels)
		v20:Start()
		battlepassBuyLevels.BuyLevels.Close.Activated:Connect(function()
			battlepassBuyLevels.Enabled = false
			v20:Close()
		end)
		background.Tier.Label.About.Activated:Connect(function()
			battlepassBuyLevels.Enabled = true
			v20:Open()
		end)

		local function buyPremiumBattlepass()
			if not v21:Get("InfiniteBattlepass.Premium") then
				v16:PromptPurchase(v13.SeasonPassProductId, Enum.InfoType.Product)
			end
		end

		v14(battlepassPremium.NewPass.Buy.Price, v13.SeasonPassProductId, "DevProduct", "Buy  %s")
		battlepassPremium.NewPass.Buy.Activated:Connect(buyPremiumBattlepass)
		local seasonPassTemplate = battlepassPremium.NewPass.ScrollingFrame.SeasonPassTemplate
		seasonPassTemplate.Parent = nil

		local function closePremiumTab()
			battlepassPremium.Enabled = false
		end

		battlepassPremium.NewPass.Close.Activated:Connect(closePremiumTab)
		battlepassPremium.NewPass.Details.Activated:Connect(closePremiumTab)
		background.Left.Leaderboard.Activated:Connect(function()
			v5:OpenView("TopTiersRewards")
		end)
		background.Left.BuyPremiumPassButton.Activated:Connect(function()
			if v21:Get("InfiniteBattlepass.Premium") then
				v6:SetGift("PremiumSeasonPass")
			else
				battlepassPremium.Enabled = true
			end
		end)
		background.Left.GiftButton.Activated:Connect(function()
			v6:SetGift("PremiumSeasonPass")
		end)
		battlepassPremium.NewPass.Gift.Activated:Connect(function()
			v6:SetGift("PremiumSeasonPass")
		end)

		local function openSelectionCrate()
			v5:Close()
			v8:Open("BattlepassSelectionCrate")
		end

		local grandReward = background.BottomProgress.GrandReward
		grandReward.PremiumRewardTemplate.Activated:Connect(openSelectionCrate)
		grandReward.FreeRewardTemplate.Activated:Connect(openSelectionCrate)
		background.Left.ClaimAll.Activated:Connect(function()
			if v3:Invoke("InfiniteBattlepass/ClaimAll") then
				return
			end

			ReplicatedStorage2.Misc.error:Play()
		end)
		local atom = v11.atom(v21, "InfiniteBattlepass.Quests.XP")
		local atom2 = v11.atom(v21, "InfiniteBattlepass.Claimed")
		local atom3 = v11.atom(v21, "InfiniteBattlepass.Premium")
		local currentTier = v4.computed(function()
			local v22 = atom() or 0
			return seasonData.Rewards.getTierFromXP(v22)
		end)
		local computed2 = v4.computed(function()
			if not seasonData.Rewards.fixed then
				return nil
			end

			local v22 = currentTier()
			local v23 = atom3() == true
			local v24 = nil
			local v25 = nil

			for k, v26 in seasonData.Rewards.fixed do
				local v27

				if v23 then
					if v26.premium == nil then
						v27 = false
					else
						v27 = v26.premium.Type == "BattlepassSelectionCrate"
					end
				else
					v27 = v23
				end

				local v28

				if v26.free == nil then
					v28 = false
				else
					v28 = v26.free.Type == "BattlepassSelectionCrate"
				end

				if not (v28 or v27) then
					continue
				end

				local v29 = {
					tier = k,
					rewardType = v27 and "Premium" or "Free"
				}

				if not v24 or v24.tier < k then
					v24 = v29
				end

				if v22 < k and (not v25 or k < v25.tier) then
					v25 = v29
				end
			end

			return v25 or v24
		end)
		local computed3 = v4.computed(function()
			local v22 = currentTier()
			local v23 = atom2()
			local v24 = atom3()
			local count = 0

			for i = 1, v22 do
				local reward = seasonData.Rewards.getReward(i, localPlayer)

				if not reward then
					continue
				end

				local free = reward.free
				local premium = reward.premium
				local v25 = not free or v23.Free[tostring(i)] == true
				local v26 = not v24 or not premium or v23.Premium[tostring(i)] == true

				if not v25 then
					count += 1
				end

				if not v24 or v26 then
					continue
				end

				count += 1
			end

			return count
		end)
		v4.effect(function()
			local v22 = computed3()
			background.Left.ClaimAll.Visible = v22 > 0
		end)
		v4.effect(function()
			local v22 = currentTier()
			local v23 = atom() or 0
			local v24 = computed2()

			if not v24 then
				grandReward.Visible = false
				return
			end

			local tier = v24.tier
			local rewardType = v24.rewardType
			local reward = seasonData.Rewards.getReward(tier, localPlayer)
			local v25 = reward and reward[string.lower(rewardType)]

			if not v25 then
				grandReward.Visible = false
				return
			end

			grandReward.FreeRewardTemplate.Visible = rewardType == "Free"
			grandReward.PremiumRewardTemplate.Visible = rewardType == "Premium"
			grandReward.Visible = true
			local child = grandReward:FindFirstChild((`{rewardType}RewardTemplate`))
			child.MainVector.Image = v25.Icon or v15.Icons:GetIcon("DEFAULT_MISSING")

			for k, v26 in v12[rewardType == "Free" and "Normal" or "Premium"] do
				if typeof(v26) == "function" then
					v26 = v26(localPlayer)
				end

				if not v26 then
					continue
				end

				local child2 = child:FindFirstChild((`Vector{k}`))

				if child2 then
					child2.Image = v26.Icon or v15.Icons:GetIcon("DEFAULT_MISSING")
				end
			end

			local fill = child.ProgressBar.Fill
			local v26 = v23 / reward.xp
			local v27 = math.clamp(v26, 0, 1) * 0.85 + 0.15
			fill.Size = UDim2.fromScale(v27, 1)
			fill.Visible = v26 > 0
			local unlockTier = child.ProgressBar:FindFirstChild("UnlockTier")

			if unlockTier then
				unlockTier.Text = `Tier {math.min(v22, tier)}/{tier}`
			end

			if v19 == "Window" then
				child.ProgressBar.Visible = true
				child.Button.Visible = false
			end
		end)
		v4.effect(function()
			local v22 = atom3()
			background.Left.BuyPremiumPassButton.TextLabel.Text = v22 and "GIFT PREMIUM" or "BUY PREMIUM"
			background.Left.GiftButton.Visible = not v22
			local v23 = currentTier() + 10
			local v24 = assert(seasonData.Rewards.getReward(v23, localPlayer))
			local v25 = assert(v24.premium or v24.free)
			battlepassPremium.NewPass.PremiumReward.Unlock.Text = `Lv. {v23} Unlock`
			battlepassPremium.NewPass.PremiumReward.Reward.ItemName.Text = v25.DisplayName or ""
			battlepassPremium.NewPass.PremiumReward.Vector.Image = v25.Icon or ""

			if v17:CanShowRewardInfo(v25) then
				v17:AddFromRewardInfo(battlepassPremium.NewPass.PremiumReward, v25)
			end

			battlepassPremium.NewPass.PremiumIcon.Image = v15.Icons:GetIcon("BattlepassPremium") or v15.Icons:GetIcon("BattlepassTierSkip")
			battlepassPremium.NewPass.PremiumBonus.Vector.Image = v15.Icons:GetIcon("BattlepassTierSkip")
			background.BottomLogo.Image = v15.Icons:GetIcon("BattlepassPremium") or v15.Icons:GetIcon("BattlepassTierSkip")
			background.BottomLogo.Lock.Visible = not v22
			background.TopLogo.Image = v15.Icons:GetIcon("BattlepassTierSkip")
		end)
		local v22 = {}
		local v23 = {}
		v4.effect(function()
			local v24 = currentTier()
			local v25 = math.max(v24, 1)
			local v26 = v24 + 10

			for k, v27 in v22 do
				if v25 < k or k < v26 then
					continue
				end

				v22[k] = nil
				v17:Remove(v27)
				v17:Remove(v27.ImageButton)
				table.insert(v23, v27)
			end

			for i = v25, v26 do
				local clone = v22[i] or table.remove(v23)

				if not clone then
					clone = seasonPassTemplate:Clone()
					clone.Parent = battlepassPremium.NewPass.ScrollingFrame
				end

				assert(clone)
				local reward = seasonData.Rewards.getReward(i)

				if not reward then
					continue
				end

				if reward.free then
					clone.ImageButton.ImageLabel.Image = reward.free.Icon or v15.Icons:GetIcon("DEFAULT_MISSING")
					clone.ImageButton.Visible = true

					if v17:CanShowRewardInfo(reward.free) then
						v17:AddFromRewardInfo(clone.ImageButton, reward.free)
					end
				else
					clone.ImageButton.Visible = false
					v17:Remove(clone.ImageButton)
				end

				if reward.premium then
					clone.ImageLabel.Image = reward.premium.Icon or v15.Icons:GetIcon("DEFAULT_MISSING")
					clone.ImageLabel.Visible = true

					if v17:CanShowRewardInfo(reward.premium) then
						v17:AddFromRewardInfo(clone, reward.premium)
					end
				else
					clone.ImageLabel.Visible = false
				end

				clone.LayoutOrder = i
			end
		end)
		local v24 = currentTier()
		local v25 = false
		v4.effect(function()
			local v26 = currentTier()
			local v27 = atom() or 0
			local v28

			if v26 > 0 then
				v28 = seasonData.Rewards.getReward(v26) or nil
			end

			local reward = seasonData.Rewards.getReward(v26 + 1)
			local xp = v28 and v28.xp or 0
			local xp2 = reward and reward.xp or 0
			local v29 = v27 - xp
			local v30 = xp2 - xp
			local v31 = not (v30 > 0) and 1 or v29 / v30 or 1
			background.Tier.Label.Xp.Text = `{v29}/{v30}`
			background.Tier.Label.TierLevel.Text = `Tier {v26}`
			background.Tier.Label.ProgressBar.FillHolder.Fill:TweenSize(
				UDim2.fromScale(v31, 1),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Sine,
				0.5,
				true
			)

			if v26 ~= v24 then
				v25 = true
				v24 = v26
			end

			for _, frame in background.Left.BuySkipsList:GetChildren() do
				if not frame:IsA("Frame") then
					continue
				end

				local v32 = tonumber(string.match(frame.Name, "(%d+)"))
				local skipButton = frame:FindFirstChild("SkipButton")

				if not skipButton then
					continue
				end

				local v33 = v32 == 1 and "Skip" or "Skips"
				skipButton.Label.Text = `Buy {v32} {v33}`
			end
		end)

		local function tryClaimReward(p: number, p2: string)
			return (v3:Invoke("InfiniteBattlepass/Claim", p, p2))
		end

		local v26 = v10({
			container = background.Scroll,
			template = background.Scroll.Template,
			currentTier = currentTier,
			buffer = 0,
			getTierData = seasonData.Rewards.getReward,
			render = function(p, data, instance)
				instance.ProgressBar.Circle.TextLabel.Text = p
				instance.Name = p
				local free = data.free
				local premium = data.premium
				local computed4 = v4.computed(function()
					local v27 = currentTier()

					if p <= v27 then
						return 1
					end

					if v27 + 1 ~= p then
						return 0
					end

					local v28 = atom() or 0
					local xp

					if v27 >= 1 then
						local reward = v9.SeasonData.Rewards.getReward(v27, localPlayer)
						xp = reward and reward.xp or 0
					else
						xp = 0
					end

					return (v28 - xp) / (data.xp - xp)
				end)
				local effectScope = v4.effectScope(function()
					v4.effect(function()
						local v27 = atom2()
						local v28 = atom3() == true
						local v29 = computed4()
						local v30 = v29 == 1
						local visible = free and v27.Free[tostring(p)] == true
						local visible2 = premium and v27.Premium[tostring(p)] == true
						instance.Free.ClaimedFrame.Visible = visible
						instance.Premium.Square.ClaimedFrame.Visible = visible2
						instance.Premium.Square.Locked.Visible = not v28 and premium
						instance.ProgressBar.Fill.Size = UDim2.fromScale(v29, 1)
						local activatedConnection = nil
						local activatedConnection2 = nil

						if visible or not (v30 and free) then
							instance.Claim.Visible = false
						else
							instance.Claim.Visible = true
							activatedConnection = instance.Claim.Activated:Connect(function()
								if not v3:Invoke("InfiniteBattlepass/Claim", p, "Free") then
									ReplicatedStorage2.Misc.error:Play()
								end
							end)
						end

						if visible2 or not (v30 and premium and v28) then
							instance.Premium.Claim.Visible = false
						else
							instance.Premium.Claim.Visible = true
							activatedConnection2 = instance.Premium.Claim.Activated:Connect(function()
								if not v3:Invoke("InfiniteBattlepass/Claim", p, "Premium") then
									ReplicatedStorage2.Misc.error:Play()
								end
							end)
						end

						return function()
							if activatedConnection then
								activatedConnection:Disconnect()
							end

							if activatedConnection2 then
								activatedConnection2:Disconnect()
							end
						end
					end)
				end, true)

				if free then
					instance.Free.ItemIcon.Image = free.Icon or v15.Icons:GetIcon("DEFAULT_MISSING")
					instance.Free.AmountHolder.Label.Text = free.DisplayName or "???"
					instance.Free.Visible = true

					if v17:CanShowRewardInfo(free) then
						v17:AddFromRewardInfo(instance.Free, free)
					end
				else
					instance.Free.Visible = false
				end

				if premium then
					instance.Premium.Square.ItemIcon.Image = premium.Icon or v15.Icons:GetIcon("DEFAULT_MISSING")
					instance.Premium.Square.AmountHolder.Label.Text = premium.DisplayName or "???"
					instance.Premium.Visible = true

					if v17:CanShowRewardInfo(premium) then
						v17:AddFromRewardInfo(instance.Premium, premium)
					end
				else
					instance.Premium.Visible = false
				end

				local activatedConnection = nil
				local activatedConnection2 = nil
				local inspect = instance:FindFirstChild("Inspect")
				local v27 = free and v18:CanPreview(free)

				if free and inspect and v27 then
					inspect.Visible = true
					activatedConnection = inspect.Activated:Connect(function()
						v18:PreviewReward(free, nil)
					end)
				elseif inspect then
					inspect.Visible = false
				end

				local inspect2 = instance.Premium:FindFirstChild("Inspect")
				local v28 = premium and v18:CanPreview(premium)

				if premium and inspect2 and v28 then
					inspect2.Visible = true
					activatedConnection2 = inspect2.Activated:Connect(function()
						v18:PreviewReward(premium, nil)
					end)
				elseif inspect2 then
					inspect2.Visible = false
				end

				return function()
					v17:Remove(instance.Free)
					v17:Remove(instance.Premium)

					if activatedConnection then
						activatedConnection:Disconnect()
					end

					if activatedConnection2 then
						activatedConnection2:Disconnect()
					end

					activatedConnection = nil
					activatedConnection2 = nil
					effectScope()
				end
			end
		})
		local flag = true
		v8:OnGuiOpen("Battlepass", function()
			if flag then
				flag = false
				task.wait(0.05)
			end

			v26.scrollToCurrent(true)
		end)

		local function checkRewardsToNotification()
			local v27 = computed3()

			if v27 == 0 then
				return
			end

			task.spawn(function()
				v7:DisplayMessage({
					Message = `You have {v27} unclaimed reward{v27 > 1 and "s" or ""} in the Battlepass!`,
					Duration = 5,
					Caller = localPlayer.Name
				})
			end)
		end

		task.delay(5, checkRewardsToNotification)
	end
}