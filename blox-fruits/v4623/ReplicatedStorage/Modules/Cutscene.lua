local v = {
	Http = game:GetService("HttpService"),
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	ServerScriptService = game:GetService("ServerScriptService"),
	ServerStorage = game:GetService("ServerStorage")
}
local modules = {
	Maid = require(game.ReplicatedStorage.Util.Maid),
	Signal = require(game.ReplicatedStorage.Util.Signal),
	CutsceneEnvironment = require(script.CutsceneEnvironment),
	EnvironmentTransition = require(script.EnvironmentTransition)
}

if v.RunService:IsClient() then
	modules.AttributeCounter = require(game.ReplicatedStorage.Util.AttributeCounter)
	modules.CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
	modules.DialogueController = require(game.ReplicatedStorage.DialogueController)
	modules.Sound = require(game.ReplicatedStorage.Util.Sound)
	modules.Effect = require(game.ReplicatedStorage.Effect)
	modules.CutsceneNpc = require(script.CutsceneNpc)
	modules.EnvironmentPresets = require(script.CutsceneEnvironment.Presets)
	modules.EnvironmentTransitionPresets = require(script.EnvironmentTransition.Presets)
	modules.Animation = require(script.CutsceneUtil.Animation)
	modules.Input = require(script.CutsceneUtil.Input)
	modules.Wait = require(script.CutsceneUtil.Wait)
end

require(script.Types)
local v3 = {
	CutsceneEnvironment = modules.CutsceneEnvironment,
	EnvironmentTransition = modules.EnvironmentTransition
}
v3.__index = v3
local v4 = {}
local frozen = table.freeze({ Enum.KeyCode.Space, Enum.KeyCode.Escape, Enum.KeyCode.ButtonB })
local v5 = nil
local count = 0

function v4.normalizeConfig(options)
	local v6 = options or {}
	local cameraWeight = v6.CameraWeight or 1
	local cameraBlendInTime = v6.CameraBlendInTime or 0.35
	local cameraBlendOutTime = v6.CameraBlendOutTime or 0.35
	local v7

	if cameraWeight >= 0 then
		v7 = cameraWeight <= 1
	else
		v7 = false
	end

	assert(v7, "Cutscene CameraWeight must be between zero and one")
	assert(cameraBlendInTime >= 0, "Cutscene CameraBlendInTime must be non-negative")
	assert(cameraBlendOutTime >= 0, "Cutscene CameraBlendOutTime must be non-negative")
	local clone = table.clone(v6.SkipKeyCodes or frozen)

	for _, v8 in clone do
		local v9

		if typeof(v8) == "EnumItem" then
			v9 = v8.EnumType == Enum.KeyCode
		else
			v9 = false
		end

		assert(v9, "Cutscene SkipKeyCodes must contain KeyCodes")
	end

	local touchSkipButton = v6.TouchSkipButton or {}
	local dependencies = v6.Dependencies or {}
	local clone2 = table.clone(dependencies.Environments or {})
	local v8 = {}

	for _, v9 in clone2 do
		local v10

		if typeof(v9) == "string" then
			v10 = v9 ~= ""
		else
			v10 = false
		end

		assert(v10, "Environment dependencies must be names")
		assert(not v8[v9], (`Duplicate environment dependency "{v9}"`))
		v8[v9] = true
	end

	return {
		Camera = v6.Camera,
		CameraWeight = cameraWeight,
		CameraBlendInTime = cameraBlendInTime,
		CameraBlendOutTime = cameraBlendOutTime,
		FadeToBlackOnFinish = v6.FadeToBlackOnFinish ~= false,
		SkipEnabled = v6.SkipEnabled ~= false,
		SkipKeyCodes = clone,
		TouchSkipButton = {
			Enabled = touchSkipButton.Enabled ~= false,
			Title = touchSkipButton.Title or "Skip",
			Description = touchSkipButton.Description,
			Position = touchSkipButton.Position or UDim2.fromScale(0.86, 0.72),
			Image = touchSkipButton.Image
		},
		Dependencies = {
			Environments = clone2
		}
	}
end

function v4.getCutscenesFolder()
	local cutscenes = v.ServerScriptService:FindFirstChild("Cutscenes")

	if cutscenes and cutscenes:IsA("Folder") then
		return cutscenes
	end

	return nil
end

function v4.isSourceModule(instance)
	local cutscenesFolder = v4.getCutscenesFolder()
	return cutscenesFolder ~= nil and instance:IsDescendantOf(cutscenesFolder)
end

function v4.findCallerSourceModule()
	local cutscenesFolder = v4.getCutscenesFolder()

	if not cutscenesFolder then
		return nil
	end

	for i = 3, 100 do
		local v6 = debug.info(i, "f")

		if v6 == nil then
			break
		end

		if typeof(v6) ~= "function" then
			continue
		end

		local v7 = getfenv(v6)
		local script2 = v7 and v7.script

		if typeof(script2) == "Instance" and script2:IsA("ModuleScript") and script2:IsDescendantOf(cutscenesFolder) then
			return script2
		end
	end

	return nil
end

function v4:findSourceModule()
	local _sourceModule = self._sourceModule

	if _sourceModule and _sourceModule.Parent and v4.isSourceModule(_sourceModule) then
		return _sourceModule
	end

	local cutscenesFolder = v4.getCutscenesFolder()

	if not cutscenesFolder then
		return nil
	end

	for _, moduleScript in cutscenesFolder:GetDescendants() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local success, result = pcall(require, moduleScript)

		if not (success and result == self) then
			continue
		end

		self._sourceModule = moduleScript
		return moduleScript
	end

	return nil
end

function v4.resolveEnvironmentTemplates(p, instance)
	local modelsByChildName = {}

	for _, childName in p.Dependencies.Environments do
		local model = instance:FindFirstChild(childName) or instance:WaitForChild(childName, 10)
		assert(
			model and model:IsA("Model"),
			(`Replicated cutscene environment "{childName}" is missing or is not a Model`)
		)
		modelsByChildName[childName] = model
	end

	return modelsByChildName
end

function v4.createPlayback()
	count += 1
	local maid = modules.Maid.new()
	local signal = modules.Signal()
	maid:GiveTask(signal)
	return {
		Id = count,
		Maid = maid,
		Cancelled = signal,
		SceneFolder = nil,
		CameraController = nil,
		CameraSnapshot = nil,
		Character = nil,
		Humanoid = nil,
		MovementMarker = nil,
		PreviousAutoRotate = nil,
		Controls = nil,
		ControlsWereEnabled = false,
		MenuHiddenLock = nil,
		DialogueState = nil,
		DialogueEntity = nil,
		RunnerThread = nil,
		ReturnMaid = nil,
		ReturnCancelled = nil,
		ReturnThread = nil,
		Returning = false,
		TeardownComplete = false,
		CancellationFired = false,
		Finalized = false
	}
end

function v4:resolveEnvironment(name)
	if typeof(name) ~= "string" then
		assert(modules.CutsceneEnvironment.is(name), "Expected a CutsceneEnvironment or environment preset name")
		return name
	end

	local _dependencyEnvironment = self._dependencyEnvironments[name]

	if _dependencyEnvironment then
		return _dependencyEnvironment
	end

	local _environmentTemplate = self._environmentTemplates[name]

	if not _environmentTemplate then
		return modules.EnvironmentPresets.create(name)
	end

	local cutsceneEnvironment = modules.CutsceneEnvironment.new({
		Name = name,
		Template = _environmentTemplate
	})
	self._dependencyEnvironments[name] = cutsceneEnvironment
	return cutsceneEnvironment
end

function v4.resolveEnvironmentTransition(value)
	if typeof(value) == "string" then
		return modules.EnvironmentTransitionPresets.get(value)
	end

	assert(modules.EnvironmentTransition.is(value), "Expected an EnvironmentTransition or transition preset name")
	return value
end

function v4:ownEnvironment(instance)
	if self._environments[instance] then
		return
	end

	self._environments[instance] = true
	self._maid:GiveTask(function()
		self._environments[instance] = nil

		if self._environment == instance then
			self._environment = nil
		end

		instance:Destroy()
	end)
end

function v4:bindEnvironment(p, object)
	function p.Maid.Environment()
		if self._environment == object then
			self._environment = nil
		end

		object:Unload()
	end

	p.Maid.EnvironmentFailure = object.Failed.Event:Connect(function(p2: string)
		if self._playback == p and self._environment == object then
			v4.finish(self, p, "Failed", p2)
		end
	end)
end

function v4.getControls()
	local localPlayer = v.Players.LocalPlayer
	local playerScripts = localPlayer and localPlayer:FindFirstChild("PlayerScripts") or localPlayer and localPlayer:WaitForChild(
		"PlayerScripts",
		5
	)
	local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule") or playerScripts and playerScripts:WaitForChild(
		"PlayerModule",
		5
	)

	if not (playerModule and playerModule:IsA("ModuleScript")) then
		return nil
	end

	local success, result = pcall(function()
		local module = require(playerModule)
		return module:GetControls()
	end)

	if success then
		return result
	end

	return nil
end

function v4:disableMovement()
	local character = v.Players.LocalPlayer.Character
	self.Character = character

	if not character then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = "DisableMovement"
	folder:SetAttribute("CutsceneOwned", self.Id)
	folder.Parent = character
	self.MovementMarker = folder
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	self.Humanoid = humanoid

	if humanoid then
		self.PreviousAutoRotate = humanoid.AutoRotate
		humanoid.AutoRotate = false
	end

	local controls = v4.getControls()
	self.Controls = controls

	if controls then
		local activeController = controls:GetActiveController()
		self.ControlsWereEnabled = activeController ~= nil and activeController.enabled == true
		controls:Disable()
	end
end

function v4:restoreMovement()
	local movementMarker = self.MovementMarker
	self.MovementMarker = nil

	if movementMarker then
		movementMarker:Destroy()
	end

	local character = self.Character
	local v6

	if character == nil or character.Parent == nil then
		v6 = false
	else
		v6 = character:FindFirstChild("DisableMovement") == nil
	end

	local humanoid = self.Humanoid

	if v6 and humanoid and humanoid.Parent and self.PreviousAutoRotate ~= nil then
		humanoid.AutoRotate = self.PreviousAutoRotate
	end

	if v6 and self.ControlsWereEnabled and self.Controls then
		self.Controls:Enable()
	end

	self.Character = nil
	self.Humanoid = nil
	self.Controls = nil
end

function v4:closeOwnedDialogue()
	local dialogueEntity = self.DialogueEntity
	local dialogueState = self.DialogueState or dialogueEntity and dialogueEntity._state

	if dialogueState and modules.DialogueController.getActiveDialogue() == dialogueState then
		modules.DialogueController.close()
	end

	self.DialogueState = nil
	self.DialogueEntity = nil
end

function v4:releaseCamera(p2: number)
	local cameraController = self.CameraController
	self.CameraController = nil

	if not cameraController then
		return
	end

	local success, result = pcall(function()
		cameraController:ClearCameraTarget()
		cameraController:FadeOut(p2)
	end)

	if not success then
		warn((`[Cutscene] Camera restoration failed: {tostring(result)}`))
		pcall(cameraController.Destroy, cameraController)
	end
end

function v4:fireCancellation(p)
	if self.CancellationFired then
		return
	end

	self.CancellationFired = true
	self.Cancelled:Fire(p)
end

function v4:teardownPlayback(p: number)
	if self.TeardownComplete then
		return
	end

	self.TeardownComplete = true
	v4.closeOwnedDialogue(self)
	v4.releaseCamera(self, p)
	self.Maid:DoCleaning()
	v4.restoreMovement(self)
	local menuHiddenLock = self.MenuHiddenLock
	self.MenuHiddenLock = nil

	if menuHiddenLock then
		menuHiddenLock:Destroy()
	end
end

function v4:finishImmediate(state2, lastStatus, lastError: string?, flag: boolean?)
	if state2.Finalized then
		return false
	end

	state2.Finalized = true
	v4.fireCancellation(state2, lastStatus)
	local returnCancelled = state2.ReturnCancelled

	if returnCancelled then
		returnCancelled:Fire(lastStatus)
	end

	v4.teardownPlayback(state2, self._config.CameraBlendOutTime)
	local returnMaid = state2.ReturnMaid
	state2.ReturnMaid = nil
	state2.ReturnCancelled = nil

	if returnMaid then
		returnMaid:DoCleaning()
	end

	if v5 == self then
		v5 = nil
	end

	if self._playback == state2 then
		self._playback = nil
	end

	self._lastStatus = lastStatus
	self._lastError = lastError
	local runnerThread = state2.RunnerThread
	local returnThread = state2.ReturnThread
	local thread = coroutine.running()
	state2.RunnerThread = nil
	state2.ReturnThread = nil

	if runnerThread and runnerThread ~= thread then
		pcall(task.cancel, runnerThread)
	end

	if returnThread and returnThread ~= thread then
		pcall(task.cancel, returnThread)
	end

	self.Finished:Fire(lastStatus, lastError)

	if runnerThread == thread and lastStatus ~= "Completed" and lastStatus ~= "Failed" and not flag then
		task.cancel(thread)
	end

	return true
end

function v4:getReturnEnvironment()
	local _environment = self._environment

	if _environment then
		return _environment
	end

	local cutsceneEnvironment = modules.CutsceneEnvironment.new({
		Name = "ReturnToGameplay"
	})
	v4.ownEnvironment(self, cutsceneEnvironment)
	return cutsceneEnvironment
end

function v4.runReturnTransition(p, data, p2, p3: string?)
	local v6 = assert(data.ReturnMaid, "Cutscene return cleanup is unavailable")
	local v7 = assert(data.ReturnCancelled, "Cutscene return cancellation is unavailable")
	v4.resolveEnvironmentTransition("FadeToBlack"):_execute(function()
		local returnEnvironment = v4.getReturnEnvironment(p)
		v4.teardownPlayback(data, 0)
		return returnEnvironment
	end, nil, v7.Event, v6)

	if data.Finalized then
		return
	end

	assert(data.TeardownComplete, "Cutscene return transition did not restore gameplay")
	v4.finishImmediate(p, data, p2, p3)
end

function v4.beginReturn(p, state, p2, p3: string?, flag: boolean?)
	if state.Returning then
		return false
	end

	state.Returning = true
	local maid = modules.Maid.new()
	local signal = modules.Signal()
	maid:GiveTask(signal)
	state.ReturnMaid = maid
	state.ReturnCancelled = signal
	v4.fireCancellation(state, p2)
	local runnerThread = state.RunnerThread
	local thread = coroutine.running()
	state.RunnerThread = nil
	state.ReturnThread = task.defer(function()
		local v6, v7 = xpcall(function()
			v4.runReturnTransition(p, state, p2, p3)
		end, debug.traceback)

		if v6 or state.Finalized then
			return
		end

		warn((`[Cutscene] Return transition failed: {tostring(v7)}`))
		v4.finishImmediate(p, state, "Failed", (tostring(v7)))
	end)

	if runnerThread and runnerThread ~= thread then
		pcall(task.cancel, runnerThread)
	end

	if runnerThread == thread and p2 ~= "Completed" and p2 ~= "Failed" and not flag then
		task.cancel(thread)
	end

	return true
end

function v4:finish(p2, p3, p4: string?, flag: boolean?, flag2: boolean?)
	if p2.Finalized then
		return false
	end

	if flag2 or not self._config.FadeToBlackOnFinish then
		return v4.finishImmediate(self, p2, p3, p4, flag)
	end

	return v4.beginReturn(self, p2, p3, p4, flag)
end

function v4:setupPlayback(player)
	if modules.DialogueController.getActiveDialogue() then
		modules.DialogueController.close()
	end

	local localPlayer = v.Players.LocalPlayer
	local folder = Instance.new("Folder")
	folder.Name = `Cutscene_{localPlayer.UserId}_{player.Id}`
	folder:SetAttribute("LocalCutscene", true)
	folder.Parent = workspace
	player.SceneFolder = folder
	player.Maid:GiveTask(folder)
	local camera = self._config.Camera or workspace.CurrentCamera
	assert(camera, "Cutscene requires workspace.CurrentCamera")
	player.CameraSnapshot = {
		CFrame = camera.CFrame,
		CameraType = camera.CameraType,
		FieldOfView = camera.FieldOfView
	}
	player.CameraController = modules.CameraController.new(
		camera,
		self._config.CameraWeight,
		self._config.CameraBlendInTime
	)
	player.MenuHiddenLock = modules.AttributeCounter.destroyable(localPlayer, "MenuHidden")
	v4.disableMovement(player)
	local character = player.Character
	local humanoid = player.Humanoid

	if humanoid then
		player.Maid:GiveTask(humanoid.Died:Connect(function()
			if self._playback == player then
				v4.finish(self, player, "Cancelled", nil, nil, true)
			end
		end))
	end

	player.Maid:GiveTask(localPlayer.CharacterRemoving:Connect(function(character2)
		if character2 == character and self._playback == player then
			v4.finish(self, player, "Cancelled", nil, nil, true)
		end
	end))

	if self._config.SkipEnabled then
		player.Maid:GiveTask(modules.Input.bindSkip(
			`CutsceneSkip_{player.Id}`,
			self._config.SkipKeyCodes,
			self._config.TouchSkipButton,
			function()
				if self._playback == player then
					v4.finish(self, player, "Skipped", nil)
				end
			end
		))
	end
end

function v4:getPlayback(p2: string)
	local _playback = self._playback
	assert(_playback and not _playback.Finalized, (`Cutscene:{p2}() requires active playback`))
	return _playback
end

function v4.getCameraController(p, p2: string)
	local playback = v4.getPlayback(p, p2)
	local cameraController = playback.CameraController
	assert(cameraController, (`Cutscene:{p2}() cannot run after the camera was restored`))
	return playback, cameraController
end

function v4.resolveNpcModel(model)
	if model == nil then
		return nil
	end

	if modules.CutsceneNpc.is(model) then
		return model:GetModel()
	end

	local v6

	if typeof(model) == "Instance" then
		v6 = model:IsA("Model")
	else
		v6 = false
	end

	assert(v6, "Expected a CutsceneNpc or Model")
	return model
end

function v4.getDisplayName(instance)
	local displayName = instance:GetAttribute("DisplayName")

	if typeof(displayName) == "string" and displayName ~= "" then
		return displayName
	end

	return instance.Name
end

function v4.buildDialogue(data, p)
	assert(typeof(data.Text) == "string", "Cutscene dialogue Text must be a string")
	assert(data.Duration == nil or data.Duration >= 0, "Cutscene dialogue Duration must be non-negative")
	local dialogueController = modules.DialogueController.new()
	dialogueController:setTitle(data.Title or not p and "" or v4.getDisplayName(p) or "")

	if data.Subtitle ~= nil then
		dialogueController:setSubtitle(data.Subtitle)
	end

	local head = data.Head or p
	dialogueController:addPage(function(object)
		object:addText(data.Text)
		object:noCancel()

		if data.Skippable == false then
			object:noSkip()
		end

		if head then
			object:setHead(head)
		end

		if data.Duration ~= nil then
			object:advanceAfterDelay(data.Duration)
		end
	end)
	return dialogueController:build()
end

function v4:attachDialogueHead(p2)
	local _pages = self._pages

	if typeof(_pages) ~= "table" then
		return nil
	end

	local buildsBy_page = {}

	for _, _page in _pages do
		local build = _page.build

		if typeof(build) ~= "function" then
			continue
		end

		buildsBy_page[_page] = build
		local build2 = build

		function _page:build()
			build2(self)

			if self._floatingHead == nil then
				self:setHead(p2)
			end
		end
	end

	return function()
		for k, build in buildsBy_page do
			k.build = build
		end
	end
end

function v4.showDialogue(_, state, dialogueEntity, p)
	local npcModel = v4.resolveNpcModel(p)
	local v6

	if typeof(dialogueEntity) == "table" then
		v6 = typeof((rawget(dialogueEntity, "Text"))) == "string"
	else
		v6 = false
	end

	if v6 then
		dialogueEntity = v4.buildDialogue(dialogueEntity, npcModel)
	end

	assert(typeof(dialogueEntity) == "table", "Cutscene:ShowDialogue() expected a dialogue or DialogueConfig")

	if not v6 and dialogueEntity._built == false then
		dialogueEntity:build()
	end

	v4.closeOwnedDialogue(state)

	if modules.DialogueController.getActiveDialogue() then
		modules.DialogueController.close()
	end

	if npcModel and not v6 then
		state.Maid.DialogueHeadRestore = v4.attachDialogueHead(dialogueEntity, npcModel)
	end

	local v7 = false
	local v8 = nil
	local v9 = nil
	state.DialogueEntity = dialogueEntity
	local thread = task.defer(function()
		if state.Finalized then
			v7 = true
			return
		end

		local success, result = pcall(modules.DialogueController.start, dialogueEntity)

		if success then
			v8 = result
		else
			v9 = result
		end

		v7 = true
	end)
	state.Maid.DialogueThread = thread

	if not modules.Wait.untilCondition(function()
		return v7 or dialogueEntity._state ~= nil
	end, state.Cancelled.Event) then
		return false
	end

	if v9 ~= nil then
		error(v9, 0)
	end

	local _state = dialogueEntity._state or v8

	if _state == nil then
		state.Maid.DialogueThread = nil
		state.Maid.DialogueHeadRestore = nil
		state.DialogueEntity = nil
		return false
	else
		state.DialogueState = _state
		local untilCondition = modules.Wait.untilCondition(function()
			return modules.DialogueController.getActiveDialogue() ~= _state
		end, state.Cancelled.Event)
		state.DialogueState = nil
		state.DialogueEntity = nil
		state.Maid.DialogueThread = nil
		state.Maid.DialogueHeadRestore = nil
		return untilCondition and not state.Finalized
	end
end

function v4.resolveSoundLocation(model)
	if modules.CutsceneNpc.is(model) then
		local model2 = model:GetModel()
		return model2.PrimaryPart or model2:GetPivot()
	end

	if typeof(model) == "Instance" and model:IsA("Model") then
		return model.PrimaryPart or model:GetPivot()
	end

	return model
end

function v4.registerDisposable(p, p2)
	if p2 ~= nil then
		p.Maid:GiveTask(p2)
	end
end

function v4:cloneInstance()
	local archivable = self.Archivable
	self.Archivable = true
	local success, result = pcall(self.Clone, self)
	self.Archivable = archivable

	if not success then
		error(`Failed to clone "{self:GetFullName()}": {tostring(result)}`, 3)
	end

	return result
end

function v4:createReplicationPackage(instance, p2)
	local playerGui = instance:FindFirstChildOfClass("PlayerGui") or instance:WaitForChild("PlayerGui", 10)
	assert(playerGui and playerGui:IsA("PlayerGui"), (`PlayerGui is unavailable for {instance.Name}`))
	local folder = Instance.new("Folder")
	folder.Name = `Cutscene_{p2.Name}_{v.Http:GenerateGUID(false)}`
	folder:SetAttribute("CutscenePackage", true)
	folder:SetAttribute("CutsceneName", p2.Name)
	local instance2 = v4.cloneInstance(p2)
	instance2.Name = "Cutscene"
	instance2.Parent = folder
	local folder2 = Instance.new("Folder")
	folder2.Name = "Environments"
	folder2.Parent = folder
	local cutsceneEnvironments = v.ServerStorage:FindFirstChild("CutsceneEnvironments")

	for _, childName in self._config.Dependencies.Environments do
		assert(cutsceneEnvironments, "ServerStorage.CutsceneEnvironments is unavailable")
		local model = cutsceneEnvironments:FindFirstChild(childName)
		assert(model and model:IsA("Model"), (`Cutscene environment "{childName}" is missing or is not a Model`))
		local instance3 = v4.cloneInstance(model)
		instance3.Name = childName
		instance3.Parent = folder2
	end

	local runner = script:FindFirstChild("Runner")
	assert(runner and runner:IsA("LocalScript"), "Cutscene runner is unavailable")
	local instance_2 = v4.cloneInstance(runner)
	instance_2.Parent = folder
	folder.Parent = playerGui
	return folder
end

function v3.new(p)
	local config = v4.normalizeConfig(p)
	local maid = modules.Maid.new()
	local signal = modules.Signal()
	local sourceModule

	if v.RunService:IsServer() then
		sourceModule = v4.findCallerSourceModule()
	end

	local self = setmetatable({
		_maid = maid,
		_config = config,
		_playback = nil,
		_environments = {},
		_dependencyEnvironments = {},
		_environmentTemplates = {},
		_environment = nil,
		_runner = nil,
		_sourceModule = sourceModule,
		_runCount = 0,
		_lastStatus = nil,
		_lastError = nil,
		_destroyed = false,
		Finished = signal
	}, v3)
	maid:GiveTask(signal)
	return self
end

function v3.is(p)
	return typeof(p) == "table" and getmetatable(p) == v3
end

function v3:_bindSourceModule(moduleScript)
	assert(v.RunService:IsServer(), "Cutscene source modules can only be bound on the server")
	assert(v3.is(self), "Expected a Cutscene.new() result")
	assert(moduleScript:IsA("ModuleScript") and v4.isSourceModule(moduleScript), "Invalid cutscene source module")
	self._sourceModule = moduleScript
end

function v3:_bindReplicatedEnvironmentFolder(folder)
	assert(v3.is(self), "Expected a Cutscene.new() result")
	assert(folder:IsA("Folder"), "Expected a replicated environment Folder")
	self._environmentTemplates = v4.resolveEnvironmentTemplates(self._config, folder)
end

function v3._runReplicated(instance, instance2)
	assert(v.RunService:IsClient(), "Replicated cutscenes can only run on the client")
	assert(instance:IsDescendantOf(instance2), "Cutscene source module must belong to its package")
	local environments = instance2:FindFirstChild("Environments") or instance2:WaitForChild("Environments", 10)
	assert(environments and environments:IsA("Folder"), "Cutscene package has no environment folder")
	local v6, v7 = xpcall(function()
		return require(instance)
	end, debug.traceback)

	if not v6 then
		error(v7, 2)
	end

	assert(v3.is(v7), (`"{instance.Name}" must return Cutscene.new()`))
	v7:_bindReplicatedEnvironmentFolder(environments)

	if v7._runCount == 0 then
		v7:Run()
	end

	local v8, v9 = v7:AwaitFinished()
	v7:Destroy()
	return v8, v9
end

function v4:play(callback)
	assert(not self._destroyed, "Cutscene is destroyed")
	assert(typeof(callback) == "function", "Cutscene:Play() requires a callback")
	self._runCount += 1
	local v6 = v5

	if v6 and v6._playback then
		v4.finish(v6, v6._playback, "Replaced", nil, nil, true)
	end

	local playback = v4.createPlayback()
	self._playback = playback
	self._lastStatus = nil
	self._lastError = nil
	v5 = self
	local v7, v8 = xpcall(function()
		v4.setupPlayback(self, playback)
	end, debug.traceback)

	if v7 then
		playback.RunnerThread = task.defer(function()
			local v9, v10 = xpcall(function()
				callback(self)
			end, debug.traceback)

			if playback.Finalized then
				return
			end

			if v9 then
				v4.finish(self, playback, "Completed", nil)
				return
			end

			warn((`[Cutscene] Runner failed: {tostring(v10)}`))
			v4.finish(self, playback, "Failed", (tostring(v10)))
		end)
		return self
	end

	v4.finish(self, playback, "Failed", tostring(v8), nil, true)
	return self
end

function v3:Run(runner)
	assert(not self._destroyed, "Cutscene is destroyed")

	if runner ~= nil then
		assert(typeof(runner) == "function", "Cutscene:Run() callback must be a function")
		self._runner = runner
	end

	if v.RunService:IsServer() then
		return self
	end

	local _runner = self._runner
	assert(_runner, "Cutscene:Run() requires a callback on its first run")

	if runner == nil and self._playback and not self._playback.Finalized then
		return self
	end

	return v4.play(self, _runner)
end

function v3:RunOnPlayer(player)
	assert(v.RunService:IsServer(), "Cutscene:RunOnPlayer() can only be called on the server")
	assert(not self._destroyed, "Cutscene is destroyed")
	local v6

	if typeof(player) == "Instance" then
		v6 = player:IsA("Player")
	else
		v6 = false
	end

	assert(v6, "Cutscene:RunOnPlayer() requires a Player")
	local sourceModule = v4.findSourceModule(self)
	assert(sourceModule, "Cutscene is not returned by a ModuleScript inside ServerScriptService.Cutscenes")
	return v4.createReplicationPackage(self, player, sourceModule)
end

function v3:Play(callback)
	return self:Run(callback)
end

function v3:Cancel()
	local _playback = self._playback

	if _playback then
		return (v4.finish(self, _playback, "Cancelled", nil))
	end

	return false
end

function v3:Skip()
	local _playback = self._playback

	if _playback then
		return (v4.finish(self, _playback, "Skipped", nil))
	end

	return false
end

function v3:Destroy()
	if self._destroyed then
		return
	end

	local _playback = self._playback
	local thread = coroutine.running()
	local v6

	if _playback == nil then
		v6 = false
	else
		v6 = _playback.RunnerThread == thread
	end

	self._destroyed = true

	if _playback then
		v4.finish(self, _playback, "Cancelled", nil, v6, true)
	end

	self._maid:DoCleaning()

	if v6 then
		task.cancel(thread)
	end
end

function v3:Wait(p2: number)
	local _playback = self._playback

	if _playback and not _playback.Finalized then
		return modules.Wait.duration(p2, _playback.Cancelled.Event) and not _playback.Finalized
	end

	return false
end

function v3:AwaitFinished()
	if self._lastStatus then
		return self._lastStatus, self._lastError
	end

	if self._destroyed then
		return "Cancelled", nil
	end

	return self.Finished:Wait()
end

function v3:PreloadEnvironment(p2)
	assert(not self._destroyed, "Cutscene is destroyed")
	local environment = v4.resolveEnvironment(self, p2)
	environment:Preload()
	v4.ownEnvironment(self, environment)
	return environment
end

function v3:LoadEnvironment(p)
	local playback = v4.getPlayback(self, "LoadEnvironment")
	local preloadEnvironment = self:PreloadEnvironment(p)

	if self._environment == preloadEnvironment then
		return preloadEnvironment
	end

	self:UnloadEnvironment()
	preloadEnvironment:Load()
	self._environment = preloadEnvironment
	v4.bindEnvironment(self, playback, preloadEnvironment)
	return preloadEnvironment
end

function v3:TransitionEnvironment(p, p2, p3)
	local playback = v4.getPlayback(self, "TransitionEnvironment")
	return v4.resolveEnvironmentTransition(p):_execute(function()
		return self:LoadEnvironment(p2)
	end, p3, playback.Cancelled.Event, playback.Maid)
end

function v3:GetEnvironment()
	return self._environment
end

function v3:UnloadEnvironment()
	local _environment = self._environment

	if not _environment then
		return nil
	end

	local _playback = self._playback

	if _playback and not _playback.Finalized then
		_playback.Maid.EnvironmentFailure = nil
		_playback.Maid.Environment = nil
	end

	if self._environment == _environment then
		self._environment = nil
		_environment:Unload()
	end

	return _environment
end

function v3.SpawnNpc(p, p2, p3)
	local playback = v4.getPlayback(p, "SpawnNpc")
	local v6 = assert(playback.SceneFolder, "Cutscene scene folder is unavailable")
	local cutsceneNpc = modules.CutsceneNpc.new(p2, v6, p3)
	playback.Maid:GiveTask(cutsceneNpc)
	return cutsceneNpc
end

function v3:ShowDialogue(p2, p3)
	local playback = v4.getPlayback(self, "ShowDialogue")
	return v4.showDialogue(self, playback, p2, p3)
end

function v3:Say(value, text: string, options)
	local clone = table.clone(options or {})
	clone.Text = text
	local v6 = nil

	if typeof(value) == "string" then
		clone.Title = clone.Title or value
	elseif value ~= nil then
		local npcModel = v4.resolveNpcModel(value)

		if npcModel then
			clone.Title = clone.Title or v4.getDisplayName(npcModel)
			clone.Head = clone.Head or npcModel
		end

		v6 = value
	end

	return self:ShowDialogue(clone, v6)
end

function v3:PlayAnimation(model, p2: string, p3)
	local playback = v4.getPlayback(self, "PlayAnimation")

	if modules.CutsceneNpc.is(model) then
		return model:PlayAnimation(p2, p3)
	end

	local v6

	if typeof(model) == "Instance" then
		v6 = model:IsA("Model")
	else
		v6 = false
	end

	assert(v6, "PlayAnimation target must be a CutsceneNpc or Model")
	return modules.Animation.play(model, p2, p3, playback.Maid)
end

function v3.PlaySound(p, p2: string, p3, p4)
	local playback = v4.getPlayback(p, "PlaySound")
	local v6 = modules.Sound:Play(p2, v4.resolveSoundLocation(p3), p4)
	playback.Maid:GiveTask(v6)
	return v6
end

function v3.PlayEffect(p, p2, options)
	local playback = v4.getPlayback(p, "PlayEffect")
	local effect = modules.Effect.new(p2)
	local v6 = effect.play(effect, options or {})
	v4.registerDisposable(playback, v6)
	v4.registerDisposable(playback, effect)
	return v6 or effect
end

function v3.TeleportCameraTo(p, cframe: CFrame)
	local _, v6 = v4.getCameraController(p, "TeleportCameraTo")
	v6:TeleportTo(cframe)
end

function v3.AnimateCameraTo(p, cframe: CFrame, p2: number?, p3: number?)
	local _, v6 = v4.getCameraController(p, "AnimateCameraTo")
	v6.Animations:AnimateTo(cframe, p2, p3)
end

function v3:SetCameraTarget(primaryPart)
	local _, v6 = v4.getCameraController(self, "SetCameraTarget")

	if modules.CutsceneNpc.is(primaryPart) then
		local model = primaryPart:GetModel()
		primaryPart = model.PrimaryPart or function()
			return model:GetPivot()
		end
	end

	return v6:SetCameraTarget(primaryPart)
end

function v3:ClearCameraTarget()
	local _, v6 = v4.getCameraController(self, "ClearCameraTarget")
	v6:ClearCameraTarget()
end

function v3:AnimateFieldOfView(p2: number, p3: number?, p4: number?)
	local _, v6 = v4.getCameraController(self, "AnimateFieldOfView")
	v6.Animations:AnimateFieldOfView(p2, p3, p4)
end

function v3.ImpulseCamera(p, vector: Vector3)
	local _, v6 = v4.getCameraController(p, "ImpulseCamera")
	v6.Animations:Impulse(vector)
end

function v3.ImpulseCameraRotation(p, vector: Vector3)
	local _, v6 = v4.getCameraController(p, "ImpulseCameraRotation")
	v6.Animations:RotationImpulse(vector)
end

function v3.SkipCameraAnimations(p)
	local _, v6 = v4.getCameraController(p, "SkipCameraAnimations")
	v6.Animations:SkipToGoal()
end

function v3:FadeOutCamera(p2: number?)
	local playback = v4.getPlayback(self, "FadeOutCamera")
	v4.releaseCamera(playback, p2 or self._config.CameraBlendOutTime)
end

function v3.RestoreCamera(p)
	local cameraController, v6 = v4.getCameraController(p, "RestoreCamera")
	local v7 = assert(cameraController.CameraSnapshot, "Cutscene camera snapshot is unavailable")
	cameraController.CameraController = nil
	local success, result = pcall(v6.TeleportBack, v6, v7.CFrame)

	if not success then
		pcall(v6.Destroy, v6)
		error(`Cutscene camera restoration failed: {tostring(result)}`, 2)
	end
end

return table.freeze(v3)