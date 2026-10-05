local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
require(script.Types)
local TextTags = require(script.TextTags)
local Translation = require(script.Translation)
local Dialogue = require(script.Dialogue)
local FromProps = require(script.Dialogue.Renderable.FromProps)
local RenderableLayer = require(script.ReactComponents.RenderableLayer)
local State = require(script.Dialogue.State)
local Window = require(script.Dialogue.Window)
local Head = require(script.Dialogue.Head)
local Legacy = require(script.Legacy)
local Note = require(script.Note)
local AttributeCounter = require(game.ReplicatedStorage.Util.AttributeCounter)
require(game.ReplicatedStorage.NPCManager.Types)
local v = nil
local v2 = nil
local diedConnection = nil
local characterRemovingConnection = nil
local renderSteppedConnection = nil
local v3 = nil

function Translation.onRetranslated(p: string, p2: string)
	local v4 = v

	if not v4 then
		return
	end

	local current = v4:getCurrent()

	if not current then
		return
	end

	local v5 = current:swapTranslatedText(p, p2)

	for _, _option in current._options do
		v5 = _option:swapTranslatedText(p, p2) or v5
	end

	local option = current._cancel.option

	if option then
		v5 = option:swapTranslatedText(p, p2) or v5
	end

	if v5 then
		v4._window:refreshText()
	end
end

local DialogueController = {
	Active = false,
	Terminating = false
}

local function willTerminateAfterDelay(object)
	if object._advanceDelay == nil or object._textIndex < #object._textGroups then
		return false
	end

	return not object._advancePage and #object._options == 0 and object:getCancelOption() == nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function acquireHudLock(p)
	if v ~= p or v3 then
		return
	end

	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	v3 = AttributeCounter.destroyable(localPlayer, "MenuHidden")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseHudLock()
	local v4 = v3
	v3 = nil

	if v4 then
		v4:Destroy()
	end
end

local function beginTerminatingIfNeeded(object)
	local current = object:getCurrent()

	if not current then
		return false
	end

	local v4

	if current._advanceDelay == nil or current._textIndex < #current._textGroups or current._advancePage or #current._options ~= 0 then
		v4 = false
	else
		v4 = current:getCancelOption() == nil
	end

	if not v4 then
		return false
	end

	if v2 == object then
		return true
	end

	v2 = object
	DialogueController.Terminating = true
	DialogueController.Active = false
	releaseHudLock() -- equivalent call inferred; original call site unknown
	local _window = object._window

	if _window.setTerminating then
		_window:setTerminating(true)
	end

	return true
end

function DialogueController.getDialogueConstructor()
	return (Dialogue.new())
end

function DialogueController.new()
	return (Dialogue.new())
end

function DialogueController.startForTool(p, p2, p3: number?)
	local ToolInteraction = require(script.ToolInteraction)
	return ToolInteraction.start(DialogueController, p, p2, p3)
end

function DialogueController.getActiveDialogue()
	return v
end

function DialogueController.reactRenderable(options, children)
	local v4 = options or {}
	assert(v4)

	if children == nil then
		children = v4.children
	end

	local v5 = {
		Renderables = FromProps.snapshotsFromProps(v4),
		Position = v4.Position,
		Size = v4.Size,
		AnchorPoint = v4.AnchorPoint,
		ZIndex = v4.ZIndex,
		Children = children
	}
	return React.createElement(RenderableLayer, v5)
end

local function isLegacyFillerPage(object)
	if #object._options > 0 or object:getCancelOption() ~= nil then
		return false
	end

	local _textGroups = object._textGroups

	if #_textGroups == 0 then
		return true
	end

	if #_textGroups > 1 then
		return false
	end

	local _rawTexts = {}

	for _, v4 in _textGroups[1] do
		table.insert(_rawTexts, v4._rawText)
	end

	local joined = table.concat(_rawTexts, " ")
	return joined == "" or joined == "..."
end

function DialogueController.notifyNPC(object, p: string, ...)
	local NPC = object:getNPC()

	if not NPC then
		return
	end

	local v4 = NPC[p]

	if not v4 then
		return
	end

	local success, result = pcall(v4, NPC, ...)

	if not success then
		warn((`[DIALOGUE] {p} failed for {NPC:getModel().Name}: {tostring(result)}`))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function notifyLineChanged(object)
	local current = object:getCurrent()

	if not current then
		return
	end

	DialogueController.notifyNPC(object, "onDialogueLine", object, current)
end

function DialogueController.start(converted, p)
	if Legacy.is(converted) then
		converted = Legacy.convert(converted)
	end

	if v or Note.isActive() then
		warn("[DIALOGUE]", "there's already an active dialogue")
		return nil
	end

	local v4 = Window.new()

	if not v4:canRender() then
		return nil
	end

	pcall(function()
		local character = Players.LocalPlayer.Character
		local holding = character and character:FindFirstChild("Holding", true)

		if holding then
			holding.Value = false
		end
	end)
	local state = State.new(v4, converted._title, converted._subtitle, converted._titleSprite, p, converted)
	v4._state = state
	v4._wantsToRender = true
	v4._onAdvance = DialogueController.advance
	v4._onSelect = DialogueController.select
	converted._state = state
	v = state
	v2 = nil
	DialogueController.Active = true
	DialogueController.Terminating = false
	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

	if humanoid then
		diedConnection = humanoid.Died:Connect(function()
			DialogueController.close()
		end)
	end

	if localPlayer and character then
		characterRemovingConnection = localPlayer.CharacterRemoving:Connect(function(character2)
			if character2 == character then
				DialogueController.close()
			end
		end)
	end

	local _onRenderSteppedFn = converted._onRenderSteppedFn

	if _onRenderSteppedFn then
		local total = 0
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			total += dt

			if _onRenderSteppedFn(total) == true then
				total = 0
			end
		end)
	end

	local _openTop = converted:_openTop(state)

	if v ~= state then
		state:destroyPageMaids()
		return nil
	end

	if _openTop == nil or isLegacyFillerPage(_openTop) then
		DialogueController.close()
		return nil
	end

	state._npcLifecycleStarted = true
	DialogueController.notifyNPC(state, "onDialogueStarted")

	if v ~= state then
		return state
	end

	notifyLineChanged(state) -- equivalent call inferred; original call site unknown

	if v ~= state then
		return state
	end

	v4:render()

	if beginTerminatingIfNeeded(state) then
		return state
	end

	acquireHudLock(state) -- equivalent call inferred; original call site unknown

	while v == state and v2 ~= state do
		task.wait()
	end

	return state
end

function DialogueController.advance()
	local v4 = v

	if not v4 then
		return
	end

	local current = v4:getCurrent()

	if not current then
		DialogueController.close()
	elseif current:advanceText() then
		notifyLineChanged(v4) -- equivalent call inferred; original call site unknown
		v4._window:render()
		beginTerminatingIfNeeded(v4)
	elseif current._advancePage then
		local v5 = current:advancePage()

		if v5 == nil or isLegacyFillerPage(v5) then
			DialogueController.close()
			return
		end

		notifyLineChanged(v4) -- equivalent call inferred; original call site unknown
		v4._window:render()
		beginTerminatingIfNeeded(v4)
	elseif #current._options == 0 and current:getCancelOption() == nil then
		DialogueController.close()
	end
end

function DialogueController:select()
	local v4 = v

	if not v4 or self._locked then
		return
	end

	local jump = self:resolveJump(v4)

	if v ~= v4 then
		return
	end

	if jump == nil then
		if self._isCancel then
			Head.playAction("Bye")
		end

		DialogueController.close()
	else
		if isLegacyFillerPage(jump) then
			DialogueController.close()
			return
		end

		notifyLineChanged(v4) -- equivalent call inferred; original call site unknown
		v4._window:render()
		beginTerminatingIfNeeded(v4)
	end
end

function DialogueController.close()
	releaseHudLock() -- equivalent call inferred; original call site unknown
	local v4 = v

	if not v4 then
		Note.dismiss()
		return
	end

	v = nil

	if v2 == v4 then
		v2 = nil
	end

	DialogueController.Active = false
	DialogueController.Terminating = false

	if diedConnection then
		diedConnection:Disconnect()
		diedConnection = nil
	end

	if characterRemovingConnection then
		characterRemovingConnection:Disconnect()
		characterRemovingConnection = nil
	end

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	local current = v4:getCurrent()
	local success, result

	if current and current._onFinishedFn then
		success, result = pcall(current._onFinishedFn, current)
	else
		success = true
	end

	v4:destroyPageMaids()
	local _dialogue = v4._dialogue

	if _dialogue then
		if _dialogue._destroyMaid then
			_dialogue:_destroyMaid()
		end

		_dialogue._state = nil
	end

	v4._window._wantsToRender = false
	v4._window:render()
	Head.clear()
	Note.dismiss()

	if v4._npcLifecycleStarted then
		v4._npcLifecycleStarted = false
		DialogueController.notifyNPC(v4, "onDialogueEnded")
	end

	if not success then
		error(result, 0)
	end
end

function DialogueController.updateTitle(p: string)
	local v4 = v

	if v4 then
		v4:setTitle(p)
		v4._window:render()
	end
end

function DialogueController.updateTitleSprite(p: string?, p2: string?, p3)
	local v4 = v

	if not v4 then
		return
	end

	if p then
		local sprite = TextTags.sprite(p)

		if not sprite then
			warn("[DIALOGUE]", (`unknown title sprite "{p}"`))
			return
		end

		local spriteRight

		if p2 then
			spriteRight = TextTags.sprite(p2)
		end

		if p2 and not spriteRight then
			warn("[DIALOGUE]", (`unknown title sprite "{p2}"`))
		end

		v4:setTitleSprite({
			sprite = sprite,
			spriteRight = spriteRight,
			wiggle = p3 and p3.wiggle
		})
		v4._window:render()
	else
		v4:setTitleSprite(nil)
		v4._window:render()
	end
end

function DialogueController.updateSubtitle(p: string?)
	local v4 = v

	if v4 then
		v4:setSubtitle(p)
		v4._window:render()
	end
end

function DialogueController.addHead(p)
	Head.show(p)
end

DialogueController.playAction = Head.playAction

function DialogueController.showNote(p)
	if v then
		warn("[DIALOGUE]", "there's already an active dialogue")
	else
		Note.show(p)
	end
end

function DialogueController.hookNote(p, p2: string)
	Note.hook(p, p2)
end

function DialogueController.HookNote(_, p, p2: string)
	DialogueController.hookNote(p, p2)
end

function DialogueController.hideFrame()
	local v4 = v

	if v4 then
		v4._window._wantsToRender = false
		v4._window:render()
	end
end

function DialogueController.showFrame()
	local v4 = v

	if v4 then
		v4._window._wantsToRender = true
		v4._window:render()
	end
end

function DialogueController.hideWindow(flag: boolean?)
	local v4 = v

	if v4 then
		v4._window:setSlide(flag and "hidden" or "title")
	end
end

function DialogueController.unhideWindow()
	local v4 = v

	if v4 then
		v4._window:setSlide("shown")
	end
end

function DialogueController.resumeWhenCallbackFinishes(callback)
	local v4 = v
	DialogueController.hideFrame()
	releaseHudLock() -- equivalent call inferred; original call site unknown
	local v5 = nil
	local thread = task.spawn(function()
		v5 = callback()
	end)

	while coroutine.status(thread) ~= "dead" do
		task.wait()
	end

	if v ~= v4 then
		return
	end

	if v5 == false then
		DialogueController.close()
		return
	end

	local localPlayer = v4 and v2 ~= v4 and v == v4 and not v3 and Players.LocalPlayer

	if localPlayer then
		v3 = AttributeCounter.destroyable(localPlayer, "MenuHidden")
	end

	DialogueController.showFrame()
end

return DialogueController