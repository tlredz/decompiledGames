local BellonaGodFight = {}
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local slashes = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("fishing"):WaitForChild("slashes")
local fishing = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("fishing")
local uDim = UDim2.new(0.162, 0, 0.168, 0)
local color = Color3.fromRGB(255, 120, 40)
local uDim2 = UDim2.new(0.098, 0, 0.104, 0)
local color2 = Color3.fromRGB(255, 220, 80)
local uDim3 = UDim2.new(0.036, 0, 0.104, 0)
local color3 = Color3.fromRGB(220, 40, 40)
local color4 = Color3.fromRGB(140, 25, 25)

function BellonaGodFight:BarToScreenX(p2: number)
	local reel_bar = self.current.reel_bar
	local absolutePosition = reel_bar.AbsolutePosition
	local absoluteSize = reel_bar.AbsoluteSize
	local absoluteSize2 = self.current.reel.AbsoluteSize
	return (absolutePosition.X + p2 * absoluteSize.X) / absoluteSize2.X
end

function BellonaGodFight:GetBarScreenY()
	return self.current.reel_bar.Position.Y.Scale
end

function BellonaGodFight:CheckHitScreenX(p: number, value: number?)
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

function BellonaGodFight:HitEffect(backgroundColor: Color3)
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

function BellonaGodFight:SpawnDodgeText()
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

function BellonaGodFight:GetPhaseSpeedMult()
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

function BellonaGodFight:GetBiasedTargetX(min: number, max: number)
	if self.random:NextNumber(0, 1) < 0.5 then
		return (math.clamp(self.current.barPosition + self.random:NextNumber(-0.15, 0.15), min, max))
	end

	return self.random:NextNumber(min, max)
end

function BellonaGodFight:DamageHealth(p: number)
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

function BellonaGodFight:GetHealthPercent()
	return (math.clamp(self.health / self.maxHealth, 0, 1))
end

function BellonaGodFight:CreateHealthBar()
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

function BellonaGodFight:CreateTimer()
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

function BellonaGodFight:CreateOverlay()
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

function BellonaGodFight:CreateSilhouette()
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Size = UDim2.new(0.25, 0, 0.2, 0)
	imageLabel.Position = UDim2.new(0.5, 0, 0.06, 0)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://115845698932422"
	imageLabel.ImageColor3 = color4
	imageLabel.ImageTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.ZIndex = 2
	imageLabel.Parent = self.current.reel
	TweenService:Create(imageLabel, TweenInfo.new(3, Enum.EasingStyle.Sine), {
		ImageTransparency = 0.15
	}):Play()
	self.silhouette = imageLabel
end

function BellonaGodFight:ShowPhaseText(text: string)
	local current = self.current

	if not (current and current.active) then
		return
	end

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(0.25, 0, 0.035, 0)
	textLabel.Position = UDim2.fromScale(0.5, 0.45)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 180, 100)
	textLabel.TextStrokeTransparency = 0.1
	textLabel.TextStrokeColor3 = Color3.fromRGB(80, 20, 0)
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

function BellonaGodFight:OnFightComplete()
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

function BellonaGodFight:OnFightFailed()
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

function BellonaGodFight:SpawnSpear(p: number)
	local current = self.current

	if not (current and current.active and self.fightActive) then
		return
	end

	local config = self.config
	local reel = current.reel
	local spearWarningTime = config.SpearWarningTime or 0.6
	local barToScreenX = self:BarToScreenX(p)
	local barScreenY = self:GetBarScreenY()
	fx:PlaySound(script.SpearWarning, reel, true)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0.08, 0, 1, 0)
	frame.Position = UDim2.fromScale(p, 0.5)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = color
	frame.BackgroundTransparency = 0.5
	frame.ZIndex = 14
	frame.Parent = current.reel_bar
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.15, 0),
		NumberSequenceKeypoint.new(0.85, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	uIGradient.Parent = frame
	current.logicTweens:CreateAndPlay(
		frame,
		TweenInfo.new(spearWarningTime / 4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 3, true),
		{
			BackgroundTransparency = 0.3
		}
	)
	current.logicTweens:CreateAndPlay(
		frame,
		TweenInfo.new(spearWarningTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{
			Size = UDim2.new(0.03, 0, 1, 0)
		}
	)
	current:DelayLogic(spearWarningTime, function()
		if frame.Parent then
			frame:Destroy()
		end
	end)
	current:WaitLogic(spearWarningTime)

	if not (current.active and self.fightActive) then
		return
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Size = uDim
	imageLabel.Position = UDim2.fromScale(barToScreenX, -0.15)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://82317421402458"
	imageLabel.ImageColor3 = color
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Rotation = 180
	imageLabel.ZIndex = 16
	imageLabel.Parent = reel
	local v = (config.SpearFallTime or 1.2) * self:GetPhaseSpeedMult()
	local v2 = barScreenY + 0.3
	local v3 = current.logicTweens:Create(
		imageLabel,
		TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{
			Position = UDim2.fromScale(barToScreenX, v2)
		}
	)
	local v4 = false
	local onLogicStepConnection = nil
	onLogicStepConnection = current.OnLogicStep:Connect(function()
		if v4 or not (current.active and self.fightActive) then
			onLogicStepConnection:Disconnect()
			return
		end

		local v5 = imageLabel.Position.Y.Scale + imageLabel.Size.Y.Scale

		if barScreenY - 0.02 <= v5 and imageLabel.Position.Y.Scale <= barScreenY + 0.02 then
			local v6, v7 = self:CheckHitScreenX(barToScreenX, 0.04)

			if v6 then
				v4 = true
				onLogicStepConnection:Disconnect()
				self:DamageHealth(config.SpearDamage)
				self:HitEffect(color)
				fx:PlaySound(script.SpearImpact, reel, true)
				v3:Cancel()
				current.logicTweens:CreateAndPlay(imageLabel, TweenInfo.new(0.2), {
					ImageTransparency = 1
				}):Play()
				task.delay(0.25, function()
					if imageLabel.Parent then
						imageLabel:Destroy()
					end
				end)
			elseif v7 then
				v4 = true
				onLogicStepConnection:Disconnect()
				self:SpawnDodgeText()
			end
		end
	end)
	v3.Completed:Once(function()
		onLogicStepConnection:Disconnect()
		v3:Destroy()

		if imageLabel.Parent then
			imageLabel:Destroy()
		end
	end)
	v3:Play()
end

function BellonaGodFight:SpawnArrow(flag: boolean, p: number)
	local current = self.current

	if not (current and current.active and self.fightActive) then
		return
	end

	local config = self.config
	local reel = current.reel
	local v = (config.ArrowArcTime or 0.8) * self:GetPhaseSpeedMult()
	local barToScreenX = self:BarToScreenX(p)
	local barScreenY = self:GetBarScreenY()
	local v2 = flag and -0.05 or 1.05
	local v3 = barScreenY - 0.3
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Size = uDim2
	imageLabel.Position = UDim2.fromScale(v2, v3)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://139495386833064"
	imageLabel.ImageColor3 = color2
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.ZIndex = 16
	imageLabel.Parent = reel
	fx:PlaySound(script.ArrowLaunch, reel, true)
	local total = 0
	local v4 = false
	local onLogicStepConnection = nil
	onLogicStepConnection = current.OnLogicStep:Connect(function(p2)
		if v4 or not (current.active and self.fightActive) then
			onLogicStepConnection:Disconnect()

			if imageLabel.Parent then
				imageLabel:Destroy()
			end
		else
			total += p2
			local v5 = math.clamp(total / v, 0, 1)
			local v6 = v2 + (barToScreenX - v2) * v5
			local v7 = v5 * -0.6 * (1 - v5)
			local v8 = v3 + (barScreenY - v3) * v5 + v7
			imageLabel.Position = UDim2.fromScale(v6, v8)
			local v9 = barToScreenX - v2
			local v10 = barScreenY - v3 + (1 - v5 * 2) * -0.6
			imageLabel.Rotation = math.deg((math.atan2(v10, v9))) + 90

			if v5 > 0.6 and math.abs(v8 - barScreenY) < 0.05 then
				local v11, _ = self:CheckHitScreenX(v6, 0.03)

				if v11 then
					v4 = true
					onLogicStepConnection:Disconnect()
					self:DamageHealth(config.ArrowDamage)
					self:HitEffect(color2)
					fx:PlaySound(script.ArrowImpact, reel, true)
					current.renderTweens:CreateAndPlay(imageLabel, TweenInfo.new(0.15), {
						ImageTransparency = 1
					})
					current:DelayLogic(0.2, function()
						if imageLabel.Parent then
							imageLabel:Destroy()
						end
					end)
				end
			end

			if v5 >= 1 then
				onLogicStepConnection:Disconnect()

				if not v4 then
					local _, v11 = self:CheckHitScreenX(imageLabel.Position.X.Scale, 0.03)

					if v11 then
						self:SpawnDodgeText()
					end
				end

				if imageLabel.Parent then
					imageLabel:Destroy()
				end
			end
		end
	end)
end

function BellonaGodFight:SpawnSword(p: number)
	local current = self.current

	if not (current and current.active and self.fightActive) then
		return
	end

	local config = self.config
	local reel = current.reel
	local v = (config.SwordWindupTime or 1) * self:GetPhaseSpeedMult()
	local swordSlashTime = config.SwordSlashTime or 0.15
	local swordWidth = config.SwordWidth or 0.3
	local barToScreenX = self:BarToScreenX(p)
	local barScreenY = self:GetBarScreenY()
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Size = uDim3
	imageLabel.Position = UDim2.fromScale(barToScreenX, barScreenY)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.7)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://82463301279786"
	imageLabel.ImageColor3 = color3
	imageLabel.ImageTransparency = 0.3
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Rotation = 0
	imageLabel.ZIndex = 16
	imageLabel.Parent = reel
	fx:PlaySound(script.SwordAppear, reel, true)
	current.logicTweens:CreateAndPlay(imageLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		ImageTransparency = 0
	})
	current:WaitLogic(v)

	if current.active and self.fightActive then
		local v2 = self.random:NextNumber(0, 1) > 0.5 and 1 or -1
		fx:PlaySound(script.SwordImpact, reel, true)
		current.logicTweens:CreateAndPlay(
			imageLabel,
			TweenInfo.new(swordSlashTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				Rotation = 120 * v2
			}
		)
		current:WaitLogic(swordSlashTime)

		if current.active and self.fightActive then
			local scale = current.reel_bar.Size.X.Scale
			local v3 = swordWidth * scale / 2
			local v4 = barToScreenX - v3
			local v5 = barToScreenX + v3
			local v6 = (self.current.barSize or config.DodgeBarSize or 0.3) / 2
			local barToScreenX2 = self:BarToScreenX(current.barPosition)
			local v7 = barToScreenX2 - v6 * scale
			local v8 = barToScreenX2 + v6 * scale

			if v4 <= v8 and v7 <= v5 then
				self:DamageHealth(config.SwordDamage)
				self:HitEffect(color3)
				local v9 = fishing.slashes:FindFirstChild(config.SwordSlashIcon or "Default Slash") or fishing.slashes["Default Slash"]
				local v10 = slashes:FindFirstChild(config.SwordSlashSound or "stabbystab") or slashes.stabbystab
				current.fx:Slash({
					Time = 0.35,
					Color = config.SwordGradientColor or color3,
					Sound = { v10 },
					Icon = { v9 }
				})
			else
				local v9 = (config.NearMissRange or 0.06) * scale

				if v4 - v9 <= v8 and v7 <= v5 + v9 then
					self:SpawnDodgeText()
				end
			end
		end

		current.logicTweens:CreateAndPlay(
			imageLabel,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				ImageTransparency = 1
			}
		)
		current:DelayLogic(0.3, function()
			if imageLabel.Parent then
				imageLabel:Destroy()
			end
		end)
	elseif imageLabel.Parent then
		imageLabel:Destroy()
	end
end

function BellonaGodFight:RunSpears()
	local current = self.current
	local config = self.config

	while current.active and self.fightActive do
		local v = tick() - self.fightStartTime
		local v2 = (config.SpearRamp or 0.02) * v
		current:WaitLogic((math.max(
			1,
			self.random:NextNumber(config.SpearMinInterval, config.SpearMaxInterval) * self:GetPhaseSpeedMult() - v2
		)))

		if current.active and self.fightActive then
			task.spawn(self.SpawnSpear, self, self:GetBiasedTargetX(0.08, 0.92))
		else
			break
		end
	end
end

function BellonaGodFight:RunArrows()
	local current = self.current
	local config = self.config

	while current.active and self.fightActive do
		local v = tick() - self.fightStartTime
		local v2 = (config.ArrowRamp or 0.015) * v
		current:WaitLogic((math.max(
			0.8,
			self.random:NextNumber(config.ArrowMinInterval, config.ArrowMaxInterval) * self:GetPhaseSpeedMult() - v2
		)))

		if not (current.active and self.fightActive) then
			break
		end

		local arrowBurstCount = config.ArrowBurstCount

		if self.currentPhase >= 4 then
			arrowBurstCount += 1
		end

		for i = 1, arrowBurstCount do
			if current.active and self.fightActive then
				task.spawn(self.SpawnArrow, self, self.random:NextNumber(0, 1) > 0.5, self:GetBiasedTargetX(0.1, 0.9))

				if i < arrowBurstCount then
					current:WaitLogic(config.ArrowBurstDelay)
				end
			else
				break
			end
		end
	end
end

function BellonaGodFight:RunSwords()
	local current = self.current
	local config = self.config
	local v = true
	local total = 0
	self.reelTrove:Add(current.OnLogicStep:Connect(function(p)
		if not (self.fightActive and current.active) then
			return
		end

		total += p

		if not v then
			return
		end

		v = false
		local v2 = config.SwordChance + (config.SwordRamp or 0) * total

		if self.currentPhase >= 4 then
			v2 += 20
		end

		if self.random:NextNumber(0, 100) < v2 then
			local integer = self.random:NextInteger(config.SwordComboMin, config.SwordComboMax)

			if self.currentPhase >= 4 then
				integer += 1
			end

			local barPosition = current.barPosition
			local v3

			if self.random:NextNumber(0, 1) < 0.5 then
				v3 = barPosition < 0.5
			else
				v3 = self.random:NextNumber(0, 1) > 0.5
			end

			for i = 1, integer do
				if not (current.active and self.fightActive) then
					break
				end

				local v4

				if i % 2 == 1 then
					v4 = v3
				else
					v4 = not v3
				end

				local v5 = v4 and self.random:NextNumber(0.15, 0.4) or self.random:NextNumber(0.6, 0.85)
				task.spawn(self.SpawnSword, self, v5)

				if i < integer then
					current:WaitLogic(config.SwordComboDelay or 0.8)
				end
			end
		end

		current:DelayLogic(config.SwordInterval * self:GetPhaseSpeedMult(), function()
			v = true
		end)
	end))
end

function BellonaGodFight:Morph(p, object2)
	local config = self.config
	local isGodFight = config.IsGodFight == true
	task.spawn(ContentProvider.PreloadAsync, ContentProvider, {
		"rbxassetid://82317421402458",
		"rbxassetid://139495386833064",
		"rbxassetid://82463301279786",
		"rbxassetid://115845698932422"
	})
	self.maxHealth = config.MaxHealth or 200
	self.health = self.maxHealth
	self.fightActive = false
	self.fightStartTime = 0
	self.currentPhase = 0
	self.random = object2:GetRandom(8)

	if isGodFight then
		object2:AddModifier("barSize", "force", config.DodgeBarSize or 0.3)
		object2.core.minigame.NoFail = true
		object2:AddModifier("progress", "force_final", 0.1)
		p.fish.Visible = false
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
		object2.BuildEndingData:BindAtPriority(1000, function(p2)
			p2.IsGodFight = true
			p2.GodName = config.GodName or "Bellona"
			p2.EndingHealth = self.health / self.maxHealth
			return p2
		end)
	end

	task.spawn(function()
		object2:WaitUntilReady()
		self.fightActive = true
		self.fightStartTime = tick()
		self.currentPhase = 1
		task.spawn(self.RunSpears, self)
		task.spawn(self.RunArrows, self)
		task.spawn(self.RunSwords, self)

		if not isGodFight then
			object2.OnMinigameEnd:Once(function()
				self.fightActive = false
			end)
			return
		end

		local fightDuration = config.FightDuration or 60
		self:ShowPhaseText("Bellona attacks!")
		task.spawn(function()
			object2:WaitLogic(fightDuration * 0.33)

			if not self.fightActive then
				return
			end

			self.currentPhase = 2
			self:ShowPhaseText("Bellona's rage builds!")
			fx:PlaySound(script.PhaseTransition, object2.reel, true)
			object2:WaitLogic(fightDuration * 0.33)

			if not self.fightActive then
				return
			end

			self.currentPhase = 3
			self:ShowPhaseText("War intensifies!")
			fx:PlaySound(script.PhaseTransition, object2.reel, true)
			object2.fx:SpawnShake(object2.reel_bar, 0.3, 1, 0.02, false)
			object2:WaitLogic(fightDuration * 0.17)

			if not self.fightActive then
				return
			end

			self.currentPhase = 4
			self:ShowPhaseText("Bellona's fury!")
			fx:PlaySound(script.PhaseTransition, object2.reel, true)
			object2.fx:SpawnShake(object2.reel_bar, 0.5, 2, 0.02, true)
		end)
		self.reelTrove:Add(object2.OnLogicStep:Connect(function(p2)
			if not (self.fightActive and object2.active) then
				return
			end

			if self.healthFill then
				local uDim4 = UDim2.fromScale(self:GetHealthPercent(), 1)
				self.healthFill.Size = self.healthFill.Size:Lerp(uDim4, (math.min(p2 * 12, 1)))
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
					self.healthDamageFill.Size = UDim2.fromScale(math.max(scale - p2 * 0.5, healthPercent), 1)
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
					self.timerLabel.TextColor3 = Color3.fromRGB(255, 200, 200):Lerp(
						Color3.fromRGB(255, 100, 100),
						(math.abs((math.sin(tick() * 3))))
					)
				else
					self.timerLabel.TextColor3 = Color3.fromRGB(255, 200, 200)
				end
			end

			if v <= 0 then
				self:OnFightComplete()
			end
		end))
	end)
end

setmetatable(BellonaGodFight, module)
return BellonaGodFight