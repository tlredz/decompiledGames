local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local GUI = require(ReplicatedStorage.Client.GUI)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local GamepadBindings = require(ReplicatedStorage.Client.GamepadBindings)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Numbers = require(ReplicatedStorage.Shared.Utils.Numbers)
local addCommas = Numbers.AddCommas
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local ScrambleMastery = require(ReplicatedStorage.Data.ScrambleMastery)
local Assets = require(ReplicatedStorage.Data.Assets)
local MilestoneCard = require(ReplicatedStorage.Controllers.GUI.BossMasteryController.MilestoneCard)
local color = Color3.fromRGB(80, 255, 120)
local color2 = Color3.fromRGB(255, 64, 64)
local frozen = table.freeze({
	[10] = "10KillsSkin",
	[25] = "25KillsSkin",
	[50] = "50KillsSkin",
	[75] = "75KillsSkin",
	[100] = "100KillsSkin"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function toast(text: string, color3: Color3, icon: string?)
	Toast.Show({
		Text = text,
		Seconds = 3,
		Color = color3,
		Image = icon,
		SingleLine = true,
		Unique = true
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rewardOf(p: string)
	local milestone = ScrambleMastery.GetMilestone(p)

	if milestone then
		return milestone.Reward
	end

	return ScrambleMastery.InfiniteReward
end

return {
	new = function(callback, callback2)
		local v = {}
		local maid = Trove.new()
		local maid2 = maid:Add(Trove.new())
		local scrambleBossMastery = GUI.Get("ScrambleBossMastery")
		local frame = scrambleBossMastery.Frame
		local bossShopButton = frame.Header.BossShopButton
		local amount = frame.Header.CurrencyHolder.Amount
		local infoHolder = frame.InfoHolder
		local notMax = infoHolder.NextRewardInfoHolder.NotMax
		local max = infoHolder.NextRewardInfoHolder.Max
		local scrollingFrame = frame.ScrollingFrame
		local template = scrollingFrame.Template
		local nextRewardIcon = frame.NextRewardIcon
		local v2 = nil
		local icon = nextRewardIcon.Icon
		local v3 = {}
		local v4 = {}
		local v5 = nil
		local flag = true
		local v6 = false

		local function available()
			return v5 ~= nil and v5.Ready == true and v5.Enabled == true and v5.WorldReady == true and workspace:GetServerTimeNow() < (v5.EventEndsAt or 0)
		end

		local function refreshNextReward()
			nextRewardIcon.Visible = false
			v2 = nil

			if flag then
				local v7

				if v5 == nil or v5.Ready ~= true or v5.Enabled ~= true or v5.WorldReady ~= true then
					v7 = false
				else
					v7 = workspace:GetServerTimeNow() < (v5.EventEndsAt or 0)
				end

				if v7 and scrambleBossMastery.Enabled and frame.Visible and scrollingFrame.Visible then
					local state = v5.State

					if not state then
						return
					end

					for _, milestone in ScrambleMastery.Milestones do
						if milestone.Reward.Kind ~= "Pet" or state.ClaimedMilestoneIds[milestone.Id] == true or state.Mastery >= milestone.Kills then
							continue
						end

						local parent = v3[milestone.Id].Button.Parent
						local absolutePosition = parent.AbsolutePosition
						local absoluteSize = parent.AbsoluteSize
						local absolutePosition2 = scrollingFrame.AbsolutePosition
						local absoluteWindowSize = scrollingFrame.AbsoluteWindowSize

						if not parent.Visible or absoluteSize.X <= 0 or absoluteSize.Y <= 0 or absoluteWindowSize.X <= 0 or absoluteWindowSize.Y <= 0 then
							return
						end

						local v8 = absolutePosition.X >= absolutePosition2.X + absoluteWindowSize.X
						local v9 = scrollingFrame.CanvasPosition.X + absoluteWindowSize.X < scrollingFrame.AbsoluteCanvasSize.X - 1
						icon.Image = Assets.Directory[milestone.Reward.Category].Icon
						nextRewardIcon.Visible = v8 and v9

						if not nextRewardIcon.Visible then
							parent = nil
						end

						v2 = parent
						return
					end

					return
				end
			end

			maid2:Clean()
		end

		local function scrollToNextReward()
			refreshNextReward()
			local v7 = v2

			if v7 == nil then
				return
			end

			maid2:Clean()
			local X = scrollingFrame.AbsoluteWindowSize.X
			local v8 = scrollingFrame.CanvasPosition.X + v7.AbsolutePosition.X - scrollingFrame.AbsolutePosition.X - (X - v7.AbsoluteSize.X) / 2
			local v9 = math.max(0, scrollingFrame.AbsoluteCanvasSize.X - X)
			local tween = TweenService:Create(
				scrollingFrame,
				TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					CanvasPosition = Vector2.new(math.clamp(v8, 0, v9), scrollingFrame.CanvasPosition.Y)
				}
			)
			maid2:Add(function()
				tween:Cancel()
				tween:Destroy()
			end)
			tween:Play()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshCanvas()
			local uIListLayout = scrollingFrame.UIListLayout
			local v7 = uIListLayout.Padding.Scale * scrollingFrame.AbsoluteSize.X + uIListLayout.Padding.Offset
			scrollingFrame.CanvasSize = UDim2.fromOffset(math.ceil(uIListLayout.AbsoluteContentSize.X + v7), 0)
			refreshNextReward()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function writeChip(chip, p)
			local presentation = ScrambleMastery.Presentation(p)
			chip.Visible = true
			chip.Icon.Image = presentation.Icon
			chip.Amount.Text = presentation.Amount
			chip.CompletedCheckmark.Visible = false
		end

		local function refresh()
			local state = v5 and v5.State

			if not (flag and state) then
				return
			end

			amount.Text = addCommas(state.Samples)
			infoHolder.MasteryLabel.Text = addCommas(state.Mastery)
			local v7 = nil

			for k, milestone in ScrambleMastery.Milestones do
				local v8 = state.ClaimedMilestoneIds[milestone.Id] == true
				local v9 = v8 and "Claimed" or state.Mastery >= milestone.Kills and "Claimable" or "Locked"
				v3[milestone.Id].Refresh(milestone.Kills, ScrambleMastery.Presentation(milestone.Reward), v9, k)

				if v7 ~= nil or v8 then
					continue
				end

				v7 = milestone
			end

			local finalMilestone = ScrambleMastery.FinalMilestone()
			local v8 = state.ClaimedMilestoneIds[finalMilestone.Id] == true
			local claimableInfiniteCount = ScrambleMastery.ClaimableInfiniteCount(state)
			local v9 = v3[ScrambleMastery.InfiniteMilestoneId]
			v9.SetVisible(v8)
			v9.Refresh(
				finalMilestone.Kills + (state.InfiniteRewardsClaimed + 1) * ScrambleMastery.InfiniteEveryKills,
				ScrambleMastery.Presentation(ScrambleMastery.InfiniteReward),
				v8 and claimableInfiniteCount > 0 and "Claimable" or "Locked",
				#ScrambleMastery.Milestones + 1
			)
			local notMax2 = notMax
			local max2 = max
			local visible = v7 ~= nil
			local visible2 = v7 == nil
			notMax2.Visible = visible
			max2.Visible = visible2

			if v7 then
				local v14 = math.max(v7.Kills - state.Mastery, 0)
				notMax.MasteryGoal.Text = v14 == 0 and "Reward ready" or `{addCommas(v14)} more`
				writeChip(notMax.RewardHolder.Chip, v7.Reward) -- equivalent call inferred; original call site unknown
			else
				local v14 = math.max(state.Mastery - finalMilestone.Kills, 0)
				local v15 = claimableInfiniteCount > 0 and 0 or ScrambleMastery.InfiniteEveryKills - v14 % ScrambleMastery.InfiniteEveryKills
				max.MasteryGoal.Text = v15 == 0 and "Reward ready" or `{addCommas(v15)} more`
				writeChip(max.RewardHolder.Chip, ScrambleMastery.InfiniteReward) -- equivalent call inferred; original call site unknown
			end

			refreshNextReward()
		end

		local function notifyReady()
			local state = v5 and v5.State

			if not state then
				return
			end

			local v7 = {}

			for _, milestone in ScrambleMastery.Milestones do
				if not (state.Mastery >= milestone.Kills) or state.ClaimedMilestoneIds[milestone.Id] then
					continue
				end

				table.insert(v7, milestone.Id)
			end

			local v8 = state.InfiniteRewardsClaimed + 1

			for i = v8, v8 + ScrambleMastery.ClaimableInfiniteCount(state) - 1 do
				table.insert(v7, (`{ScrambleMastery.InfiniteMilestoneId}:{i}`))
			end

			local v9 = nil

			for _, v10 in v7 do
				if v4[v10] then
					continue
				end

				v4[v10] = true
				v9 = v9 or v10
			end

			if v9 and not Tabs.IsActive("ScrambleBossMastery") then
				local v11 = rewardOf(string.split(v9, ":")[1]) -- equivalent call inferred; original call site unknown
				toast(
					#v7 == 1 and "You have a Scramble Mastery reward ready to claim!" or `You have {#v7} Scramble Mastery rewards ready to claim!`,
					color,
					ScrambleMastery.Presentation(v11).Icon
				) -- equivalent call inferred; original call site unknown
			end
		end

		local function claim(p: string, p2)
			if not v6 then
				local v7

				if v5 == nil or v5.Ready ~= true or v5.Enabled ~= true or v5.WorldReady ~= true then
					v7 = false
				else
					v7 = workspace:GetServerTimeNow() < (v5.EventEndsAt or 0)
				end

				if v7 then
					v6 = true
					p2.SetPending(true)
					local success, result = pcall(callback, "Milestone", p)
					v6 = false

					if not flag then
						return
					end

					p2.SetPending(false)
					local presentation = ScrambleMastery.Presentation
					local v8 = rewardOf(p) -- equivalent call inferred; original call site unknown
					local icon2 = presentation(v8).Icon

					if success and result then
						if result.Ok then
							toast("Scramble Mastery reward claimed!", color, icon2) -- equivalent call inferred; original call site unknown
						elseif result.Reason == "Busy" or result.Reason == "ProfileUnavailable" then
							toast("Please wait a moment and try again.", color2, icon2) -- equivalent call inferred; original call site unknown
						end
					else
						toast("Could not confirm the claim. Try again.", color2, icon2) -- equivalent call inferred; original call site unknown
					end

					refresh()
				end
			end
		end

		template.Visible = false
		nextRewardIcon.Visible = false

		for _, v7 in frozen do
			scrollingFrame[v7].Visible = false
		end

		for _, milestone in ScrambleMastery.Milestones do
			local v7 = frozen[milestone.Kills]
			local v8

			if v7 then
				v8 = scrollingFrame[v7]
			else
				v8 = template
			end

			v3[milestone.Id] = MilestoneCard.New(v8, scrollingFrame, milestone.Id, claim, v7 ~= nil)

			if milestone.Reward.Kind ~= "Pet" then
				continue
			end

			local parent = v3[milestone.Id].Button.Parent
			maid:Connect(parent:GetPropertyChangedSignal("AbsolutePosition"), refreshNextReward)
			maid:Connect(parent:GetPropertyChangedSignal("AbsoluteSize"), refreshNextReward)
		end

		v3[ScrambleMastery.InfiniteMilestoneId] = MilestoneCard.New(
			template,
			scrollingFrame,
			ScrambleMastery.InfiniteMilestoneId,
			claim
		)

		for _, v7 in v3 do
			maid:Add(v7.Destroy)
		end

		maid:Connect(scrollingFrame:GetPropertyChangedSignal("CanvasPosition"), refreshNextReward)
		maid:Connect(scrollingFrame:GetPropertyChangedSignal("AbsoluteWindowSize"), refreshCanvas)
		maid:Connect(scrollingFrame:GetPropertyChangedSignal("AbsolutePosition"), refreshNextReward)
		maid:Connect(scrollingFrame:GetPropertyChangedSignal("Visible"), refreshNextReward)
		maid:Connect(scrollingFrame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), refreshCanvas)
		refreshCanvas() -- equivalent call inferred; original call site unknown
		maid:Connect(scrambleBossMastery:GetPropertyChangedSignal("Enabled"), refreshCanvas)
		maid:Connect(frame:GetPropertyChangedSignal("Visible"), refreshNextReward)
		local consoleButton = bossShopButton.ConsoleButton
		consoleButton:SetAttribute("GamepadKey", "ButtonX")
		GamepadBindings.Inspect(consoleButton)
		maid:Add(ButtonFX(bossShopButton, 1.08, callback2))
		maid:Add(ButtonFX(nextRewardIcon, 1.05, scrollToNextReward))
		maid:Add(Tabs.Activated:Connect(function(p)
			if p == "ScrambleBossMastery" then
				refreshCanvas() -- equivalent call inferred; original call site unknown
				refresh()
				notifyReady()
			end
		end))

		local function refreshShopButtonPosition()
			if bossShopButton.AbsolutePosition.Y < GuiService:GetInsetArea(Enum.ScreenInsets.CoreUISafeInsets).Min.Y then
				bossShopButton.Position = UDim2.new(0, 0, 0, 0)
				bossShopButton.AnchorPoint = Vector2.new(1, 0)
			else
				bossShopButton.Position = UDim2.new(0, 0, -0.275, 0)
				bossShopButton.AnchorPoint = Vector2.new(0, 1)
			end
		end

		maid:Add(frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
			refreshShopButtonPosition()
		end))
		refreshShopButtonPosition()

		function v.Update(p)
			v5 = p
			local v7

			if v5 == nil or v5.Ready ~= true or v5.Enabled ~= true or v5.WorldReady ~= true then
				v7 = false
			else
				v7 = workspace:GetServerTimeNow() < (v5.EventEndsAt or 0)
			end

			if not v7 then
				v.Close()
			end

			refresh()
			notifyReady()
		end

		function v.Toggle()
			if Tabs.IsActive("ScrambleBossMastery") then
				v.Close()
				return
			end

			local v7

			if v5 == nil or v5.Ready ~= true or v5.Enabled ~= true or v5.WorldReady ~= true then
				v7 = false
			else
				v7 = workspace:GetServerTimeNow() < (v5.EventEndsAt or 0)
			end

			if v7 and v5.State then
				refresh()
				Tabs.Activate("ScrambleBossMastery")
			end
		end

		function v.Close()
			maid2:Clean()

			if Tabs.IsActive("ScrambleBossMastery") then
				Tabs.Deactivate()
			end
		end

		function v.Destroy()
			flag = false
			nextRewardIcon.Visible = false
			maid:Destroy()
		end

		return v
	end
}