local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local AreaEggCycle = require(ReplicatedStorage.Shared.Util.AreaEggCycle)
local CameraShaker = require(ReplicatedStorage.Packages.CameraShaker)
local EggState = require(ReplicatedStorage.Client.EggState)
local GUI = require(ReplicatedStorage.Client.GUI)
local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
local LightingController = require(ReplicatedStorage.Controllers.Game.LightingController)
local PlacedEggRenderer = require(ReplicatedStorage.Shared.Eggs.PlacedEggRenderer)
local Player = require(ReplicatedStorage.Shared.Player)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Sakura = require(ReplicatedStorage.Data.Sakura)
local SakuraBloomPolicy = require(ReplicatedStorage.Client.Modules.SakuraBloomPolicy)
local Save = require(ReplicatedStorage.Shared.Save)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local Trove = require(ReplicatedStorage.Packages.Trove)
local game2 = ReplicatedStorage.Controllers:FindFirstChild("Game")
local plots = game2 and game2:FindFirstChild("Plots")
local activeAssetsController = plots and plots:FindFirstChild("ActiveAssetsController")
local result

if activeAssetsController == nil then
	result = nil
else
	local success
	success, result = pcall(require, activeAssetsController)

	if not success then
		result = nil
	end
end

local v = {}
local v2 = {
	Cutscene1 = true,
	Cutscene2 = true,
	ZoneReveal = true
}
local v3 = {
	Cutscene1 = true,
	Tutorial = true,
	Steal = true
}
local v4 = {}
local v5 = {
	Enum.CoreGuiType.Backpack,
	Enum.CoreGuiType.Chat,
	Enum.CoreGuiType.PlayerList,
	Enum.CoreGuiType.Health,
	Enum.CoreGuiType.EmotesMenu
}
local localPlayer = Players.LocalPlayer
local v6 = Trove.new()
local flag = false
local v7 = nil
local maid = Trove.new()
local v8 = nil
local build = Workspace:WaitForChild("World"):WaitForChild("Build")
local screenGui = GUI.TutorialInstructions()
assert(screenGui:IsA("ScreenGui"), "TutorialInstructions must be a ScreenGui")
local isCarrying = false
local v9 = false
local enabled = screenGui.Enabled
local v10 = CameraShaker.new()
local flag2 = false
local v11 = nil
local v12 = nil
local v13 = nil
local v14 = nil

local function resolveMarker()
	local world = Workspace:FindFirstChild("World")
	local areas = world and world:FindFirstChild("Areas")
	local adminAbuseEggSpawn = areas and areas:FindFirstChild("AdminAbuseEggSpawn")

	if adminAbuseEggSpawn == nil or not adminAbuseEggSpawn:IsA("BasePart") then
		return nil
	end

	return adminAbuseEggSpawn
end

local function resolveWall()
	local world = Workspace:FindFirstChild("World")
	local areas = world and world:FindFirstChild("Areas")
	local wallStartVisual = areas and areas:FindFirstChild("WallStartVisual")

	if wallStartVisual == nil or not wallStartVisual:IsA("BasePart") then
		return nil
	end

	return wallStartVisual
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveShot(subject: Vector3, p: number, value: number?)
	local v15 = createVector(-1, 0, 0)
	local unit = (v15.Magnitude <= 0 and createVector(-1, 0, 0) or v15).Unit
	local v16 = math.max(p / 0.8, value or 70) * 0.5 / 0.3152987888789835
	local v17 = (unit * 0.9945218953682733 + createVector(0, 0.104528464, 0)) * v16
	return CFrame.lookAt(subject + v17, subject)
end

local function resolveModelSubject(childName: string)
	local model = Workspace:FindFirstChild(childName)

	if model == nil or not model:IsA("Model") then
		return nil, nil
	end

	local boundingBox, v15 = model:GetBoundingBox()
	return boundingBox.Position, v15.Y
end

local v15 = {}

local function resolveSubject(adminAbuseEggSpawn)
	local dragonEventCutsceneBeat = Workspace:GetAttribute("DragonEventCutsceneBeat")
	local v16

	if type(dragonEventCutsceneBeat) == "string" then
		v16 = v15[dragonEventCutsceneBeat]
	end

	if v16 ~= nil then
		local model = Workspace:FindFirstChild(v16.Name)
		local position, Y

		if not (model == nil or not model:IsA("Model")) then
			local boundingBox, v17 = model:GetBoundingBox()
			position = boundingBox.Position
			Y = v17.Y
		end

		if position ~= nil and Y ~= nil then
			return position + Vector3.new(0, v16.FocusLift or 0, 0), Y, v16.MinFramedHeight
		end
	end

	for _, childName in { "DragonCutscene", "DragonModel" } do
		local model = Workspace:FindFirstChild(childName)
		local position, Y

		if not (model == nil or not model:IsA("Model")) then
			local boundingBox, v17 = model:GetBoundingBox()
			position = boundingBox.Position
			Y = v17.Y
		end

		if position ~= nil and Y ~= nil then
			return position, Y
		end
	end

	return adminAbuseEggSpawn.Position, 70
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreCamera()
	local currentCamera = Workspace.CurrentCamera

	if currentCamera == nil then
		return
	end

	currentCamera.CameraType = Enum.CameraType.Custom
	currentCamera.FieldOfView = 70
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid ~= nil then
		currentCamera.CameraSubject = humanoid
	end
end

local function ensureOverlay()
	local v16 = v11

	if v16 ~= nil and v16.Gui.Parent ~= nil then
		return v16
	end

	local screenGui2 = Instance.new("ScreenGui")
	screenGui2.Name = "DragonCinematic"
	screenGui2.IgnoreGuiInset = true
	screenGui2.ResetOnSpawn = false
	screenGui2.DisplayOrder = 50
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Vignette"
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://104574024062008"
	imageLabel.ImageColor3 = Color3.new(0, 0, 0)
	imageLabel.ImageTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Stretch
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.ZIndex = 1
	imageLabel.Parent = screenGui2

	local function bar(name: string, position: UDim2)
		local frame = Instance.new("Frame")
		frame.Name = name
		frame.BackgroundColor3 = Color3.new(0, 0, 0)
		frame.BorderSizePixel = 0
		frame.Size = UDim2.fromScale(1, 0.11)
		frame.Position = position
		frame.ZIndex = 2
		frame.Parent = screenGui2
		return frame
	end

	local top = bar("Top", UDim2.fromScale(0, -0.11))
	local bottom = bar("Bottom", UDim2.fromScale(0, 1))
	screenGui2.Parent = localPlayer:WaitForChild("PlayerGui")
	local v19 = {
		Gui = screenGui2,
		Top = top,
		Bottom = bottom,
		Vignette = imageLabel
	}
	v11 = v19
	return v19
end

local function setOverlayShown(flag3: boolean)
	local overlay = ensureOverlay()
	local quint = Enum.EasingStyle.Quint
	local v17

	if flag3 then
		v17 = Enum.EasingDirection.Out
	else
		v17 = Enum.EasingDirection.In
	end

	local tweenInfo = TweenInfo.new(0.9, quint, v17)
	local top = overlay.Top
	local position

	if flag3 then
		position = UDim2.fromScale(0, 0)
	else
		position = UDim2.fromScale(0, -0.11)
	end

	TweenService:Create(top, tweenInfo, {
		Position = position
	}):Play()
	local bottom = overlay.Bottom
	local position2

	if flag3 then
		position2 = UDim2.fromScale(0, 0.89)
	else
		position2 = UDim2.fromScale(0, 1)
	end

	TweenService:Create(bottom, tweenInfo, {
		Position = position2
	}):Play()
	TweenService:Create(overlay.Vignette, tweenInfo, {
		ImageTransparency = flag3 and 0.3 or 1
	}):Play()
end

local function hideAllUi()
	if v12 ~= nil then
		return
	end

	local v16 = {}
	v13 = Tabs.Active()

	for _, screenGui2 in localPlayer:WaitForChild("PlayerGui"):GetChildren() do
		if not (screenGui2:IsA("ScreenGui") and screenGui2.Name ~= "DragonCinematic" and screenGui2.Enabled) then
			continue
		end

		v16[screenGui2] = true
		screenGui2.Enabled = false
	end

	v12 = v16
	pcall(function()
		localPlayer.PlayerGui.BottomUI.BottomFrame.Holder.List.Visible = false
	end)
	local coreGuiEnableds = {}

	for _, v17 in v5 do
		coreGuiEnableds[v17] = StarterGui:GetCoreGuiEnabled(v17)
		StarterGui:SetCoreGuiEnabled(v17, false)
	end

	v14 = coreGuiEnableds
end

local function restoreAllUi()
	local v16 = v12
	local v17 = v13
	v12 = nil
	v13 = nil

	if v16 ~= nil then
		for k in v16 do
			if k.Parent ~= nil and k.Name ~= v17 then
				k.Enabled = true
			end
		end
	end

	pcall(function()
		localPlayer.PlayerGui.BottomUI.BottomFrame.Holder.List.Visible = true
	end)
	local v18 = v14
	v14 = nil

	if v18 ~= nil then
		for k, v19 in v18 do
			StarterGui:SetCoreGuiEnabled(k, v19)
		end
	end

	return v17
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideCutsceneUi()
	if v7 == nil then
		v7 = HiddenUIHandler.Acquire()
	end

	hideAllUi()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreCutsceneUi()
	local v16 = restoreAllUi()
	local v17 = v7
	v7 = nil

	if v17 ~= nil then
		v17()
	end

	if v16 ~= nil then
		Tabs.Activate(v16, {
			instant = true
		})
	end
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function easeInOutCubic(p: number)
	if p < 0.5 then
		return p * 4 * p * p
	end

	return 1 - (p * -2 + 2) ^ 3 / 2
end

local function handheldNoise(p: number, p2: number)
	return (math.noise(p * 0.22, p2 * 7.31, 0.5) + math.noise(p * 1.1, p2 * 7.31 + 3.17, 9.5) * 0.22) / 1.22 * 2
end

local function handheldOffset(p: number, p2: number)
	local v16 = (math.noise(p * 0.22, 7.31, 0.5) + math.noise(p * 1.1, 10.48, 9.5) * 0.22) / 1.22 * 2 * 0.038397243543875255 * p2
	local v17 = (math.noise(p * 0.22, 14.62, 0.5) + math.noise(p * 1.1, 17.79, 9.5) * 0.22) / 1.22 * 2 * 0.026179938779914945 * p2
	local v18 = (math.noise(p * 0.22, 21.93, 0.5) + math.noise(p * 1.1, 25.1, 9.5) * 0.22) / 1.22 * 2 * 0.010471975511965976 * p2
	local v19 = Vector3.new(
		(math.noise(p * 0.22, 29.24, 0.5) + math.noise(p * 1.1, 32.41, 9.5) * 0.22) / 1.22 * 2 * 0.25,
		(math.noise(p * 0.22, 36.55, 0.5) + math.noise(p * 1.1, 39.72, 9.5) * 0.22) / 1.22 * 2 * 0.20000000298023224,
		(math.noise(p * 0.22, 43.86, 0.5) + math.noise(p * 1.1, 47.03, 9.5) * 0.22) / 1.22 * 2 * 0.10000000149011612
	) * p2
	return CFrame.new(v19) * CFrame.Angles(0, v16, 0) * CFrame.Angles(v17, 0, v18)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopCutscene()
	if not flag then
		return
	end

	flag = false
	RunService:UnbindFromRenderStep("DragonEventCutsceneCamera")
	setOverlayShown(false)
	restoreCamera() -- equivalent call inferred; original call site unknown
	restoreCutsceneUi() -- equivalent call inferred; original call site unknown
end

local function resolveZoneBounds()
	local world = Workspace:FindFirstChild("World")
	local areas = world and world:FindFirstChild("Areas")
	local cherryBlossom = areas and areas:FindFirstChild("CherryBlossom")
	local bounds = cherryBlossom and cherryBlossom:FindFirstChild("Bounds")

	if bounds == nil or not bounds:IsA("BasePart") then
		return nil
	end

	return bounds
end

local function startZoneRevealCutscene()
	local zoneBounds = resolveZoneBounds()
	local currentCamera = Workspace.CurrentCamera

	if zoneBounds == nil or currentCamera == nil then
		return
	end

	flag = true
	hideCutsceneUi() -- equivalent call inferred; original call site unknown
	setOverlayShown(true)
	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.FieldOfView = 60
	local position = zoneBounds.Position
	local v16 = position + createVector(120, 10, 0)
	local cframe = CFrame.lookAt(position + createVector(-400, 28, 0), v16)
	local cframe2 = CFrame.lookAt(position + createVector(-240, 18, 0), v16)
	local lastTime = os.clock()
	RunService:BindToRenderStep("DragonEventCutsceneCamera", Enum.RenderPriority.Camera.Value + 1, function(p: number)
		if not flag then
			return
		end

		currentCamera.CameraType = Enum.CameraType.Scriptable
		local v17 = os.clock() - lastTime
		local v19 = easeInOutCubic(math.clamp(v17 / 9, 0, 1))
		local v20 = math.clamp(v17 / 1.5, 0, 1)
		currentCamera.CFrame = cframe:Lerp(cframe2, v19) * handheldOffset(v17, v20) * v10:Update(p)
	end)
end

local function startCutscene(dragonEventPhase)
	if flag then
		return
	end

	if dragonEventPhase == "ZoneReveal" then
		startZoneRevealCutscene()
	elseif dragonEventPhase == "Cutscene1" then
		hideCutsceneUi() -- equivalent call inferred; original call site unknown
		local CutscenePart1 = require(script.CutscenePart1)
		local cutscenePart1 = CutscenePart1(v6)
		task.spawn(function()
			cutscenePart1.Run()

			if not flag then
				restoreCutsceneUi() -- equivalent call inferred; original call site unknown
			end
		end)
	elseif dragonEventPhase == "Cutscene2" then
		hideCutsceneUi() -- equivalent call inferred; original call site unknown
		local CutscenePart2 = require(script.CutscenePart2)
		local cutscenePart2 = CutscenePart2(v6)
		task.spawn(function()
			cutscenePart2.Run()

			if not flag then
				restoreCutsceneUi() -- equivalent call inferred; original call site unknown
			end
		end)
	else
		local world = Workspace:FindFirstChild("World")
		local areas = world and world:FindFirstChild("Areas")
		local adminAbuseEggSpawn = areas and areas:FindFirstChild("AdminAbuseEggSpawn")

		if adminAbuseEggSpawn == nil or not adminAbuseEggSpawn:IsA("BasePart") then
			adminAbuseEggSpawn = nil
		end

		local currentCamera = Workspace.CurrentCamera

		if adminAbuseEggSpawn == nil or currentCamera == nil then
			return
		end

		flag = true
		hideCutsceneUi() -- equivalent call inferred; original call site unknown
		setOverlayShown(true)
		currentCamera.CameraType = Enum.CameraType.Scriptable
		currentCamera.FieldOfView = 80
		local position = adminAbuseEggSpawn.Position
		local v16 = createVector(-1, 0, 0)
		local v17 = ((v16.Magnitude <= 0 and createVector(-1, 0, 0) or v16).Unit * 0.9945218953682733 + createVector(
			0,
			0.104528464,
			0
		)) * 138.75727260339056
		local cframe = CFrame.lookAt(position + v17, position)
		currentCamera.CFrame = cframe
		local v18 = cframe
		local fieldOfView = 80
		local lastTime = os.clock()
		local dragonEventCutsceneBeat = Workspace:GetAttribute("DragonEventCutsceneBeat")
		local lastTime2 = os.clock()
		local v19 = nil
		RunService:BindToRenderStep(
			"DragonEventCutsceneCamera",
			Enum.RenderPriority.Camera.Value + 1,
			function(p: number)
				if not flag then
					return
				end

				currentCamera.CameraType = Enum.CameraType.Scriptable
				local dragonEventCutsceneBeat2 = Workspace:GetAttribute("DragonEventCutsceneBeat")

				if dragonEventCutsceneBeat2 ~= dragonEventCutsceneBeat then
					dragonEventCutsceneBeat = dragonEventCutsceneBeat2
					v18 = cframe
					fieldOfView = currentCamera.FieldOfView
					lastTime = os.clock()
					v19 = nil
				end

				local subject, v20, v21 = resolveSubject(adminAbuseEggSpawn)
				local v22 = v19

				if v22 ~= nil then
					subject = v22:Lerp(subject, 1 - math.exp(-p / 0.18))
				end

				v19 = subject
				local shot = resolveShot(subject, v20, v21) -- equivalent call inferred; original call site unknown
				local v23 = (type(dragonEventCutsceneBeat2) ~= "string" or v4[dragonEventCutsceneBeat2] == nil) and 1.6 or v4[dragonEventCutsceneBeat2]
				local v25 = easeInOutCubic(math.clamp((os.clock() - lastTime) / v23, 0, 1))
				cframe = v18:Lerp(shot, v25)
				local v26 = os.clock() - lastTime2
				local v27 = math.clamp(v26 / 1.5, 0, 1)
				currentCamera.CFrame = cframe * handheldOffset(v26, v27) * v10:Update(p)
				currentCamera.FieldOfView = fieldOfView + (35 - fieldOfView) * v25
			end
		)
	end
end

local function preloadCutsceneAssets()
	if flag2 then
		return
	end

	flag2 = true
	task.spawn(function()
		ContentProvider:PreloadAsync({ ReplicatedStorage.CutsceneAssets.DragonEggEventCutscene1 })
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setNightGuiHidden(flag3: boolean)
	local playerGui = localPlayer.PlayerGui
	local resetStartTimer = playerGui and playerGui:FindFirstChild("ResetStartTimer")

	if resetStartTimer ~= nil and resetStartTimer:IsA("SurfaceGui") then
		resetStartTimer.Enabled = not flag3
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyTutorial()
	v8 = nil
	maid:Clean()
end

local function showTutorial()
	if v8 ~= nil then
		return
	end

	local world = Workspace:FindFirstChild("World")
	local areas = world and world:FindFirstChild("Areas")
	local wallStartVisual = areas and areas:FindFirstChild("WallStartVisual")

	if wallStartVisual == nil or not wallStartVisual:IsA("BasePart") then
		wallStartVisual = nil
	end

	if wallStartVisual == nil then
		return
	end

	local clone = script.WallStartVisual:Clone()
	maid:Add(clone)
	clone.Parent = Workspace
	v8 = clone
	local main = clone.SurfaceGui.Main
	local title = main.Title
	local timerLabel = main.TimerLabel
	local v16 = nil
	maid:Add(RunService.Heartbeat:Connect(function()
		local serverTimeNow = Workspace:GetServerTimeNow()
		title.Text = AreaEggCycle.IsNightPhase(serverTimeNow) and "Starting in" or "Time Remaining"
		local secondsUntilPhaseEnd = AreaEggCycle.SecondsUntilPhaseEnd(serverTimeNow)
		local v17 = math.floor(secondsUntilPhaseEnd / 60)
		local v18 = math.floor(secondsUntilPhaseEnd % 60)

		if secondsUntilPhaseEnd < 1 then
			v16 = serverTimeNow
		end

		if v16 then
			timerLabel.Text = "GET READY!!!"

			if serverTimeNow - v16 > 7 then
				v16 = nil
			end
		else
			timerLabel.Text = string.format("%d:%02d", v17, v18)
		end

		setNightGuiHidden(true) -- equivalent call inferred; original call site unknown
	end))
	maid:Add(function()
		setNightGuiHidden(false) -- equivalent call inferred; original call site unknown
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPetsHidden(flag3: boolean)
	local v16 = result

	if v16 == nil then
		return
	end

	pcall(v16.SetAllPetsHidden, flag3)
end

local function isInsideCherryBlossom()
	local zoneBounds = resolveZoneBounds()

	if zoneBounds == nil then
		return false
	end

	local primaryPart = Player.FindPrimaryPart(localPlayer)

	if primaryPart == nil then
		return false
	end

	local pointToObjectSpace = zoneBounds.CFrame:PointToObjectSpace(primaryPart.Position)
	return math.abs(pointToObjectSpace.X) <= zoneBounds.Size.X / 2 and math.abs(pointToObjectSpace.Z) <= zoneBounds.Size.Z / 2
end

local function isInBloom(serverTimeNow: number)
	local isLoaded = Save.IsLoaded()
	local v16

	if isLoaded then
		v16 = Save.Peek()
	end

	if not SakuraBloomPolicy.HasBloomUnlocked(isLoaded, v16) then
		return false
	end

	local attribute = Workspace:GetAttribute(Sakura.Bloom.EndsAtAttribute)
	return typeof(attribute) == "number" and serverTimeNow < attribute and isInsideCherryBlossom()
end

local function onPhaseChanged()
	local dragonEventPhase = Workspace:GetAttribute("DragonEventPhase")

	if dragonEventPhase == nil or not v2[dragonEventPhase] then
		stopCutscene() -- equivalent call inferred; original call site unknown
	else
		startCutscene(dragonEventPhase)
	end

	if dragonEventPhase == "Tutorial" or dragonEventPhase == "Steal" then
		showTutorial()
	else
		destroyTutorial() -- equivalent call inferred; original call site unknown
	end

	pcall(function()
		localPlayer.PlayerGui.DragonEggEventUI.Enabled = dragonEventPhase == "Steal"
		task.spawn(function()
			if dragonEventPhase == "Steal" then
				while localPlayer.PlayerGui.DragonEggEventUI.Enabled do
					task.wait(1)
					local serverTimeNow = Workspace:GetServerTimeNow()

					if isInBloom(serverTimeNow) or AreaEggCycle.IsNightPhase(serverTimeNow) or not AreaEggCycle.IsCloseToReset(AreaEggCycle.SecondsUntilPhaseEnd(serverTimeNow)) then
						continue
					end

					if isCarrying or (v9 or enabled) then
						continue
					end

					localPlayer.PlayerGui.DragonEggEventUI.Enabled = false
				end
			end
		end)
	end)
	local v16

	if dragonEventPhase == nil then
		v16 = false
	else
		v16 = v3[dragonEventPhase] == true
	end

	setNightGuiHidden(v16) -- equivalent call inferred; original call site unknown
	setPetsHidden(v16) -- equivalent call inferred; original call site unknown
	PlacedEggRenderer.SetAllHidden(v16)
end

local function onBeatChanged()
	local dragonEventCutsceneBeat = Workspace:GetAttribute("DragonEventCutsceneBeat")
	local v16

	if type(dragonEventCutsceneBeat) == "string" then
		v16 = v[dragonEventCutsceneBeat]
	end

	if v16 ~= nil and flag then
		v10:ShakeOnce(v16.Magnitude, v16.Roughness, v16.FadeIn, v16.FadeOut)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onMapChanged()
	if build:GetAttribute("DragonEventMap") == true then
		LightingController.SetLayer("DragonEvent", "DragonEvent", 50, 2)
	else
		LightingController.ClearLayer("DragonEvent", 2)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onNestGuideBeamAdded(beam)
	if beam:IsA("Beam") then
		beam.Enabled = beam:GetAttribute("Owner") == localPlayer.UserId
	end
end

local DragonEggEvent = {
	StartEvent = function(_, _: number, _) end,
	StopEvent = function(_)
		stopCutscene() -- equivalent call inferred; original call site unknown
		destroyTutorial() -- equivalent call inferred; original call site unknown
		setNightGuiHidden(false) -- equivalent call inferred; original call site unknown
		setPetsHidden(false) -- equivalent call inferred; original call site unknown
		PlacedEggRenderer.SetAllHidden(false)
		restoreCutsceneUi() -- equivalent call inferred; original call site unknown
	end
}
Workspace:GetAttributeChangedSignal("DragonEventPhase"):Connect(onPhaseChanged)
Workspace:GetAttributeChangedSignal("DragonEventCutsceneBeat"):Connect(onBeatChanged)
build:GetAttributeChangedSignal("DragonEventMap"):Connect(onMapChanged)
CollectionService:GetInstanceAddedSignal("DragonNestGuideBeam"):Connect(onNestGuideBeamAdded)

for _, v16 in CollectionService:GetTagged("DragonNestGuideBeam") do
	onNestGuideBeamAdded(v16) -- equivalent call inferred; original call site unknown
end

EggState.CarryChanged:Connect(function(p)
	isCarrying = p.IsCarrying
end)
Remotes.Treadmill.AssignedBeltShifted.OnClientEvent:Connect(function(p: string?)
	v9 = p ~= nil
end)
screenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
	enabled = screenGui.Enabled
end)
localPlayer.CharacterAdded:Connect(function()
	if not flag then
		restoreCamera() -- equivalent call inferred; original call site unknown
	end

	local dragonEventPhase = Workspace:GetAttribute("DragonEventPhase")
	setNightGuiHidden(dragonEventPhase ~= nil and v3[dragonEventPhase] == true) -- equivalent call inferred; original call site unknown
end)
onPhaseChanged()
onMapChanged() -- equivalent call inferred; original call site unknown

if not flag2 then
	flag2 = true
	task.spawn(function()
		ContentProvider:PreloadAsync({ ReplicatedStorage.CutsceneAssets.DragonEggEventCutscene1 })
	end)
end

return DragonEggEvent