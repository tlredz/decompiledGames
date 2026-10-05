local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerGui

if RunService:IsClient() then
	playerGui = Players.LocalPlayer.PlayerGui
else
	playerGui = nil
end

local MaskedManColorManiaConfig = require(script.Parent.MaskedManColorManiaConfig)
local AnimationIDs = require(script.Parent.AnimationIDs)
local FakeAdminMessageUtil = require(ReplicatedStorage.Utilities.FakeAdminMessageUtil)
local flag = false
local count = 0
local rig2 = nil
local rig3 = nil
local torso = nil
local v3 = {}
local bossRig = nil
local descendants = {}
local highlight = nil
local v4 = false
local renderSteppedConnection = nil
local visibilityByFrame = {}
local v5 = nil
local v6 = nil
local v7 = nil
local v8 = nil
local v9 = nil
local v10 = nil
local v11 = {
	{
		text = "I've been waiting for you!",
		wait = 1
	},
	{
		text = "READY TO PLAY?"
	}
}
local v12 = {
	{
		text = "ARGH. Well played.",
		wait = 1
	},
	{
		text = "But this isn't the last you'll see of me.",
		wait = 0.5
	},
	{
		text = "WE'LL MEET AGAIN!"
	}
}
local fieldOfView = nil

local function getRigParts(part)
	local v13 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function processVisible(p, flag2: boolean)
		p.Transparency = 1

		if not flag2 then
			table.insert(v13, p)
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

	return v13
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setRigVisible(p, flag2: boolean)
	local v13 = v3[p]

	if not v13 then
		return
	end

	local transparency = flag2 and 0 or 1

	for _, v15 in ipairs(v13) do
		v15.Transparency = transparency
	end
end

local function setRigsVisible(list, flag2: boolean)
	for _, v13 in ipairs(list) do
		setRigVisible(v13, flag2) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideAllRigs()
	for k in pairs(v3) do
		local v13 = v3[k]

		if not v13 then
			continue
		end

		for _, v14 in ipairs(v13) do
			v14.Transparency = 1
		end
	end
end

local function setLiveBossRigVisible(enabled: boolean)
	if v4 or not bossRig then
		return
	end

	local transparency = enabled and 0 or 1

	for _, v14 in ipairs(descendants) do
		if v14.Name ~= "HumanoidRootPart" then
			v14.Transparency = transparency
		end
	end

	if highlight then
		highlight.Enabled = enabled
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getFrontFaceCFrame(instance)
	local v13 = instance.Size.Z * 0.5
	local v14 = instance.Position - instance.CFrame.LookVector * v13
	return CFrame.lookAt(v14, instance.Position)
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

local function loadTrack(rig, animId: string)
	local parent = rig:FindFirstChildOfClass("Humanoid") or rig:FindFirstChildOfClass("AnimationController")

	if not parent then
		parent = Instance.new("AnimationController")
		parent.Parent = rig
	end

	local v14 = parent:FindFirstChildOfClass("Animator")

	if not v14 then
		v14 = Instance.new("Animator")
		v14.Parent = parent
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animId
	local success, result = pcall(function()
		return v14:LoadAnimation(animation)
	end)

	if success and result then
		return result
	end

	warn(("[MaskedManColorManiaCutscenes] Failed to load '%s' on %s"):format(animId, rig.Name or "?"))
	return nil
end

local function loadAllTracks(list)
	local v13 = {}
	local count2 = #list

	if count2 > 0 then
		for _, v14 in ipairs(list) do
			local spec = v14
			task.spawn(function()
				local track = loadTrack(spec.rig, spec.animId)

				if track then
					local v17 = os.clock() + 2

					while track.Length == 0 and os.clock() < v17 do
						task.wait()
					end

					table.insert(v13, {
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

	return v13
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
		if not v8 then
			return
		end

		TweenService:Create(v8, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 0
		}):Play()
	end)
	track:GetMarkerReachedSignal("FadetoBlackEnd"):Connect(function()
		if not v8 then
			return
		end

		TweenService:Create(v8, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 1
		}):Play()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playMaskMessages(list)
	task.spawn(function()
		for _, v13 in ipairs(list) do
			FakeAdminMessageUtil.show({
				message = v13.text,
				senderName = MaskedManColorManiaConfig.MessageSenderName,
				senderUserId = MaskedManColorManiaConfig.DefaultSenderId,
				preloadedThumb = MaskedManColorManiaConfig.bossIcon
			})

			if v13.wait then
				task.wait(v13.wait)
			end
		end
	end)
end

local function tweenBarSize(p, udim: UDim2, duration: number)
	TweenService:Create(p, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
		Size = udim
	}):Play()
end

local function buildGui()
	if v5 and v5.Parent then
		return
	end

	if not playerGui then
		warn("[MaskedManColorManiaCutscenes.buildGui] - PlayerGui is nil. Was this called on the server?")
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MaskedManColorManiaCutsceneGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui
	v5 = screenGui

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

	v6 = makeBar(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0))
	v7 = makeBar(Vector2.new(0, 1), UDim2.new(0, 0, 1, 0))
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ZIndex = 10
	frame.Parent = screenGui
	v8 = frame
end

local function hideTaggedUI()
	local playerGui2 = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")

	if not playerGui2 then
		return
	end

	table.clear(visibilityByFrame)

	for _, frame in CollectionService:GetTagged("UI") do
		if not frame:IsA("Frame") or not frame:IsDescendantOf(playerGui2) or frame:FindFirstAncestor("AdminAnnounce") then
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

local function fadeToBlack(duration: number)
	if not v8 then
		return
	end

	local tween = TweenService:Create(v8, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
		BackgroundTransparency = 0
	})
	tween:Play()
	tween.Completed:Wait()
end

local function showCredits()
	if not playerGui then
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MaskedManColorManiaCredits"
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 100
	screenGui.Parent = playerGui
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

Producer - FoeCakes & Chichine & Lyrzrinn

Scripter - FoeCakes

Animator - EternityReality

Builder - FoeCakes & Nextune_Dev

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

local function runCutscene(list, p, value: number?, flag2: boolean?, p2)
	if flag then
		return
	end

	flag = true
	count += 1
	local v13 = count
	local v14 = false

	local function fireMaskMessagesOnce()
		if v14 or count ~= v13 or not p2 then
			return
		end

		v14 = true
		playMaskMessages(p2) -- equivalent call inferred; original call site unknown
	end

	if v8 then
		v8.BackgroundTransparency = 1
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
	fieldOfView = currentCamera.FieldOfView
	currentCamera.FieldOfView = 40
	startCameraFollow() -- equivalent call inferred; original call site unknown

	if v6 then
		tweenBarSize(v6, UDim2.new(1, 0, 0.12, 0), 0.5)
	end

	if v7 then
		tweenBarSize(v7, UDim2.new(1, 0, 0.12, 0), 0.5)
	end

	if count ~= v13 then
		return
	end

	for _, v15 in ipairs(list) do
		local v16 = v3[v15]

		if not v16 then
			continue
		end

		for _, v17 in ipairs(v16) do
			v17.Transparency = 0
		end
	end

	if not v4 and bossRig then
		for _, v15 in ipairs(descendants) do
			if v15.Name ~= "HumanoidRootPart" then
				v15.Transparency = 1
			end
		end

		if highlight then
			highlight.Enabled = false
		end
	end

	local v15 = loadAllTracks(p)

	if count ~= v13 then
		return
	end

	local length = 0

	for _, v16 in ipairs(v15) do
		connectFadeMarkers(v16.track);
		(v16.track:GetMarkerReachedSignal("StartSpeech") or v16.track:GetMarkerReachedSignal("SpeechStart")):Connect(fireMaskMessagesOnce)

		if length < v16.length then
			length = v16.length
		end
	end

	for _, v16 in ipairs(v15) do
		playAndHold(v16.track) -- equivalent call inferred; original call site unknown
	end

	task.delay(1.2, fireMaskMessagesOnce)
	local v16 = math.max(0, length + (value or 0))

	if v16 > 0 then
		task.wait(v16)
	end

	if count ~= v13 then
		return
	end

	if v6 then
		tweenBarSize(v6, UDim2.new(1, 0, 0, 0), 0.5)
	end

	if v7 then
		tweenBarSize(v7, UDim2.new(1, 0, 0, 0), 0.5)
	end

	task.wait(0.5)

	if v8 then
		v8.BackgroundTransparency = 1
	end

	for _, v17 in ipairs(list) do
		local v18 = v3[v17]

		if not v18 then
			continue
		end

		for _, v19 in ipairs(v18) do
			v19.Transparency = 1
		end
	end

	if flag2 then
		if not v4 and bossRig then
			for _, v17 in ipairs(descendants) do
				if v17.Name ~= "HumanoidRootPart" then
					v17.Transparency = 0
				end
			end

			if highlight then
				highlight.Enabled = true
			end
		end
	else
		v4 = true
	end

	stopCameraFollow() -- equivalent call inferred; original call site unknown
	currentCamera.CameraType = Enum.CameraType.Custom
	currentCamera.FieldOfView = fieldOfView or 70

	if humanoid and humanoid.Parent then
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
	end

	restoreTaggedUI() -- equivalent call inferred; original call site unknown
	flag = false
end

local MaskedManColorManiaCutscenes = {}

function MaskedManColorManiaCutscenes.init(instance)
	local cutscenes = MaskedManColorManiaConfig.Cutscenes
	local scriptables = instance:FindFirstChild("Scriptables")
	local child = scriptables and scriptables:FindFirstChild(cutscenes.RigsFolderName)

	if not child then
		warn(("[MaskedManColorManiaCutscenes] %s not found under mapClone.Scriptables"):format(cutscenes.RigsFolderName))
		return
	end

	local function waitRig(childName: string)
		local child2 = child:WaitForChild(childName, 10)

		if not child2 then
			warn(("[MaskedManColorManiaCutscenes] Rig '%s' not found"):format(childName))
		end

		return child2
	end

	local cameraRigName = cutscenes.CameraRigName
	local child2 = child:WaitForChild(cameraRigName, 10)

	if not child2 then
		warn(("[MaskedManColorManiaCutscenes] Rig '%s' not found"):format(cameraRigName))
	end

	rig2 = child2
	local bossRigName = cutscenes.BossRigName
	local child3 = child:WaitForChild(bossRigName, 10)

	if not child3 then
		warn(("[MaskedManColorManiaCutscenes] Rig '%s' not found"):format(bossRigName))
	end

	rig3 = child3
	v3 = {}
	local v13 = { rig2, rig3 }

	for _, v14 in ipairs(v13) do
		if v14 then
			v3[v14] = getRigParts(v14)
		end
	end

	torso = rig2 and rig2:FindFirstChild("Torso") or nil
	v4 = false
	bossRig = scriptables:FindFirstChild("BossRig")

	if bossRig then
		descendants = {}

		for _, descendant in ipairs(bossRig:GetDescendants()) do
			if not (descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture")) then
				continue
			end

			table.insert(descendants, descendant)
		end

		highlight = bossRig:FindFirstChildWhichIsA("Highlight", true)
	else
		descendants = {}
		highlight = nil
	end

	if rig2 and rig3 then
		v9 = {
			{
				rig = rig2,
				animId = AnimationIDs.CutsceneCamRigStart
			},
			{
				rig = rig3,
				animId = AnimationIDs.CutsceneBossRigStart
			}
		}
		v10 = {
			{
				rig = rig2,
				animId = AnimationIDs.CutsceneCamRigEnd
			},
			{
				rig = rig3,
				animId = AnimationIDs.CutsceneBossRigEnd
			}
		}
	end

	hideAllRigs() -- equivalent call inferred; original call site unknown
	buildGui()
end

function MaskedManColorManiaCutscenes.playOpening()
	if not v9 then
		return
	end

	local v13 = { rig2, rig3 }
	local v14 = {}

	for _, v15 in ipairs(v13) do
		if v15 then
			table.insert(v14, v15)
		end
	end

	task.spawn(function()
		runCutscene(v14, v9, -1, true, v11)
	end)
end

function MaskedManColorManiaCutscenes.playEnding()
	if not v10 then
		return
	end

	if not playerGui then
		warn("[MaskedManColorManiaCutscenes.playEnding] - PlayerGui is nil. Was this called on the server?")
		return
	end

	local screenGui = playerGui:FindFirstChild(MaskedManColorManiaConfig.sseChannelName .. "ScoreHUD")

	if screenGui and screenGui:IsA("ScreenGui") then
		screenGui.Enabled = false
	end

	local v13 = { rig2, rig3 }
	local v14 = {}

	for _, v15 in ipairs(v13) do
		if v15 then
			table.insert(v14, v15)
		end
	end

	task.spawn(function()
		runCutscene(v14, v10, -1, false, v12)
		fadeToBlack(1)
		showCredits()
	end)
end

function MaskedManColorManiaCutscenes.stopAll()
	count += 1
	flag = false
	restoreTaggedUI() -- equivalent call inferred; original call site unknown
	stopCameraFollow() -- equivalent call inferred; original call site unknown
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		currentCamera.CameraType = Enum.CameraType.Custom
		currentCamera.FieldOfView = fieldOfView or 70
	end

	if v8 then
		v8.BackgroundTransparency = 1
	end

	if v6 then
		v6.Size = UDim2.new(1, 0, 0, 0)
	end

	if v7 then
		v7.Size = UDim2.new(1, 0, 0, 0)
	end

	local maskedManColorManiaCredits = playerGui and playerGui:FindFirstChild("MaskedManColorManiaCredits")

	if maskedManColorManiaCredits then
		maskedManColorManiaCredits:Destroy()
	end

	hideAllRigs() -- equivalent call inferred; original call site unknown
	local character = Players.LocalPlayer and Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
	end
end

return MaskedManColorManiaCutscenes