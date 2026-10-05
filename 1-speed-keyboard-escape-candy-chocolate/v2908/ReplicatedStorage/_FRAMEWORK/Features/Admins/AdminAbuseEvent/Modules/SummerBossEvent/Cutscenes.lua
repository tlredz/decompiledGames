local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local AdminAbuseUtils = require(script.Parent.Parent.Parent.AdminAbuseUtils)
local Config = require(script.Parent.Config)
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local v = nil
local v2 = nil
local v3 = {}
local v4 = {}

local function getCutsceneTemplate()
	local adminAbuse = ReplicatedStorage:FindFirstChild("AdminAbuse")
	local summerBossEvent

	if adminAbuse then
		summerBossEvent = adminAbuse:FindFirstChild("SummerBossEvent")
	end

	local assets

	if summerBossEvent then
		assets = summerBossEvent:FindFirstChild("Assets")
	end

	local cutsceneModel

	if assets then
		cutsceneModel = assets:FindFirstChild("CutsceneModel")
	end

	assert(cutsceneModel and cutsceneModel:IsA("Model"), "SummerBossEvent.Assets.CutsceneModel was not found")
	return cutsceneModel
end

local function getRig(instance, childName: string)
	local model = instance:FindFirstChild(childName)
	assert(model and model:IsA("Model"), (`SummerBossEvent cutscene rig '{childName}' was not found`))
	return model
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
	assert(basePart, "SummerBossEvent HumanoidCameraRig has no camera target")
	return basePart
end

local function hideModel(folder)
	for _, descendant in folder:GetDescendants() do
		if not (descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture")) then
			continue
		end

		descendant.Transparency = 1
	end
end

local function playPortalSound(folder, enabled: boolean)
	local v5 = enabled and "PortalOpen" or "PortalClose"
	local sound = ReplicatedStorage.AdminAbuse.SummerBossEvent.SFX:FindFirstChild(v5)

	if not (sound and sound:IsA("Sound")) then
		warn((`[SummerBossEvent] SFX.{v5} was not found`))
		return
	end

	local clone = sound:Clone()
	clone.Looped = false
	clone.RollOffMinDistance = 60
	clone.RollOffMaxDistance = 500
	clone.RollOffMode = Enum.RollOffMode.InverseTapered
	clone.Parent = folder
	Debris:AddItem(clone, 30)
	clone:Play()
end

local function playGlobalSwingSound()
	local swing1 = ReplicatedStorage.AdminAbuse.SummerBossEvent.SFX:FindFirstChild("Swing1")

	if not (swing1 and swing1:IsA("Sound")) then
		warn("[SummerBossEvent] SFX.Swing1 was not found")
		return
	end

	local clone = swing1:Clone()
	clone.Looped = false
	clone.Parent = SoundService
	Debris:AddItem(clone, 30)
	SoundService:PlayLocalSound(clone)
end

local function setPortalVisible(folder, enabled: boolean)
	local v5 = v4[folder]

	if v5 == nil then
		v5 = folder.Transparency < 1
	end

	if v5 == enabled then
		return
	end

	v4[folder] = enabled
	playPortalSound(folder, enabled)
	local v6 = v3[folder]

	if v6 then
		v6:Cancel()
	end

	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end

	local tween = TweenService:Create(folder, tweenInfo, {
		Transparency = enabled and 0 or 1
	})
	v3[folder] = tween
	tween.Completed:Once(function()
		if v3[folder] == tween then
			v3[folder] = nil
		end
	end)
	tween:Play()
end

local function getPortal(instance, childName: string)
	local scriptables = instance:WaitForChild("Scriptables", 10)
	local part

	if scriptables then
		part = scriptables:WaitForChild(childName, 10)
	end

	assert(part and part:IsA("Part"), (`SummerBossEvent Scriptables.{childName} was not found`))
	return part
end

local function connectTrackMarkers(track, fXPortal1, fXPortal2, callback)
	track:GetMarkerReachedSignal("Portal1"):Connect(function(p: string)
		setPortalVisible(fXPortal1, p == "1")
	end)
	track:GetMarkerReachedSignal("Portal2"):Connect(function(p: string)
		setPortalVisible(fXPortal2, p == "1")
	end)
	track:GetMarkerReachedSignal("Masked"):Connect(function(p: string)
		if callback and p ~= "" then
			callback(p)
		end
	end)
	track:GetMarkerReachedSignal("Swing"):Connect(function()
		playGlobalSwingSound()
	end)
end

local function createPlacedModel(parent)
	local anchor = parent:FindFirstChild("Anchor") or parent:WaitForChild("Anchor", 10)
	assert(anchor and anchor:IsA("BasePart"), "SummerBossEvent live map Anchor was not found")
	local clone = getCutsceneTemplate():Clone()
	clone.Name = "ActiveSummerBossCutscene"
	clone.Parent = parent
	clone:PivotTo(anchor.CFrame)
	hideModel(clone)
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyModel(instance)
	if v == instance then
		v = nil
		v2 = nil
	end

	instance:Destroy()
end

local function playUnchecked(instance, data, callback, callback2)
	if RunService:IsServer() then
		return
	end

	if v2 then
		AdminAbuseUtils.Cutscenes.stop(v2)
	end

	if v then
		v:Destroy()
		v = nil
	end

	local placedModel = createPlacedModel(instance)
	v = placedModel
	local humanoidCameraRig = placedModel:FindFirstChild("HumanoidCameraRig")
	assert(
		humanoidCameraRig and humanoidCameraRig:IsA("Model"),
		"SummerBossEvent cutscene rig 'HumanoidCameraRig' was not found"
	)
	local tragedyRig = placedModel:FindFirstChild("TragedyRig")
	assert(tragedyRig and tragedyRig:IsA("Model"), "SummerBossEvent cutscene rig 'TragedyRig' was not found")
	local tragedyRig2 = placedModel:FindFirstChild("TragedyRig2")
	assert(tragedyRig2 and tragedyRig2:IsA("Model"), "SummerBossEvent cutscene rig 'TragedyRig2' was not found")
	local scriptables = instance:WaitForChild("Scriptables", 10)
	local fXPortal1

	if scriptables then
		fXPortal1 = scriptables:WaitForChild("FXPortal1", 10)
	end

	assert(fXPortal1 and fXPortal1:IsA("Part"), "SummerBossEvent Scriptables.FXPortal1 was not found")
	local scriptables2 = instance:WaitForChild("Scriptables", 10)
	local fXPortal2

	if scriptables2 then
		fXPortal2 = scriptables2:WaitForChild("FXPortal2", 10)
	end

	assert(fXPortal2 and fXPortal2:IsA("Part"), "SummerBossEvent Scriptables.FXPortal2 was not found")
	local tracks = {
		{
			track = AdminAbuseUtils.Animations.loadAnimation(humanoidCameraRig, data.camera),
			fadeTime = 0
		},
		{
			track = AdminAbuseUtils.Animations.loadAnimation(tragedyRig, data.characterOne),
			fadeTime = 0
		}
	}
	local tragedyRig2s = { tragedyRig }

	if data.characterTwo then
		table.insert(tracks, {
			track = AdminAbuseUtils.Animations.loadAnimation(tragedyRig2, data.characterTwo),
			fadeTime = 0
		})
		table.insert(tragedyRig2s, tragedyRig2)
	end

	for _, v6 in tracks do
		connectTrackMarkers(v6.track, fXPortal1, fXPortal2, callback2)
	end

	v2 = AdminAbuseUtils.Cutscenes.play({
		name = "SummerBossCutscene",
		cameraTarget = getCameraTarget(humanoidCameraRig),
		tracks = tracks,
		visibleRigs = tragedyRig2s,
		fieldOfView = Config.cutsceneFieldOfView,
		onFinished = function(flag: boolean)
			destroyModel(placedModel) -- equivalent call inferred; original call site unknown

			if callback then
				callback(flag)
			end
		end
	})

	if not v2 then
		destroyModel(placedModel) -- equivalent call inferred; original call site unknown

		if callback then
			callback(false)
		end
	end
end

local function play(parent, p2, callback, callback2)
	local v5, v6 = xpcall(function()
		playUnchecked(parent, p2, callback, callback2)
	end, debug.traceback)

	if v5 then
		return
	end

	if v2 then
		AdminAbuseUtils.Cutscenes.stop(v2)
		v2 = nil
	elseif v then
		v:Destroy()
		v = nil
	end

	warn((`[SummerBossEvent] Cutscene setup failed: {tostring(v6)}`))

	if callback then
		callback(false)
	end
end

local Cutscenes = {}

function Cutscenes.getEndingDurationSeconds()
	assert(RunService:IsServer(), "Cutscenes.getEndingDurationSeconds can only be called on the server")
	local preload = AdminAbuseUtils.Animations.preload(Config.endingCutsceneAnimations.camera)
	local v5 = os.clock() + 10

	while preload.Length <= 0 and os.clock() < v5 do
		RunService.Heartbeat:Wait()
	end

	if preload.Length > 0 then
		return preload.Length
	end

	return nil
end

function Cutscenes.SetPortalVisible(parent, enabled: boolean)
	setPortalVisible(parent, enabled)
end

function Cutscenes.playOpening(parent, callback, callback2)
	play(parent, Config.openingCutsceneAnimations, callback, callback2)
end

function Cutscenes.playEnding(parent, callback, callback2)
	play(parent, Config.endingCutsceneAnimations, callback, callback2)
end

function Cutscenes.cleanup()
	for k, v5 in v3 do
		v5:Cancel()
		v3[k] = nil
	end

	for k in v4 do
		v4[k] = nil
	end

	if v2 then
		AdminAbuseUtils.Cutscenes.stop(v2)
	elseif v then
		v:Destroy()
		v = nil
	end
end

return Cutscenes