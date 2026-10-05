local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local adminAbuse = ReplicatedStorage:WaitForChild("AdminAbuse")
local BossClientBase = require(adminAbuse.Modules.Shared.BossClientBase)
local FakeAdminMessageUtil = require(ReplicatedStorage.Utilities.FakeAdminMessageUtil)
local ChichineConfig = require(script.ChichineConfig)
local ChichineCutscenes = require(script.ChichineCutscenes)
local ZoneSweet = require(script.AttacksClient.ZoneSweet)
local HammerSmash = require(script.AttacksClient.HammerSmash)
local SwordTango = require(script.AttacksClient.SwordTango)
local BoulderRain = require(script.AttacksClient.BoulderRain)
local GlassShatter = require(script.AttacksClient.GlassShatter)
local ShootingKeycaps = require(script.AttacksClient.ShootingKeycaps)
local MiguelSwarm = require(script.AttacksClient.MiguelSwarm)
local v = nil
local v2 = {}
local v3 = {}
local transitionManager = nil
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil
local v8 = nil
local count = 0
local flag = false
local mapName = nil
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://123920758489558"

local function getTransitionManager()
	if not transitionManager then
		local coolTransitions = require(ReplicatedStorage.coolTransitions)
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		transitionManager = coolTransitions.TransitionManager.new(playerGui)
	end

	return transitionManager
end

local function getLiveCosmeticRig()
	if not mapName then
		return nil
	end

	local adminAbuse2 = workspace:FindFirstChild("AdminAbuse")
	local map = adminAbuse2 and adminAbuse2:FindFirstChild("Map")

	if not map then
		return nil
	end

	local child = map:FindFirstChild(mapName)

	if not child then
		return nil
	end

	local scriptables = child:FindFirstChild("Scriptables")

	if not scriptables then
		return nil
	end

	local cosmeticBossRig = scriptables:FindFirstChild("CosmeticBossRig")

	if cosmeticBossRig and cosmeticBossRig:IsA("Model") then
		return cosmeticBossRig
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startLaughLoop()
	flag = true
	local random = Random.new()
	task.spawn(function()
		while flag do
			task.wait(random:NextNumber(35, 120))

			if not flag then
				break
			end

			local liveCosmeticRig = getLiveCosmeticRig()

			if not liveCosmeticRig then
				continue
			end

			local humanoid = liveCosmeticRig:FindFirstChildOfClass("Humanoid")
			local animator = humanoid and humanoid:FindFirstChildOfClass("Animator") or liveCosmeticRig:FindFirstChildOfClass("Animator")

			if not animator then
				continue
			end

			local track = animator:LoadAnimation(animation)
			track.Looped = true
			track.Priority = Enum.AnimationPriority.Action
			track:Play(0.5)
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://4810729995"
			sound.Volume = 1
			sound.Parent = Players.LocalPlayer
			sound:Play()
			Debris:AddItem(sound, 20)
			local v9 = false
			local endedConnection = sound.Ended:Connect(function()
				v9 = true
			end)
			local total = 0

			repeat
				total += task.wait(0.1)
			until v9 or not flag or total > 15

			endedConnection:Disconnect()
			sound:Stop()
			track:Stop(0.5)
		end
	end)
end

local function showCredits()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ChichineCredits"
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 100
	screenGui.Parent = playerGui
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1
	frame.Parent = screenGui
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 0.6)
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

Scripter - FoeCakes

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

local function _destroyTimeshiftFx()
	if v4 then
		v4:Destroy()
		v4 = nil
	end

	if v5 then
		v5:Destroy()
		v5 = nil
	end

	if v6 then
		v6:Destroy()
		v6 = nil
	end

	if v7 then
		v7:Destroy()
		v7 = nil
	end

	if v8 then
		v8:Destroy()
		v8 = nil
	end
end

local function _findActiveSoundtrack()
	for _, sound in CollectionService:GetTagged("Music") do
		if sound:IsA("Sound") and sound.IsPlaying then
			return sound
		end
	end

	return nil
end

local function _timeshiftBegin(duration: number)
	count += 1
	_destroyTimeshiftFx()
	local Lighting = game:GetService("Lighting")
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Name = "ChichineTimeshiftCC"
	colorCorrectionEffect.Saturation = 0
	colorCorrectionEffect.Contrast = 0
	colorCorrectionEffect.Brightness = 0
	colorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
	colorCorrectionEffect.Parent = Lighting
	v4 = colorCorrectionEffect
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
		screenGui.Name = "ChichineTimeshiftFlash"
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
		v8 = screenGui
		TweenService:Create(frame, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		}):Play()
		task.delay(0.5, function()
			if not screenGui.Parent then
				return
			end

			frame.BackgroundColor3 = Color3.fromRGB(150, 110, 255)
			frame.BackgroundTransparency = 0.85
		end)
	end

	if not ChichineConfig.GlassShatter.timeshiftDistortAudio then
		return
	end

	print("[ChichineBossRoom] _timeshiftBegin: CC+flash created, finding soundtrack")
	local parent = _findActiveSoundtrack()

	if parent and parent.Parent then
		local equalizerSoundEffect = Instance.new("EqualizerSoundEffect")
		equalizerSoundEffect.LowGain = 0
		equalizerSoundEffect.MidGain = 0
		equalizerSoundEffect.HighGain = 0
		equalizerSoundEffect.Parent = parent
		v5 = equalizerSoundEffect
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
		reverbSoundEffect.Parent = parent
		v6 = reverbSoundEffect
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
		pitchShiftSoundEffect.Parent = parent
		v7 = pitchShiftSoundEffect
		TweenService:Create(
			pitchShiftSoundEffect,
			TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Octave = 0.7
			}
		):Play()
	end
end

local function _timeshiftEnd(duration: number)
	count += 1
	local v9 = count
	local v10 = v4
	local v11 = v5
	local v12 = v6
	local v13 = v7
	local v14 = v8

	if v10 then
		TweenService:Create(v10, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Saturation = 0,
			Contrast = 0,
			Brightness = 0
		}):Play()
	end

	if v11 then
		TweenService:Create(v11, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			HighGain = 0,
			MidGain = 0,
			LowGain = 0
		}):Play()
	end

	if v12 then
		TweenService:Create(v12, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			WetLevel = 0,
			DryLevel = 0
		}):Play()
	end

	if v13 then
		TweenService:Create(v13, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Octave = 1
		}):Play()
	end

	if v14 and v14:FindFirstChildOfClass("Frame") then
		TweenService:Create(
			v14:FindFirstChildOfClass("Frame"),
			TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				BackgroundTransparency = 1
			}
		):Play()
	end

	task.delay(duration + 0.05, function()
		if v9 ~= count then
			return
		end

		_destroyTimeshiftFx()
	end)
end

local function cleanupCosmetics()
	for _, v9 in pairs(v2) do
		local v10 = v9
		pcall(function()
			v10:Destroy()
		end)
	end

	table.clear(v2)

	for _, v9 in v3 do
		local v10 = v9
		pcall(function()
			v10:Destroy()
		end)
	end

	table.clear(v3)
	HammerSmash.cleanup()
	SwordTango.cleanup()
	BoulderRain.cleanup()
	GlassShatter.cleanup()
	ShootingKeycaps.cleanup()
	MiguelSwarm.cleanup()
	_destroyTimeshiftFx()
end

local function playSpatialSound(x: number, y: number, z: number, soundId: string, volume: number)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CFrame = CFrame.new(x, y, z)
	part.Parent = workspace
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume
	sound.RollOffMaxDistance = 120
	sound.Parent = part
	table.insert(v3, sound)
	sound:Play()
	sound.Ended:Connect(function()
		pcall(function()
			table.remove(v3, table.find(v3, sound) or 0)
			part:Destroy()
		end)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function screenShake(duration: number, intensity: number)
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	task.spawn(function()
		local total = 0

		while total < duration do
			total += task.wait()
			local v9 = 1 - total / duration
			humanoid.CameraOffset = Vector3.new(
				math.sin(total * 43) * v9 * intensity,
				math.sin(total * 29) * v9 * intensity,
				0
			)
		end

		humanoid.CameraOffset = createVector(0, 0, 0)
	end)
end

local function handleFx(p: string, data)
	if p == "ShowBossMessage" then
		local message = data.message

		if type(message) ~= "string" or message == "" then
			return
		end

		local senderId = data.senderId or ChichineConfig.DefaultSenderId
		local duration = data.duration or 8
		task.spawn(function()
			local success, result = pcall(function()
				return Players:GetNameFromUserIdAsync(senderId)
			end)
			FakeAdminMessageUtil.show({
				message = message,
				senderName = success and result or "User" .. tostring(senderId),
				senderUserId = senderId,
				preloadedThumb = ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(senderId),
				duration = duration
			})
		end)
	elseif p == "PhaseRoar" then
		local character = Players.LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			local v9 = 0.65
			local v10 = 0.5
			task.spawn(function()
				local total = 0

				while total < v9 do
					total += task.wait()
					local v11 = 1 - total / v9
					humanoid.CameraOffset = Vector3.new(
						math.sin(total * 43) * v11 * v10,
						math.sin(total * 29) * v11 * v10,
						0
					)
				end

				humanoid.CameraOffset = createVector(0, 0, 0)
			end)
		end

		if data.x then
			playSpatialSound(data.x, data.y or 0, data.z or 0, "rbxassetid://0", 1)
		end
	elseif p == "PortalOpen" then
		local id = data.id or 1
		local x = data.x or 0
		local y = data.y or 0
		local z = data.z or 0
		local r = data.r or 8
		local part = Instance.new("Part")
		part.Name = "ChichinePortalDisc"
		part.Shape = Enum.PartType.Cylinder
		part.Size = Vector3.new(0.4, r * 2, r * 2)
		part.CFrame = CFrame.new(x, y + 0.15, z) * CFrame.Angles(0, 0, 1.5707963267948966)
		part.Anchored = true
		part.CanCollide = false
		part.Material = Enum.Material.Neon
		part.BrickColor = BrickColor.new("Dark indigo")
		part.Transparency = 0.35
		part.CastShadow = false
		part.Parent = workspace
		v2[id] = part
		task.spawn(function()
			while part and part.Parent do
				TweenService:Create(
					part,
					TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
					{
						Transparency = 0.68
					}
				):Play()
				task.wait(0.72)
			end
		end)
		local part2 = Instance.new("Part")
		part2.Name = "ChichinePortalBeam"
		part2.Shape = Enum.PartType.Cylinder
		part2.Size = createVector(0.1, 2.5, 2.5)
		part2.CFrame = CFrame.new(x, y + 12, z) * CFrame.Angles(0, 0, 1.5707963267948966)
		part2.Anchored = true
		part2.CanCollide = false
		part2.Material = Enum.Material.Neon
		part2.BrickColor = BrickColor.new("Dark indigo")
		part2.Transparency = 0.6
		part2.CastShadow = false
		part2.Parent = part
		TweenService:Create(part2, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = createVector(24, 2.5, 2.5),
			Transparency = 0.15
		}):Play()
	elseif p == "PortalClose" then
		local id = data.id or 1
		local v9 = v2[id]

		if not v9 then
			return
		end

		v2[id] = nil
		TweenService:Create(v9, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Transparency = 1
		}):Play()
		task.delay(0.5, function()
			pcall(function()
				v9:Destroy()
			end)
		end)
	elseif p == "PlaySound" then
		local id = data.id or data.soundId

		if type(id) ~= "string" then
			return
		end

		local vol = data.vol or data.volume or 1

		if not data.global then
			playSpatialSound(data.x or 0, data.y or 0, data.z or 0, id, vol)
			return
		end

		local sound = Instance.new("Sound")
		sound.SoundId = id
		sound.Volume = vol
		sound.Parent = SoundService
		sound:Play()
		sound.Ended:Connect(function()
			pcall(function()
				sound:Destroy()
			end)
		end)
	else
		if p == "StopOpeningCutscene" then
			return
		end

		if p == "OpeningCutscene" then
			if type(data.mapName) == "string" then
				mapName = data.mapName

				if not flag then
					startLaughLoop() -- equivalent call inferred; original call site unknown
				end

				task.spawn(function()
					local child = workspace.AdminAbuse.Map:WaitForChild(data.mapName, 10)

					if child then
						GlassShatter.scan(child)
						task.spawn(function()
							local scriptables = child:FindFirstChild("Scriptables")
							local cosmeticBossRig = scriptables and scriptables:FindFirstChild("CosmeticBossRig")

							if not (cosmeticBossRig and cosmeticBossRig:IsA("Model")) then
								return
							end

							local humanoid = cosmeticBossRig:FindFirstChildOfClass("Humanoid")
							local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

							if not animator then
								local animationController = cosmeticBossRig:FindFirstChildOfClass("AnimationController")
								animator = animationController and animationController:FindFirstChildOfClass("Animator")
							end

							if not animator then
								return
							end

							local animation2 = Instance.new("Animation")
							animation2.AnimationId = "rbxassetid://129833233965732"
							local success, result = pcall(function()
								return animator:LoadAnimation(animation2)
							end)
							animation2:Destroy()

							if not success then
								return
							end

							result.Looped = true
							result:Play()
						end)
						local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
						local screenGui = Instance.new("ScreenGui")
						screenGui.Name = "ChichineOpenBlack"
						screenGui.IgnoreGuiInset = true
						screenGui.ResetOnSpawn = false
						screenGui.DisplayOrder = 999998
						screenGui.Parent = playerGui
						local frame = Instance.new("Frame")
						frame.Size = UDim2.fromScale(1, 1)
						frame.BackgroundColor3 = Color3.new(0, 0, 0)
						frame.BackgroundTransparency = 1
						frame.BorderSizePixel = 0
						frame.Parent = screenGui
						local tween = TweenService:Create(
							frame,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								BackgroundTransparency = 0
							}
						)
						tween:Play()
						tween.Completed:Wait()
						task.wait(0.5)
						local tween2 = TweenService:Create(
							frame,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								BackgroundTransparency = 1
							}
						)
						tween2:Play()
						tween2.Completed:Once(function()
							screenGui:Destroy()

							if v then
								v:showCutsceneUi()
							end
						end)
					else
						warn("[ChichineBossRoom] OpeningCutscene: map not found:", data.mapName)

						if v then
							v:showCutsceneUi()
						end
					end
				end)
			else
				warn("[ChichineBossRoom] OpeningCutscene: mapName missing from payload")

				if v then
					v:showCutsceneUi()
				end
			end
		elseif p == "SpawnOrbs" then
			local v9 = type(data.count) == "number" and math.max(1, (math.floor(data.count))) or 1
			task.spawn(GlassShatter.spawnFromZone, v9)
		elseif p == "SpawnGiantOrbs" then
			local v9 = type(data.count) == "number" and math.max(1, (math.floor(data.count))) or 1
			task.spawn(GlassShatter.spawnGiantFromZone, v9)
		elseif p == "EndingCutscene" then
			if v then
				v:stop()
				v = nil
			end

			task.spawn(function()
				cleanupCosmetics()
				local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
				local screenGui = Instance.new("ScreenGui")
				screenGui.Name = "ChichineEndBlack"
				screenGui.IgnoreGuiInset = true
				screenGui.ResetOnSpawn = false
				screenGui.DisplayOrder = 999998
				screenGui.Parent = playerGui
				local frame = Instance.new("Frame")
				frame.Size = UDim2.fromScale(1, 1)
				frame.BackgroundColor3 = Color3.new(0, 0, 0)
				frame.BackgroundTransparency = 1
				frame.BorderSizePixel = 0
				frame.Parent = screenGui
				local tween = TweenService:Create(
					frame,
					TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						BackgroundTransparency = 0
					}
				)
				tween:Play()
				tween.Completed:Wait()
				local defaultSenderId = ChichineConfig.DefaultSenderId
				local lokiiSenderId = ChichineConfig.LokiiSenderId

				for _, v9 in {
					{
						id = defaultSenderId,
						msg = "What happened?"
					},
					{
						id = lokiiSenderId,
						msg = "We stopped you."
					},
					{
						id = defaultSenderId,
						msg = "There's no way you did. I can feel World 3 open."
					},
					{
						id = lokiiSenderId,
						msg = "Wait... really?"
					},
					{
						id = defaultSenderId,
						msg = "Yes... World 3 is here, World 1 and 2 are intact... HOW?!"
					}
				} do
					local senderUserId = v9.id
					local message = v9.msg
					task.spawn(function()
						local success, result = pcall(function()
							return Players:GetNameFromUserIdAsync(senderUserId)
						end)
						FakeAdminMessageUtil.show({
							message = message,
							senderName = success and result or "User" .. tostring(senderUserId),
							senderUserId = senderUserId,
							preloadedThumb = ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(senderUserId),
							duration = 8
						})
					end)
					task.wait(4)
				end

				local tween2 = TweenService:Create(
					frame,
					TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						BackgroundTransparency = 1
					}
				)
				tween2:Play()
				tween2.Completed:Once(function()
					screenGui:Destroy()
				end)
				task.wait(1.5)
				showCredits()
				task.wait(1.5)
			end)
		elseif p == "TilesTransition" then
			if data.targetUserId ~= Players.LocalPlayer.UserId then
				return
			end

			if not transitionManager then
				local coolTransitions = require(ReplicatedStorage.coolTransitions)
				local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
				transitionManager = coolTransitions.TransitionManager.new(playerGui)
			end

			local v9 = transitionManager

			if v9 then
				task.spawn(function()
					v9:PlayInOut(1, function() end, "Center", "Tiles")
				end)
			end
		elseif p == "ZoneWarn" then
			ZoneSweet.ZoneWarn(data)
		elseif p == "ZoneHit" then
			ZoneSweet.ZoneHit(data)
		elseif p == "ScreenShake" then
			local duration = data.duration or 0.3
			local intensity = data.intensity or 0.4
			screenShake(duration, intensity) -- equivalent call inferred; original call site unknown
		elseif p == "HMHover" then
			task.spawn(HammerSmash.hover, data)
		elseif p == "HMWarn" then
			HammerSmash.warn(data)
		elseif p == "HMSmash" then
			task.spawn(HammerSmash.smash, data)
		elseif p == "HMImpact" then
			HammerSmash.impact(data)
		elseif p == "SwordTango" then
			task.spawn(SwordTango.play, data)
		elseif p == "BoulderRainWarn" then
			task.spawn(BoulderRain.warn, data)
		elseif p == "BoulderRainSpawn" then
			task.spawn(BoulderRain.spawn, data)
		elseif p == "GlassShatterOpen" then
			print("[ChichineBossRoom] Client: GlassShatterOpen received id=" .. tostring(data.id))
			task.spawn(GlassShatter.open, data)
		elseif p == "GlassShatterClose" then
			print("[ChichineBossRoom] Client: GlassShatterClose received")
			GlassShatter.closeAll()
		elseif p == "SKSpawn" then
			task.spawn(ShootingKeycaps.spawn, data)
		elseif p == "SKImpact" then
			ShootingKeycaps.impactFx(data)
		elseif p == "TimeshiftBegin" then
			local fadeIn = data.fadeIn
			task.spawn(_timeshiftBegin, type(fadeIn) ~= "number" and 0.6 or math.max(0.05, fadeIn) or 0.6)
		elseif p == "TimeshiftEnd" then
			local fadeOut = data.fadeOut
			task.spawn(_timeshiftEnd, type(fadeOut) ~= "number" and 0.5 or math.max(0.05, fadeOut) or 0.5)
		elseif p == "BossTeleport" then
			print("BossTeleport was called")
			local rigModel = data.rigModel

			if not rigModel then
				warn("[Chichinebossroom.client] - BossTeleport cmd missing rigModel arg")
				return
			end

			for _, part in ipairs(rigModel:GetDescendants()) do
				if not part:IsA("BasePart") then
					continue
				end

				local clone = part:Clone()
				clone.Parent = data.debrisFolder or workspace
				clone.Anchored = true
				clone.Color = Color3.fromRGB(255, 255, 255)
				clone.Material = Enum.Material.ForceField

				if #clone:GetChildren() > 0 then
					for _, child in ipairs(clone:GetChildren()) do
						child:Destroy()
					end
				end

				local tween = TweenService:Create(clone, TweenInfo.new(3), {
					Transparency = 1
				})
				tween:Play()
				tween.Completed:Once(function(p2)
					tween:Destroy()
					clone:Destroy()
				end)
			end
		elseif p == "DisappearNPC" then
			if not data.npc then
				warn("[Chichinebossroom FX/Client] - DisappearNPC missing npc arg")
				return
			end

			for _, part in ipairs(data.npc:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				local tween = TweenService:Create(part, TweenInfo.new(1.5), {
					Transparency = 1
				})
				tween:Play()
				tween.Completed:Once(function(p2)
					tween:Destroy()
				end)
			end
		end
	end
end

local flag2 = false
local flag3 = false
local ChichineBossRoom = {}
ChichineBossRoom.IsAdminAbuse = true
ChichineBossRoom.NeedsDuration = false
ChichineBossRoom.SkipDoorTransition = ChichineConfig.SkipDoorTransition
ChichineBossRoom.SkipDoorCamera = ChichineConfig.SkipDoorCamera

function ChichineBossRoom.Fire(_: number?)
	flag2 = false
	flag3 = false

	if v then
		v:stop()
	end

	cleanupCosmetics()
	v = BossClientBase.new({
		sseChannelName = ChichineConfig.sseChannelName,
		bossDisplayName = ChichineConfig.bossName,
		bossIcon = ChichineConfig.bossIcon,
		phaseThresholds = ChichineConfig.PHASE_THRESHOLDS,
		hideCutsceneUi = false,
		animatedGradient = true,
		onFx = function(p: string, p2)
			if p == "OpeningCutscene" then
				if flag2 then
					return
				else
					flag2 = true
				end
			elseif p == "EndingCutscene" then
				if flag3 then
					return
				else
					flag3 = true
				end
			end

			handleFx(p, p2)
		end
	})
	v:fire()
	MiguelSwarm.init()
	local _sse = v._sse

	if _sse then
		_sse:onChange("OpeningCutscene", function(p)
			if type(p) == "table" and p.mapName and not flag2 then
				task.delay(2, function()
					if not flag2 then
						flag2 = true
						local v9 = p

						if type(v9.mapName) == "string" then
							mapName = v9.mapName

							if not flag then
								startLaughLoop() -- equivalent call inferred; original call site unknown
							end

							task.spawn(function()
								local child = workspace.AdminAbuse.Map:WaitForChild(v9.mapName, 10)

								if child then
									GlassShatter.scan(child)
									task.spawn(function()
										local scriptables = child:FindFirstChild("Scriptables")
										local cosmeticBossRig = scriptables and scriptables:FindFirstChild("CosmeticBossRig")

										if not (cosmeticBossRig and cosmeticBossRig:IsA("Model")) then
											return
										end

										local humanoid = cosmeticBossRig:FindFirstChildOfClass("Humanoid")
										local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

										if not animator then
											local animationController = cosmeticBossRig:FindFirstChildOfClass("AnimationController")
											animator = animationController and animationController:FindFirstChildOfClass("Animator")
										end

										if not animator then
											return
										end

										local animation2 = Instance.new("Animation")
										animation2.AnimationId = "rbxassetid://129833233965732"
										local success, result = pcall(function()
											return animator:LoadAnimation(animation2)
										end)
										animation2:Destroy()

										if not success then
											return
										end

										result.Looped = true
										result:Play()
									end)
									local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
									local screenGui = Instance.new("ScreenGui")
									screenGui.Name = "ChichineOpenBlack"
									screenGui.IgnoreGuiInset = true
									screenGui.ResetOnSpawn = false
									screenGui.DisplayOrder = 999998
									screenGui.Parent = playerGui
									local frame = Instance.new("Frame")
									frame.Size = UDim2.fromScale(1, 1)
									frame.BackgroundColor3 = Color3.new(0, 0, 0)
									frame.BackgroundTransparency = 1
									frame.BorderSizePixel = 0
									frame.Parent = screenGui
									local tween = TweenService:Create(
										frame,
										TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											BackgroundTransparency = 0
										}
									)
									tween:Play()
									tween.Completed:Wait()
									task.wait(0.5)
									local tween2 = TweenService:Create(
										frame,
										TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
										{
											BackgroundTransparency = 1
										}
									)
									tween2:Play()
									tween2.Completed:Once(function()
										screenGui:Destroy()

										if v then
											v:showCutsceneUi()
										end
									end)
								else
									warn("[ChichineBossRoom] OpeningCutscene: map not found:", v9.mapName)

									if v then
										v:showCutsceneUi()
									end
								end
							end)
						else
							warn("[ChichineBossRoom] OpeningCutscene: mapName missing from payload")

							if v then
								v:showCutsceneUi()
							end
						end
					end
				end)
			end
		end)
		_sse:onChange("EndingCutscene", function(p)
			if type(p) == "table" and not flag3 then
				flag3 = true

				if v then
					v:stop()
					v = nil
				end

				task.spawn(function()
					cleanupCosmetics()
					local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
					local screenGui = Instance.new("ScreenGui")
					screenGui.Name = "ChichineEndBlack"
					screenGui.IgnoreGuiInset = true
					screenGui.ResetOnSpawn = false
					screenGui.DisplayOrder = 999998
					screenGui.Parent = playerGui
					local frame = Instance.new("Frame")
					frame.Size = UDim2.fromScale(1, 1)
					frame.BackgroundColor3 = Color3.new(0, 0, 0)
					frame.BackgroundTransparency = 1
					frame.BorderSizePixel = 0
					frame.Parent = screenGui
					local tween = TweenService:Create(
						frame,
						TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							BackgroundTransparency = 0
						}
					)
					tween:Play()
					tween.Completed:Wait()
					local defaultSenderId = ChichineConfig.DefaultSenderId
					local lokiiSenderId = ChichineConfig.LokiiSenderId

					for _, v9 in {
						{
							id = defaultSenderId,
							msg = "What happened?"
						},
						{
							id = lokiiSenderId,
							msg = "We stopped you."
						},
						{
							id = defaultSenderId,
							msg = "There's no way you did. I can feel World 3 open."
						},
						{
							id = lokiiSenderId,
							msg = "Wait... really?"
						},
						{
							id = defaultSenderId,
							msg = "Yes... World 3 is here, World 1 and 2 are intact... HOW?!"
						}
					} do
						local senderUserId = v9.id
						local message = v9.msg
						task.spawn(function()
							local success, result = pcall(function()
								return Players:GetNameFromUserIdAsync(senderUserId)
							end)
							FakeAdminMessageUtil.show({
								message = message,
								senderName = success and result or "User" .. tostring(senderUserId),
								senderUserId = senderUserId,
								preloadedThumb = ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(senderUserId),
								duration = 8
							})
						end)
						task.wait(4)
					end

					local tween2 = TweenService:Create(
						frame,
						TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							BackgroundTransparency = 1
						}
					)
					tween2:Play()
					tween2.Completed:Once(function()
						screenGui:Destroy()
					end)
					task.wait(1.5)
					showCredits()
					task.wait(1.5)
				end)
			end
		end)
	end
end

function ChichineBossRoom.Stop()
	flag = false
	mapName = nil
	ChichineCutscenes.stop()

	if v then
		v:stop()
		v = nil
	end

	cleanupCosmetics()

	if transitionManager then
		transitionManager:Destroy()
		transitionManager = nil
	end

	flag2 = false
	flag3 = false
end

ChichineBossRoom.Hidden = true
return ChichineBossRoom