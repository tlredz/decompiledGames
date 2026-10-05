local BonusMomentsController = require(game.ReplicatedStorage.Controllers.BonusMomentsController)
local BonusMomentsGuide = require(game.ReplicatedStorage.BonusMomentsGuide)
local DialogueController = require(game.ReplicatedStorage.DialogueController)
require(game.ReplicatedStorage.DialoguesList.Types)
require(game.ReplicatedStorage.DialogueController.Types)
local Util = require(game.ReplicatedStorage.DialoguesList.Util)
local RunService = game:GetService("RunService")
local v = RunService:IsStudio() and 1 or 10
local v2 = DialogueController.new()
v2:setTitle("Desert Merchant")

local function getPricklyHarvest()
	local pricklyHarvest = BonusMomentsController:GetLoadedMoments()["Prickly Harvest"]

	if pricklyHarvest then
		return pricklyHarvest, pricklyHarvest.MomentData
	end

	return pricklyHarvest, nil
end

local function noteMerchantVisit()
	local rescueHasan = BonusMomentsController:GetLoadedMoments()["Rescue Hasan"]
	local completed

	if rescueHasan == nil then
		completed = false
	else
		completed = rescueHasan.Completed or rescueHasan.Progress == 2
	end

	if not completed then
		return completed
	end

	local pricklyHarvest = BonusMomentsController:GetLoadedMoments()["Prickly Harvest"]
	local momentData

	if pricklyHarvest then
		momentData = pricklyHarvest.MomentData
	end

	if momentData then
		momentData:TalkedToMerchant()
	end

	return completed
end

local function isTurnInReady()
	local pricklyHarvest = BonusMomentsController:GetLoadedMoments()["Prickly Harvest"]

	if pricklyHarvest then
		local _ = pricklyHarvest.MomentData
	end

	return pricklyHarvest ~= nil and pricklyHarvest:InvokeServer("TurnInReady") == true
end

local function buildQuestPage(object)
	local pricklyHarvest = BonusMomentsController:GetLoadedMoments()["Prickly Harvest"]
	local momentData

	if pricklyHarvest then
		momentData = pricklyHarvest.MomentData
	end

	if not pricklyHarvest then
		object:addText("...")
		return
	end

	local v3, v4 = pricklyHarvest:InvokeServer("Interact")

	if v3 == "Reward" then
		object:addText("Ten blossoms, and not one of them bruised. I can make my drinks this year after all.")
	end

	if v3 == "Reward" or v3 == "Completed" then
		Util.playAction("Positive")
		local interactQuestGiver = BonusMomentsGuide.interactQuestGiver("DesertMerchant")
		local openingDialogue

		if interactQuestGiver then
			openingDialogue = interactQuestGiver.OpeningDialogue
		end

		if openingDialogue then
			for _, v5 in openingDialogue do
				object:addText(v5)
			end
		end
	end

	if v3 == nil then
		object:addText("...")
	elseif v3 == "StartQuest" then
		local v5

		if momentData then
			v5 = momentData:PlayCactusPan()
		else
			v5 = nil
		end

		if v5 then
			v2:getMaid():GiveTask(v5.stop)
		end

		object:addText("These cacti take a long time to bloom, if I miss this next cycle, I won't be able to keep my business afloat!")
		object:addText("They're flowering right now! But I'm not the only one who has noticed...")
		object:addText("See those two? Whenever I try to interfere with harvesting some of the cacti, they push me to the side.")
		object:noCancel()
		object:onPageAdvance(function(object2)
			if v5 then
				v5.focusMerchant()
			end

			object2:addText("I need 10 Cactus Petals before the bloom cycle ends, or else I can't continue my business, and I'll be forced to shut it down. Please get them for me!")
			object2:noCancel()
			object2:addOptionType("Chat", function(object3)
				object3:setText("Sure")
				object3:jumpToPage(function(object4)
					if v5 then
						v5.stop()
					end

					object4:addText("Thank you! Please be quick, there isn't much time till the blooming cycle ends, and they become unusable.")
				end)
			end)
		end)
	elseif v3 == "InProgress" then
		local v5 = v - v4
		object:addText(string.format(
			"Thank you for helping. I still need %s more Cactus Petal%s.",
			tostring(v5),
			v5 > 1 and "s" or ""
		))
	elseif v3 == "Completed" then
		object:addText("Thank you again for your help.")
	elseif v3 == "Unavailable" then
		object:addText("The cacti aren't ready to bloom yet. But when they are, I'll need some help gathering them.")
	end
end

local function buildMainPage(object, p)
	local rescueHasan = BonusMomentsController:GetLoadedMoments()["Rescue Hasan"]
	local completed

	if rescueHasan == nil then
		completed = false
	else
		completed = rescueHasan.Completed or rescueHasan.Progress == 2
	end

	if completed then
		local pricklyHarvest = BonusMomentsController:GetLoadedMoments()["Prickly Harvest"]
		local momentData

		if pricklyHarvest then
			momentData = pricklyHarvest.MomentData
		end

		if momentData then
			momentData:TalkedToMerchant()
		end
	end

	if not completed then
		object:addText("Have you seen Hasan out there? He's my best friend on this island.")
		object:addText("He hasn't come back in days. The last time anyone saw him, he was heading to the pyramid.")
		object:addText("If you're going that way, please help him.")
	end

	object:addText("So what can I do for you?")
	object:addOptionType("Quest", function(object2)
		object2:setText("Prickly Harvest")
		object2:jumpToPage(buildQuestPage)
	end)
	local rumorDialogue

	if p then
		rumorDialogue = p.RumorDialogue
	else
		rumorDialogue = nil
	end

	if rumorDialogue then
		object:addOptionType("Quest", function(object2)
			object2:setText("Rumor")
			object2:jumpToPage(function(object3)
				for _, v3 in rumorDialogue do
					object3:addText(v3)
				end

				object3:addOptionType("Chat", function(object4)
					object4:setText("Return")
					object4:goBack()
				end)
			end)
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function buildLandingPage(p, p2)
	local pricklyHarvest = BonusMomentsController:GetLoadedMoments()["Prickly Harvest"]

	if pricklyHarvest then
		local _ = pricklyHarvest.MomentData
	end

	local v3

	if pricklyHarvest == nil then
		v3 = false
	else
		v3 = pricklyHarvest:InvokeServer("TurnInReady") == true
	end

	if not v3 then
		buildMainPage(p, p2)
		return
	end

	local rescueHasan = BonusMomentsController:GetLoadedMoments()["Rescue Hasan"]
	local v4

	if rescueHasan == nil then
		v4 = false
	else
		v4 = rescueHasan.Completed or rescueHasan.Progress == 2
	end

	if v4 then
		local pricklyHarvest2 = BonusMomentsController:GetLoadedMoments()["Prickly Harvest"]
		local momentData

		if pricklyHarvest2 then
			momentData = pricklyHarvest2.MomentData
		end

		if momentData then
			momentData:TalkedToMerchant()
		end
	end

	buildQuestPage(p)
end

v2:addPage("Main", function(object)
	local interactQuestGiver = BonusMomentsGuide.interactQuestGiver("DesertMerchant")
	local openingDialogue

	if interactQuestGiver then
		openingDialogue = interactQuestGiver.OpeningDialogue
	end

	if openingDialogue and #openingDialogue > 0 then
		for _, v3 in openingDialogue do
			object:addText(v3)
		end

		object:onPageAdvance(function(p)
			buildLandingPage(p, interactQuestGiver) -- equivalent call inferred; original call site unknown
		end)
	else
		buildLandingPage(object, interactQuestGiver) -- equivalent call inferred; original call site unknown
	end
end)
return v2:build()