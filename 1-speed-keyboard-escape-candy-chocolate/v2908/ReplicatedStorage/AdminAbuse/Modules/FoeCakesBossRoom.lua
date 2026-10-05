local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local remotes = ReplicatedStorage:WaitForChild("AdminAbuse"):WaitForChild("Remotes")
local FoeCakesBossAnimIds = require(script:FindFirstChild("FoeCakesBossAnimIds"))
local FoeCakesBossSoundIds = require(script:FindFirstChild("FoeCakesBossSoundIds"))
FoeCakesBossSoundIds = FoeCakesBossSoundIds.SFX
local FoeCakesBossSoundIds2 = require(script:FindFirstChild("FoeCakesBossSoundIds"))
local soundtracks = FoeCakesBossSoundIds2.Soundtracks
local FoeCakesCutscenes = require(script:FindFirstChild("FoeCakesCutscenes"))
local camerashaker = require(ReplicatedStorage.Packages.camerashaker)
local adminAbuseBossFx = remotes:WaitForChild("AdminAbuseBossFx")
local v = nil
local parent = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local onClientEventConnection = nil
local onClientEventConnection2 = nil
local v7 = 1
local v8 = 0
local flag = false
local v9 = {}
local v10 = nil
local v11 = nil
local v12 = nil
local v13 = nil
local identity = CFrame.identity
local identity2 = CFrame.identity
local visibilityByFrame = {}
local v14 = nil
local v15 = {}
local v16 = nil
local flag2 = false
local v17 = 1
local v18 = 0
local animation = Instance.new("Animation")
animation.AnimationId = FoeCakesBossAnimIds.Laugh
local v19 = nil
local v20 = nil
local v21 = nil
local v22 = nil
local v23 = nil
local count = 0

local function hideTaggedUI()
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChild("PlayerGui")

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

local function forceEndCinematic()
	restoreTaggedUI() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getClientDebrisFolder()
	local adminAbuse = workspace:FindFirstChild("AdminAbuse")
	local map = adminAbuse and adminAbuse:FindFirstChild("Map")
	return map and map:FindFirstChild("Debris", true) or workspace
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function getSoundtrackIndex(p: number)
	if p >= 7 then
		return 3
	end

	if p >= 4 then
		return 2
	end

	return 1
end

local function stopSoundtrack()
	v18 = 0

	if v14 and v14.Parent then
		local v24 = v14
		local tween = TweenService:Create(v24, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Volume = 0
		})
		tween:Play()
		tween.Completed:Once(function()
			v24:Stop()
			v24:Destroy()
			tween:Destroy()
		end)
	end

	v14 = nil
end

local function startSoundtrack(p: number?)
	local soundtrackIndex = getSoundtrackIndex(p or v17)
	stopSoundtrack()
	local soundtrack = soundtracks[soundtrackIndex]

	if not soundtrack then
		return
	end

	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	local sound = Instance.new("Sound")
	sound.Name = "FoeCakesBossMusic"
	sound.SoundId = "rbxassetid://" .. tostring(soundtrack)
	sound.Looped = true
	sound.Volume = 0
	sound.Parent = localPlayer
	v14 = sound
	v18 = soundtrackIndex
	task.spawn(function()
		if not sound.IsLoaded then
			sound.Loaded:Wait()
		end

		if sound and sound.Parent then
			sound:Play()
			TweenService:Create(sound, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Volume = 0.5
			}):Play()
		end
	end)
end

local function getLiveBossRig()
	local adminAbuse = workspace:FindFirstChild("AdminAbuse")
	local map = adminAbuse and adminAbuse:FindFirstChild("Map")

	if not map then
		return nil
	end

	for _, model in map:GetChildren() do
		if not (model:IsA("Model") and model:GetAttribute("AdminAbuseLiveMap")) then
			continue
		end

		local bossRig = model:FindFirstChild("BossRig")

		if bossRig and bossRig:IsA("Model") then
			return bossRig
		end

		return nil
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startLaughLoop()
	flag2 = true
	local random = Random.new()
	task.spawn(function()
		while flag2 do
			task.wait(random:NextNumber(15, 35))

			if not flag2 then
				break
			end

			local liveBossRig = getLiveBossRig()

			if not liveBossRig then
				continue
			end

			local humanoid = liveBossRig:FindFirstChildOfClass("Humanoid")
			local animator = humanoid and humanoid:FindFirstChildOfClass("Animator") or liveBossRig:FindFirstChildOfClass("Animator")

			if not animator then
				continue
			end

			local track = animator:LoadAnimation(animation)
			track.Looped = true
			track.Priority = Enum.AnimationPriority.Action
			track:Play(0.5)
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://4810729995"
			sound.Volume = 4.5
			sound.Parent = liveBossRig.PrimaryPart or liveBossRig
			sound:Play()
			Debris:AddItem(sound, 20)
			local v24 = false
			local endedConnection = sound.Ended:Connect(function()
				v24 = true
			end)
			local total = 0

			repeat
				total += task.wait(0.1)
			until v24 or not flag2 or total > 15

			endedConnection:Disconnect()
			sound:Stop()
			track:Stop(0.5)
		end
	end)
end

local function refreshBar()
	local v24 = parent
	local v25 = v3
	local v26 = v5

	if not v26 or not v24 or v7 <= 0 then
		return
	end

	local v27 = math.clamp(v26.Value, 0, v7)
	v24.Size = UDim2.new(math.clamp(v27 / v7, 0, 1), 0, 1, 0)

	if v25 then
		if v7 >= 1000000 then
			v25.Text = string.format("%.3fM / %.1fM", v27 / 1000000, v7 / 1000000)
		else
			v25.Text = string.format("%d / %d", math.floor(v27 + 0.5), (math.floor(v7 + 0.5)))
		end
	end

	local v28 = v27 / v7

	for i, v29 in ipairs(v9) do
		local v30 = i * 0.1 <= v28
		local backgroundColor

		if v30 then
			backgroundColor = Color3.fromRGB(220, 30, 60)
		else
			backgroundColor = Color3.fromRGB(95, 95, 105)
		end

		v29.BackgroundColor3 = backgroundColor
		v29.BackgroundTransparency = v30 and 0.05 or 0.35
	end
end

local function onBossHpSync(value, max, value2)
	if type(value) ~= "number" then
		return
	end

	if type(max) ~= "number" then
		max = value
	end

	if max <= 0 or type(value2) == "number" and value2 < v8 then
		return
	end

	if type(value2) == "number" then
		v8 = value2
	end

	v7 = max

	if v6 then
		v6:Cancel()
		v6 = nil
	end

	local v24 = math.clamp(value, 0, max)

	if flag then
		local v25 = v5

		if not v25 then
			return
		end

		local tween = TweenService:Create(v25, TweenInfo.new(0.38, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Value = v24
		})
		v6 = tween
		tween:Play()
	else
		flag = true

		if v5 then
			v5.Value = v24
		end

		refreshBar()
	end
end

local function destroyUi()
	if v6 then
		v6:Cancel()
		v6 = nil
	end

	if onClientEventConnection then
		onClientEventConnection:Disconnect()
		onClientEventConnection = nil
	end

	if v11 then
		v11:Cancel()
		v11:Destroy()
		v11 = nil
	end

	if v10 then
		v10:Destroy()
		v10 = nil
	end

	if v then
		v:Destroy()
		v = nil
	end

	table.clear(v9)
	parent = nil
	v3 = nil
	v4 = nil
	v5 = nil
	v8 = 0
	v7 = 1
	flag = false
end

local function applyPhase4BossBarStyle()
	if not parent then
		return
	end

	local tween = TweenService:Create(parent, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundColor3 = Color3.fromRGB(160, 160, 160)
	})
	tween:Play()
	tween.Completed:Once(function()
		tween:Destroy()
	end)

	if v11 then
		v11:Cancel()
		v11:Destroy()
		v11 = nil
	end

	if v10 then
		v10:Destroy()
	end

	local uIGradient = Instance.new("UIGradient")
	uIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.3, Color3.fromRGB(10, 10, 10)),
		ColorSequenceKeypoint.new(0.65, Color3.fromRGB(220, 220, 220)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 5))
	})
	uIGradient.Rotation = 0
	uIGradient.Offset = Vector2.new(-0.6, 0)
	uIGradient.Parent = parent
	v10 = uIGradient
	v11 = TweenService:Create(
		uIGradient,
		TweenInfo.new(4.1887902047863905, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{
			Offset = Vector2.new(0.6, 0)
		}
	)
	v11:Play()
end

local function applyPhase8BossBarStyle()
	if not parent then
		return
	end

	local tween = TweenService:Create(parent, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundColor3 = Color3.fromRGB(120, 0, 160)
	})
	tween:Play()
	tween.Completed:Once(function()
		tween:Destroy()
	end)

	if v11 then
		v11:Cancel()
		v11:Destroy()
		v11 = nil
	end

	if v10 then
		v10:Destroy()
	end

	local uIGradient = Instance.new("UIGradient")
	uIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 30, 255)),
		ColorSequenceKeypoint.new(0.32, Color3.fromRGB(10, 0, 20)),
		ColorSequenceKeypoint.new(0.68, Color3.fromRGB(185, 20, 240)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 0, 10))
	})
	uIGradient.Rotation = 0
	uIGradient.Offset = Vector2.new(-0.65, 0)
	uIGradient.Parent = parent
	v10 = uIGradient
	v11 = TweenService:Create(
		uIGradient,
		TweenInfo.new(3.6959913571644627, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{
			Offset = Vector2.new(0.65, 0)
		}
	)
	v11:Play()
end

local function buildUi()
	destroyUi()
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FoeCakesBossHud"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 80
	screenGui.Parent = playerGui
	v = screenGui
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
	imageLabel.Image = "rbxthumb://type=AvatarHeadShot&id=586487285&w=150&h=150"
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

	for i = 1, 9 do
		local v24 = i * 0.1
		local frame4 = Instance.new("Frame")
		frame4.Name = "PhaseMarker" .. i
		frame4.AnchorPoint = Vector2.new(0.5, 0.5)
		frame4.Position = UDim2.new(v24, 0, 0.5, 0)
		frame4.Size = UDim2.new(0, 4, 1, 0)
		frame4.BorderSizePixel = 0
		frame4.BackgroundColor3 = Color3.fromRGB(95, 95, 105)
		frame4.BackgroundTransparency = 0.35
		frame4.ZIndex = frame3.ZIndex + 2
		frame4.Parent = frame2
		local uIStroke_2 = Instance.new("UIStroke", frame4)
		uIStroke_2.Thickness = 1
		v9[i] = frame4
		local textLabel = Instance.new("TextLabel")
		textLabel.AnchorPoint = Vector2.new(0.5, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Position = UDim2.new(v24, 0, 0.5, 14)
		textLabel.Size = UDim2.new(0, 40, 0, 16)
		textLabel.ZIndex = frame3.ZIndex + 3
		textLabel.Font = Enum.Font.GothamBold
		textLabel.Text = "P" .. i + 1
		textLabel.TextScaled = true
		textLabel.TextStrokeTransparency = 0.55
		textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		textLabel.TextColor3 = Color3.fromRGB(190, 190, 200)
		textLabel.Parent = frame2
	end

	local textLabel = Instance.new("TextLabel", frame2)
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(0.45, 0, 1, 0)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Text = ("FoeCakes"):upper() .. " BOSS EVENT"
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextScaled = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	local uIPadding = Instance.new("UIPadding", textLabel)
	uIPadding.PaddingLeft = UDim.new(0.04, 0)
	local textLabel2 = Instance.new("TextLabel", frame2)
	textLabel2.AnchorPoint = Vector2.new(1, 0)
	textLabel2.BackgroundTransparency = 1
	textLabel2.Position = UDim2.new(1, 0, 0, 0)
	textLabel2.Size = UDim2.new(0.4, 0, 1, 0)
	textLabel2.Font = Enum.Font.GothamBold
	textLabel2.Text = "0 / 0"
	textLabel2.TextColor3 = Color3.new(1, 1, 1)
	textLabel2.TextScaled = true
	textLabel2.TextXAlignment = Enum.TextXAlignment.Right
	local uIPadding_2 = Instance.new("UIPadding", textLabel2)
	uIPadding_2.PaddingRight = UDim.new(0.04, 0)
	v3 = textLabel2
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	numberValue.Changed:Connect(refreshBar)
	v5 = numberValue
	local textLabel3 = Instance.new("TextLabel", screenGui)
	textLabel3.Name = "PhaseLabel"
	textLabel3.AnchorPoint = Vector2.new(0.5, 0)
	textLabel3.BackgroundTransparency = 1
	textLabel3.Position = UDim2.new(0.5, 0, 0.08, 52)
	textLabel3.Size = UDim2.new(0.12, 0, 0, 20)
	textLabel3.Font = Enum.Font.GothamBold
	textLabel3.Text = "PHASE 1"
	textLabel3.TextColor3 = Color3.new(1, 1, 1)
	textLabel3.TextScaled = true
	textLabel3.TextStrokeTransparency = 0.5
	textLabel3.TextStrokeColor3 = Color3.new(0, 0, 0)
	v4 = textLabel3
end

local function destroyTimeshiftEffects()
	if v19 then
		v19:Destroy()
		v19 = nil
	end

	if v20 then
		v20:Destroy()
		v20 = nil
	end

	if v21 then
		v21:Destroy()
		v21 = nil
	end

	if v22 then
		v22:Destroy()
		v22 = nil
	end

	if v23 then
		v23:Destroy()
		v23 = nil
	end
end

local function timeshiftBegin(duration: number)
	count += 1
	destroyTimeshiftEffects()
	local Lighting = game:GetService("Lighting")
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Name = "FoeCakesTimeshiftCC"
	colorCorrectionEffect.Saturation = 0
	colorCorrectionEffect.Contrast = 0
	colorCorrectionEffect.Brightness = 0
	colorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
	colorCorrectionEffect.Parent = Lighting
	v19 = colorCorrectionEffect
	TweenService:Create(
		colorCorrectionEffect,
		TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Saturation = -1,
			Contrast = 0.4,
			Brightness = -0.12
		}
	):Play()
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChild("PlayerGui")

	if playerGui then
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "FoeCakesTimeshiftFlash"
		screenGui.IgnoreGuiInset = true
		screenGui.ResetOnSpawn = false
		screenGui.DisplayOrder = 1000000
		screenGui.Parent = playerGui
		local frame = Instance.new("Frame")
		frame.Size = UDim2.fromScale(1, 1)
		frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		frame.BackgroundTransparency = 0
		frame.BorderSizePixel = 0
		frame.Parent = screenGui
		v23 = screenGui
		TweenService:Create(frame, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		}):Play()
		task.delay(0.5, function()
			if not screenGui.Parent then
				return
			end

			frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			frame.BackgroundTransparency = 0.85
		end)
	end

	local parent2 = v14

	if parent2 and parent2.Parent then
		local equalizerSoundEffect = Instance.new("EqualizerSoundEffect")
		equalizerSoundEffect.LowGain = 0
		equalizerSoundEffect.MidGain = 0
		equalizerSoundEffect.HighGain = 0
		equalizerSoundEffect.Parent = parent2
		v20 = equalizerSoundEffect
		TweenService:Create(
			equalizerSoundEffect,
			TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				HighGain = -20,
				MidGain = -8,
				LowGain = 2
			}
		):Play()
		local reverbSoundEffect = Instance.new("ReverbSoundEffect")
		reverbSoundEffect.DecayTime = 1.5
		reverbSoundEffect.Density = 1
		reverbSoundEffect.WetLevel = 0
		reverbSoundEffect.DryLevel = 0
		reverbSoundEffect.Parent = parent2
		v21 = reverbSoundEffect
		TweenService:Create(
			reverbSoundEffect,
			TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				DecayTime = 3,
				WetLevel = 6,
				DryLevel = -3
			}
		):Play()
		local pitchShiftSoundEffect = Instance.new("PitchShiftSoundEffect")
		pitchShiftSoundEffect.Octave = 1
		pitchShiftSoundEffect.Parent = parent2
		v22 = pitchShiftSoundEffect
		TweenService:Create(
			pitchShiftSoundEffect,
			TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Octave = 0.7
			}
		):Play()
	end
end

local function timeshiftEnd(duration: number)
	count += 1
	local v24 = count
	local v25 = v19
	local v26 = v20
	local v27 = v21
	local v28 = v22
	local v29 = v23

	if v25 then
		TweenService:Create(v25, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Saturation = 0,
			Contrast = 0,
			Brightness = 0
		}):Play()
	end

	if v26 then
		TweenService:Create(v26, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			HighGain = 0,
			MidGain = 0,
			LowGain = 0
		}):Play()
	end

	if v27 then
		TweenService:Create(v27, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			WetLevel = 0,
			DryLevel = 0
		}):Play()
	end

	if v28 then
		TweenService:Create(v28, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Octave = 1
		}):Play()
	end

	if v29 and v29:FindFirstChildOfClass("Frame") then
		TweenService:Create(
			v29:FindFirstChildOfClass("Frame"),
			TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				BackgroundTransparency = 1
			}
		):Play()
	end

	task.delay(duration + 0.05, function()
		if v24 ~= count then
			return
		end

		destroyTimeshiftEffects()
	end)
end

local function showFakeAnnouncement(message: string)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local notificationFrame = ReplicatedStorage:FindFirstChild("NotificationFrame")

	if not notificationFrame then
		return
	end

	local clone = notificationFrame:Clone()
	local avatar = clone:FindFirstChild("Avatar")

	if avatar and avatar:IsA("ImageLabel") then
		local success, result = pcall(function()
			return Players:GetUserThumbnailAsync(586487285, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)

		if success and result then
			avatar.Image = result
		end
	end

	local text = clone:FindFirstChild("Text")

	if text and text:IsA("TextLabel") then
		text.RichText = true
		text.Text = "<font color=\"rgb(255,120,200)\"><b>FoeCakes</b></font> : " .. message
	end

	local v24 = {}
	local v25 = {}

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("UIStroke") then
			table.insert(v24, {
				obj = descendant,
				prop = "Transparency"
			})
		elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			table.insert(v24, {
				obj = descendant,
				prop = "TextTransparency"
			})

			if descendant.BackgroundTransparency < 1 then
				table.insert(v24, {
					obj = descendant,
					prop = "BackgroundTransparency"
				})
			end
		elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
			table.insert(v24, {
				obj = descendant,
				prop = "ImageTransparency"
			})

			if descendant.BackgroundTransparency < 1 then
				table.insert(v24, {
					obj = descendant,
					prop = "BackgroundTransparency"
				})
			end
		elseif descendant:IsA("Frame") and descendant.BackgroundTransparency < 1 then
			table.insert(v24, {
				obj = descendant,
				prop = "BackgroundTransparency"
			})
		end

		if descendant:IsA("UIGradient") then
			table.insert(v25, {
				obj = descendant,
				original = descendant.Transparency
			})
		end
	end

	if clone:IsA("Frame") and clone.BackgroundTransparency < 1 then
		table.insert(v24, {
			obj = clone,
			prop = "BackgroundTransparency"
		})
	end

	local v26 = {}

	for i, v27 in ipairs(v24) do
		v26[i] = v27.obj[v27.prop]
		v27.obj[v27.prop] = 1
	end

	local numberSequence = NumberSequence.new(1)

	for _, v27 in ipairs(v25) do
		v27.obj.Transparency = numberSequence
	end

	local adminAnnounce = playerGui:FindFirstChild("AdminAnnounce")

	if adminAnnounce and adminAnnounce:IsA("ScreenGui") then
		adminAnnounce.DisplayOrder = 1000001
	end

	local mainFrame = adminAnnounce and adminAnnounce:FindFirstChild("MainFrame")
	local screenGui = nil

	if mainFrame then
		clone.Parent = mainFrame
	else
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "FakeAnnounce"
		screenGui.IgnoreGuiInset = true
		screenGui.DisplayOrder = 1000001
		screenGui.Parent = playerGui
		clone.Parent = screenGui
	end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://98797174600699"
	sound.Volume = 0.4
	sound.Parent = playerGui
	sound:Play()
	local Debris2 = game:GetService("Debris")
	Debris2:AddItem(sound, 5)
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for i, v27 in ipairs(v24) do
		TweenService:Create(v27.obj, tweenInfo, {
			[v27.prop] = v26[i]
		}):Play()
	end

	for _, v27 in ipairs(v25) do
		v27.obj.Transparency = v27.original
	end

	task.delay(3.5, function()
		local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

		for _, v27 in ipairs(v24) do
			TweenService:Create(v27.obj, tweenInfo2, {
				[v27.prop] = 1
			}):Play()
		end

		for _, v27 in ipairs(v25) do
			v27.obj.Transparency = numberSequence
		end

		task.delay(0.5, function()
			if clone and clone.Parent then
				clone:Destroy()
			end

			if screenGui and screenGui.Parent then
				screenGui:Destroy()
			end
		end)
	end)
end

local function handlePlaySound(data)
	local id = tostring(data.id or "")

	if id == "" then
		return
	end

	local vol = tonumber(data.vol) or 1
	local pitch = tonumber(data.pitch) or 1
	local global = data.global == true
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = vol
	sound.PlaybackSpeed = pitch

	if global then
		sound.Parent = Players.LocalPlayer or workspace
	else
		local x = tonumber(data.x) or 0
		local y = tonumber(data.y) or 0
		local z = tonumber(data.z) or 0
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.Transparency = 1
		part.Position = Vector3.new(x, y, z)
		part.Parent = getClientDebrisFolder()
		Debris:AddItem(part, 12)
		local minDist = tonumber(data.minDist)
		local maxDist = tonumber(data.maxDist)

		if minDist then
			sound.RollOffMinDistance = minDist
		end

		if maxDist then
			sound.RollOffMaxDistance = maxDist
		end

		sound.Parent = part
	end

	v15[id] = sound
	sound:Play()
	Debris:AddItem(sound, 20)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function teardownFxListener()
	if onClientEventConnection2 then
		onClientEventConnection2:Disconnect()
		onClientEventConnection2 = nil
	end

	if v12 then
		v12:Stop()
		v12 = nil
	end

	restoreTaggedUI() -- equivalent call inferred; original call site unknown
	v13 = nil
	identity = CFrame.identity
	identity2 = CFrame.identity
	RunService:UnbindFromRenderStep("FoeCakesCinematicLock")
end

local v24 = {
	[7] = 0.6,
	[8] = 0.48,
	[9] = 0.36,
	[10] = 0.25
}

local function setupFxListener()
	teardownFxListener() -- equivalent call inferred; original call site unknown
	v12 = camerashaker.new(Enum.RenderPriority.Camera.Value, function(cframe: CFrame)
		identity = cframe
	end)
	v12:Start()
	RunService:BindToRenderStep("FoeCakesCinematicLock", Enum.RenderPriority.Camera.Value + 1, function()
		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			return
		end

		local v25 = v13

		if v25 then
			currentCamera.CFrame = v25 * identity2 * identity
		else
			currentCamera.CFrame *= identity
		end
	end)
	onClientEventConnection2 = adminAbuseBossFx.OnClientEvent:Connect(function(value, p)
		if type(value) ~= "string" then
			return
		end

		local v25 = type(p) ~= "table" and {} or p

		local function num(p2: string, p3: number)
			local v26 = v25[p2]

			if type(v26) == "number" then
				return v26
			end

			return p3
		end

		if value == "SetCamera" then
			local type2 = v25.type
			local currentCamera = workspace.CurrentCamera

			if not currentCamera then
				return
			end

			if type2 == "Reset" then
				restoreTaggedUI() -- equivalent call inferred; original call site unknown
				v13 = nil
				currentCamera.CameraType = Enum.CameraType.Custom
				local character = Players.LocalPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					currentCamera.CameraSubject = humanoid
				end
			else
				local cf = v25.cf

				if typeof(cf) ~= "CFrame" then
					return
				end

				hideTaggedUI()
				currentCamera.CameraSubject = nil
				currentCamera.CameraType = Enum.CameraType.Scriptable

				if type2 == "Fixed" then
					v13 = cf
				elseif type2 == "Tween" then
					v13 = nil
					local dur = v25.dur
					TweenService:Create(
						currentCamera,
						TweenInfo.new(
							type(dur) ~= "number" and 2 or dur,
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.InOut
						),
						{
							CFrame = cf
						}
					):Play()
				end
			end
		elseif value == "ScreenShake" then
			local intensity = v25.intensity
			local v26 = type(intensity) ~= "number" and 0.3 or intensity
			local duration = v25.duration
			local v27 = type(duration) ~= "number" and 0.5 or duration
			local radius = v25.radius

			if type(radius) == "number" then
				local localPlayer = Players.LocalPlayer
				local character = localPlayer and localPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					local position = humanoidRootPart.Position
					local x = v25.x
					local v28 = type(x) ~= "number" and 0 or x
					local y = v25.y
					local v29 = type(y) ~= "number" and 0 or y
					local z = v25.z

					if radius < (position - Vector3.new(v28, v29, type(z) ~= "number" and 0 or z)).Magnitude then
						return
					end
				end
			end

			if v12 then
				local v28 = v24[v17] or 1
				v12:ShakeOnce(v26 * v28, 8, 0.05, v27 * 0.85)
			end
		elseif value == "PhaseChange" then
			local phase = v25.phase
			local v26 = math.floor((math.clamp(type(phase) ~= "number" and 1 or phase, 1, 10)))
			v17 = v26
			local soundtrackIndex = getSoundtrackIndex(v26)

			if v14 and soundtrackIndex ~= v18 then
				startSoundtrack(v26)
			end

			if v4 then
				v4.Text = "PHASE " .. tostring(v26)
				v4.TextColor3 = Color3.fromRGB(255, 80, 80)
				task.delay(0.5, function()
					if v4 then
						TweenService:Create(v4, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							TextColor3 = Color3.new(1, 1, 1)
						}):Play()
					end
				end)
			end

			if v26 >= 8 then
				applyPhase8BossBarStyle()
			elseif v26 >= 4 then
				applyPhase4BossBarStyle()
			end
		elseif value == "DebrisWarn" then
			local x = v25.x
			local v26 = type(x) ~= "number" and 0 or x
			local y = v25.y
			local v27 = type(y) ~= "number" and 0 or y
			local z = v25.z
			local vector2 = Vector3.new(v26, v27, type(z) ~= "number" and 0 or z)
			local radius = v25.radius
			local v28 = type(radius) ~= "number" and 6 or radius
			local t = v25.t
			local v29 = type(t) ~= "number" and 2.5 or t
			local part = Instance.new("Part")
			part.Name = "FoeCakesDebrisWarnFx"
			part.Shape = Enum.PartType.Cylinder
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(255, 55, 55)
			part.Transparency = 0.3
			part.Size = Vector3.new(0.05, v28 * 2, v28 * 2)
			part.CFrame = CFrame.fromMatrix(
				vector2 + createVector(0, 2, 0),
				createVector(0, 1, 0),
				createVector(0, 0, -1)
			)
			part.Parent = getClientDebrisFolder()
			local tween = TweenService:Create(
				part,
				TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					Size = Vector3.new(2, v28 * 2, v28 * 2)
				}
			)
			tween:Play()
			tween.Completed:Connect(function()
				tween:Destroy()
			end)
			local tween2 = TweenService:Create(
				part,
				TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{
					Transparency = 0.75
				}
			)
			task.delay(0.15, function()
				if part.Parent then
					tween2:Play()
				end
			end)
			task.delay(math.max(0, v29 - 0.2), function()
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
						Size = Vector3.new(0.05, v28 * 2, v28 * 2)
					}
				)
				tween3.Completed:Once(function()
					tween3:Destroy()

					if part.Parent then
						part:Destroy()
					end
				end)
				tween3:Play()
			end)
		elseif value == "DebrisLand" then
			local x = v25.x
			local v26 = type(x) ~= "number" and 0 or x
			local y = v25.y
			local v27 = type(y) ~= "number" and 0 or y
			local z = v25.z
			local vector2 = Vector3.new(v26, v27, type(z) ~= "number" and 0 or z)
			local part = Instance.new("Part")
			part.Name = "FoeCakesDebrisLandFx"
			part.Shape = Enum.PartType.Cylinder
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(255, 190, 80)
			part.Transparency = 0.15
			part.Size = createVector(1, 1, 1)
			part.CFrame = CFrame.fromMatrix(
				vector2 + createVector(0, 0.5, 0),
				createVector(0, 1, 0),
				createVector(0, 0, -1)
			)
			part.Parent = getClientDebrisFolder()
			local tween = TweenService:Create(
				part,
				TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Transparency = 1,
					Size = createVector(1, 22, 22)
				}
			)
			tween.Completed:Once(function()
				tween:Destroy()

				if part.Parent then
					part:Destroy()
				end
			end)
			tween:Play()
		elseif value == "DustPuff" then
			local x = v25.x
			local v26 = type(x) ~= "number" and 0 or x
			local y = v25.y
			local v27 = type(y) ~= "number" and 0 or y
			local z = v25.z
			local vector2 = Vector3.new(v26, v27, type(z) ~= "number" and 0 or z)
			local part = Instance.new("Part")
			part.Name = "FoeCakesDustPuffFx"
			part.Shape = Enum.PartType.Cylinder
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(210, 185, 155)
			part.Transparency = 0.5
			part.Size = createVector(0.4, 0.4, 0.4)
			part.CFrame = CFrame.fromMatrix(
				vector2 + createVector(0, 0.2, 0),
				createVector(0, 1, 0),
				createVector(0, 0, -1)
			)
			part.Parent = getClientDebrisFolder()
			local tween = TweenService:Create(
				part,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Transparency = 1,
					Size = createVector(0.4, 6, 6)
				}
			)
			tween.Completed:Once(function()
				tween:Destroy()

				if part.Parent then
					part:Destroy()
				end
			end)
			tween:Play()
		elseif value == "ZoneWarn" then
			local x = v25.x
			local v26 = type(x) ~= "number" and 0 or x
			local y = v25.y
			local v27 = type(y) ~= "number" and 0 or y
			local z = v25.z
			local vector2 = Vector3.new(v26, v27, type(z) ~= "number" and 0 or z)
			local hx = v25.hx
			local v28 = type(hx) ~= "number" and 9 or hx
			local hz = v25.hz
			local v29 = type(hz) ~= "number" and 9 or hz
			local t = v25.t
			local v30 = type(t) ~= "number" and 1.4 or t
			local part = Instance.new("Part")
			part.Name = "FoeCakesZoneWarnFx"
			part.Shape = Enum.PartType.Cylinder
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(220, 80, 80)
			part.Transparency = 0.3
			part.Size = Vector3.new(0.05, v28 * 2, v29 * 2)
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
					Size = Vector3.new(3, v28 * 2, v29 * 2)
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
			task.delay(math.max(0, v30 - 0.2), function()
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
						Size = Vector3.new(0.05, v28 * 2, v29 * 2)
					}
				)
				tween3.Completed:Once(function()
					tween3:Destroy()

					if part.Parent then
						part:Destroy()
					end
				end)
				tween3:Play()
			end)
		elseif value == "ZoneHit" then
			local x = v25.x
			local v26 = type(x) ~= "number" and 0 or x
			local y = v25.y
			local v27 = type(y) ~= "number" and 0 or y
			local z = v25.z
			local vector2 = Vector3.new(v26, v27, type(z) ~= "number" and 0 or z)
			local hx = v25.hx
			local v28 = type(hx) ~= "number" and 9 or hx
			local hz = v25.hz
			local v29 = type(hz) ~= "number" and 9 or hz
			local part = Instance.new("Part")
			part.Name = "FoeCakesZoneJetFx"
			part.Shape = Enum.PartType.Cylinder
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(255, 80, 80)
			part.Transparency = 0.15
			part.Size = Vector3.new(2, v28 * 1.6, v29 * 1.6)
			part.CFrame = CFrame.fromMatrix(
				vector2 - createVector(0, 4, 0),
				createVector(0, 1, 0),
				createVector(0, 0, -1)
			)
			part.Parent = getClientDebrisFolder()
			local tween = TweenService:Create(
				part,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Size = Vector3.new(120, v28 * 1.9, v29 * 1.9),
					CFrame = CFrame.fromMatrix(
						vector2 + createVector(0, 56, 0),
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
						Size = createVector(120, 0.1, 0.1)
					}
				)
				tween2.Completed:Once(function()
					tween2:Destroy()

					if part.Parent then
						part:Destroy()
					end
				end)
				tween2:Play()
			end)
		elseif value == "EyeWarn" then
			local x = v25.x
			local v26 = type(x) ~= "number" and 0 or x
			local y = v25.y
			local v27 = type(y) ~= "number" and 0 or y
			local z = v25.z
			local vector2 = Vector3.new(v26, v27, type(z) ~= "number" and 0 or z)
			local radius = v25.radius
			local v28 = type(radius) ~= "number" and 5 or radius
			local t = v25.t
			local v29 = type(t) ~= "number" and 1.5 or t
			local part = Instance.new("Part")
			part.Name = "FoeCakesEyeWarnFx"
			part.Shape = Enum.PartType.Cylinder
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(200, 200, 255)
			part.Transparency = 0.3
			part.Size = Vector3.new(0.05, v28 * 2, v28 * 2)
			part.CFrame = CFrame.fromMatrix(
				vector2 + createVector(0, 2, 0),
				createVector(0, 1, 0),
				createVector(0, 0, -1)
			)
			part.Parent = getClientDebrisFolder()
			local tween = TweenService:Create(
				part,
				TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					Size = Vector3.new(2, v28 * 2, v28 * 2)
				}
			)
			tween:Play()
			tween.Completed:Connect(function()
				tween:Destroy()
			end)
			local tween2 = TweenService:Create(
				part,
				TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{
					Transparency = 0.75
				}
			)
			task.delay(0.15, function()
				if part.Parent then
					tween2:Play()
				end
			end)
			task.delay(math.max(0, v29 - 0.2), function()
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
						Size = Vector3.new(0.05, v28 * 2, v28 * 2)
					}
				)
				tween3.Completed:Once(function()
					tween3:Destroy()

					if part.Parent then
						part:Destroy()
					end
				end)
				tween3:Play()
			end)
		elseif value == "EyeBeam" then
			local fx = v25.fx
			local v26 = type(fx) ~= "number" and 0 or fx
			local fy = v25.fy
			local v27 = type(fy) ~= "number" and 0 or fy
			local fz = v25.fz
			local vector2 = Vector3.new(v26, v27, type(fz) ~= "number" and 0 or fz)
			local tx = v25.tx
			local v28 = type(tx) ~= "number" and 0 or tx
			local ty = v25.ty
			local v29 = type(ty) ~= "number" and 0 or ty
			local tz = v25.tz
			local vector3 = Vector3.new(v28, v29, type(tz) ~= "number" and 0 or tz)
			local v30 = (vector2 + vector3) * 0.5
			local magnitude = (vector3 - vector2).Magnitude

			if magnitude < 0.1 then
				return
			end

			local unit = (vector3 - vector2).Unit
			local v31 = math.abs((unit:Dot(createVector(0, 1, 0)))) < 0.99 and createVector(0, 1, 0) or createVector(
				0,
				0,
				1
			)
			local part = Instance.new("Part")
			part.Name = "FoeCakesEyeBeamFx"
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(220, 220, 255)
			part.Transparency = 0.1
			part.Size = Vector3.new(magnitude, 1.5, 1.5)
			part.CFrame = CFrame.fromMatrix(v30, unit, v31)
			part.Parent = getClientDebrisFolder()
			local tween = TweenService:Create(
				part,
				TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					Transparency = 1,
					Size = Vector3.new(magnitude, 0.05, 0.05)
				}
			)
			tween.Completed:Once(function()
				tween:Destroy()

				if part.Parent then
					part:Destroy()
				end
			end)
			tween:Play()
		elseif value == "EyeTargetStart" then
			local localPlayer = Players.LocalPlayer
			local character = localPlayer and localPlayer.Character

			if not character then
				return
			end

			local eyeTargetHL = character:FindFirstChild("EyeTargetHL")

			if eyeTargetHL then
				eyeTargetHL:Destroy()
			end

			local highlight = Instance.new("Highlight")
			highlight.Name = "EyeTargetHL"
			highlight.Adornee = character
			highlight.FillColor = Color3.fromRGB(255, 30, 30)
			highlight.FillTransparency = 0.5
			highlight.OutlineColor = Color3.fromRGB(255, 80, 80)
			highlight.OutlineTransparency = 0
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.Parent = character
		elseif value == "EyeTargetFire" then
			local localPlayer = Players.LocalPlayer
			local character = localPlayer and localPlayer.Character
			local eyeTargetHL = character and character:FindFirstChild("EyeTargetHL")

			if not eyeTargetHL then
				return
			end

			eyeTargetHL.FillTransparency = 0
			eyeTargetHL.OutlineTransparency = 0
		elseif value == "EyeTargetEnd" then
			local localPlayer = Players.LocalPlayer
			local character = localPlayer and localPlayer.Character
			local eyeTargetHL = character and character:FindFirstChild("EyeTargetHL")

			if not eyeTargetHL then
				return
			end

			local tween = TweenService:Create(
				eyeTargetHL,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					FillTransparency = 1,
					OutlineTransparency = 1
				}
			)
			tween:Play()
			tween.Completed:Once(function()
				tween:Destroy()

				if eyeTargetHL and eyeTargetHL.Parent then
					eyeTargetHL:Destroy()
				end
			end)

			if v16 and v16.Parent then
				v16:Stop()
				v16:Destroy()
				v16 = nil
			end
		elseif value == "EyeBeeping" then
			if v16 and v16.Parent then
				v16:Stop()
				v16:Destroy()
				v16 = nil
			end

			local eyeOfUnionBeeping = ReplicatedStorage:FindFirstChild("EyeOfUnionBeeping")

			if eyeOfUnionBeeping and eyeOfUnionBeeping:IsA("Sound") then
				local clone = eyeOfUnionBeeping:Clone()
				clone.Parent = Players.LocalPlayer
				clone:Play()
				v16 = clone
			end
		elseif value == "EyePreshot" then
			if v16 and v16.Parent then
				v16:Stop()
				v16:Destroy()
				v16 = nil
			end

			local eyeOfUnionPreshot = ReplicatedStorage:FindFirstChild("EyeOfUnionPreshot")

			if eyeOfUnionPreshot and eyeOfUnionPreshot:IsA("Sound") then
				local clone = eyeOfUnionPreshot:Clone()
				clone.Parent = Players.LocalPlayer
				clone:Play()
				Debris:AddItem(clone, 5)
			end
		elseif value == "FadeToBlack" then
			local dur = v25.dur
			local v26 = type(dur) ~= "number" and 0.5 or dur
			task.spawn(function()
				local localPlayer = Players.LocalPlayer
				local playerGui = localPlayer and localPlayer:WaitForChild("PlayerGui")

				if not playerGui then
					return
				end

				local parent2 = playerGui:FindFirstChild("FoeCakesCutsceneBlack")

				if not (parent2 and parent2:IsA("ScreenGui")) then
					parent2 = Instance.new("ScreenGui")
					parent2.Name = "FoeCakesCutsceneBlack"
					parent2.ResetOnSpawn = false
					parent2.IgnoreGuiInset = true
					parent2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
					local frame = Instance.new("Frame")
					frame.Name = "Black"
					frame.Size = UDim2.fromScale(1, 1)
					frame.BackgroundColor3 = Color3.new(0, 0, 0)
					frame.BackgroundTransparency = 1
					frame.BorderSizePixel = 0
					frame.ZIndex = 100
					frame.Parent = parent2
					parent2.Parent = playerGui
				end

				local black = parent2:FindFirstChild("Black")

				if not black then
					return
				end

				local tween = TweenService:Create(black, TweenInfo.new(v26, Enum.EasingStyle.Linear), {
					BackgroundTransparency = 0
				})
				tween:Play()
				tween.Completed:Wait()
				tween:Destroy()
			end)
		elseif value == "OpeningCutscene" then
			task.spawn(function()
				FoeCakesCutscenes.playOpening(v25)
				startSoundtrack()
				startLaughLoop() -- equivalent call inferred; original call site unknown
			end)
		elseif value == "EndingCutscene" then
			flag2 = false
			stopSoundtrack()
			task.spawn(function()
				FoeCakesCutscenes.playEnding(v25, function()
					FoeCakesBossRoom.Stop()
				end)
			end)
		elseif value == "FinalCutscene" then
			flag2 = false
			task.spawn(function()
				local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

				if v then
					v.Enabled = false
				end

				local screenGui = Instance.new("ScreenGui")
				screenGui.Name = "FoeCakesBossEndTransition"
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
				TweenService:Create(frame, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					BackgroundTransparency = 0
				}):Play()
				task.delay(2, function()
					stopSoundtrack()
				end)
				Debris:AddItem(screenGui, 10)
			end)
		elseif value == "CloudWarn" then
			local x = v25.x
			local v26 = type(x) ~= "number" and 0 or x
			local y = v25.y
			local v27 = type(y) ~= "number" and 0 or y
			local z = v25.z
			local vector2 = Vector3.new(v26, v27, type(z) ~= "number" and 0 or z)
			local radius = v25.radius
			local v28 = type(radius) ~= "number" and 5 or radius
			local t = v25.t
			local v29 = type(t) ~= "number" and 2 or t
			local part = Instance.new("Part")
			part.Name = "FoeCakesCloudWarnFx"
			part.Shape = Enum.PartType.Cylinder
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(255, 55, 55)
			part.Transparency = 0.3
			part.Size = Vector3.new(0.05, v28 * 2, v28 * 2)
			part.CFrame = CFrame.fromMatrix(
				vector2 + createVector(0, 2, 0),
				createVector(0, 1, 0),
				createVector(0, 0, -1)
			)
			part.Parent = getClientDebrisFolder()
			local tween = TweenService:Create(
				part,
				TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					Size = Vector3.new(2, v28 * 2, v28 * 2)
				}
			)
			tween:Play()
			tween.Completed:Connect(function()
				tween:Destroy()
			end)
			local tween2 = TweenService:Create(
				part,
				TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{
					Transparency = 0.75
				}
			)
			task.delay(0.15, function()
				if part.Parent then
					tween2:Play()
				end
			end)
			task.delay(math.max(0, v29 - 0.2), function()
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
						Size = Vector3.new(0.05, v28 * 2, v28 * 2)
					}
				)
				tween3.Completed:Once(function()
					tween3:Destroy()

					if part.Parent then
						part:Destroy()
					end
				end)
				tween3:Play()
			end)
		elseif value == "CloudStrike" then
			local fx = v25.fx
			local v26 = type(fx) ~= "number" and 0 or fx
			local fy = v25.fy
			local v27 = type(fy) ~= "number" and 0 or fy
			local fz = v25.fz
			local vector2 = Vector3.new(v26, v27, type(fz) ~= "number" and 0 or fz)
			local tx = v25.tx
			local v28 = type(tx) ~= "number" and 0 or tx
			local ty = v25.ty
			local v29 = type(ty) ~= "number" and 0 or ty
			local tz = v25.tz
			local vector3 = Vector3.new(v28, v29, type(tz) ~= "number" and 0 or tz)
			local magnitude = (vector3 - vector2).Magnitude

			if magnitude < 0.1 then
				return
			end

			local clientDebrisFolder = getClientDebrisFolder() -- equivalent call inferred; original call site unknown
			local random = Random.new()
			local v30 = magnitude * 0.13
			local unit = (vector3 - vector2).Unit
			local unit2

			if math.abs((unit:Dot(createVector(1, 0, 0)))) < 0.99 then
				unit2 = unit:Cross(createVector(1, 0, 0)).Unit
			else
				unit2 = unit:Cross(createVector(0, 0, 1)).Unit
			end

			local unit3 = unit:Cross(unit2).Unit
			local v31 = { vector2 }

			for i = 1, 6 do
				local v32 = i / 7
				local lerped = vector2:Lerp(vector3, v32)
				local v33 = math.sin(v32 * 3.141592653589793)
				local v34 = random:NextNumber(-v30, v30) * v33
				local v35 = random:NextNumber(-v30 * 0.5, v30 * 0.5) * v33
				table.insert(v31, lerped + unit2 * v34 + unit3 * v35)
			end

			table.insert(v31, vector3)

			for i = 1, #v31 - 1 do
				local v32 = v31[i]
				local v33 = v31[i + 1]
				local magnitude2 = (v33 - v32).Magnitude

				if magnitude2 < 0.01 then
					continue
				end

				local unit4 = (v33 - v32).Unit
				local v34 = math.abs((unit4:Dot(createVector(0, 1, 0)))) < 0.99 and createVector(0, 1, 0) or createVector(
					0,
					0,
					1
				)
				local part = Instance.new("Part")
				part.Name = "FoeCakesCloudBoltFx"
				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.Material = Enum.Material.Neon
				part.Color = Color3.fromRGB(200, 220, 255)
				part.Transparency = 0.1
				part.Size = Vector3.new(magnitude2, 2.8, 2.8)
				part.CFrame = CFrame.fromMatrix((v32 + v33) * 0.5, unit4, v34)
				part.Parent = clientDebrisFolder
				local tween = TweenService:Create(
					part,
					TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Transparency = 1,
						Size = Vector3.new(magnitude2, 0.05, 0.05)
					}
				)
				tween.Completed:Once(function()
					tween:Destroy()

					if part.Parent then
						part:Destroy()
					end
				end)
				tween:Play()
			end

			local part = Instance.new("Part")
			part.Name = "FoeCakesCloudFlashFx"
			part.Shape = Enum.PartType.Cylinder
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(255, 240, 100)
			part.Transparency = 0.15
			part.Size = createVector(1, 1, 1)
			part.CFrame = CFrame.fromMatrix(
				vector3 + createVector(0, 0.5, 0),
				createVector(0, 1, 0),
				createVector(0, 0, -1)
			)
			part.Parent = clientDebrisFolder
			local tween = TweenService:Create(
				part,
				TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Transparency = 1,
					Size = createVector(1, 20, 20)
				}
			)
			tween.Completed:Once(function()
				tween:Destroy()

				if part.Parent then
					part:Destroy()
				end
			end)
			tween:Play()
			local part2 = Instance.new("Part")
			part2.Name = "FoeCakesCloudExplosionFx"
			part2.Shape = Enum.PartType.Ball
			part2.Anchored = true
			part2.CanCollide = false
			part2.CanQuery = false
			part2.Material = Enum.Material.Neon
			part2.Color = Color3.fromRGB(180, 210, 255)
			part2.Transparency = 0.15
			part2.Size = createVector(3, 3, 3)
			part2.CFrame = CFrame.new(vector3 + createVector(0, 1.5, 0))
			part2.Parent = clientDebrisFolder
			local tween2 = TweenService:Create(
				part2,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Transparency = 1,
					Size = createVector(16, 16, 16)
				}
			)
			tween2.Completed:Once(function()
				tween2:Destroy()

				if part2.Parent then
					part2:Destroy()
				end
			end)
			tween2:Play()
		elseif value == "PortalBeam" then
			local ox = v25.ox
			local v26 = type(ox) ~= "number" and 0 or ox
			local oy = v25.oy
			local v27 = type(oy) ~= "number" and 0 or oy
			local oz = v25.oz
			local vector2 = Vector3.new(v26, v27, type(oz) ~= "number" and 0 or oz)
			local tx = v25.tx
			local v28 = type(tx) ~= "number" and 0 or tx
			local ty = v25.ty
			local v29 = type(ty) ~= "number" and 0 or ty
			local tz = v25.tz
			local vector3 = Vector3.new(v28, v29, type(tz) ~= "number" and 0 or tz)
			local chargeSec = v25.chargeSec
			local v30 = type(chargeSec) ~= "number" and 0.8 or chargeSec
			local holdSec = v25.holdSec
			local v31 = type(holdSec) ~= "number" and 0.35 or holdSec
			local width = v25.width
			local v32 = type(width) ~= "number" and 0.6 or width
			local colorR = v25.colorR
			local v33 = type(colorR) ~= "number" and 0.667 or colorR
			local colorG = v25.colorG
			local v34 = type(colorG) ~= "number" and 0.431 or colorG
			local colorB = v25.colorB
			local color = Color3.new(v33, v34, type(colorB) ~= "number" and 1 or colorB)
			local v35 = vector3 - vector2
			local magnitude = v35.Magnitude

			if magnitude < 0.1 then
				return
			end

			local unit = v35.Unit
			local v36 = (vector2 + vector3) * 0.5
			local unit2

			if math.abs(unit.Y) < 0.9 then
				unit2 = (createVector(0, 1, 0)):Cross(unit).Unit
			else
				unit2 = (createVector(1, 0, 0)):Cross(unit).Unit
			end

			local cframe = CFrame.fromMatrix(vector2, unit2, unit, unit2:Cross(unit))
			local part = Instance.new("Part")
			part.Name = "GlassShatterBeamFx"
			part.Shape = Enum.PartType.Cylinder
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Material = Enum.Material.Neon
			part.Color = color
			part.Transparency = 0.5
			part.Size = Vector3.new(v32, 0.1, v32)
			part.CFrame = cframe
			part.Parent = getClientDebrisFolder()
			local tween = TweenService:Create(
				part,
				TweenInfo.new(v30, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Size = Vector3.new(v32, magnitude, v32),
					CFrame = CFrame.fromMatrix(v36, unit2, unit, unit2:Cross(unit)),
					Transparency = 0.35
				}
			)
			tween:Play()
			tween.Completed:Once(function()
				tween:Destroy()

				if not part.Parent then
					return
				end

				part.Color = Color3.new(1, 1, 1)
				part.Transparency = 0
				task.delay(v31, function()
					if not part.Parent then
						return
					end

					local tween2 = TweenService:Create(
						part,
						TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							Transparency = 1,
							Size = Vector3.new(0.05, magnitude, 0.05)
						}
					)
					tween2.Completed:Once(function()
						tween2:Destroy()

						if part.Parent then
							part:Destroy()
						end
					end)
					tween2:Play()
				end)
			end)
		elseif value == "TimeshiftBegin" then
			local fadeIn = v25.fadeIn
			local v26 = type(fadeIn) ~= "number" and 0.6 or fadeIn
			timeshiftBegin(math.max(0.05, v26))
		elseif value == "TimeshiftEnd" then
			local fadeOut = v25.fadeOut
			local v26 = type(fadeOut) ~= "number" and 0.5 or fadeOut
			timeshiftEnd(math.max(0.05, v26))
		elseif value == "PlaySound" then
			handlePlaySound(v25)
		elseif value == "StopSound" then
			local id = tostring(v25.id or "")
			local v26 = v15[id]

			if v26 and v26.Parent then
				v26:Stop()
				v26:Destroy()
			end

			v15[id] = nil
		elseif value == "StartSoundtrack" then
			if not v14 then
				local phase = v25.phase
				local v26

				if type(phase) == "number" then
					v26 = math.floor((math.clamp(phase, 1, 10)))
				else
					v26 = v17
				end

				startSoundtrack(v26)

				if not flag2 then
					startLaughLoop() -- equivalent call inferred; original call site unknown
				end
			end
		elseif value == "FoeCakesMsg" then
			local message = v25.message

			if type(message) == "string" then
				showFakeAnnouncement(message)
			end
		end
	end)
end

local FoeCakesBossRoom_2 = {}
FoeCakesBossRoom_2.IsAdminAbuse = true
FoeCakesBossRoom_2.NeedsDuration = false
FoeCakesBossRoom_2.SkipDoorTransition = false
FoeCakesBossRoom_2.Sounds = { (tostring(soundtracks[1])) }

function FoeCakesBossRoom_2.Fire()
	buildUi()
	onClientEventConnection = remotes:WaitForChild("AdminAbuseBossSync").OnClientEvent:Connect(onBossHpSync)
	setupFxListener()
end

function FoeCakesBossRoom_2.Stop()
	flag2 = false
	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character
	local eyeTargetHL = character and character:FindFirstChild("EyeTargetHL")

	if eyeTargetHL then
		eyeTargetHL:Destroy()
	end

	destroyTimeshiftEffects()
	stopSoundtrack()
	teardownFxListener() -- equivalent call inferred; original call site unknown
	FoeCakesCutscenes.stopAll()
	destroyUi()

	if v16 and v16.Parent then
		v16:Stop()
		v16:Destroy()
		v16 = nil
	end

	table.clear(v15)
end

FoeCakesBossRoom_2.Hidden = true
return FoeCakesBossRoom_2