local createVector = vector.create
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local stage15 = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Stages"):WaitForChild("Stage15")
local Config = require(script.Config)
local AdminAbuseUtils = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminAbuseEvent.AdminAbuseUtils)
local ClientState = require(ReplicatedStorage.ClientState)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
local Config2 = require(ReplicatedStorage.Config)
local localPlayer = Players.LocalPlayer
local cframe = CFrame.Angles(0, 3.141592653589793, 0)
local cframe2 = CFrame.Angles(0, 3.141592653589793, 0)
local v = nil
local v2 = nil
local name = nil
local v3 = false
local flag = false
local v4 = {}
local v5 = {}
local v6 = nil
local speed = Config.VoidChase.speed
local v7 = nil
local v8 = nil
local v9 = {}
local v10 = 0
local lookVector = createVector(-0, -0, -1)
local v11 = 0
local transitionManager = nil
local thread = nil
local controls = nil
local diedConnection = nil
local v12 = nil
local thread2 = nil
local v13 = nil
local v14 = nil
local v15 = nil
local stage15SpeedBoost = localPlayer:GetAttribute("Stage15SpeedBoost") or 0
local v16 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function hasBeatenStage()
	return ClientState:Get().World3Stage15Beaten == true
end

local function fetchRigTemplate()
	return stage15:WaitForChild("Stage15BossRig")
end

local function fetchChaseRigTemplate()
	return stage15:WaitForChild("Stage15BossRigChase")
end

local function fetchCameraRigTemplate()
	return stage15:WaitForChild("Stage15CameraRig")
end

local function weldToRoot(folder, part)
	if folder:IsA("BasePart") then
		folder.Anchored = false
		folder.CanCollide = false
		folder.Massless = true
		folder.CFrame = part.CFrame * CFrame.new(0, -2, 0)
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = part
		weldConstraint.Part1 = folder
		weldConstraint.Parent = folder
	elseif folder:IsA("Model") then
		folder:PivotTo(part.CFrame * CFrame.new(0, -2, 0))
		local primaryPart = folder.PrimaryPart or folder:FindFirstChildWhichIsA("BasePart", true)

		if primaryPart then
			for _, part2 in folder:GetDescendants() do
				if not part2:IsA("BasePart") then
					continue
				end

				part2.Anchored = false
				part2.CanCollide = false
				part2.Massless = true
			end

			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = part
			weldConstraint.Part1 = primaryPart
			weldConstraint.Parent = primaryPart
		end
	end
end

local function emitSpeedIncreaseParticles(folder)
	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter.Rate)
		end
	end
end

local function checkSpeedIncreaseReady()
	local character = localPlayer.Character
	local child = stage15:FindFirstChild(Config.SpeedIncrease.templateName)
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if character and child and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return true, character, child, humanoidRootPart, nil
	end

	return
		false,
		nil,
		nil,
		nil,
		"[SpeedBoss_Stage15th_W3.playSpeedIncreaseVisual] - Missing SpeedIncrease template or HumanoidRootPart"
end

local function applySpeedIncreaseVisual(character, child, humanoidRootPart)
	local clone = child:Clone()

	for _, billboardGui in clone:GetDescendants() do
		if billboardGui:IsA("BillboardGui") then
			billboardGui.ClipsDescendants = false
		end
	end

	clone.Parent = character
	weldToRoot(clone, humanoidRootPart)
	emitSpeedIncreaseParticles(clone)
	Debris:AddItem(clone, Config.SpeedIncrease.debrisSeconds)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playSpeedIncreaseVisual()
	local character = localPlayer.Character
	local child = stage15:FindFirstChild(Config.SpeedIncrease.templateName)
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local flag2, v17

	if character and child and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		flag2 = true
	else
		flag2 = false
		character = nil
		child = nil
		humanoidRootPart = nil
		v17 = "[SpeedBoss_Stage15th_W3.playSpeedIncreaseVisual] - Missing SpeedIncrease template or HumanoidRootPart"
	end

	if flag2 then
		applySpeedIncreaseVisual(character, child, humanoidRootPart)
	else
		warn(v17)
	end
end

local function showSpeedIncreaseBillboard(p: number, stage15SpeedBoost2: number)
	local MAX_LEVEL_SPEED_CAP = Config2.MAX_LEVEL_SPEED_CAP
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local v17

	if humanoid and humanoid.WalkSpeed > 0 then
		v17 = humanoid.WalkSpeed
	else
		v17 = Config2.CalculateMaxSpeed(ClientState:Get().Level or 1) + stage15SpeedBoost2
	end

	NotificationSystem:ShowPlusOneText((`+{math.floor(p)} Run Speed! {math.floor((math.min(v17, MAX_LEVEL_SPEED_CAP)))}/{math.floor(MAX_LEVEL_SPEED_CAP)}`))
end

local function ensureSound(p, name2: string, soundId: string)
	if p and p.Parent then
		return p
	end

	local sound = Instance.new("Sound")
	sound.Name = name2
	sound.SoundId = soundId
	sound.Looped = false
	sound.Volume = 1
	sound.Parent = SoundService
	return sound
end

local function ensureSpeedBoostSound()
	local v17 = v14
	local speedBoost = Config.Audio.speedBoost

	if not (v17 and v17.Parent) then
		v17 = Instance.new("Sound")
		v17.Name = "Stage15SpeedBoost"
		v17.SoundId = speedBoost
		v17.Looped = false
		v17.Volume = 1
		v17.Parent = SoundService
	end

	v14 = v17
	return v17
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playSpeedBoostAudio()
	local v17 = v14
	local speedBoost = Config.Audio.speedBoost

	if not (v17 and v17.Parent) then
		v17 = Instance.new("Sound")
		v17.Name = "Stage15SpeedBoost"
		v17.SoundId = speedBoost
		v17.Looped = false
		v17.Volume = 1
		v17.Parent = SoundService
	end

	v14 = v17
	v17.TimePosition = 0
	v17:Play()
end

local function onStage15SpeedBoostChanged()
	local stage15SpeedBoost2 = localPlayer:GetAttribute("Stage15SpeedBoost") or 0
	local v17 = stage15SpeedBoost2 - stage15SpeedBoost
	stage15SpeedBoost = stage15SpeedBoost2

	if v17 > 0 and ClientState:Get().World3Stage15Beaten ~= true then
		showSpeedIncreaseBillboard(v17, stage15SpeedBoost2)
		playSpeedIncreaseVisual() -- equivalent call inferred; original call site unknown
		playSpeedBoostAudio() -- equivalent call inferred; original call site unknown
	end
end

local function getTransitionManager()
	if not transitionManager then
		local coolTransitions = require(ReplicatedStorage.coolTransitions)
		local playerGui = localPlayer:WaitForChild("PlayerGui")
		transitionManager = coolTransitions.TransitionManager.new(playerGui)
	end

	return transitionManager
end

local function getPlayerControls()
	if controls then
		return controls
	end

	local playerScripts = localPlayer:FindFirstChild("PlayerScripts")
	local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule")

	if playerModule then
		local module = require(playerModule)
		controls = module:GetControls()
	else
		warn("[SpeedBoss_Stage15th_W3.getPlayerControls] - PlayerModule not found")
	end

	return controls
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lockPlayerControls()
	local playerControls = getPlayerControls()

	if playerControls then
		playerControls:Disable()
	end
end

local function unlockPlayerControls()
	local playerControls = getPlayerControls()

	if playerControls then
		playerControls:Enable()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scheduleCutsceneFade(maid, durationSeconds: number)
	local v17 = math.max(durationSeconds - 0.6, 0)
	maid:Add(task.delay(v17, function()
		maid:RemoveNoClean("cutsceneFade")

		if not transitionManager then
			local coolTransitions = require(ReplicatedStorage.coolTransitions)
			local playerGui = localPlayer:WaitForChild("PlayerGui")
			transitionManager = coolTransitions.TransitionManager.new(playerGui)
		end

		transitionManager:PlayInOut(1.2, nil, "Center", "Fade", 0.15)
	end), true, "cutsceneFade")
end

local function ensureDialogSound(soundId: string)
	local v17 = v13

	if not (v17 and v17.Parent) then
		v17 = Instance.new("Sound")
		v17.Name = "Stage15NpcDialog"
		v17.SoundId = soundId
		v17.Looped = false
		v17.Volume = 1
		v17.Parent = SoundService
	end

	v17.SoundId = soundId
	v13 = v17
	return v17
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopDialogAudio()
	if v13 then
		v13:Stop()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playDialogAudio(soundId: string)
	local v17 = v13

	if not (v17 and v17.Parent) then
		v17 = Instance.new("Sound")
		v17.Name = "Stage15NpcDialog"
		v17.SoundId = soundId
		v17.Looped = false
		v17.Volume = 1
		v17.Parent = SoundService
	end

	v17.SoundId = soundId
	v13 = v17
	v17.TimePosition = 0
	v17:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelScheduledStageMusic()
	if thread then
		pcall(task.cancel, thread)
		thread = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startStageMusic()
	if not v12 and ClientState:Get().World3Stage15Beaten ~= true then
		v12 = AdminAbuseUtils.Musics.play(Config.Audio.stageMusic, {
			name = "Stage15Music",
			looping = true
		})
	end
end

local function scheduleStageMusic(p: number)
	cancelScheduledStageMusic() -- equivalent call inferred; original call site unknown
	local v17 = math.max(p - 5, 0)
	thread = task.delay(v17, function()
		thread = nil
		startStageMusic() -- equivalent call inferred; original call site unknown
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelMusicFade()
	if thread2 then
		pcall(task.cancel, thread2)
		thread2 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopStageMusic()
	cancelScheduledStageMusic() -- equivalent call inferred; original call site unknown
	cancelMusicFade() -- equivalent call inferred; original call site unknown

	if v12 then
		AdminAbuseUtils.Musics.stop(v12)
		v12 = nil
	end
end

local function fadeOutStageMusic(_: number)
	cancelScheduledStageMusic() -- equivalent call inferred; original call site unknown
	cancelMusicFade() -- equivalent call inferred; original call site unknown
	local v17 = v12

	if v17 then
		TweenService:Create(v17.audioPlayer, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Volume = 0
		}):Play()
		thread2 = task.delay(1, function()
			thread2 = nil

			if v12 == v17 then
				AdminAbuseUtils.Musics.stop(v17)
				v12 = nil
			end
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelCutsceneFovTween()
	if v15 then
		v15:Cancel()
		v15 = nil
	end
end

local function applyCutsceneFov(p: string)
	local v17, v18 = string.match(tostring(p), "^%s*([%d%.]+)%s*/%s*([%d%.]+)%s*$")
	local fieldOfView = tonumber(v17)
	local v20 = tonumber(v18)
	local currentCamera = workspace.CurrentCamera

	if not (fieldOfView and v20 and v20 >= 0 and currentCamera) then
		warn(string.format(
			"[SpeedBoss_Stage15th_W3.applyCutsceneFov] - FOV marker must be TargetFov/TransitionDuration, got: %s",
			(tostring(p))
		))
		return
	end

	cancelCutsceneFovTween() -- equivalent call inferred; original call site unknown

	if v20 == 0 then
		currentCamera.FieldOfView = fieldOfView
		return
	end

	local tween = TweenService:Create(
		currentCamera,
		TweenInfo.new(v20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			FieldOfView = fieldOfView
		}
	)
	v15 = tween
	tween:Play()
end

local function showNpcSpeech(text: string, duration: number)
	if type(text) ~= "string" or text == "" then
		warn("[SpeedBoss_Stage15th_W3.showNpcSpeech] - NPCSpeech marker had no text")
		return
	end

	local v17 = {
		text = text,
		senderName = Config.NpcDialog.senderName,
		isOwner = false,
		Duration = duration,
		icon = Config.NpcDialog.icon
	}

	for _, bindableEvent in CollectionService:GetTagged("AdminAnnounceListener") do
		if bindableEvent:IsA("BindableEvent") and bindableEvent:IsDescendantOf(game) then
			bindableEvent:Fire(v17)
		end
	end
end

local function connectCameraCutsceneMarkers(cameraTrack, dialogSoundId: string, dialogDuration: number)
	return { cameraTrack:GetMarkerReachedSignal("NPCDialogAudioStart"):Connect(function()
			playDialogAudio(dialogSoundId) -- equivalent call inferred; original call site unknown
		end), cameraTrack:GetMarkerReachedSignal("FOV"):Connect(applyCutsceneFov), cameraTrack:GetMarkerReachedSignal("NPCSpeech"):Connect(function(text: string)
			showNpcSpeech(text, dialogDuration)
		end) }
end

local function preloadStageAssets()
	AdminAbuseUtils.Animations.preload(Config.Animations.CutsceneIntro.Camera)
	AdminAbuseUtils.Animations.preload(Config.Animations.CutsceneIntro.BossRig)
	AdminAbuseUtils.Animations.preload(Config.Animations.CutsceneOutro.Camera)
	AdminAbuseUtils.Animations.preload(Config.Animations.CutsceneOutro.BossRig)
	local dialog = Config.Audio.dialog
	local v17 = v13

	if not (v17 and v17.Parent) then
		v17 = Instance.new("Sound")
		v17.Name = "Stage15NpcDialog"
		v17.SoundId = dialog
		v17.Looped = false
		v17.Volume = 1
		v17.Parent = SoundService
	end

	v17.SoundId = dialog
	v13 = v17
	local v18 = v14
	local speedBoost = Config.Audio.speedBoost

	if not (v18 and v18.Parent) then
		v18 = Instance.new("Sound")
		v18.Name = "Stage15SpeedBoost"
		v18.SoundId = speedBoost
		v18.Looped = false
		v18.Volume = 1
		v18.Parent = SoundService
	end

	v14 = v18
end

local function changeRigVisibility(folder, transparency: number)
	for _, descendant in folder:GetDescendants() do
		if not (descendant ~= folder.PrimaryPart and (descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture"))) then
			continue
		end

		descendant.Transparency = transparency
	end
end

local function tweenRigToTransparent(folder, duration: number)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)

	for _, descendant in folder:GetDescendants() do
		if not (descendant ~= folder.PrimaryPart and (descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture"))) then
			continue
		end

		TweenService:Create(descendant, tweenInfo, {
			Transparency = 1
		}):Play()
	end
end

local function getRigPosition(childName: string)
	local v17 = CollectionService:GetTagged(Config.CoreConfig.rigPositionsTagName)[1]
	local part = v17 and v17:FindFirstChild(childName)

	if part and part:IsA("BasePart") then
		return part
	end

	return nil
end

local function getCameraTarget(instance)
	local cameraTarget = instance:FindFirstChild("CameraTarget", true)

	if cameraTarget and (cameraTarget:IsA("BasePart") or cameraTarget:IsA("Attachment")) then
		return cameraTarget
	end

	warn("[SpeedBoss_Stage15th_W3.getCameraTarget] - No 'CameraTarget' in rig, falling back to Torso")
	local torso = instance:FindFirstChild("Torso", true)

	if torso and torso:IsA("BasePart") then
		return torso
	end

	local basePart = instance:FindFirstChildWhichIsA("BasePart", true)
	assert(basePart, "SpeedBoss_Stage15th_W3 Stage15CameraRig has no camera target")
	return basePart
end

local function waitForTrackLength(track)
	local total = 0

	while track.Length <= 0 and total < 3 do
		total += RunService.Heartbeat:Wait()
	end

	return track.Length
end

local function computeCutsceneDuration(items)
	local v17 = 0

	for _, item in items do
		v17 = math.max(v17, (waitForTrackLength(item.track)))
	end

	return v17 + 0.15
end

local function getVisualBossWaypoints()
	local v17 = CollectionService:GetTagged(Config.CoreConfig.rigPositionsTagName)[1]
	local child = v17 and v17:FindFirstChild(Config.VisualBoss.waypointsFolderName)

	if not child then
		warn("[SpeedBoss_Stage15th_W3.getVisualBossWaypoints] - Missing waypoints folder")
		return {}
	end

	local parts = {}

	for _, part in child:GetChildren() do
		if part:IsA("BasePart") and tonumber(part.Name) then
			table.insert(parts, part)
		end
	end

	table.sort(parts, function(a, b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)
	return parts
end

local function prepareChaseRigParts(folder)
	local primaryPart = folder.PrimaryPart or folder:FindFirstChild("HumanoidRootPart")

	if not primaryPart then
		warn("[SpeedBoss_Stage15th_W3.prepareChaseRigParts] - No PrimaryPart or HumanoidRootPart, animations will not play")
	end

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = part == primaryPart
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getChaseBossSpeed()
	local v17 = Config2.STAGE_RECOMMENDED_LEVELS[Config.VisualBoss.stageNumber]
	local stage15SpeedBoost2 = localPlayer:GetAttribute("Stage15SpeedBoost") or 0
	return Config2.CalculateMaxSpeed(v17) + stage15SpeedBoost2 + Config.VisualBoss.speedLead
end

local function updateChaseBossMovement(instance, dt: number)
	local v17 = v9[v10]

	if not v17 then
		return
	end

	local position = instance:GetPivot().Position
	local v18 = v17.Position - position
	local magnitude = v18.Magnitude

	if magnitude <= 1 then
		instance:PivotTo(CFrame.lookAt(v17.Position, v17.Position + lookVector) * cframe2)
		return
	end

	local unit = v18.Unit
	local v19 = position + unit * math.min(getChaseBossSpeed() * dt, magnitude)
	lookVector = unit
	instance:PivotTo(CFrame.lookAt(v19, v19 + unit) * cframe2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scheduleNextChaseEmote()
	v11 = os.clock() + math.random(Config.ChaseEmote.minInterval, Config.ChaseEmote.maxInterval)
end

local function playChaseEmote(p)
	local emotes = Config.Animations.Chase.Emotes
	local maid = v7

	if maid and #emotes > 0 then
		local animation = AdminAbuseUtils.Animations.loadAnimation(p, emotes[math.random(1, #emotes)])
		animation.Priority = Enum.AnimationPriority.Action
		animation:Play(0.2)
		maid:Add(function()
			animation:Stop(0.2)
			animation:Destroy()
		end, true, "chaseEmote")
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyChaseBoss()
	local v17 = v7
	v7 = nil
	v8 = nil
	v9 = {}
	v10 = 0
	lookVector = createVector(-0, -0, -1)

	if v17 then
		v17:Destroy()
	end
end

local function checkChaseBossReady()
	local visualBossWaypoints = getVisualBossWaypoints()

	if #visualBossWaypoints > 0 then
		return true, stage15:WaitForChild("Stage15BossRigChase"), visualBossWaypoints, nil
	end

	return false, nil, nil, "[SpeedBoss_Stage15th_W3.spawnChaseBoss] - Missing boss rig template or VisualBossWaypoints"
end

local function applyChaseBossSpawn(stage15BossRigChase, visualBossWaypoints)
	local v17 = visualBossWaypoints[1]
	local clone = stage15BossRigChase:Clone()
	prepareChaseRigParts(clone)
	changeRigVisibility(clone, 0)
	clone:PivotTo(v17.CFrame * cframe2)
	clone.Parent = workspace
	local animation = AdminAbuseUtils.Animations.loadAnimation(clone, Config.Animations.Chase.Idle)
	animation.Looped = true
	animation:Play(0)
	v8 = clone
	v9 = visualBossWaypoints
	lookVector = v17.CFrame.LookVector
	v10 = 2
	scheduleNextChaseEmote() -- equivalent call inferred; original call site unknown
	local maid = Janitor.new()
	maid:Add(clone, "Destroy")
	maid:Add(function()
		animation:Stop(0)
		animation:Destroy()
	end, true)
	v7 = maid
end

-- equivalent calls inferred from this helper; original call sites unknown
local function spawnChaseBoss()
	if v8 then
		return
	end

	local visualBossWaypoints = getVisualBossWaypoints()
	local stage15BossRigChase, flag2, v17

	if #visualBossWaypoints > 0 then
		stage15BossRigChase = stage15:WaitForChild("Stage15BossRigChase")
		flag2 = true
	else
		flag2 = false
		visualBossWaypoints = nil
		v17 = "[SpeedBoss_Stage15th_W3.spawnChaseBoss] - Missing boss rig template or VisualBossWaypoints"
	end

	if flag2 then
		applyChaseBossSpawn(stage15BossRigChase, visualBossWaypoints)
	else
		warn(v17)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function advanceChaseBoss(p: number)
	if v8 and p == v10 then
		v10 += 1
	end

	if Config.VoidChase.speedStep <= p then
		speed = Config.VoidChase.speedAfterStep
	end
end

local function checkStageStepPartReady(part)
	if not part:IsA("BasePart") then
		return false, nil, nil
	end

	local step = part:GetAttribute("Step")

	if typeof(step) ~= "number" then
		step = tonumber(part.Name)
	end

	if step then
		return true, part, step
	end

	return false, nil, nil
end

local function onStageStepPartDetected(part)
	local step, flag2

	if part:IsA("BasePart") then
		step = part:GetAttribute("Step")

		if typeof(step) ~= "number" then
			step = tonumber(part.Name)
		end

		if step then
			flag2 = true
		else
			flag2 = false
			part = nil
			step = nil
		end
	else
		flag2 = false
		part = nil
		step = nil
	end

	if flag2 then
		part.Touched:Connect(function(otherPart)
			if otherPart.Parent == localPlayer.Character then
				advanceChaseBoss(step) -- equivalent call inferred; original call site unknown
			end
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function killLocalPlayer()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid.Health > 0 then
		humanoid.Health = 0
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hasReachedVoidFinish(instance, p)
	return (p.Position - instance.Position):Dot(instance.CFrame.LookVector) <= 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreVoidPart(p)
	local v17 = v5[p]

	if v17 then
		p.CFrame = v17.cframe
		p.Transparency = v17.transparency
		p.CanCollide = v17.canCollide
		p.CanTouch = v17.canTouch
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopVoidChase(p)
	local v17 = v4[p]

	if v17 then
		v4[p] = nil
		v17.janitor:Destroy()
	end
end

local function startVoidChase(part)
	if not part:IsA("BasePart") or v4[part] then
		return
	end

	part.Transparency = 0
	part.CanCollide = true
	part.CanTouch = true
	local touchedConnection = part.Touched:Connect(function(otherPart)
		local character = localPlayer.Character

		if character and otherPart:IsDescendantOf(character) then
			killLocalPlayer() -- equivalent call inferred; original call site unknown
			stopVoidChase(part) -- equivalent call inferred; original call site unknown
		end
	end)
	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and humanoidRootPart.Position.X >= part.Position.X then
			killLocalPlayer() -- equivalent call inferred; original call site unknown
		end
	end)
	local voidAudio = part:FindFirstChild("VoidAudio")

	if voidAudio and voidAudio:IsA("Sound") then
		voidAudio.TimePosition = 0
		voidAudio:Play()
	end

	local maid = Janitor.new()
	maid:Add(touchedConnection)
	maid:Add(heartbeatConnection)
	maid:Add(function()
		restoreVoidPart(part) -- equivalent call inferred; original call site unknown
	end, true)

	if voidAudio and voidAudio:IsA("Sound") then
		maid:Add(function()
			voidAudio:Stop()
		end, true)
	end

	v4[part] = {
		janitor = maid,
		moveAt = os.clock() + Config.VoidChase.startDelay
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startAllVoidChases()
	speed = Config.VoidChase.speed

	for _, v17 in CollectionService:GetTagged(Config.CoreConfig.voidPartTagName) do
		startVoidChase(v17)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopAllVoidChases()
	speed = Config.VoidChase.speed

	for k in v4 do
		stopVoidChase(k) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopCutscene()
	local v17 = v
	v = nil
	v2 = nil
	name = nil

	if v17 then
		v17:Destroy()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function finishCutscene(object, p, flag2: boolean)
	if v ~= object then
		return
	end

	local v17 = v3
	v3 = false

	if flag2 then
		object:RemoveNoClean("cutsceneDialog")
	end

	stopCutscene() -- equivalent call inferred; original call site unknown
	p.onFinished(flag2 or v17)
end

local function buildCutsceneRigs(object, p, p2)
	local clone = stage15:WaitForChild("Stage15BossRig"):Clone()
	local clone2 = stage15:WaitForChild("Stage15CameraRig"):Clone()
	clone:PivotTo(p2.CFrame)
	clone2:PivotTo(p2.CFrame * p.cameraRigRotation)
	changeRigVisibility(clone, 1)
	changeRigVisibility(clone2, 1)
	clone.Parent = workspace
	clone2.Parent = workspace
	object:Add(clone, "Destroy")
	object:Add(clone2, "Destroy")
	return clone, clone2
end

local function prepareCutscenePlayback(p, p2, cutsceneRigs, p3)
	RunService.Heartbeat:Wait()

	if v ~= p then
		return nil
	end

	local animation = AdminAbuseUtils.Animations.loadAnimation(p3, p2.cameraAnimation)
	local animation2 = AdminAbuseUtils.Animations.loadAnimation(cutsceneRigs, p2.bossAnimation)
	local tracks = {
		{
			track = animation,
			fadeTime = 0
		},
		{
			track = animation2,
			fadeTime = 0
		}
	}
	local v18 = 0

	for _, v19 in tracks do
		v18 = math.max(v18, (waitForTrackLength(v19.track)))
	end

	local durationSeconds = v18 + 0.15

	if v == p then
		return {
			cameraTrack = animation,
			bossTrack = animation2,
			tracks = tracks,
			durationSeconds = durationSeconds
		}
	end

	return nil
end

local function isIntroSkipInput(input)
	if input.UserInputState ~= Enum.UserInputState.Begin then
		return false
	end

	local userInputType = input.UserInputType

	if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
		return true
	end

	if string.find(userInputType.Name, "Gamepad", 1, true) ~= 1 then
		return false
	end

	local name2 = input.KeyCode.Name
	return string.sub(name2, 1, 6) == "Button" or string.sub(name2, 1, 4) == "DPad"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function beginIntroEncounter()
	if flag then
		return
	end

	flag = true
	NotificationSystem:ShowMessage(Config.VoidChase.warningText, Color3.fromRGB(255, 76, 76))
	startStageMusic() -- equivalent call inferred; original call site unknown
	startAllVoidChases() -- equivalent call inferred; original call site unknown
	spawnChaseBoss() -- equivalent call inferred; original call site unknown
end

local function requestSkipIntro()
	if name == "SpeedBossStage15Intro" then
		v3 = true
		beginIntroEncounter() -- equivalent call inferred; original call site unknown

		if v2 then
			AdminAbuseUtils.Cutscenes.stop(v2)
		end
	end
end

local function startCutscenePlayback(maid, data, cutsceneRigs, p, data2)
	local connections = connectCameraCutsceneMarkers(data2.cameraTrack, data.dialogSoundId, data.dialogDuration)

	if data.fadesBossOut then
		table.insert(connections, data2.bossTrack:GetMarkerReachedSignal("Transparency"):Connect(function()
			tweenRigToTransparent(cutsceneRigs, 1)
		end))
	end

	local inputBeganConnection

	if data.name == "SpeedBossStage15Intro" then
		inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
			if isIntroSkipInput(input) and name == "SpeedBossStage15Intro" then
				v3 = true
				beginIntroEncounter() -- equivalent call inferred; original call site unknown

				if v2 then
					AdminAbuseUtils.Cutscenes.stop(v2)
				end
			end
		end)
	end

	lockPlayerControls() -- equivalent call inferred; original call site unknown
	local currentCamera = workspace.CurrentCamera
	local play = AdminAbuseUtils.Cutscenes.play
	local v17 = {
		name = data.name,
		cameraTarget = getCameraTarget(p),
		tracks = data2.tracks,
		visibleRigs = { cutsceneRigs },
		durationSeconds = data2.durationSeconds,
		fieldOfView = 0,
		onFinished = 0
	}
	local fieldOfView

	if currentCamera then
		fieldOfView = currentCamera.FieldOfView
	end

	v17.fieldOfView = fieldOfView

	function v17.onFinished(flag2: boolean)
		finishCutscene(maid, data, flag2) -- equivalent call inferred; original call site unknown
	end

	local v19 = play(v17)

	for _, connection in connections do
		maid:Add(connection)
	end

	if inputBeganConnection then
		maid:Add(inputBeganConnection)
	end

	scheduleCutsceneFade(maid, data2.durationSeconds) -- equivalent call inferred; original call site unknown
	maid:Add(unlockPlayerControls, true)
	maid:Add(cancelCutsceneFovTween, true)
	maid:Add(stopDialogAudio, true, "cutsceneDialog")
	maid:Add(function()
		if v19 then
			AdminAbuseUtils.Cutscenes.stop(v19)
		end
	end, true)

	if v19 then
		v2 = v19

		if data.onStarted then
			data.onStarted(data2.durationSeconds)
		end
	else
		warn(string.format(
			"[SpeedBoss_Stage15th_W3.playCutscene] - Cutscenes.play returned no handle for %s",
			data.name
		))
		stopCutscene() -- equivalent call inferred; original call site unknown
	end
end

local function runCutscene(p, part)
	local v17 = Janitor.new()
	v = v17
	name = p.name
	local cutsceneRigs, v18 = buildCutsceneRigs(v17, p, part)
	local v19 = prepareCutscenePlayback(v17, p, cutsceneRigs, v18)

	if v19 then
		startCutscenePlayback(v17, p, cutsceneRigs, v18, v19)
	end
end

local function playCutscene(p)
	if v then
		return
	end

	if hasBeatenStage() then
		p.onFinished(true)
		return
	end

	local rigPositionName = p.rigPositionName
	local v17 = CollectionService:GetTagged(Config.CoreConfig.rigPositionsTagName)[1]
	local part = v17 and v17:FindFirstChild(rigPositionName)

	if not (part and part:IsA("BasePart")) then
		part = nil
	end

	if part then
		runCutscene(p, part)
	else
		warn(string.format(
			"[SpeedBoss_Stage15th_W3.playCutscene] - Missing cutscene rig template(s) or %s",
			p.rigPositionName
		))
	end
end

local function onIntroFinished(flag2: boolean)
	if flag2 or flag then
		beginIntroEncounter() -- equivalent call inferred; original call site unknown
	else
		stopStageMusic() -- equivalent call inferred; original call site unknown
	end
end

local function onOutroFinished(_: boolean)
	stopStageMusic() -- equivalent call inferred; original call site unknown
end

local v17 = {
	name = "SpeedBossStage15Intro",
	rigPositionName = Config.CoreConfig.introRigPositionName,
	cameraRigRotation = cframe,
	cameraAnimation = Config.Animations.CutsceneIntro.Camera,
	bossAnimation = Config.Animations.CutsceneIntro.BossRig,
	dialogSoundId = Config.Audio.dialog,
	dialogDuration = Config.NpcDialog.duration,
	fadesBossOut = false,
	onStarted = scheduleStageMusic,
	onFinished = onIntroFinished
}
local v18 = {
	name = "SpeedBossStage15Outro",
	rigPositionName = Config.CoreConfig.outroRigPositionName,
	cameraRigRotation = CFrame.identity,
	cameraAnimation = Config.Animations.CutsceneOutro.Camera,
	bossAnimation = Config.Animations.CutsceneOutro.BossRig,
	dialogSoundId = Config.Audio.dialogOutro,
	dialogDuration = Config.NpcDialog.outroDuration,
	fadesBossOut = true,
	onStarted = fadeOutStageMusic,
	onFinished = onOutroFinished
}

local function resetStageEncounter()
	flag = false
	stopCutscene() -- equivalent call inferred; original call site unknown
	stopDialogAudio() -- equivalent call inferred; original call site unknown
	stopStageMusic() -- equivalent call inferred; original call site unknown
	destroyChaseBoss() -- equivalent call inferred; original call site unknown
	stopAllVoidChases() -- equivalent call inferred; original call site unknown
end

local function onEntryPartDetected(part)
	if not part:IsA("BasePart") then
		return
	end

	part.Touched:Connect(function(otherPart)
		if otherPart.Parent == localPlayer.Character then
			local now = os.clock()

			if now - v16 >= 2 then
				flag = false
				playCutscene(v17)
			end

			v16 = now
		end
	end)
end

local function onEndPartDetected(part)
	if not part:IsA("BasePart") then
		return
	end

	part.Touched:Connect(function(otherPart)
		if otherPart.Parent == localPlayer.Character then
			destroyChaseBoss() -- equivalent call inferred; original call site unknown
			stopAllVoidChases() -- equivalent call inferred; original call site unknown
			playCutscene(v18)
		end
	end)
end

local function onVoidChasePartDetected(part)
	if part:IsA("BasePart") and not v5[part] then
		v5[part] = {
			cframe = part.CFrame,
			transparency = part.Transparency,
			canCollide = part.CanCollide,
			canTouch = part.CanTouch
		}
	end
end

local function onVoidFinishPartDetected(part)
	if part:IsA("BasePart") then
		v6 = part
	end
end

local function bindCharacterDied(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid") or instance:WaitForChild("Humanoid", 5)

	if diedConnection then
		diedConnection:Disconnect()
		diedConnection = nil
	end

	if humanoid and humanoid:IsA("Humanoid") then
		diedConnection = humanoid.Died:Connect(resetStageEncounter)
	end
end

local function connectTagged(tag: string, callback)
	CollectionService:GetInstanceAddedSignal(tag):Connect(callback)

	for _, v19 in CollectionService:GetTagged(tag) do
		task.spawn(callback, v19)
	end
end

connectTagged(Config.CoreConfig.entryTriggerPartName, onEntryPartDetected)
connectTagged(Config.CoreConfig.leaveTriggerPartName, onEndPartDetected)
connectTagged(Config.CoreConfig.voidFinishTagName, onVoidFinishPartDetected)
connectTagged(Config.CoreConfig.voidPartTagName, onVoidChasePartDetected)
connectTagged(Config.VisualBoss.speedPartTagName, onStageStepPartDetected)
localPlayer.CharacterAdded:Connect(bindCharacterDied)

if localPlayer.Character then
	task.spawn(bindCharacterDied, localPlayer.Character)
end

RunService.PreRender:Connect(function(dt: number)
	for k, v19 in v4 do
		if k.Parent and not (v6 and hasReachedVoidFinish(k, v6)) then
			if not (os.clock() < v19.moveAt) then
				k.CFrame += k.CFrame.LookVector * speed * dt
			end
		else
			stopVoidChase(k) -- equivalent call inferred; original call site unknown
		end
	end

	local v19 = v8

	if v19 then
		updateChaseBossMovement(v19, dt)
		local now = os.clock()

		if v11 <= now then
			playChaseEmote(v19)
			scheduleNextChaseEmote() -- equivalent call inferred; original call site unknown
		end
	end
end)
task.spawn(preloadStageAssets)
localPlayer:GetAttributeChangedSignal("Stage15SpeedBoost"):Connect(onStage15SpeedBoostChanged)