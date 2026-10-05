local VeiledCharybdisBehavior = {}
game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
game:GetService("GuiService")
local Players = game:GetService("Players")
local CameraShaker = require(ReplicatedStorage.packages.CameraShaker)
local fx = require(ReplicatedStorage.shared.modules.fx)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local LightingController = require(ReplicatedStorage.client.legacyControllers.LightingController)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
DataController = DataController.PlayerDataReplicator
local PreloadUtils = require(ReplicatedStorage.shared.utils.FischUtils.Shared.PreloadUtils)
local module = require("./PassiveHandler")
local UI = script:WaitForChild("UI")
local sounds = script:WaitForChild("Sounds")
local veiledScene = script:WaitForChild("VeiledScene")
local anims = script:WaitForChild("Anims")
local mouth = veiledScene:WaitForChild("FishModel"):WaitForChild("RootPart"):WaitForChild("Bone"):WaitForChild("Bone.001"):WaitForChild("Bone.003"):WaitForChild("mouth")
local animator = veiledScene.FishModel:WaitForChild("AnimationController"):WaitForChild("Animator")
local music = SoundService:WaitForChild("music")

local function degorient(p, p2, p3)
	return CFrame.fromOrientation(math.rad(p), math.rad(p2), (math.rad(p3)))
end

local v = CFrame.new(4.455, -9988, 19.95) * CFrame.fromOrientation(0, 1.5707963267948966, 0)
local v2 = CFrame.new(-7.211, -9988, 19.95) * CFrame.fromOrientation(0, 1.5707963267948966, 0)
local cFrame = CFrame.new(-10.362, -10002, 19.95) * CFrame.fromOrientation(0, 1.5707963267948966, 0)
local cFrame2 = CFrame.new(-6.015, -9985.597, 12.291) * CFrame.fromOrientation(
	-0.18730873532403144,
	-2.1964619570498236,
	-0.08726646259971647
)
local cFrame3 = CFrame.new(-17.932, -9982.816, 3.68) * CFrame.fromOrientation(
	-0.18730873532403144,
	-2.1964619570498236,
	0.17453292519943295
)
local cframe = CFrame.new(-8, -9988.439, 20)
local cFrame4 = CFrame.new(13.222, -9983.756, 3.71) * CFrame.fromOrientation(
	-0.17074556072260524,
	2.1954496660836673,
	0.17453292519943295
)
Random.new()

function VeiledCharybdisBehavior:Morph(parent, object)
	object:Preload(script:GetChildren())
	self.random = object:GetRandom(6)
	self.nextSpawn = 0
	self.currentDanger = 0
	self.veiledActive = false
	self._lastProgress = object.progress
	self.container = UI.whirlpoolContainer:Clone()
	self.container.Parent = parent
	self.dangerBar = UI.danger:Clone()
	self.dangerBar.bar.Size = UDim2.fromScale(0, 1)
	self.dangerBar.Visible = false
	self.dangerBar.Size = UDim2.fromScale(0, 0.269)
	self.dangerBar.warnLeft.Visible = false
	self.dangerBar.warnRight.Visible = false
	self.dangerBar.Parent = parent
	self.dangerGlow1 = self.dangerBar.bar.UIShadow
	self.dangerGlow2 = self.dangerBar.bar.UIShadow2
	self._dangerBarVelocity = 0
	self._playerVel = CFrame.identity
	self.whirpools = {}
	TweenService:Create(music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		Volume = 0
	}):Play()
	self.reelTrove:Add(function()
		TweenService:Create(music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			Volume = music:GetAttribute("DefaultVolume") * (SettingsController:GetSettingValue("musicVolume") / 100)
		}):Play()
		local tween = TweenService:Create(sounds.Music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			Volume = 0
		})
		tween.Completed:Once(function()
			sounds.Music:Stop()
		end)
		tween:Play()
	end)
	self.reelTrove:Add(object.OnMinigameEnd:Once(function(p)
		if not self.veiledActive or self.currentDanger >= 100 then
			return
		end

		if not p then
			for _, v7 in mouth:QueryDescendants("> Attachment#bob") do
				v7:Destroy()
			end

			self.reelTrove:Add(animator:LoadAnimation(anims.FishByeLoser)):Play(0.1)
		end

		local v7 = self.trove:Add(UI.darken:Clone())
		v7.BackgroundTransparency = 1
		v7.Parent = object.reel
		local tween = TweenService:Create(v7, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
			BackgroundTransparency = 0
		})
		tween:Play()
		tween.Completed:Wait()
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		workspace.CurrentCamera.FieldOfView = 70
		local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
		workspace.CurrentCamera.CameraSubject = character:WaitForChild("Humanoid")
		TweenService:Create(v7, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			BackgroundTransparency = 1
		}):Play()
	end))
	self.current.BuildEndingData:Bind(function(p)
		p.VeiledCharybdis_Died = self.currentDanger >= 100
		return p
	end)
end

local function cloneCharacter()
	local character = Players.LocalPlayer.Character or script.FallbackPlayerModel
	local archivable = character.Archivable
	character.Archivable = true
	local clone = character:Clone()
	character.Archivable = archivable

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BaseScript") and not descendant:HasTag("StreamingSafe") or descendant:IsA("BillboardGui") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") and descendant:HasTag("PlayerRoot") then
			descendant:RemoveTag("PlayerRoot")
		end
	end

	local tool = clone:FindFirstChildWhichIsA("Tool")
	local bobber = tool and tool:FindFirstChild("bobber")

	if bobber then
		local bob = bobber:FindFirstChild("bob")

		if bob then
			bob.Parent = mouth
			clone.Destroying:Once(function()
				bob:Destroy()
			end)
		end

		bobber:Destroy()
	end

	local humanoid = clone:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.EvaluateStateMachine = false
		humanoid.BreakJointsOnDeath = false
		humanoid.RequiresNeck = false
		humanoid.AutoRotate = false
		humanoid.AutoJumpEnabled = false
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end

	local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		error("HEEEEEEELP")
	end

	clone.PrimaryPart = humanoidRootPart
	humanoidRootPart.Anchored = true
	clone:PivotTo(v)
	clone.Parent = workspace.active
	local animator2 = humanoid:FindFirstChildWhichIsA("Animator") or Instance.new("Animator", humanoid)
	local humanoid2 = character:FindFirstChildWhichIsA("Humanoid")
	local animator3 = humanoid2 and humanoid2:FindFirstChildWhichIsA("Animator")

	if animator2 and animator3 then
		for _, v7 in animator3:GetPlayingAnimationTracks(), nil, nil do
			if v7.Animation then
				local track = animator2:LoadAnimation(v7.Animation)
				track.Priority = v7.Priority
				track.Looped = v7.Looped
				track:Play(0, v7.WeightTarget, v7.Speed)
			else
				warn("No animation instance found for", v7)
			end
		end
	end

	return clone
end

function VeiledCharybdisBehavior:StartVeiledPhase(object)
	self.veiledActive = true
	object.logicPaused = true
	object.progressLocked = true
	object.core.ui.CameraFOV_Enabled = false
	object.core.ui.CameraShake_Enabled = false
	object.core.fish.Disabled = true
	object.core.minigame.Disabled = true
	object:AddCleanupDelay(2)

	if object.core.ui.CameraShake_CurrentShake then
		object.core.ui.CameraShake_CurrentShake.Stop()
	end

	local v7 = self.trove:Add(UI.darken:Clone())
	v7.BackgroundTransparency = 1
	v7.Parent = object.reel
	local currentCamera = workspace.CurrentCamera
	TweenService:Create(v7, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
		BackgroundTransparency = 0
	}):Play()
	local tween = TweenService:Create(currentCamera, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
		FieldOfView = 45
	})
	veiledScene.Parent = workspace.active
	local veiledScenePlayer = self.reelTrove:Add((cloneCharacter()))
	self.veiledScenePlayer = veiledScenePlayer
	self.veiledScenePlayerRoot = veiledScenePlayer.PrimaryPart
	self.reelTrove:Add(function()
		veiledScene.Parent = nil
		self.veiledScenePlayer = nil
		self.veiledScenePlayerRoot = nil
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		workspace.CurrentCamera.FieldOfView = 70
		local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
		workspace.CurrentCamera.CameraSubject = character:WaitForChild("Humanoid")
		task.delay(0.1, function()
			LightingController.UpdateLighting(0)
		end)
	end)
	local v9 = self.reelTrove:Add(animator:LoadAnimation(anims.FishIdle))
	v9:Play()
	self.reelTrove:Add(RunService.PreAnimation:Connect(function()
		v9:AdjustSpeed(1 + self.currentDanger / 50)
	end))
	tween:Play()
	PreloadUtils.PreloadAsync({ sounds.Music, veiledScene })

	if tween.PlaybackState == Enum.PlaybackState.Playing then
		tween.Completed:Wait()
	end

	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.CFrame = cFrame2
	currentCamera.Focus = cframe
	currentCamera.FieldOfView = 20
	sounds.Music.Volume = 0.25
	sounds.Music:Play()
	Lighting.GlobalShadows = true
	self.reelTrove:Add(function()
		v9:Stop()
		Lighting.GlobalShadows = SettingsController:GetSettingValue("shadowsEnabled")
	end)
	self.reelTrove:Add(LightingController.HookLighting:BindAtPriority(9999999999, function(data)
		data.Lighting.Ambient = Color3.fromRGB(78, 41, 111)
		data.Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
		data.Lighting.Brightness = 3
		data.Lighting.ColorShift_Top = Color3.fromRGB(116, 69, 255)
		data.Lighting.ColorShift_Bottom = Color3.new()
		data.Lighting.EnvironmentDiffuseScale = 1
		data.Lighting.EnvironmentSpecularScale = 1
		data.Lighting.ClockTime = 0
		data.Lighting.GeographicLatitude = 0
		data.Lighting.ExposureCompensation = 0
		data.Atmosphere.Density = 0.46
		data.Atmosphere.Offset = 0
		data.Atmosphere.Color = Color3.fromRGB(189, 64, 112)
		data.Atmosphere.Decay = Color3.fromRGB(32, 196, 255)
		data.Atmosphere.Glare = 0
		data.Atmosphere.Haze = 2
		data.BloomEffect.Intensity = 1
		data.BloomEffect.Size = 60
		data.BloomEffect.Threshold = 1
		data.ColorCorrectionEffect.Brightness = 0
		data.ColorCorrectionEffect.Contrast = 0
		data.ColorCorrectionEffect.Saturation = 0
		data.ColorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
		data.DepthOfFieldEffect.FarIntensity = 1
		data.DepthOfFieldEffect.FocusDistance = 0.05
		data.DepthOfFieldEffect.InFocusRadius = 100
		data.DepthOfFieldEffect.NearIntensity = 0
		data.SunRaysEffect.Intensity = 0
		data.Clouds.Cover = 0
		data.Clouds.Density = 0
		data.BlurEffect.Size = 0
		return data
	end))
	LightingController.UpdateLighting(0)
	TweenService:Create(v7, TweenInfo.new(2, Enum.EasingStyle.Linear), {
		BackgroundTransparency = 1
	}):Play()
	TweenService:Create(currentCamera, TweenInfo.new(10, Enum.EasingStyle.Quint), {
		CFrame = cFrame3
	}):Play()
	TweenService:Create(currentCamera, TweenInfo.new(10, Enum.EasingStyle.Exponential), {
		FieldOfView = 45
	}):Play()
	TweenService:Create(object.reel_progress.bar, TweenInfo.new(10, Enum.EasingStyle.Exponential), {
		Size = UDim2.fromScale(0.2, 1)
	}):Play()
	task.wait(7)
	TweenService:Create(currentCamera, TweenInfo.new(3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		CFrame = cFrame4
	}):Play()
	task.wait(2)
	TweenService:Create(object.reel_progspeed, TweenInfo.new(1, Enum.EasingStyle.Quint), {
		Position = object.reel_progspeed.Position + UDim2.fromScale(0, 0.739)
	}):Play()
	TweenService:Create(object.reel_trueprogspeed, TweenInfo.new(1, Enum.EasingStyle.Quint), {
		Position = object.reel_trueprogspeed.Position + UDim2.fromScale(0, 0.739)
	}):Play()
	self.dangerBar.Visible = true
	TweenService:Create(self.dangerBar, TweenInfo.new(3, Enum.EasingStyle.Quint), {
		Size = UDim2.fromScale(0.539, 0.269)
	}):Play()
	task.wait(1)
	local v10 = CameraShaker.new(Enum.RenderPriority.Camera.Value + 1, function(p)
		if not object.active then
			return
		end

		currentCamera.CFrame = cFrame4 * p
	end, "VeiledCameraShake")
	v10:Start()
	v10:ShakeSustain(CameraShaker.Presets.Earthquake)
	self.reelTrove:Add(function()
		v10:StopSustained(1)
		task.delay(1, function()
			v10:Stop()
		end)
	end)
	object:AddModifier("trueprogressefficiency", "add", self.config.TrueProgressSpeed * 0.01)
	object:AddModifier("progressefficiency", "force_add", self.config.ForcedProgressSpeed * 0.01)
	object:AddModifier("progressLossMultiplier", "multiply", self.config.ProgressLossMultiplier)
	object.progressLocked = false
	object:AddProgress((20 - object.progress) / object.trueprogressefficiency)
	self._lastProgress = 20
	object:Update(0)
	object.logicPaused = false
	object.fishmove = tick()
	object.frozenUntil = 0
	object.core.fish:MoveRandom()
	object.core.minigame.NoComplete = false
	object.core.fish.Disabled = false
	object.core.minigame.Disabled = false
end

local whirpools = {}

function VeiledCharybdisBehavior:TickLogic_Rod(object2, p: number)
	if not object2.active then
		return
	end

	if self.veiledActive then
		self.nextSpawn -= p
		local v7 = object2.progress - self._lastProgress

		if self.currentDanger < 100 and self._lastProgress > 0 then
			if v7 > 0 then
				self.currentDanger = math.clamp(self.currentDanger + v7 * self.config.ProgressGainPullRatio, 0, 100)
			else
				self.currentDanger = math.clamp(self.currentDanger + v7 * self.config.ProgressLossPullRatio, 0, 100)
			end
		end

		self._lastProgress = object2.progress

		if self.currentDanger >= 100 and object2.active then
			if object2.core.minigame.NoFail then
				object2:AddProgress(-1000 / math.max(object2.trueprogressefficiency, 0.0001))
				self.currentDanger = 0
				self._lastProgress = 0
			else
				if self.veiledScenePlayerRoot then
					TweenService:Create(
						self.veiledScenePlayerRoot,
						TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
						{
							CFrame = cFrame
						}
					):Play()
					fx:PlaySound(sounds.scream, self.veiledScenePlayerRoot, false)
				end

				TweenService:Create(music, TweenInfo.new(2, Enum.EasingStyle.Linear), {
					Volume = music:GetAttribute("DefaultVolume") * (SettingsController:GetSettingValue("musicVolume") / 100)
				}):Play()
				local tween = TweenService:Create(sounds.Music, TweenInfo.new(2, Enum.EasingStyle.Linear), {
					Volume = 0
				})
				tween.Completed:Once(function()
					sounds.Music:Stop()
				end)
				tween:Play()
				object2:AddCleanupDelay(5)
				object2:EndMinigame(false)
				task.wait(0.35)
				fx:PlaySound(sounds.growl, mouth, false)
				self.reelTrove:Add(animator:LoadAnimation(anims.FishAttack)):Play(0.1)
				return
			end
		end

		while self.nextSpawn <= 0 do
			self:SpawnWhirlpool(object2)
		end

		for _, whirpool in ipairs(self.whirpools) do
			self:TickWhirlpoolLogic(object2, whirpool, p)

			if not (whirpool.lifetime <= 0) then
				continue
			end

			if whirpool.guiObject then
				local guiObject = whirpool.guiObject
				TweenService:Create(
					guiObject.UIScale,
					TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						Scale = 0
					}
				):Play()
				task.delay(0.5, function()
					guiObject:Destroy()
				end)
			end

			local _barSizeModifier = whirpool._barSizeModifier
			TweenService:Create(_barSizeModifier, TweenInfo.new(3, Enum.EasingStyle.Quint), {
				Value = 0
			}):Play()
			task.delay(3, function()
				_barSizeModifier:Destroy()
			end)
			table.insert(whirpools, whirpool)
		end

		for _, v8 in ipairs(whirpools) do
			local index = table.find(self.whirpools, v8)

			if index then
				table.remove(self.whirpools, index)
			end
		end

		table.clear(whirpools)
	elseif self.current.progress >= 100 then
		task.spawn(self.StartVeiledPhase, self, object2)
	end
end

function VeiledCharybdisBehavior:TickRender_Rod(state, p: number)
	local smoothDamp, dangerBarVelocity = TweenService:SmoothDamp(
		self.dangerBar.bar.Size.X.Scale,
		math.clamp(self.currentDanger / 100, 0, 1),
		self._dangerBarVelocity,
		0.1,
		nil,
		p
	)
	self._dangerBarVelocity = dangerBarVelocity
	self.dangerBar.bar.Size = UDim2.fromScale(smoothDamp, 1)
	local warnLeft = self.dangerBar.warnLeft
	warnLeft.Visible = self.currentDanger > 75 and tick() % 0.25 > 0.125
	self.dangerBar.warnRight.Visible = self.dangerBar.warnLeft.Visible
	self.dangerGlow1.Transparency = 1 - self.currentDanger / 100
	self.dangerGlow2.Transparency = 0.5 - self.currentDanger / 200

	for _, whirpool in ipairs(self.whirpools) do
		self:TickWhirlpoolRender(state, whirpool, p)
	end

	if self.veiledScenePlayerRoot and state.active then
		local veiledScenePlayerRoot = self.veiledScenePlayerRoot
		local smoothDamp2, playerVel = TweenService:SmoothDamp(
			self.veiledScenePlayerRoot.CFrame,
			v:Lerp(v2, self.currentDanger / 100),
			self._playerVel,
			0.5,
			nil,
			p
		)
		veiledScenePlayerRoot.CFrame = smoothDamp2
		self._playerVel = playerVel
		local attachment = state.rod and state.rod:QueryDescendants("> BasePart#bobber > Attachment#mouth0")[1]

		if attachment and attachment:IsA("Attachment") then
			attachment.WorldCFrame = mouth.WorldCFrame
		end

		state.fishPos = mouth.WorldPosition
	end
end

local function fadeOut(p, p2: number)
	TweenService:Create(p, TweenInfo.new(p2 * 0.9, Enum.EasingStyle.Linear), {
		BackgroundTransparency = 1
	}):Play()
end

function VeiledCharybdisBehavior:SpawnWhirlpool(object)
	self.nextSpawn += self.random:NextNumber(self.config.WhirlpoolIntervalMin, self.config.WhirlpoolIntervalMax)
	local number = self.random:NextNumber(0 + self.config.WhirlpoolSize * 0.5, 1 - self.config.WhirlpoolSize * 0.5)
	local guiObject = self.reelTrove:Add(UI.whirlpool:Clone())
	guiObject.Position = UDim2.fromScale(number, 0.5)
	guiObject.Size = UDim2.fromScale(self.config.WhirlpoolSize, self.config.WhirlpoolSize)
	guiObject.UIScale.Scale = 0
	local v8 = {
		guiObject = guiObject,
		position = number,
		rotation = 0,
		lifetime = self.config.WhirlpoolLifetime,
		_barSizeModifier = object:CreateModifier("barSize", "add"),
		targetBarSize = 0,
		barSizeVel = 0
	}
	guiObject.Parent = self.container
	TweenService:Create(guiObject.UIScale, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
		Scale = 1
	}):Play()
	table.insert(self.whirpools, v8)
end

function VeiledCharybdisBehavior:TickWhirlpoolLogic(object, state2, p: number)
	state2.lifetime -= p

	if object:IsInBar(state2.position, self.config.WhirlpoolSize) then
		if object.barSize > 0 then
			state2.targetBarSize -= self.config.WhirlpoolControlReduction * p
			self.currentDanger += self.config.WhirlpoolDangerRate * p
		end
	else
		state2.targetBarSize = 0
	end

	local v7 = state2.position - object.barPosition
	local v8 = math.sign(v7)
	local v9 = 1 - math.abs(v7)
	object.core.rod.CurrentVelocity += v8 * v9 * self.config.WhirlpoolPullPower * p
end

function VeiledCharybdisBehavior:TickWhirlpoolRender(_, state, p: number)
	state.rotation += p * 180
	state.guiObject.whirlpool.Rotation = state.rotation
	local v7 = state.targetBarSize - state._barSizeModifier.Value
	local _barSizeModifier = state._barSizeModifier
	local smoothDamp, barSizeVel = TweenService:SmoothDamp(
		state._barSizeModifier.Value,
		state.targetBarSize,
		state.barSizeVel,
		v7 > 0 and 3 or 0.5,
		nil,
		p
	)
	_barSizeModifier.Value = smoothDamp
	state.barSizeVel = barSizeVel
end

setmetatable(VeiledCharybdisBehavior, module)
return VeiledCharybdisBehavior