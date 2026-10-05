local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Shared.Globals.Constants)
local GuardTutorialFlags = require(ReplicatedStorage.Shared.Flags.GuardTutorialFlags)
local GuardTutorialPresentation = require(ReplicatedStorage.Client.GuardTutorialPresentation)
local GuardTutorialSteps = require(ReplicatedStorage.Data.GuardTutorialSteps)
local GuardTutorial = require(ReplicatedStorage.Shared.Types.GuardTutorial)
local Log = require(ReplicatedStorage.Packages.Log)
local MilestoneAdapter = require(script.MilestoneAdapter)
local Promise = require(ReplicatedStorage.Packages.Promise)
local OnboardingTiming = require(ReplicatedStorage.Shared.Util.OnboardingTiming)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(script.Types.Interface)
local TryCall = require(ReplicatedStorage.Shared.Utils.TryCall)
local EquipEgg = require(script.Steps.EquipEgg)
local ExpandPen = require(script.Steps.ExpandPen)
local HatchEgg = require(script.Steps.HatchEgg)
local HeadToPen = require(script.Steps.HeadToPen)
local PlaceEgg = require(script.Steps.PlaceEgg)
local PlacePet = require(script.Steps.PlacePet)
local StealEgg = require(script.Steps.StealEgg)
local TreadmillIntro = require(script.Steps.TreadmillIntro)
local GuardTutorialController = {}
GuardTutorialController.__index = GuardTutorialController
GuardTutorialController.__class = "GuardTutorialController"
local v = {
	[StealEgg.StepId] = StealEgg,
	[HeadToPen.StepId] = HeadToPen,
	[EquipEgg.StepId] = EquipEgg,
	[PlaceEgg.StepId] = PlaceEgg,
	[HatchEgg.StepId] = HatchEgg,
	[PlacePet.StepId] = PlacePet,
	[ExpandPen.StepId] = ExpandPen,
	[TreadmillIntro.StepId] = TreadmillIntro
}
local v2 = Log.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function getProgressIndex(_readStoredProgress)
	if _readStoredProgress.Completed then
		return 1e999
	end

	local currentStepId = _readStoredProgress.CurrentStepId

	if currentStepId == nil then
		return 0
	end

	return GuardTutorialSteps.GetIndex(currentStepId) or 0
end

function GuardTutorialController.new()
	local self = setmetatable({}, GuardTutorialController)
	self._activeStepCleanup = nil
	self._activeStepId = nil
	self._adapter = MilestoneAdapter.new()
	self._currentProgress = GuardTutorial.CopyProgress(GuardTutorial.DEFAULT_PROGRESS)
	self._lastStoredIndex = nil
	self._presentation = GuardTutorialPresentation.new()
	self._refreshGeneration = 0
	self._retryScheduled = false
	self._runtimeEnabled = false
	self._runtimeRevision = -1
	self._runtimeStateReady = false
	self._runtimeStateRequestPending = false
	self._pauseNotificationShown = false
	self._pausedForAdminAbuse = false
	self._started = false
	self._trove = Trove.new()
	return self
end

function GuardTutorialController:_clearActiveStep()
	local _activeStepCleanup = self._activeStepCleanup

	if _activeStepCleanup ~= nil then
		self._activeStepCleanup = nil
		_activeStepCleanup()
	end

	self._presentation:DropEverything()
	self._activeStepId = nil
end

function GuardTutorialController:_maybeShowPauseNotification()
	if self._pauseNotificationShown or not self._runtimeStateReady or self._runtimeEnabled or not (self._pausedForAdminAbuse and GuardTutorialFlags.PauseNotificationEnabled:Get() and Save.IsLoaded()) then
		return
	end

	if self:_readStoredProgress().Completed then
		return
	end

	self._pauseNotificationShown = true
	local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
	Toast.Show({
		Lane = "Banner",
		Text = "Tutorial paused during Admin Abuse. It will resume after the event.",
		Seconds = 5,
		Color = Color3.new(1, 1, 1),
		ShowShadow = true,
		Unique = true
	})
end

function GuardTutorialController:_applyRuntimeState(data)
	if data.Revision < self._runtimeRevision then
		return
	end

	local _runtimeStateReady = self._runtimeStateReady
	local _runtimeEnabled = self._runtimeEnabled
	self._runtimeEnabled = data.Enabled
	self._runtimeRevision = data.Revision
	self._runtimeStateReady = true
	OnboardingTiming.Mark("TutorialRuntimeReady")
	self._pausedForAdminAbuse = data.PausedForAdminAbuse

	if not data.PausedForAdminAbuse then
		self._pauseNotificationShown = false
	end

	if data.Enabled then
		if not (_runtimeStateReady and _runtimeEnabled) then
			self:RefreshProgress()
		end
	else
		self:_clearActiveStep()
		self._refreshGeneration += 1
		self:_maybeShowPauseNotification()
	end
end

function GuardTutorialController:_requestRuntimeState()
	if self._runtimeStateRequestPending then
		return false
	end

	self._runtimeStateRequestPending = true
	local v3, v4 = Promise.try(function()
		return Remotes.GuardOnboarding.AskLiveState:InvokeServer()
	end):timeout(30):await()
	self._runtimeStateRequestPending = false

	if not (v3 and self._started and GuardTutorial.SchemaValidation.RuntimeState(v4)) then
		return false
	end

	self:_applyRuntimeState(v4)
	return true
end

function GuardTutorialController:_queueRuntimeStateRetry()
	if self._runtimeStateReady or not self._started then
		return
	end

	local v3 = nil
	v3 = Timer.Simple(0.5, function()
		if not self._started or self._runtimeStateReady or self:_requestRuntimeState() then
			local connection = v3

			if connection ~= nil then
				connection:Disconnect()
			end
		end
	end)
	self._trove:Add(v3)
end

function GuardTutorialController:_readStoredProgress()
	local v3 = Save.Await()

	if v3 == nil then
		return GuardTutorial.CopyProgress(GuardTutorial.DEFAULT_PROGRESS)
	end

	return GuardTutorial.SanitizeProgress(v3.GuardTutorialProgress)
end

function GuardTutorialController:_syncProgress(p)
	local v3, v4, v5 = TryCall(function()
		return Remotes.GuardOnboarding.AskProgressSync:InvokeServer(p)
	end)

	if not (v3 and v4 == true) then
		return nil
	end

	local progress, v6 = GuardTutorial.SchemaValidation.Progress(v5)
	assert(progress, v6)
	return GuardTutorial.SanitizeProgress(v5)
end

function GuardTutorialController:_queueSyncRetry()
	if self._retryScheduled or not (self._started and self._runtimeStateReady and self._runtimeEnabled) then
		return
	end

	v2:AtTrace():Log("[GuardTutorialController] Queueing tutorial progress sync retry")
	self._retryScheduled = true
	task.delay(0.5, function()
		if self._started and self._runtimeStateReady and self._runtimeEnabled then
			self._retryScheduled = false
			self:RefreshProgress()
		else
			self._retryScheduled = false
		end
	end)
end

function GuardTutorialController:_resolveNextProgress(p2)
	if p2.Completed then
		return GuardTutorial.CopyProgress(p2)
	end

	if self._currentProgress.Completed then
		return {
			Completed = true,
			CurrentStepId = nil
		}
	end

	local orderedStepIds = GuardTutorialSteps.GetOrderedStepIds()
	local v3

	if p2.CurrentStepId == nil then
		v3 = 1
	else
		v3 = GuardTutorialSteps.GetIndex(p2.CurrentStepId)
		assert(v3 ~= nil, (`Unknown guard tutorial step id: {p2.CurrentStepId}`))
	end

	local currentStepId = self._currentProgress.CurrentStepId

	if currentStepId ~= nil then
		local index = GuardTutorialSteps.GetIndex(currentStepId)

		if index ~= nil and v3 < index then
			v3 = index
		end
	end

	for i = v3, #orderedStepIds do
		local orderedStepId = orderedStepIds[i]
		local v4 = v[orderedStepId]
		assert(v4 ~= nil, (`Missing guard tutorial step module for {orderedStepId}`))

		if not v4.IsSatisfied(self._adapter) then
			return {
				Completed = false,
				CurrentStepId = orderedStepId
			}
		end
	end

	return {
		Completed = true,
		CurrentStepId = nil
	}
end

function GuardTutorialController:_bindCurrentStep()
	local currentStepId = self._currentProgress.CurrentStepId

	if self._currentProgress.Completed or currentStepId == nil then
		self:_clearActiveStep()
		return
	end

	if self._activeStepId == currentStepId and self._activeStepCleanup ~= nil then
		return
	end

	self:_clearActiveStep()
	local v3 = v[currentStepId]
	assert(v3 ~= nil, (`Missing guard tutorial step module for {currentStepId}`))
	self._activeStepId = currentStepId
	local v4

	if v3.Present == nil then
		v4 = nil
	else
		v4 = v3.Present(self._presentation, self._adapter)
	end

	local v5 = v3.Bind(self._adapter, function()
		if self._currentProgress.Completed or self._currentProgress.CurrentStepId ~= currentStepId then
			return
		end

		self:RefreshProgress()
	end)

	function self._activeStepCleanup()
		v5()

		if v4 ~= nil then
			v4()
		end

		self._presentation:DropEverything()
	end
end

function GuardTutorialController:_startAfterReadiness()
	local _readStoredProgress = self:_readStoredProgress()
	self._currentProgress = _readStoredProgress

	if _readStoredProgress.Completed then
		self:_clearActiveStep()
		return
	end

	self:RefreshProgress()
	self:_maybeShowPauseNotification()
end

function GuardTutorialController:Start()
	if self._started then
		return
	end

	self._started = true
	self._trove:Add(Remotes.GuardOnboarding.LiveStateShifted.OnClientEvent:Connect(function(p)
		if GuardTutorial.SchemaValidation.RuntimeState(p) then
			self:_applyRuntimeState(p)
		end
	end))
	self._trove:Add(GuardTutorialFlags.PauseNotificationEnabled.Changed:Connect(function(flag: boolean)
		if flag then
			self:_maybeShowPauseNotification()
		else
			self._pauseNotificationShown = false
		end
	end))
	task.spawn(function()
		if not self:_requestRuntimeState() then
			self:_queueRuntimeStateRetry()
		end
	end)
	self._trove:Add(self._adapter.Changed:Connect(function()
		self:RefreshProgress()
	end))
	self._trove:Add(Save.Watch("GuardTutorialProgress"):Connect(function()
		self:RefreshProgress()
	end))

	if Save.IsLoaded() then
		self:_startAfterReadiness()
		return
	end

	local loadedConnection = Save.Loaded:Connect(function()
		self:_startAfterReadiness()
	end)
	self._trove:Add(loadedConnection)

	if Save.IsLoaded() then
		loadedConnection:Disconnect()
		self:_startAfterReadiness()
	end
end

function GuardTutorialController:RefreshProgress()
	if not (self._started and self._runtimeStateReady and self._runtimeEnabled and Save.IsLoaded()) then
		return
	end

	self._refreshGeneration += 1
	local _refreshGeneration = self._refreshGeneration
	local _readStoredProgress = self:_readStoredProgress()
	local progressIndex = getProgressIndex(_readStoredProgress) -- equivalent call inferred; original call site unknown

	if self._lastStoredIndex ~= nil and progressIndex < self._lastStoredIndex then
		self._currentProgress = GuardTutorial.CopyProgress(_readStoredProgress)
	end

	self._lastStoredIndex = progressIndex
	local _resolveNextProgress = self:_resolveNextProgress(_readStoredProgress)
	local v3 = _readStoredProgress.Completed ~= _resolveNextProgress.Completed or _readStoredProgress.CurrentStepId ~= _resolveNextProgress.CurrentStepId
	self._currentProgress = _resolveNextProgress
	self:_bindCurrentStep()

	if self._activeStepId ~= nil then
		OnboardingTiming.Mark("FirstStepBound")
	end

	if v3 then
		local _syncProgress = self:_syncProgress(_resolveNextProgress)

		if not self._started or _refreshGeneration ~= self._refreshGeneration then
			return
		end

		if _syncProgress == nil then
			self:_queueSyncRetry()
		else
			self._currentProgress = _syncProgress
			self:_bindCurrentStep()
		end
	end
end

function GuardTutorialController:Destroy()
	self._started = false
	self:_clearActiveStep()
	self._trove:Destroy()
	self._presentation:Destroy()
	self._adapter:Destroy()
end

return GuardTutorialController