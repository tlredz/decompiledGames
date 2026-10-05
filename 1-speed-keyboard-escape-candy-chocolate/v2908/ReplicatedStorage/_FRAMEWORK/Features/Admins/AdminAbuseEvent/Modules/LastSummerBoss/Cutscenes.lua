local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local AdminAbuseUtils = require(script.Parent.Parent.Parent.AdminAbuseUtils)
local Config = require(script.Parent.Config)
local CutsceneFade = require(script.Parent.CutsceneFade)
local v = Enum.RenderPriority.Camera.Value + 2
local v2 = Enum.RenderPriority.Camera.Value + 3
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil
local flag = false
local flag2 = false
local flag3 = false
local transparenciesByDescendant = {}
local enabledsByDescendant = {}
local visibilityByFrame = {}
local emitters = {}

local function getCutsceneTemplate()
	local adminAbuse = ReplicatedStorage:FindFirstChild("AdminAbuse")
	local lastSummerBoss

	if adminAbuse then
		lastSummerBoss = adminAbuse:FindFirstChild("LastSummerBoss")
	end

	local assets

	if lastSummerBoss then
		assets = lastSummerBoss:FindFirstChild("Assets")
	end

	local cutsceneModel

	if assets then
		cutsceneModel = assets:FindFirstChild("CutsceneModel")
	end

	assert(cutsceneModel and cutsceneModel:IsA("Model"), "LastSummerBoss.Assets.CutsceneModel was not found")
	return cutsceneModel
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRig(instance, rigName: string)
	local model = instance:FindFirstChild(rigName)
	assert(model and model:IsA("Model"), (`LastSummerBoss cutscene rig '{rigName}' was not found`))
	return model
end

local function stripRigCosmetics(folder)
	for _, descendant in folder:GetDescendants() do
		if not (descendant:IsA("Accessory") or descendant:IsA("Clothing") or descendant:IsA("ShirtGraphic") or descendant:IsA("CharacterMesh") or descendant:IsA("BodyColors") or descendant:IsA("Decal") and descendant.Parent and descendant.Parent.Name == "Head") then
			continue
		end

		descendant:Destroy()
	end
end

local function applyLocalPlayerAppearance(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local localPlayer = Players.LocalPlayer

	if humanoid and localPlayer then
		stripRigCosmetics(instance)
		task.spawn(function()
			local success, result = pcall(function()
				return Players:GetHumanoidDescriptionFromUserId(localPlayer.UserId)
			end)

			if not (success and result and instance.Parent) then
				return
			end

			local scale = instance:GetScale()

			if scale ~= 1 then
				instance:ScaleTo(1)
			end

			pcall(function()
				humanoid:ApplyDescriptionAsync(result)
			end)

			if scale ~= 1 and instance.Parent then
				instance:ScaleTo(scale)
			end
		end)
	end
end

local function getCameraTarget(humanoidCameraRig)
	local cameraTarget = humanoidCameraRig:FindFirstChild("CameraTarget", true)

	if cameraTarget and (cameraTarget:IsA("BasePart") or cameraTarget:IsA("Attachment")) then
		return cameraTarget
	end

	local torso = humanoidCameraRig:FindFirstChild("Torso", true)

	if torso and torso:IsA("BasePart") then
		return torso
	end

	local basePart = humanoidCameraRig:FindFirstChildWhichIsA("BasePart", true)
	assert(basePart, "LastSummerBoss HumanoidCameraRig has no camera target")
	return basePart
end

local function applyCameraOffsetX(attachment, p: number)
	local cFrame

	if attachment:IsA("Attachment") then
		local parent = attachment.Parent
		assert(parent and parent:IsA("BasePart"), "LastSummerBoss camera target attachment has no BasePart parent")
		cFrame = attachment.CFrame
		attachment = parent
	else
		cFrame = CFrame.new()
	end

	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "CutsceneCameraOffset"
	attachment2.CFrame = cFrame * CFrame.new(p, 0, 0)
	attachment2.Parent = attachment
	return attachment2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopCameraFreeze()
	if flag then
		RunService:UnbindFromRenderStep("LastSummerBossCutsceneCameraFreeze")
		flag = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopEndFade()
	if flag2 then
		RunService:UnbindFromRenderStep("LastSummerBossCutsceneEndFade")
		flag2 = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function watchCameraFreeze(cameraTrack, p: number)
	stopCameraFreeze() -- equivalent call inferred; original call site unknown
	flag = true
	local cFrame = nil
	RunService:BindToRenderStep("LastSummerBossCutsceneCameraFreeze", v, function()
		local currentCamera = Workspace.CurrentCamera

		if not currentCamera then
			return
		end

		if not cFrame then
			if cameraTrack.Length <= 0 or cameraTrack.TimePosition < cameraTrack.Length - p then
				return
			else
				cFrame = currentCamera.CFrame
			end
		end

		currentCamera.CFrame = cFrame
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function watchCutsceneEndFade(cameraTrack, cutsceneEndFadeSeconds: number)
	stopEndFade() -- equivalent call inferred; original call site unknown
	flag2 = true
	local flag4 = false
	RunService:BindToRenderStep("LastSummerBossCutsceneEndFade", v2, function()
		if flag4 or (cameraTrack.Length <= 0 or cameraTrack.TimePosition < cameraTrack.Length - cutsceneEndFadeSeconds) then
			return
		end

		flag4 = true
		task.spawn(CutsceneFade.toBlack, cutsceneEndFadeSeconds)
		task.defer(stopEndFade)
	end)
end

local function hideModel(folder)
	for _, descendant in folder:GetDescendants() do
		if not (descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture")) then
			continue
		end

		descendant.Transparency = 1
	end
end

local function hideWorldAndHudForCutscene(instance)
	if flag3 then
		return
	end

	flag3 = true
	local treadmills = instance:FindFirstChild("Treadmills")

	if treadmills then
		for _, descendant in treadmills:GetDescendants() do
			if descendant:IsA("BasePart") then
				transparenciesByDescendant[descendant] = descendant.Transparency
				descendant.Transparency = 1
			elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") then
				enabledsByDescendant[descendant] = descendant.Enabled
				descendant.Enabled = false
			end
		end
	end

	local localPlayer = Players.LocalPlayer
	local playerGui

	if localPlayer then
		playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	end

	if playerGui then
		for _, frame in CollectionService:GetTagged("UI") do
			if not (frame:IsA("Frame") and frame:IsDescendantOf(playerGui)) then
				continue
			end

			visibilityByFrame[frame] = frame.Visible
			frame.Visible = false
		end
	end
end

local function restoreWorldAndHud()
	if not flag3 then
		return
	end

	flag3 = false

	for k, transparency in transparenciesByDescendant do
		if k.Parent then
			k.Transparency = transparency
		end
	end

	table.clear(transparenciesByDescendant)

	for effect, enabled in enabledsByDescendant do
		if not (effect.Parent and (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail"))) then
			continue
		end

		effect.Enabled = enabled
	end

	table.clear(enabledsByDescendant)

	for k, visible in visibilityByFrame do
		if k.Parent then
			k.Visible = visible
		end
	end

	table.clear(visibilityByFrame)
end

local function playGlobalSound(childName: string)
	local sound = ReplicatedStorage.AdminAbuse.LastSummerBoss.SFX:FindFirstChild(childName)

	if not (sound and sound:IsA("Sound")) then
		warn((`[LastSummerBoss] SFX.{childName} was not found`))
		return
	end

	local clone = sound:Clone()
	clone.Looped = false
	clone.Parent = SoundService
	Debris:AddItem(clone, 30)
	SoundService:PlayLocalSound(clone)
end

local function resolvePortalAttachment(instance, p: number)
	local scriptables = instance:FindFirstChild("Scriptables")
	local vFXPortals

	if scriptables then
		vFXPortals = scriptables:FindFirstChild("VFXPortals")
	end

	local child

	if vFXPortals then
		child = vFXPortals:FindFirstChild("Portal" .. tostring(p))
	end

	if not child then
		return nil, (`Scriptables.VFXPortals.Portal{p} was not found`)
	end

	local attachment = child:FindFirstChildWhichIsA("Attachment", true)

	if attachment then
		return attachment
	end

	return nil, (`Scriptables.VFXPortals.Portal{p} has no Attachment`)
end

local function enablePortalVfx(p, p2: number)
	local portalAttachment, v8 = resolvePortalAttachment(p, p2)

	if portalAttachment then
		for _, emitter in portalAttachment:GetDescendants() do
			if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
				continue
			end

			emitter.Enabled = true
			table.insert(emitters, emitter)
		end
	elseif v8 then
		warn((`[LastSummerBoss] {v8}`))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disableActivePortalVfx()
	for _, v8 in emitters do
		if v8.Parent then
			v8.Enabled = false
		end
	end

	table.clear(emitters)
end

local function connectCameraTrackMarkers(cameraTrack, p, p2, callback, callback2)
	cameraTrack:GetMarkerReachedSignal("Portal"):Connect(function(p3: string)
		local v8 = tonumber(p3)

		if v8 then
			enablePortalVfx(p, v8)
		end
	end)
	cameraTrack:GetMarkerReachedSignal("Dialogue"):Connect(function(p3: string)
		local v8 = p2 and callback and p2[tonumber(p3) or -1]

		if v8 then
			callback(v8.text, v8.duration)
		end
	end)

	local function firePlayerLine()
		if callback2 then
			callback2("Let's get this done.", 3)
		end
	end

	cameraTrack:GetMarkerReachedSignal("PlayerTalk"):Connect(firePlayerLine)
	cameraTrack:GetMarkerReachedSignal("PlayerDialogue"):Connect(firePlayerLine)
	cameraTrack:GetMarkerReachedSignal("Swing"):Connect(function()
		playGlobalSound("Swing1")
	end)
	cameraTrack:GetMarkerReachedSignal("Slide"):Connect(function()
		playGlobalSound("Slide")
	end)
	cameraTrack:GetMarkerReachedSignal("Lock_Hit"):Connect(function()
		playGlobalSound("Lock_Hit")
	end)
end

local function getOrCreatePersistentModel(parent)
	if v3 then
		return v3
	end

	local anchor = parent:FindFirstChild("Anchor") or parent:WaitForChild("Anchor", 10)
	assert(anchor and anchor:IsA("BasePart"), "LastSummerBoss live map Anchor was not found")
	local clone = getCutsceneTemplate():Clone()
	clone.Name = "ActiveLastSummerBossCutscene"
	clone.Parent = parent
	clone:PivotTo(anchor.CFrame * CFrame.new(0, Config.cutsceneVerticalOffsetY, 0))
	hideModel(clone)
	local playerRig = clone:FindFirstChild("PlayerRig")
	assert(playerRig and playerRig:IsA("Model"), "LastSummerBoss cutscene rig 'PlayerRig' was not found")
	applyLocalPlayerAppearance(playerRig)
	v3 = clone
	return clone
end

local function buildBundle(persistentModel, data, p: number?)
	local humanoidCameraRig = persistentModel:FindFirstChild("HumanoidCameraRig")
	assert(
		humanoidCameraRig and humanoidCameraRig:IsA("Model"),
		"LastSummerBoss cutscene rig 'HumanoidCameraRig' was not found"
	)
	local cameraTarget = getCameraTarget(humanoidCameraRig)

	if p and p ~= 0 then
		cameraTarget = applyCameraOffsetX(cameraTarget, p)
	end

	local v8 = {
		track = AdminAbuseUtils.Animations.loadAnimation(humanoidCameraRig, data.camera),
		fadeTime = 0
	}
	local tracks = { v8 }
	local rigs = {}

	for _, v10 in {
		{
			rigName = "PlayerRig",
			animationId = data.player
		},
		{
			rigName = "LuckymatRig",
			animationId = data.luckymat
		},
		{
			rigName = "LokiiRig",
			animationId = data.lokii
		},
		{
			rigName = "TheMaskRig",
			animationId = data.theMask
		},
		{
			rigName = "ChichineRig",
			animationId = data.chichine
		},
		{
			rigName = "CageRig",
			animationId = data.cage
		}
	} do
		local rig = getRig(persistentModel, v10.rigName) -- equivalent call inferred; original call site unknown
		table.insert(tracks, {
			track = AdminAbuseUtils.Animations.loadAnimation(rig, v10.animationId),
			fadeTime = 0
		})
		table.insert(rigs, rig)
	end

	return {
		cameraTrack = v8.track,
		cameraTarget = cameraTarget,
		tracks = tracks,
		visibleRigs = rigs
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensurePhaseBundle(parent, p2: string)
	local persistentModel = getOrCreatePersistentModel(parent)

	if p2 == "opening" then
		if not v4 then
			v4 = buildBundle(persistentModel, Config.openingCutsceneAnimations, nil)
		end
	elseif not v5 then
		v5 = buildBundle(persistentModel, Config.endingCutsceneAnimations, Config.endingCameraOffsetX)
	end
end

local function waitForCutsceneReady(p: string)
	local v8 = os.clock() + 10

	while true do
		local v9

		if p == "opening" then
			v9 = v4
		else
			v9 = v5
		end

		if v9 then
			local v10 = false

			for _, track in v9.tracks do
				if not (track.track.Length <= 0) then
					continue
				end

				v10 = true
				break
			end

			if not v10 then
				return v9
			end
		end

		if v8 <= os.clock() then
			return nil
		else
			RunService.Heartbeat:Wait()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function finishPhase(p: string)
	if v7 == p then
		v7 = nil
		v6 = nil
	end

	stopCameraFreeze() -- equivalent call inferred; original call site unknown
	stopEndFade() -- equivalent call inferred; original call site unknown
	disableActivePortalVfx() -- equivalent call inferred; original call site unknown

	if p == "opening" then
		v4 = nil
	else
		v5 = nil
	end
end

local function playUnchecked(parent, p2: string, p3, callback, callback2, p4: number?, callback3, callback4, p5: number?)
	if RunService:IsServer() then
		return
	end

	stopCameraFreeze() -- equivalent call inferred; original call site unknown
	stopEndFade() -- equivalent call inferred; original call site unknown
	CutsceneFade.toBlack(Config.cutsceneStartFadeSeconds)

	if v6 then
		AdminAbuseUtils.Cutscenes.stop(v6)
		v6 = nil
	end

	v7 = p2

	if callback3 then
		callback3()
	end

	ensurePhaseBundle(parent, p2) -- equivalent call inferred; original call site unknown
	local v8 = waitForCutsceneReady(p2)

	if v7 ~= p2 then
		return
	end

	if v8 then
		connectCameraTrackMarkers(v8.cameraTrack, parent, p3, callback2, callback4)

		if p5 then
			enablePortalVfx(parent, p5)
		end

		hideWorldAndHudForCutscene(parent)
		v6 = AdminAbuseUtils.Cutscenes.play({
			name = "LastSummerBossCutscene",
			cameraTarget = v8.cameraTarget,
			tracks = v8.tracks,
			visibleRigs = v8.visibleRigs,
			fieldOfView = Config.cutsceneFieldOfView,
			durationSeconds = v8.cameraTrack.Length,
			onFinished = function(flag4: boolean)
				restoreWorldAndHud()
				finishPhase(p2) -- equivalent call inferred; original call site unknown

				if callback then
					callback(flag4)
				end

				CutsceneFade.fromBlack(Config.cutsceneFadeInSeconds)
			end
		})

		if v6 then
			task.spawn(CutsceneFade.fromBlack, Config.cutsceneFadeInSeconds)
			watchCutsceneEndFade(v8.cameraTrack, Config.cutsceneEndFadeSeconds) -- equivalent call inferred; original call site unknown

			if p4 and p4 > 0 then
				watchCameraFreeze(v8.cameraTrack, p4) -- equivalent call inferred; original call site unknown
			end
		else
			restoreWorldAndHud()
			finishPhase(p2) -- equivalent call inferred; original call site unknown
			CutsceneFade.fromBlack(Config.cutsceneFadeInSeconds)

			if callback then
				callback(false)
			end
		end
	else
		warn("[LastSummerBoss] Cutscene animations never loaded for this client; skipping the cutscene and leaving the camera unlocked")
		v7 = nil
		CutsceneFade.fromBlack(Config.cutsceneFadeInSeconds)

		if callback then
			callback(false)
		end
	end
end

local function play(parent, p2: string, p3, callback, callback2, p4: number?, callback3, callback4, p5: number?)
	local v8, v9 = xpcall(function()
		playUnchecked(parent, p2, p3, callback, callback2, p4, callback3, callback4, p5)
	end, debug.traceback)

	if v8 then
		return
	end

	stopCameraFreeze() -- equivalent call inferred; original call site unknown
	stopEndFade() -- equivalent call inferred; original call site unknown
	disableActivePortalVfx() -- equivalent call inferred; original call site unknown
	restoreWorldAndHud()

	if v6 then
		AdminAbuseUtils.Cutscenes.stop(v6)
		v6 = nil
	end

	v7 = nil
	CutsceneFade.fromBlack(Config.cutsceneFadeInSeconds)
	warn((`[LastSummerBoss] Cutscene setup failed: {tostring(v9)}`))

	if callback then
		callback(false)
	end
end

local Cutscenes = {}

function Cutscenes.getEndingDurationSeconds()
	assert(RunService:IsServer(), "Cutscenes.getEndingDurationSeconds can only be called on the server")
	AdminAbuseUtils.Animations.preloadAsync({ Config.endingCutsceneAnimations.camera }, {
		maxAttempts = 3,
		retryBaseSeconds = 1,
		retryMaxSeconds = 4
	})
	local preload = AdminAbuseUtils.Animations.preload(Config.endingCutsceneAnimations.camera)
	local v8 = os.clock() + 10

	while preload.Length <= 0 and os.clock() < v8 do
		RunService.Heartbeat:Wait()
	end

	if preload.Length > 0 then
		return preload.Length
	end

	return nil
end

function Cutscenes.playOpening(p, callback, callback2, callback3, callback4)
	play(p, "opening", Config.openingDialogue, callback, callback2, nil, callback3, callback4)
end

function Cutscenes.playEnding(parent, callback, callback2, callback3)
	play(
		parent,
		"ending",
		Config.endingDialogue,
		callback,
		callback2,
		Config.endingCameraFreezeLeadSeconds,
		callback3,
		nil,
		2
	)
end

function Cutscenes.cleanup()
	stopCameraFreeze() -- equivalent call inferred; original call site unknown
	stopEndFade() -- equivalent call inferred; original call site unknown
	disableActivePortalVfx() -- equivalent call inferred; original call site unknown
	local v8 = v6 ~= nil

	if v8 then
		CutsceneFade.toBlack(Config.cutsceneEndFadeSeconds)
	end

	restoreWorldAndHud()

	if v6 then
		AdminAbuseUtils.Cutscenes.stop(v6)
		v6 = nil
	end

	v7 = nil

	if v3 then
		v3:Destroy()
		v3 = nil
	end

	v4 = nil
	v5 = nil

	if v8 then
		task.spawn(function()
			CutsceneFade.fromBlack(Config.cutsceneFadeInSeconds)
			CutsceneFade.cleanup()
		end)
	else
		CutsceneFade.cleanup()
	end
end

return Cutscenes