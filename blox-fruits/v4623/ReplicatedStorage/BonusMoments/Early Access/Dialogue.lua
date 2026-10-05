local DialogueController = require(game.ReplicatedStorage.DialogueController)
local Config = require(script.Parent.Config)
local v = {
	[Config.STAGES.FIND_KEY] = "the key to robotmega's office is lying around near his desk. find it while he's there, and then sneak in through the back when nobody is around.",
	[Config.STAGES.HAS_KEY] = "u got the key to robotmega's office. sneak in while nobody's there.",
	[Config.STAGES.INFILTRATION] = "get back to robotmega's office. u still need to grab the 2017 sea animation system."
}
local v2 = {
	"uhhh, don't worry about it, it's just a bag.",
	"run along now, fetch that sea animation system. you do want tester, don't you?"
}
local v3 = {}
local Dialogue = {}

function v3.addResponse(object, p: string, p2: string?, callback)
	object:addOptionType("Chat", function(object2)
		object2:setText(p)

		if p2 then
			object2:jumpTo(p2)
		end

		if callback then
			object2:onSelected(callback)
		end
	end)
end

function v3.addBagPage(object, p: string, p2: string?, callback)
	object:addPage("Bag", function(object2)
		object2:noCancel()

		for _, v4 in v2 do
			object2:addText(v4)
		end

		v3.addResponse(object2, p, p2, callback)
	end)
end

function Dialogue.feedback(p: string, items, callback, p2: number?, flag: boolean?)
	local v4 = DialogueController.new()
	v4:setTitle(p)
	v4:addPage("Main", function(object)
		object:noCancel()

		for _, item in items do
			object:addText(item)
		end

		if callback then
			object:onFinished(callback)
		end

		if p2 then
			object:advanceAfterDelay(p2)
		end

		if flag then
			object:noSkip()
		end
	end)
	return v4:build()
end

function Dialogue.intro(callback)
	local v4 = DialogueController.new()
	v4:setTitle(Config.QUEST_GIVER_TITLE)
	v4:addPage("Main", function(object)
		object:noCancel()
		object:addText("yo bro! tryna test my new game?")
		v3.addResponse(object, "yes", "Favor")
	end)
	v4:addPage("Favor", function(object)
		object:noCancel()
		object:addText("bet. i just need one tiny favor first. can u sneak into robotmega's office and decompile his 2017 sea animation system?")
		object:addText("not because i need it. let's get that straight.")
		object:addText("i could remake it in 20 minutes if i wanted to.")
		object:addText("i'm just curious. purely educational purposes.")
		object:addText("the key to robotmega's office is lying around near his desk. find it while he's there, and then sneak in through the back when nobody is around.")
		v3.addResponse(object, "k", nil, callback)
		v3.addResponse(object, "what are you holding behind your back?", "Bag")
	end)
	v3.addBagPage(v4, "k", nil, callback)
	return v4:build()
end

function Dialogue.reward(callback)
	local v4 = DialogueController.new()
	v4:setTitle(Config.QUEST_GIVER_TITLE)
	v4:addPage("Reward", function(object)
		object:noCancel()
		object:addText("yoooo no way, you actually got it.")
		object:addText("aight bro, as promised... i'm officially promoting you to ✨ TESTER ✨.")
		object:addText("don't lose that btw. it's a very important role.")
		v3.addResponse(object, "can i test the game now?", "NotReady")
	end)
	v4:addPage("NotReady", function(object)
		object:noCancel()
		object:addText("nah.")
		v3.addResponse(object, "why?", "Development")
	end)
	v4:addPage("Development", function(object)
		object:noCancel()
		object:addText("game's not ready yet. we're still cooking.")
		v3.addResponse(object, "hasn't it been like 4 years...?", "History")
	end)
	v4:addPage("History", function(object)
		object:noCancel()
		object:addText("game development hard bro. last year the lead builder's fish died. year before that we had to rewrite the entire game because of some roblox update. then we found out one of the devs wasn't actually developing, he was just in vc saying 'that would be fire' every 20 minutes.")
		v3.addResponse(object, "so what does tester do?", "TesterRole")
	end)
	v4:addPage("TesterRole", function(object)
		object:noCancel()
		object:addText("mostly flex the role.")
		v3.addResponse(object, "that's it?", "Announcements")
	end)
	v4:addPage("Announcements", function(object)
		object:noCancel()
		object:addText("nah, every few months i post an announcement saying we're making good progress. then everyone reacts with 🔥. very important job.")
		v3.addResponse(object, "so when can i actually test?", "Christmas")
	end)
	v4:addPage("Christmas", function(object)
		object:noCancel()
		object:addText("christmas.")
		v3.addResponse(object, "this christmas?", "Hopefully")
	end)
	v4:addPage("Hopefully", function(object)
		object:noCancel()
		object:addText("hopefully.")
		v3.addResponse(object, "you said that last christmas.", "Progress")
	end)
	v4:addPage("Progress", function(object)
		object:noCancel()
		object:addText("and look how much progress we've made since then.")
		v3.addResponse(object, "what's changed?", "Changed")
	end)
	v4:addPage("Changed", function(object)
		object:noCancel()
		object:addText("you have tester role now.")
		object:onFinished(callback)
	end)
	return v4:build()
end

function Dialogue.reminder(p: number)
	local v4 = DialogueController.new()
	v4:setTitle(Config.QUEST_GIVER_TITLE)
	v4:addPage("Main", function(object)
		object:noCancel()
		object:addText(v[p] or "bro i'm still cooking. come back later.")
		v3.addResponse(object, "k")
		v3.addResponse(object, "what are you holding behind your back?", "Bag")
	end)
	v3.addBagPage(v4, "k")
	return v4:build()
end

function Dialogue.selfThought(p)
	return Dialogue.feedback("", p)
end

function Dialogue.developerDoor(flag: boolean)
	if flag then
		return Dialogue.selfThought({ "The door is locked. Looks like a relaxation room for playing games and taking a rest." })
	end

	return Dialogue.selfThought({ "Hmm.. It looks like they're really busy playing ga- I mean, making games." })
end

function Dialogue.testerNote()
	local v4 = DialogueController.new()
	v4:setTitle(Config.NOTE_TITLE)
	v4:addPage("Main", function(object)
		object:noCancel()
		object:addText("rlly busy developing right now, so much work to be done, come back later.")
		object:addText("to-do list (TOP SECRET):\n1. post a new 2nd sneak trailer for the 5th trailer")
	end)
	return v4:build()
end

function Dialogue.locked()
	return Dialogue.feedback(Config.REAR_DOOR_DISPLAY_NAME, { "[It's locked.]" }, nil, 2)
end

function Dialogue.uploaded(p: string)
	return Dialogue.feedback(
		p,
		{
			"[Uploading totally_not_a_virus.exe...]",
			"[Decompiling SeaAnimationSystem_2017...]",
			"Upload complete. I got the sea animation system."
		},
		nil,
		Config.CUTSCENE.UPLOAD_DIALOGUE_ADVANCE_DELAY,
		true
	)
end

function Dialogue.completed()
	return Dialogue.feedback(Config.QUEST_GIVER_TITLE, { "bro, you're already a tester. mostly just flex the role." })
end

function Dialogue.testerDoorLocked()
	return Dialogue.selfThought({ "It's locked. Maybe I should ask around?" })
end

function Dialogue.testerDoor(p: number)
	local v4 = Config.TESTER_DOOR_REASONS[p] or `can't let u in. internal build #{p} passed locally, which means it definitely broke in production.`
	return Dialogue.feedback(Config.QUEST_GIVER_TITLE, { v4 })
end

return Dialogue