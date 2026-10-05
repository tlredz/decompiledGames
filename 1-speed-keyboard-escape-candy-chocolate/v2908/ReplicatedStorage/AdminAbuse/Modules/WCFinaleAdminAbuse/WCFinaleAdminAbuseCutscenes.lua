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

local WCFinaleAdminAbuseConfig = require(script.Parent.WCFinaleAdminAbuseConfig)
local WCFinaleAdminAbuseAnimationIDs = require(script.Parent.WCFinaleAdminAbuseAnimationIDs)
local FakeAdminMessageUtil = require(ReplicatedStorage.Utilities.FakeAdminMessageUtil)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local flag = false
local count = 0
local v = Janitor.new()
local v2 = nil
local rig2 = nil
local rig3 = nil
local torso = nil
local v5 = {}
local bossRig = nil
local descendants = {}
local highlight = nil
local v6 = false
local renderSteppedConnection = nil
local visibilityByFrame = {}
local v7 = nil
local v8 = nil
local v9 = nil
local v10 = nil
local v11 = nil
local v12 = nil
local v13 = {
	{
		text = "Heard tomorrow was the world cup finale?",
		wait = 1
	},
	{
		text = "LET'S HAVE SOME FUN!"
	}
}
local v14 = {
	{
		text = "Not bad. This was fun!",
		wait = 2
	},
	{
		text = "UNTIL NEXT TIME!"
	}
}
local fieldOfView = nil

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
	local v15 = v5[p]

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
	for k in pairs(v5) do
		local v15 = v5[k]

		if not v15 then
			continue
		end

		for _, v16 in ipairs(v15) do
			v16.Transparency = 1
		end
	end
end

local function setLiveBossRigVisible(enabled: boolean)
	if v6 or not bossRig then
		return
	end

	local transparency = enabled and 0 or 1

	for _, v16 in ipairs(descendants) do
		if v16.Name ~= "HumanoidRootPart" then
			v16.Transparency = transparency
		end
	end

	if highlight then
		highlight.Enabled = enabled
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

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreCameraAndControls()
	stopCameraFollow() -- equivalent call inferred; original call site unknown
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		currentCamera.CameraType = Enum.CameraType.Custom
		currentCamera.FieldOfView = fieldOfView or 70
	end

	fieldOfView = nil
	local character = Players.LocalPlayer and Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
	end
end

local function loadTrack(rig, animId: string)
	local parent = rig:FindFirstChildOfClass("Humanoid") or rig:FindFirstChildOfClass("AnimationController")

	if not parent then
		parent = Instance.new("AnimationController")
		parent.Parent = rig
	end

	local v16 = parent:FindFirstChildOfClass("Animator")

	if not v16 then
		v16 = Instance.new("Animator")
		v16.Parent = parent
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animId
	local success, result = pcall(function()
		return v16:LoadAnimation(animation)
	end)

	if success and result then
		return result
	end

	warn(("[WCFinaleAdminAbuseCutscenes] Failed to load '%s' on %s"):format(animId, rig.Name or "?"))
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

local function playAndHold(track, maid)
	track.Priority = Enum.AnimationPriority.Action
	track.Looped = false
	track:Play(0)
	maid:Add(track.Stopped:Connect(function()
		track:AdjustSpeed(0)
	end))
end

local function connectFadeMarkers(track, maid)
	maid:Add(track:GetMarkerReachedSignal("FadetoBlackStart"):Connect(function()
		if not v10 then
			return
		end

		TweenService:Create(v10, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 0
		}):Play()
	end))
	maid:Add(track:GetMarkerReachedSignal("FadetoBlackEnd"):Connect(function()
		if not v10 then
			return
		end

		TweenService:Create(v10, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 1
		}):Play()
	end))
end

local function playWhistleSFX()
	local adminAbuse = ReplicatedStorage:FindFirstChild("AdminAbuse")
	local wCFinaleAdminAbuse = adminAbuse and adminAbuse:FindFirstChild("WCFinaleAdminAbuse")
	local SFX = wCFinaleAdminAbuse and wCFinaleAdminAbuse:FindFirstChild("SFX")
	local whistle = SFX and SFX:FindFirstChild("Whistle")

	if not (whistle and whistle:IsA("Sound")) then
		warn("[WCFinaleAdminAbuseCutscenes] RS.AdminAbuse.WCFinaleAdminAbuse.SFX.Whistle not found")
		return
	end

	local clone = whistle:Clone()
	clone.Parent = SoundService
	clone:Play()
	clone.Ended:Once(function()
		clone:Destroy()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function connectSfxMarkers(track, maid)
	maid:Add(track:GetMarkerReachedSignal("Sifflet"):Connect(playWhistleSFX))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playMaskMessages(list)
	task.spawn(function()
		for _, v15 in ipairs(list) do
			FakeAdminMessageUtil.show({
				message = v15.text,
				senderName = WCFinaleAdminAbuseConfig.MessageSenderName,
				senderUserId = WCFinaleAdminAbuseConfig.DefaultSenderId,
				preloadedThumb = WCFinaleAdminAbuseConfig.bossIcon
			})

			if v15.wait then
				task.wait(v15.wait)
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
	if v7 and v7.Parent then
		return
	end

	if not playerGui then
		warn("[WCFinaleAdminAbuseCutscenes.buildGui] - PlayerGui is nil. Was this called on the server?")
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "WCFinaleAdminAbuseCutsceneGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui
	v7 = v:Add(screenGui)

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

	v8 = makeBar(Vector2.new(0, 0), UDim2.new(0, 0, 0, 0))
	v9 = makeBar(Vector2.new(0, 1), UDim2.new(0, 0, 1, 0))
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ZIndex = 10
	frame.Parent = screenGui
	v10 = frame
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
	if not v10 then
		return
	end

	local tween = TweenService:Create(v10, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
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
	screenGui.Name = "WCFinaleAdminAbuseCredits"
	screenGui.ResetOnSpawn = false
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

local function runCutscene(p, p2, value: number?, flag2: boolean?, p3)
	if flag then
		return false
	end

	flag = true
	count += 1
	local v15 = count
	local maid = Janitor.new()
	v2 = maid

	local function releaseRun()
		maid:Cleanup()

		if v2 == maid then
			v2 = nil
		end

		return false
	end

	local v16 = false

	local function fireMaskMessagesOnce()
		if v16 or count ~= v15 or not p3 then
			return
		end

		v16 = true
		playMaskMessages(p3) -- equivalent call inferred; original call site unknown
	end

	if v10 then
		v10.BackgroundTransparency = 1
	end

	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
	end

	hideTaggedUI()
	local success, result = pcall(function()
		local currentCamera = workspace.CurrentCamera
		currentCamera.CameraType = Enum.CameraType.Scriptable

		if fieldOfView == nil then
			fieldOfView = currentCamera.FieldOfView
		end

		currentCamera.FieldOfView = 40
		startCameraFollow() -- equivalent call inferred; original call site unknown

		if v8 then
			tweenBarSize(v8, UDim2.new(1, 0, 0.12, 0), 0.5)
		end

		if v9 then
			tweenBarSize(v9, UDim2.new(1, 0, 0.12, 0), 0.5)
		end

		if count ~= v15 then
			return
		end

		for _, v18 in ipairs(p) do
			local v19 = v5[v18]

			if not v19 then
				continue
			end

			for _, v20 in ipairs(v19) do
				v20.Transparency = 0
			end
		end

		if not v6 and bossRig then
			for _, v18 in ipairs(descendants) do
				if v18.Name ~= "HumanoidRootPart" then
					v18.Transparency = 1
				end
			end

			if highlight then
				highlight.Enabled = false
			end
		end

		local v18 = loadAllTracks(p2)

		if count ~= v15 then
			return
		end

		local length = 0

		for _, v19 in ipairs(v18) do
			connectFadeMarkers(v19.track, maid)
			connectSfxMarkers(v19.track, maid) -- equivalent call inferred; original call site unknown
			local markerReachedSignal = v19.track:GetMarkerReachedSignal("StartSpeech") or v19.track:GetMarkerReachedSignal("SpeechStart")
			maid:Add(markerReachedSignal:Connect(fireMaskMessagesOnce))

			if length < v19.length then
				length = v19.length
			end
		end

		for _, v19 in ipairs(v18) do
			playAndHold(v19.track, maid)
		end

		task.delay(1.2, fireMaskMessagesOnce)
		local v19 = math.max(0, length + (value or 0))

		if v19 > 0 then
			task.wait(v19)
		end

		if count ~= v15 then
			return
		end

		if v8 then
			tweenBarSize(v8, UDim2.new(1, 0, 0, 0), 0.5)
		end

		if v9 then
			tweenBarSize(v9, UDim2.new(1, 0, 0, 0), 0.5)
		end

		task.wait(0.5)

		if count ~= v15 then
			return
		end

		if v10 then
			v10.BackgroundTransparency = 1
		end

		for _, v21 in ipairs(p) do
			local v22 = v5[v21]

			if not v22 then
				continue
			end

			for _, v23 in ipairs(v22) do
				v23.Transparency = 1
			end
		end

		if flag2 then
			if not v6 then
				if not bossRig then
					return
				end

				for _, v21 in ipairs(descendants) do
					if v21.Name ~= "HumanoidRootPart" then
						v21.Transparency = 0
					end
				end

				if highlight then
					highlight.Enabled = true
				end
			end
		else
			v6 = true
		end
	end)
	maid:Cleanup()

	if v2 == maid then
		v2 = nil
	end

	if count ~= v15 then
		return false
	end

	if not success then
		warn("[WCFinaleAdminAbuseCutscenes] runCutscene errored:", result)
	end

	restoreCameraAndControls() -- equivalent call inferred; original call site unknown
	restoreTaggedUI() -- equivalent call inferred; original call site unknown
	flag = false
	return success
end

local WCFinaleAdminAbuseCutscenes = {}

function WCFinaleAdminAbuseCutscenes.init(instance)
	local cutscenes = WCFinaleAdminAbuseConfig.Cutscenes
	local scriptables = instance:FindFirstChild("Scriptables")
	local child = scriptables and scriptables:FindFirstChild(cutscenes.RigsFolderName)

	if not child then
		warn(("[WCFinaleAdminAbuseCutscenes] %s not found under mapClone.Scriptables"):format(cutscenes.RigsFolderName))
		return
	end

	local function waitRig(childName: string)
		local child2 = child:WaitForChild(childName, 10)

		if not child2 then
			warn(("[WCFinaleAdminAbuseCutscenes] Rig '%s' not found"):format(childName))
		end

		return child2
	end

	local cameraRigName = cutscenes.CameraRigName
	local child2 = child:WaitForChild(cameraRigName, 10)

	if not child2 then
		warn(("[WCFinaleAdminAbuseCutscenes] Rig '%s' not found"):format(cameraRigName))
	end

	rig2 = child2
	local bossRigName = cutscenes.BossRigName
	local child3 = child:WaitForChild(bossRigName, 10)

	if not child3 then
		warn(("[WCFinaleAdminAbuseCutscenes] Rig '%s' not found"):format(bossRigName))
	end

	rig3 = child3
	v5 = {}
	local v15 = { rig2, rig3 }

	for _, v16 in ipairs(v15) do
		if v16 then
			v5[v16] = getRigParts(v16)
		end
	end

	torso = rig2 and rig2:FindFirstChild("Torso") or nil
	v6 = false
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
		v11 = {
			{
				rig = rig2,
				animId = WCFinaleAdminAbuseAnimationIDs.CutsceneCamRigStart
			},
			{
				rig = rig3,
				animId = WCFinaleAdminAbuseAnimationIDs.CutsceneBossRigStart
			}
		}
		v12 = {
			{
				rig = rig2,
				animId = WCFinaleAdminAbuseAnimationIDs.CutsceneCamRigEnd
			},
			{
				rig = rig3,
				animId = WCFinaleAdminAbuseAnimationIDs.CutsceneBossRigEnd
			}
		}
	end

	hideAllRigs() -- equivalent call inferred; original call site unknown
	buildGui()
end

function WCFinaleAdminAbuseCutscenes.playOpening()
	if not v11 then
		return
	end

	local v15 = { rig2, rig3 }
	local v16 = {}

	for _, v17 in ipairs(v15) do
		if v17 then
			table.insert(v16, v17)
		end
	end

	task.spawn(function()
		runCutscene(v16, v11, -1, true, v13)
	end)
end

function WCFinaleAdminAbuseCutscenes.playEnding()
	if not v12 then
		return
	end

	if not playerGui then
		warn("[WCFinaleAdminAbuseCutscenes.playEnding] - PlayerGui is nil. Was this called on the server?")
		return
	end

	local screenGui = playerGui:FindFirstChild(WCFinaleAdminAbuseConfig.sseChannelName .. "ScoreHUD")

	if screenGui and screenGui:IsA("ScreenGui") then
		screenGui.Enabled = false
	end

	local v15 = { rig2, rig3 }
	local v16 = {}

	for _, v17 in ipairs(v15) do
		if v17 then
			table.insert(v16, v17)
		end
	end

	task.spawn(function()
		if runCutscene(v16, v12, -1, false, v14) then
			fadeToBlack(1)
			showCredits()
		end
	end)
end

function WCFinaleAdminAbuseCutscenes.stopAll()
	count += 1
	flag = false
	restoreTaggedUI() -- equivalent call inferred; original call site unknown
	restoreCameraAndControls() -- equivalent call inferred; original call site unknown
	local wCFinaleAdminAbuseCredits = playerGui and playerGui:FindFirstChild("WCFinaleAdminAbuseCredits")

	if wCFinaleAdminAbuseCredits then
		wCFinaleAdminAbuseCredits:Destroy()
	end

	hideAllRigs() -- equivalent call inferred; original call site unknown

	if v2 then
		v2:Cleanup()
		v2 = nil
	end

	v:Cleanup()
	v7 = nil
	v8 = nil
	v9 = nil
	v10 = nil
	v5 = {}
	descendants = {}
	highlight = nil
	rig2 = nil
	rig3 = nil
	torso = nil
	bossRig = nil
	v11 = nil
	v12 = nil
end

return WCFinaleAdminAbuseCutscenes