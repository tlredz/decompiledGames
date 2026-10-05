local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CameraController = require(ReplicatedStorage.Controllers.CameraController)
local NPCInteractionConfig = require(ReplicatedStorage.NPCManager.NPCInteractionConfig)
local NPC = require(ReplicatedStorage.NPCManager.NPC)
require(ReplicatedStorage.NPCManager.Types)
local localPlayer = Players.LocalPlayer
local frozen = table.freeze({
	BACK = 6,
	HEIGHT = 3.5,
	SIDE = 1.5,
	EYES = 1.5,
	FOCUS_BLEND = 0.35,
	FADE_OUT = 0.25
})
local extended = NPC.extend("HiddenRoom")

-- equivalent calls inferred from this helper; original call sites unknown
local function flatDirection(vector2: Vector3, lookVector: Vector3)
	local v = vector2 * createVector(1, 0, 1)

	if v.Magnitude > 0.05 then
		return v.Unit
	end

	local v2 = lookVector * createVector(1, 0, 1)

	if v2.Magnitude > 0.05 then
		return v2.Unit
	end

	return createVector(0, 0, 1)
end

local function getShot(character, position: Vector3)
	local pivot = character:GetPivot()
	local vector2 = flatDirection(position - pivot.Position, pivot.LookVector) -- equivalent call inferred; original call site unknown
	local cross = vector2:Cross(createVector(0, 1, 0))
	local v2 = pivot.Position - vector2 * frozen.BACK + createVector(0, 1, 0) * frozen.HEIGHT + cross * frozen.SIDE
	local v3 = pivot.Position + createVector(0, 1, 0) * frozen.EYES
	return CFrame.lookAt(v2, v3:Lerp(position, frozen.FOCUS_BLEND))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function closeDialogue()
	local DialogueController = require(ReplicatedStorage.DialogueController)
	DialogueController.close()
end

function extended.new(p, p2)
	local v = NPC.new(p, p2)
	setmetatable(v, extended)
	v._dialogueToken = 0
	return v
end

function extended:getInteractionRange()
	return 45 + NPCInteractionConfig.getLocalCharacterReach()
end

function extended.getIfStagesOwnDialogue(_)
	return true
end

function extended:onDialogueStarted()
	self._dialogueToken += 1
	local _dialogueToken = self._dialogueToken
	local _rootPart = self._modelState._rootPart
	local currentCamera = workspace.CurrentCamera
	local v

	if currentCamera and not CameraController.hasActiveControllers(currentCamera) then
		v = CameraController.new()
	else
		v = nil
	end

	function self._maid.HiddenRoomDialogue()
		if v then
			v:FadeOut(frozen.FADE_OUT)
		end
	end

	task.spawn(function()
		while self._dialogueToken == _dialogueToken do
			local character = localPlayer.Character

			if not (character and _rootPart) then
				break
			end

			if self:getDistanceFromPlayer() > self:getInteractionRange() + 8 then
				closeDialogue() -- equivalent call inferred; original call site unknown
				break
			else
				if v then
					v.Animations:AnimateTo(
						getShot(character, _rootPart.Position),
						1,
						NPCInteractionConfig.DIALOGUE_CAMERA_FREQUENCY
					)
				end

				RunService.RenderStepped:Wait()
			end
		end
	end)
end

function extended:onDialogueEnded()
	self._dialogueToken += 1
	self._maid.HiddenRoomDialogue = nil
end

return extended