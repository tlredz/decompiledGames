local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local remotes = ReplicatedStorage:WaitForChild("AdminAbuse"):WaitForChild("Remotes")
local NextuneBossRoomAnimIds = require(script:WaitForChild("NextuneBossRoomAnimIds"))
local adminAbuseBossFx = remotes:WaitForChild("AdminAbuseBossFx")
local camerashaker = require(ReplicatedStorage.Packages.camerashaker)
local v = nil
local parent = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local onClientEventConnection = nil
local onClientEventConnection2 = nil
local v7 = false
local cFrame = nil
local identity = CFrame.identity
local identity2 = CFrame.identity
local v8 = 0
local v9 = 1
local flag = false
local v10 = nil
local flag2 = false
local clone = nil
local backgroundColor3 = nil
local v11 = nil
local heartbeatConnection = nil
local v12 = nil
local v13 = nil
local v14 = nil
local v15 = nil
local v16 = nil
local v17 = nil
local count = 0
local v18 = 0
local v19 = nil
local v20 = 0
local v21 = 1
local visibilityByFrame = {}

local function hideTaggedUI()
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	local playerGui = localPlayer:FindFirstChild("PlayerGui")

	if not playerGui then
		return
	end

	table.clear(visibilityByFrame)

	for _, frame in CollectionService:GetTagged("UI") do
		if not (frame:IsA("Frame") and frame:IsDescendantOf(playerGui)) then
			continue
		end

		visibilityByFrame[frame] = frame.Visible
		frame.Visible = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreTaggedUI()
	for k, visible in visibilityByFrame do
		if k and k.Parent then
			k.Visible = visible
		end
	end

	table.clear(visibilityByFrame)
end

local function beginCinematic()
	count += 1

	if not v7 then
		hideTaggedUI()
	end

	v7 = true
	return count
end

local function endCinematicIfToken(p: number)
	if p ~= count then
		return false
	end

	count += 1
	v7 = false
	restoreTaggedUI() -- equivalent call inferred; original call site unknown
	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function forceEndCinematic()
	count += 1
	v7 = false
	restoreTaggedUI() -- equivalent call inferred; original call site unknown
end

local NextuneBossRoom = {
	Hidden = true,
	NeedsDuration = false,
	SkipDoorTransition = false,
	RequiresRespawnRefire = false,
	IsAdminAbuse = true,
	PhaseMusic = {
		"rbxassetid://85133275269470",
		"rbxassetid://132744646373593",
		"rbxassetid://115060825765034",
		"rbxassetid://115060825765034"
	},
	SFX = {
		Roar = "rbxassetid://140076040328382",
		Laugh = "rbxassetid://4810729995",
		Glitch = "rbxassetid://135159133360974",
		Death = "rbxassetid://XXXXXXX",
		Explosion = "rbxassetid://121250496298953"
	},
	BossAnimations = {
		IdlePhase1 = NextuneBossRoomAnimIds.IdlePhase1,
		IdlePhase2 = NextuneBossRoomAnimIds.IdlePhase2,
		IdlePhase3 = NextuneBossRoomAnimIds.IdlePhase3,
		PrepareJump = NextuneBossRoomAnimIds.PrepareJump,
		Jump = NextuneBossRoomAnimIds.Jump,
		Fall = NextuneBossRoomAnimIds.Fall,
		Roar = NextuneBossRoomAnimIds.Roar,
		Laugh = NextuneBossRoomAnimIds.Laugh
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function playSfxWithAutoFade(sound)
	local _ = sound.Volume
	sound:Play()
	task.spawn(function()
		local timeLength = sound.TimeLength
		local count2 = 0

		while timeLength <= 0 and count2 < 30 do
			task.wait(0.1)

			if sound and sound.Parent then
				timeLength = sound.TimeLength
				count2 += 1
			else
				return
			end
		end

		if timeLength < 1 then
			return
		end

		local v22 = timeLength - 0.5

		while sound and sound.Parent and sound.IsPlaying do
			if v22 <= sound.TimePosition then
				local v23 = math.max(0.05, timeLength - sound.TimePosition)
				TweenService:Create(sound, TweenInfo.new(v23, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Volume = 0
				}):Play()
				break
			else
				task.wait(0.05)
			end
		end
	end)
end

local function playPhaseMusic(p: number)
	local soundId = NextuneBossRoom.PhaseMusic[p]

	if not soundId or soundId == "rbxassetid://XXXXXXX" then
		return
	end

	if v19 and v19.Parent then
		local v23 = v19
		local tween = TweenService:Create(v23, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Volume = 0
		})
		tween:Play()
		tween.Completed:Once(function()
			v23:Stop()
			v23:Destroy()
			tween:Destroy()
		end)
	end

	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	local sound = Instance.new("Sound")
	sound.Name = "NextuneMusicPhase" .. tostring(p)
	sound.SoundId = soundId
	sound.Looped = true
	sound.Volume = 0
	sound.Parent = localPlayer
	v19 = sound
	v20 = p
	task.spawn(function()
		if not sound.IsLoaded then
			sound.Loaded:Wait()
		end

		if not (sound and sound.Parent) then
			return
		end

		sound:Play()
		local tween = TweenService:Create(sound, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Volume = 0.5
		})
		tween:Play()
		tween.Completed:Once(function()
			tween:Destroy()
		end)
	end)
end

local function stopPhaseMusic()
	if v19 and v19.Parent then
		local v22 = v19
		local tween = TweenService:Create(v22, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Volume = 0
		})
		tween:Play()
		tween.Completed:Once(function()
			v22:Stop()
			v22:Destroy()
			tween:Destroy()
		end)
	end

	v19 = nil
	v20 = 0
end

local function preloadAssets()
	local v22 = {}

	for _, v23 in pairs(NextuneBossRoom.PhaseMusic) do
		if type(v23) ~= "string" or not v23:match("rbxassetid://") or v23:match("XXXXXXX") then
			continue
		end

		table.insert(v22, v23)
	end

	for _, v23 in pairs(NextuneBossRoom.SFX) do
		if type(v23) ~= "string" or not v23:match("rbxassetid://") or v23:match("XXXXXXX") then
			continue
		end

		table.insert(v22, v23)
	end

	for _, bossAnimation in pairs(NextuneBossRoom.BossAnimations) do
		if type(bossAnimation) ~= "string" or not bossAnimation:match("rbxassetid://") or bossAnimation:match("XXXXXXX") then
			continue
		end

		local animation = Instance.new("Animation")
		animation.AnimationId = bossAnimation
		table.insert(v22, animation)
	end

	print("[NextuneBossRoom] Preloading " .. #v22 .. " assets...")
	task.spawn(function()
		local lastTime = os.clock()
		pcall(function()
			ContentProvider:PreloadAsync(v22)
		end)
		print(string.format("[NextuneBossRoom] Preloading finished in %.2fs", os.clock() - lastTime))
	end)
end

local function showCredits()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "NextuneCredits"
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
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextScaled = true
	textLabel.Text = [[
 Brought to you by:
    
Hosts - Secret_Lokii & LuckyMatg
Producer - Chichine
Scripter - FoeCakes
Music - X3LL3N
Builder - NEXTUNE_DEV]]
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
	tween.Completed:Connect(function()
		screenGui:Destroy()
	end)
end

local function showFakeAnnouncement(value: string?)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local notificationFrame = ReplicatedStorage:FindFirstChild("NotificationFrame")

	if not notificationFrame then
		warn("[NextuneBossRoom] FakeAnnounce: NotificationFrame template missing")
		return
	end

	local clone2 = notificationFrame:Clone()
	local avatar = clone2:FindFirstChild("Avatar")

	if avatar and avatar:IsA("ImageLabel") then
		local success, result = pcall(function()
			return Players:GetUserThumbnailAsync(156, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)

		if success and result then
			avatar.Image = result
		end

		avatar.ImageColor3 = Color3.new(0, 0, 0)
	end

	local text = clone2:FindFirstChild("Text")

	if text and text:IsA("TextLabel") then
		text.RichText = true
		text.Text = "<font color=\"rgb(225,20,255)\"><b>???</b></font> : " .. (value or "Everything is going as planned.")
	end

	local v22 = {}
	local v23 = {}

	for _, descendant in clone2:GetDescendants() do
		if descendant:IsA("UIStroke") then
			table.insert(v22, {
				obj = descendant,
				prop = "Transparency"
			})
		elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			table.insert(v22, {
				obj = descendant,
				prop = "TextTransparency"
			})

			if descendant.BackgroundTransparency < 1 then
				table.insert(v22, {
					obj = descendant,
					prop = "BackgroundTransparency"
				})
			end
		elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
			table.insert(v22, {
				obj = descendant,
				prop = "ImageTransparency"
			})

			if descendant.BackgroundTransparency < 1 then
				table.insert(v22, {
					obj = descendant,
					prop = "BackgroundTransparency"
				})
			end
		elseif descendant:IsA("Frame") and descendant.BackgroundTransparency < 1 then
			table.insert(v22, {
				obj = descendant,
				prop = "BackgroundTransparency"
			})
		end

		if descendant:IsA("UIGradient") then
			table.insert(v23, {
				obj = descendant,
				original = descendant.Transparency
			})
		end
	end

	if clone2:IsA("Frame") and clone2.BackgroundTransparency < 1 then
		table.insert(v22, {
			obj = clone2,
			prop = "BackgroundTransparency"
		})
	end

	local v24 = {}

	for i, v25 in ipairs(v22) do
		v24[i] = v25.obj[v25.prop]
		v25.obj[v25.prop] = 1
	end

	local numberSequence = NumberSequence.new(1)

	for _, v25 in ipairs(v23) do
		v25.obj.Transparency = numberSequence
	end

	local adminAnnounce = playerGui:FindFirstChild("AdminAnnounce")
	local mainFrame = adminAnnounce and adminAnnounce:FindFirstChild("MainFrame")
	local screenGui = nil

	if mainFrame then
		clone2.Parent = mainFrame
	else
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "FakeAnnounce"
		screenGui.IgnoreGuiInset = true
		screenGui.DisplayOrder = 110
		screenGui.Parent = playerGui
		clone2.Parent = screenGui
	end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://98797174600699"
	sound.Volume = 0.4
	sound.Parent = playerGui
	playSfxWithAutoFade(sound) -- equivalent call inferred; original call site unknown
	local Debris2 = game:GetService("Debris")
	Debris2:AddItem(sound, 5)
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for i, v25 in ipairs(v22) do
		TweenService:Create(v25.obj, tweenInfo, {
			[v25.prop] = v24[i]
		}):Play()
	end

	for _, v25 in ipairs(v23) do
		v25.obj.Transparency = v25.original
	end

	task.delay(3.5, function()
		local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

		for _, v25 in ipairs(v22) do
			TweenService:Create(v25.obj, tweenInfo2, {
				[v25.prop] = 1
			}):Play()
		end

		for _, v25 in ipairs(v23) do
			v25.obj.Transparency = numberSequence
		end

		task.delay(0.5, function()
			if clone2 and clone2.Parent then
				clone2:Destroy()
			end

			if screenGui and screenGui.Parent then
				screenGui:Destroy()
			end
		end)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getBossRig()
	local adminAbuse = workspace:FindFirstChild("AdminAbuse")
	local map = adminAbuse and adminAbuse:FindFirstChild("Map")
	return map and map:FindFirstChild("BossRig", true)
end

local function setVfxEnabled(enabled: boolean)
	local bossRig = getBossRig() -- equivalent call inferred; original call site unknown
	local tornadoVFX = bossRig and bossRig:FindFirstChild("TornadoVFX")
	local tornadoVFXMain = tornadoVFX and tornadoVFX:FindFirstChild("Main")

	if not tornadoVFXMain then
		return
	end

	for _, emitter in tornadoVFXMain:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end

local function refreshBar()
	local v22 = parent
	local v23 = v3
	local v24 = v5

	if not v24 or not v22 or v9 <= 0 then
		return
	end

	local v25 = math.clamp(v24.Value, 0, v9)
	v22.Size = UDim2.new(math.clamp(v25 / v9, 0, 1), 0, 1, 0)

	if v23 then
		if v9 >= 1000000 then
			v23.Text = string.format("%.3fM / %.1fM", v25 / 1000000, v9 / 1000000)
		else
			v23.Text = string.format("%d / %d", math.floor(v25 + 0.5), (math.floor(v9 + 0.5)))
		end
	end

	if v16 then
		local v26 = v25 / v9 >= 0.999
		local v27 = v16
		local backgroundColor

		if v26 then
			backgroundColor = Color3.fromRGB(255, 30, 80)
		else
			backgroundColor = Color3.fromRGB(95, 95, 105)
		end

		v27.BackgroundColor3 = backgroundColor
		v16.BackgroundTransparency = v26 and 0.05 or 0.35

		if v17 then
			local v29 = v17
			local textColor

			if v26 then
				textColor = Color3.fromRGB(255, 200, 210)
			else
				textColor = Color3.fromRGB(190, 190, 200)
			end

			v29.TextColor3 = textColor
		end
	end
end

local function applyPhaseMarkerStyle(p: number)
	local v22 = v12

	if v22 then
		local v23 = p >= 2
		local backgroundColor

		if v23 then
			backgroundColor = Color3.fromRGB(185, 110, 255)
		else
			backgroundColor = Color3.fromRGB(95, 95, 105)
		end

		v22.BackgroundColor3 = backgroundColor
		v22.BackgroundTransparency = v23 and 0.05 or 0.35
	end

	local v23 = v14

	if v23 then
		local textColor

		if p >= 2 then
			textColor = Color3.fromRGB(235, 205, 255)
		else
			textColor = Color3.fromRGB(190, 190, 200)
		end

		v23.TextColor3 = textColor
	end

	local v24 = v13

	if v24 then
		local v25 = p >= 3
		local backgroundColor

		if v25 then
			backgroundColor = Color3.fromRGB(220, 25, 255)
		else
			backgroundColor = Color3.fromRGB(95, 95, 105)
		end

		v24.BackgroundColor3 = backgroundColor
		v24.BackgroundTransparency = v25 and 0.05 or 0.35
	end

	local v25 = v15

	if v25 then
		local textColor

		if p >= 3 then
			textColor = Color3.fromRGB(235, 205, 255)
		else
			textColor = Color3.fromRGB(190, 190, 200)
		end

		v25.TextColor3 = textColor
	end

	local v26 = v16

	if v26 then
		v26.BackgroundColor3 = Color3.fromRGB(95, 95, 105)
		v26.BackgroundTransparency = 0.35
	end

	local v27 = v17

	if v27 then
		v27.TextColor3 = Color3.fromRGB(190, 190, 200)
	end
end

local function applyPhase3BossBarStyle()
	if not parent then
		return
	end

	local tween = TweenService:Create(parent, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundColor3 = Color3.fromRGB(155, 0, 190)
	})
	tween:Play()
	tween.Completed:Once(function()
		tween:Destroy()
	end)

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if v11 then
		v11:Destroy()
	end

	local uIGradient = Instance.new("UIGradient")
	uIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(235, 30, 255)),
		ColorSequenceKeypoint.new(0.32, Color3.fromRGB(20, 8, 30)),
		ColorSequenceKeypoint.new(0.68, Color3.fromRGB(195, 16, 240)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 0, 12))
	})
	uIGradient.Rotation = 0
	uIGradient.Parent = parent
	v11 = uIGradient
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v22 = v11

		if v22 and v22.Parent then
			v22.Offset = Vector2.new(math.sin(os.clock() * 0.85) * 0.65, 0)
		elseif heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end)
end

local function onBossHpSync(value, value2, value3)
	if type(value) ~= "number" then
		return
	end

	local v22

	if type(value2) == "number" then
		v22 = value2
	else
		v22 = value
	end

	if v22 <= 0 or type(value3) == "number" and value3 < v8 then
		return
	end

	if type(value3) == "number" then
		v8 = value3
	end

	v9 = v22

	if v6 then
		v6:Cancel()
		v6 = nil
	end

	local v23 = math.clamp(value, 0, v22)

	if flag then
		local v24 = v5

		if not v24 then
			return
		end

		local tween = TweenService:Create(v24, TweenInfo.new(0.38, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Value = v23
		})
		v6 = tween
		tween:Play()

		if v21 == 3 and value / value2 <= 0.1 then
			v21 = 4
			playPhaseMusic(4)
		end
	else
		flag = true

		if v5 then
			v5.Value = v23
		end

		refreshBar()
	end
end

local function destroyUi()
	stopPhaseMusic()

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if v11 then
		v11:Destroy()
		v11 = nil
	end

	if clone then
		clone:Destroy()
		clone = nil
	end

	if v6 then
		v6:Cancel()
		v6 = nil
	end

	if onClientEventConnection then
		onClientEventConnection:Disconnect()
		onClientEventConnection = nil
	end

	if v then
		v:Destroy()
		v = nil
	end

	v12 = nil
	v13 = nil
	v14 = nil
	v15 = nil
	v16 = nil
	v17 = nil
	parent = nil
	v3 = nil
	v4 = nil
	v5 = nil
	v8 = 0
	v9 = 1
	flag = false
	v21 = 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function teardownCutsceneListener()
	if onClientEventConnection2 then
		onClientEventConnection2:Disconnect()
		onClientEventConnection2 = nil
	end

	if v10 then
		v10:Stop()
		v10 = nil
	end

	forceEndCinematic() -- equivalent call inferred; original call site unknown
	v18 = 0
	cFrame = nil
	identity = CFrame.identity
	identity2 = CFrame.identity
	RunService:UnbindFromRenderStep("NextuneCinematicLock")
end

local function buildUi()
	destroyUi()
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "NextuneBossHud"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 80
	screenGui.Parent = playerGui
	v = screenGui
	local pulseBoss = ReplicatedStorage:FindFirstChild("PulseBoss")

	if pulseBoss and pulseBoss:IsA("ScreenGui") then
		clone = pulseBoss:Clone()
		clone.Parent = playerGui
		local frame = clone:FindFirstChild("Frame")

		if frame then
			backgroundColor3 = frame.BackgroundColor3
			task.spawn(function()
				while clone and clone.Parent do
					frame.BackgroundTransparency = (math.sin(os.clock() * 3) + 1) / 2 * 0.3 + 0.6
					task.wait()
				end
			end)
		end
	end

	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.BackgroundTransparency = 1
	frame.Position = UDim2.new(0.5, 0, 0, 45)
	frame.Size = UDim2.new(0.6, 0, 0.08, 0)
	frame.Parent = screenGui
	local frame2 = Instance.new("Frame")
	frame2.Name = "ProgressBg"
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	frame2.BackgroundTransparency = 0.4
	frame2.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame2.Size = UDim2.new(1, 0, 0.65, 0)
	frame2.Parent = frame
	local uICorner = Instance.new("UICorner", frame2)
	uICorner.CornerRadius = UDim.new(0.5, 0)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.AnchorPoint = Vector2.new(0, 0.5)
	imageLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	imageLabel.BorderSizePixel = 0
	imageLabel.Position = UDim2.new(0, -65, 0.5, 0)
	imageLabel.Size = UDim2.new(0, 60, 0, 60)
	imageLabel.Image = "rbxthumb://type=AvatarHeadShot&id=563212204&w=150&h=150"
	imageLabel.Parent = frame2
	local uICorner_2 = Instance.new("UICorner", imageLabel)
	uICorner_2.CornerRadius = UDim.new(1, 0)
	local uIStroke = Instance.new("UIStroke", imageLabel)
	uIStroke.Color = Color3.fromRGB(148, 8, 8)
	uIStroke.Thickness = 2
	local frame3 = Instance.new("Frame", frame2)
	frame3.Name = "Fill"
	frame3.BackgroundColor3 = Color3.fromRGB(148, 8, 8)
	frame3.Size = UDim2.new(0, 0, 1, 0)
	local uICorner_3 = Instance.new("UICorner", frame3)
	uICorner_3.CornerRadius = UDim.new(0.5, 0)
	parent = frame3
	local frame4 = Instance.new("Frame")
	frame4.Name = "Phase2Marker"
	frame4.AnchorPoint = Vector2.new(0.5, 0.5)
	frame4.Position = UDim2.new(0.33, 0, 0.5, 0)
	frame4.Size = UDim2.new(0, 6, 1, 0)
	frame4.BorderSizePixel = 0
	frame4.ZIndex = frame3.ZIndex + 2
	frame4.Parent = frame2
	local uIStroke_2 = Instance.new("UIStroke", frame4)
	uIStroke_2.Thickness = 1
	v12 = frame4
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Phase2Text"
	textLabel.AnchorPoint = Vector2.new(0.5, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Position = UDim2.new(0.33, 0, 0.5, 16)
	textLabel.Size = UDim2.new(0, 64, 0, 22)
	textLabel.ZIndex = frame3.ZIndex + 3
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Text = "P2"
	textLabel.TextScaled = true
	textLabel.TextStrokeTransparency = 0.55
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.TextColor3 = Color3.fromRGB(190, 190, 200)
	textLabel.Parent = frame2
	v14 = textLabel
	local frame5 = Instance.new("Frame")
	frame5.Name = "Phase3Marker"
	frame5.AnchorPoint = Vector2.new(0.5, 0.5)
	frame5.Position = UDim2.new(0.67, 0, 0.5, 0)
	frame5.Size = UDim2.new(0, 6, 1, 0)
	frame5.BorderSizePixel = 0
	frame5.ZIndex = frame3.ZIndex + 2
	frame5.Parent = frame2
	local uIStroke_3 = Instance.new("UIStroke", frame5)
	uIStroke_3.Thickness = 1
	v13 = frame5
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "Phase3Text"
	textLabel2.AnchorPoint = Vector2.new(0.5, 0)
	textLabel2.BackgroundTransparency = 1
	textLabel2.Position = UDim2.new(0.67, 0, 0.5, 16)
	textLabel2.Size = UDim2.new(0, 64, 0, 22)
	textLabel2.ZIndex = frame3.ZIndex + 3
	textLabel2.Font = Enum.Font.GothamBold
	textLabel2.Text = "P3"
	textLabel2.TextScaled = true
	textLabel2.TextStrokeTransparency = 0.55
	textLabel2.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel2.TextColor3 = Color3.fromRGB(190, 190, 200)
	textLabel2.Parent = frame2
	v15 = textLabel2
	local frame6 = Instance.new("Frame")
	frame6.Name = "EndMarker"
	frame6.AnchorPoint = Vector2.new(0.5, 0.5)
	frame6.Position = UDim2.new(1, 0, 0.5, 0)
	frame6.Size = UDim2.new(0, 6, 1, 0)
	frame6.BorderSizePixel = 0
	frame6.ZIndex = frame3.ZIndex + 2
	frame6.Parent = frame2
	local uIStroke_4 = Instance.new("UIStroke", frame6)
	uIStroke_4.Thickness = 1
	v16 = frame6
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.Name = "EndText"
	textLabel3.AnchorPoint = Vector2.new(0.5, 0)
	textLabel3.BackgroundTransparency = 1
	textLabel3.Position = UDim2.new(1, 0, 0.5, 16)
	textLabel3.Size = UDim2.new(0, 64, 0, 22)
	textLabel3.ZIndex = frame3.ZIndex + 3
	textLabel3.Font = Enum.Font.GothamBold
	textLabel3.Text = "???"
	textLabel3.TextScaled = true
	textLabel3.TextStrokeTransparency = 0.55
	textLabel3.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel3.TextColor3 = Color3.fromRGB(190, 190, 200)
	textLabel3.Parent = frame2
	v17 = textLabel3
	applyPhaseMarkerStyle(1)
	local textLabel4 = Instance.new("TextLabel", frame2)
	textLabel4.BackgroundTransparency = 1
	textLabel4.Size = UDim2.new(0.45, 0, 1, 0)
	textLabel4.Font = Enum.Font.GothamBold
	textLabel4.Text = ("Nextune"):upper() .. " BOSS EVENT"
	textLabel4.TextColor3 = Color3.new(1, 1, 1)
	textLabel4.TextScaled = true
	textLabel4.TextXAlignment = Enum.TextXAlignment.Left
	local uIPadding = Instance.new("UIPadding", textLabel4)
	uIPadding.PaddingLeft = UDim.new(0.04, 0)
	local textLabel5 = Instance.new("TextLabel", frame2)
	textLabel5.AnchorPoint = Vector2.new(1, 0)
	textLabel5.BackgroundTransparency = 1
	textLabel5.Position = UDim2.new(1, 0, 0, 0)
	textLabel5.Size = UDim2.new(0.4, 0, 1, 0)
	textLabel5.Font = Enum.Font.GothamBold
	textLabel5.Text = "0 / 0"
	textLabel5.TextColor3 = Color3.new(1, 1, 1)
	textLabel5.TextScaled = true
	textLabel5.TextXAlignment = Enum.TextXAlignment.Right
	local uIPadding_2 = Instance.new("UIPadding", textLabel5)
	uIPadding_2.PaddingRight = UDim.new(0.04, 0)
	v3 = textLabel5
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	numberValue.Changed:Connect(refreshBar)
	v5 = numberValue
	local textLabel6 = Instance.new("TextLabel", screenGui)
	textLabel6.Name = "PhaseLabel"
	textLabel6.AnchorPoint = Vector2.new(0.5, 0)
	textLabel6.BackgroundTransparency = 1
	textLabel6.Position = UDim2.new(0.5, 0, 0.08, 52)
	textLabel6.Size = UDim2.new(0.12, 0, 0, 20)
	textLabel6.Font = Enum.Font.GothamBold
	textLabel6.Text = "PHASE 1"
	textLabel6.TextColor3 = Color3.new(1, 1, 1)
	textLabel6.TextScaled = true
	textLabel6.TextStrokeTransparency = 0.5
	textLabel6.TextStrokeColor3 = Color3.new(0, 0, 0)
	v4 = textLabel6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getClientDebrisFolder()
	local adminAbuse = workspace:FindFirstChild("AdminAbuse")
	local map = adminAbuse and adminAbuse:FindFirstChild("Map")
	return map and map:FindFirstChild("Debris", true) or workspace
end

local function setupCutsceneListener()
	teardownCutsceneListener() -- equivalent call inferred; original call site unknown
	onClientEventConnection2 = adminAbuseBossFx.OnClientEvent:Connect(function(value, data)
		if type(value) ~= "string" then
			warn("[NextuneBossRoom] fxRemote: expected string cmd, got:", (type(value)))
			return
		end

		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			return
		end

		if value == "SetCamera" then
			if type(data) ~= "table" then
				warn("[NextuneBossRoom] SetCamera: expected table data, got:", (type(data)))
				return
			end

			local type2 = data.type

			if type2 == "Reset" then
				forceEndCinematic() -- equivalent call inferred; original call site unknown
				v18 = 0
				currentCamera.CameraType = Enum.CameraType.Custom
				local character = Players.LocalPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					currentCamera.CameraSubject = humanoid
				end
			else
				local cf = data.cf

				if typeof(cf) ~= "CFrame" then
					warn("[NextuneBossRoom] SetCamera: cf is not a CFrame, got:", (typeof(cf)))
					return
				end

				count += 1

				if not v7 then
					hideTaggedUI()
				end

				v7 = true
				v18 = 0
				currentCamera.CameraSubject = nil
				currentCamera.CameraType = Enum.CameraType.Scriptable

				if type2 == "Fixed" then
					currentCamera.CFrame = cf
				elseif type2 == "Tween" then
					TweenService:Create(
						currentCamera,
						TweenInfo.new(data.dur or 2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{
							CFrame = cf
						}
					):Play()
				end
			end
		elseif value == "Presentation" then
			print("[NextuneBossRoom] Presentation handler entered")
			count += 1

			if not v7 then
				hideTaggedUI()
			end

			v7 = true
			local v22 = count
			v18 = 0
			currentCamera.CameraType = Enum.CameraType.Scriptable
			currentCamera.CameraSubject = nil
			task.spawn(function()
				if v then
					v.Enabled = false
				end

				local currentCamera2 = workspace.CurrentCamera

				if not currentCamera2 then
					warn("[NextuneBossRoom] Presentation: CurrentCamera is nil")
					return
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function restoreCamera()
					local v23

					if v22 == count then
						forceEndCinematic() -- equivalent call inferred; original call site unknown
						v23 = true
					else
						v23 = false
					end

					if not v23 then
						return
					end

					print("[NextuneBossRoom] Presentation: restoring camera")
					currentCamera2.CameraType = Enum.CameraType.Custom
					local character = Players.LocalPlayer.Character
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")

					if humanoid then
						currentCamera2.CameraSubject = humanoid
					end
				end

				local v23 = (type(data) ~= "table" or type(data.cframes) ~= "table") and {} or data.cframes or {}
				print("[NextuneBossRoom] Presentation: received", #v23, "camera CFrames from server")

				if #v23 == 0 then
					warn("[NextuneBossRoom] Presentation: No camera CFrames received — check workspace.AdminAbuse.Map.Cameras on the server")
					restoreCamera() -- equivalent call inferred; original call site unknown
				else
					local bossRig = getBossRig() -- equivalent call inferred; original call site unknown
					local humanoid = bossRig and bossRig:FindFirstChildOfClass("Humanoid")
					local animator = humanoid and humanoid:FindFirstChildOfClass("Animator") or bossRig and bossRig:FindFirstChildOfClass("Animator")
					print("[NextuneBossRoom] Presentation: bossRig=", bossRig, "| animator=", animator)
					print("[NextuneBossRoom] Presentation: sweeping to farthest cam over", 2.5, "sec")
					local v24 = v23[1]
					local cFrame2 = currentCamera2.CFrame
					local lastTime = tick()

					repeat
						local v25 = math.clamp((tick() - lastTime) / 2.5, 0, 1)
						cFrame = cFrame2:Lerp(v24, v25 * v25 * (3 - v25 * 2))
						task.wait()
					until tick() - lastTime >= 2.5

					cFrame = v24
					local track

					if animator and NextuneBossRoom.BossAnimations.Roar ~= "rbxassetid://XXXXXXX" then
						local animation = Instance.new("Animation")
						animation.AnimationId = NextuneBossRoom.BossAnimations.Roar
						track = animator:LoadAnimation(animation)
						local connection = nil
						connection = track:GetMarkerReachedSignal("Roar"):Connect(function()
							if connection then
								connection:Disconnect()
								connection = nil
							end

							print("[NextuneBossRoom] Presentation: 'Roar' marker reached — starting effects")
							setVfxEnabled(true)

							if NextuneBossRoom.SFX.Roar ~= "rbxassetid://XXXXXXX" then
								local sound = Instance.new("Sound")
								sound.SoundId = NextuneBossRoom.SFX.Roar
								sound.Volume = 2
								sound.Parent = bossRig and bossRig.PrimaryPart or workspace
								playSfxWithAutoFade(sound) -- equivalent call inferred; original call site unknown
								local Debris2 = game:GetService("Debris")
								Debris2:AddItem(sound, 7)
							end

							task.spawn(function()
								local random = Random.new()
								local lastTime2 = tick()
								local v25 = lastTime2 + 5

								while tick() < v25 and v7 and v22 == count do
									local v26 = (1 - math.clamp((tick() - lastTime2 - 3.75) / 1.25, 0, 1)) * 0.72
									local cframe = CFrame.Angles(
										random:NextNumber(-0.024, 0.024) * v26 * 3.5,
										random:NextNumber(-0.028, 0.028) * v26 * 3.5,
										random:NextNumber(-0.016, 0.016) * v26 * 3.5
									)
									identity2 = CFrame.new(
										random:NextNumber(-1, 1) * v26 * 0.44,
										random:NextNumber(-1, 1) * v26 * 0.36,
										random:NextNumber(-1, 1) * v26 * 0.44
									) * cframe
									task.wait()
								end

								identity2 = CFrame.identity
							end)
						end)
						track:Play(0.5, 1, 1)
						print("[NextuneBossRoom] Presentation: roar animation playing — waiting for 'Roar' marker...")
					end

					print("[NextuneBossRoom] Presentation: holding for", 5, "sec")
					task.wait(5)
					identity2 = CFrame.identity

					if track then
						track:Stop()
					end

					setVfxEnabled(false)
					cFrame = nil

					for i = 2, #v23 do
						print("[NextuneBossRoom] Presentation: tweening to cam index:", i)
						local cFrame3 = v23[i]
						local tween = TweenService:Create(
							currentCamera2,
							TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								CFrame = cFrame3
							}
						)
						tween:Play()
						tween.Completed:Wait()
					end

					restoreCamera() -- equivalent call inferred; original call site unknown

					if v then
						v.Enabled = true
					end
				end
			end)
		elseif value == "PhaseChange" then
			local phase = type(data) == "table" and tonumber(data.phase) or 1
			v21 = phase

			if v4 then
				v4.Text = "PHASE " .. tostring(phase)
			end

			applyPhaseMarkerStyle(math.floor((math.clamp(phase, 1, 3))))

			if phase >= 3 then
				applyPhase3BossBarStyle()
			end

			playPhaseMusic(phase)
			local rate = ({ 500, 2500, 10000 })[phase]

			if rate then
				local adminAbuse = workspace:FindFirstChild("AdminAbuse")
				local map = adminAbuse and adminAbuse:FindFirstChild("Map")
				local scriptables = map and map:FindFirstChild("Scriptables", true)
				local glitchFX = scriptables and scriptables:FindFirstChild("GlitchFX")
				local bossRig = map and map:FindFirstChild("BossRig", true)
				local glitchFX2 = bossRig and bossRig:FindFirstChild("GlitchFX")

				if glitchFX2 then
					for _, emitter in glitchFX2:GetDescendants() do
						if emitter:IsA("ParticleEmitter") then
							emitter.Rate = rate
						end
					end
				end

				if glitchFX then
					for _, emitter in glitchFX:GetDescendants() do
						if emitter:IsA("ParticleEmitter") then
							emitter.Rate = rate
						end
					end
				end
			end
		elseif value == "PhaseCutscene" then
			local v22 = type(data) ~= "table" and 2 or tonumber(data.phase) or 2
			local _ = type(data) == "table" and tonumber(data.duration)
			local shots

			if type(data) == "table" then
				shots = data.shots
			else
				shots = false
			end

			task.spawn(function()
				if type(shots) ~= "table" or #shots == 0 then
					warn("[NextuneBossRoom] PhaseCutscene: no shot data received for Phase" .. tostring(v22))
					return
				end

				local currentCamera2 = workspace.CurrentCamera

				if not currentCamera2 then
					return
				end

				count += 1

				if not v7 then
					hideTaggedUI()
				end

				v7 = true
				local v23 = count
				v18 = 0
				currentCamera2.CameraType = Enum.CameraType.Scriptable
				currentCamera2.CameraSubject = nil

				for _, shot in ipairs(shots) do
					local cf = shot.cf
					local tweenDuration = shot.tweenDuration
					local holdDuration = shot.holdDuration
					local tween = TweenService:Create(
						currentCamera2,
						TweenInfo.new(tweenDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CFrame = cf
						}
					)
					tween:Play()
					tween.Completed:Wait()
					cFrame = cf
					local v26 = os.clock() + holdDuration
					local v27 = os.clock()
					task.spawn(function()
						local random = Random.new()
						local v28 = math.max(holdDuration, 0.001)

						while os.clock() < v26 and v7 and v23 == count do
							local v29 = (1 - math.clamp((os.clock() - v27 - v28 * 0.75) / (v28 * 0.25), 0, 1)) * 0.18
							local cframe = CFrame.Angles(
								random:NextNumber(-0.024, 0.024) * v29 * 3.5,
								random:NextNumber(-0.028, 0.028) * v29 * 3.5,
								random:NextNumber(-0.016, 0.016) * v29 * 3.5
							)
							identity2 = CFrame.new(
								random:NextNumber(-1, 1) * v29 * 0.44,
								random:NextNumber(-1, 1) * v29 * 0.36,
								random:NextNumber(-1, 1) * v29 * 0.44
							) * cframe
							task.wait()
						end

						identity2 = CFrame.identity
					end)
					task.wait((math.max(0, holdDuration)))
					cFrame = nil
				end

				local flag3

				if v23 == count then
					forceEndCinematic() -- equivalent call inferred; original call site unknown
					flag3 = true
				else
					flag3 = false
				end

				if flag3 then
					currentCamera2.CameraType = Enum.CameraType.Custom
					local character = Players.LocalPlayer.Character
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")

					if humanoid then
						currentCamera2.CameraSubject = humanoid
					end
				end
			end)
		elseif value == "ScreenShake" then
			if type(data) ~= "table" then
				return
			end

			local intensity = tonumber(data.intensity) or 0.3
			local duration = tonumber(data.duration) or 0.5

			if v10 then
				v10:ShakeOnce(intensity, 8, 0.05, duration * 0.85)
			end
		elseif value == "ZoneWarn" then
			if type(data) ~= "table" then
				return
			end

			local function num(p: string, p2: number)
				local v22 = data[p]

				if type(v22) == "number" then
					return v22
				end

				return p2
			end

			local x = data.x
			local v22 = type(x) ~= "number" and 0 or x
			local y = data.y
			local v23 = type(y) ~= "number" and 0 or y
			local z = data.z
			local vector2 = Vector3.new(v22, v23, type(z) ~= "number" and 0 or z)
			local hx = data.hx
			local v24 = type(hx) ~= "number" and 9 or hx
			local hz = data.hz
			local v25 = type(hz) ~= "number" and 9 or hz
			local t = data.t
			local v26 = type(t) ~= "number" and 1.4 or t
			local color = ({ Color3.fromRGB(255, 152, 220), Color3.fromRGB(106, 57, 9) })[math.random(1, 2)]
			local part = Instance.new("Part")
			part.Name = "NexZoneWarnFx"
			part.Shape = Enum.PartType.Cylinder
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.Material = Enum.Material.Neon
			part.Color = color
			part.Transparency = 0.3
			part.Size = Vector3.new(0.05, v24 * 2, v25 * 2)
			part.CFrame = CFrame.fromMatrix(
				vector2 + createVector(0, 2.5, 0),
				createVector(0, 1, 0),
				createVector(0, 0, -1)
			)
			part.Parent = getClientDebrisFolder()
			local tween = TweenService:Create(
				part,
				TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					Size = Vector3.new(3, v24 * 2, v25 * 2)
				}
			)
			tween:Play()
			tween.Completed:Connect(function()
				tween:Destroy()
			end)
			local tween2 = TweenService:Create(
				part,
				TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{
					Transparency = 0.72
				}
			)
			task.delay(0.2, function()
				if part.Parent then
					tween2:Play()
				end
			end)
			task.delay(math.max(0, v26 - 0.2), function()
				if not part.Parent then
					tween2:Destroy()
					return
				end

				tween2:Cancel()
				tween2:Destroy()
				local tween3 = TweenService:Create(
					part,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Transparency = 1,
						Size = Vector3.new(0.05, v24 * 2, v25 * 2)
					}
				)
				local completedConnection = nil
				completedConnection = tween3.Completed:Connect(function()
					completedConnection:Disconnect()
					tween3:Destroy()

					if part.Parent then
						part:Destroy()
					end
				end)
				tween3:Play()
			end)
		elseif value == "ZoneHit" then
			if type(data) ~= "table" then
				return
			end

			local function num(p: string, p2: number)
				local v22 = data[p]

				if type(v22) == "number" then
					return v22
				end

				return p2
			end

			local x = data.x
			local v22 = type(x) ~= "number" and 0 or x
			local y = data.y
			local v23 = type(y) ~= "number" and 0 or y
			local z = data.z
			local vector2 = Vector3.new(v22, v23, type(z) ~= "number" and 0 or z)
			local hx = data.hx
			local v24 = type(hx) ~= "number" and 9 or hx
			local hz = data.hz
			local v25 = type(hz) ~= "number" and 9 or hz
			local color = ({ Color3.fromRGB(255, 152, 220), Color3.fromRGB(106, 57, 9) })[math.random(1, 2)]
			local part = Instance.new("Part")
			part.Name = "NexZoneJetFx"
			part.Shape = Enum.PartType.Cylinder
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.Material = Enum.Material.Neon
			part.Color = color
			part.Transparency = 0.15
			part.Size = Vector3.new(2, v24 * 1.6, v25 * 1.6)
			part.CFrame = CFrame.fromMatrix(
				vector2 - createVector(0, 4, 0),
				createVector(0, 1, 0),
				createVector(0, 0, -1)
			)
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://109344802985233"
			sound.Parent = part
			part.Parent = getClientDebrisFolder()
			sound:Play()
			local tween = TweenService:Create(
				part,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Size = Vector3.new(160, v24 * 1.9, v25 * 1.9),
					CFrame = CFrame.fromMatrix(
						vector2 + createVector(0, 76, 0),
						createVector(0, 1, 0),
						createVector(0, 0, -1)
					)
				}
			)
			tween:Play()
			task.delay(0.35, function()
				tween:Destroy()

				if not part.Parent then
					return
				end

				local tween2 = TweenService:Create(
					part,
					TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						Transparency = 1,
						Size = createVector(160, 0.1, 0.1)
					}
				)
				local completedConnection = nil
				completedConnection = tween2.Completed:Connect(function()
					completedConnection:Disconnect()
					tween2:Destroy()

					if part.Parent then
						part:Destroy()
					end
				end)
				tween2:Play()
			end)
			local part2 = Instance.new("Part")
			part2.Name = "NexZonePopFx"
			part2.Anchored = true
			part2.CanCollide = false
			part2.CanQuery = false
			part2.Material = Enum.Material.Neon
			part2.Color = Color3.fromRGB(255, 152, 220)
			part2.Transparency = 0.4
			part2.Size = createVector(1, 0.5, 1)
			part2.CFrame = CFrame.new(vector2 + createVector(0, 0.25, 0))
			part2.Parent = getClientDebrisFolder()
			local tween2 = TweenService:Create(
				part2,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Transparency = 1,
					Size = Vector3.new(v24 * 2.8, 0.5, v25 * 2.8)
				}
			)
			local completedConnection = nil
			completedConnection = tween2.Completed:Connect(function()
				completedConnection:Disconnect()
				tween2:Destroy()

				if part2.Parent then
					part2:Destroy()
				end
			end)
			tween2:Play()
		elseif value == "Phase3Cutscene" then
			local shots = type(data) == "table" and data.shots or {}
			local bossRig = getBossRig() -- equivalent call inferred; original call site unknown

			if bossRig and NextuneBossRoom.SFX.Glitch ~= "rbxassetid://XXXXX" then
				local sound = Instance.new("Sound")
				sound.SoundId = NextuneBossRoom.SFX.Glitch
				sound.Volume = 10
				sound.Parent = bossRig.PrimaryPart or bossRig
				playSfxWithAutoFade(sound) -- equivalent call inferred; original call site unknown
				Debris:AddItem(sound, 10)
			end

			task.spawn(function()
				if type(shots) ~= "table" or #shots == 0 then
					warn("[NextuneBossRoom] Phase3Cutscene: no shot data received")
					return
				end

				local currentCamera2 = workspace.CurrentCamera

				if not currentCamera2 then
					return
				end

				count += 1

				if not v7 then
					hideTaggedUI()
				end

				v7 = true
				local v22 = count
				v18 = v22
				currentCamera2.CameraType = Enum.CameraType.Scriptable
				currentCamera2.CameraSubject = nil

				if v then
					v.Enabled = false
				end

				task.spawn(function()
					local random = Random.new()

					while v7 and v22 == count do
						identity2 = CFrame.new(
							random:NextNumber(-1, 1) * 0.45 * 0.44,
							random:NextNumber(-1, 1) * 0.45 * 0.36,
							random:NextNumber(-1, 1) * 0.45 * 0.44
						) * CFrame.Angles(
							random:NextNumber(-0.024, 0.024) * 0.45 * 3.5,
							random:NextNumber(-0.028, 0.028) * 0.45 * 3.5,
							random:NextNumber(-0.016, 0.016) * 0.45 * 3.5
						)
						task.wait()
					end

					identity2 = CFrame.identity
				end)

				for i, shot in ipairs(shots) do
					if not v7 or v22 ~= count then
						break
					end

					local cf = shot.cf
					local tweenDuration = shot.tweenDuration
					local holdDuration = shot.holdDuration
					local v23 = i == #shots
					local tween = TweenService:Create(
						currentCamera2,
						TweenInfo.new(tweenDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CFrame = cf
						}
					)
					tween:Play()
					tween.Completed:Wait()
					tween:Destroy()
					cFrame = cf
					local v27 = os.clock() + holdDuration
					local v28 = os.clock()
					task.spawn(function()
						local random = Random.new()
						local v29 = math.max(holdDuration, 0.001)

						while v7 and v22 == count and (v23 or os.clock() < v27) do
							local v30 = os.clock() - v28
							local v31 = (v23 and 1 or 1 - math.clamp((v30 - v29 * 0.75) / (v29 * 0.25), 0, 1)) * 0.18
							identity2 = CFrame.new(
								random:NextNumber(-1, 1) * v31 * 0.44,
								random:NextNumber(-1, 1) * v31 * 0.36,
								random:NextNumber(-1, 1) * v31 * 0.44
							) * CFrame.Angles(
								random:NextNumber(-0.024, 0.024) * v31 * 3.5,
								random:NextNumber(-0.028, 0.028) * v31 * 3.5,
								random:NextNumber(-0.016, 0.016) * v31 * 3.5
							)
							task.wait()
						end

						identity2 = CFrame.identity
					end)

					if v23 then
						while v7 and v22 == count do
							task.wait(0.1)
						end
					else
						task.wait((math.max(0, holdDuration)))
						cFrame = nil
					end
				end

				if v22 == count then
				end
			end)
		elseif value == "Phase3CutsceneEnd" then
			if v18 <= 0 then
				return
			end

			if v18 > 0 then
				local v22

				if v18 == count then
					forceEndCinematic() -- equivalent call inferred; original call site unknown
					v22 = true
				else
					v22 = false
				end

				if not v22 then
					return
				end
			end

			v18 = 0
			cFrame = nil
			identity2 = CFrame.identity
			local currentCamera2 = workspace.CurrentCamera

			if currentCamera2 then
				currentCamera2.CameraType = Enum.CameraType.Custom
				local character = Players.LocalPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					currentCamera2.CameraSubject = humanoid
				end
			end

			if v then
				v.Enabled = true
			end
		elseif value == "BossPulse" then
			local cloneFrame = clone and clone:FindFirstChild("Frame")

			if cloneFrame then
				local color

				if data and data.purple == true then
					color = Color3.fromRGB(225, 20, 255)
				else
					color = backgroundColor3 or cloneFrame.BackgroundColor3
				end

				local backgroundColor = backgroundColor3 or cloneFrame.BackgroundColor3
				local tween = TweenService:Create(
					cloneFrame,
					TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						BackgroundTransparency = 0.1,
						BackgroundColor3 = color
					}
				)
				tween:Play()
				tween.Completed:Once(function()
					tween:Destroy()
					local tween2 = TweenService:Create(
						cloneFrame,
						TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							BackgroundTransparency = 0.85,
							BackgroundColor3 = backgroundColor
						}
					)
					tween2:Play()
					tween2.Completed:Once(function()
						tween2:Destroy()
					end)
				end)
			end
		elseif value == "FinalCutscene" then
			task.spawn(function()
				local WAIT_INTERVAL = 1.5
				local currentCamera2 = workspace.CurrentCamera

				if not currentCamera2 then
					return
				end

				if v then
					v.Enabled = false
				end

				if clone then
					clone.Enabled = false
				end

				flag2 = false
				local localPlayer = Players.LocalPlayer
				local playerGui = localPlayer:WaitForChild("PlayerGui")
				local screenGui = Instance.new("ScreenGui")
				screenGui.Name = "NextuneBossEndTransition"
				screenGui.IgnoreGuiInset = true
				screenGui.ResetOnSpawn = false
				screenGui.DisplayOrder = 999999
				screenGui.Parent = playerGui
				local frame = Instance.new("Frame")
				frame.Size = UDim2.fromScale(1, 1)
				frame.BackgroundColor3 = Color3.new(0, 0, 0)
				frame.BorderSizePixel = 0
				frame.BackgroundTransparency = 1
				frame.Parent = screenGui
				TweenService:Create(frame, TweenInfo.new(1.5), {
					BackgroundTransparency = 0
				}):Play()
				task.wait(WAIT_INTERVAL)
				local adminAbuse = workspace:FindFirstChild("AdminAbuse")
				local map = adminAbuse and adminAbuse:FindFirstChild("Map")
				local scriptables = map and map:FindFirstChild("Scriptables", true)
				local cameras = scriptables and scriptables:FindFirstChild("Cameras")
				local phaseEnd = cameras and cameras:FindFirstChild("PhaseEnd")
				local phaseEnd2 = scriptables and scriptables:FindFirstChild("PhaseEnd")
				local _1 = phaseEnd and phaseEnd:FindFirstChild("1")

				if _1 then
					count += 1

					if not v7 then
						hideTaggedUI()
					end

					v7 = true
					currentCamera2.CameraType = Enum.CameraType.Scriptable
					currentCamera2.CFrame = _1.CFrame
					cFrame = _1.CFrame
				end

				TweenService:Create(frame, TweenInfo.new(1.5), {
					BackgroundTransparency = 1
				}):Play()
				task.wait(WAIT_INTERVAL)
				local bossRig = getBossRig() -- equivalent call inferred; original call site unknown
				local humanoid = bossRig and bossRig:FindFirstChildOfClass("Humanoid")
				local animator = humanoid and humanoid:FindFirstChildOfClass("Animator") or bossRig and bossRig:FindFirstChildOfClass("Animator")
				local _2 = phaseEnd and phaseEnd:FindFirstChild("2")
				local _3 = phaseEnd and phaseEnd:FindFirstChild("3")
				local lastTime = os.clock()
				local flag3 = true
				local VFX = phaseEnd2 and phaseEnd2:FindFirstChild("VFX")

				if VFX then
					task.spawn(function()
						for _, model in VFX:GetChildren() do
							if model:IsA("Model") then
								for _, emitter in model:GetDescendants() do
									if emitter:IsA("ParticleEmitter") then
										emitter.Enabled = true
									end
								end
							end

							task.wait(0.1)
						end
					end)
				end

				task.spawn(function()
					local random = Random.new()

					while flag3 do
						local v22 = os.clock() - lastTime
						local v23

						if v22 < 10 then
							v23 = math.clamp(v22 / 10, 0, 1) * 0.5 + 0.1
						else
							v23 = math.clamp((v22 - 10) / 2, 0, 1) * 0.4 + 0.6
						end

						identity2 = CFrame.new(
							random:NextNumber(-1, 1) * v23 * 0.3,
							random:NextNumber(-1, 1) * v23 * 0.25,
							random:NextNumber(-1, 1) * v23 * 0.3
						) * CFrame.Angles(
							random:NextNumber(-0.02, 0.02) * v23 * 2,
							random:NextNumber(-0.02, 0.02) * v23 * 2,
							random:NextNumber(-0.015, 0.015) * v23 * 2
						)
						task.wait()
					end

					identity2 = CFrame.identity
				end)
				task.spawn(function()
					local track

					if animator then
						local animation = Instance.new("Animation")
						animation.AnimationId = NextuneBossRoomAnimIds.Glitch
						track = animator:LoadAnimation(animation)

						if track then
							track.Priority = Enum.AnimationPriority.Action4
							track.Looped = true
							track:Play(0.2)
						end
					end

					local sound

					if bossRig and NextuneBossRoom.SFX.Glitch ~= "rbxassetid://XXXXX" then
						sound = Instance.new("Sound")
						sound.SoundId = NextuneBossRoom.SFX.Glitch
						sound.Volume = 10
						sound.Looped = true
						sound.Parent = bossRig.PrimaryPart or bossRig
						sound:Play()
					end

					while flag3 do
						local playbackSpeed = math.clamp((os.clock() - lastTime) / 12, 0, 1) * 3 + 1

						if track then
							track:AdjustSpeed(playbackSpeed)
						end

						if sound then
							sound.PlaybackSpeed = playbackSpeed
						end

						task.wait(0.05)
					end

					if track then
						track:Stop(0)
					end

					if sound then
						sound:Stop()
						sound:Destroy()
					end
				end)
				task.wait(5)

				if _2 then
					cFrame = _2.CFrame
					currentCamera2.CFrame = _2.CFrame
				end

				if _3 then
					cFrame = nil
					local tween = TweenService:Create(
						currentCamera2,
						TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{
							CFrame = _3.CFrame
						}
					)
					tween:Play()
					tween.Completed:Wait()
					tween:Destroy()
					cFrame = _3.CFrame
				else
					task.wait(4)
				end

				task.wait(2)

				if bossRig then
					local humanoidRootPart = bossRig:FindFirstChild("HumanoidRootPart")
					local sound = Instance.new("Sound")
					sound.SoundId = NextuneBossRoom.SFX.Explosion
					sound.Volume = 4
					sound.Parent = humanoidRootPart or bossRig.PrimaryPart or bossRig
					sound:Play()
					Debris:AddItem(sound, 6)
				end

				task.wait(1)
				flag3 = false
				stopPhaseMusic()
				local adminAbuse2 = workspace:FindFirstChild("AdminAbuse")
				local map2 = adminAbuse2 and adminAbuse2:FindFirstChild("Map")
				local scriptables2 = map2 and map2:FindFirstChild("Scriptables", true)
				local glitchFX = scriptables2 and scriptables2:FindFirstChild("GlitchFX")

				if glitchFX then
					glitchFX:Destroy()
				end

				task.wait(7)
				TweenService:Create(frame, TweenInfo.new(0.5), {
					BackgroundTransparency = 0
				}):Play()
				task.wait(0.5)
				local _4 = phaseEnd and phaseEnd:FindFirstChild("4")

				if _4 then
					currentCamera2.CFrame = _4.CFrame
					cFrame = _4.CFrame
				end

				TweenService:Create(frame, TweenInfo.new(0.5), {
					BackgroundTransparency = 1
				}):Play()
				task.wait(0.5)
				showFakeAnnouncement()
				task.wait(2.5)
				local _5 = phaseEnd and phaseEnd:FindFirstChild("5")

				if _5 then
					cFrame = nil
					local tween = TweenService:Create(
						currentCamera2,
						TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{
							CFrame = _5.CFrame
						}
					)
					tween:Play()
					tween.Completed:Wait()
					tween:Destroy()
					cFrame = _5.CFrame
					task.delay(0.5, function()
						showFakeAnnouncement("It's your turn now.")
					end)
				end

				task.wait(WAIT_INTERVAL)
				TweenService:Create(frame, TweenInfo.new(0.5), {
					BackgroundTransparency = 0
				}):Play()
				task.wait(10)

				if screenGui then
					screenGui:Destroy()
				end

				forceEndCinematic() -- equivalent call inferred; original call site unknown
				destroyUi()
				currentCamera2.CameraType = Enum.CameraType.Custom
				local character = localPlayer.Character
				local humanoid2 = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid2 then
					currentCamera2.CameraSubject = humanoid2
				end

				showCredits()
			end)
		else
			print("[NextuneBossRoom] fxRemote: unhandled cmd:", value)
		end
	end)
	RunService:BindToRenderStep("NextuneCinematicLock", Enum.RenderPriority.Camera.Value + 2, function()
		if not v7 then
			return
		end

		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			return
		end

		if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
			currentCamera.CameraType = Enum.CameraType.Scriptable
		end

		if cFrame then
			currentCamera.CFrame = cFrame * identity2 * identity
		end
	end)

	if v10 then
		v10:Stop()
	end

	v10 = camerashaker.new(Enum.RenderPriority.Camera.Value + 1, function(cframe: CFrame)
		identity = cframe
	end)
	v10:Start()
end

function NextuneBossRoom.Fire(_, _: number?)
	flag2 = false
	destroyUi()
	teardownCutsceneListener() -- equivalent call inferred; original call site unknown
	buildUi()
	setupCutsceneListener()
	local adminAbuseBossSync = remotes:FindFirstChild("AdminAbuseBossSync")

	if adminAbuseBossSync and adminAbuseBossSync:IsA("RemoteEvent") then
		onClientEventConnection = adminAbuseBossSync.OnClientEvent:Connect(function(p, p2, p3)
			onBossHpSync(p, p2, p3)
		end)
	end

	preloadAssets()
	v21 = 1
	playPhaseMusic(1)
	flag2 = true
	task.spawn(function()
		local WAIT_INTERVAL = 0.1
		local random = Random.new()

		while flag2 do
			task.wait(random:NextNumber(15, 35))

			if not flag2 or v7 then
				continue
			end

			local bossRig = getBossRig() -- equivalent call inferred; original call site unknown

			if not bossRig then
				continue
			end

			local humanoid = bossRig:FindFirstChildOfClass("Humanoid")
			local animator = humanoid and humanoid:FindFirstChildOfClass("Animator") or bossRig:FindFirstChildOfClass("Animator")

			if not animator then
				continue
			end

			local number = random:NextNumber()
			local v22

			if v21 >= 2 then
				v22 = number < 0.3 and "Roar" or number < 0.7 and "Laugh" or "Glitch"
			else
				v22 = number < 0.4 and "Roar" or "Laugh"
			end

			if v22 == "Roar" then
				local animation = Instance.new("Animation")
				animation.AnimationId = NextuneBossRoom.BossAnimations.Roar
				local track = animator:LoadAnimation(animation)
				track.Priority = Enum.AnimationPriority.Action
				local sound

				if NextuneBossRoom.SFX.Roar ~= "rbxassetid://XXXXXXX" then
					sound = Instance.new("Sound")
					sound.SoundId = NextuneBossRoom.SFX.Roar
					sound.Volume = 2.2
					sound.Parent = bossRig.PrimaryPart or bossRig
					playSfxWithAutoFade(sound) -- equivalent call inferred; original call site unknown
					local Debris2 = game:GetService("Debris")
					Debris2:AddItem(sound, 8)
				end

				setVfxEnabled(true)
				track:Play(0.5)
				local total = 0
				local v23

				if sound then
					v23 = 4.5
				else
					v23 = 3
				end

				repeat
					total += task.wait(WAIT_INTERVAL)
				until v23 <= total or not flag2 or v7

				track:Stop(0.6)
				setVfxEnabled(false)
			elseif v22 == "Glitch" then
				local animation = Instance.new("Animation")
				animation.AnimationId = NextuneBossRoomAnimIds.Glitch
				local track = animator:LoadAnimation(animation)
				track.Priority = Enum.AnimationPriority.Action
				track:Play(0.3)

				if NextuneBossRoom.SFX.Glitch ~= "rbxassetid://XXXXX" then
					local sound = Instance.new("Sound")
					sound.SoundId = NextuneBossRoom.SFX.Glitch
					sound.Volume = 1.5
					sound.Parent = bossRig.PrimaryPart or bossRig
					playSfxWithAutoFade(sound) -- equivalent call inferred; original call site unknown
					local Debris2 = game:GetService("Debris")
					Debris2:AddItem(sound, 8)
				end

				local total = 0
				local length

				if track.Length > 0 then
					length = track.Length
				else
					length = 3
				end

				repeat
					total += task.wait(WAIT_INTERVAL)
				until length <= total or not flag2 or v7

				track:Stop(0.4)
			else
				local animation = Instance.new("Animation")
				animation.AnimationId = NextuneBossRoom.BossAnimations.Laugh
				local track = animator:LoadAnimation(animation)
				track.Looped = true
				track.Priority = Enum.AnimationPriority.Action
				track:Play(0.5)

				if NextuneBossRoom.SFX.Laugh == "rbxassetid://XXXXXXX" then
					local v23 = not (track.Length > 0) and 4 or track.Length
					local total = 0

					repeat
						total += task.wait(WAIT_INTERVAL)
					until v23 <= total or not flag2 or v7
				else
					local sound = Instance.new("Sound")
					sound.SoundId = NextuneBossRoom.SFX.Laugh
					sound.Volume = 1.5
					sound.Parent = bossRig.PrimaryPart or bossRig
					playSfxWithAutoFade(sound) -- equivalent call inferred; original call site unknown
					local v23 = false
					local endedConnection = sound.Ended:Connect(function()
						v23 = true
					end)
					local total = 0

					repeat
						total += task.wait(WAIT_INTERVAL)
					until v23 or not flag2 or v7 or total > 15

					endedConnection:Disconnect()
					sound:Stop()
					local Debris2 = game:GetService("Debris")
					Debris2:AddItem(sound, 1)
				end

				track:Stop(0.5)
			end
		end
	end)
end

function NextuneBossRoom:Stop()
	flag2 = false
	destroyUi()
	teardownCutsceneListener() -- equivalent call inferred; original call site unknown
end

function NextuneBossRoom.SyncBossBarToPlayer(_, _) end

return NextuneBossRoom