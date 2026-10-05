local FlameslasherBehavior = {}
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
game:GetService("GuiService")
local fx = require(ReplicatedStorage.shared.modules.fx)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local LightingController = require(ReplicatedStorage.client.legacyControllers.LightingController)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local module = require("./PassiveHandler")
local random = Random.new()

function FlameslasherBehavior:Morph(parent, object2)
	ContentProvider:PreloadAsync(script:GetChildren())
	ContentProvider:PreloadAsync({ "rbxassetid://1842907382" })
	self.random = object2:GetRandom(6)
	self.nextSpawn = self.config.FireballInterval
	self.currentOverload = 0
	self.container = script.fireballContainer:Clone()
	self.container.Parent = parent
	self.overloadBar = script.overload:Clone()
	self.overloadBar.bar.Size = UDim2.fromScale(0, 1)
	self.overloadBar.Parent = parent
	self.pbarGlow = script.glow:Clone()
	self.pbarGlow.Parent = parent.playerbar
	self.barGlow = script.glow:Clone()
	self.barGlow.Parent = parent
	local modifier = self.current:CreateModifier("accel", "multiply")
	local modifier2 = self.current:CreateModifier("barSize", "multiply")
	local modifier3 = self.current:CreateModifier("progressefficiency", "force_final")
	local modifier4 = self.current:CreateModifier("progressLossMultiplier", "multiply")
	modifier3.Value = 0
	modifier.Value = 2.5
	self.current.trueprogspeed_format = ""
	self.current:AddModifier("trueprogressefficiency", "force_final", 0.5)
	local v = 0
	playerDataReplicator:WaitForLoaded()
	self.skillIssueFactor = math.clamp(
		(playerDataReplicator:TryIndex({ "FishSkillIssueFactor", self.current.fish.Name }) or 0) - 5,
		0,
		100
	)

	if self.current.data.IgnoreSkillIssueFactor then
		self.skillIssueFactor = 0
	end

	self.current.reel_progspeed.Position += UDim2.fromScale(0, 0.739)
	local music = SoundService:WaitForChild("music")
	TweenService:Create(music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		Volume = 0
	}):Play()
	self.reelTrove:Add(function()
		TweenService:Create(music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			Volume = music:GetAttribute("DefaultVolume") * (SettingsController:GetSettingValue("musicVolume") / 100)
		}):Play()
		local tween = TweenService:Create(script.Music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			Volume = 0
		})
		tween.Completed:Once(function()
			script.Music:Stop()
		end)
		tween:Play()
	end)
	self.reelTrove:Add(self.current.OnSlash:Connect(function(_, _, p)
		self.currentOverload += 20 + p * 5
	end))
	self.reelTrove:Add(self.current.OnReady:Once(function()
		script.Music.Volume = 0.75
		script.Music:Play()
		local v2 = self.trove:Add(script.darken:Clone())
		v2.BackgroundTransparency = 1
		v2.Parent = object2.reel
		TweenService:Create(v2, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
			BackgroundTransparency = 0.25
		}):Play()
		object2.OnMinigameEnd:Once(function()
			local tween = TweenService:Create(v2, TweenInfo.new(1), {
				BackgroundTransparency = 1
			})
			tween.Completed:Once(function()
				v2:Destroy()
				tween:Destroy()
			end)
			tween:Play()
		end)
	end))
	local flag = false
	self.current.BuildEndingData:Bind(function(p)
		p.Flameslasher_FinalOverload = self.currentOverload
		p.Flameslasher_OverloadDeath = flag
		return p
	end)
	self.reelTrove:Add(object2.OnLogicStep:Connect(function(p: number)
		if flag then
			return
		end

		local smoothDamp, v2 = TweenService:SmoothDamp(
			self.overloadBar.bar.Size.X.Scale,
			math.clamp(self.currentOverload / 100, 0, 1),
			v,
			0.25,
			nil,
			p
		)
		v = v2
		self.overloadBar.bar.Size = UDim2.fromScale(smoothDamp, 1)

		if not self.current.active or self.current.isPaused then
			return
		end

		self.nextSpawn -= p

		if self.currentOverload < 100 then
			self.currentOverload = math.max(self.currentOverload + self.config.OverloadDecay * p, 0)
			modifier2.Value = 1 - self.currentOverload / 100 * 0.75 * math.clamp(1 - self.skillIssueFactor / 10, 0, 1)
			modifier3.Value = self.currentOverload / 100 * 0.5 + self.skillIssueFactor / 10
			modifier4.Value = self.currentOverload / 400

			if self.nextSpawn <= 0 then
				self:SpawnFireball()
			end

			local warnLeft = self.overloadBar.warnLeft
			warnLeft.Visible = self.currentOverload > 75 and tick() % 0.25 > 0.125
			self.overloadBar.warnRight.Visible = self.overloadBar.warnLeft.Visible
			self.overloadBar.bar.glow.ImageTransparency = 1 - self.currentOverload / 100
		else
			flag = true
			self:OverloadAnimation()
		end
	end))
end

function FlameslasherBehavior:SpawnFireball()
	self.nextSpawn += self.config.FireballInterval
	local fishPosition = self.current.fishPosition
	local clone = script.fireball:Clone()
	clone.Position = UDim2.fromScale(fishPosition, 0)
	clone.Rotation = self.random:NextNumber(-self.config.FireballAngle, self.config.FireballAngle)
	clone.falling.Position = UDim2.fromScale(0.5, -self.config.FireballDistance)
	clone.falling.Size = UDim2.fromScale(self.config.FireballSize * 3, 20)
	clone.falling.ImageTransparency = 1
	clone.Parent = self.container
	local v = self.current.logicTweens:Create(
		clone.falling,
		TweenInfo.new(self.config.FireballFallTime, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
		{
			Position = UDim2.fromScale(0.5, 0.5)
		}
	)
	self.current.logicTweens:Create(
		clone.falling,
		TweenInfo.new(self.config.FireballFallTime * 0.25, Enum.EasingStyle.Linear),
		{
			ImageTransparency = 0
		}
	):Play()
	local thread = task.spawn(function()
		while clone.Parent and clone:FindFirstChild("falling") do
			for i = 0, 896, 128 do
				for i2 = 0, 896, 128 do
					if not clone:FindFirstChild("falling") then
						return
					end

					clone.falling.ImageRectOffset = Vector2.new(i2, i)
					task.wait(0.025)
				end
			end
		end
	end)
	v.Completed:Once(function()
		if not self.config then
			clone:Destroy()
			return
		end

		if self.current:IsInBar(fishPosition, self.config.FireballSize) then
			self:OnHit(fishPosition)
		else
			self:OnMiss(fishPosition)
		end

		clone:Destroy()
		pcall(task.cancel, thread)
		local clone2 = script.explosion:Clone()
		clone2.Position = UDim2.fromScale(fishPosition, 0.5)
		clone2.Parent = self.container
		fx:PlaySound(script.Explosion, self.reel, random:NextNumber(1, 2))

		for i = 0, 384, 128 do
			for i2 = 0, 384, 128 do
				clone2.ImageRectOffset = Vector2.new(i2, i)
				task.wait(0.025)
			end
		end

		clone2:Destroy()
	end)
	v:Play()
end

function FlameslasherBehavior:OnHit(_: number)
	self.currentOverload = math.max(self.currentOverload + self.config.FireballHitOverload, 0)
	self.current:AddProgress(self.config.FireballHitProgress * (self.currentOverload / 100) * (1 + self.skillIssueFactor / 10))
	self.pbarGlow.ImageTransparency = 0
	self.current.renderTweens:Create(self.pbarGlow, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
		ImageTransparency = 1
	}):Play()
end

function FlameslasherBehavior:OnMiss(_: number)
	self.currentOverload = math.max(self.currentOverload + self.config.FireballMissOverload, 0)
	self.current:AddProgress(self.config.FireballMissProgress * (1 - self.currentOverload / 100) * (1 + self.skillIssueFactor / 10))
	self.barGlow.ImageTransparency = 0
	self.current.renderTweens:Create(self.barGlow, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
		ImageTransparency = 1
	}):Play()
end

function FlameslasherBehavior:OverloadAnimation()
	local connection = LightingController.HookLighting:BindAtPriority(9999999, function(data)
		data.Lighting.ClockTime = 12
		data.Atmosphere.Haze = 0
		data.ColorCorrectionEffect.Saturation = 0.45
		data.ColorCorrectionEffect.Contrast = 0
		data.Lighting.Ambient = Color3.fromRGB(170, 170, 170)
		data.Lighting.OutdoorAmbient = Color3.fromRGB(240, 240, 240)
		return data
	end)
	LightingController.UpdateLighting(0)
	local absolutePosition = self.overloadBar.AbsolutePosition
	local absoluteSize = self.overloadBar.AbsoluteSize
	local clone = script.glow2:Clone()
	clone.Position = UDim2.fromOffset(absolutePosition.X + absoluteSize.X / 2, absolutePosition.Y + absoluteSize.Y / 2)
	clone.ImageTransparency = 1
	clone.Parent = self.current.reel
	self.overloadBar.stroke.UIGradient.Enabled = false
	self.overloadBar.bar.UIGradient.Enabled = false
	self.overloadBar.bar.glow.ImageColor3 = Color3.fromRGB(255, 255, 255)
	self.overloadBar.bar.glow.UIGradient.Enabled = false
	self.overloadBar.bar.Size = UDim2.fromScale(1, 1)
	script.PreEruption.Volume = 0.001
	script.PreEruption:Play()
	TweenService:Create(script.PreEruption, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
		Volume = 1
	}):Play()
	local lastTime = tick()
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local value = TweenService:GetValue(
			math.clamp(tick() - lastTime, 0, 1),
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.In
		)
		self.overloadBar.Position = UDim2.fromScale(
			0.5 + random:NextNumber(-0.5, 0.5) * value,
			3.25 + random:NextNumber(-2, 2) * value
		)
	end)
	TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
		ImageTransparency = 0
	}):Play()
	TweenService:Create(clone.UIScale, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
		Scale = 10
	}):Play()
	task.wait(1)
	self.current.core.ui.CameraShake_Enabled = false

	if self.current.core.ui.CameraShake_CurrentShake then
		self.current.core.ui.CameraShake_CurrentShake.Stop()
	end

	script.PreEruption:Stop()
	renderSteppedConnection:Disconnect()
	self.current.reel_bar.Visible = false
	self.current.reel.Enabled = false
	local cFrame = CFrame.new(-24126.266, 2670.526, -4952.935) * CFrame.fromOrientation(
		-0.4508010924976154,
		-0.1659633585721408,
		-0
	)
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.CurrentCamera.CFrame = cFrame
	workspace.CurrentCamera.Focus = CFrame.new(-24106, 2603.391, -5068.882)
	task.wait(0.5)

	if not SettingsController:GetSettingValue("photosensitiveMode") then
		task.spawn(function()
			local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect.Name = "EruptionCC"
			colorCorrectionEffect.Parent = Lighting
			colorCorrectionEffect.Brightness = 0
			colorCorrectionEffect.Saturation = -1.45
			colorCorrectionEffect.Contrast = -100
			colorCorrectionEffect.TintColor = Color3.new(1, 1, 1)
			task.wait(0.1)
			colorCorrectionEffect.Contrast = 100
			task.wait(0.1)
			colorCorrectionEffect.Contrast = 0
			colorCorrectionEffect.Saturation = 0
			colorCorrectionEffect.Brightness = 1
			colorCorrectionEffect.TintColor = Color3.fromRGB(255, 155, 155)
			TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
				Brightness = 0,
				TintColor = Color3.fromRGB(255, 255, 255)
			}):Play()
			task.wait(1)
			colorCorrectionEffect:Destroy()
		end)
	end

	local clone2 = script.eruption:Clone()
	clone2.Parent = workspace
	fx:ShakeScreen(game.Players.LocalPlayer, 1, 1, true)
	script.Eruption1:Play()
	script.Eruption2:Play()
	script.Eruption3:Play()

	for _ = 1, 3 do
		for _, v2 in clone2:QueryDescendants("ParticleEmitter") do
			v2:Emit(v2:GetAttribute("EmitCount"))
		end

		task.wait(0.1)
	end

	if self.current.active then
		self.current:EndMinigame(false)
	end

	task.wait(3)
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	clone2:Destroy()
	connection:Disconnect()
end

setmetatable(FlameslasherBehavior, module)
return FlameslasherBehavior