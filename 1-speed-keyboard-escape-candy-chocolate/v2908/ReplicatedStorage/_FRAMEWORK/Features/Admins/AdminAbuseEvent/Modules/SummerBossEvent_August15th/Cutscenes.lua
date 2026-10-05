local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local AdminAbuseUtils = require(script.Parent.Parent.Parent.AdminAbuseUtils)
local Config = require(script.Parent.Config)
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local v = Enum.RenderPriority.Camera.Value + 2
local v2 = nil
local v3 = nil
local v4 = {}
local v5 = {}
local flag = false

local function getCutsceneTemplate()
	local adminAbuse = ReplicatedStorage:FindFirstChild("AdminAbuse")
	local summerBossEvent_August15th

	if adminAbuse then
		summerBossEvent_August15th = adminAbuse:FindFirstChild("SummerBossEvent_August15th")
	end

	local assets

	if summerBossEvent_August15th then
		assets = summerBossEvent_August15th:FindFirstChild("Assets")
	end

	local cutsceneModel

	if assets then
		cutsceneModel = assets:FindFirstChild("CutsceneModel")
	end

	assert(
		cutsceneModel and cutsceneModel:IsA("Model"),
		"SummerBossEvent_August15th.Assets.CutsceneModel was not found"
	)
	return cutsceneModel
end

local function getRig(instance, childName: string)
	local model = instance:FindFirstChild(childName)
	assert(model and model:IsA("Model"), (`SummerBossEvent_August15th cutscene rig '{childName}' was not found`))
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
	assert(basePart, "SummerBossEvent_August15th HumanoidCameraRig has no camera target")
	return basePart
end

local function applyCameraOffsetX(attachment, p: number)
	local cFrame

	if attachment:IsA("Attachment") then
		local parent = attachment.Parent
		assert(
			parent and parent:IsA("BasePart"),
			"SummerBossEvent_August15th camera target attachment has no BasePart parent"
		)
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
		RunService:UnbindFromRenderStep("SummerBossCutsceneCameraFreeze")
		flag = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function watchCameraFreeze(track, p: number)
	stopCameraFreeze() -- equivalent call inferred; original call site unknown
	flag = true
	local cFrame = nil
	RunService:BindToRenderStep("SummerBossCutsceneCameraFreeze", v, function()
		local currentCamera = Workspace.CurrentCamera

		if not currentCamera then
			return
		end

		if not cFrame then
			if track.Length <= 0 or track.TimePosition < track.Length - p then
				return
			else
				cFrame = currentCamera.CFrame
			end
		end

		currentCamera.CFrame = cFrame
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

local function playPortalSound(folder, enabled: boolean)
	local v6 = enabled and "PortalOpen" or "PortalClose"
	local sound = ReplicatedStorage.AdminAbuse.SummerBossEvent_August15th.SFX:FindFirstChild(v6)

	if not (sound and sound:IsA("Sound")) then
		warn((`[SummerBossEvent_August15th] SFX.{v6} was not found`))
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
	local swing1 = ReplicatedStorage.AdminAbuse.SummerBossEvent_August15th.SFX:FindFirstChild("Swing1")

	if not (swing1 and swing1:IsA("Sound")) then
		warn("[SummerBossEvent_August15th] SFX.Swing1 was not found")
		return
	end

	local clone = swing1:Clone()
	clone.Looped = false
	clone.Parent = SoundService
	Debris:AddItem(clone, 30)
	SoundService:PlayLocalSound(clone)
end

local function setPortalVisible(folder, enabled: boolean)
	local v6 = v5[folder]

	if v6 == nil then
		v6 = folder.Transparency < 1
	end

	if v6 == enabled then
		return
	end

	v5[folder] = enabled
	playPortalSound(folder, enabled)
	local v7 = v4[folder]

	if v7 then
		v7:Cancel()
	end

	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end

	local tween = TweenService:Create(folder, tweenInfo, {
		Transparency = enabled and 0 or 1
	})
	v4[folder] = tween
	tween.Completed:Once(function()
		if v4[folder] == tween then
			v4[folder] = nil
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

	assert(part and part:IsA("Part"), (`SummerBossEvent_August15th Scriptables.{childName} was not found`))
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
	assert(anchor and anchor:IsA("BasePart"), "SummerBossEvent_August15th live map Anchor was not found")
	local clone = getCutsceneTemplate():Clone()
	clone.Name = "ActiveSummerBossCutscene"
	clone.Parent = parent
	clone:PivotTo(anchor.CFrame * CFrame.new(0, Config.cutsceneVerticalOffsetY, 0))
	hideModel(clone)
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyModel(instance)
	if v2 == instance then
		v2 = nil
		v3 = nil
	end

	stopCameraFreeze() -- equivalent call inferred; original call site unknown
	instance:Destroy()
end

local function playUnchecked(instance, data, callback, callback2, p: number?, p2: number?)
	if RunService:IsServer() then
		return
	end

	stopCameraFreeze() -- equivalent call inferred; original call site unknown

	if v3 then
		AdminAbuseUtils.Cutscenes.stop(v3)
	end

	if v2 then
		v2:Destroy()
		v2 = nil
	end

	local placedModel = createPlacedModel(instance)
	v2 = placedModel
	local humanoidCameraRig = placedModel:FindFirstChild("HumanoidCameraRig")
	assert(
		humanoidCameraRig and humanoidCameraRig:IsA("Model"),
		"SummerBossEvent_August15th cutscene rig 'HumanoidCameraRig' was not found"
	)
	local tragedyRig = placedModel:FindFirstChild("TragedyRig")
	assert(tragedyRig and tragedyRig:IsA("Model"), "SummerBossEvent_August15th cutscene rig 'TragedyRig' was not found")
	local tragedyRig2 = placedModel:FindFirstChild("TragedyRig2")
	assert(
		tragedyRig2 and tragedyRig2:IsA("Model"),
		"SummerBossEvent_August15th cutscene rig 'TragedyRig2' was not found"
	)
	local scriptables = instance:WaitForChild("Scriptables", 10)
	local fXPortal1

	if scriptables then
		fXPortal1 = scriptables:WaitForChild("FXPortal1", 10)
	end

	assert(fXPortal1 and fXPortal1:IsA("Part"), "SummerBossEvent_August15th Scriptables.FXPortal1 was not found")
	local scriptables2 = instance:WaitForChild("Scriptables", 10)
	local fXPortal2

	if scriptables2 then
		fXPortal2 = scriptables2:WaitForChild("FXPortal2", 10)
	end

	assert(fXPortal2 and fXPortal2:IsA("Part"), "SummerBossEvent_August15th Scriptables.FXPortal2 was not found")
	local cameraTarget = getCameraTarget(humanoidCameraRig)

	if p and p ~= 0 then
		cameraTarget = applyCameraOffsetX(cameraTarget, p)
	end

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

	for _, v7 in tracks do
		connectTrackMarkers(v7.track, fXPortal1, fXPortal2, callback2)
	end

	v3 = AdminAbuseUtils.Cutscenes.play({
		name = "SummerBossCutscene",
		cameraTarget = cameraTarget,
		tracks = tracks,
		visibleRigs = tragedyRig2s,
		fieldOfView = Config.cutsceneFieldOfView,
		onFinished = function(flag2: boolean)
			destroyModel(placedModel) -- equivalent call inferred; original call site unknown

			if callback then
				callback(flag2)
			end
		end
	})

	if v3 then
		if p2 and p2 > 0 then
			watchCameraFreeze(tracks[1].track, p2) -- equivalent call inferred; original call site unknown
		end
	else
		destroyModel(placedModel) -- equivalent call inferred; original call site unknown

		if callback then
			callback(false)
		end
	end
end

local function play(parent, p2, callback, callback2, p3: number?, p4: number?)
	local v6, v7 = xpcall(function()
		playUnchecked(parent, p2, callback, callback2, p3, p4)
	end, debug.traceback)

	if v6 then
		return
	end

	stopCameraFreeze() -- equivalent call inferred; original call site unknown

	if v3 then
		AdminAbuseUtils.Cutscenes.stop(v3)
		v3 = nil
	elseif v2 then
		v2:Destroy()
		v2 = nil
	end

	warn((`[SummerBossEvent_August15th] Cutscene setup failed: {tostring(v7)}`))

	if callback then
		callback(false)
	end
end

local Cutscenes = {}

function Cutscenes.getEndingDurationSeconds()
	assert(RunService:IsServer(), "Cutscenes.getEndingDurationSeconds can only be called on the server")
	local preload = AdminAbuseUtils.Animations.preload(Config.endingCutsceneAnimations.camera)
	local v6 = os.clock() + 10

	while preload.Length <= 0 and os.clock() < v6 do
		RunService.Heartbeat:Wait()
	end

	if preload.Length > 0 then
		return preload.Length
	end

	return nil
end

function Cutscenes.SetPortalVisible(parent, flag2: boolean)
	setPortalVisible(parent, flag2)
end

function Cutscenes.playOpening(p, callback, callback2)
	play(p, Config.openingCutsceneAnimations, callback, callback2)
end

function Cutscenes.playEnding(parent, callback, callback2)
	play(
		parent,
		Config.endingCutsceneAnimations,
		callback,
		callback2,
		Config.endingCameraOffsetX,
		Config.endingCameraFreezeLeadSeconds
	)
end

function Cutscenes.cleanup()
	for k, v6 in v4 do
		v6:Cancel()
		v4[k] = nil
	end

	for k in v5 do
		v5[k] = nil
	end

	stopCameraFreeze() -- equivalent call inferred; original call site unknown

	if v3 then
		AdminAbuseUtils.Cutscenes.stop(v3)
	elseif v2 then
		v2:Destroy()
		v2 = nil
	end
end

return Cutscenes