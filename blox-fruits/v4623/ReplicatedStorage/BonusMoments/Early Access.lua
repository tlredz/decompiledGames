local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
local DialogueController = require(game.ReplicatedStorage.DialogueController)
local DialogueRegistry = require(game.ReplicatedStorage.Controllers.BonusMomentsController.DialogueRegistry)
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local Config = require(script.Config)
local Dialogue = require(script.Dialogue)
local Infiltration = require(script.Infiltration)
local Presence = require(script.Presence)
local Scene = require(script.Scene)
local v = nil
local flag = false
local v2 = {
	getState = function(p)
		return p.MiscData._earlyAccessState
	end,
	setStage = function(state, stage: number)
		if state.cancelled or state.stage == stage then
			return
		end

		state.stage = stage
		state.scene:setStage(stage)
	end,
	refreshPresence = function(p, data)
		if data.cancelled then
			return
		end

		local v3 = data.available and not p.Completed
		Presence.setQuestGiverVisible(v3)
		data.scene:setQuestGiverVisible(v3)
	end
}

function v2.setAvailable(p, p2, available: boolean)
	if p2.cancelled then
		return
	end

	p2.available = available
	v2.refreshPresence(p, p2)
end

function v2.invoke(object, p: string)
	local success, result, v3, v4 = pcall(function()
		return object:InvokeServer(p)
	end)

	if success then
		return result, v3, v4
	end

	warn((`[{script.Name}] {p} failed: {result}`))
	return nil, nil, nil
end

function v2.request(p, state, p2: string)
	if state.busy or state.cancelled or DialogueController.Active then
		return nil, nil, nil
	end

	state.busy = true
	local v3, v4, v5 = v2.invoke(p, p2)
	state.busy = false
	return v3, v4, v5
end

function v2:openDialogue(p)
	if self.busy or self.cancelled or DialogueController.Active then
		return
	end

	self.busy = true
	local success, result = pcall(DialogueController.start, p)
	self.busy = false

	if not success then
		warn((`[{script.Name}] dialogue failed: {result}`))
	end
end

function v2.acceptQuest(p, p2)
	local v3, v4 = v2.invoke(p, "AcceptQuest")

	if v3 == "Accepted" and typeof(v4) == "number" then
		v2.setStage(p2, v4)
	end
end

function v2.claimReward(p, p2)
	local v3, v4 = v2.invoke(p, "ClaimReward")

	if v3 == "Completed" and typeof(v4) == "number" then
		v2.setStage(p2, v4)
		pcall(function()
			Sound:Play(Config.PROMOTION_SOUND)
		end)
	end
end

function v2.finishInfiltration(p, p2)
	local v3, v4 = v2.invoke(p, "FinishInfiltration")

	if v3 == "Finished" and typeof(v4) == "number" then
		v2.setStage(p2, v4)
	end
end

function v2.playInfiltration(p, state)
	if state.busy or state.cancelled then
		return
	end

	state.busy = true
	local v3, v4 = Infiltration.play(p)
	state.busy = false

	if state.cancelled then
		return
	end

	if v3 then
		v2.finishInfiltration(p, state)
	elseif v4 ~= "the infiltration cutscene was cancelled" then
		warn((`[{script.Name}] {v4 or "infiltration cutscene failed"}`))
	end
end

function v2.getLocalQuestGiverResult(p, p2)
	if p.Completed or p2.stage == Config.STAGES.TESTER then
		return "Completed"
	end

	if p2.stage == Config.STAGES.UNSTARTED then
		return "Intro"
	end

	if p2.stage == Config.STAGES.RETURN_TO_DEVELOPER then
		return "Reward"
	end

	return "Reminder"
end

function v2.createQuestGiverDialogue(p, p2, p3: string)
	if p3 == "Intro" then
		return Dialogue.intro(function()
			v2.acceptQuest(p, p2)
		end)
	elseif p3 == "Reward" then
		return Dialogue.reward(function()
			v2.claimReward(p, p2)
		end)
	elseif p3 == "Completed" then
		return Dialogue.completed()
	end

	return Dialogue.reminder(p2.stage)
end

function v2.getQuestGiverDialogue(p, p2)
	local request, v3 = v2.request(p, p2, "InteractQuestGiver")

	if typeof(v3) == "number" then
		v2.setStage(p2, v3)
	end

	if request == "Unavailable" then
		v2.setAvailable(p, p2, false)
		return Dialogue.testerDoorLocked()
	end

	if request == nil then
		local v4 = v2.invoke(p, "GetState")

		if typeof(v4) == "number" then
			v2.setStage(p2, v4)
		end
	end

	if request ~= "Intro" and request ~= "Reward" and request ~= "Completed" and request ~= "Reminder" then
		request = v2.getLocalQuestGiverResult(p, p2)
	end

	return v2.createQuestGiverDialogue(p, p2, request)
end

function v2.handleKey(p, p2)
	local request, v3 = v2.request(p, p2, "CollectKey")

	if request == "Collected" and typeof(v3) == "number" then
		v2.setStage(p2, v3)
	end
end

function v2.handleMansionDoor(p, p2)
	local request, v3 = v2.request(p, p2, "InteractMansionDoor")

	if typeof(v3) == "number" then
		v2.setStage(p2, v3)
	end

	if request == "Locked" then
		v2.openDialogue(p2, Dialogue.locked())
	elseif request == "Infiltration" then
		v2.playInfiltration(p, p2)
	end
end

function v2.handleTesterDoor(p, p2)
	local request, v3 = v2.request(p, p2, "InteractTesterDoor")

	if request == "QuestGiver" and typeof(v3) == "number" then
		v2.setStage(p2, v3)
		v2.openDialogue(p2, Dialogue.testerDoorLocked())
	elseif request == "Denied" and typeof(v3) == "number" then
		v2.openDialogue(p2, Dialogue.testerDoor(v3))
	end
end

function v2.getPeekGoal()
	local DEVELOPER_DOOR_PEEK_CFRAME = Config.DEVELOPER_DOOR_PEEK_CFRAME
	local chillingModel = Presence.getChillingModel()

	if not chillingModel then
		return DEVELOPER_DOOR_PEEK_CFRAME
	end

	local head = chillingModel:FindFirstChild("Head")
	local position

	if head and head:IsA("BasePart") then
		position = head.Position
	else
		position = chillingModel:GetPivot().Position
	end

	if (position - DEVELOPER_DOOR_PEEK_CFRAME.Position).Magnitude <= 0.05 then
		return DEVELOPER_DOOR_PEEK_CFRAME
	end

	return CFrame.lookAt(DEVELOPER_DOOR_PEEK_CFRAME.Position, position)
end

function v2:peekThroughWindow(p2)
	local peekCamera = CameraController.new()
	self.peekCamera = peekCamera
	peekCamera.Animations:AnimateTo(
		v2.getPeekGoal(),
		Config.DEVELOPER_DOOR_PEEK_DAMPING,
		Config.DEVELOPER_DOOR_PEEK_FREQUENCY
	)
	task.defer(function()
		if self.peekCamera == peekCamera then
			self.peekDialogue = DialogueController.getActiveDialogue()
		end
	end)
	v2.openDialogue(self, p2)

	if self.peekCamera == peekCamera then
		self.peekCamera = nil
		self.peekDialogue = nil
		peekCamera:FadeOut(Config.DEVELOPER_DOOR_PEEK_FADE)
	end
end

function v2.handleDeveloperDoor(_, data)
	if data.busy or data.cancelled or DialogueController.Active then
		return
	end

	local developerDoor = Dialogue.developerDoor(data.available)

	if data.available then
		v2.openDialogue(data, developerDoor)
	else
		v2.peekThroughWindow(data, developerDoor)
	end
end

function v2.interact(p, p2, p3: string)
	if p3 == "MansionKey" then
		v2.handleKey(p, p2)
	elseif p3 == "MansionDoor" then
		v2.handleMansionDoor(p, p2)
	elseif p3 == "TesterDoor" then
		v2.handleTesterDoor(p, p2)
	elseif p3 == "DeveloperDoor" then
		v2.handleDeveloperDoor(p, p2)
	elseif p3 == "TesterSign" then
		v2.openDialogue(p2, Dialogue.testerNote())
	end
end

function v2.destroyState(p, state)
	if state.cleaned then
		return
	end

	state.cleaned = true
	state.cancelled = true
	local peekCamera = state.peekCamera
	local peekDialogue = state.peekDialogue
	state.peekCamera = nil
	state.peekDialogue = nil
	local activeDialogue = DialogueController.getActiveDialogue()

	if peekCamera and activeDialogue and (not peekDialogue or activeDialogue == peekDialogue) then
		DialogueController.close()
	end

	if peekCamera then
		peekCamera:FadeOut(Config.DEVELOPER_DOOR_PEEK_FADE)
	end

	Infiltration.cancel(p)
	Presence.reset()
	state.scene:destroy()

	if p.MiscData._earlyAccessState == state then
		p.MiscData._earlyAccessState = nil
	end
end

function v2.createState(maid, stage: number)
	local state = v2.getState(maid)

	if state then
		v2.destroyState(maid, state)
	end

	local earlyAccessState = {
		scene = nil,
		stage = stage,
		busy = false,
		available = false,
		peekCamera = nil,
		peekDialogue = nil,
		cancelled = false,
		cleaned = false
	}
	earlyAccessState.scene = Scene.new(function(p2: string)
		task.spawn(v2.interact, maid, earlyAccessState, p2)
	end)
	maid.MiscData._earlyAccessState = earlyAccessState
	earlyAccessState.scene:setStage(stage)
	v2.refreshPresence(maid, earlyAccessState)
	maid:GiveTask(function()
		v2.destroyState(maid, earlyAccessState)
	end)
	task.spawn(function()
		local v4 = v2.invoke(maid, "GetState")

		if not earlyAccessState.cancelled and typeof(v4) == "number" then
			v2.setStage(earlyAccessState, v4)
		end
	end)
	task.spawn(function()
		local v4 = v2.invoke(maid, "IsAvailable")
		v2.setAvailable(maid, earlyAccessState, v4 == true)
	end)
	return earlyAccessState
end

function v2.getOrCreateState(p)
	local state = v2.getState(p)

	if state then
		return state
	end

	local v3

	if p.Completed then
		v3 = Config.STAGES.TESTER
	else
		v3 = Config.STAGES.UNSTARTED
	end

	return v2.createState(p, v3)
end

function v2.installQuestGiverDialogue()
	if flag then
		return
	end

	flag = true
	DialogueRegistry.register(Config.QUEST_GIVER_NPC_NAME, "EarlyAccess", 100, function(_)
		local v3 = v

		if not v3 or v3.Player:GetAttribute("CurrentLocation") ~= Config.ISLAND then
			return nil
		end

		local state = v2.getOrCreateState(v3)
		return v2.getQuestGiverDialogue(v3, state)
	end)
end

local EarlyAccess = {}
EarlyAccess.DataName = script.Name
EarlyAccess.LoadWhenCompleted = true

function EarlyAccess.OnLoad(p)
	v = p
	v2.installQuestGiverDialogue()
	local v3

	if p.Completed then
		v3 = Config.STAGES.TESTER
	else
		v3 = Config.STAGES.UNSTARTED
	end

	v2.createState(p, v3)
end

function EarlyAccess.OnComplete(p, flag2: boolean, flag3: boolean?)
	if flag3 and v == p then
		v = nil
	end

	local state = v2.getState(p)
	local available

	if state then
		available = state.available
	else
		available = false
	end

	if state then
		v2.destroyState(p, state)
	end

	if flag2 and not flag3 then
		task.defer(function()
			if p.Completed then
				local state2 = v2.createState(p, Config.STAGES.TESTER)
				v2.setAvailable(p, state2, available)
			end
		end)
	end
end

EarlyAccess.RemoteEvents = {
	State = function(p, value: number)
		local state = v2.getState(p)

		if state and typeof(value) == "number" then
			v2.setStage(state, value)
		end
	end,
	Available = function(p, flag2: boolean)
		local state = v2.getState(p)

		if state then
			v2.setAvailable(p, state, flag2 == true)
		end
	end
}
return EarlyAccess