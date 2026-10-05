local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local playerGui

if RunService:IsClient() then
	playerGui = Players.LocalPlayer.PlayerGui
else
	playerGui = nil
end

local FakeAdminMessageUtil = require(ReplicatedStorage.Utilities.FakeAdminMessageUtil)
local LuckymatAnimIds = require(script.Parent.LuckymatAnimIds)
local flag = false
local count = 0
local rig = nil
local rig2 = nil
local rig3 = nil
local rig4 = nil
local rig5 = nil
local rig6 = nil
local torso = nil
local v7 = {}
local renderSteppedConnection = nil
local visibilityByFrame = {}
local v8 = nil
local v9 = nil
local v10 = nil
local v11 = nil
local v12 = nil
local v13 = nil
local v14 = nil

local function getRigParts(part)
	local v15 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function processVisible(p, flag2: boolean)
		p.Transparency = 1

		if not flag2 then
			table.insert(v15, p)
		end
	end

	if part:IsA("BasePart") then
		processVisible(part, part.Name == "HumanoidRootPart" or part.Name == "RootPart") -- equivalent call inferred; original call site unknown
	end

	for _, descendant in ipairs(part:GetDescendants()) do
		if descendant:IsA("BasePart") then
			processVisible(descendant, descendant.Name == "HumanoidRootPart" or descendant.Name == "RootPart") -- equivalent call inferred; original call site unknown
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			processVisible(descendant, false) -- equivalent call inferred; original call site unknown
		end
	end

	return v15
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setRigVisible(p, flag2: boolean)
	print(v7)
	local v15 = v7[p]

	if not v15 then
		return
	end

	local transparency = flag2 and 0 or 1

	for _, v17 in ipairs(v15) do
		v17.Transparency = transparency
	end
end

local function setRigsVisible(list, flag2: boolean)
	for _, v15 in ipairs(list) do
		setRigVisible(v15, flag2) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideAllRigs()
	for k in pairs(v7) do
		print(v7)
		local v15 = v7[k]

		if not v15 then
			continue
		end

		for _, v16 in ipairs(v15) do
			v16.Transparency = 1
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getFrontFaceCFrame(instance)
	local v15 = instance.Size.Z * 0.5
	local v16 = instance.Position - instance.CFrame.LookVector * v15
	return CFrame.lookAt(v16, instance.Position)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startCameraFollow()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
	end

	local currentCamera = workspace.CurrentCamera
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		if torso and torso.Parent then
			currentCamera.CFrame = getFrontFaceCFrame(torso)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopCameraFollow()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

local function loadTrack(parent, animationId: string)
	local parent2 = parent:FindFirstChildOfClass("Humanoid") or parent:FindFirstChildOfClass("AnimationController")

	if not parent2 then
		parent2 = Instance.new("AnimationController")
		parent2.Parent = parent
	end

	local v16 = parent2:FindFirstChildOfClass("Animator")

	if not v16 then
		v16 = Instance.new("Animator")
		v16.Parent = parent2
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local success, result = pcall(function()
		return v16:LoadAnimation(animation)
	end)

	if success and result then
		return result
	end

	warn(("[LuckymatCutscenes] Failed to load '%s' on %s"):format(animationId, parent.Name or "?"))
	return nil
end

local function loadAllTracks(list)
	local v15 = {}
	local count2 = #list

	if count2 > 0 then
		for _, v16 in ipairs(list) do
			local spec = v16
			task.spawn(function()
				local track = loadTrack(spec.rig, spec.animId)

				if track then
					local v19 = os.clock() + 2

					while track.Length == 0 and os.clock() < v19 do
						task.wait()
					end

					table.insert(v15, {
						spec = spec,
						track = track,
						length = track.Length
					})
				end

				count2 -= 1
			end)
		end

		while count2 > 0 do
			task.wait()
		end
	end

	return v15
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playAndHold(track)
	track.Priority = Enum.AnimationPriority.Action
	track.Looped = false
	track:Play(0)
	track.Stopped:Connect(function()
		track:AdjustSpeed(0)
	end)
end

local function connectFadeMarkers(track)
	track:GetMarkerReachedSignal("FadetoBlackStart"):Connect(function()
		if not v11 then
			return
		end

		TweenService:Create(v11, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 0
		}):Play()
	end)
	track:GetMarkerReachedSignal("FadetoBlackEnd"):Connect(function()
		if not v11 then
			return
		end

		TweenService:Create(v11, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 1
		}):Play()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function connectDialogueMarker(track)
	track:GetMarkerReachedSignal("Dialogue"):Connect(function()
		FakeAdminMessageUtil.show({
			message = "Finally, next week...",
			senderName = "chichine",
			senderUserId = 18298071
		})
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startBossIdle()
	if not rig2 then
		return
	end

	local v15 = rig2
	print(v7)
	local v16 = v7[v15]

	if v16 then
		for _, v17 in ipairs(v16) do
			v17.Transparency = 0
		end
	end

	local v17 = loadTrack(rig2, LuckymatAnimIds.idle.player)

	if v17 then
		v17.Priority = Enum.AnimationPriority.Idle
		v17.Looped = true
		v17:Play(0.3)
		v14 = v17
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopBossIdle()
	if v14 then
		v14:Stop(0.3)
		v14 = nil
	end

	if rig2 then
		local v15 = rig2
		print(v7)
		local v16 = v7[v15]

		if not v16 then
			return
		end

		for _, v17 in ipairs(v16) do
			v17.Transparency = 1
		end
	end
end

local function tweenBarSize(p, udim: UDim2, duration: number)
	TweenService:Create(p, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
		Size = udim
	}):Play()
end

local function buildGui()
	if v8 and v8.Parent then
		return
	end

	if not playerGui then
		warn("[LuckymatCutscenes.playEnding] - PlayerGui is nil. Was this called on the server? ")
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LuckymatCutsceneGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui
	v8 = screenGui

	local function makeBar(anchorPoint: Vector2, position: UDim2)
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 0, 0)
		frame.Position = position
		frame.AnchorPoint = anchorPoint
		frame.BackgroundColor3 = Color3.new(0, 0, 0)
		frame.BorderSizePixel = 0
		frame.ZIndex = 5
		frame.Parent = screenGui
		return frame
	end

	v9 = makeBar(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0))
	v10 = makeBar(Vector2.new(0, 1), UDim2.new(0, 0, 1, 0))
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ZIndex = 10
	frame.Parent = screenGui
	v11 = frame
end

local function hideTaggedUI()
	local playerGui2 = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")

	if not playerGui2 then
		return
	end

	table.clear(visibilityByFrame)

	for _, frame in CollectionService:GetTagged("UI") do
		if not (frame:IsA("Frame") and frame:IsDescendantOf(playerGui2)) then
			continue
		end

		visibilityByFrame[frame] = frame.Visible
		frame.Visible = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreTaggedUI()
	for k, visible in pairs(visibilityByFrame) do
		if k and k.Parent then
			k.Visible = visible
		end
	end

	table.clear(visibilityByFrame)
end

local function showCredits()
	local playerGui2 = Players.LocalPlayer:WaitForChild("PlayerGui")
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LuckymatCredits"
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 100
	screenGui.Parent = playerGui2
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1
	frame.Parent = screenGui
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(0.8, 0.4)
	textLabel.Position = UDim2.fromScale(0.5, 0.5)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextStrokeColor3 = Color3.new()
	textLabel.TextStrokeTransparency = 0
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextScaled = true
	textLabel.Text = [[
Host - Secret_Lokii & LuckyMatg

Producer - FoeCakes & Chichine

Scripter - FoeCakes & Lyzrinn

Cutscenes - Orthemia

Builder - Nextune_Dev

Music - X3LL3N
]]
	textLabel.TextTransparency = 1
	textLabel.Parent = frame
	TweenService:Create(textLabel, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0
	}):Play()
	task.wait(6.5)
	local tween = TweenService:Create(textLabel, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		TextTransparency = 1
	})
	tween:Play()
	tween.Completed:Once(function()
		screenGui:Destroy()
	end)
end

local function showKillMessage()
	local playerGui2 = Players.LocalPlayer:WaitForChild("PlayerGui")
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LuckymatKillMessage"
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 100
	screenGui.Parent = playerGui2
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(0.7, 0.1)
	textLabel.Position = UDim2.fromScale(0.5, 0.5)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.TextStrokeTransparency = 0
	textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
	textLabel.TextScaled = true
	textLabel.Text = "KILL THE NOOBS TO WIN"
	textLabel.Parent = screenGui
	local uIScale = Instance.new("UIScale")
	uIScale.Scale = 1
	uIScale.Parent = textLabel
	TweenService:Create(uIScale, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		Scale = 1.08
	}):Play()
	task.delay(5, function()
		if screenGui and screenGui.Parent then
			screenGui:Destroy()
		end
	end)
end

local function runCutscene(list, p, value: number?)
	if flag then
		return
	end

	flag = true
	count += 1
	local v15 = count

	if v11 then
		v11.BackgroundTransparency = 1
	end

	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
	end

	hideTaggedUI()
	local currentCamera = workspace.CurrentCamera
	currentCamera.CameraType = Enum.CameraType.Scriptable
	startCameraFollow() -- equivalent call inferred; original call site unknown

	if v9 then
		tweenBarSize(v9, UDim2.new(1, 0, 0.12, 0), 0.5)
	end

	if v10 then
		tweenBarSize(v10, UDim2.new(1, 0, 0.12, 0), 0.5)
	end

	if count ~= v15 then
		return
	end

	for _, v16 in ipairs(list) do
		print(v7)
		local v17 = v7[v16]

		if not v17 then
			continue
		end

		for _, v18 in ipairs(v17) do
			v18.Transparency = 0
		end
	end

	local v16 = loadAllTracks(p)

	if count ~= v15 then
		return
	end

	local length = 0

	for _, v17 in ipairs(v16) do
		connectFadeMarkers(v17.track)

		if v17.spec.rig == rig then
			connectDialogueMarker(v17.track) -- equivalent call inferred; original call site unknown
		end

		if length < v17.length then
			length = v17.length
		end
	end

	for _, v17 in ipairs(v16) do
		playAndHold(v17.track) -- equivalent call inferred; original call site unknown
	end

	local v17 = math.max(0, length + (value or 0))

	if v17 > 0 then
		task.wait(v17)
	end

	if count ~= v15 then
		return
	end

	if v9 then
		tweenBarSize(v9, UDim2.new(1, 0, 0, 0), 0.5)
	end

	if v10 then
		tweenBarSize(v10, UDim2.new(1, 0, 0, 0), 0.5)
	end

	task.wait(0.5)

	if v11 then
		v11.BackgroundTransparency = 1
	end

	for _, v18 in ipairs(list) do
		print(v7)
		local v19 = v7[v18]

		if not v19 then
			continue
		end

		for _, v20 in ipairs(v19) do
			v20.Transparency = 1
		end
	end

	stopCameraFollow() -- equivalent call inferred; original call site unknown
	currentCamera.CameraType = Enum.CameraType.Custom

	if humanoid and humanoid.Parent then
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
	end

	restoreTaggedUI() -- equivalent call inferred; original call site unknown
	flag = false
end

local LuckymatCutscenes = {}

function LuckymatCutscenes.init(instance)
	local scriptables = instance:FindFirstChild("Scriptables")
	local cutsceneObjects = scriptables and scriptables:FindFirstChild("CutsceneObjects")

	if not cutsceneObjects then
		warn("[LuckymatCutscenes] CutsceneObjects not found under mapClone.Scriptables")
		return
	end

	local function waitRig(childName: string)
		local child = cutsceneObjects:WaitForChild(childName, 10)

		if not child then
			warn(("[LuckymatCutscenes] Rig '%s' not found"):format(childName))
		end

		return child
	end

	local humanoidCameraRig = cutsceneObjects:WaitForChild("HumanoidCameraRig", 10)

	if not humanoidCameraRig then
		warn(("[LuckymatCutscenes] Rig '%s' not found"):format("HumanoidCameraRig"))
	end

	rig = humanoidCameraRig
	local luckyMatg = cutsceneObjects:WaitForChild("LuckyMatg", 10)

	if not luckyMatg then
		warn(("[LuckymatCutscenes] Rig '%s' not found"):format("LuckyMatg"))
	end

	rig2 = luckyMatg
	local leftWall = cutsceneObjects:WaitForChild("LeftWall", 10)

	if not leftWall then
		warn(("[LuckymatCutscenes] Rig '%s' not found"):format("LeftWall"))
	end

	rig3 = leftWall
	local rightWall = cutsceneObjects:WaitForChild("RightWall", 10)

	if not rightWall then
		warn(("[LuckymatCutscenes] Rig '%s' not found"):format("RightWall"))
	end

	rig4 = rightWall
	local treadmillAdminAbuse = cutsceneObjects:WaitForChild("TreadmillAdminAbuse", 10)

	if not treadmillAdminAbuse then
		warn(("[LuckymatCutscenes] Rig '%s' not found"):format("TreadmillAdminAbuse"))
	end

	rig5 = treadmillAdminAbuse
	local chichine = cutsceneObjects:WaitForChild("chichine", 10)

	if not chichine then
		warn(("[LuckymatCutscenes] Rig '%s' not found"):format("chichine"))
	end

	rig6 = chichine
	v7 = {}
	local v15 = {
		rig,
		rig2,
		rig3,
		rig4,
		rig5,
		rig6
	}

	for _, v16 in ipairs(v15) do
		if v16 then
			v7[v16] = getRigParts(v16)
		end
	end

	torso = rig and rig:FindFirstChild("Torso") or nil

	if rig2 and rig and rig3 and rig4 and rig5 then
		v12 = {
			{
				rig = rig2,
				animId = LuckymatAnimIds.OPENING.player
			},
			{
				rig = rig,
				animId = LuckymatAnimIds.OPENING.camera
			},
			{
				rig = rig3,
				animId = LuckymatAnimIds.OPENING.doorL
			},
			{
				rig = rig4,
				animId = LuckymatAnimIds.OPENING.doorR
			},
			{
				rig = rig5,
				animId = LuckymatAnimIds.OPENING.treadmill
			}
		}
	end

	if rig2 and rig and rig6 then
		v13 = {
			{
				rig = rig2,
				animId = LuckymatAnimIds.ENDING.player
			},
			{
				rig = rig,
				animId = LuckymatAnimIds.ENDING.camera
			},
			{
				rig = rig6,
				animId = LuckymatAnimIds.ENDING.chichine
			}
		}
	end

	hideAllRigs() -- equivalent call inferred; original call site unknown
	buildGui()
end

function LuckymatCutscenes.playOpening()
	if not v12 then
		return
	end

	local v15 = {
		rig2,
		rig,
		rig3,
		rig4,
		rig5
	}
	local v16 = {}

	for _, v17 in ipairs(v15) do
		if v17 then
			table.insert(v16, v17)
		end
	end

	local v17 = count
	task.spawn(function()
		runCutscene(v16, v12, -1.25)

		if rig5 and rig5.Parent then
			v7[rig5] = nil
			rig5:Destroy()
			rig5 = nil
		end

		if count == v17 + 1 then
			showKillMessage()
			startBossIdle() -- equivalent call inferred; original call site unknown

			if v16._treadmill then
				v16._treadmill:Destroy()
			end
		end
	end)
end

function LuckymatCutscenes.playEnding()
	if not v13 then
		return
	end

	if not playerGui then
		warn("[LuckymatCutscenes.playEnding] - PlayerGui is nil. Was this called on the server? ")
		return
	end

	local v15 = { rig2, rig, rig6 }
	local v16 = {}

	for _, v17 in ipairs(v15) do
		if v17 then
			table.insert(v16, v17)
		end
	end

	local luckymatBossRoomHUD = playerGui:FindFirstChild("LuckymatBossRoomHUD")

	if luckymatBossRoomHUD then
		luckymatBossRoomHUD.Enabled = false
	end

	task.spawn(function()
		local sound = Instance.new("Sound")
		sound.Volume = 1.5
		sound.SoundId = "rbxassetid://79348298352567"
		sound.Parent = SoundService
		task.delay(4, function()
			sound:Play()
			sound.Ended:Once(function(_: string)
				sound:Destroy()
			end)

			if rig2 then
				local torso2 = rig2:FindFirstChild("Torso")
				local humanoid = torso2 and rig2:FindFirstChildOfClass("Humanoid")

				if humanoid then
					humanoid.RequiresNeck = false
					local neck = torso2:FindFirstChild("Neck")

					if neck then
						neck:Destroy()
					end
				end
			end
		end)
		runCutscene(v16, v13, 0)
		showCredits()
	end)
end

function LuckymatCutscenes.stopAll()
	count += 1
	flag = false
	restoreTaggedUI() -- equivalent call inferred; original call site unknown
	stopCameraFollow() -- equivalent call inferred; original call site unknown
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		currentCamera.CameraType = Enum.CameraType.Custom
	end

	if v11 then
		v11.BackgroundTransparency = 1
	end

	if v9 then
		v9.Size = UDim2.new(1, 0, 0, 0)
	end

	if v10 then
		v10.Size = UDim2.new(1, 0, 0, 0)
	end

	hideAllRigs() -- equivalent call inferred; original call site unknown
	stopBossIdle() -- equivalent call inferred; original call site unknown
	local character = Players.LocalPlayer and Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
	end
end

function LuckymatCutscenes.stopBossIdle()
	if v14 then
		v14:Stop(0.3)
		v14 = nil
	end

	if rig2 then
		local v15 = rig2
		print(v7)
		local v16 = v7[v15]

		if not v16 then
			return
		end

		for _, v17 in ipairs(v16) do
			v17.Transparency = 1
		end
	end
end

return LuckymatCutscenes