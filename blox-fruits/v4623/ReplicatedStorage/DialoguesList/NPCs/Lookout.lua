local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return {}
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BonusMomentInteraction = require(ReplicatedStorage.Util.BonusMomentInteraction)
local BonusMomentsGuide = require(ReplicatedStorage.BonusMomentsGuide)
local DialogueController = require(ReplicatedStorage.DialogueController)
local frozen = table.freeze({
	DataName = "Lookout",
	Island = "Middle Town",
	GuideInteractionName = "TravelDressrosa",
	OpeningCopy = "There have been some real shady smugglers sailing around these parts. You think you have what it takes to be the island lookout? Watch closely...",
	HoldingCopy = "[Watch the ships carefully.]",
	UnavailableCopy = "Give me a moment. I'm still getting my bearings.",
	TransformedCopy = "Come back when you've returned to your normal form.",
	FailureCopy = "I can't get a clear view right now. Let's try again in a moment.",
	CompletedCopy = "You have a sharp eye. The marines know exactly which ships to stop now.",
	ThankYouCopy = "Four for four! You've got the sharpest eyes in Middle Town. The marines know exactly which ships to stop now.",
	AnswerHoldingCopy = "[Checking the count.]",
	IntroResponses = {
		"Persistent, aren't you? Come back another time.",
		"Still here? Come back when I've had time to think."
	},
	WrongCopyByRounds = {
		[0] = "Oh no... We sent the marines after the <Red>wrong ships</Red> before spotting a single smuggler group.",
		[1] = "You caught one smuggler group, but the next count sent the marines after the <Red>wrong ships</Red>.",
		[2] = "Two good calls isn't bad, but that last count sent the marines after the <Red>wrong ships</Red>.",
		[3] = "Three groups spotted! You were one answer away, but the marines boarded the <Red>wrong ships</Red>."
	},
	IntermissionDuration = 1.25,
	MaxReadyRetries = 6,
	MaxAnswerChoices = 4,
	MaxRounds = 4,
	RoundShipCounts = {
		3,
		5,
		8,
		11
	},
	IntermissionCopy = {
		[2] = "I sent my guys after them. Let's keep looking for more smugglers.",
		[3] = "Wow, there's a lot of ships coming! Get ready, there's probably lots of smugglers hidden among them!",
		[4] = "One last wave. They're moving faster now, so don't blink!"
	},
	ThinkingActions = { "Explain", "Observe", "Shrug" },
	PluralBoatNames = {
		Dinghy = "Dinghies",
		Sloop = "Sloops",
		Brigade = "Brigades",
		["Grand Brigade"] = "Grand Brigades"
	}
})
local v = false
local count = 0
local v2 = nil
local v3 = nil
local v4 = {}
local fn

function v4.getLoadedMoment()
	local success, result = pcall(function()
		return require(ReplicatedStorage.Controllers.BonusMomentsController)
	end)

	if not success or typeof(result) ~= "table" then
		return nil
	end

	local success2, result2 = pcall(function()
		return result:GetLoadedMoments()
	end)

	if success2 and typeof(result2) == "table" then
		return result2[frozen.DataName]
	end

	return nil
end

function v4.invokeMoment(object, ...)
	local v5 = table.pack(...)
	return pcall(function()
		return object:InvokeServer(table.unpack(v5, 1, v5.n))
	end)
end

function v4.cancelPresentation(p)
	local momentData = p and p.MomentData
	local cancelObservation = momentData and momentData.cancelObservation

	if typeof(cancelObservation) == "function" then
		pcall(cancelObservation, p)
	end
end

function v4.pageIsCurrent(p, p2)
	local activeDialogue = DialogueController.getActiveDialogue()
	return activeDialogue == p.DialogueState and activeDialogue ~= nil and activeDialogue:getCurrent() == p2
end

function v4.contextOwnsPage(p, p2)
	return v2 == p and not p.Aborted and not p.Finished and v4.pageIsCurrent(p, p2)
end

function v4.contextMomentIsAvailable(p)
	local moment = p.Moment
	return v4.getLoadedMoment() == moment and moment.Completed ~= true and moment.Player ~= nil and moment.Player:GetAttribute("CurrentLocation") == frozen.Island and not BonusMomentInteraction.isTransformed(moment.Player.Character)
end

function v4.contextOwnsAvailablePage(p, p2)
	return v4.contextOwnsPage(p, p2) and v4.contextMomentIsAvailable(p)
end

function v4.fireTokenAbort(p, p2)
	task.spawn(function()
		pcall(function()
			p.Moment:InvokeServer("AbortAttempt", p2)
		end)
	end)
end

function v4.fireFinaleFinished(p, p2)
	task.spawn(function()
		pcall(function()
			p.Moment:InvokeServer("FinishFinale", p2)
		end)
	end)
end

function v4.finishSuccessfulFinale(p, p2)
	local v5, v6 = v4.invokeMoment(p.Moment, "FinishFinale", p2)

	if not v5 or v6 ~= true then
		warn("[Lookout] successful finale could not be completed by the server")
		return nil
	end

	local interactQuestGiver = BonusMomentsGuide.interactQuestGiver(frozen.GuideInteractionName)

	if interactQuestGiver then
		return interactQuestGiver.OpeningDialogue
	end

	return nil
end

function v4:finishAttempt()
	self.Finished = true

	if v2 == self then
		v2 = nil
	end
end

function v4:abortAttempt()
	if self.Aborted or self.Finished then
		return
	end

	self.Aborted = true
	v4.cancelPresentation(self.Moment)
	v4.fireTokenAbort(self, self.Token)

	if v2 == self then
		v2 = nil
	end
end

function v4.attachPageGuard(object, p)
	local v5 = {
		PlannedTransition = false
	}
	local maid = object:getMaid()

	function maid.LookoutAttemptGuard()
		if not v5.PlannedTransition then
			v4.abortAttempt(p)
		end
	end

	return v5
end

function v4.deferFinaleCutscene(p, callback, p2, callback2)
	task.defer(function()
		local success, result, v5 = pcall(callback, p, p2, callback2)

		if success then
			if result ~= true then
				warn((`[Lookout] finale cutscene was rejected: {tostring(v5)}`))
				callback2(false)
			end
		else
			warn((`[Lookout] finale cutscene failed: {tostring(result)}`))
			callback2(false)
		end
	end)
end

function v4.resolveScore(p, value: number)
	local selected

	if typeof(p.RoundsSurvived) == "number" then
		selected = math.clamp(math.floor(p.RoundsSurvived), 0, frozen.MaxRounds)
	else
		selected = math.clamp(value, 0, frozen.MaxRounds)
	end

	if typeof(p.BestRounds) == "number" then
		return selected, (math.clamp(math.floor(p.BestRounds), selected, frozen.MaxRounds))
	end

	return selected, selected
end

function v4.addWrongResult(object, p: number, p2: number)
	object:addText(frozen.WrongCopyByRounds[p] or frozen.WrongCopyByRounds[0])
	object:addText((`Best lookout run: {p2}/{frozen.MaxRounds} rounds.`))
end

function v4.playWrongAnswerCinematic(p, object, p2, p3, value, p4: number, p5: number)
	local momentData = p.Moment.MomentData
	local playFinaleCutscene = momentData and momentData.playFinaleCutscene

	if typeof(p3) ~= "table" or typeof(value) ~= "string" or typeof(playFinaleCutscene) ~= "function" then
		return false
	end

	p2.PlannedTransition = true
	v4.finishAttempt(p)
	v4.deferFinaleCutscene(p.Moment, playFinaleCutscene, p3, function()
		v4.fireFinaleFinished(p, value)

		if not v4.pageIsCurrent(p, object) then
			return
		end

		object:pageRedirect(function(p6)
			v4.addWrongResult(p6, p4, p5)
		end)
		DialogueController.unhideWindow()
	end)
	return true
end

function v4.showFinaleCompletion(p, object, flag: boolean, items)
	if not v4.pageIsCurrent(p, object) then
		return
	end

	object:pageRedirect(function(object2)
		local v5

		if flag then
			v5 = frozen.ThankYouCopy
		else
			v5 = frozen.FailureCopy
		end

		object2:addText(v5)

		if items then
			for _, item in items do
				object2:addText(item)
			end
		end
	end)
	DialogueController.unhideWindow()
end

function v4.validateRoundPayload(data)
	if typeof(data) ~= "table" or typeof(data.Token) ~= "string" or data.Token == "" or typeof(data.Round) ~= "number" or typeof(data.Manifest) ~= "table" then
		return false
	end

	local roundShipCount = frozen.RoundShipCounts[data.Round]
	return roundShipCount ~= nil and #data.Manifest == roundShipCount
end

function v4.resolveQuestion(data, p: number?)
	if typeof(data) ~= "table" then
		return nil, nil, nil
	end

	local v5

	if p then
		v5 = frozen.RoundShipCounts[p]
	end

	if not v5 then
		return nil, nil, nil
	end

	local targetBoat = data.TargetBoat
	local targetFlagColor = data.TargetFlagColor
	local v6

	if typeof(targetBoat) == "string" then
		v6 = frozen.PluralBoatNames[targetBoat]
	end

	if not v6 or typeof(targetFlagColor) ~= "string" then
		return nil, nil, nil
	end

	local answerChoices = data.AnswerChoices
	local v7 = math.min(frozen.MaxAnswerChoices, v5 + 1)

	if typeof(answerChoices) ~= "table" or #answerChoices ~= v7 then
		return nil, nil, nil
	end

	local v8 = {}
	local answerChoices2 = {}

	for i = 1, v7 do
		local answerChoice = answerChoices[i]

		if typeof(answerChoice) ~= "number" or answerChoice % 1 ~= 0 or answerChoice < 0 or v5 < answerChoice or v8[answerChoice] then
			return nil, nil, nil
		end

		v8[answerChoice] = true
		table.insert(answerChoices2, answerChoice)
	end

	return v6, targetFlagColor, answerChoices2
end

function v4.showAttemptFailure(p, object, p2, p3: string?)
	local pageIsCurrent = v4.pageIsCurrent(p, object)

	if pageIsCurrent then
		p2.PlannedTransition = true
	end

	v4.abortAttempt(p)

	if pageIsCurrent and v4.pageIsCurrent(p, object) then
		object:pageRedirect(function(object2)
			object2:addText(p3 or frozen.FailureCopy)
		end)
		DialogueController.unhideWindow()
	end
end

function v4.waitForReadyRetry(p, p2, value: number)
	local v5 = os.clock() + math.clamp(value, 0.05, 5)

	while os.clock() < v5 do
		if not v4.contextOwnsAvailablePage(p, p2) then
			return false
		end

		task.wait((math.min(v5 - os.clock(), 0.1)))
	end

	return v4.contextOwnsAvailablePage(p, p2)
end

function v4.buildNextHoldingPage(object, p, p2)
	if typeof(p2) == "table" and typeof(p2.Token) == "string" then
		p.Token = p2.Token
	end

	if v4.validateRoundPayload(p2) then
		p.Token = p2.Token
		p.Round = p2.Round
		object:addText(frozen.HoldingCopy)
		object:noCancel()
		DialogueController.hideWindow(true)
		local v5 = v4.attachPageGuard(object, p)
		task.defer(fn, p, p2, object, v5)
	else
		v4.abortAttempt(p)
		object:addText(frozen.FailureCopy)
		DialogueController.unhideWindow()
	end
end

function v4.buildIntermissionPage(object, p, p2)
	object:addText(assert(frozen.IntermissionCopy[p2.Round], "Missing Lookout intermission copy"))
	object:noCancel()
	local v5 = v4.attachPageGuard(object, p)
	object:onPageAdvance(function(object2)
		if v4.contextOwnsAvailablePage(p, object) then
			v5.PlannedTransition = true
			v4.buildNextHoldingPage(object2, p, p2)
		else
			v4.abortAttempt(p)
			object2:close()
		end
	end)
	object:advanceAfterDelay(frozen.IntermissionDuration)
end

function v4.handleSubmitResponse(object, p, state, p2: number, data)
	if typeof(data) ~= "table" then
		v4.showAttemptFailure(state, object, p, frozen.FailureCopy)
	elseif data.Correct == false then
		local score, v5 = v4.resolveScore(data, (state.Round or 1) - 1)

		if v4.playWrongAnswerCinematic(state, object, p, data.Finale, data.FinaleToken, score, v5) then
			return
		end

		if typeof(data.FinaleToken) == "string" then
			v4.fireFinaleFinished(state, data.FinaleToken)
		end

		p.PlannedTransition = true
		v4.finishAttempt(state)
		object:pageRedirect(function(p3)
			v4.addWrongResult(p3, score, v5)
		end)
		DialogueController.unhideWindow()
	elseif data.Correct ~= true then
		v4.showAttemptFailure(state, object, p, frozen.FailureCopy)
	elseif data.NextRound == nil then
		if data.Completed == true then
			local finale = data.Finale
			local finaleToken = data.FinaleToken
			local momentData = state.Moment.MomentData
			local playFinaleCutscene = momentData and momentData.playFinaleCutscene

			if typeof(finale) == "table" and typeof(finaleToken) == "string" and typeof(playFinaleCutscene) == "function" then
				p.PlannedTransition = true
				v = true
				v4.finishAttempt(state)
				v4.deferFinaleCutscene(state.Moment, playFinaleCutscene, finale, function(flag: boolean)
					local v5 = v4.finishSuccessfulFinale(state, finaleToken)
					v4.showFinaleCompletion(state, object, flag, v5)
				end)
			else
				warn("[Lookout] final answer returned without a valid finale presentation")

				if typeof(finaleToken) == "string" then
					v4.fireFinaleFinished(state, finaleToken)
				end

				v4.showAttemptFailure(state, object, p, frozen.FailureCopy)
			end
		else
			warn((`[Lookout] correct answer {p2} had no next-round or final response`))
			v4.showAttemptFailure(state, object, p, frozen.FailureCopy)
		end
	else
		local nextRound = data.NextRound

		if typeof(nextRound) == "table" and typeof(nextRound.Token) == "string" then
			state.Token = nextRound.Token
		end

		if not v4.validateRoundPayload(nextRound) then
			v4.showAttemptFailure(state, object, p, frozen.FailureCopy)
			return
		end

		p.PlannedTransition = true
		object:pageRedirect(function(p3)
			v4.buildIntermissionPage(p3, state, nextRound)
		end)
		DialogueController.unhideWindow()
	end
end

function v4:runSubmitAnswer(p2: number, p3: string, p4, p5)
	if v4.contextOwnsAvailablePage(self, p4) then
		local v5, v6 = v4.invokeMoment(self.Moment, "SubmitAnswer", p3, p2)
		self.Submitting = false

		if v4.contextOwnsPage(self, p4) then
			if v5 then
				v4.handleSubmitResponse(p4, p5, self, p2, v6)
			else
				v4.showAttemptFailure(self, p4, p5, frozen.FailureCopy)
			end
		else
			if v5 and typeof(v6) == "table" and typeof(v6.FinaleToken) == "string" then
				v4.fireFinaleFinished(self, v6.FinaleToken)
			elseif v5 and typeof(v6) == "table" and typeof(v6.NextRound) == "table" and typeof(v6.NextRound.Token) == "string" then
				v4.fireTokenAbort(self, v6.NextRound.Token)
			end

			v4.abortAttempt(self)
		end
	else
		self.Submitting = false
		v4.abortAttempt(self)
	end
end

function v4.buildQuestionPage(object, p, p2: string, _, p3: string, p4: string, items)
	object:addText((`The smugglers had {p4} flags on their {p3}! How many did you see?`))
	object:setCancelText("Nevermind")
	local v5 = v4.attachPageGuard(object, p)

	for _, item in items do
		local v6 = item
		object:addOption(function(object2)
			object2:setText((tostring(v6)))
			object2:onSelected(function()
				v5.PlannedTransition = true
			end)
			object2:jumpToPage(function(object3)
				if p.Submitting or not v4.contextOwnsAvailablePage(p, object) then
					v4.abortAttempt(p)
					object3:addText(frozen.FailureCopy)
				else
					p.Submitting = true
					object3:addText(frozen.AnswerHoldingCopy)
					object3:noCancel()
					DialogueController.hideWindow(true)
					local v7 = v4.attachPageGuard(object3, p)
					task.defer(v4.runSubmitAnswer, p, v6, p2, object3, v7)
				end
			end)
		end)
	end
end

function v4.redirectToQuestion(p, object, p2, p3)
	local question, v5, v6 = v4.resolveQuestion(p3, p.Round)

	if not (question and v5 and v6) then
		v4.showAttemptFailure(p, object, p2, frozen.FailureCopy)
		return
	end

	if not v4.contextOwnsAvailablePage(p, object) then
		v4.abortAttempt(p)
		return
	end

	local token = p.Token

	if not token then
		v4.showAttemptFailure(p, object, p2, frozen.FailureCopy)
		return
	end

	p2.PlannedTransition = true
	object:pageRedirect(function(p4)
		v4.buildQuestionPage(p4, p, token, p3, question, v5, v6)
	end)
	DialogueController.playAction(frozen.ThinkingActions[math.random(1, #frozen.ThinkingActions)])
	DialogueController.unhideWindow()
end

fn = function(state, p, p2, p3)
	if not (v4.contextOwnsAvailablePage(state, p2) and v4.validateRoundPayload(p)) then
		v4.showAttemptFailure(state, p2, p3, frozen.FailureCopy)
		return
	end

	state.Token = p.Token
	state.Round = p.Round
	local momentData = state.Moment.MomentData
	local startObservation = momentData and momentData.startObservation

	if typeof(startObservation) ~= "function" then
		v4.showAttemptFailure(state, p2, p3, frozen.FailureCopy)
		return
	end

	local success, result, v5 = pcall(startObservation, state.Moment, p)

	if success and result == true then
		if not v4.contextOwnsAvailablePage(state, p2) then
			v4.abortAttempt(state)
			return
		end

		local v6 = nil

		for _ = 1, frozen.MaxReadyRetries do
			local v7, v8 = v4.invokeMoment(state.Moment, "ObservationFinished", state.Token)

			if not v7 or typeof(v8) ~= "table" then
				v4.showAttemptFailure(state, p2, p3, frozen.FailureCopy)
				return
			end

			if v8.Ready ~= false then
				v6 = v8
				break
			end

			local v9 = typeof(v8.RetryAfter) ~= "number" and 0.1 or v8.RetryAfter

			if v4.waitForReadyRetry(state, p2, v9) then
				continue
			end

			v4.abortAttempt(state)
			return
		end

		if v6 then
			v4.redirectToQuestion(state, p2, p3, v6)
		else
			v4.showAttemptFailure(state, p2, p3, frozen.FailureCopy)
		end
	else
		warn((`[Lookout] observation failed: {tostring(v5)}`))
		v4.showAttemptFailure(state, p2, p3, frozen.FailureCopy)
	end
end

function v4:runInitialAttempt(p2, p3)
	if not v4.contextOwnsAvailablePage(self, p2) then
		v4.abortAttempt(self)
		return
	end

	local v5, v6 = v4.invokeMoment(self.Moment, "StartAttempt")

	if v5 and typeof(v6) == "table" and BonusMomentInteraction.isTransformedReason(v6.Blocked) then
		BonusMomentInteraction.notifyTransformed()
		v4.showAttemptFailure(self, p2, p3, frozen.TransformedCopy)
	else
		if v5 and typeof(v6) == "table" and typeof(v6.Token) == "string" then
			self.Token = v6.Token
		end

		if not (v5 and v4.validateRoundPayload(v6)) then
			v4.showAttemptFailure(self, p2, p3, frozen.FailureCopy)
			return
		end

		if v4.contextOwnsAvailablePage(self, p2) then
			fn(self, v6, p2, p3)
			return
		end

		v4.fireTokenAbort(self, v6.Token)
		v4.abortAttempt(self)
	end
end

function v4.validateProgress(data)
	if typeof(data) == "table" and typeof(data.IntroVisits) == "number" and data.IntroVisits % 1 == 0 and not (data.IntroVisits < 0) and not (data.IntroVisits > 3) and typeof(data.NextVisitAt) == "number" and typeof(data.BestRounds) == "number" and data.BestRounds % 1 == 0 and not (data.BestRounds < 0) and not (data.BestRounds > frozen.MaxRounds) and typeof(data.Unlocked) == "boolean" and typeof(data.SecondsRemaining) == "number" and not (data.SecondsRemaining < 0) then
		return data
	end

	return nil
end

function v4.getProgress(p)
	local v5, v6 = v4.invokeMoment(p, "GetProgress")

	if v5 then
		return (v4.validateProgress(v6))
	end

	return nil
end

function v4.getDialogueOffer(data)
	if v or not data or data.Completed or data.Active or data.Player:GetAttribute("CurrentLocation") ~= frozen.Island or BonusMomentInteraction.isTransformed(data.Player.Character) then
		return nil
	end

	local progress = v4.getProgress(data)

	if progress then
		return {
			Label = progress.Unlocked and "Keep lookout" or "Ask about lookout duty"
		}
	end

	return nil
end

function v4.buildAvailablePage(object, p)
	object:addText(frozen.OpeningCopy)

	if p.BestRounds > 0 then
		object:addText((`Your best lookout run is {p.BestRounds}/{frozen.MaxRounds} rounds.`))
	end

	object:setCancelText("Nevermind")
	object:addOptionType("Accept", function(object2)
		object2:setText("Keep lookout")
		object2:jumpToPage(v4.buildInitialHoldingPage)
	end)
end

function v4.buildCooldownPage(object, p)
	v3 = object
	local maid = object:getMaid()

	function maid.LookoutCooldownPage()
		if v3 == object then
			v3 = nil
		end
	end

	local v5 = math.max(1, (math.ceil(p.SecondsRemaining / 60)))
	local v6 = math.floor(v5 / 60)
	local v7 = v5 % 60
	local v8

	if v6 > 0 then
		v8 = `{v6}h {v7}m`
	else
		v8 = `{v7}m`
	end

	object:addText(frozen.IntroResponses[p.IntroVisits] or frozen.UnavailableCopy)
	object:addText((`[Ask about lookout duty again in {v8}.]`))
end

function v4.closeCooldownDialogue(p)
	local activeDialogue = DialogueController.getActiveDialogue()

	if v3 and activeDialogue and activeDialogue:getCurrent() == v3 and v4.getLoadedMoment() == p then
		DialogueController.close()
	end
end

function v4.buildIntroductionPage(object, p)
	local v5, v6, v7 = v4.invokeMoment(p, "AdvanceIntroduction")
	local v8

	if v5 then
		v8 = v4.validateProgress(v6)
	end

	if not v8 then
		object:addText(frozen.UnavailableCopy)
	elseif v8.Unlocked and v7 == "Unlocked" then
		v4.buildAvailablePage(object, v8)
	else
		v4.buildCooldownPage(object, v8)
	end
end

function v4.buildInitialHoldingPage(object)
	local loadedMoment = v4.getLoadedMoment()

	if loadedMoment and not (loadedMoment.Completed or v) then
		if BonusMomentInteraction.isTransformed(loadedMoment.Player.Character) then
			BonusMomentInteraction.notifyTransformed()
			object:addText(frozen.TransformedCopy)
		else
			local progress = v4.getProgress(loadedMoment)

			if not (progress and progress.Unlocked) then
				object:addText(frozen.UnavailableCopy)
				return
			end

			if v2 then
				v4.abortAttempt(v2)
			end

			local activeDialogue = DialogueController.getActiveDialogue()

			if not activeDialogue then
				object:addText(frozen.UnavailableCopy)
				return
			end

			count += 1
			local v5 = {
				Moment = loadedMoment,
				DialogueState = activeDialogue,
				Generation = count,
				Token = nil,
				Round = nil,
				Aborted = false,
				Finished = false,
				Submitting = false
			}
			v2 = v5
			v5.Moment:GiveTask(function()
				v4.abortAttempt(v5)
			end)
			object:addText(frozen.HoldingCopy)
			object:noCancel()
			DialogueController.hideWindow(true)
			local v6 = v4.attachPageGuard(object, v5)
			task.defer(v4.runInitialAttempt, v5, object, v6)
		end
	else
		local v5

		if v or loadedMoment and loadedMoment.Completed then
			v5 = frozen.CompletedCopy
		else
			v5 = frozen.UnavailableCopy
		end

		object:addText(v5)
	end
end

local v5 = DialogueController.new()
v5:setTitle("Experienced Captain")
local v6 = v5:addPage("Main", function(object)
	local loadedMoment = v4.getLoadedMoment()

	if v or loadedMoment and loadedMoment.Completed then
		object:close()
	elseif not loadedMoment then
		object:close()
	elseif BonusMomentInteraction.isTransformed(loadedMoment.Player.Character) then
		BonusMomentInteraction.notifyTransformed()
		object:close()
	else
		local progress = v4.getProgress(loadedMoment)

		if not progress then
			object:addText(frozen.UnavailableCopy)
		elseif progress.SecondsRemaining > 0 then
			v4.buildCooldownPage(object, progress)
		elseif progress.Unlocked then
			v4.buildAvailablePage(object, progress)
		else
			v4.buildIntroductionPage(object, loadedMoment)
		end
	end
end):build()
v6.getDialogueOffer = v4.getDialogueOffer
v6.closeCooldownDialogue = v4.closeCooldownDialogue
return v6