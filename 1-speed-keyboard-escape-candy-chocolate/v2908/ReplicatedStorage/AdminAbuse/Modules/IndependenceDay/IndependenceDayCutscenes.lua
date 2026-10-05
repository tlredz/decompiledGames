local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local IndependenceDayConfig = require(script.Parent.IndependenceDayConfig)
local localPlayer, playerGui

if RunService:IsClient() then
	localPlayer = Players.LocalPlayer
	playerGui = localPlayer.PlayerGui
else
	playerGui = nil
	localPlayer = nil
end

local currentCamera = workspace.CurrentCamera
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "IndependenceDayCutsceneFade"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999999
screenGui.Parent = playerGui
local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(1, 1)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.ZIndex = 999999
frame.Parent = screenGui
local v = nil

local function fade(FADE_DURATION: number, backgroundTransparency: number)
	if v then
		v:Cancel()
	end

	local tween = TweenService:Create(frame, TweenInfo.new(FADE_DURATION, Enum.EasingStyle.Linear), {
		BackgroundTransparency = backgroundTransparency
	})
	v = tween
	tween:Play()
	return tween
end

local function getLiveMap()
	local model = workspace.AdminAbuse.Map:GetChildren()[1]

	if model and model:IsA("Model") then
		return model
	end

	return nil
end

local function showRig(folder)
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") then
			if descendant.Name ~= "HumanoidRootPart" and descendant.Name ~= "RootPart" then
				descendant.Transparency = 0
			end
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			descendant.Transparency = 0
		end
	end
end

local function hideRig(folder)
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Transparency = 1
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			descendant.Transparency = 1
		end
	end
end

local walkSpeed = 16
local jumpHeight = 7.2

-- equivalent calls inferred from this helper; original call sites unknown
local function freezePlayer()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	walkSpeed = humanoid.WalkSpeed
	jumpHeight = humanoid.JumpHeight
	humanoid.WalkSpeed = 0
	humanoid.JumpHeight = 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unfreezePlayer()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	humanoid.WalkSpeed = walkSpeed
	humanoid.JumpHeight = jumpHeight
end

local v2 = {
	IndependenceDayCutsceneFade = true
}
local enabledsByScreenGui = {}

local function disableOtherGuis()
	local playerGui2 = localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui2 then
		return
	end

	table.clear(enabledsByScreenGui)

	for _, screenGui2 in playerGui2:GetChildren() do
		if screenGui2.Name == "AdminAnnounce" or not screenGui2:IsA("ScreenGui") or v2[screenGui2.Name] then
			continue
		end

		enabledsByScreenGui[screenGui2] = screenGui2.Enabled
		screenGui2.Enabled = false
	end
end

local function restoreOtherGuis()
	local playerGui2 = localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui2 then
		return
	end

	for _, screenGui2 in playerGui2:GetChildren() do
		if not screenGui2:IsA("ScreenGui") or v2[screenGui2.Name] then
			continue
		end

		local enabled = enabledsByScreenGui[screenGui2]

		if enabled ~= nil then
			screenGui2.Enabled = enabled
		end
	end

	table.clear(enabledsByScreenGui)
end

local flag = false

local function bindCamera(humanoidCameraRig)
	local cameraTarget = humanoidCameraRig:FindFirstChild("CameraTarget", true) or humanoidCameraRig:FindFirstChild("Torso") or humanoidCameraRig:FindFirstChildWhichIsA("BasePart")

	if not cameraTarget then
		warn("[IndependenceDayCutscenes] bindCamera: no trackable part in", humanoidCameraRig:GetFullName())
		return
	end

	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.FieldOfView = IndependenceDayConfig.CAMERA_FOV

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getCF()
		if cameraTarget:IsA("Attachment") then
			return cameraTarget.WorldCFrame
		end

		return cameraTarget.CFrame
	end

	local v3 = currentCamera
	local CF = getCF() -- equivalent call inferred; original call site unknown
	v3.CFrame = CF
	RunService:BindToRenderStep("IndependenceDayCutsceneCamera", Enum.RenderPriority.Camera.Value, function()
		local v4 = currentCamera
		local CF2 = getCF() -- equivalent call inferred; original call site unknown
		v4.CFrame = CF2
	end)
	flag = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unbindCamera()
	if flag then
		RunService:UnbindFromRenderStep("IndependenceDayCutsceneCamera")
		flag = false
	end
end

local flag2 = false
local v3 = {}
local connection = nil
local bindableEvent = Instance.new("BindableEvent")
local flag3 = false

local function waitForCleanupDone(CLEANUP_SIGNAL_TIMEOUT_SEC: number)
	if flag3 then
		return
	end

	local v4 = false
	local eventConnection = bindableEvent.Event:Once(function()
		v4 = true
	end)
	local lastTime = os.clock()

	while not v4 and os.clock() - lastTime < CLEANUP_SIGNAL_TIMEOUT_SEC do
		task.wait(0.1)
	end

	eventConnection:Disconnect()
end

local function getAnimator(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid") or instance:FindFirstChildOfClass("AnimationController")

	if not humanoid then
		return nil
	end

	local v4 = humanoid:FindFirstChildOfClass("Animator")

	if not v4 then
		v4 = Instance.new("Animator")
		v4.Parent = humanoid
	end

	return v4
end

local function loadTrack(instance, animationId: string)
	local humanoid = instance:FindFirstChildOfClass("Humanoid") or instance:FindFirstChildOfClass("AnimationController")
	local v4

	if humanoid then
		v4 = humanoid:FindFirstChildOfClass("Animator")

		if not v4 then
			v4 = Instance.new("Animator")
			v4.Parent = humanoid
		end
	else
		v4 = nil
	end

	if not v4 then
		warn("[IndependenceDayCutscenes] No Humanoid/AnimationController found on", instance:GetFullName())
		return nil
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local success, result = pcall(function()
		return v4:LoadAnimation(animation)
	end)
	animation:Destroy()

	if success then
		result.Looped = false
		return result
	end

	warn("[IndependenceDayCutscenes] LoadAnimation failed:", result)
	return nil
end

local function teardownInternal()
	unbindCamera() -- equivalent call inferred; original call site unknown

	if connection then
		connection:Disconnect()
		connection = nil
	end

	for _, v4 in v3 do
		if v4.IsPlaying then
			v4:Stop(0)
		end
	end

	table.clear(v3)
end

local IndependenceDayCutscenes = {
	isActive = function()
		return flag2
	end,
	stop = function()
		if not flag2 then
			return
		end

		teardownInternal()
		currentCamera.CameraType = Enum.CameraType.Custom
		currentCamera.FieldOfView = IndependenceDayConfig.DEFAULT_FOV
		unfreezePlayer() -- equivalent call inferred; original call site unknown
		restoreOtherGuis()
		frame.BackgroundTransparency = 1
		flag2 = false
		local independenceDayCredits = playerGui and playerGui:FindFirstChild("IndependenceDayCredits")

		if independenceDayCredits then
			independenceDayCredits:Destroy()
		end
	end,
	showCredits = function()
		if not playerGui then
			return
		end

		local screenGui2 = Instance.new("ScreenGui")
		screenGui2.Name = "IndependenceDayCredits"
		screenGui2.IgnoreGuiInset = true
		screenGui2.DisplayOrder = 1000000
		screenGui2.Parent = playerGui
		local frame2 = Instance.new("Frame")
		frame2.Size = UDim2.fromScale(1, 1)
		frame2.BackgroundTransparency = 1
		frame2.Parent = screenGui2
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.fromScale(0.8, 0.4)
		textLabel.Position = UDim2.fromScale(0.5, 0.5)
		textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextColor3 = Color3.new(1, 1, 1)
		textLabel.TextScaled = true
		textLabel.Text = [[
Host - Secret_Lokii & LuckyMatg
Producer - Chichine & FoeCakes
Scripter - FoeCakes
Animator - EternityReality
Builder - Nextune_Dev
Music - X3ll3n
]]
		textLabel.TextTransparency = 1
		textLabel.Parent = frame2
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Color = Color3.new()
		uIStroke.Parent = textLabel
		TweenService:Create(
			textLabel,
			TweenInfo.new(IndependenceDayConfig.CREDITS_FADE_SEC, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				TextTransparency = 0
			}
		):Play()
		task.wait(IndependenceDayConfig.CREDITS_DURATION + IndependenceDayConfig.CREDITS_FADE_SEC)
		local tween = TweenService:Create(
			textLabel,
			TweenInfo.new(IndependenceDayConfig.CREDITS_FADE_SEC, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				TextTransparency = 1
			}
		)
		tween:Play()
		tween.Completed:Once(function()
			screenGui2:Destroy()
			tween:Destroy()
		end)
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function finishCutscene(items)
	fade(IndependenceDayConfig.FADE_DURATION, 0).Completed:Connect(function()
		teardownInternal()

		for _, item in items do
			local v4 = item
			pcall(function()
				hideRig(v4)
			end)
		end

		currentCamera.CameraType = Enum.CameraType.Custom
		currentCamera.FieldOfView = IndependenceDayConfig.DEFAULT_FOV
		unfreezePlayer() -- equivalent call inferred; original call site unknown
		restoreOtherGuis()
		fade(IndependenceDayConfig.FADE_DURATION, 1).Completed:Connect(function()
			frame.BackgroundTransparency = 1
			flag2 = false
		end)
	end)
end

function IndependenceDayCutscenes.playOpening(_)
	if flag2 then
		return
	end

	teardownInternal()
	flag2 = true
	local model = workspace.AdminAbuse.Map:GetChildren()[1]

	if not (model and model:IsA("Model")) then
		model = nil
	end

	local scriptables = model and model:FindFirstChild("Scriptables")
	local cutsceneRigs = scriptables and scriptables:FindFirstChild("CutsceneRigs")

	if cutsceneRigs then
		local humanoidCameraRig = cutsceneRigs:FindFirstChild("HumanoidCameraRig")
		local jets = cutsceneRigs:FindFirstChild("Jets")

		if humanoidCameraRig and jets then
			showRig(humanoidCameraRig)
			showRig(jets)
			freezePlayer() -- equivalent call inferred; original call site unknown
			disableOtherGuis()
			bindCamera(humanoidCameraRig)
			local v4

			if humanoidCameraRig:IsA("Model") then
				v4 = loadTrack(humanoidCameraRig, IndependenceDayConfig.ANIM_IDS.Opening.HumanoidCameraRig) or nil
			end

			local v5

			if jets:IsA("Model") then
				v5 = loadTrack(jets, IndependenceDayConfig.ANIM_IDS.Opening.Jets) or nil
			end

			local v6 = { humanoidCameraRig, jets }

			if v5 then
				v5:Play(0, 1, 1)
				table.insert(v3, v5)
			end

			if v4 then
				v4:Play(0, 1, 1)
				table.insert(v3, v4)
				local length = v4.Length
				task.delay(length - 0.5, function()
					finishCutscene(v6) -- equivalent call inferred; original call site unknown
				end)
			else
				warn("[IndependenceDayCutscenes] Opening: no camera track — ending immediately")
				finishCutscene(v6) -- equivalent call inferred; original call site unknown
			end

			for _, part in ipairs(jets:GetChildren()) do
				if not (part:IsA("BasePart") and part ~= jets.PrimaryPart) then
					continue
				end

				local v7 = part:FindFirstChildOfClass("Highlight")

				if not v7 then
					v7 = Instance.new("Highlight")
					v7.Parent = part
					v7.FillColor = Color3.fromHex(part:GetAttribute("HighlightColor")) or Color3.fromHex("#FF0000")
				end

				v7.Enabled = true
			end

			local jet_1 = jets:FindFirstChild("Jet_1")
			local SFX = jet_1 and jet_1:FindFirstChild("SFX")

			if SFX then
				SFX.RollOffMaxDistance = 5000
				SFX.Volume = 5
				SFX:Play()
				task.delay(v4.Length - 3, function()
					local tween = TweenService:Create(SFX, TweenInfo.new(2), {
						Volume = 0
					})
					tween:Play()
					tween.Completed:Once(function(_)
						tween:Destroy()
					end)
				end)
				print("played sfx")
			end

			task.delay(v4.Length - 1, function()
				for _, part in ipairs(jets:GetChildren()) do
					if not (part:IsA("BasePart") and part ~= jets.PrimaryPart) then
						continue
					end

					local highlight = part:FindFirstChildOfClass("Highlight")

					if highlight then
						highlight.Enabled = false
					end
				end

				SFX:Stop()
			end)
		else
			warn("[IndependenceDayCutscenes] Opening: missing HumanoidCameraRig or Jets")
			flag2 = false
		end
	else
		warn("[IndependenceDayCutscenes] CutsceneRigs not found under live map")
		flag2 = false
	end
end

function IndependenceDayCutscenes.playEnding(_)
	if flag2 then
		return
	end

	teardownInternal()
	flag2 = true
	flag3 = false
	freezePlayer() -- equivalent call inferred; original call site unknown
	disableOtherGuis()
	fade(IndependenceDayConfig.FADE_DURATION, 0).Completed:Connect(function()
		unfreezePlayer() -- equivalent call inferred; original call site unknown
		restoreOtherGuis()
		IndependenceDayCutscenes.showCredits()
		waitForCleanupDone(IndependenceDayConfig.CLEANUP_SIGNAL_TIMEOUT_SEC)
		fade(IndependenceDayConfig.FADE_DURATION, 1).Completed:Connect(function()
			frame.BackgroundTransparency = 1
			flag2 = false
		end)
	end)
end

function IndependenceDayCutscenes.notifyCleanupDone()
	flag3 = true
	bindableEvent:Fire()
end

function IndependenceDayCutscenes.getCutsceneRigsFolder()
	local model = workspace.AdminAbuse.Map:GetChildren()[1]

	if not (model and model:IsA("Model")) then
		model = nil
	end

	local scriptables = model and model:FindFirstChild("Scriptables")
	return scriptables and scriptables:FindFirstChild("CutsceneRigs")
end

IndependenceDayCutscenes.showRig = showRig
IndependenceDayCutscenes.hideRig = hideRig
IndependenceDayCutscenes.loadTrack = loadTrack
return IndependenceDayCutscenes