local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local AdminAbuseUtils = require(script.Parent.Parent.Parent.AdminAbuseUtils)
local InstanceUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.InstanceUtils)
local CutsceneFade = require(script.Parent.CutsceneFade)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local Cutscenes = {}
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local v = Enum.RenderPriority.Camera.Value + 3
local v2 = nil
local connection = nil
local threads = {}
local v3 = {}
local v4 = false
local flag = false
local flag2 = false
local v5 = nil
local visibilityByFrame = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getRigsFolder(instance, p)
	local scriptables = instance:FindFirstChild("Scriptables")

	if scriptables then
		return (scriptables:FindFirstChild(p.cutsceneRigsFolderName))
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getHoldingFolder()
	return ReplicatedStorage:FindFirstChild("AllanBossRoomCutsceneRigs")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSceneCloneParent()
	return Workspace:FindFirstChild("AdminAbuse") or Workspace
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyActiveSceneClone()
	if v5 then
		v5:Destroy()
		v5 = nil
	end
end

local function resolveScene(data, childName: string)
	local holdingFolder = getHoldingFolder() -- equivalent call inferred; original call site unknown
	local child

	if holdingFolder then
		child = holdingFolder:FindFirstChild(childName)
	end

	if not child then
		return nil
	end

	destroyActiveSceneClone() -- equivalent call inferred; original call site unknown
	local clone = child:Clone()
	clone.Parent = getSceneCloneParent()
	v5 = clone
	local models = {}
	local cameraRig = nil
	local lokiiRig = nil
	local allanRig = nil
	local bridgeRig = nil

	for _, model in clone:GetChildren() do
		if model.Name == data.cutsceneCameraRigName and model:IsA("Model") then
			cameraRig = model
		elseif model.Name == data.cutsceneLokiiRigName and model:IsA("Model") then
			lokiiRig = model
		elseif model.Name == data.cutsceneAllanRigName and model:IsA("Model") then
			allanRig = model
		elseif model.Name == data.cutsceneBridgeRigName and model:IsA("Model") then
			bridgeRig = model
		else
			table.insert(models, model)
		end
	end

	if cameraRig and lokiiRig and allanRig then
		return {
			cameraRig = cameraRig,
			lokiiRig = lokiiRig,
			allanRig = allanRig,
			bridgeRig = bridgeRig,
			decorativeProps = models
		}
	end

	destroyActiveSceneClone() -- equivalent call inferred; original call site unknown
	return nil
end

local function getCameraTarget(instance)
	local cameraTarget = instance:FindFirstChild("CameraTarget", true) or instance:FindFirstChild("Torso", true)

	if cameraTarget and cameraTarget:IsA("BasePart") then
		return cameraTarget
	end

	return instance:FindFirstChildWhichIsA("BasePart", true)
end

local function getLiveRigs(p, p2)
	local potentialInstances = {}

	for _, v6 in { p2.lokiiBossRigPath, p2.allanBossRigPath } do
		local potentialInstance = InstanceUtils.getPotentialInstance(p, v6)

		if potentialInstance then
			table.insert(potentialInstances, potentialInstance)
		end
	end

	return potentialInstances
end

local function setLiveRigVisible(p, data, enabled: boolean)
	if v4 and enabled then
		return
	end

	for _, folder in getLiveRigs(p, data) do
		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" then
				descendant.Transparency = enabled and 0 or 1
			elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
				descendant.Transparency = enabled and 0 or 1
			elseif descendant:IsA("BillboardGui") then
				descendant.Enabled = enabled
			end
		end
	end
end

local function getRigRoot(instance)
	local primaryPart = instance.PrimaryPart or instance:FindFirstChild("HumanoidRootPart")

	if primaryPart and primaryPart:IsA("BasePart") then
		return primaryPart
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function anchorRig(instance)
	local primaryPart = instance.PrimaryPart or instance:FindFirstChild("HumanoidRootPart")

	if not (primaryPart and primaryPart:IsA("BasePart")) then
		primaryPart = nil
	end

	if primaryPart then
		primaryPart.Anchored = true
	end
end

local anchorSceneChildren

anchorSceneChildren = function(instance)
	for _, child in instance:GetChildren() do
		if child:IsA("Folder") then
			anchorSceneChildren(child)
		elseif child:IsA("BasePart") then
			child.Anchored = true
		elseif child:IsA("Model") then
			if child:FindFirstChildWhichIsA("Humanoid", true) ~= nil or child:FindFirstChildWhichIsA(
				"AnimationController",
				true
			) ~= nil then
				anchorRig(child) -- equivalent call inferred; original call site unknown
			else
				for _, part in child:GetDescendants() do
					if part:IsA("BasePart") then
						part.Anchored = true
					end
				end
			end
		end
	end
end

local applyPlacement

applyPlacement = function(instance, cframe: CFrame)
	for _, child in instance:GetChildren() do
		if child:IsA("Model") then
			child:PivotTo(cframe * child:GetPivot())
		elseif child:IsA("BasePart") then
			child.CFrame = cframe * child.CFrame
		elseif child:IsA("Folder") then
			applyPlacement(child, cframe)
		end
	end
end

local function hideSceneInstance(part)
	if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture") then
		part.Transparency = 1
	elseif part:IsA("ParticleEmitter") or part:IsA("Beam") or part:IsA("Trail") or part:IsA("BillboardGui") then
		part.Enabled = false
	end
end

local function setSceneEffectsEnabled(items, enabled: boolean)
	for _, folder in items do
		for _, descendant in folder:GetDescendants() do
			if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("BillboardGui")) then
				continue
			end

			descendant.Enabled = enabled
		end
	end
end

local function hideHudForCutscene()
	if flag2 then
		return
	end

	flag2 = true
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

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreHud()
	if not flag2 then
		return
	end

	flag2 = false

	for k, visible in visibilityByFrame do
		if k.Parent then
			k.Visible = visible
		end
	end

	table.clear(visibilityByFrame)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopEndFade()
	if flag then
		RunService:UnbindFromRenderStep("AllanBossRoomCutsceneEndFade")
		flag = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function watchCutsceneEndFade(animation, cutsceneEndFadeSeconds: number)
	stopEndFade() -- equivalent call inferred; original call site unknown

	if cutsceneEndFadeSeconds <= 0 then
		return
	end

	flag = true
	local flag3 = false
	RunService:BindToRenderStep("AllanBossRoomCutsceneEndFade", v, function()
		if flag3 or (animation.Length <= 0 or animation.TimePosition < animation.Length - cutsceneEndFadeSeconds) then
			return
		end

		flag3 = true
		task.spawn(CutsceneFade.toBlack, cutsceneEndFadeSeconds)
		task.defer(stopEndFade)
	end)
end

local function stopDialogueTimers()
	for _, v6 in threads do
		if coroutine.status(v6) ~= "dead" then
			task.cancel(v6)
		end
	end

	table.clear(threads)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fireDialogueLine(p: number, data, callback)
	if v3[p] then
		return
	end

	v3[p] = true
	callback(data.text, data.speaker, data.duration)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function connectDialogueMarkers(object, p, callback)
	if connection then
		connection:Disconnect()
	end

	connection = object:GetMarkerReachedSignal("Dialogue"):Connect(function(p2: string)
		if p and callback then
			local v6 = tonumber(p2) or -1
			local v7 = p[v6]

			if v7 then
				fireDialogueLine(v6, v7, callback) -- equivalent call inferred; original call site unknown
			end
		end
	end)
end

local function scheduleDialogueTimers(items, callback)
	stopDialogueTimers()

	if not (items and callback) then
		return
	end

	for k, item in items do
		if item.atSeconds then
			table.insert(threads, task.delay(item.atSeconds, fireDialogueLine, k, item, callback))
		end
	end
end

local function play(p, data, p2: string, data2, p3, flag3: boolean, callback, callback2)
	if RunService:IsServer() then
		return
	end

	stopEndFade() -- equivalent call inferred; original call site unknown
	CutsceneFade.toBlack(data.cutsceneStartFadeSeconds)

	if v2 then
		AdminAbuseUtils.Cutscenes.stop(v2)
		v2 = nil
	end

	local scene = resolveScene(data, p2)
	local cameraTarget

	if scene then
		local cameraRig = scene.cameraRig
		cameraTarget = cameraRig:FindFirstChild("CameraTarget", true) or cameraRig:FindFirstChild("Torso", true)

		if not (cameraTarget and cameraTarget:IsA("BasePart")) then
			cameraTarget = cameraRig:FindFirstChildWhichIsA("BasePart", true)
		end
	end

	if scene and cameraTarget then
		setLiveRigVisible(p, data, false)
		hideHudForCutscene()
		anchorRig(scene.lokiiRig) -- equivalent call inferred; original call site unknown
		anchorRig(scene.allanRig) -- equivalent call inferred; original call site unknown
		local animation = AdminAbuseUtils.Animations.loadAnimation(scene.cameraRig, data2.camera)
		table.clear(v3)
		connectDialogueMarkers(animation, p3, callback) -- equivalent call inferred; original call site unknown
		scheduleDialogueTimers(p3, callback)
		local tracks = {
			{
				track = animation,
				fadeTime = 0
			},
			{
				track = AdminAbuseUtils.Animations.loadAnimation(scene.lokiiRig, data2.lokii),
				fadeTime = 0
			},
			{
				track = AdminAbuseUtils.Animations.loadAnimation(scene.allanRig, data2.allan),
				fadeTime = 0
			}
		}
		local visibleRigs = { scene.lokiiRig, scene.allanRig }

		if data2.bridge and scene.bridgeRig then
			table.insert(tracks, {
				track = AdminAbuseUtils.Animations.loadAnimation(scene.bridgeRig, data2.bridge),
				fadeTime = 0
			})
			table.insert(visibleRigs, scene.bridgeRig)
		end

		for _, decorativeProp in scene.decorativeProps do
			table.insert(visibleRigs, decorativeProp)
		end

		setSceneEffectsEnabled(visibleRigs, true)
		local v8 = AdminAbuseUtils.Cutscenes.play({
			name = "AllanBossRoomCutscene",
			cameraTarget = cameraTarget,
			fieldOfView = data.cutsceneFieldOfView,
			tracks = tracks,
			visibleRigs = visibleRigs,
			controlCamera = true,
			onFinished = function(flag4: boolean)
				stopEndFade() -- equivalent call inferred; original call site unknown
				stopDialogueTimers()
				restoreHud() -- equivalent call inferred; original call site unknown
				setSceneEffectsEnabled(visibleRigs, false)
				destroyActiveSceneClone() -- equivalent call inferred; original call site unknown

				if v2 and v2.name == "AllanBossRoomCutscene" then
					v2 = nil
				end

				if flag3 then
					v4 = true
				else
					setLiveRigVisible(p, data, true)
				end

				if callback2 then
					callback2(flag4)
				end

				CutsceneFade.fromBlack(data.cutsceneFadeInSeconds)
			end
		})
		v2 = v8

		if v8 then
			task.spawn(CutsceneFade.fromBlack, data.cutsceneFadeInSeconds)
			watchCutsceneEndFade(animation, data.cutsceneEndFadeSeconds) -- equivalent call inferred; original call site unknown
		else
			stopDialogueTimers()
			restoreHud() -- equivalent call inferred; original call site unknown
			setSceneEffectsEnabled(visibleRigs, false)
			destroyActiveSceneClone() -- equivalent call inferred; original call site unknown

			if flag3 then
				v4 = true
			else
				setLiveRigVisible(p, data, true)
			end

			CutsceneFade.fromBlack(data.cutsceneFadeInSeconds)

			if callback2 then
				callback2(false)
			end
		end
	else
		destroyActiveSceneClone() -- equivalent call inferred; original call site unknown
		local v6

		if ReplicatedStorage:FindFirstChild("AllanBossRoomCutsceneRigs") == nil then
			v6 = string.format(
				"Cutscene rigs were never extracted; ReplicatedStorage.%s is missing",
				"AllanBossRoomCutsceneRigs"
			)
		else
			v6 = string.format(
				"Cutscene rig(s) missing from the cached scene ReplicatedStorage.%s.%s",
				"AllanBossRoomCutsceneRigs",
				p2
			)
		end

		logger:warn(v6)
		CutsceneFade.fromBlack(data.cutsceneFadeInSeconds)

		if callback2 then
			callback2(false)
		end
	end
end

function Cutscenes.extractRigs(instance, p, cframe: CFrame)
	assert(RunService:IsServer(), "AllanBossRoom.Cutscenes.extractRigs is server-only")
	local rigsFolder = getRigsFolder(instance, p) -- equivalent call inferred; original call site unknown

	if not rigsFolder then
		logger:warn(string.format(
			"Cutscene rigs folder 'Scriptables.%s' not found under %s",
			p.cutsceneRigsFolderName,
			instance:GetFullName()
		))
		return
	end

	for _, part in rigsFolder:GetDescendants() do
		hideSceneInstance(part)

		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end

	anchorSceneChildren(rigsFolder)
	applyPlacement(rigsFolder, cframe)
	Cutscenes.releaseRigs()
	rigsFolder.Name = "AllanBossRoomCutsceneRigs"
	rigsFolder.Parent = ReplicatedStorage
end

function Cutscenes.releaseRigs()
	assert(RunService:IsServer(), "AllanBossRoom.Cutscenes.releaseRigs is server-only")
	local holdingFolder = getHoldingFolder() -- equivalent call inferred; original call site unknown

	if holdingFolder then
		holdingFolder:Destroy()
	end
end

function Cutscenes.getEndingDurationSeconds(p)
	assert(RunService:IsServer(), "AllanBossRoom.Cutscenes.getEndingDurationSeconds is server-only")
	local preload = AdminAbuseUtils.Animations.preload(p.endingCutsceneAnimations.camera)
	local v6 = os.clock() + 10

	while preload.Length <= 0 and os.clock() < v6 do
		RunService.Heartbeat:Wait()
	end

	if preload.Length > 0 then
		return preload.Length
	end

	return nil
end

function Cutscenes.playOpening(p, data, callback, callback2)
	play(
		p,
		data,
		data.cutsceneIntroFolderName,
		data.openingCutsceneAnimations,
		data.openingDialogue,
		false,
		callback,
		callback2
	)
end

function Cutscenes.playEnding(p, data, callback, callback2)
	play(
		p,
		data,
		data.cutsceneOutroFolderName,
		data.endingCutsceneAnimations,
		data.endingDialogue,
		true,
		callback,
		callback2
	)
end

function Cutscenes.cleanup()
	stopEndFade() -- equivalent call inferred; original call site unknown
	stopDialogueTimers()
	destroyActiveSceneClone() -- equivalent call inferred; original call site unknown

	if v2 then
		AdminAbuseUtils.Cutscenes.stop(v2)
		v2 = nil
	end

	if connection then
		connection:Disconnect()
		connection = nil
	end

	table.clear(v3)
	v4 = false
	CutsceneFade.cleanup()
end

return Cutscenes