local ReplicatedStorage = game:GetService("ReplicatedStorage")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local packages = ReplicatedStorage.packages
local shared = ReplicatedStorage.shared
local DataController = require(legacyControllers.DataController)
local HudController = require(legacyControllers.HudController)
local QuestController = require(legacyControllers.QuestController)
require(legacyControllers.SettingsController)
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local fx = require(shared.modules.fx)
local rods = require(shared.modules.library.rods)
local mastery = require(shared.modules.library.rods.mastery)
local QuestShared = require(shared.modules.QuestShared)
local remoteFunction = Net:RemoteFunction("RodEnhancements/SetEnabled", -1)
local remoteFunction2 = Net:RemoteFunction("Mastery/LoadQuests")
local remoteEvent = Net:RemoteEvent("Mastery/ClaimQuest")
local remoteEvent2 = Net:RemoteEvent("Mastery/Complete")
local anno_localthought = ReplicatedStorage.events.anno_localthought
local localPlayer = game.Players.LocalPlayer
local playerDataReplicator = DataController.PlayerDataReplicator
local rods2 = HudController:GetSafeZone().equipment.Container.Rods
local mastery2 = rods2.Mastery
local main = rods2.Main
local color = Color3.fromRGB(161, 255, 192)
local color2 = Color3.fromRGB(154, 170, 190)
local color3 = Color3.fromRGB(255, 243, 153)
local color4 = Color3.fromRGB(161, 255, 192)
local v = {
	NoRodInRewards = true
}
local maid = Trove.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function getProgressGoal(quest)
	if quest.Goal[1] == "DataInstanceValue" then
		return quest.Goal[3]
	end

	return quest.Goal[2]
end

local function readQuestState(p: string, p2: string, max: number)
	local objectiveInstance = QuestShared:GetObjectiveInstance(localPlayer, `{p}/{p2}-MASTERY`, 1)

	if not objectiveInstance or type(objectiveInstance.Value) ~= "number" then
		return false, false, nil
	end

	local value = objectiveInstance.Value
	local v2 = value < 0
	return v2, value == -2, v2 and max or math.clamp(value, 0, max)
end

return {
	UpdateMastery = function(_, p: string)
		maid:Clean()
		local rod = rods[p]
		local v2 = mastery.Mastery[p]

		if not (rod and v2) then
			return
		end

		remoteFunction2:InvokeServer(p)
		local rodTemplate = mastery2.RodTemplate
		rodTemplate.RodImage.Image = rod.Icon or ""
		rodTemplate.Rod.RodInfo.rodTitle.Text = `[{p}]`
		rodTemplate.Rod.RodInfo.desc.Text = rod.Description or ""
		rodTemplate.UIStroke.Color = rod.Color
		rodTemplate.Gradient.BackgroundColor3 = rod.Color
		local count = 0

		for _ in v2.Quests do
			count += 1
		end

		local extended = maid:Extend()
		local clone

		if v2.CompleteReward then
			local rewardDescription, v3 = QuestController:GetRewardDescription(v2.CompleteReward.Info, v)
			clone = script.Template:Clone()
			clone.Name = "CompleteReward"
			clone.LayoutOrder = -100000
			clone.Reward.Text = `Final Reward: {v2.CompleteReward.Display or rewardDescription or "???"}`
			clone.Goals.Text = "Claim all other mastery quests for this rod"
			clone.Goals.TextColor3 = color3
			clone.IgnoreList.ImageLabel.Image = v2.CompleteReward.Icon or v3 or ""
			clone.IgnoreList.Gradient.BackgroundColor3 = color3
			clone.Header.Text = "Completion Reward"
			clone.Header.TextColor3 = color3
			clone.UIStroke.Color = color3
			clone.IgnoreList.Claim.claimButton.UIStroke.Color = color3
			clone.IgnoreList.Claim.claimButton.Label.TextColor3 = color3
			clone.IgnoreList.Claim.Visible = false
			clone.IgnoreList.Claim.claimButton.Visible = false
			maid:Add(clone)
			clone.Parent = mastery2.ScrollingFrame
		else
			clone = nil
		end

		local function refreshCompletionReward()
			if not clone then
				return
			end

			local count2 = 0
			local v3 = false

			for k, quest in v2.Quests do
				local progressGoal = getProgressGoal(quest) -- equivalent call inferred; original call site unknown
				local objectiveInstance = QuestShared:GetObjectiveInstance(localPlayer, `{p}/{k}-MASTERY`, 1)
				local v5, v6

				if objectiveInstance and type(objectiveInstance.Value) == "number" then
					local value = objectiveInstance.Value
					v5 = value < 0
					v6 = value == -2

					if not (v5 and progressGoal) then
						math.clamp(value, 0, progressGoal)
					end
				else
					v5 = false
					v6 = false
				end

				if v5 then
					count2 += 1
				end

				if v6 then
					v3 = true
				end
			end

			local visible = count <= count2
			local visible2 = visible and not v3
			clone.IgnoreList.Claim.Visible = visible
			clone.IgnoreList.Claim.claimButton.Visible = visible2
			extended:Clean()

			if visible2 then
				extended:Connect(clone.IgnoreList.Claim.claimButton.Activated, function()
					clone.IgnoreList.Claim.claimButton.Visible = false
					remoteEvent2:FireServer(p)
					fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.unlock1, script.Parent, false)
				end)
			end
		end

		for k, quest in v2.Quests do
			local rewardDescription, v3 = QuestController:GetRewardDescription(quest.Reward.Info, v)
			local clone2 = script.Template:Clone()
			clone2.Name = k
			clone2.LayoutOrder = quest.Order
			local icon = quest.Reward.Icon or v3 or ""
			clone2.Header.Text = quest.Name
			clone2.Header.TextColor3 = Color3.fromRGB(255, 255, 255)
			clone2.Reward.Text = `Reward: {quest.Reward.Display or rewardDescription or "???"}`
			clone2.Reward.Size = UDim2.fromScale(icon == "" and 1 or 0.6, 0)
			clone2.IgnoreList.ImageLabel.Image = icon
			local formatted = `{p}/{k}-MASTERY`
			local objectiveInstance = QuestShared:GetObjectiveInstance(localPlayer, formatted, 1)

			if objectiveInstance then
				local progressGoal = getProgressGoal(quest) -- equivalent call inferred; original call site unknown
				local extended2 = maid:Extend()
				local claim = clone2.IgnoreList.Claim
				local v4 = k
				local v6 = formatted
				local v7 = objectiveInstance
				local v8 = clone2
				local v10 = claim.claimButton
				local v12 = quest

				local function updateProgress(flag: boolean?)
					local v13 = progressGoal
					local objectiveInstance2 = QuestShared:GetObjectiveInstance(localPlayer, `{p}/{v4}-MASTERY`, 1)
					local v14

					if objectiveInstance2 and type(objectiveInstance2.Value) == "number" then
						local value = objectiveInstance2.Value
						v14 = value < 0
						local v16 = v14 and v13 or math.clamp(value, 0, v13)
					else
						v14 = false
					end

					local questInstance = QuestShared:GetQuestInstance(localPlayer, v6)
					local goalDescription = v7.Value >= 0 and QuestController:GetGoalDescription(questInstance, v7, 1) or "Quest Completed"
					v8.Goals.Text = goalDescription
					local v15

					if v7.Value >= 0 then
						v15 = progressGoal <= v7.Value
					else
						v15 = false
					end

					local visible = claim.Visible and v10.Visible
					claim.Visible = v15 or v14
					v10.Visible = v15 and not v14
					extended2:Clean()

					if v10.Visible then
						extended2:Connect(v10.Activated, function()
							v10.Visible = false
							remoteEvent:FireServer(p, v4)
							fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.unlock3, script.Parent, false)
						end)
					end

					if not flag and not visible and v15 then
						task.delay(1, function()
							fx:PlaySound(
								ReplicatedStorage.resources.sounds.sfx.player.questUpdate,
								script.Parent,
								false
							)
							anno_localthought:Fire((`"<font color="#{color4:ToHex()}"><b><i>{v12.Name}</i></b></font>" mastery is ready to claim for <b><font color="#{rod.Color:ToHex()}">{p}</font></b>!`))
						end)
					end

					refreshCompletionReward()
				end

				updateProgress(true)
				local updateProgress2 = updateProgress
				maid:Add(objectiveInstance:GetPropertyChangedSignal("Value"):Connect(function()
					updateProgress2(false)
				end))
				maid:Add(clone2)
				clone2.Parent = mastery2.ScrollingFrame
			else
				clone2:Destroy()
			end
		end

		refreshCompletionReward()
		local passiveToggle = mastery2.PassiveToggle
		local v3 = playerDataReplicator:TryIndex({ "RodEnhancements", p }) or {}
		local v4 = nil

		for k, v6 in v3 do
			if not k:match("^Mastery") then
				continue
			end

			v4 = v6
			break
		end

		local v6 = v4 == true

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updatePassiveToggle(flag: boolean)
			passiveToggle.BackgroundColor3 = flag and color or color2
		end

		updatePassiveToggle(v6) -- equivalent call inferred; original call site unknown
		passiveToggle.Visible = v4 ~= nil
		maid:Connect(passiveToggle.Activated, function()
			local v7 = false
			local v8 = nil

			for k, _ in v3 do
				if k:match("^Mastery") then
					v7, v8 = remoteFunction:InvokeServer(p, k, not v6)
				end
			end

			if not v7 then
				anno_localthought:Fire((`<font color="#ff5858">{v8 or "Something went wrong."}</font>`))
				return
			end

			v6 = not v6
			updatePassiveToggle(v6) -- equivalent call inferred; original call site unknown
		end)
		maid:Connect(mastery2.Back.Activated, function()
			maid:Clean()
			mastery2.Visible = false
			main.Visible = true
		end)
	end
}