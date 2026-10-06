local module = require("@game/ReplicatedStorage/Omni")
local v = {
	StartAttribute = "StartTime",
	FadeOutInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
}
local v2 = {
	Path = "Cutscene.Secret",
	FinishTime = 12.65
}
local v3 = {
	Name = "SecretCutsceneFlash",
	Color = Color3.new(1, 1, 1),
	DisplayOrder = 100,
	LeadTime = 1,
	FadeOutInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 1)
}
local _ = {
	Amplitude = 0.3,
	Frequency = 0.07,
	FadeInTime = 0.1
}
local v4 = {
	FillColor = Color3.new(0, 0, 0),
	FillTransparency = 0,
	OutlineTransparency = 1,
	DepthMode = Enum.HighlightDepthMode.Occluded
}
local currentCamera = workspace.CurrentCamera
local secret = module.Assets:WaitForChild("Cutscenes"):WaitForChild("Secret")
local camera = secret:WaitForChild("Camera")
local aura = secret:WaitForChild("Aura")
local music = secret:WaitForChild("Music")
local spawn = workspace:WaitForChild("Server"):WaitForChild("Cutscenes"):WaitForChild("Secret"):WaitForChild("Spawn")
local secret2 = module.Assets:WaitForChild("Animations"):WaitForChild("Cutscenes"):WaitForChild("Secret")
local fighter = secret2:WaitForChild("Fighter")
local camera2 = secret2:WaitForChild("Camera")
local dummy = module.Assets:WaitForChild("Characters"):WaitForChild("Others"):WaitForChild("Dummy")
local flag = false

local function PrepareModel(folder)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Massless = true
		part.CanTouch = false
		part.CanQuery = false
		part.CanCollide = false
		part.CollisionGroup = "Fighters"
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PlaceModel(instance, p, cFrame: CFrame)
	instance:PivotTo(cFrame * p.CFrame:ToObjectSpace(instance:GetPivot()))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function EnsureJoints(clone, humanoid)
	if clone:FindFirstChildWhichIsA("Motor6D", true) or clone:FindFirstChildWhichIsA("AnimationConstraint", true) then
		return
	end

	humanoid:BuildRigFromAttachments()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function LoadTrack(animator, animation)
	local track = animator:LoadAnimation(animation)
	track.Priority = Enum.AnimationPriority.Action4
	track.Looped = false
	return track
end

local function HideInterface()
	local screenGuis = {}
	local playerGui = module.Instance:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return screenGuis
	end

	for _, screenGui in playerGui:GetChildren() do
		if not (screenGui:IsA("ScreenGui") and screenGui.Enabled) then
			continue
		end

		screenGui.Enabled = false
		table.insert(screenGuis, screenGui)
	end

	return screenGuis
end

local function ShowInterface(items)
	for _, item in items do
		if item.Parent then
			item.Enabled = true
		end
	end
end

local function CreateDummy(state)
	local clone = dummy:Clone()
	local humanoid = clone:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not (humanoid and humanoidRootPart and animator) then
		clone:Destroy()
		return
	end

	EnsureJoints(clone, humanoid) -- equivalent call inferred; original call site unknown
	PrepareModel(clone)
	local highlight = Instance.new("Highlight")
	highlight.FillColor = v4.FillColor
	highlight.FillTransparency = v4.FillTransparency
	highlight.OutlineTransparency = v4.OutlineTransparency
	highlight.DepthMode = v4.DepthMode
	highlight.Parent = clone
	humanoidRootPart.Anchored = true
	PlaceModel(clone, humanoidRootPart, spawn.CFrame) -- equivalent call inferred; original call site unknown
	clone.Parent = workspace.Cache
	state.Dummy = clone
	state.DummyTrack = LoadTrack(animator, fighter)
	return true
end

local function CreateCamera(state)
	local clone = camera:Clone()
	local root = clone:FindFirstChild("Root")
	local cam = clone:FindFirstChild("Cam")
	local animationController = clone:FindFirstChildOfClass("AnimationController")
	local animator = animationController and animationController:FindFirstChildOfClass("Animator")

	if not (root and cam and animator) then
		clone:Destroy()
		return
	end

	root.Anchored = true
	PlaceModel(clone, root, spawn.CFrame) -- equivalent call inferred; original call site unknown
	clone.Parent = workspace.Cache
	state.CameraRig = clone
	state.CameraPart = cam
	state.CameraTrack = LoadTrack(animator, camera2)
	return true
end

local function PauseBackgroundMusic(state)
	local musics = module.Services.SoundService:FindFirstChild("Musics")

	if not musics then
		return
	end

	state.PausedMusics = {}

	for _, sound in musics:GetChildren() do
		if not (sound:IsA("Sound") and sound.IsPlaying) then
			continue
		end

		sound:Pause()
		table.insert(state.PausedMusics, sound)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ResumeBackgroundMusic(state)
	if not state.PausedMusics then
		return
	end

	for _, pausedMusic in state.PausedMusics do
		if pausedMusic.Parent then
			pausedMusic:Resume()
		end
	end

	state.PausedMusics = nil
end

local function CreateMusic(state)
	local settings = module.Data and module.Data.Settings
	local musicVolume = settings and settings["Music Volume"] or 100
	local clone = music:Clone()
	clone.Volume = music.Volume * (musicVolume / 100)
	clone.Parent = module.Services.SoundService
	state.Music = clone
	pcall(function()
		local ContentProvider = game:GetService("ContentProvider")
		ContentProvider:PreloadAsync({ clone })
	end)
end

local function UpdateMusic(state)
	if not state.Music or state.MusicStarted then
		return
	end

	local cameraTrack = state.CameraTrack

	if cameraTrack.Length <= 0 or cameraTrack.TimePosition <= 0 then
		return
	end

	state.MusicStarted = true
	state.Music.TimePosition = (music:GetAttribute(v.StartAttribute) or 0) + cameraTrack.TimePosition
	state.Music:Play()
end

local function FadeOutMusic(state)
	local music2 = state.Music

	if not music2 then
		return
	end

	state.Music = nil
	local v5 = module.Services.TweenService:Create(music2, v.FadeOutInfo, {
		Volume = 0
	})
	v5.Completed:Once(function()
		music2:Destroy()
	end)
	v5:Play()
end

local function CreateFlash(state)
	local playerGui = module.Instance:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = v3.Name
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = v3.DisplayOrder
	local frame = Instance.new("Frame")
	frame.Name = "Flash"
	frame.Size = UDim2.fromScale(1, 1)
	frame.Position = UDim2.fromScale(0, 0)
	frame.BackgroundColor3 = v3.Color
	frame.BorderSizePixel = 0
	frame.BackgroundTransparency = 1
	frame.Parent = screenGui
	screenGui.Parent = playerGui
	state.FlashGui = screenGui
	state.Flash = frame
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateFlash(data)
	if not data.Flash or data.Transformed then
		return
	end

	local transformationEndTime = fighter:GetAttribute("TransformationEndTime")

	if type(transformationEndTime) ~= "number" then
		return
	end

	local v5 = (data.DummyTrack.TimePosition - (transformationEndTime - v3.LeadTime)) / v3.LeadTime
	data.Flash.BackgroundTransparency = 1 - math.clamp(v5, 0, 1)
end

local function FadeOutFlash(state)
	if not state.Flash then
		return
	end

	state.Flash.BackgroundTransparency = 0
	module.Services.TweenService:Create(state.Flash, v3.FadeOutInfo, {
		BackgroundTransparency = 1
	}):Play()
end

local function PlayCue(p, p2: string)
	local v5 = module.Sound:PlayEffect(`Cutscene.Secret.{p2}`, {
		MaxVoices = 1
	})
	table.insert(p.Cues, v5)
end

local function UpdateCues(state)
	if state.FinishPlayed or not state.CameraTrack or state.CameraTrack.TimePosition < 12.65 then
		return
	end

	state.FinishPlayed = true
	local v5 = module.Sound:PlayEffect(`{v2.Path}.Finish`, {
		MaxVoices = 1
	})
	table.insert(state.Cues, v5)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CancelCues(state)
	for _, cue in state.Cues do
		cue:cancel()
	end

	table.clear(state.Cues)
end

local function IsTrackEnding(data)
	local isPlaying = data.IsPlaying

	if isPlaying then
		if data.Length > 0 then
			isPlaying = data.TimePosition >= data.Length - 0.1
		else
			isPlaying = false
		end
	end

	return isPlaying
end

local function FreezeTracks(state)
	state.Frozen = true

	for _, v5 in { "CameraTrack", "FighterTrack", "DummyTrack" } do
		local v6 = state[v5]

		if not (v6 and v6.IsPlaying and v6.Length > 0) then
			continue
		end

		v6.TimePosition = v6.Length - 0.001
		v6:AdjustSpeed(0)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopShake(state)
	if not state.Shake then
		return
	end

	state.Shake:Stop()
	state.Shake = nil
end

local function StartTransformation(state)
	if state.TransformationStarted or not state.Dummy then
		return
	end

	state.TransformationStarted = true
	local v5 = module.Sound:PlayEffect(`{v2.Path}.Scream`, {
		MaxVoices = 1
	})
	table.insert(state.Cues, v5)
	local v6 = module.Sound:PlayEffect(`{v2.Path}.Aura`, {
		MaxVoices = 1
	})
	table.insert(state.Cues, v6)
	local upperTorso = state.Dummy:FindFirstChild("UpperTorso")

	if upperTorso then
		for _, child in aura:GetChildren() do
			local clone = child:Clone()
			clone.Parent = upperTorso
		end

		module.Utils.Particles:EnableAll(upperTorso)
		module.Utils.Particles:Emit(upperTorso)
	end

	state.Shake = module.Utils.CameraShake:Play({
		Amplitude = 0.3,
		Frequency = 0.07,
		FadeInTime = 0.1
	})

	if state.Shake then
		state.Shake.Sustain = true
	end
end

local function Transform(state)
	if state.Transformed then
		return
	end

	state.Transformed = true
	StopShake(state) -- equivalent call inferred; original call site unknown
	FadeOutFlash(state)
	local fighter2, v6, v7, _, v8 = module.Utils.Characters.Get({
		Name = state.FighterName,
		Shiny = state.Shiny,
		RemoveHumanoidStates = true
	})

	if not (fighter2 and v6 and v7 and v8) then
		return
	end

	PrepareModel(fighter2)
	v7.Anchored = true
	PlaceModel(fighter2, v7, spawn.CFrame) -- equivalent call inferred; original call site unknown
	fighter2.Parent = workspace.Cache
	state.Fighter = fighter2
	local timePosition = state.DummyTrack.TimePosition
	state.FighterTrack = LoadTrack(v8, fighter)
	state.FighterTrack:Play(0)
	state.FighterTrack.TimePosition = timePosition

	if state.Dummy then
		state.Dummy:Destroy()
		state.Dummy = nil
	end

	local v9 = module.Sound:PlayEffect(`{v2.Path}.Reveal`, {
		MaxVoices = 1
	})
	table.insert(state.Cues, v9)
end

local function Run(state)
	CreateMusic(state)

	if not (CreateDummy(state) and CreateCamera(state)) then
		return
	end

	state.HiddenInterface = HideInterface()
	PauseBackgroundMusic(state)
	CreateFlash(state)
	module.Signal:FireSelf("Player", "FOV", "Disable")
	module.Scripts.Player.Camera.AddCameraTypeModifier("SecretCutscene", Enum.CameraType.Scriptable, 100)
	state.RenderBound = true
	module.Services.RunService:BindToRenderStep("SecretCutsceneCamera", Enum.RenderPriority.Camera.Value + 1, function()
		if not state.Frozen then
			local cameraTrack = state.CameraTrack
			local isPlaying = cameraTrack.IsPlaying

			if isPlaying then
				if cameraTrack.Length > 0 then
					isPlaying = cameraTrack.TimePosition >= cameraTrack.Length - 0.1
				else
					isPlaying = false
				end
			end

			if isPlaying then
				FreezeTracks(state)
			end
		end

		currentCamera.CFrame = state.CameraPart.CFrame
		UpdateFlash(state) -- equivalent call inferred; original call site unknown
		UpdateMusic(state)
		local v6 = state

		if not v6.FinishPlayed then
			if not v6.CameraTrack or v6.CameraTrack.TimePosition < v2.FinishTime then
				return
			end

			v6.FinishPlayed = true
			local v7 = module.Sound:PlayEffect(`{v2.Path}.Finish`, {
				MaxVoices = 1
			})
			table.insert(v6.Cues, v7)
		end
	end)
	state.StartMarkerConnection = state.DummyTrack:GetMarkerReachedSignal("TransformationStart"):Connect(function()
		StartTransformation(state)
	end)
	state.EndMarkerConnection = state.DummyTrack:GetMarkerReachedSignal("TransformationEnd"):Connect(function()
		Transform(state)
	end)
	local v5 = false
	state.StoppedConnection = state.CameraTrack.Stopped:Once(function()
		v5 = true
	end)
	state.DummyTrack:Play(0)
	state.CameraTrack:Play(0)
	local v6 = module.Sound:PlayEffect(`{v2.Path}.Suspense`, {
		MaxVoices = 1
	})
	table.insert(state.Cues, v6)
	currentCamera.CFrame = state.CameraPart.CFrame
	local lastTime = os.clock()

	while not v5 and not state.Frozen and not state.Cancelled and os.clock() - lastTime < 30 do
		task.wait()
	end

	if state.Frozen and not state.Cancelled then
		task.wait(1)
	end
end

local function Cleanup(state)
	for _, v5 in {
		"StartMarkerConnection",
		"EndMarkerConnection",
		"StoppedConnection",
		"DestroyConnection"
	} do
		if not state[v5] then
			continue
		end

		state[v5]:Disconnect()
		state[v5] = nil
	end

	if state.RenderBound then
		state.RenderBound = nil
		module.Services.RunService:UnbindFromRenderStep("SecretCutsceneCamera")
	end

	StopShake(state) -- equivalent call inferred; original call site unknown
	FadeOutMusic(state)
	ResumeBackgroundMusic(state) -- equivalent call inferred; original call site unknown

	if state.Cancelled then
		CancelCues(state) -- equivalent call inferred; original call site unknown
	end

	module.Scripts.Player.Camera.RemoveCameraTypeModifier("SecretCutscene")

	if state.HiddenInterface then
		module.Signal:FireSelf("Player", "FOV", "Enable")

		for _, v5 in state.HiddenInterface do
			if v5.Parent then
				v5.Enabled = true
			end
		end

		state.HiddenInterface = nil
	end

	state.Flash = nil

	for _, v5 in {
		"Dummy",
		"Fighter",
		"CameraRig",
		"FlashGui"
	} do
		if not state[v5] then
			continue
		end

		state[v5]:Destroy()
		state[v5] = nil
	end
end

local SecretCutscene = {}

function SecretCutscene.IsPlaying()
	return flag
end

function SecretCutscene:Play(flag2: boolean?)
	if flag or not module.Shared.Fighters.List[self] then
		return
	end

	flag = true
	local v5 = {
		FighterName = self,
		Shiny = flag2 == true,
		Cancelled = false,
		Cues = {}
	}
	v5.DestroyConnection = script.Destroying:Connect(function()
		v5.Cancelled = true
	end)
	local success, result = pcall(Run, v5)
	Cleanup(v5)
	flag = false

	if not success then
		warn("[SecretCutscene]", result)
	end
end

return SecretCutscene