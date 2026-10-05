local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DialogueController = require(ReplicatedStorage.DialogueController)
local FailureTemplates = require(script.Parent.FailureTemplates)
require(script.Parent.Types)
local v2 = nil
local frozen = table.freeze({
	ChaseShout = "<AnimateEffect=ShoutShake>GET BACK HERE!!!<AnimateEffect=/>",
	LookoutConcern = "Are you sure they're chasing the right guy? <Red>I don't feel so good about this...</Red>",
	Marine1 = "Check his cargo!",
	Marine2 = "We've got you now!",
	Marine3 = "Let's see what we have here...",
	Marine3Shaking = "<AnimateEffect=DialogueShake>Let's see what we have here...<AnimateEffect=/>",
	Marine3Reaction = "Yeah... These will be coming with us. No wonder nobody can roll a Dragon Fruit from the Gacha Dealer!",
	PirateReaction = "No! Not the Dragon Fruits! I worked so hard stealing every last one from the Gacha Dealer!",
	FishermanReaction = "<AnimateEffect=ShoutShake>STAY AWAY FROM MY FISH!<AnimateEffect=/> I'll blast ye off the sea!",
	DoghouseBanAll = "/ban all",
	DoghouseBanCorrection = "WAIT OGM I MEAN OTHER NOT ALL!!! WAI-"
})

local function getOrCreateState()
	local activeDialogue = DialogueController.getActiveDialogue()

	if activeDialogue then
		return activeDialogue
	end

	local v3 = DialogueController.new()
	v3:setTitle("Marine")
	v3:addPage(function(object)
		object:addText("[The marines inspect the captured cargo.]")
		object:noCancel()
		object:noSkip()
	end)
	local v4 = v3:build()
	task.spawn(function()
		DialogueController.start(v4)
	end)

	for _ = 1, 10 do
		local activeDialogue2 = DialogueController.getActiveDialogue()

		if activeDialogue2 then
			v2 = activeDialogue2
			return activeDialogue2
		else
			task.wait()
		end
	end

	return nil
end

local function show(p, p2: string, p3: string, flag: boolean?)
	local state = getOrCreateState()
	local v3 = state and state:getCurrent()

	if not v3 then
		return false
	end

	if p then
		p.beginDialogue()
	end

	v3:setTitle(p2)
	v3:noCancel()
	v3:noSkip()

	if flag then
		v3:replaceTextWithoutReplay(p3)
	else
		v3:replaceText(p3)
	end

	DialogueController.unhideWindow()
	return true
end

local v = {
	closeOwned = function()
		if v2 and DialogueController.getActiveDialogue() == v2 then
			DialogueController.close()
		end

		v2 = nil
	end,
	hide = function()
		DialogueController.hideWindow(true)
	end,
	showChaseShout = function(p)
		return (show(p, "Marines", frozen.ChaseShout))
	end,
	showFailureChaseReply = function(p, p2)
		local v3 = FailureTemplates.get(p2)
		return (show(p, v3.ChaseTitle, v3.ChaseText))
	end,
	showLookoutConcern = function(p)
		return (show(p, "Lookout", frozen.LookoutConcern))
	end,
	showMarine1 = function(p)
		return (show(p, "Marine 1", frozen.Marine1))
	end,
	showMarine2 = function(p)
		return (show(p, "Marine 2", frozen.Marine2))
	end,
	showFollowerInspecting = function(p)
		return (show(p, "Marine 3", frozen.Marine3))
	end,
	showFollowerShaking = function()
		local marine3Shaking = frozen.Marine3Shaking
		local state = getOrCreateState()
		local v3 = state and state:getCurrent()

		if not v3 then
			return false
		end

		v3:setTitle("Marine 3")
		v3:noCancel()
		v3:noSkip()
		v3:replaceTextWithoutReplay(marine3Shaking)
		DialogueController.unhideWindow()
		return true
	end,
	showFollowerStoppedShaking = function()
		local marine3 = frozen.Marine3
		local state = getOrCreateState()
		local v3 = state and state:getCurrent()

		if not v3 then
			return false
		end

		v3:setTitle("Marine 3")
		v3:noCancel()
		v3:noSkip()
		v3:replaceTextWithoutReplay(marine3)
		DialogueController.unhideWindow()
		return true
	end,
	showFollowerFailureReaction = function(p, p2)
		return (show(p, "Marine 3", FailureTemplates.get(p2).CrateReactionText))
	end,
	showFollowerReaction = function(p)
		return (show(p, "Marine 3", frozen.Marine3Reaction))
	end,
	showPirateReaction = function(p)
		return (show(p, "Pirate", frozen.PirateReaction))
	end,
	showFishermanReaction = function(p)
		return (show(p, "Fisherman", frozen.FishermanReaction))
	end,
	showDoghouseBanAll = function(p)
		return (show(p, "Doghouse", frozen.DoghouseBanAll))
	end,
	showDoghouseBanCorrection = function(p)
		return (show(p, "Doghouse", frozen.DoghouseBanCorrection))
	end
}
return table.freeze(v)