local Quests = require(game.ReplicatedStorage.Quests)
local DialogueController = require(game.ReplicatedStorage.DialogueController)
local BonusMomentsGuide = require(game.ReplicatedStorage.BonusMomentsGuide)
local CraftWindow = require(game.ReplicatedStorage.Controllers.UI.CraftWindow)
local Config = require(game.ReplicatedStorage.NPCManager.NPC.Config)
local Net = require(game.ReplicatedStorage.Modules.Net)
local TextUtil = require(game.ReplicatedStorage.Modules.Util.TextUtil)
require(script.Parent.Types)
require(game.ReplicatedStorage.DialogueController.Types)
local actions = Config.Actions
local now = 0
local Util = {}

for k, action in pairs(actions) do
	local animation = Instance.new("Animation")
	animation.Name = "Animation_" .. k
	animation.AnimationId = "rbxassetid://" .. action
	actions[k] = animation
end

function Util.playAction(p: string, p2)
	if tick() - now < 0.03333333333333333 then
		return
	end

	now = tick()
	task.spawn(function()
		local dialogueModel = p2

		if not dialogueModel then
			local Global = require(game.ReplicatedStorage.Global)
			dialogueModel = Global.dialogueModel
		end

		if not (dialogueModel and dialogueModel:FindFirstChildWhichIsA("Humanoid") and dialogueModel:FindFirstChild("UpperTorso")) then
			return
		end

		local clone = dialogueModel:FindFirstChild("Animation_" .. p)

		if not clone then
			clone = actions[p] and actions[p]:Clone()

			if not clone then
				return
			end

			clone.Parent = dialogueModel
		end

		local track = dialogueModel:FindFirstChildWhichIsA("Humanoid"):LoadAnimation(clone)

		if p == "Pain" then
			track.Looped = false
		elseif p == "Floating" then
			track.Priority = Enum.AnimationPriority.Action4
		end

		track:Play(0.3)
	end)
end

function Util.stopAction(p: string, dialogueModel)
	if not dialogueModel then
		local Global = require(game.ReplicatedStorage.Global)
		dialogueModel = Global.dialogueModel
	end

	if not (dialogueModel and dialogueModel:FindFirstChildWhichIsA("Humanoid") and dialogueModel:FindFirstChild("UpperTorso")) then
		return
	end

	local animationId = actions[p].AnimationId

	for _, v in dialogueModel:FindFirstChildWhichIsA("Animator", true):GetPlayingAnimationTracks() do
		if v.Animation.AnimationId ~= animationId then
			continue
		end

		v:Stop()
		v:Destroy()
	end
end

function Util.promptCraftAndWaitForGuiToClose(p, p2, p3)
	CraftWindow:Open("NPC", p, p2, p3)
	game.Players.LocalPlayer.PlayerGui.Craft:GetPropertyChangedSignal("Enabled"):Wait()
end

local Global = require(game.ReplicatedStorage.Global)
Global.promptCraftAndWaitForGuiToClose = Util.promptCraftAndWaitForGuiToClose

function Util.generateQuest(p: string, options)
	local v = options or {}
	assert(v, "bad params")
	local v2 = "" .. p
	local nPCName = v.NPCName

	if v.NoReturn then
		v2 = nil
	end

	local quest = Quests[p]
	local v3 = next(quest)
	local v4

	if v3 == nil then
		v4 = false
	else
		v4 = next(quest, v3) ~= nil
	end

	local function questDescription(p2)
		local v5 = {}

		for k, v6 in next, p2.Task, nil do
			local v7 = v6 > 1 and "s" or ""
			table.insert(v5, "Defeat " .. (v6 == 1 and "" or v6 .. " ") .. k .. v7)
		end

		local description = "" .. table.concat(v5, "\n")
		local rewardText = ""

		if p2.Reward.Beli then
			rewardText ..= "<Color=Green>$" .. TextUtil.commaValue(p2.Reward.Beli) .. "<Color=/>\n"
		end

		if p2.Reward.Exp then
			rewardText ..= "<Color=Yellow>" .. TextUtil.commaValue(p2.Reward.Exp) .. " Exp.<Color=/>"
		end

		return {
			Description = description,
			Rewards = {
				Beli = p2.Reward.Beli,
				Exp = p2.Reward.Exp
			},
			RewardText = rewardText
		}
	end

	local function startQuestText(p2: number)
		local v5 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", p, p2)

		if v5 == 0 then
			Util.playAction("Positive")
			return "[Quest accepted.]"
		elseif v5 == 1 then
			Util.playAction("Negative")
			return "[An error has occurred.]"
		elseif v5 == 2 then
			Util.playAction("Explain")
			return "[You already completed this quest.]"
		end

		Util.playAction("Negative")
		return "[You must be Level " .. v5 .. " to accept this quest.]"
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isLevelLocked(p2)
		return game.Players.LocalPlayer.Data.Level.Value < p2.LevelReq
	end

	local function hasKillEnemyTask(p2)
		return typeof(p2.Task) == "table" and next(p2.Task) ~= nil
	end

	local function questOptionText(p2)
		if v4 then
			return p2.ShortName or p2.Name or "Quest"
		end

		return "Quest"
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function reportQuestInteraction()
		if not v2 then
			return
		end

		task.spawn(function()
			local GuideModule = require(game.ReplicatedStorage.GuideModule)
			local data = GuideModule.Data
			local compassTargetTracked = data.LastMeters <= 10 and data.LastClosestNPC ~= nil and typeof(data.LastClosestNPC) == "string" and data.LastClosestNPC == nPCName
			Net:RemoteEvent("RobloxAnalytics"):FireServer({
				Context = "SpokeToNPC",
				InternalName = v2,
				CompassTargetTracked = compassTargetTracked
			})
		end)
	end

	local v5 = DialogueController.new()
	v5:setTitle(nPCName or "Quest")
	v5:setSubtitle("Quest Giver")

	local function buildQuestDetailsPage(object, p2: number, p3)
		local v6 = questDescription(p3)
		object:setTitle(v6.Description)
		object:setSubtitle("Rewards")
		object:addText(v6.RewardText)
		object:addOptionType("Accept", function(object2)
			object2:setText("Accept")
			object2:jumpToPage(function(object3)
				object3:addText((startQuestText(p2)))
				object3:advanceAfterDelay(0.5)
			end)
		end)

		if not v.NoReturn then
			object:addOptionType("Chat", function(object2)
				object2:setText("Return")
				object2:goBack()
			end)
		end
	end

	v5.InternalQuestName = v2

	local function buildQuestSelectPage(object, interactQuestGiver)
		object:addText(v.TextOverride or "Please select a quest.")

		if v.ExtraOptions then
			v.ExtraOptions(object)
		end

		for k, v6 in next, quest, nil do
			local levelLocked = isLevelLocked(v6) -- equivalent call inferred; original call site unknown
			local v7 = v6
			local v9 = k
			object:addOptionType(levelLocked and "Locked" or "Quest", function(object2)
				local v10 = v7
				object2:setText(not v4 and "Quest" or v10.ShortName or v10.Name or "Quest")

				if not levelLocked then
					local v11 = v7
					local v12

					if typeof(v11.Task) == "table" then
						v12 = next(v11.Task) ~= nil
					else
						v12 = false
					end

					if v12 then
						object2:setIcon(function(object3)
							object3:setImage("rbxassetid://101361996661425")
						end)
					end
				end

				if levelLocked then
					object2:setLocked(true)
				end

				object2:jumpToPage(function(p2)
					buildQuestDetailsPage(p2, v9, v7)
				end)
			end)
		end

		local rumorDialogue

		if interactQuestGiver then
			rumorDialogue = interactQuestGiver.RumorDialogue
		else
			rumorDialogue = nil
		end

		if rumorDialogue then
			object:addOptionType("Quest", function(object2)
				object2:setText("Rumor")
				object2:jumpToPage(function(object3)
					for _, v6 in rumorDialogue do
						object3:addText(v6)
					end

					object3:addOptionType("Chat", function(object4)
						object4:setText("Return")
						object4:goBack()
					end)
				end)
			end)
		end
	end

	v5:addPage(function(object)
		local v6

		if v.BeforeGuide then
			v6 = v.BeforeGuide()
		end

		local interactQuestGiver = BonusMomentsGuide.interactQuestGiver(p)
		local openingDialogue

		if interactQuestGiver then
			openingDialogue = interactQuestGiver.OpeningDialogue
		end

		local v7 = {}

		if v6 then
			table.move(v6, 1, #v6, 1, v7)
		end

		if openingDialogue then
			table.move(openingDialogue, 1, #openingDialogue, #v7 + 1, v7)
		end

		if #v7 > 0 then
			for _, v8 in v7 do
				object:addText(v8)
			end

			object:onPageAdvance(function(p2)
				buildQuestSelectPage(p2, interactQuestGiver)
			end)
		else
			buildQuestSelectPage(object, interactQuestGiver)
		end

		reportQuestInteraction() -- equivalent call inferred; original call site unknown
	end)

	function v5.Get()
		return v5:build()
	end

	return v5:build()
end

return Util