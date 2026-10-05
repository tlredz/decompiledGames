local createVector = vector.create
local HadesGodFight = {}
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("fishing"):WaitForChild("slashes")
ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("fishing")
local color = Color3.fromRGB(189, 84, 255)
local color2 = Color3.fromRGB(59, 140, 47)

function HadesGodFight:BarToScreenX(p2: number)
	local reel_bar = self.current.reel_bar
	local absolutePosition = reel_bar.AbsolutePosition
	local absoluteSize = reel_bar.AbsoluteSize
	local absoluteSize2 = self.current.reel.AbsoluteSize
	return (absolutePosition.X + p2 * absoluteSize.X) / absoluteSize2.X
end

function HadesGodFight:GetBarScreenY()
	return self.current.reel_bar.Position.Y.Scale
end

function HadesGodFight:CheckHitScreenX(p: number, value: number?)
	local v = (self.current.barSize or self.config.DodgeBarSize or 0.3) / 2
	local barToScreenX = self:BarToScreenX(self.current.barPosition)
	local scale = self.current.reel_bar.Size.X.Scale
	local v2 = (value or 0.02) * scale / 2
	local v3 = p - v2
	local v4 = p + v2
	local v5 = barToScreenX - v * scale
	local v6 = barToScreenX + v * scale

	if v5 <= v4 and v3 <= v6 then
		return true, false
	end

	local v7 = (self.config.NearMissRange or 0.06) * scale
	return false, v5 - v7 <= v4 and v3 <= v6 + v7
end

function HadesGodFight:HitEffect(backgroundColor: Color3)
	local current = self.current

	if not current then
		return
	end

	current.fx:SpawnShake(current.reel_bar, 0.7, 0.4, 0.015, true)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = backgroundColor
	frame.BackgroundTransparency = 0.3
	frame.ZIndex = 20
	frame.Parent = current.reel_playerbar
	local tween = TweenService:Create(frame, TweenInfo.new(0.4), {
		BackgroundTransparency = 1
	})
	tween.Completed:Once(function()
		frame:Destroy()
		tween:Destroy()
	end)
	tween:Play()
end

function HadesGodFight:SpawnDodgeText()
	local current = self.current

	if not (current and current.active) then
		return
	end

	local barScreenY = self:GetBarScreenY()
	local barToScreenX = self:BarToScreenX(current.barPosition)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "DodgeText"
	textLabel.Size = UDim2.new(0.1, 0, 0.03, 0)
	textLabel.Position = UDim2.fromScale(barToScreenX, barScreenY - 0.04)
	textLabel.AnchorPoint = Vector2.new(0.5, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextStrokeTransparency = 0.3
	textLabel.TextStrokeColor3 = Color3.fromRGB(40, 40, 40)
	textLabel.Font = Enum.Font.Fondamento
	textLabel.TextScaled = true
	textLabel.Text = "DODGE!"
	textLabel.ZIndex = 25
	textLabel.Parent = current.reel
	TweenService:Create(textLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(barToScreenX, barScreenY - 0.08),
		TextTransparency = 1,
		TextStrokeTransparency = 1
	}):Play()
	task.delay(0.55, function()
		if textLabel.Parent then
			textLabel:Destroy()
		end
	end)
end

function HadesGodFight:GetPhaseSpeedMult()
	if self.currentPhase >= 4 then
		return 0.5
	end

	if self.currentPhase >= 3 then
		return 0.7
	end

	if self.currentPhase >= 2 then
		return 0.85
	end

	return 1
end

function HadesGodFight:GetBiasedTargetX(min: number, max: number)
	if self.random:NextNumber(0, 1) < 0.5 then
		return (math.clamp(self.current.barPosition + self.random:NextNumber(-0.15, 0.15), min, max))
	end

	return self.random:NextNumber(min, max)
end

function HadesGodFight:DamageHealth(p: number)
	if not self.fightActive then
		return
	end

	if self.config.IsGodFight then
		self.health = math.max(0, self.health - p)

		if self.health <= 0 then
			self.fightActive = false
			self:OnFightFailed()
		end
	else
		self.current:AddProgress(-p)
	end
end

function HadesGodFight:GetHealthPercent()
	return (math.clamp(self.health / self.maxHealth, 0, 1))
end

function HadesGodFight:CreateHealthBar()
	local config = self.config
	local frame = Instance.new("Frame")
	frame.Name = "GodFightHealthBar"
	frame.Size = UDim2.new(1, 0, 0, 16)
	frame.Position = UDim2.new(0, 0, 1, 8)
	frame.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
	frame.BackgroundTransparency = 0.2
	frame.ZIndex = 10
	local uICorner = Instance.new("UICorner", frame)
	uICorner.CornerRadius = UDim.new(0, 4)
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = Color3.fromRGB(120, 30, 30)
	uIStroke.Thickness = 2
	uIStroke.Transparency = 0.2
	uIStroke.Parent = frame
	local frame2 = Instance.new("Frame")
	frame2.Name = "DamageFill"
	frame2.Size = UDim2.fromScale(1, 1)
	frame2.BackgroundColor3 = config.HealthBarDamagedColor or Color3.fromRGB(100, 15, 15)
	frame2.BackgroundTransparency = 0.3
	frame2.ZIndex = 11
	local uICorner_2 = Instance.new("UICorner", frame2)
	uICorner_2.CornerRadius = UDim.new(0, 3)
	frame2.Parent = frame
	local frame3 = Instance.new("Frame")
	frame3.Name = "Fill"
	frame3.Size = UDim2.fromScale(1, 1)
	frame3.BackgroundColor3 = config.HealthBarColor or Color3.fromRGB(200, 35, 35)
	frame3.ZIndex = 12
	local uICorner_3 = Instance.new("UICorner", frame3)
	uICorner_3.CornerRadius = UDim.new(0, 3)
	frame3.Parent = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextStrokeTransparency = 0.5
	textLabel.TextStrokeColor3 = Color3.fromRGB(40, 0, 0)
	textLabel.Font = Enum.Font.Fondamento
	textLabel.TextScaled = true
	textLabel.Text = "SURVIVE"
	textLabel.ZIndex = 13
	textLabel.Parent = frame
	frame.Parent = self.current.reel_bar
	self.healthFill = frame3
	self.healthDamageFill = frame2
	self.healthText = textLabel
end

function HadesGodFight:CreateTimer()
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(0.5, 0, 0, 22)
	textLabel.Position = UDim2.new(0.5, 0, 1, 30)
	textLabel.AnchorPoint = Vector2.new(0.5, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 200, 200)
	textLabel.TextStrokeTransparency = 0.2
	textLabel.TextStrokeColor3 = Color3.fromRGB(80, 0, 0)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.Fondamento
	textLabel.Text = ""
	textLabel.ZIndex = 12
	textLabel.Parent = self.current.reel_bar
	self.timerLabel = textLabel
end

function HadesGodFight:CreateOverlay()
	local dim = Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Dim")

	if not dim then
		return
	end

	dim.Enabled = true
	local frame = dim:FindFirstChildWhichIsA("Frame")

	if not frame then
		return
	end

	self.dimFrame = frame
	self.dimGui = dim
	TweenService:Create(frame, TweenInfo.new(2, Enum.EasingStyle.Sine), {
		BackgroundTransparency = self.config.OverlayTransparency or 0.55
	}):Play()
end

function HadesGodFight:CreateSilhouette()
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Size = UDim2.new(0.25, 0, 0.2, 0)
	imageLabel.Position = UDim2.new(0.5, 0, 0.06, 0)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://139243612378118"
	imageLabel.ImageColor3 = color2
	imageLabel.ImageTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.ZIndex = 2
	imageLabel.Parent = self.current.reel
	TweenService:Create(imageLabel, TweenInfo.new(3, Enum.EasingStyle.Sine), {
		ImageTransparency = 0.15
	}):Play()
	self.silhouette = imageLabel
end

function HadesGodFight:ShowPhaseText(text: string)
	local current = self.current

	if not (current and current.active) then
		return
	end

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(0.25, 0, 0.035, 0)
	textLabel.Position = UDim2.fromScale(0.5, 0.45)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(108, 255, 162)
	textLabel.TextStrokeTransparency = 0.1
	textLabel.TextStrokeColor3 = Color3.fromRGB(37, 80, 40)
	textLabel.Font = Enum.Font.Fondamento
	textLabel.TextScaled = true
	textLabel.Text = text
	textLabel.ZIndex = 25
	textLabel.Parent = current.reel
	TweenService:Create(textLabel, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0.5, 0, 0.07, 0)
	}):Play()
	task.delay(1.5, function()
		if not textLabel.Parent then
			return
		end

		TweenService:Create(textLabel, TweenInfo.new(0.5), {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}):Play()
		task.delay(0.55, function()
			if textLabel.Parent then
				textLabel:Destroy()
			end
		end)
	end)
end

function HadesGodFight:OnFightComplete()
	if not (self.current and self.current.active) then
		return
	end

	self.fightActive = false
	fx:ShakeScreen(Players.LocalPlayer, 3, 2)

	if self.healthFill then
		TweenService:Create(self.healthFill, TweenInfo.new(0.5), {
			BackgroundColor3 = Color3.fromRGB(80, 200, 80)
		}):Play()
	end

	if self.healthText then
		self.healthText.Text = "SEAL BROKEN"
		self.healthText.TextColor3 = Color3.fromRGB(180, 255, 180)
	end

	if self.timerLabel then
		self.timerLabel.Text = "VICTORY"
		self.timerLabel.TextColor3 = Color3.fromRGB(180, 255, 180)
	end

	task.delay(1.5, function()
		if self.current and self.current.active then
			self.current:EndMinigame(true)
		end
	end)
end

function HadesGodFight:OnFightFailed()
	if not (self.current and self.current.active) then
		return
	end

	self.fightActive = false
	fx:ShakeScreen(Players.LocalPlayer, 5, 1)

	if self.healthFill then
		TweenService:Create(self.healthFill, TweenInfo.new(0.3), {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		}):Play()
	end

	if self.healthDamageFill then
		TweenService:Create(self.healthDamageFill, TweenInfo.new(0.5), {
			Size = UDim2.fromScale(0, 1)
		}):Play()
	end

	if self.healthText then
		self.healthText.Text = "DEFEATED"
		self.healthText.TextColor3 = Color3.fromRGB(255, 80, 80)
	end

	if self.timerLabel then
		self.timerLabel.Text = "DEFEATED"
		self.timerLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
	end

	task.delay(1.5, function()
		if self.current and self.current.active then
			self.current:EndMinigame(false)
		end
	end)
end

function HadesGodFight:SpawnBeam(p: number)
	local function fadeOut(p2, p3: number)
		self.current.logicTweens:Create(p2, TweenInfo.new(p3 * 0.9, Enum.EasingStyle.Linear), {
			BackgroundTransparency = 1
		}):Play()
	end

	local clone = script.warning:Clone()
	local laser = clone.laser
	local absoluteSize = self.reel.Parent.AbsoluteSize
	local absolutePosition = self.reel.Parent.AbsolutePosition
	local absolutePosition2 = self.reel.AbsolutePosition
	local v = absoluteSize.Y - absolutePosition.Y - absolutePosition2.Y
	clone.Size = UDim2.new(self.config.BeamWidth, 0, 0, absoluteSize.Y + GuiService:GetGuiInset().Y)
	clone.Position = UDim2.new(p, 0, 0, v)
	clone.warnFill.Size = UDim2.fromScale(1, 0)
	laser.Visible = false
	clone.Parent = self.laserContainer
	self.current.logicTweens:Create(clone.warnFill, TweenInfo.new(self.config.BeamWarnTime, Enum.EasingStyle.Linear), {
		Size = UDim2.fromScale(1, 1)
	}):Play()

	for _ = 1, 4 do
		clone.BackgroundTransparency = 0.5
		clone.borderLeft.BackgroundTransparency = 0
		clone.borderRight.BackgroundTransparency = 0
		fadeOut(clone, self.config.BeamWarnTime / 4)
		fadeOut(clone.borderLeft, self.config.BeamWarnTime / 4)
		fadeOut(clone.borderRight, self.config.BeamWarnTime / 4)
		fx:PlaySound(script.WarningSound, self.reel, false)
		self.current:WaitLogic(self.config.BeamWarnTime / 4)
	end

	laser.detail1.Position = UDim2.fromScale(0.5, 0)
	laser.detail2.Position = UDim2.fromScale(0.5, 0)
	laser.detail3.Position = UDim2.fromScale(0.5, -2)
	clone.warnFill.Visible = false
	clone.exclamation.Visible = false
	laser.Visible = true
	self.current.logicTweens:Create(laser.detail1, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
		Position = UDim2.fromScale(0.5, -2)
	}):Play()
	self.current.logicTweens:Create(laser.detail2, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
		Position = UDim2.fromScale(0.5, -2)
	}):Play()
	self.current.logicTweens:Create(laser.detail3, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
		Position = UDim2.fromScale(0.5, 0)
	}):Play()
	self.current:DelayLogic(0.25, function()
		for _, child in laser:GetChildren() do
			self.current.logicTweens:Create(child, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
				ImageTransparency = 1
			}):Play()
		end
	end)
	fx:PlaySound(script.LaserSound, self.reel, true, "FishingSound")

	if self.current:IsInBar(p, self.config.BeamWidth) then
		self:DamageHealth(self.config.BeamDamage)
		self:HitEffect(color)
	else
		self.current.fx:SpawnShake(self.reel, 0.15, 0.25, 0.01, false)
	end

	self.current:WaitLogic(0.7)
	clone:Destroy()
end

function HadesGodFight:SpawnWisp()
	local v = self.current.barSize <= self.config.WispIncreaseThreshold

	if not v then
		if self.current.barSize >= self.config.WispReduceThreshold then
			v = false
		else
			v = self.random:NextInteger(1, 2) == 1
		end
	end

	local v2 = self.random:NextNumber(self.config.WispControlMin, self.config.WispControlMax) * (v and 1 or -1)

	if not v then
		v2 = math.max(v2, -(self.current.barSize - 0.05))
	end

	local v3 = math.max(math.abs(v2) // 0.05, 1)
	local absoluteSize = self.reel.Parent.AbsoluteSize

	for i = 1, v3 do
		self.current:DelayLogic((i - 1) * 0.05, function()
			local clone = v and script.wispLight:Clone() or script.wispDark:Clone()
			local unit = (Random.new():NextUnitVector() * createVector(1, 1, 0)).Unit
			local v4 = Vector2.new(unit.X, unit.Y) * absoluteSize
			local uDim = UDim2.fromScale(math.random(), math.random())
			clone.Position = uDim + UDim2.fromOffset(v4.X, v4.Y)
			clone.Parent = self.current.reel_playerbar

			for _, image in clone:GetChildren() do
				if not image:IsA("ImageLabel") then
					continue
				end

				local imageTransparency = image.ImageTransparency
				image.ImageTransparency = 1
				self.current.logicTweens:Create(image, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
					ImageTransparency = imageTransparency
				}):Play()
			end

			local v5 = self.current.logicTweens:Create(
				clone,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					Position = uDim
				}
			)
			v5.Completed:Once(function()
				clone:Destroy()
				v5:Destroy()
			end)
			v5:Play()
		end)
	end

	fx:PlaySound(script.WispSpawn, self.reel, true, "FishingSound")
	self.current:WaitLogic(0.5)
	self.current.logicTweens:Create(self.controlModifier, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
		Value = self.controlModifier.Value + v2
	}):Play()
	self.targetPS *= 1 - self.config.WispProgressSpeedReduce
	self.current.logicTweens:Create(self.progSpeedModifier, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
		Value = self.targetPS
	}):Play()
	local clone = v and script.glowLight:Clone() or script.glowDark:Clone()
	clone.ImageTransparency = 0
	clone.Visible = true
	clone.Parent = self.current.reel_playerbar
	local v4 = self.current.logicTweens:Create(clone, TweenInfo.new(2, Enum.EasingStyle.Linear), {
		ImageTransparency = 1
	})
	v4.Completed:Once(function()
		clone:Destroy()
		v4:Destroy()
	end)
	v4:Play()
end

function HadesGodFight:RunBeams()
	local current = self.current
	local config = self.config

	while current.active and self.fightActive do
		local v = tick() - self.fightStartTime
		local v2 = (config.BeamRamp or 0.02) * v
		current:WaitLogic((math.max(
			1,
			self.random:NextNumber(config.BeamMinInterval, config.BeamMaxInterval) * self:GetPhaseSpeedMult() - v2
		)))

		if current.active and self.fightActive then
			task.spawn(self.SpawnBeam, self, self:GetBiasedTargetX(0.08, 0.92))
		else
			break
		end
	end
end

function HadesGodFight:RunWisps()
	local current = self.current
	local config = self.config

	while current.active and self.fightActive do
		local v = tick() - self.fightStartTime
		local v2 = (config.WispRamp or 0.02) * v
		current:WaitLogic((math.max(
			1,
			self.random:NextNumber(config.WispMinInterval, config.WispMaxInterval) * self:GetPhaseSpeedMult() - v2
		)))

		if current.active and self.fightActive then
			task.spawn(self.SpawnWisp, self, self:GetBiasedTargetX(0.08, 0.92))
		else
			break
		end
	end
end

function HadesGodFight:Morph(parent, object2)
	local config = self.config
	local isGodFight = config.IsGodFight == true
	task.spawn(ContentProvider.PreloadAsync, ContentProvider, { "rbxassetid://139243612378118", script.warning })
	self.laserContainer = script.laserContainer:Clone()
	self.laserContainer.Parent = parent
	self.maxHealth = config.MaxHealth or 200
	self.health = self.maxHealth
	self.fightActive = false
	self.fightStartTime = 0
	self.currentPhase = 0
	self.random = object2:GetRandom(8)
	self.controlModifier = object2:CreateModifier("barSize", "force_add")
	self.progSpeedModifier = object2:CreateModifier("progressefficiency", "force_multiply")
	self.progSpeedModifier.Value = 1
	self.targetPS = 1

	if isGodFight then
		object2:AddModifier("barSize", "force", config.DodgeBarSize or 0.3)
		object2.core.minigame.NoFail = true
		object2.core.ui.OnBarEffects_Enabled = false
		object2.core.ui.ShinyNotify_Enabled = false
		object2:AddModifier("progress", "force_final", 0.1)
		object2.core.fish:Disable()
		object2.core.minigame:Disable()
		parent.fish.Visible = false
		object2.reel_progspeed.Visible = false
		object2.reel_progress.Visible = false
		local left = object2.reel_playerbar:FindFirstChild("left")
		local right = object2.reel_playerbar:FindFirstChild("right")

		if left then
			left.Visible = false
		end

		if right then
			right.Visible = false
		end

		self:CreateHealthBar()
		self:CreateTimer()
		self:CreateOverlay()
		self:CreateSilhouette()
		object2:AddCleanupDelay(2)
		object2.OnMinigameEnd:Once(function()
			self.fightActive = false

			if self.dimFrame then
				local dimGui = self.dimGui
				TweenService:Create(self.dimFrame, TweenInfo.new(1.5), {
					BackgroundTransparency = 1
				}):Play()
				task.delay(1.5, function()
					if dimGui then
						dimGui.Enabled = false
					end
				end)
			end

			if self.silhouette then
				TweenService:Create(self.silhouette, TweenInfo.new(1.5), {
					ImageTransparency = 1,
					Position = self.silhouette.Position + UDim2.fromScale(0, -0.1)
				}):Play()
			end
		end)
		object2.BuildEndingData:BindAtPriority(1000, function(p)
			p.IsGodFight = true
			p.GodName = config.GodName or "Hades"
			p.EndingHealth = self.health / self.maxHealth
			return p
		end)
	end

	task.spawn(function()
		object2:WaitUntilReady()
		self.fightActive = true
		self.fightStartTime = tick()
		self.currentPhase = 1
		task.spawn(self.RunBeams, self)
		task.spawn(self.RunWisps, self)

		if not isGodFight then
			object2.OnMinigameEnd:Once(function()
				self.fightActive = false
			end)
			return
		end

		local fightDuration = config.FightDuration or 60
		local v = fightDuration
		self:ShowPhaseText("Hades emerges!")
		task.spawn(function()
			object2:WaitLogic(fightDuration * 0.33)

			if not self.fightActive then
				return
			end

			self.currentPhase = 2
			self:ShowPhaseText("Screams of the dead echo around you...")
			fx:PlaySound(script.PhaseTransition, object2.reel, true)
			object2:WaitLogic(fightDuration * 0.33)

			if not self.fightActive then
				return
			end

			self.currentPhase = 3
			self:ShowPhaseText("Restless souls overhelm you...")
			fx:PlaySound(script.PhaseTransition, object2.reel, true)
			object2.fx:SpawnShake(object2.reel_bar, 0.3, 1, 0.02, false)
			object2:WaitLogic(fightDuration * 0.17)

			if not self.fightActive then
				return
			end

			self.currentPhase = 4
			self:ShowPhaseText((`{Players.LocalPlayer.DisplayName}... The Underworld is calling your name!`))
			fx:PlaySound(script.PhaseTransition, object2.reel, true)
			object2.fx:SpawnShake(object2.reel_bar, 0.5, 2, 0.02, true)
		end)
		self.reelTrove:Add(object2.OnLogicStep:Connect(function(p: number)
			if not (self.fightActive and object2.active) then
				return
			end

			if self.healthFill then
				local uDim = UDim2.fromScale(self:GetHealthPercent(), 1)
				self.healthFill.Size = self.healthFill.Size:Lerp(uDim, (math.min(p * 12, 1)))
				local healthPercent = self:GetHealthPercent()
				local healthBarColor = config.HealthBarColor or Color3.fromRGB(200, 35, 35)

				if healthPercent < 0.25 then
					self.healthFill.BackgroundColor3 = healthBarColor:Lerp(
						Color3.fromRGB(255, 0, 0),
						math.abs((math.sin(tick() * 4))) * 0.5
					)
				else
					self.healthFill.BackgroundColor3 = healthBarColor
				end
			end

			if self.healthDamageFill then
				local healthPercent = self:GetHealthPercent()
				local scale = self.healthDamageFill.Size.X.Scale

				if healthPercent < scale then
					self.healthDamageFill.Size = UDim2.fromScale(math.max(scale - p * 0.5, healthPercent), 1)
				else
					self.healthDamageFill.Size = UDim2.fromScale(healthPercent, 1)
				end
			end

			if self.healthText then
				self.healthText.Text = `{math.ceil(self:GetHealthPercent() * 100)}%`
			end

			v = math.max(0, v - p)

			if self.timerLabel then
				local v2 = math.ceil(v)
				self.timerLabel.Text = `{v2} Second{v2 == 1 and "" or "s"}`

				if v <= 10 then
					self.timerLabel.TextColor3 = Color3.fromRGB(200, 255, 192):Lerp(
						Color3.fromRGB(255, 100, 100),
						(math.abs((math.sin(tick() * 3))))
					)
				else
					self.timerLabel.TextColor3 = Color3.fromRGB(205, 255, 197)
				end
			end

			if v <= 0 then
				self:OnFightComplete()
			end
		end))
	end)
end

setmetatable(HadesGodFight, module)
return HadesGodFight