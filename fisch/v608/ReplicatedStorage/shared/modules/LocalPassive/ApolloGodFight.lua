local ApolloGodFight = {}
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("GuiService")
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local color = Color3.fromRGB(255, 201, 66)
local color2 = Color3.fromRGB(231, 155, 48)
local color3 = Color3.fromRGB(255, 230, 120)
local color4 = Color3.fromRGB(255, 255, 200)
Color3.fromRGB(255, 200, 60)

function ApolloGodFight:BarToScreenX(p2: number)
	local reel_bar = self.current.reel_bar
	local absolutePosition = reel_bar.AbsolutePosition
	local absoluteSize = reel_bar.AbsoluteSize
	local absoluteSize2 = self.current.reel.AbsoluteSize
	return (absolutePosition.X + p2 * absoluteSize.X) / absoluteSize2.X
end

function ApolloGodFight:GetBarScreenY()
	return self.current.reel_bar.Position.Y.Scale
end

function ApolloGodFight:HitEffect(backgroundColor: Color3)
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

function ApolloGodFight:SpawnDodgeText()
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
	textLabel.TextColor3 = Color3.fromRGB(255, 240, 150)
	textLabel.TextStrokeTransparency = 0.3
	textLabel.TextStrokeColor3 = Color3.fromRGB(100, 70, 0)
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
	current:DelayLogic(0.55, function()
		if textLabel.Parent then
			textLabel:Destroy()
		end
	end)
end

function ApolloGodFight:GetPhaseSpeedMult()
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

function ApolloGodFight:GetBiasedTargetX(min: number, max: number)
	if self.random:NextNumber(0, 1) < 0.5 then
		return (math.clamp(self.current.barPosition + self.random:NextNumber(-0.15, 0.15), min, max))
	end

	return self.random:NextNumber(min, max)
end

function ApolloGodFight:DamageHealth(p: number)
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

function ApolloGodFight:GetHealthPercent()
	return (math.clamp(self.health / self.maxHealth, 0, 1))
end

function ApolloGodFight:CreateHealthBar()
	local config = self.config
	local frame = Instance.new("Frame")
	frame.Name = "GodFightHealthBar"
	frame.Size = UDim2.new(1, 0, 0, 16)
	frame.Position = UDim2.new(0, 0, 1, 8)
	frame.BackgroundColor3 = Color3.fromRGB(30, 20, 5)
	frame.BackgroundTransparency = 0.2
	frame.ZIndex = 10
	local uICorner = Instance.new("UICorner", frame)
	uICorner.CornerRadius = UDim.new(0, 4)
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = Color3.fromRGB(180, 150, 30)
	uIStroke.Thickness = 2
	uIStroke.Transparency = 0.2
	uIStroke.Parent = frame
	local frame2 = Instance.new("Frame")
	frame2.Name = "DamageFill"
	frame2.Size = UDim2.fromScale(1, 1)
	frame2.BackgroundColor3 = config.HealthBarDamagedColor or Color3.fromRGB(140, 100, 10)
	frame2.BackgroundTransparency = 0.3
	frame2.ZIndex = 11
	local uICorner_2 = Instance.new("UICorner", frame2)
	uICorner_2.CornerRadius = UDim.new(0, 3)
	frame2.Parent = frame
	local frame3 = Instance.new("Frame")
	frame3.Name = "Fill"
	frame3.Size = UDim2.fromScale(1, 1)
	frame3.BackgroundColor3 = config.HealthBarColor or Color3.fromRGB(255, 200, 40)
	frame3.ZIndex = 12
	local uICorner_3 = Instance.new("UICorner", frame3)
	uICorner_3.CornerRadius = UDim.new(0, 3)
	frame3.Parent = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextStrokeTransparency = 0.5
	textLabel.TextStrokeColor3 = Color3.fromRGB(80, 60, 0)
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

function ApolloGodFight:CreateTimer()
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(0.5, 0, 0, 22)
	textLabel.Position = UDim2.new(0.5, 0, 1, 30)
	textLabel.AnchorPoint = Vector2.new(0.5, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 230, 150)
	textLabel.TextStrokeTransparency = 0.2
	textLabel.TextStrokeColor3 = Color3.fromRGB(100, 70, 0)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.Fondamento
	textLabel.Text = ""
	textLabel.ZIndex = 12
	textLabel.Parent = self.current.reel_bar
	self.timerLabel = textLabel
end

function ApolloGodFight:CreateOverlay()
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

function ApolloGodFight:CreateSilhouette()
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Size = UDim2.new(0.25, 0, 0.2, 0)
	imageLabel.Position = UDim2.new(0.5, 0, 0.06, 0)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://93200760854317"
	imageLabel.ImageTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.ZIndex = 2
	imageLabel.Parent = self.current.reel
	TweenService:Create(imageLabel, TweenInfo.new(3, Enum.EasingStyle.Sine), {
		ImageTransparency = 0.15
	}):Play()
	self.silhouette = imageLabel
end

function ApolloGodFight:ShowPhaseText(text: string)
	local current = self.current

	if not (current and current.active) then
		return
	end

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(0.25, 0, 0.035, 0)
	textLabel.Position = UDim2.fromScale(0.5, 0.45)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
	textLabel.TextStrokeTransparency = 0.1
	textLabel.TextStrokeColor3 = Color3.fromRGB(120, 80, 0)
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

function ApolloGodFight:OnFightComplete()
	if not (self.current and self.current.active) then
		return
	end

	self.fightActive = false
	fx:ShakeScreen(Players.LocalPlayer, 3, 2)

	if self.healthFill then
		TweenService:Create(self.healthFill, TweenInfo.new(0.5), {
			BackgroundColor3 = Color3.fromRGB(255, 240, 100)
		}):Play()
	end

	if self.healthText then
		self.healthText.Text = "SEAL BROKEN"
		self.healthText.TextColor3 = Color3.fromRGB(255, 245, 180)
	end

	if self.timerLabel then
		self.timerLabel.Text = "VICTORY"
		self.timerLabel.TextColor3 = Color3.fromRGB(255, 245, 180)
	end

	task.delay(1.5, function()
		if self.current and self.current.active then
			self.current:EndMinigame(true)
		end
	end)
end

function ApolloGodFight:OnFightFailed()
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

function ApolloGodFight:SpawnScorchMark(p2: number, p3: number)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "ScorchMark"
	imageLabel.Size = UDim2.fromScale(p3, 1)
	imageLabel.Position = UDim2.fromScale(p2, 0.5)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://70998636649073"
	imageLabel.ImageRectSize = Vector2.new(128, 128)
	imageLabel.ImageColor3 = color2
	imageLabel.BorderSizePixel = 0
	imageLabel.ZIndex = 2
	imageLabel.Parent = self.current.reel_bar
	TweenService:Create(imageLabel, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		ImageTransparency = 1,
		Size = UDim2.new(p3 * 0.3, 0, 0.5, 0)
	}):Play()
	task.delay(1.6, function()
		if imageLabel.Parent then
			imageLabel:Destroy()
		end
	end)
end

function ApolloGodFight:SpawnSunRay(p: number)
	local config = self.config
	local barToScreenX = self:BarToScreenX(p)
	local barScreenY = self:GetBarScreenY()
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Spotlight"
	imageLabel.Size = UDim2.fromScale(0.15, 0.15)
	imageLabel.Position = UDim2.fromScale(barToScreenX, 0.3)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://1423321375"
	imageLabel.ImageColor3 = color
	imageLabel.ImageTransparency = 0.25
	imageLabel.ZIndex = 14
	imageLabel.Parent = self.current.reel
	local v = fx:PlaySound(script.RayCharge, self.reel, false)
	self.current.logicTweens:Create(
		imageLabel,
		TweenInfo.new(config.RayFocusTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
		{
			Size = UDim2.fromScale(0.04, 0.04),
			Position = UDim2.fromScale(barToScreenX, barScreenY),
			ImageTransparency = 0.1
		}
	):Play()
	self.current:WaitLogic(config.RayFocusTime)

	if v and v.Parent then
		v:Destroy()
	end

	if not self.fightActive then
		imageLabel:Destroy()
		return
	end

	imageLabel:Destroy()
	local frame = Instance.new("Frame")
	frame.Name = "SunRay"
	frame.Size = UDim2.fromScale(config.RayWidth * self.current.reel_bar.Size.X.Scale, 15)
	frame.Position = UDim2.fromScale(barToScreenX, barScreenY - 0.03)
	frame.AnchorPoint = Vector2.new(0.5, 1)
	frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame.BackgroundTransparency = 0.1
	frame.BorderSizePixel = 0
	frame.ZIndex = 15
	frame.Parent = self.current.reel
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 220)),
		ColorSequenceKeypoint.new(0.3, color),
		ColorSequenceKeypoint.new(1, color2)
	})
	uIGradient.Rotation = 90
	uIGradient.Parent = frame
	fx:PlaySound(script.RayFire, self.reel, true, "FishingSound")

	if self.current:IsInBar(p, config.RayWidth) then
		self:DamageHealth(config.RayDamage)
		self:HitEffect(color)
	else
		self:SpawnDodgeText()
		self.current.fx:SpawnShake(self.reel, 0.15, 0.25, 0.01, false)
	end

	self:SpawnScorchMark(p, config.RayWidth)
	self.current:WaitLogic(0.15)
	local v2 = config.RayWidth * self.current.reel_bar.Size.X.Scale * 0.3
	self.current.logicTweens:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(v2, frame.Size.Y.Scale)
	}):Play()
	self.current:DelayLogic(0.45, function()
		if frame.Parent then
			frame:Destroy()
		end
	end)
end

function ApolloGodFight.SpawnRaySpread(data, p: number)
	local config = data.config
	local raySpreadCount = config.RaySpreadCount or 3
	local raySpreadArc = config.RaySpreadArc or 0.3
	local v = raySpreadArc / math.max(raySpreadCount - 1, 1)
	local v2 = p - raySpreadArc / 2

	for i = 0, raySpreadCount - 1 do
		local v3 = math.clamp(v2 + v * i, 0.05, 0.95)
		task.spawn(data.SpawnSunRay, data, v3)
		data.current:WaitLogic(0.15)
	end
end

function ApolloGodFight:SpawnHarpString(p: number)
	local config = self.config
	local barToScreenX = self:BarToScreenX(p)
	local barScreenY = self:GetBarScreenY()
	local scale = self.current.reel_bar.Size.X.Scale
	local frame = Instance.new("Frame")
	frame.Name = "HarpString"
	frame.Size = UDim2.fromScale(config.StringWidth * scale, 15)
	frame.Position = UDim2.fromScale(barToScreenX, barScreenY - 0.03)
	frame.AnchorPoint = Vector2.new(0.5, 1)
	frame.BackgroundColor3 = color3
	frame.BackgroundTransparency = 0.7
	frame.BorderSizePixel = 0
	frame.ZIndex = 14
	frame.Parent = self.current.reel
	local flag = true
	task.spawn(function()
		while flag do
			local number = self.random:NextNumber(-0.003, 0.003)
			frame.Position = UDim2.fromScale(barToScreenX + number, frame.Position.Y.Scale)
			task.wait(0.03)
		end

		frame.Position = UDim2.fromScale(barToScreenX, frame.Position.Y.Scale)
	end)
	self.current.logicTweens:Create(
		frame,
		TweenInfo.new(config.StringWarnTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{
			BackgroundTransparency = 0.1,
			BackgroundColor3 = color4
		}
	):Play()
	fx:PlaySound(script.StringWarn, self.reel, false)
	self.current:WaitLogic(config.StringWarnTime)
	flag = false

	if not self.fightActive then
		frame:Destroy()
		return
	end

	frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame.BackgroundTransparency = 0
	fx:PlaySound(script.StringPluck, self.reel, true, "FishingSound")

	if self.current:IsInBar(p, config.StringWidth * 2) then
		self:DamageHealth(config.StringDamage)
		self:HitEffect(color3)
	else
		self:SpawnDodgeText()
	end

	task.spawn(function()
		local frame2 = Instance.new("Frame")
		frame2.Name = "VibrateDebris"
		frame2.Size = frame.Size
		frame2.Position = frame.Position
		frame2.AnchorPoint = Vector2.new(0.5, 1)
		frame2.BackgroundColor3 = color3
		frame2.BackgroundTransparency = 0.35
		frame2.BorderSizePixel = 0
		frame2.ZIndex = 13
		frame2.Parent = self.current.reel
		local v = self.current.logicTweens:Create(frame2, TweenInfo.new(0.35, Enum.EasingStyle.Linear), {
			Size = frame2.Size + UDim2.fromScale(frame2.Size.X.Scale, 0),
			BackgroundTransparency = 1
		})
		v:Play()
		v.Completed:Once(function()
			v:Destroy()
			frame2:Destroy()
		end)
	end)
	self.current.logicTweens:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
		BackgroundTransparency = 1
	}):Play()
	self.current:WaitLogic(0.1)
	self.current:DelayLogic(0.55, function()
		if frame.Parent then
			frame:Destroy()
		end
	end)
end

function ApolloGodFight:RunRays()
	local current = self.current
	local config = self.config

	while current.active and self.fightActive and self.activeAttackType == "rays" do
		local v = tick() - self.fightStartTime
		local v2 = (config.RayRamp or 0.02) * v
		local v3 = math.max(
			1,
			self.random:NextNumber(config.RayMinInterval, config.RayMaxInterval) * self:GetPhaseSpeedMult() - v2
		)
		self.current:WaitLogic(v3)

		if not current.active or not self.fightActive or self.activeAttackType ~= "rays" then
			break
		end

		if self.currentPhase >= 3 and self.random:NextNumber(0, 1) < 0.3 then
			task.spawn(self.SpawnRaySpread, self, self:GetBiasedTargetX(0.15, 0.85))
		else
			task.spawn(self.SpawnSunRay, self, self:GetBiasedTargetX(0.08, 0.92))
		end
	end
end

function ApolloGodFight:RunStrings()
	local current = self.current
	local config = self.config

	while current.active and self.fightActive and self.activeAttackType == "strings" do
		local v = tick() - self.fightStartTime
		local v2 = (config.StringRamp or 0.01) * v
		local v3 = math.max(
			1,
			self.random:NextNumber(config.StringMinInterval, config.StringMaxInterval) * self:GetPhaseSpeedMult() - v2
		)
		self.current:WaitLogic(v3)

		if not current.active or not self.fightActive or self.activeAttackType ~= "strings" then
			break
		end

		task.spawn(self.SpawnHarpString, self, self:GetBiasedTargetX(0.08, 0.92))
	end
end

function ApolloGodFight:Morph(parent, object2)
	local config = self.config
	local isGodFight = config.IsGodFight == true
	task.spawn(
		ContentProvider.PreloadAsync,
		ContentProvider,
		{ "rbxassetid://93200760854317", "rbxassetid://7733960981" }
	)
	self.attackContainer = Instance.new("Frame")
	self.attackContainer.Name = "AttackContainer"
	self.attackContainer.Size = UDim2.fromScale(1, 1)
	self.attackContainer.BackgroundTransparency = 1
	self.attackContainer.ZIndex = 14
	self.attackContainer.Parent = parent
	self.maxHealth = config.MaxHealth or 200
	self.health = self.maxHealth
	self.fightActive = false
	self.fightStartTime = 0
	self.currentPhase = 0
	self.activeAttackType = "rays"
	self.random = object2:GetRandom(8)

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
			p.GodName = config.GodName or "Apollo"
			p.EndingHealth = self.health / self.maxHealth
			return p
		end)
	end

	task.spawn(function()
		object2:WaitUntilReady()
		self.fightActive = true
		self.fightStartTime = tick()
		self.currentPhase = 1
		local fightDuration = config.FightDuration or 60
		local phaseDurations = config.PhaseDurations or {
			0.3,
			0.25,
			0.25,
			0.2
		}

		if isGodFight then
			self:ShowPhaseText("Apollo descends!")
			task.spawn(function()
				self.activeAttackType = "rays"
				task.spawn(self.RunRays, self)
				local v = fightDuration * phaseDurations[1]
				self.current:WaitLogic(v)
				local v2 = 0 + v

				if not self.fightActive then
					return
				end

				self.currentPhase = 2
				self.activeAttackType = "strings"
				self:ShowPhaseText("The hymn of light begins...")
				fx:PlaySound(script.PhaseTransition, object2.reel, true)
				task.spawn(self.RunStrings, self)
				local v3 = fightDuration * phaseDurations[2]
				self.current:WaitLogic(v3)
				v2 += v3

				if not self.fightActive then
					return
				end

				self.currentPhase = 3
				self:ShowPhaseText("Light and melody converge!")
				fx:PlaySound(script.PhaseTransition, object2.reel, true)
				object2.fx:SpawnShake(object2.reel_bar, 0.3, 1, 0.02, false)
				task.spawn(function()
					while self.fightActive and self.currentPhase == 3 do
						self.activeAttackType = "rays"
						task.spawn(self.RunRays, self)
						self.current:WaitLogic(4 * self:GetPhaseSpeedMult())

						if not self.fightActive or self.currentPhase ~= 3 then
							break
						end

						self.activeAttackType = "strings"
						task.spawn(self.RunStrings, self)
						self.current:WaitLogic(4 * self:GetPhaseSpeedMult())
					end
				end)
				local v4 = fightDuration * phaseDurations[3]
				self.current:WaitLogic(v4)

				if not self.fightActive then
					return
				end

				self.currentPhase = 4
				self:ShowPhaseText((`{Players.LocalPlayer.DisplayName}... You cannot outshine a god!`))
				fx:PlaySound(script.PhaseTransition, object2.reel, true)
				object2.fx:SpawnShake(object2.reel_bar, 0.5, 2, 0.02, true)
				self.activeAttackType = "rays"
				task.spawn(self.RunRays, self)
				self.activeAttackType = "strings"
				task.spawn(self.RunStrings, self)
			end)
			self.reelTrove:Add(object2.OnLogicStep:Connect(function(p: number)
				if not (self.fightActive and object2.active) then
					return
				end

				if self.healthFill then
					local uDim = UDim2.fromScale(self:GetHealthPercent(), 1)
					self.healthFill.Size = self.healthFill.Size:Lerp(uDim, (math.min(p * 12, 1)))
					local healthPercent = self:GetHealthPercent()
					local healthBarColor = config.HealthBarColor or Color3.fromRGB(255, 200, 40)

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

				local v = math.max(0, fightDuration - (tick() - self.fightStartTime))

				if self.timerLabel then
					local v2 = math.ceil(v)
					self.timerLabel.Text = `{v2} Second{v2 == 1 and "" or "s"}`

					if v <= 10 then
						self.timerLabel.TextColor3 = Color3.fromRGB(255, 230, 150):Lerp(
							Color3.fromRGB(255, 100, 100),
							(math.abs((math.sin(tick() * 3))))
						)
					else
						self.timerLabel.TextColor3 = Color3.fromRGB(255, 230, 150)
					end
				end

				if v <= 0 then
					self:OnFightComplete()
				end
			end))
		else
			task.spawn(self.RunRays, self)
			object2.OnMinigameEnd:Once(function()
				self.fightActive = false
			end)
		end
	end)
end

setmetatable(ApolloGodFight, module)
return ApolloGodFight