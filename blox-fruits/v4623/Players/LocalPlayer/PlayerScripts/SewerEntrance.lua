local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AttributeCounter = require(ReplicatedStorage.Util.AttributeCounter)
local BonusMomentsController = require(ReplicatedStorage.Controllers.BonusMomentsController)
local CameraController = require(ReplicatedStorage.Controllers.CameraController)
require(ReplicatedStorage.Controllers.CameraController.Types)
local Net = require(ReplicatedStorage.Modules.Net)
local SewerSystem = require(ReplicatedStorage.Modules.World.SewerSystem)
local Sound = require(ReplicatedStorage.Util.Sound)
local SewerFloodTransitionEffect = require(ReplicatedStorage.Controllers.MapServices.Transitions.SewerFloodTransitionEffect)
local v = {
	CAMERA_FADE_TIME = 0.65,
	ENTRANCE_SOUND = "FountainCitySFX.BF_FountainCity_Enter_Sewer_Cutscene_01",
	CAMERA_FOCUS_HEIGHT = 2.5,
	CAMERA_TRACKING_DAMPING = 1,
	CAMERA_TRACKING_FREQUENCY = 4,
	ENEMY_REVEAL_BLEND_TIME = 0.65,
	ENEMY_REVEAL_DELAY = 1,
	ENEMY_REVEAL_DURATION = 1.5,
	ENEMY_REVEAL_FOCUS_HEIGHT = 2,
	ENEMY_REVEAL_TRACKING_FREQUENCY = 2.25,
	ENEMY_REVEAL_TRIGGER_DISTANCES = { 110, 100 },
	ENEMY_REVEAL_VISIBILITY_POLL_INTERVAL = 0.1,
	FLOOD_TRANSITION_HOLD = 1.75,
	SEQUENCE_TIMEOUT_PADDING = 3,
	TELEPORT_ARRIVAL_DISTANCE = 30,
	TELEPORT_ARRIVAL_TIMEOUT = 1.5
}
local localPlayer = Players.LocalPlayer
local PlayerModule = require(localPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
local controls = PlayerModule:GetControls()
local remoteEvent = Net:RemoteEvent(SewerSystem.ENTRANCE_REMOTE_NAME)
local v2 = nil
local v3 = nil
local v4 = nil
local count = 0
local v5 = {
	createDungeonPreview = function(p)
		local v6 = BonusMomentsController:GetLoadedMoments()[SewerSystem.BONUS_MOMENT_NAME]

		if not v6 then
			return nil
		end

		local moduleScript = v6.MiscData[SewerSystem.DUNGEON_PREVIEW_MODULE_DATA_KEY]

		if typeof(moduleScript) ~= "Instance" or not moduleScript:IsA("ModuleScript") then
			return nil
		end

		local success, result = pcall(require, moduleScript)

		if not success or typeof(result) ~= "table" or typeof(result.new) ~= "function" then
			warn((`[SewerEntrance] Dungeon camera controller failed to load: {tostring(result)}`))
			return nil
		end

		local success2, result2 = pcall(result.new, p)

		if success2 then
			return result2
		end

		warn((`[SewerEntrance] Dungeon camera controller failed to initialize: {tostring(result2)}`))
		return nil
	end
}

function v5:getDungeonPreview()
	if self.previewDisabled then
		return nil
	end

	if self.preview then
		return self.preview
	end

	local dungeonPreview = v5.createDungeonPreview(self.controller)
	self.preview = dungeonPreview
	return dungeonPreview
end

function v5.getEnemyPreviews(items)
	if typeof(items) ~= "table" then
		return nil
	end

	local models = {}

	for _, model in items do
		if typeof(model) ~= "Instance" or not model:IsA("Model") then
			return nil
		end

		table.insert(models, model)
	end

	return models
end

function v5.getEnemyFocus(p)
	local v6 = createVector(0, 0, 0)
	local count2 = 0

	for _, character in p.characters do
		if not character.Parent then
			continue
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			continue
		end

		v6 += humanoidRootPart.Position
		count2 += 1
	end

	local v7

	if count2 > 0 then
		v7 = v6 / count2
	else
		v7 = p.roomCFrame.Position
	end

	return v7 + createVector(0, 1, 0) * v.ENEMY_REVEAL_FOCUS_HEIGHT
end

function v5.canPlayEnemyReveal(p)
	local character = localPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	local currentCamera = workspace.CurrentCamera

	if not (character and humanoidRootPart and humanoidRootPart:IsA("BasePart") and currentCamera) then
		return false
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }

	for _, character2 in p.characters do
		local head = character2:FindFirstChild("Head") or character2:FindFirstChild("HumanoidRootPart")

		if not head or not head:IsA("BasePart") or (head.Position - humanoidRootPart.Position).Magnitude > p.triggerDistance then
			continue
		end

		local worldToViewportPoint, v6 = currentCamera:WorldToViewportPoint(head.Position)

		if not v6 or worldToViewportPoint.Z <= 0 then
			continue
		end

		local raycastResult = workspace:Raycast(
			currentCamera.CFrame.Position,
			head.Position - currentCamera.CFrame.Position,
			raycastParams
		)

		if not raycastResult or raycastResult.Instance:IsDescendantOf(character2) then
			return true
		end
	end

	return false
end

function v5.playPendingEnemyReveal()
	if v2 or v3 then
		return
	end

	local v6 = v4

	if not v6 then
		return
	end

	if localPlayer:GetAttribute("ExactLocation") ~= SewerSystem.LOCATION_NAME then
		v4 = nil
		return
	end

	local v7 = v6.availableAt - os.clock()

	if v7 > 0 then
		task.delay(v7, function()
			if v4 == v6 then
				v5.playPendingEnemyReveal()
			end
		end)
		return
	end

	if not v5.canPlayEnemyReveal(v6) then
		task.delay(v.ENEMY_REVEAL_VISIBILITY_POLL_INTERVAL, function()
			if v4 == v6 then
				v5.playPendingEnemyReveal()
			end
		end)
		return
	end

	v4 = nil
	v5.playEnemyReveal(v6)
end

function v5.playEnemyReveal(p)
	if v2 or v3 then
		v4 = p
		return
	end

	if localPlayer:GetAttribute("ExactLocation") ~= SewerSystem.LOCATION_NAME then
		v4 = nil
		return
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	count += 1
	local v6 = count
	local v7 = CameraController.new(currentCamera, 1, v.ENEMY_REVEAL_BLEND_TIME)
	v3 = v7
	local v8 = v7:SetCameraTarget(function()
		return v5.getEnemyFocus(p)
	end)
	v8:SetTrackingSpring(1, v.ENEMY_REVEAL_TRACKING_FREQUENCY)
	v8:SetPositionLocked(true)
	task.delay(v.ENEMY_REVEAL_DURATION, function()
		if v3 ~= v7 or count ~= v6 then
			return
		end

		v7:FadeOut(v.ENEMY_REVEAL_BLEND_TIME)
		task.delay(v.ENEMY_REVEAL_BLEND_TIME, function()
			if v3 == v7 and count == v6 then
				v3 = nil
				v5.playPendingEnemyReveal()
			end
		end)
	end)
end

function v5.queueEnemyReveal(value, items, roomCFrame)
	if typeof(value) ~= "number" or typeof(items) ~= "table" or typeof(roomCFrame) ~= "CFrame" then
		return
	end

	local triggerDistance = v.ENEMY_REVEAL_TRIGGER_DISTANCES[value]

	if not triggerDistance then
		return
	end

	local models = {}

	for _, model in items do
		if typeof(model) == "Instance" and model:IsA("Model") then
			table.insert(models, model)
		end
	end

	v4 = {
		availableAt = os.clock() + v.ENEMY_REVEAL_DELAY,
		characters = models,
		roomCFrame = roomCFrame,
		triggerDistance = triggerDistance
	}
	v5.playPendingEnemyReveal()
end

function v5.cancelEnemyReveal()
	count += 1
	v4 = nil

	if v3 then
		v3:Destroy()
		v3 = nil
	end
end

function v5:releaseMovement()
	if self.movementReleased then
		return
	end

	self.movementReleased = true
	self.humanoid:Move(createVector(0, 0, 0), false)

	if self.humanoid.Parent then
		self.humanoid.WalkSpeed = self.previousWalkSpeed
	end

	if self.character.Parent then
		self.character:SetAttribute("IgnoreWalkSpeed", self.previousIgnoreWalkSpeed)
	end

	self.movementLock:Destroy()

	if self.controlsWereEnabled then
		self.controls:Enable()
	end
end

function v5.walkSequence(p: number)
	local v6 = v2

	if not v6 or v6.id ~= p or v6.finishing or v6.walking then
		return
	end

	v6.walking = true

	if v6.movementReleased then
		remoteEvent:FireServer("WalkFinished", p)
		return
	end

	local v7 = os.clock() + v.TELEPORT_ARRIVAL_TIMEOUT

	while v2 == v6 and not v6.finishing and (v6.root.Position - v6.entrancePosition).Magnitude > v.TELEPORT_ARRIVAL_DISTANCE and os.clock() < v7 do
		RunService.Heartbeat:Wait()
	end

	if v2 == v6 and not v6.finishing and v6.root.Parent and v6.humanoid.Parent and not (v6.humanoid.Health <= 0 or (v6.root.Position - v6.entrancePosition).Magnitude > v.TELEPORT_ARRIVAL_DISTANCE) then
		local v8 = v6.forward * createVector(1, 0, 1)
		local v9 = not (v8.Magnitude > 0.01) and createVector(0, 0, 1) or v8.Unit
		v6.root.AssemblyLinearVelocity = createVector(0, 0, 0)
		v6.root.AssemblyAngularVelocity = createVector(0, 0, 0)
		v6.root.CFrame = CFrame.lookAt(v6.root.Position, v6.root.Position + v9)
		v6.humanoid.Sit = false
		local v10 = v6.controller:SetCameraTarget(function()
			if v6.root.Parent then
				return v6.root.Position + createVector(0, 1, 0) * v.CAMERA_FOCUS_HEIGHT
			end

			return v6.entrancePosition + createVector(0, 1, 0) * v.CAMERA_FOCUS_HEIGHT
		end)
		v10:SetPositionLocked(true)
		v10:SetTrackingSpring(v.CAMERA_TRACKING_DAMPING, v.CAMERA_TRACKING_FREQUENCY)
		local position = v6.root.Position
		local v11 = os.clock() + SewerSystem.ENTRANCE_WALK_TIMEOUT

		while v2 == v6 and not v6.finishing and v6.root.Parent and v6.humanoid.Parent and v6.humanoid.Health > 0 and (v6.root.Position - position):Dot(v9) < SewerSystem.ENTRANCE_WALK_DISTANCE and os.clock() < v11 do
			v6.humanoid:Move(v9, false)
			RunService.Heartbeat:Wait()
		end

		v6.humanoid:Move(createVector(0, 0, 0), false)

		if v2 ~= v6 or v6.finishing then
			return
		end

		if v6.root.Parent and v6.humanoid.Health > 0 then
			v6.root.AssemblyAngularVelocity = createVector(0, 0, 0)
			v6.root.CFrame = CFrame.lookAt(v6.root.Position, v6.root.Position + v9)
		end

		remoteEvent:FireServer("WalkFinished", p)
	elseif v2 == v6 and not v6.finishing then
		remoteEvent:FireServer("WalkFinished", p)
	end
end

function v5:destroyPreview()
	if self.preview then
		local preview = self.preview
		self.preview = nil
		local success, result = pcall(function()
			preview:destroy()
			return true
		end)

		if not success then
			warn((`[SewerEntrance] Dungeon preview cleanup failed: {result}`))
		end
	end
end

function v5.destroyState(p)
	for _, connection in p.connections do
		connection:Disconnect()
	end

	table.clear(p.connections)
	v5.releaseMovement(p)
	p.controller:Destroy()
	v5.destroyPreview(p)

	if v2 == p then
		v2 = nil
		task.defer(v5.playPendingEnemyReveal)
	end
end

function v5.completeSequence(p)
	if v2 ~= p then
		return
	end

	p.controller:FadeOut(v.CAMERA_FADE_TIME)
	task.delay(v.CAMERA_FADE_TIME, function()
		if v2 ~= p then
			return
		end

		v5.destroyState(p)
		remoteEvent:FireServer(SewerSystem.DUNGEON_PREVIEW_FINISHED_COMMAND, p.id)
	end)
end

function v5.finishSequence(p: number)
	local v6 = v2

	if not v6 or v6.id ~= p or v6.finishing then
		return
	end

	v6.finishing = true
	task.spawn(function()
		local success, result = pcall(function()
			local dungeonPreview = v5.getDungeonPreview(v6)

			if dungeonPreview then
				if v6.boss then
					dungeonPreview:setBoss(v6.boss)
				end

				if v6.cyborg then
					dungeonPreview:setCyborg(v6.cyborg)
				end

				if v6.enemyPreviews then
					dungeonPreview:setEnemyPreviews(v6.enemyPreviews)
				end

				dungeonPreview:play()
			end
		end)

		if not success then
			warn((`[SewerEntrance] Dungeon preview failed: {result}`))
			v5.releaseMovement(v6)
		end

		v5.completeSequence(v6)
	end)
end

function v5.startSequence(id: number, cframe: CFrame, cframe2: CFrame)
	if typeof(id) ~= "number" or typeof(cframe) ~= "CFrame" or typeof(cframe2) ~= "CFrame" then
		return
	end

	if v2 then
		v5.destroyState(v2)
	end

	v5.cancelEnemyReveal()
	local character = localPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	local currentCamera = workspace.CurrentCamera

	if not character or not humanoidRootPart or not humanoidRootPart:IsA("BasePart") or not humanoid or humanoid.Health <= 0 or not currentCamera then
		return
	end

	local activeController = controls:GetActiveController()
	local controlsWereEnabled = activeController == nil or activeController.enabled ~= false
	controls:Disable()
	local ignoreWalkSpeed = character:GetAttribute("IgnoreWalkSpeed")
	local walkSpeed = humanoid.WalkSpeed
	character:SetAttribute("IgnoreWalkSpeed", true)
	humanoid.WalkSpeed = SewerSystem.ENTRANCE_WALK_SPEED
	local destroyable = AttributeCounter.destroyable(character, "DisableMovement")
	local controller = CameraController.new(currentCamera)
	controller:TeleportTo(cframe)
	pcall(function()
		Sound:Play(v.ENTRANCE_SOUND)
	end)
	local v8 = {
		boss = nil,
		character = character,
		connections = {},
		controller = controller,
		controls = controls,
		controlsWereEnabled = controlsWereEnabled,
		cyborg = nil,
		enemyPreviews = nil,
		entrancePosition = cframe2.Position,
		finishing = false,
		forward = cframe2.LookVector,
		humanoid = humanoid,
		id = id,
		movementLock = destroyable,
		movementReleased = false,
		previousIgnoreWalkSpeed = ignoreWalkSpeed,
		previousWalkSpeed = walkSpeed,
		preview = nil,
		previewDisabled = false,
		root = humanoidRootPart,
		walking = false
	}
	v2 = v8

	local function cancelSequence()
		if v2 == v8 then
			v5.destroyState(v8)
		end
	end

	table.insert(v8.connections, character.Destroying:Once(cancelSequence))
	table.insert(v8.connections, humanoid.Died:Once(cancelSequence))
	table.insert(v8.connections, localPlayer.CharacterRemoving:Connect(function(character2)
		if character2 == character and v2 == v8 then
			v5.destroyState(v8)
		end
	end))
	local dungeonPreview = v5.getDungeonPreview(v8)

	if v2 ~= v8 then
		v5.destroyPreview(v8)
		return
	end

	if not dungeonPreview then
		v8.previewDisabled = true
		v5.releaseMovement(v8)
		v8.controller:Destroy()
	end

	task.delay(SewerSystem.ENTRANCE_WALK_TIMEOUT + v.SEQUENCE_TIMEOUT_PADDING, function()
		v5.finishSequence(id)
	end)
	remoteEvent:FireServer("Ready", id)
end

remoteEvent.OnClientEvent:Connect(function(p, model, model2, p2)
	if p == "Start" then
		v5.startSequence(model, model2, p2)
	elseif p == "Walk" then
		task.spawn(v5.walkSequence, model)
	elseif p == "Finish" then
		v5.finishSequence(model)
	elseif p == "Cancel" then
		local v6 = v2

		if v6 and v6.id == model then
			v5.destroyState(v6)
		end
	elseif p == "Flood" then
		v5.cancelEnemyReveal()
		SewerFloodTransitionEffect.play()
		task.delay(v.FLOOD_TRANSITION_HOLD, SewerFloodTransitionEffect.stopEarly)
	elseif p == "RevealEnemies" then
		v5.queueEnemyReveal(model, model2, p2)
	elseif p == SewerSystem.DUNGEON_PREVIEW_READY_COMMAND then
		local v6 = v2

		if v6 and typeof(model) == "Instance" and model:IsA("Model") then
			v6.boss = model

			if typeof(model2) == "Instance" and model2:IsA("Model") then
				v6.cyborg = model2
			end

			v6.enemyPreviews = v5.getEnemyPreviews(p2)
			local dungeonPreview = v5.getDungeonPreview(v6)

			if dungeonPreview then
				dungeonPreview:setBoss(model)

				if v6.cyborg then
					dungeonPreview:setCyborg(v6.cyborg)
				end

				if v6.enemyPreviews then
					dungeonPreview:setEnemyPreviews(v6.enemyPreviews)
				end
			end
		end
	end
end)