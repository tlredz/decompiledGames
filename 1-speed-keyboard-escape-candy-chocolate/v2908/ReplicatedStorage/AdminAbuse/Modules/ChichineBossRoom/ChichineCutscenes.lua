local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local localPlayer, playerGui

if RunService:IsClient() then
	localPlayer = Players.LocalPlayer
	playerGui = localPlayer.PlayerGui
else
	localPlayer = nil
end

local currentCamera = workspace.CurrentCamera
local v = {
	Opening = {
		chichine_start = "rbxassetid://113856668289045",
		player_start = "rbxassetid://88017832425060",
		HumanoidCameraRig_start = "rbxassetid://106227701693140"
	},
	Ending = {
		chichine_end = "rbxassetid://90430318921493",
		secretlokii_end = "rbxassetid://114579969892164",
		HumanoidCameraRig_end = "rbxassetid://137774859892392"
	}
}
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ChichineCutsceneFade"
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
local v2 = nil

local function fade(backgroundColor: Color3, duration: number, backgroundTransparency: number)
	if v2 then
		v2:Cancel()
	end

	frame.BackgroundColor3 = backgroundColor
	local tween = TweenService:Create(frame, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		BackgroundTransparency = backgroundTransparency
	})
	v2 = tween
	tween:Play()
	return tween
end

local v3 = {
	WhiteFadeIn = { Color3.new(1, 1, 1), 3, 0 },
	WhiteFadeOut = { Color3.new(1, 1, 1), 2, 1 },
	BlackFadeIn = { Color3.new(0, 0, 0), 2, 0 },
	BlackFadeOut = { Color3.new(0, 0, 0), 2, 1 }
}
local screenGui2 = Instance.new("ScreenGui")
screenGui2.Name = "ChichineCutsceneScreenEffect"
screenGui2.IgnoreGuiInset = true
screenGui2.ResetOnSpawn = false
screenGui2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui2.DisplayOrder = 999998
screenGui2.Parent = playerGui
local frame2 = Instance.new("Frame")
frame2.Name = "ScreenEffectFrame"
frame2.Size = UDim2.fromScale(1, 1)
frame2.BackgroundColor3 = Color3.fromRGB(120, 80, 180)
frame2.BackgroundTransparency = 1
frame2.BorderSizePixel = 0
frame2.ZIndex = 999998
frame2.Parent = screenGui2
local v4 = nil
local thread = nil
local v5 = {
	["0.5"] = 0.8,
	["0"] = 0.2
}
local color = Color3.fromRGB(120, 80, 180)
local color2 = Color3.new(0, 0, 0)

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelSEThread()
	if thread then
		task.cancel(thread)
		thread = nil
	end
end

local function seFade(duration: number, backgroundTransparency: number)
	if v4 then
		v4:Cancel()
	end

	local tween = TweenService:Create(frame2, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		BackgroundTransparency = backgroundTransparency
	})
	v4 = tween
	tween:Play()
	return tween
end

local function handleScreenEffectMarker(value: string)
	local match = value:match("FadeToTransparency([%d%.]+)")

	if not match then
		return
	end

	local backgroundTransparency = tonumber(match)

	if not backgroundTransparency then
		return
	end

	local v7 = v5[match] or 1
	cancelSEThread() -- equivalent call inferred; original call site unknown
	frame2.BackgroundColor3 = color
	local v8 = seFade(v7, backgroundTransparency)

	if backgroundTransparency >= 1 then
		thread = task.spawn(function()
			v8.Completed:Wait()
			task.wait(3)
			local tween = TweenService:Create(frame2, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				BackgroundTransparency = 0
			})
			tween:Play()
			tween.Completed:Wait()
			local tween2 = TweenService:Create(frame2, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				BackgroundColor3 = color2
			})
			tween2:Play()
			tween2.Completed:Wait()
			fade(Color3.new(0, 0, 0), 0.4, 0).Completed:Wait()
			task.wait(7)
			fade(Color3.new(0, 0, 0), 1.2, 1).Completed:Wait()
			frame2.BackgroundTransparency = 1
			frame2.BackgroundColor3 = color
			thread = nil
		end)
	end
end

local function playSFX(childName: string)
	local SFX = ReplicatedStorage.AdminAbuse.ChichineBossRoom:WaitForChild("SFX")
	local sound = SFX and SFX:FindFirstChild(childName)

	if sound and sound:IsA("Sound") then
		local clone = sound:Clone()
		clone.Parent = SFX
		clone:Play()
		clone.Ended:Connect(function()
			clone:Destroy()
		end)
	end
end

local function getAnimator(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid") or instance:FindFirstChildOfClass("AnimationController")

	if not humanoid then
		return nil
	end

	local v6 = humanoid:FindFirstChildOfClass("Animator")

	if not v6 then
		v6 = Instance.new("Animator")
		v6.Parent = humanoid
	end

	return v6
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

local v6 = {
	ChichineCutsceneFade = true,
	ChichineCutsceneScreenEffect = true
}
local enabledsByScreenGui = {}

local function disableOtherGuis()
	local playerGui2 = localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui2 then
		return
	end

	table.clear(enabledsByScreenGui)

	for _, screenGui3 in playerGui2:GetChildren() do
		if screenGui3.Name == "AdminAnnounce" or not screenGui3:IsA("ScreenGui") or v6[screenGui3.Name] then
			continue
		end

		enabledsByScreenGui[screenGui3] = screenGui3.Enabled
		screenGui3.Enabled = false
	end
end

local function restoreOtherGuis()
	local playerGui2 = localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui2 then
		return
	end

	for _, screenGui3 in playerGui2:GetChildren() do
		if not screenGui3:IsA("ScreenGui") or v6[screenGui3.Name] then
			continue
		end

		local enabled = enabledsByScreenGui[screenGui3]

		if enabled ~= nil then
			screenGui3.Enabled = enabled
		end
	end

	table.clear(enabledsByScreenGui)
end

local flag = false

local function bindCamera(instance)
	local cameraTarget = instance:FindFirstChild("CameraTarget", true) or instance:FindFirstChild("Torso") or instance:FindFirstChildWhichIsA("BasePart")

	if not cameraTarget then
		warn("[ChichineCutscenes] bindCamera: no trackable part in", instance:GetFullName())
		return
	end

	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.FieldOfView = 35

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getCF()
		if cameraTarget:IsA("Attachment") then
			return cameraTarget.WorldCFrame
		end

		return cameraTarget.CFrame
	end

	local v7 = currentCamera
	local CF = getCF() -- equivalent call inferred; original call site unknown
	v7.CFrame = CF
	RunService:BindToRenderStep("ChichineCutsceneCamera", Enum.RenderPriority.Camera.Value, function()
		local v8 = currentCamera
		local CF2 = getCF() -- equivalent call inferred; original call site unknown
		v8.CFrame = CF2
	end)
	flag = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unbindCamera()
	if flag then
		RunService:UnbindFromRenderStep("ChichineCutsceneCamera")
		flag = false
	end
end

local flag2 = false
local v7 = {}
local connections = {}
local endedConnection = nil
local v8 = nil

local function teardownInternal()
	unbindCamera() -- equivalent call inferred; original call site unknown

	if endedConnection then
		endedConnection:Disconnect()
		endedConnection = nil
	end

	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)

	for _, v9 in v7 do
		if v9.IsPlaying then
			v9:Stop(0)
		end
	end

	table.clear(v7)

	if v8 then
		pcall(function()
			v8:Destroy()
		end)
		v8 = nil
	end

	cancelSEThread() -- equivalent call inferred; original call site unknown
	frame2.BackgroundTransparency = 1
	frame2.BackgroundColor3 = color
end

-- equivalent calls inferred from this helper; original call sites unknown
local function attachSFXMarkers(object)
	table.insert(connections, object:GetMarkerReachedSignal("Sound"):Connect(function(p: string)
		playSFX(p)
	end))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function attachSEMarkers(object)
	table.insert(connections, object:GetMarkerReachedSignal("ScreenEffect"):Connect(function(p: string)
		handleScreenEffectMarker(p)
	end))
end

local function attachFadeMarkers(object)
	for k, v9 in v3 do
		local backgroundColor = v9[1]
		local v14 = v9[2]
		local backgroundTransparency = v9[3]
		table.insert(connections, object:GetMarkerReachedSignal(k):Connect(function()
			fade(backgroundColor, v14, backgroundTransparency)
		end))
	end
end

local function loadTrack(instance, animationId: string)
	local humanoid = instance:FindFirstChildOfClass("Humanoid") or instance:FindFirstChildOfClass("AnimationController")
	local v9

	if humanoid then
		v9 = humanoid:FindFirstChildOfClass("Animator")

		if not v9 then
			v9 = Instance.new("Animator")
			v9.Parent = humanoid
		end
	else
		v9 = nil
	end

	if not v9 then
		return nil
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local success, result = pcall(function()
		return v9:LoadAnimation(animation)
	end)
	animation:Destroy()

	if success then
		result.Looped = false
		return result
	end

	warn("[ChichineCutscenes] LoadAnimation failed:", result)
	return nil
end

local function applyPlayerAppearance(clone)
	local humanoid = clone:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	local success, result = pcall(function()
		return Players:GetHumanoidDescriptionFromUserId(localPlayer.UserId)
	end)

	if success and result then
		pcall(function()
			humanoid:ApplyDescriptionAsync(result)
		end)
	end
end

local function finishCutscene(items, callback)
	fade(Color3.new(0, 0, 0), 0.5, 0).Completed:Connect(function()
		teardownInternal()

		for _, item in items do
			local v9 = item
			pcall(function()
				hideRig(v9)
			end)
		end

		currentCamera.CameraType = Enum.CameraType.Custom
		currentCamera.FieldOfView = 70
		UserInputService.MouseIconEnabled = true
		unfreezePlayer() -- equivalent call inferred; original call site unknown
		restoreOtherGuis()
		fade(Color3.new(0, 0, 0), 0.5, 1).Completed:Connect(function()
			frame.BackgroundTransparency = 1
			flag2 = false

			if callback then
				callback()
			end
		end)
	end)
end

local ChichineCutscenes = {}

function ChichineCutscenes.isActive()
	return flag2
end

function ChichineCutscenes.stop()
	if not flag2 then
		return
	end

	teardownInternal()
	currentCamera.CameraType = Enum.CameraType.Custom
	currentCamera.FieldOfView = 70
	UserInputService.MouseIconEnabled = true
	unfreezePlayer() -- equivalent call inferred; original call site unknown
	restoreOtherGuis()
	frame.BackgroundTransparency = 1
	flag2 = false
end

function ChichineCutscenes.playOpening(instance, callback)
	if flag2 then
		return
	end

	teardownInternal()
	flag2 = true
	local scriptables = instance:FindFirstChild("Scriptables")
	local cutsceneRigs = scriptables and scriptables:FindFirstChild("CutsceneRigs")

	if cutsceneRigs then
		local chichine_start = cutsceneRigs:FindFirstChild("chichine_start")
		local player_start = cutsceneRigs:FindFirstChild("player_start")
		local humanoidCameraRig_start = cutsceneRigs:FindFirstChild("HumanoidCameraRig_start")

		if chichine_start and humanoidCameraRig_start then
			showRig(chichine_start)
			showRig(humanoidCameraRig_start)

			if player_start and player_start:IsA("Model") then
				local clone = player_start:Clone()
				clone.Parent = workspace
				v8 = clone
				showRig(clone)
				task.spawn(function()
					applyPlayerAppearance(clone)

					for _, part in clone:GetDescendants() do
						if not part:IsA("BasePart") then
							continue
						end

						part.CanCollide = false
						part.CanTouch = false
						part.CanQuery = false
					end
				end)
			end

			freezePlayer() -- equivalent call inferred; original call site unknown
			disableOtherGuis()
			bindCamera(humanoidCameraRig_start)
			local v9

			if humanoidCameraRig_start:IsA("Model") then
				v9 = loadTrack(humanoidCameraRig_start, v.Opening.HumanoidCameraRig_start) or nil
			end

			local v10

			if chichine_start:IsA("Model") then
				v10 = loadTrack(chichine_start, v.Opening.chichine_start) or nil
			end

			local v11 = v8 and loadTrack(v8, v.Opening.player_start) or nil

			if v10 then
				attachSFXMarkers(v10) -- equivalent call inferred; original call site unknown
				attachSEMarkers(v10) -- equivalent call inferred; original call site unknown
			end

			if v11 then
				attachSFXMarkers(v11) -- equivalent call inferred; original call site unknown
				attachSEMarkers(v11) -- equivalent call inferred; original call site unknown
			end

			if v9 then
				attachFadeMarkers(v9)
				attachSFXMarkers(v9) -- equivalent call inferred; original call site unknown
			end

			if v10 then
				v10:Play(0, 1, 1)
				table.insert(v7, v10)
			end

			if v11 then
				v11:Play(0, 1, 1)
				table.insert(v7, v11)
			end

			local v12 = { chichine_start, humanoidCameraRig_start }

			if v9 then
				v9:Play(0, 1, 1)
				table.insert(v7, v9)
				endedConnection = v9.Ended:Connect(function()
					if thread then
						task.spawn(function()
							while thread do
								task.wait(0.1)
							end

							finishCutscene(v12, callback)
						end)
					else
						finishCutscene(v12, callback)
					end
				end)
			else
				warn("[ChichineCutscenes] Opening: no camera track — ending immediately")
				finishCutscene(v12, callback)
			end
		else
			warn("[ChichineCutscenes] Opening: missing chichine_start or HumanoidCameraRig_start")
			flag2 = false

			if callback then
				task.spawn(callback)
			end
		end
	else
		warn("[ChichineCutscenes] CutsceneRigs not found under", instance:GetFullName())
		flag2 = false

		if callback then
			task.spawn(callback)
		end
	end
end

function ChichineCutscenes.playEnding(instance, callback)
	if flag2 then
		return
	end

	teardownInternal()
	flag2 = true
	local scriptables = instance:FindFirstChild("Scriptables")
	local cutsceneRigs = scriptables and scriptables:FindFirstChild("CutsceneRigs")

	if cutsceneRigs then
		local chichine_end = cutsceneRigs:FindFirstChild("chichine_end")
		local secretlokii_end = cutsceneRigs:FindFirstChild("secretlokii_end")
		local humanoidCameraRig_end = cutsceneRigs:FindFirstChild("HumanoidCameraRig_end")

		if chichine_end and humanoidCameraRig_end then
			showRig(chichine_end)

			if secretlokii_end then
				showRig(secretlokii_end)
			end

			showRig(humanoidCameraRig_end)
			freezePlayer() -- equivalent call inferred; original call site unknown
			disableOtherGuis()
			bindCamera(humanoidCameraRig_end)
			local v9

			if humanoidCameraRig_end:IsA("Model") then
				v9 = loadTrack(humanoidCameraRig_end, v.Ending.HumanoidCameraRig_end) or nil
			end

			local v10

			if chichine_end:IsA("Model") then
				v10 = loadTrack(chichine_end, v.Ending.chichine_end) or nil
			end

			local v11

			if secretlokii_end and secretlokii_end:IsA("Model") then
				v11 = loadTrack(secretlokii_end, v.Ending.secretlokii_end) or nil
			end

			if v10 then
				attachSFXMarkers(v10) -- equivalent call inferred; original call site unknown
				attachSEMarkers(v10) -- equivalent call inferred; original call site unknown
			end

			if v9 then
				attachFadeMarkers(v9)
				attachSFXMarkers(v9) -- equivalent call inferred; original call site unknown
			end

			if v10 then
				v10:Play(0, 1, 1)
				table.insert(v7, v10)
			end

			if v11 then
				v11:Play(0, 1, 1)
				table.insert(v7, v11)
			end

			local secretlokii_ends = { chichine_end, humanoidCameraRig_end }

			if secretlokii_end then
				table.insert(secretlokii_ends, secretlokii_end)
			end

			if v9 then
				v9:Play(0, 1, 1)
				table.insert(v7, v9)
				endedConnection = v9.Ended:Connect(function()
					if thread then
						task.spawn(function()
							while thread do
								task.wait(0.1)
							end

							finishCutscene(secretlokii_ends, callback)
						end)
					else
						finishCutscene(secretlokii_ends, callback)
					end
				end)
			else
				warn("[ChichineCutscenes] Ending: no camera track — ending immediately")
				finishCutscene(secretlokii_ends, callback)
			end
		else
			warn("[ChichineCutscenes] Ending: missing chichine_end or HumanoidCameraRig_end")
			flag2 = false

			if callback then
				task.spawn(callback)
			end
		end
	else
		warn("[ChichineCutscenes] CutsceneRigs not found for ending")
		flag2 = false

		if callback then
			task.spawn(callback)
		end
	end
end

return ChichineCutscenes