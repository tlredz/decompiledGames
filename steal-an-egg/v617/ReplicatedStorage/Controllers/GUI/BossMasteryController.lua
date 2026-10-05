local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local BossEventFlags = require(ReplicatedStorage.Shared.Flags.BossEventFlags)
local BossMastery = require(ReplicatedStorage.Data.BossMastery)
local BossMasteryFlags = require(ReplicatedStorage.Shared.Flags.BossMasteryFlags)
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local GUI = require(ReplicatedStorage.Client.GUI)
local GamepadBindings = require(ReplicatedStorage.Client.GamepadBindings)
local MenuNavigation = require(ReplicatedStorage.Client.MenuNavigation)
local MilestoneCard = require(script.MilestoneCard)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local Numbers = require(ReplicatedStorage.Shared.Utils.Numbers)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local Trove = require(ReplicatedStorage.Packages.Trove)
local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local color = Color3.fromRGB(255, 64, 64)
local color2 = Color3.fromRGB(80, 255, 120)
return {
	Start = function()
		local frame = GUI.BossMastery().Frame
		local close = frame.Close
		local header = frame.Header
		local bossShopButton = header.BossShopButton
		local gamepadGlyph = bossShopButton.GamepadGlyph
		local amount = header.CurrencyHolder.Amount
		local infoHolder = frame.InfoHolder
		local masteryLabel = infoHolder.MasteryLabel
		local nextRewardInfoHolder = infoHolder.NextRewardInfoHolder
		local notMax = nextRewardInfoHolder.NotMax
		local max = nextRewardInfoHolder.Max
		local scrollingFrame = frame.ScrollingFrame
		local template = scrollingFrame.Template
		local maid = Trove.new()
		local v = Trove.new()
		local v2 = {}
		local v3 = {}
		local v4 = {}
		local v5 = nil
		local v6 = nil
		local v7 = nil
		maid:Add(v)
		scrollingFrame.Selectable = false
		gamepadGlyph:SetAttribute("GamepadKey", "ButtonX")
		GamepadBindings.Inspect(gamepadGlyph)
		maid:Add(ButtonFX(bossShopButton, 1.08, function()
			Tabs.Activate("BossShop")
		end))

		-- equivalent calls inferred from this helper; original call sites unknown
		local function rewardPresentation(p, p2, p3: number?)
			return BossMastery.GetRewardPresentation(p, p2, p3)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function milestonePresentation(p, revealedReward)
			return BossMastery.GetMilestonePresentation(p, revealedReward)
		end

		local function nextInfinitePresentation(p: number, p2, p3: number?)
			return rewardPresentation(BossMastery.GetInfiniteReward(), p2[BossMastery.InfiniteRevealKey(p + 1)], p3)
		end

		local function revealsOf(p)
			return p.RevealedRewards or {}
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function writeRewardCell(template2, p, visible: boolean)
			local icon = template2.Icon
			local amount2 = template2.Amount
			local completedCheckmark = template2.CompletedCheckmark
			icon.Image = p.Icon
			amount2.Text = p.Amount
			completedCheckmark.Visible = visible
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function orderedMilestones()
			local clone = table.clone(BossMastery.Milestones)
			table.sort(clone, function(a, b)
				local milestoneKills = BossMastery.GetMilestoneKills(a)
				local milestoneKills2 = BossMastery.GetMilestoneKills(b)

				if milestoneKills == milestoneKills2 then
					return a.Id < b.Id
				end

				return milestoneKills < milestoneKills2
			end)
			return clone
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function formatTokens(p: number)
			if math.abs(p) > 99999 then
				return Simple.FormatCompact(math.round(p), ".#")
			end

			return Numbers.AddCommas((math.round(p)))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function rememberMilestone(nextSelectionDown)
			v7 = nextSelectionDown
			bossShopButton.NextSelectionDown = nextSelectionDown
			close.NextSelectionDown = nextSelectionDown
		end

		local function refreshNavigation(items, flag: boolean)
			local buttons = {}

			for _, item in items do
				table.insert(buttons, v2[item.Id].Button)
			end

			local button = v2[BossMastery.InfiniteMilestoneId].Button

			if flag then
				table.insert(buttons, button)
			end

			for k, nextSelectionDown in buttons do
				nextSelectionDown:SetAttribute("DefaultFocus", k == 1)
				nextSelectionDown.NextSelectionLeft = buttons[k - 1] or bossShopButton
				nextSelectionDown.NextSelectionRight = buttons[k + 1] or close
				nextSelectionDown.NextSelectionUp = bossShopButton
				nextSelectionDown.NextSelectionDown = nextSelectionDown
			end

			local selectedObject = v7

			if selectedObject == nil or table.find(buttons, selectedObject) == nil then
				if v7 == button then
					selectedObject = buttons[#buttons]
				else
					selectedObject = buttons[1]
				end
			end

			if selectedObject then
				rememberMilestone(selectedObject) -- equivalent call inferred; original call site unknown
			end

			bossShopButton.NextSelectionLeft = bossShopButton
			bossShopButton.NextSelectionRight = close
			bossShopButton.NextSelectionUp = bossShopButton
			close.NextSelectionLeft = bossShopButton
			close.NextSelectionRight = close
			close.NextSelectionUp = close

			if not flag and GuiService.SelectedObject == button and Tabs.IsActive("BossMastery") and not (MenuNavigation.IsCursorActive() or MenuNavigation.IsSuspended()) then
				GuiService.SelectedObject = selectedObject
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setTokenText(p: number)
			local amount2 = amount
			local text = formatTokens(p) -- equivalent call inferred; original call site unknown
			amount2.Text = text
		end

		local function refreshTokenBalance(flag: boolean?)
			local v8 = Save.Await()

			if v8 == nil then
				return
			end

			local bossTokens = v8.BossTokens
			local value

			if v6 then
				value = v6.Value
			else
				value = v5
			end

			v5 = bossTokens
			v:Clean()
			v6 = nil

			if flag or value == nil or value == bossTokens then
				setTokenText(bossTokens) -- equivalent call inferred; original call site unknown
			else
				local numberValue = Instance.new("NumberValue")
				numberValue.Value = value
				v6 = numberValue
				v:Add(numberValue)
				v:Connect(numberValue.Changed, setTokenText)
				setTokenText(value) -- equivalent call inferred; original call site unknown
				local tween = TweenService:Create(numberValue, tweenInfo, {
					Value = bossTokens
				})
				v:Add(tween)
				tween:Play()
			end
		end

		local function refresh()
			if not BossEventFlags.ContentEnabled:Get() then
				return
			end

			local v8 = Save.Await()

			if v8 == nil then
				return
			end

			local bossMastery = v8.BossMastery
			local revealedRewards = bossMastery.RevealedRewards or {}
			local clone = orderedMilestones() -- equivalent call inferred; original call site unknown
			local finalMilestone = BossMastery.FinalMilestone()
			local v10 = bossMastery.ClaimedMilestoneIds[finalMilestone.Id] == true
			masteryLabel.Text = Numbers.AddCommas((math.round(bossMastery.Mastery)))
			local v11 = nil
			local v12 = nil

			for k, v13 in clone do
				local milestoneKills = BossMastery.GetMilestoneKills(v13)
				local v14 = bossMastery.ClaimedMilestoneIds[v13.Id] == true
				local v15 = assert(v2[v13.Id], (`Missing Boss Mastery card {v13.Id}`))
				local v16 = v14 and "Claimed" or milestoneKills <= bossMastery.Mastery and "Claimable" or "Locked"
				local refresh2 = v15.Refresh
				local revealedReward = revealedRewards[v13.Id]
				refresh2(milestoneKills, BossMastery.GetMilestonePresentation(v13, revealedReward), v16, k)

				if v14 or not (milestoneKills <= bossMastery.Mastery) or v12 ~= nil then
					if bossMastery.Mastery < milestoneKills and v11 == nil then
						v11 = v13
					end
				else
					v12 = v13
				end
			end

			local v13 = BossMasteryFlags.InfiniteRewardEveryKills:Get()
			local milestoneKills = BossMastery.GetMilestoneKills(finalMilestone)
			local claimableInfiniteCount = BossMastery.ClaimableInfiniteCount(bossMastery)
			local v14 = milestoneKills + (bossMastery.InfiniteRewardsClaimed + 1) * v13
			local v15 = assert(v2[BossMastery.InfiniteMilestoneId], "Missing infinite Boss Mastery card")
			local v16 = v10 and claimableInfiniteCount > 0 and "Claimable" or "Locked"
			local infiniteRewardsClaimed = bossMastery.InfiniteRewardsClaimed
			local v17 = rewardPresentation(
				BossMastery.GetInfiniteReward(),
				revealedRewards[BossMastery.InfiniteRevealKey(infiniteRewardsClaimed + 1)],
				1
			) -- equivalent call inferred; original call site unknown
			refreshNavigation(clone, v10)
			v15.SetVisible(v10)
			v15.Refresh(v14, v17, v16, #clone + 1)
			local v18 = v12 or v11

			if v18 == nil then
				local v19 = math.max(bossMastery.Mastery - milestoneKills, 0)
				local v20

				if claimableInfiniteCount > 0 then
					v20 = v13
				else
					v20 = v19 % v13
				end

				local v21 = claimableInfiniteCount > 0 and 0 or v13 - v20
				local masteryGoal = max.MasteryGoal
				notMax.Visible = false
				max.Visible = true
				masteryGoal.Text = v21 == 0 and "Reward ready" or `{Numbers.AddCommas(v21)} more`
				writeRewardCell(max.Template, v17, false) -- equivalent call inferred; original call site unknown
			else
				local masteryGoal = notMax.MasteryGoal
				local v19 = math.max(BossMastery.GetMilestoneKills(v18) - bossMastery.Mastery, 0)
				notMax.Visible = true
				max.Visible = false
				masteryGoal.Text = v19 == 0 and "Reward ready" or `{Numbers.AddCommas(v19)} more`
				local template2 = notMax.Template
				local v20 = milestonePresentation(v18, revealedRewards[v18.Id]) -- equivalent call inferred; original call site unknown
				writeRewardCell(template2, v20, bossMastery.ClaimedMilestoneIds[v18.Id] == true) -- equivalent call inferred; original call site unknown
			end
		end

		local function readyRewards()
			local v8 = Save.Await()

			if v8 == nil then
				return {}
			end

			local bossMastery = v8.BossMastery
			local revealedRewards = bossMastery.RevealedRewards or {}
			local result = {}

			for _, milestone in BossMastery.Milestones do
				if not (bossMastery.Mastery >= BossMastery.GetMilestoneKills(milestone)) or bossMastery.ClaimedMilestoneIds[milestone.Id] then
					continue
				end

				local v9 = {
					Key = milestone.Id,
					Icon = 0
				}
				local revealedReward = revealedRewards[milestone.Id]
				v9.Icon = BossMastery.GetMilestonePresentation(milestone, revealedReward).Icon
				table.insert(result, v9)
			end

			local claimableInfiniteCount = BossMastery.ClaimableInfiniteCount(bossMastery)

			for i = bossMastery.InfiniteRewardsClaimed + 1, bossMastery.InfiniteRewardsClaimed + claimableInfiniteCount do
				local v9 = {
					Key = `{BossMastery.InfiniteMilestoneId}:{i}`,
					Icon = 0
				}
				local infiniteReward = BossMastery.GetInfiniteReward()
				local revealedReward = revealedRewards[BossMastery.InfiniteRevealKey(i)]
				v9.Icon = BossMastery.GetRewardPresentation(infiniteReward, revealedReward, nil).Icon
				table.insert(result, v9)
			end

			return result
		end

		local function updateReadyRewardNotification()
			if not BossEventFlags.ContentEnabled:Get() then
				return
			end

			local v8 = readyRewards()

			if Tabs.IsActive("BossMastery") then
				for _, v9 in v8 do
					v4[v9.Key] = true
				end
			else
				local v9 = {}

				for _, v10 in v8 do
					if v4[v10.Key] then
						continue
					end

					v4[v10.Key] = true
					table.insert(v9, v10)
				end

				if #v9 == 0 then
					return
				end

				local count = #v8
				Toast.Show({
					Text = count == 1 and "You have a Boss Mastery reward ready to claim!" or `You have {count} Boss Mastery rewards ready to claim!`,
					Seconds = 3,
					Color = color2,
					Image = v9[1].Icon,
					SingleLine = true
				})
			end
		end

		local function showClaimResult(p: string, flag: boolean, value: string?, p2: number?)
			local v8 = Save.Await()
			local bossMastery

			if v8 then
				bossMastery = v8.BossMastery
			end

			local v9 = not bossMastery and {} or bossMastery.RevealedRewards or {}
			local milestone = BossMastery.GetMilestone(p)
			local v10

			if milestone == nil then
				local v11 = p2 or not bossMastery and 1 or bossMastery.InfiniteRewardsClaimed + 1
				local infiniteReward = BossMastery.GetInfiniteReward()
				local v12 = v9[BossMastery.InfiniteRevealKey(v11)]
				v10 = BossMastery.GetRewardPresentation(infiniteReward, v12, nil)
			else
				local v11 = v9[milestone.Id]
				v10 = BossMastery.GetMilestonePresentation(milestone, v11)
			end

			local show = Toast.Show
			local v11 = {
				Text = flag and "Boss Mastery reward claimed!" or value or "Claim failed",
				Seconds = 2.5,
				Color = 0,
				Image = 0,
				SingleLine = true
			}
			local color3

			if flag then
				color3 = color2
			else
				color3 = color
			end

			v11.Color = color3
			v11.Image = v10.Icon
			show(v11)
		end

		local function requestClaim(p: string, controller)
			if v3[p] then
				return
			end

			local v8 = Save.Await()

			if v8 == nil then
				return
			end

			local bossMastery = v8.BossMastery
			local milestone = BossMastery.GetMilestone(p)

			if milestone then
				if bossMastery.ClaimedMilestoneIds[p] or bossMastery.Mastery < BossMastery.GetMilestoneKills(milestone) then
					return
				end
			elseif p ~= BossMastery.InfiniteMilestoneId or not bossMastery.ClaimedMilestoneIds[BossMastery.FinalMilestone().Id] or BossMastery.ClaimableInfiniteCount(bossMastery) <= 0 then
				return
			end

			local rewardIndex

			if p == BossMastery.InfiniteMilestoneId then
				rewardIndex = v8.BossMastery.InfiniteRewardsClaimed + 1
			end

			v3[p] = {
				Controller = controller,
				RewardIndex = rewardIndex
			}
			controller.SetPending(true)
			local success, result, v10 = pcall(function()
				return Remotes.BossMastery.AskClaimMilestone:InvokeServer(p)
			end)
			v3[p] = nil
			controller.SetPending(false)

			if success and result then
				refresh()
				showClaimResult(p, true, v10, rewardIndex)
			elseif success then
				showClaimResult(p, false, v10, rewardIndex)
			else
				showClaimResult(p, false, "Something went wrong, please try again.", rewardIndex)
			end
		end

		template.Visible = false

		for _, milestone in BossMastery.Milestones do
			local v8 = MilestoneCard.New(template, scrollingFrame, milestone.Id, requestClaim)
			v2[milestone.Id] = v8
			maid:Add(v8.Button.SelectionGained:Connect(function()
				if not MenuNavigation.IsCursorActive() then
					rememberMilestone(v8.Button) -- equivalent call inferred; original call site unknown
				end
			end))
			maid:Add(v8.Destroy)
		end

		local v8 = MilestoneCard.New(template, scrollingFrame, BossMastery.InfiniteMilestoneId, requestClaim)
		v2[BossMastery.InfiniteMilestoneId] = v8
		maid:Add(v8.Button.SelectionGained:Connect(function()
			if not MenuNavigation.IsCursorActive() then
				rememberMilestone(v8.Button) -- equivalent call inferred; original call site unknown
			end
		end))
		maid:Add(v8.Destroy)
		Save.Await()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function onCatalogChanged()
			refresh()
			updateReadyRewardNotification()
		end

		refresh()
		local v9 = Save.Await()

		if v9 ~= nil then
			local bossTokens = v9.BossTokens

			if v6 then
				local _ = v6.Value
			end

			v5 = bossTokens
			v:Clean()
			v6 = nil
			local text = formatTokens(bossTokens) -- equivalent call inferred; original call site unknown
			amount.Text = text
		end

		updateReadyRewardNotification()
		maid:Add(Save.WatchFields("BossMastery", function()
			onCatalogChanged() -- equivalent call inferred; original call site unknown
		end))
		maid:Add(Save.WatchFields("BossTokens", function()
			refreshTokenBalance()
		end))
		maid:Add(BossMasteryFlags.MilestoneKillOverrides.Changed:Connect(onCatalogChanged))
		maid:Add(BossMasteryFlags.MilestoneRewardIdOverrides.Changed:Connect(onCatalogChanged))
		maid:Add(BossMasteryFlags.TokenBoostPercentOverrides.Changed:Connect(onCatalogChanged))
		maid:Add(BossMasteryFlags.InfiniteRewardEveryKills.Changed:Connect(onCatalogChanged))
		maid:Add(BossMasteryFlags.InfiniteRewardId.Changed:Connect(onCatalogChanged))
		maid:Add(BossMasteryFlags.InfiniteBannerWeights.Changed:Connect(onCatalogChanged))
		maid:Add(Tabs.Activated:Connect(function(p: string)
			if p == "BossMastery" then
				refresh()
				local v10 = Save.Await()

				if v10 ~= nil then
					local bossTokens = v10.BossTokens

					if v6 then
						local _ = v6.Value
					end

					v5 = bossTokens
					v:Clean()
					v6 = nil
					setTokenText(bossTokens) -- equivalent call inferred; original call site unknown
				end

				updateReadyRewardNotification()
			end
		end))
		return maid
	end
}