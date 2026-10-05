local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local EventsConfig = require(ReplicatedStorage:WaitForChild("EventsConfig"))
local LightingSnapshot = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Events"):WaitForChild("LightingSnapshot"))
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local EggRainClient = {}
local eggRain = EventsConfig.EggRain

if not eggRain then
	return EggRainClient
end

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local templates = ReplicatedStorage:WaitForChild("Templates")
local flag = false
local v = {}
local v2 = nil

local function setPartsTransparency(part, transparency)
	if part:IsA("BasePart") then
		part.Transparency = transparency
		part.CanCollide = false
	end

	for _, descendant in ipairs(part:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Transparency = transparency
			descendant.CanCollide = false
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			descendant.Transparency = transparency
		end
	end
end

local function playSpawnSound(position)
	local sound = Instance.new("Sound")
	sound.SoundId = eggRain.SpawnSound
	sound.Volume = eggRain.SpawnSoundVolume or 1
	sound.RollOffMaxDistance = 150
	sound.RollOffMinDistance = 10
	local part = Instance.new("Part")
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CFrame = CFrame.new(position)
	part.Parent = workspace
	sound.Parent = part
	sound:Play()
	local Debris2 = game:GetService("Debris")
	Debris2:AddItem(part, 5)
end

local function hideEgg(eggId)
	v[eggId] = true

	for _, v3 in ipairs(CollectionService:GetTagged("EggRainEgg")) do
		if v3:GetAttribute("EggId") ~= eggId then
			continue
		end

		setPartsTransparency(v3, 1)
		break
	end

	if eggRain.CollectSound then
		local sound = Instance.new("Sound")
		sound.SoundId = eggRain.CollectSound
		sound.Volume = eggRain.CollectSoundVol or 1
		sound.Parent = playerGui
		sound:Play()
		Debris:AddItem(sound, 3)
	end
end

local announceDuration = eggRain.AnnounceDuration or 10
local announceFadeIn = eggRain.AnnounceFadeIn or 0.4
local announceFadeOut = eggRain.AnnounceFadeOut or 0.5
local notificationFrame = ReplicatedStorage:WaitForChild("NotificationFrame")

local function getGradients(folder)
	local result = {}

	for _, uIGradient in ipairs(folder:GetDescendants()) do
		if uIGradient:IsA("UIGradient") then
			table.insert(result, {
				obj = uIGradient,
				original = uIGradient.Transparency
			})
		end
	end

	return result
end

local function getAllVisuals(folder)
	local result = {}

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("UIStroke") then
			table.insert(result, {
				obj = descendant,
				prop = "Transparency"
			})
		elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			table.insert(result, {
				obj = descendant,
				prop = "TextTransparency"
			})

			if descendant.BackgroundTransparency < 1 then
				table.insert(result, {
					obj = descendant,
					prop = "BackgroundTransparency"
				})
			end
		elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
			table.insert(result, {
				obj = descendant,
				prop = "ImageTransparency"
			})

			if descendant.BackgroundTransparency < 1 then
				table.insert(result, {
					obj = descendant,
					prop = "BackgroundTransparency"
				})
			end
		elseif descendant:IsA("Frame") and descendant.BackgroundTransparency < 1 then
			table.insert(result, {
				obj = descendant,
				prop = "BackgroundTransparency"
			})
		end
	end

	if folder:IsA("Frame") and folder.BackgroundTransparency < 1 then
		table.insert(result, {
			obj = folder,
			prop = "BackgroundTransparency"
		})
	end

	return result
end

local function showAnnouncement(text)
	local adminAnnounce = playerGui:FindFirstChild("AdminAnnounce")
	local mainFrame = adminAnnounce and adminAnnounce:FindFirstChild("MainFrame")

	if not mainFrame then
		warn("[EggRainClient] AdminAnnounce/MainFrame introuvable dans PlayerGui")
		return
	end

	local clone = notificationFrame:Clone()
	clone.ZIndex = 100
	local text2 = clone:FindFirstChild("Text")

	if text2 then
		text2.ZIndex = 101
		text2.RichText = true
		text2.Text = "<font color=\"rgb(85,170,255)\"><b>" .. (eggRain.AdminUsername or "Admin") .. "</b></font> : " .. text
	end

	local avatar = clone:FindFirstChild("Avatar")

	if avatar and avatar:IsA("ImageLabel") then
		avatar.ZIndex = 101
	end

	local allVisuals = getAllVisuals(clone)
	local gradients = getGradients(clone)
	local v3 = {}

	for i, allVisual in ipairs(allVisuals) do
		v3[i] = allVisual.obj[allVisual.prop]
		allVisual.obj[allVisual.prop] = 1
	end

	local numberSequence = NumberSequence.new(1)

	for _, gradient in ipairs(gradients) do
		gradient.obj.Transparency = numberSequence
	end

	clone.Parent = mainFrame

	if eggRain.AnnounceSound then
		local sound = Instance.new("Sound")
		sound.SoundId = eggRain.AnnounceSound
		sound.Volume = eggRain.AnnounceSoundVol or 0.8
		sound.Parent = playerGui
		sound:Play()
		local Debris2 = game:GetService("Debris")
		Debris2:AddItem(sound, 5)
	end

	local tweenInfo = TweenInfo.new(announceFadeIn, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for i, allVisual in ipairs(allVisuals) do
		TweenService:Create(allVisual.obj, tweenInfo, {
			[allVisual.prop] = v3[i]
		}):Play()
	end

	for _, gradient in ipairs(gradients) do
		gradient.obj.Transparency = gradient.original
	end

	task.delay(announceDuration, function()
		local tweenInfo2 = TweenInfo.new(announceFadeOut, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

		for _, allVisual in ipairs(allVisuals) do
			TweenService:Create(allVisual.obj, tweenInfo2, {
				[allVisual.prop] = 1
			}):Play()
		end

		for _, gradient in ipairs(gradients) do
			gradient.obj.Transparency = numberSequence
		end

		task.delay(announceFadeOut, function()
			if clone and clone.Parent then
				clone:Destroy()
			end
		end)
	end)
end

local goldenEggNotifFrame = templates:WaitForChild("GoldenEggNotifFrame")

local function showGoldenNotif()
	local specialNotif = playerGui:FindFirstChild("SpecialNotif")
	local mainFrame = specialNotif and specialNotif:FindFirstChild("MainFrame")

	if not mainFrame then
		warn("[EggRainClient] SpecialNotif/MainFrame introuvable dans PlayerGui")
		return
	end

	local clone = goldenEggNotifFrame:Clone()
	local allVisuals = getAllVisuals(clone)
	local gradients = getGradients(clone)
	local v3 = {}

	for i, allVisual in ipairs(allVisuals) do
		v3[i] = allVisual.obj[allVisual.prop]
		allVisual.obj[allVisual.prop] = 1
	end

	local numberSequence = NumberSequence.new(1)

	for _, gradient in ipairs(gradients) do
		gradient.obj.Transparency = numberSequence
	end

	clone.Parent = mainFrame

	if eggRain.GoldenNotifSound then
		local sound = Instance.new("Sound")
		sound.SoundId = eggRain.GoldenNotifSound
		sound.Volume = eggRain.GoldenNotifSVol or 1
		sound.Parent = playerGui
		sound:Play()
		Debris:AddItem(sound, 5)
	end

	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for i, allVisual in ipairs(allVisuals) do
		TweenService:Create(allVisual.obj, tweenInfo, {
			[allVisual.prop] = v3[i]
		}):Play()
	end

	for _, gradient in ipairs(gradients) do
		gradient.obj.Transparency = gradient.original
	end

	task.delay(eggRain.GoldenNotifDuration or 3, function()
		local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

		for _, allVisual in ipairs(allVisuals) do
			TweenService:Create(allVisual.obj, tweenInfo2, {
				[allVisual.prop] = 1
			}):Play()
		end

		for _, gradient in ipairs(gradients) do
			gradient.obj.Transparency = numberSequence
		end

		task.delay(0.6, function()
			if clone and clone.Parent then
				clone:Destroy()
			end
		end)
	end)
end

local flag2 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function saveOriginalSky()
	if flag2 then
		return
	end

	flag2 = true
	LightingSnapshot.acquireShared()

	if not Lighting:FindFirstChild("EggRainCC") then
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "EggRainCC"
		colorCorrectionEffect.Parent = Lighting
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rgbTable(list)
	if type(list) == "table" and #list >= 3 then
		return Color3.fromRGB(list[1], list[2], list[3])
	end

	return Color3.fromRGB(255, 255, 255)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applySky(sky, instant)
	if not sky then
		return
	end

	saveOriginalSky() -- equivalent call inferred; original call site unknown

	if instant then
		if sky.Brightness then
			Lighting.Brightness = sky.Brightness
		end

		if sky.Ambient then
			local parent = Lighting
			local ambient = rgbTable(sky.Ambient) -- equivalent call inferred; original call site unknown
			parent.Ambient = ambient
		end

		if sky.OutdoorAmbient then
			local parent = Lighting
			local outdoorAmbient = rgbTable(sky.OutdoorAmbient) -- equivalent call inferred; original call site unknown
			parent.OutdoorAmbient = outdoorAmbient
		end

		if sky.FogEnd then
			Lighting.FogEnd = sky.FogEnd
		end

		if sky.FogColor then
			local parent = Lighting
			local fogColor = rgbTable(sky.FogColor) -- equivalent call inferred; original call site unknown
			parent.FogColor = fogColor
		end

		local eggRainCC = Lighting:FindFirstChild("EggRainCC")

		if eggRainCC then
			if sky.Saturation then
				eggRainCC.Saturation = sky.Saturation
			end

			if sky.ColorTint then
				local tintColor = rgbTable(sky.ColorTint) -- equivalent call inferred; original call site unknown
				eggRainCC.TintColor = tintColor
			end
		end
	else
		local skyTween = sky.SkyTween or 2
		local tweenInfo = TweenInfo.new(skyTween, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
		local v3 = {}

		if sky.Brightness then
			v3.Brightness = sky.Brightness
		end

		if sky.Ambient then
			local ambient = rgbTable(sky.Ambient) -- equivalent call inferred; original call site unknown
			v3.Ambient = ambient
		end

		if sky.OutdoorAmbient then
			local outdoorAmbient = rgbTable(sky.OutdoorAmbient) -- equivalent call inferred; original call site unknown
			v3.OutdoorAmbient = outdoorAmbient
		end

		if sky.FogEnd then
			v3.FogEnd = sky.FogEnd
		end

		if sky.FogColor then
			local fogColor = rgbTable(sky.FogColor) -- equivalent call inferred; original call site unknown
			v3.FogColor = fogColor
		end

		if next(v3) then
			TweenService:Create(Lighting, tweenInfo, v3):Play()
		end

		local eggRainCC = Lighting:FindFirstChild("EggRainCC")

		if eggRainCC then
			local v4 = {}

			if sky.Saturation then
				v4.Saturation = sky.Saturation
			end

			if sky.ColorTint then
				local tintColor = rgbTable(sky.ColorTint) -- equivalent call inferred; original call site unknown
				v4.TintColor = tintColor
			end

			if next(v4) then
				TweenService:Create(eggRainCC, tweenInfo, v4):Play()
			end
		end
	end
end

local function restoreSky()
	if not flag2 then
		return
	end

	flag2 = false
	local skyRestoreDuration = eggRain.SkyRestoreDuration or 3
	LightingSnapshot.releaseShared(skyRestoreDuration)
	local tweenInfo = TweenInfo.new(skyRestoreDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local eggRainCC = Lighting:FindFirstChild("EggRainCC")

	if eggRainCC then
		TweenService:Create(eggRainCC, tweenInfo, {
			Saturation = 0,
			TintColor = Color3.fromRGB(255, 255, 255)
		}):Play()
		task.delay(skyRestoreDuration + 0.5, function()
			if eggRainCC and eggRainCC.Parent then
				eggRainCC:Destroy()
			end
		end)
	end
end

local renderSteppedConnection = nil
local v3 = 0
local v4 = 0
local thread = nil

local function startShake(value)
	v4 = value or 0

	if v4 <= 0 then
		return
	end

	if thread then
		task.cancel(thread)
		thread = nil
	end

	local shakeFadeIn = eggRain.ShakeFadeIn or 0.5
	task.spawn(function()
		local lastTime = tick()

		while v3 < v4 and tick() - lastTime < shakeFadeIn do
			local v5 = math.min(1, (tick() - lastTime) / shakeFadeIn)
			v3 = v4 * v5
			task.wait()
		end

		v3 = v4
	end)

	if renderSteppedConnection then
		return
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoid and v3 > 0 then
			humanoid.CameraOffset = Vector3.new(
				(math.random() - 0.5) * 2 * v3,
				(math.random() - 0.5) * 2 * v3,
				(math.random() - 0.5) * 2 * v3
			)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopShake()
	v4 = 0
	local shakeFadeOut = eggRain.ShakeFadeOut or 0.3
	thread = task.spawn(function()
		local v5 = v3
		local lastTime = tick()

		while v3 > 0 and tick() - lastTime < shakeFadeOut do
			v3 = v5 * (1 - math.min(1, (tick() - lastTime) / shakeFadeOut))
			task.wait()
		end

		v3 = 0
		thread = nil

		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end

		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.CameraOffset = createVector(0, 0, 0)
		end
	end)
end

local function showCountdown(p)
	local number = p.number
	local text = p.text or tostring(number)
	local v5 = number == 0
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "EggRainCountdown"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 110
	screenGui.Parent = playerGui
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(0.6, 0, 0.2, 0)
	textLabel.Position = UDim2.new(0.5, 0, 0.2, 0)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextScaled = false
	textLabel.TextSize = eggRain.CountdownTextSize or 120
	textLabel.Font = Enum.Font.GothamBlack
	local countdownColor = eggRain.CountdownColor

	if countdownColor and type(countdownColor) == "table" then
		textLabel.TextColor3 = Color3.fromRGB(countdownColor[1], countdownColor[2], countdownColor[3])
	else
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	end

	textLabel.TextStrokeTransparency = 0
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.TextTransparency = 1
	textLabel.Parent = screenGui
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Thickness = 4
	uIStroke.Color = Color3.fromRGB(0, 0, 0)
	uIStroke.Transparency = 1
	uIStroke.Parent = textLabel

	if eggRain.CountdownSound then
		local sound = Instance.new("Sound")
		sound.SoundId = eggRain.CountdownSound
		sound.Volume = eggRain.CountdownSoundVol or 1
		sound.Parent = playerGui
		sound:Play()
		Debris:AddItem(sound, 3)
	end

	local countdownTextSize = eggRain.CountdownTextSize or 120

	if v5 then
		countdownTextSize = countdownTextSize * 1.5 or countdownTextSize
	end

	textLabel.TextTransparency = 0
	textLabel.TextStrokeTransparency = 0
	uIStroke.Transparency = 0
	textLabel.TextSize = 1
	TweenService:Create(textLabel, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		TextSize = countdownTextSize
	}):Play()
	task.delay(v5 and 0.7 or 0.55, function()
		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		TweenService:Create(textLabel, tweenInfo, {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}):Play()
		TweenService:Create(uIStroke, tweenInfo, {
			Transparency = 1
		}):Play()
		task.delay(0.4, function()
			if screenGui and screenGui.Parent then
				screenGui:Destroy()
			end
		end)
	end)
end

local child = ReplicatedStorage:FindFirstChild(eggRain.LightningFolder or "Ligtning")
local _ = workspace.CurrentCamera

local function onLightningEvent(p)
	if type(p) ~= "table" or not p.position then
		return
	end

	local position = p.position
	local hitParticles = child and child:FindFirstChild("HitParticles")

	if hitParticles then
		local clone = hitParticles:Clone()
		clone.Position = position
		clone.Parent = workspace
		Debris:AddItem(clone, 3)
		task.delay(0.3, function()
			if clone and clone.Parent then
				for _, descendant in ipairs(clone:GetDescendants()) do
					if descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
						descendant.Enabled = false
					end
				end
			end
		end)
	end

	local lightningSound = child and child:FindFirstChild("LightningSound")

	if lightningSound then
		local clone = lightningSound:Clone()
		clone.Volume = eggRain.LightningSoundVolume or 2
		clone.Parent = playerGui
		clone:Play()
		Debris:AddItem(clone, 5)
	end
end

local function onWaveEvent(data)
	if type(data) ~= "table" then
		return
	end

	local action = data.action

	if action == "start" then
		local wave = data.wave

		if wave then
			if wave.Sky then
				applySky(wave.Sky, data.instant)
			end

			if wave.Shake and wave.Shake > 0 then
				startShake(wave.Shake)
			end
		end
	elseif action == "stop" then
		stopShake() -- equivalent call inferred; original call site unknown
	elseif action == "end" then
		stopShake() -- equivalent call inferred; original call site unknown
		restoreSky()
	end
end

local flag3 = false
local endedConnection = nil

local function getPlaylist()
	if eggRain.MusicPlaylist and #eggRain.MusicPlaylist > 0 then
		return eggRain.MusicPlaylist
	end

	if eggRain.Music and eggRain.Music ~= "" then
		return { eggRain.Music }
	end

	return {}
end

local playTrack

playTrack = function(list, p: number)
	if not flag3 then
		return
	end

	local v5 = v2

	if not (v5 and v5.Parent) then
		return
	end

	v5.SoundId = list[p]
	v5.Looped = false
	v5.TimePosition = 0

	if endedConnection then
		endedConnection:Disconnect()
		endedConnection = nil
	end

	endedConnection = v5.Ended:Connect(function()
		if not flag3 then
			return
		end

		playTrack(list, p % #list + 1)
	end)
	task.spawn(function()
		if not v5.IsLoaded then
			v5.Loaded:Wait()
		end

		if flag3 then
			v5:Play()
		end
	end)
end

local function handleMusicEvent(p)
	if type(p) ~= "table" then
		return
	end

	if p.action == "start" then
		if v2 then
			return
		end

		local playlist = getPlaylist()

		if #playlist == 0 then
			return
		end

		local sound = Instance.new("Sound")
		sound.Name = "EggRainMusic"
		sound.Volume = eggRain.MusicVolume or 0.5
		sound.Looped = false
		sound:SetAttribute("IsEventSound", true)
		sound.Parent = SoundService
		v2 = sound
		flag3 = true
		playTrack(playlist, 1)
	elseif p.action == "stop" then
		flag3 = false

		if endedConnection then
			endedConnection:Disconnect()
			endedConnection = nil
		end

		if v2 then
			v2:Stop()
			v2:Destroy()
			v2 = nil
		end
	end
end

local function handleSyncEvent(data)
	if type(data) ~= "table" then
		return
	end

	if data.musicStartTime and data.musicStartTime > 0 then
		handleMusicEvent({
			action = "start",
			musicStartTime = data.musicStartTime
		})
	end

	if data.skyWaveIndex and data.skyWaveIndex > 0 then
		local waves = eggRain.Waves

		if waves and waves[data.skyWaveIndex] then
			local wave = waves[data.skyWaveIndex]
			local sky = wave.Sky and wave.Sky
			applySky(sky, true) -- equivalent call inferred; original call site unknown
		end
	end

	if data.shakeIntensity and data.shakeIntensity > 0 then
		startShake(data.shakeIntensity)
	end
end

local adminUserId = eggRain.AdminUserId or 0
local v5 = nil
local flag4 = false
local v6 = {}
local eggRainAdmin = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function fireAdmin(action, args)
	if not eggRainAdmin then
		return
	end

	eggRainAdmin:FireServer({
		action = action,
		args = args,
		allServers = flag4
	})
end

local function createAdminPanel()
	if localPlayer.UserId ~= adminUserId then
		return
	end

	local color = Color3.fromRGB(30, 30, 35)
	local color2 = Color3.fromRGB(40, 40, 48)
	local color3 = Color3.fromRGB(40, 160, 70)
	local color4 = Color3.fromRGB(180, 50, 50)
	local color5 = Color3.fromRGB(200, 130, 30)
	local color6 = Color3.fromRGB(50, 110, 190)
	local color7 = Color3.fromRGB(130, 60, 180)
	local color8 = Color3.fromRGB(230, 230, 235)
	local color9 = Color3.fromRGB(160, 160, 170)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "EggRainAdminPanel"
	screenGui.DisplayOrder = 200
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false
	screenGui.Parent = playerGui
	v5 = screenGui
	local frame = Instance.new("Frame")
	frame.Name = "Main"
	frame.Size = UDim2.new(0, 360, 0, 620)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = color
	frame.BackgroundTransparency = 0.02
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	local v7 = false
	local position = nil
	local position2 = nil
	local UserInputService = game:GetService("UserInputService")
	frame.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and input.Position.Y - frame.AbsolutePosition.Y <= 38 then
			v7 = true
			position = input.Position
			position2 = frame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if v7 and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local v8 = input.Position - position
			frame.Position = UDim2.new(
				position2.X.Scale,
				position2.X.Offset + v8.X,
				position2.Y.Scale,
				position2.Y.Offset + v8.Y
			)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			v7 = false
		end
	end)
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 10)
	uICorner.Parent = frame
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = Color3.fromRGB(80, 80, 100)
	uIStroke.Thickness = 1.5
	uIStroke.Parent = frame
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "Scroll"
	scrollingFrame.Size = UDim2.new(1, -16, 1, -50)
	scrollingFrame.Position = UDim2.new(0, 8, 0, 42)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.ScrollBarThickness = 4
	scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame.Parent = frame
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Padding = UDim.new(0, 6)
	uIListLayout.Parent = scrollingFrame
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingLeft = UDim.new(0, 4)
	uIPadding.PaddingRight = UDim.new(0, 4)
	uIPadding.PaddingTop = UDim.new(0, 4)
	uIPadding.Parent = scrollingFrame
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Title"
	textLabel.Size = UDim2.new(1, 0, 0, 38)
	textLabel.Position = UDim2.new(0, 0, 0, 0)
	textLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	textLabel.BackgroundTransparency = 0.1
	textLabel.BorderSizePixel = 0
	textLabel.Text = "EGG RAIN CONTROL"
	textLabel.TextColor3 = color8
	textLabel.TextSize = 16
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = frame
	local uICorner2 = Instance.new("UICorner")
	uICorner2.CornerRadius = UDim.new(0, 10)
	uICorner2.Parent = textLabel
	local textButton = Instance.new("TextButton")
	textButton.Name = "Close"
	textButton.Size = UDim2.new(0, 30, 0, 30)
	textButton.Position = UDim2.new(1, -34, 0, 4)
	textButton.BackgroundColor3 = color4
	textButton.BackgroundTransparency = 0.3
	textButton.Text = "X"
	textButton.TextColor3 = color8
	textButton.TextSize = 14
	textButton.Font = Enum.Font.GothamBold
	textButton.BorderSizePixel = 0
	textButton.Parent = frame
	local uICorner_2 = Instance.new("UICorner", textButton)
	uICorner_2.CornerRadius = UDim.new(0, 6)
	textButton.MouseButton1Click:Connect(function()
		screenGui.Enabled = false
	end)
	local count = 0

	local function sectionHeader(text)
		count += 1
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Size = UDim2.new(1, 0, 0, 22)
		textLabel2.BackgroundTransparency = 1
		textLabel2.Text = text
		textLabel2.TextColor3 = color9
		textLabel2.TextSize = 11
		textLabel2.Font = Enum.Font.GothamBold
		textLabel2.TextXAlignment = Enum.TextXAlignment.Left
		textLabel2.LayoutOrder = count
		textLabel2.Parent = scrollingFrame
		return textLabel2
	end

	local function makeBtn(text, backgroundColor, frame2, uDim)
		local textButton2 = Instance.new("TextButton")
		textButton2.Size = uDim or UDim2.new(0, 100, 0, 30)
		textButton2.BackgroundColor3 = backgroundColor
		textButton2.Text = text
		textButton2.TextColor3 = color8
		textButton2.TextSize = 12
		textButton2.Font = Enum.Font.GothamBold
		textButton2.BorderSizePixel = 0
		textButton2.AutoButtonColor = true
		textButton2.Parent = frame2
		local uICorner = Instance.new("UICorner", textButton2)
		uICorner.CornerRadius = UDim.new(0, 6)
		return textButton2
	end

	local function rowFrame(value)
		count += 1
		local frame2 = Instance.new("Frame")
		frame2.Size = UDim2.new(1, 0, 0, value or 34)
		frame2.BackgroundTransparency = 1
		frame2.LayoutOrder = count
		frame2.Parent = scrollingFrame
		return frame2
	end

	sectionHeader("STATUS")
	count += 1
	local frame2 = Instance.new("Frame")
	frame2.Size = UDim2.new(1, 0, 0, 42)
	frame2.BackgroundTransparency = 1
	frame2.LayoutOrder = count
	frame2.Parent = scrollingFrame
	frame2.BackgroundColor3 = color2
	frame2.BackgroundTransparency = 0.3
	local uICorner_3 = Instance.new("UICorner", frame2)
	uICorner_3.CornerRadius = UDim.new(0, 6)
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Size = UDim2.new(1, -12, 1, 0)
	textLabel2.Position = UDim2.new(0, 6, 0, 0)
	textLabel2.BackgroundTransparency = 1
	textLabel2.Text = "Wave: None | Music: OFF\nEggs: 0 | Lightning: OFF"
	textLabel2.TextColor3 = Color3.fromRGB(120, 220, 160)
	textLabel2.TextSize = 11
	textLabel2.Font = Enum.Font.GothamMedium
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	textLabel2.TextWrapped = true
	textLabel2.Parent = frame2
	v6.main = textLabel2
	sectionHeader("SCOPE")
	count += 1
	local frame3 = Instance.new("Frame")
	frame3.Size = UDim2.new(1, 0, 0, 30)
	frame3.BackgroundTransparency = 1
	frame3.LayoutOrder = count
	frame3.Parent = scrollingFrame
	local btn = makeBtn("This Server", color6, frame3, UDim2.new(0.48, 0, 1, 0))
	btn.Position = UDim2.new(0, 0, 0, 0)
	btn.BackgroundTransparency = 0
	local btn2 = makeBtn("All Servers", color2, frame3, UDim2.new(0.48, 0, 1, 0))
	btn2.Position = UDim2.new(0.52, 0, 0, 0)
	btn2.BackgroundTransparency = 0.3

	local function updateScopeVisual()
		if flag4 then
			btn.BackgroundColor3 = color2
			btn.BackgroundTransparency = 0.3
			btn2.BackgroundColor3 = color7
			btn2.BackgroundTransparency = 0
		else
			btn.BackgroundColor3 = color6
			btn.BackgroundTransparency = 0
			btn2.BackgroundColor3 = color2
			btn2.BackgroundTransparency = 0.3
		end
	end

	btn.MouseButton1Click:Connect(function()
		flag4 = false
		btn.BackgroundColor3 = color6
		btn.BackgroundTransparency = 0
		btn2.BackgroundColor3 = color2
		btn2.BackgroundTransparency = 0.3
	end)
	btn2.MouseButton1Click:Connect(function()
		flag4 = true
		btn.BackgroundColor3 = color2
		btn.BackgroundTransparency = 0.3
		btn2.BackgroundColor3 = color7
		btn2.BackgroundTransparency = 0
	end)
	sectionHeader("EVENT")
	count += 1
	local frame4 = Instance.new("Frame")
	frame4.Size = UDim2.new(1, 0, 0, 34)
	frame4.BackgroundTransparency = 1
	frame4.LayoutOrder = count
	frame4.Parent = scrollingFrame
	local btn3 = makeBtn("Full Auto", color3, frame4, UDim2.new(0.32, -2, 1, 0))
	btn3.Position = UDim2.new(0, 0, 0, 0)
	btn3.MouseButton1Click:Connect(function()
		if not eggRainAdmin then
			return
		end

		eggRainAdmin:FireServer({
			action = "fullAuto",
			args = nil,
			allServers = flag4
		})
	end)
	local btn4 = makeBtn("Stop All", color4, frame4, UDim2.new(0.32, -2, 1, 0))
	btn4.Position = UDim2.new(0.34, 0, 0, 0)
	btn4.MouseButton1Click:Connect(function()
		if not eggRainAdmin then
			return
		end

		eggRainAdmin:FireServer({
			action = "stopAll",
			args = nil,
			allServers = flag4
		})
	end)
	local btn5 = makeBtn("Cleanup", color5, frame4, UDim2.new(0.32, -2, 1, 0))
	btn5.Position = UDim2.new(0.68, 0, 0, 0)
	btn5.MouseButton1Click:Connect(function()
		if not eggRainAdmin then
			return
		end

		eggRainAdmin:FireServer({
			action = "cleanup",
			args = nil,
			allServers = flag4
		})
	end)
	sectionHeader("WAVES")
	count += 1
	local frame5 = Instance.new("Frame")
	frame5.Size = UDim2.new(1, 0, 0, 34)
	frame5.BackgroundTransparency = 1
	frame5.LayoutOrder = count
	frame5.Parent = scrollingFrame
	local waveIndex = 1
	local textButton2 = Instance.new("TextButton")
	textButton2.Size = UDim2.new(0.36, -2, 1, 0)
	textButton2.Position = UDim2.new(0, 0, 0, 0)
	textButton2.BackgroundColor3 = color2
	textButton2.Text = "Wave 1"
	textButton2.TextColor3 = color8
	textButton2.TextSize = 12
	textButton2.Font = Enum.Font.GothamBold
	textButton2.BorderSizePixel = 0
	textButton2.Parent = frame5
	local uICorner_4 = Instance.new("UICorner", textButton2)
	uICorner_4.CornerRadius = UDim.new(0, 6)
	textButton2.MouseButton1Click:Connect(function()
		local waves = eggRain.Waves or {}
		waveIndex = waveIndex % #waves + 1
		local wave = waves[waveIndex]
		textButton2.Text = "Wave " .. waveIndex .. (wave and " - " .. wave.Name or "")
	end)
	local btn6 = makeBtn("Start", color3, frame5, UDim2.new(0.3, -2, 1, 0))
	btn6.Position = UDim2.new(0.38, 0, 0, 0)
	btn6.MouseButton1Click:Connect(function()
		fireAdmin("startWave", {
			waveIndex = waveIndex
		}) -- equivalent call inferred; original call site unknown
	end)
	local btn7 = makeBtn("Stop", color4, frame5, UDim2.new(0.3, -2, 1, 0))
	btn7.Position = UDim2.new(0.7, 0, 0, 0)
	btn7.MouseButton1Click:Connect(function()
		if not eggRainAdmin then
			return
		end

		eggRainAdmin:FireServer({
			action = "stopWave",
			args = nil,
			allServers = flag4
		})
	end)
	sectionHeader("MANUAL SPAWN")
	count += 1
	local frame6 = Instance.new("Frame")
	frame6.Size = UDim2.new(1, 0, 0, 34)
	frame6.BackgroundTransparency = 1
	frame6.LayoutOrder = count
	frame6.Parent = scrollingFrame
	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.new(0.25, -2, 1, 0)
	textBox.Position = UDim2.new(0, 0, 0, 0)
	textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	textBox.Text = "10"
	textBox.PlaceholderText = "Qty"
	textBox.TextColor3 = color8
	textBox.TextSize = 13
	textBox.Font = Enum.Font.GothamMedium
	textBox.BorderSizePixel = 0
	textBox.ClearTextOnFocus = false
	textBox.Parent = frame6
	local uICorner_5 = Instance.new("UICorner", textBox)
	uICorner_5.CornerRadius = UDim.new(0, 6)
	local btn8 = makeBtn("Normal", color6, frame6, UDim2.new(0.36, -2, 1, 0))
	btn8.Position = UDim2.new(0.27, 0, 0, 0)
	btn8.MouseButton1Click:Connect(function()
		fireAdmin("spawnEggs", {
			count = tonumber(textBox.Text) or 10,
			golden = false
		}) -- equivalent call inferred; original call site unknown
	end)
	local btn9 = makeBtn("Golden", Color3.fromRGB(200, 170, 30), frame6, UDim2.new(0.36, -2, 1, 0))
	btn9.Position = UDim2.new(0.64, 0, 0, 0)
	btn9.MouseButton1Click:Connect(function()
		fireAdmin("spawnEggs", {
			count = tonumber(textBox.Text) or 10,
			golden = true
		}) -- equivalent call inferred; original call site unknown
	end)
	sectionHeader("MESSAGES")
	count += 1
	local frame7 = Instance.new("Frame")
	frame7.Size = UDim2.new(1, 0, 0, 34)
	frame7.BackgroundTransparency = 1
	frame7.LayoutOrder = count
	frame7.Parent = scrollingFrame
	local textBox2 = Instance.new("TextBox")
	textBox2.Size = UDim2.new(0.72, -2, 1, 0)
	textBox2.Position = UDim2.new(0, 0, 0, 0)
	textBox2.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	textBox2.Text = ""
	textBox2.PlaceholderText = "Admin message..."
	textBox2.TextColor3 = color8
	textBox2.TextSize = 12
	textBox2.Font = Enum.Font.GothamMedium
	textBox2.BorderSizePixel = 0
	textBox2.ClearTextOnFocus = false
	textBox2.Parent = frame7
	local uICorner_6 = Instance.new("UICorner", textBox2)
	uICorner_6.CornerRadius = UDim.new(0, 6)
	local btn10 = makeBtn("Send", color3, frame7, UDim2.new(0.26, -2, 1, 0))
	btn10.Position = UDim2.new(0.74, 0, 0, 0)
	btn10.MouseButton1Click:Connect(function()
		if textBox2.Text ~= "" then
			fireAdmin("announce", {
				text = textBox2.Text
			}) -- equivalent call inferred; original call site unknown
			textBox2.Text = ""
		end
	end)
	local v9 = {}

	if eggRain.Announcements then
		for i, announcement in ipairs(eggRain.Announcements) do
			table.insert(v9, {
				label = "Intro " .. i,
				text = announcement.Text
			})
		end
	end

	if eggRain.Waves then
		for i, wave in ipairs(eggRain.Waves) do
			if wave.Announce then
				table.insert(v9, {
					label = "W" .. i,
					text = wave.Announce
				})
			end
		end
	end

	if eggRain.EndAnnounce then
		table.insert(v9, {
			label = "End",
			text = eggRain.EndAnnounce
		})
	end

	if eggRain.EndSequence and eggRain.EndSequence.Messages then
		for i, message in ipairs(eggRain.EndSequence.Messages) do
			table.insert(v9, {
				label = "End " .. i + 1,
				text = message.Text
			})
		end
	end

	if #v9 > 0 then
		sectionHeader("PRESET ANNOUNCEMENTS")

		for i = 1, #v9, 3 do
			count += 1
			local frame8 = Instance.new("Frame")
			frame8.Size = UDim2.new(1, 0, 0, 28)
			frame8.BackgroundTransparency = 1
			frame8.LayoutOrder = count
			frame8.Parent = scrollingFrame

			for i2 = 0, 2 do
				local v10 = i + i2

				if #v9 < v10 then
					break
				end

				local v11 = v9[v10]
				local v12 = 1 / math.min(3, #v9 - i + 1)
				local btn11 = makeBtn(v11.label, Color3.fromRGB(70, 70, 85), frame8, UDim2.new(v12, -3, 1, 0))
				btn11.Position = UDim2.new(v12 * i2, 0, 0, 0)
				btn11.TextSize = 10
				btn11.MouseButton1Click:Connect(function()
					fireAdmin("announce", {
						text = v11.text
					}) -- equivalent call inferred; original call site unknown
				end)
			end
		end
	end

	sectionHeader("AMBIANCE / SKY")
	count += 1
	local frame8 = Instance.new("Frame")
	frame8.Size = UDim2.new(1, 0, 0, 34)
	frame8.BackgroundTransparency = 1
	frame8.LayoutOrder = count
	frame8.Parent = scrollingFrame
	local waveIndex2 = 0
	local textButton3 = Instance.new("TextButton")
	textButton3.Size = UDim2.new(0.55, -2, 1, 0)
	textButton3.Position = UDim2.new(0, 0, 0, 0)
	textButton3.BackgroundColor3 = color2
	textButton3.Text = "Normal"
	textButton3.TextColor3 = color8
	textButton3.TextSize = 12
	textButton3.Font = Enum.Font.GothamBold
	textButton3.BorderSizePixel = 0
	textButton3.Parent = frame8
	local uICorner_7 = Instance.new("UICorner", textButton3)
	uICorner_7.CornerRadius = UDim.new(0, 6)
	textButton3.MouseButton1Click:Connect(function()
		local waves = eggRain.Waves or {}
		waveIndex2 = (waveIndex2 + 1) % (#waves + 1)

		if waveIndex2 == 0 then
			textButton3.Text = "Normal"
			return
		end

		local wave = waves[waveIndex2]
		textButton3.Text = "Wave " .. waveIndex2 .. (wave and " - " .. wave.Name or "")
	end)
	local btn11 = makeBtn("Apply", color6, frame8, UDim2.new(0.43, -2, 1, 0))
	btn11.Position = UDim2.new(0.57, 0, 0, 0)
	btn11.MouseButton1Click:Connect(function()
		if waveIndex2 == 0 then
			fireAdmin("restoreSky", nil) -- equivalent call inferred; original call site unknown
		else
			fireAdmin("applySky", {
				waveIndex = waveIndex2
			}) -- equivalent call inferred; original call site unknown
		end
	end)
	sectionHeader("MUSIC")
	count += 1
	local frame9 = Instance.new("Frame")
	frame9.Size = UDim2.new(1, 0, 0, 34)
	frame9.BackgroundTransparency = 1
	frame9.LayoutOrder = count
	frame9.Parent = scrollingFrame
	local btn12 = makeBtn("Play", color3, frame9, UDim2.new(0.48, -2, 1, 0))
	btn12.Position = UDim2.new(0, 0, 0, 0)
	btn12.MouseButton1Click:Connect(function()
		if not eggRainAdmin then
			return
		end

		eggRainAdmin:FireServer({
			action = "startMusic",
			args = nil,
			allServers = flag4
		})
	end)
	local btn13 = makeBtn("Stop", color4, frame9, UDim2.new(0.48, -2, 1, 0))
	btn13.Position = UDim2.new(0.52, 0, 0, 0)
	btn13.MouseButton1Click:Connect(function()
		if not eggRainAdmin then
			return
		end

		eggRainAdmin:FireServer({
			action = "stopMusic",
			args = nil,
			allServers = flag4
		})
	end)
	sectionHeader("END SEQUENCE")
	count += 1
	local frame10 = Instance.new("Frame")
	frame10.Size = UDim2.new(1, 0, 0, 34)
	frame10.BackgroundTransparency = 1
	frame10.LayoutOrder = count
	frame10.Parent = scrollingFrame
	local btn14 = makeBtn("Run End Sequence", color5, frame10, UDim2.new(1, 0, 1, 0))
	btn14.Position = UDim2.new(0, 0, 0, 0)
	btn14.MouseButton1Click:Connect(function()
		if not eggRainAdmin then
			return
		end

		eggRainAdmin:FireServer({
			action = "endSequence",
			args = nil,
			allServers = flag4
		})
	end)
end

local function updateAdminStatus(data)
	if not (v6.main and type(data) == "table") then
		return
	end

	local v7 = data.music and "ON" or "OFF"
	local v8 = data.lightning and "ON" or "OFF"
	local v9 = data.fullAuto and " | AUTO" or ""
	v6.main.Text = "Wave: " .. (data.wave or "None") .. " | Music: " .. v7 .. v9 .. "\nEggs: " .. (data.eggsActive or 0) .. " | Lightning: " .. v8
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hookAdminButton()
	if localPlayer.UserId ~= adminUserId then
		return
	end

	task.spawn(function()
		local adminMenuGUI_v2 = playerGui:WaitForChild("AdminMenuGUI_v2", 30)

		if not adminMenuGUI_v2 then
			return
		end

		local panel = adminMenuGUI_v2:WaitForChild("Panel", 10)

		if not panel then
			return
		end

		local eggRainButton = panel:WaitForChild("EggRainButton", 10)

		if not eggRainButton then
			warn("[EggRainClient] AdminMenuGUI_v2/Panel/EggRainButton introuvable")
			return
		end

		eggRainButton.MouseButton1Click:Connect(function()
			if v5 then
				v5.Enabled = not v5.Enabled
			end
		end)
		print("[EggRainClient] Admin button hooked.")
	end)
end

function EggRainClient.Init(_)
	if flag then
		return
	end

	flag = true
	task.spawn(function()
		local v7 = { eggRain.SpawnSound }

		if eggRain.AnnounceSound then
			table.insert(v7, eggRain.AnnounceSound)
		end

		if eggRain.GoldenNotifSound then
			table.insert(v7, eggRain.GoldenNotifSound)
		end

		if eggRain.CountdownSound then
			table.insert(v7, eggRain.CountdownSound)
		end

		if eggRain.CollectSound then
			table.insert(v7, eggRain.CollectSound)
		end

		ContentProvider:PreloadAsync(v7)
	end)
	remotes:WaitForChild("EggRainAnnounce").OnClientEvent:Connect(function(p)
		if type(p) ~= "table" or not p.text then
			return
		end

		showAnnouncement(p.text)
	end)
	remotes:WaitForChild("EggRainWave").OnClientEvent:Connect(onWaveEvent)
	remotes:WaitForChild("EggRainCountdown").OnClientEvent:Connect(function(p)
		if type(p) ~= "table" then
			return
		end

		showCountdown(p)
	end)
	remotes:WaitForChild("EggRainPre").OnClientEvent:Connect(function(p)
		if type(p) ~= "table" then
			return
		end

		local position = p.position

		if not position then
			return
		end

		playSpawnSound(position)

		if p.eggType == 1 then
			showGoldenNotif()
		end
	end)
	remotes:WaitForChild("EggRainHide").OnClientEvent:Connect(function(p)
		if type(p) ~= "table" or type(p.eggId) ~= "number" then
			return
		end

		hideEgg(p.eggId)
	end)
	remotes:WaitForChild("EggRainLightning").OnClientEvent:Connect(onLightningEvent)
	remotes:WaitForChild("EggRainMusic").OnClientEvent:Connect(handleMusicEvent)
	remotes:WaitForChild("EggRainSync").OnClientEvent:Connect(handleSyncEvent)

	if localPlayer.UserId == adminUserId then
		eggRainAdmin = remotes:WaitForChild("EggRainAdmin")
		remotes:WaitForChild("EggRainStatus").OnClientEvent:Connect(updateAdminStatus)
		createAdminPanel()
		hookAdminButton() -- equivalent call inferred; original call site unknown
	end
end

return EggRainClient