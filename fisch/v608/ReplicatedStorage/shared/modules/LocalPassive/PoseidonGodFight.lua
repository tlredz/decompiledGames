local PoseidonGodFight = {}
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local uDim = UDim2.new(0.162, 0, 0.168, 0)
local color = Color3.fromRGB(30, 120, 200)
local color2 = Color3.fromRGB(30, 130, 210)
local color3 = Color3.fromRGB(60, 170, 240)
local color4 = Color3.fromRGB(20, 80, 160)

function PoseidonGodFight:BarToScreenX(p2: number)
	local reel_bar = self.current.reel_bar
	local absolutePosition = reel_bar.AbsolutePosition
	local absoluteSize = reel_bar.AbsoluteSize
	local absoluteSize2 = self.current.reel.AbsoluteSize
	return (absolutePosition.X + p2 * absoluteSize.X) / absoluteSize2.X
end

function PoseidonGodFight:GetBarScreenY()
	return self.current.reel_bar.Position.Y.Scale
end

function PoseidonGodFight:GetBarScreenBounds()
	local reel_bar = self.current.reel_bar
	local v = reel_bar.Position.X.Scale + reel_bar.Position.X.Offset / reel_bar.AbsoluteSize.X
	local scale = reel_bar.Size.X.Scale
	return v - scale / 2, v + scale / 2
end

function PoseidonGodFight:CheckHitScreenX(p: number, value: number?)
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

function PoseidonGodFight:HitEffect(backgroundColor: Color3)
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
	local frame2 = Instance.new("Frame")
	frame2.Name = "WaterPulse"
	frame2.Size = UDim2.fromScale(1, 1)
	frame2.Position = UDim2.fromScale(0, 0)
	frame2.BackgroundColor3 = color2
	frame2.BackgroundTransparency = 0.45
	frame2.ZIndex = 30
	frame2.Parent = current.reel
	TweenService:Create(frame2, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1
	}):Play()
	task.delay(0.65, function()
		if frame2.Parent then
			frame2:Destroy()
		end
	end)
end

function PoseidonGodFight:SpawnDodgeText()
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

function PoseidonGodFight:GetPhaseSpeedMult()
	if self.currentPhase >= 4 then
		return 0.75
	end

	if self.currentPhase >= 3 then
		return 0.8
	end

	if self.currentPhase >= 2 then
		return 0.85
	end

	return 0.92
end

function PoseidonGodFight:GetBiasedTargetX(min: number, max: number)
	if self.random:NextNumber(0, 1) < 0.5 then
		return (math.clamp(self.current.barPosition + self.random:NextNumber(-0.15, 0.15), min, max))
	end

	return self.random:NextNumber(min, max)
end

function PoseidonGodFight:DamageHealth(p: number)
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

function PoseidonGodFight:GetHealthPercent()
	return (math.clamp(self.health / self.maxHealth, 0, 1))
end

function PoseidonGodFight:SpawnSplash(p: number, color5: Color3?)
	local current = self.current

	if not current then
		return
	end

	local barScreenY = self:GetBarScreenY()
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Size = UDim2.fromScale(0.1, 0.06)
	imageLabel.AnchorPoint = Vector2.new(0.5, 1)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://99534224346344"
	imageLabel.ImageColor3 = color5 or color
	imageLabel.ImageTransparency = 0.1
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.ZIndex = 19
	imageLabel.Position = UDim2.fromScale(p, barScreenY - 0.01)
	imageLabel.Parent = current.reel
	current.logicTweens:Create(imageLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(0.16, 0.1),
		ImageTransparency = 1
	}):Play()
	current:DelayLogic(0.45, function()
		if imageLabel.Parent then
			imageLabel:Destroy()
		end
	end)
end

function PoseidonGodFight:AddWaterTexture(parent, p2: number)
	parent.ClipsDescendants = true
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "WaterCaustics"
	imageLabel.Size = UDim2.fromScale(1.3, 1.3)
	imageLabel.Position = UDim2.fromScale(-0.15, -0.15)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://73800640689903"
	imageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
	imageLabel.ImageTransparency = 0.75
	imageLabel.ScaleType = Enum.ScaleType.Tile
	imageLabel.TileSize = UDim2.fromOffset(64, 64)
	imageLabel.ZIndex = parent.ZIndex + 1
	imageLabel.Parent = parent
	self.current.logicTweens:Create(
		imageLabel,
		TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{
			Position = UDim2.fromScale(p2 * 0.15 + -0.15, -0.1)
		}
	):Play()
	return imageLabel
end

function PoseidonGodFight:CreateHealthBar()
	local config = self.config
	local frame = Instance.new("Frame")
	frame.Name = "GodFightHealthBar"
	frame.Size = UDim2.new(1, 0, 0, 16)
	frame.Position = UDim2.new(0, 0, 1, 8)
	frame.BackgroundColor3 = Color3.fromRGB(5, 20, 40)
	frame.BackgroundTransparency = 0.2
	frame.ZIndex = 10
	local uICorner = Instance.new("UICorner", frame)
	uICorner.CornerRadius = UDim.new(0, 4)
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = Color3.fromRGB(30, 80, 140)
	uIStroke.Thickness = 2
	uIStroke.Transparency = 0.2
	uIStroke.Parent = frame
	local frame2 = Instance.new("Frame")
	frame2.Name = "DamageFill"
	frame2.Size = UDim2.fromScale(1, 1)
	frame2.BackgroundColor3 = config.HealthBarDamagedColor or Color3.fromRGB(15, 40, 80)
	frame2.BackgroundTransparency = 0.3
	frame2.ZIndex = 11
	local uICorner_2 = Instance.new("UICorner", frame2)
	uICorner_2.CornerRadius = UDim.new(0, 3)
	frame2.Parent = frame
	local frame3 = Instance.new("Frame")
	frame3.Name = "Fill"
	frame3.Size = UDim2.fromScale(1, 1)
	frame3.BackgroundColor3 = config.HealthBarColor or Color3.fromRGB(30, 140, 220)
	frame3.ZIndex = 12
	local uICorner_3 = Instance.new("UICorner", frame3)
	uICorner_3.CornerRadius = UDim.new(0, 3)
	frame3.Parent = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextStrokeTransparency = 0.5
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 20, 50)
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

function PoseidonGodFight:CreateTimer()
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(0.5, 0, 0, 22)
	textLabel.Position = UDim2.new(0.5, 0, 1, 30)
	textLabel.AnchorPoint = Vector2.new(0.5, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(180, 220, 255)
	textLabel.TextStrokeTransparency = 0.2
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 30, 80)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.Fondamento
	textLabel.Text = ""
	textLabel.ZIndex = 12
	textLabel.Parent = self.current.reel_bar
	self.timerLabel = textLabel
end

function PoseidonGodFight:CreateOverlay()
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

function PoseidonGodFight:CreateSilhouette()
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Size = UDim2.new(0.25, 0, 0.2, 0)
	imageLabel.Position = UDim2.new(0.5, 0, 0.06, 0)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://106241417570647"
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

function PoseidonGodFight:ShowPhaseText(text: string)
	local current = self.current

	if not (current and current.active) then
		return
	end

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(0.25, 0, 0.035, 0)
	textLabel.Position = UDim2.fromScale(0.5, 0.45)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
	textLabel.TextStrokeTransparency = 0.1
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 30, 80)
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

function PoseidonGodFight:OnFightComplete()
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

function PoseidonGodFight:OnFightFailed()
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

function PoseidonGodFight:SpawnTrident(p: number)
	local current = self.current

	if not (current and current.active and self.fightActive) then
		return
	end

	local config = self.config
	local reel = current.reel
	local tridentWarningTime = config.TridentWarningTime or 0.6
	local barToScreenX = self:BarToScreenX(p)
	local barScreenY = self:GetBarScreenY()
	fx:PlaySound(script.TridentWarning, reel, true)
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
	current.logicTweens:Create(
		frame,
		TweenInfo.new(tridentWarningTime / 4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 3, true),
		{
			BackgroundTransparency = 0.3
		}
	):Play()
	current.logicTweens:Create(
		frame,
		TweenInfo.new(tridentWarningTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{
			Size = UDim2.new(0.03, 0, 1, 0)
		}
	):Play()
	current:DelayLogic(tridentWarningTime, function()
		if frame.Parent then
			frame:Destroy()
		end
	end)
	current:WaitLogic(tridentWarningTime)

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
	local v = (config.TridentFallTime or 1.2) * self:GetPhaseSpeedMult()
	local v2 = current.logicTweens:Create(
		imageLabel,
		TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{
			Position = UDim2.fromScale(barToScreenX, barScreenY + 0.3)
		}
	)
	local v3 = false
	local now = os.clock()
	local onLogicStepConnection = nil
	onLogicStepConnection = current.OnLogicStep:Connect(function()
		if v3 or not (current.active and self.fightActive) then
			onLogicStepConnection:Disconnect()
			return
		end

		local now2 = os.clock()

		if now2 - now >= 0.06 then
			now = now2
			local imageLabel2 = Instance.new("ImageLabel")
			imageLabel2.Size = imageLabel.Size
			imageLabel2.Position = imageLabel.Position
			imageLabel2.AnchorPoint = Vector2.new(0.5, 0)
			imageLabel2.BackgroundTransparency = 1
			imageLabel2.Image = "rbxassetid://82317421402458"
			imageLabel2.ImageColor3 = color
			imageLabel2.ImageTransparency = 0.55
			imageLabel2.ScaleType = Enum.ScaleType.Fit
			imageLabel2.Rotation = 180
			imageLabel2.ZIndex = 15
			imageLabel2.Parent = reel
			current.logicTweens:Create(imageLabel2, TweenInfo.new(0.2), {
				ImageTransparency = 1
			}):Play()
			current:DelayLogic(0.25, function()
				if imageLabel2.Parent then
					imageLabel2:Destroy()
				end
			end)
		end

		local v4 = imageLabel.Position.Y.Scale + imageLabel.Size.Y.Scale

		if barScreenY - 0.02 <= v4 and imageLabel.Position.Y.Scale <= barScreenY + 0.02 then
			local v5, v6 = self:CheckHitScreenX(barToScreenX, 0.04)

			if v5 then
				v3 = true
				onLogicStepConnection:Disconnect()
				self:DamageHealth(config.TridentDamage)
				self:HitEffect(color)
				fx:PlaySound(script.TridentImpact, reel, true)
				self:SpawnSplash(barToScreenX, color)
				fx:PlaySound(script.SplashSound, reel, true)
				v2:Cancel()
				current.logicTweens:Create(imageLabel, TweenInfo.new(0.2), {
					ImageTransparency = 1
				}):Play()
				current:DelayLogic(0.25, function()
					if imageLabel.Parent then
						imageLabel:Destroy()
					end
				end)
			elseif v6 then
				v3 = true
				onLogicStepConnection:Disconnect()
				self:SpawnDodgeText()
			end
		end
	end)
	v2.Completed:Once(function()
		if not v3 then
			self:SpawnSplash(barToScreenX, color)
		end

		onLogicStepConnection:Disconnect()
		v2:Destroy()

		if imageLabel.Parent then
			imageLabel:Destroy()
		end
	end)
	v2:Play()
end

function PoseidonGodFight:SpawnWave(flag: boolean)
	local current = self.current

	if not (current and current.active and self.fightActive) then
		return
	end

	local config = self.config
	local reel = current.reel
	local v = (config.WaveWarningTime or 1.2) * self:GetPhaseSpeedMult()
	local barScreenY = self:GetBarScreenY()
	local barScreenBounds, v2 = self:GetBarScreenBounds()
	local midpoint = (barScreenBounds + v2) / 2
	local v4 = (v2 - barScreenBounds) / 2
	local v5 = flag and barScreenBounds + v4 / 2 or midpoint + v4 / 2

	if not config.IsGodFight and current.core and current.core.fish then
		current.core.fish:ForceMoveTo(flag and 0.8 or 0.2, v * 0.5)
	end

	fx:PlaySound(script.WaveWarning, reel, true)
	local frame = Instance.new("Frame")
	frame.Name = "WaveWarning"
	frame.Size = UDim2.fromScale(v4, 0.25)
	frame.Position = UDim2.fromScale(v5, barScreenY)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = color3
	frame.BackgroundTransparency = 0.7
	frame.ZIndex = 16
	frame.Parent = reel
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Rotation = flag and 0 or 180
	uIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.7, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	uIGradient.Parent = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(0.06, 0.04)
	textLabel.Position = UDim2.fromScale(v5, barScreenY - 0.06)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = color3
	textLabel.TextStrokeTransparency = 0.2
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 30, 80)
	textLabel.Font = Enum.Font.Fondamento
	textLabel.TextScaled = true
	textLabel.Text = flag and ">>>" or "<<<"
	textLabel.ZIndex = 17
	textLabel.Parent = reel
	current.logicTweens:Create(
		frame,
		TweenInfo.new(v / 5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 4, true),
		{
			BackgroundTransparency = 0.4
		}
	):Play()
	current.logicTweens:Create(
		textLabel,
		TweenInfo.new(v / 5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 4, true),
		{
			TextTransparency = 0.3
		}
	):Play()
	local v6 = self.currentPhase >= 3 and 3 or 2
	local v7 = flag and 0.55 or 0.08
	local v8 = flag and 0.92 or 0.45

	for i = 1, v6 do
		current:DelayLogic(v * (i / (v6 + 1)), function()
			if current.active and self.fightActive then
				task.spawn(self.SpawnTrident, self, self.random:NextNumber(v7, v8))
			end
		end)
	end

	current:WaitLogic(v)

	if frame.Parent then
		frame:Destroy()
	end

	if textLabel.Parent then
		textLabel:Destroy()
	end

	if not (current.active and self.fightActive) then
		return
	end

	fx:PlaySound(script.WaveImpact, reel, true)
	current.fx:SpawnShake(current.reel_bar, 0.6, 0.6, 0.02, true)
	local v9 = flag and barScreenBounds - v4 or v2 + v4
	local frame2 = Instance.new("Frame")
	frame2.Name = "PoseidonWave"
	frame2.Size = UDim2.fromScale(v4, 0.3)
	frame2.Position = UDim2.fromScale(v9, barScreenY)
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.BackgroundColor3 = color2
	frame2.BackgroundTransparency = 0.15
	frame2.ZIndex = 18
	frame2.Parent = reel
	local uIGradient2 = Instance.new("UIGradient")
	uIGradient2.Rotation = 270
	uIGradient2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.6, 0.1),
		NumberSequenceKeypoint.new(1, 0.9)
	})
	uIGradient2.Parent = frame2
	local uICorner = Instance.new("UICorner", frame2)
	uICorner.CornerRadius = UDim.new(0, 4)
	local frame3 = Instance.new("Frame")
	frame3.Name = "FoamCrest"
	frame3.Size = UDim2.fromScale(0.04, 1.15)
	frame3.Position = UDim2.fromScale(flag and 1 or 0, 0.5)
	frame3.AnchorPoint = Vector2.new(0.5, 0.55)
	frame3.BackgroundColor3 = Color3.fromRGB(180, 230, 255)
	frame3.BackgroundTransparency = 0.2
	frame3.ZIndex = frame2.ZIndex + 1
	frame3.Parent = frame2
	local uICorner_2 = Instance.new("UICorner", frame3)
	uICorner_2.CornerRadius = UDim.new(0, 3)
	local uIGradient3 = Instance.new("UIGradient")
	uIGradient3.Rotation = 270
	uIGradient3.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.5, 0.3),
		NumberSequenceKeypoint.new(1, 1)
	})
	uIGradient3.Parent = frame3
	self:AddWaterTexture(frame2, flag and 1 or -1)
	current.logicTweens:Create(frame2, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(v5, barScreenY)
	}):Play()
	self:SpawnSplash(flag and self:BarToScreenX(0.55) or self:BarToScreenX(0.45), color2)
	current:WaitLogic(0.25)

	if current.active and self.fightActive then
		local v10 = flag and current.barPosition < 0.5 and true or not flag and current.barPosition >= 0.5

		if v10 and os.clock() < self.waveImmunityUntil then
			v10 = false
		end

		if v10 then
			self:DamageHealth(config.WaveDamage)
			self:HitEffect(color2)
			fx:PlaySound(script.SplashSound, reel, true)
			self.lastWaveHit = true
			self.waveImmunityUntil = os.clock() + 3
			current.core.rod:ApplyImpulse((flag and 1 or -1) * 0.8)

			if not self.waveSlowed then
				self.waveSlowed = true
				local modifier = current:CreateModifier("accel", "multiply")
				modifier.Value = 0.4
				current:DelayLogic(2, function()
					modifier:Destroy()
					self.waveSlowed = false
				end)
			end

			local modifier = current:CreateModifier("accel", "multiply")
			modifier.Value = -1
			current:DelayLogic(1.5, function()
				modifier:Destroy()
			end)
		else
			self:SpawnDodgeText()
		end

		local lastTime = os.clock()
		local v11 = nil
		local flag2 = false
		local backgroundColor3 = current.reel_playerbar.BackgroundColor3
		local total = 0
		current.logicTweens:Create(
			frame2,
			TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 3, true),
			{
				Position = frame2.Position + UDim2.fromScale(0.005, 0.003)
			}
		):Play()
		local onLogicStepConnection = nil
		onLogicStepConnection = current.OnLogicStep:Connect(function(p)
			if current.active and self.fightActive and not (os.clock() - lastTime > 1.5) then
				if flag and current.barPosition < 0.5 or not flag and current.barPosition >= 0.5 then
					self:DamageHealth(5 * p)

					if not v11 then
						v11 = current:CreateModifier("accel", "multiply")
						v11.Value = 0.6
					end

					current.reel_playerbar.BackgroundColor3 = current.reel_playerbar.BackgroundColor3:Lerp(
						color2,
						(math.min(p * 5, 1))
					)
					total += p

					if total >= 0.15 then
						total = 0
						current.fx:SpawnShake(current.reel_bar, 0.05, 0.1, 0.004, false)
					end

					flag2 = true
				else
					if v11 then
						v11:Destroy()
						v11 = nil
					end

					if flag2 then
						current.reel_playerbar.BackgroundColor3 = current.reel_playerbar.BackgroundColor3:Lerp(
							backgroundColor3,
							(math.min(p * 8, 1))
						)
						local backgroundColor32 = current.reel_playerbar.BackgroundColor3

						if math.abs(backgroundColor32.R - backgroundColor3.R) < 0.02 and math.abs(backgroundColor32.G - backgroundColor3.G) < 0.02 and math.abs(backgroundColor32.B - backgroundColor3.B) < 0.02 then
							current.reel_playerbar.BackgroundColor3 = backgroundColor3
							flag2 = false
						end
					end
				end
			else
				if v11 then
					v11:Destroy()
					v11 = nil
				end

				if flag2 then
					current.reel_playerbar.BackgroundColor3 = backgroundColor3
				end

				onLogicStepConnection:Disconnect()
			end
		end)
		current:DelayLogic(1.5, function()
			if onLogicStepConnection.Connected then
				onLogicStepConnection:Disconnect()
			end

			if v11 then
				v11:Destroy()
				v11 = nil
			end

			current.reel_playerbar.BackgroundColor3 = backgroundColor3

			if not frame2.Parent then
				return
			end

			current.logicTweens:Create(frame2, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				BackgroundTransparency = 1
			}):Play()
			current:DelayLogic(0.85, function()
				if frame2.Parent then
					frame2:Destroy()
				end
			end)
		end)
	elseif frame2.Parent then
		frame2:Destroy()
	end
end

function PoseidonGodFight:SpawnDoubleWave()
	local current = self.current

	if not (current and current.active and self.fightActive) then
		return
	end

	local config = self.config
	local reel = current.reel
	local v = (config.WaveWarningTime or 1.2) * self:GetPhaseSpeedMult()
	local barScreenY = self:GetBarScreenY()
	local barScreenBounds, v2 = self:GetBarScreenBounds()
	local v3 = (v2 - barScreenBounds) * 0.4

	if not config.IsGodFight and current.core and current.core.fish then
		current.core.fish:ForceMoveTo(0.5, v * 0.5)
	end

	fx:PlaySound(script.WaveWarning, reel, true)
	local v4 = barScreenBounds + v3 / 2
	local v5 = v2 - v3 / 2

	local function createWarning(p: number, rotation: number)
		local frame = Instance.new("Frame")
		frame.Size = UDim2.fromScale(v3, 0.25)
		frame.Position = UDim2.fromScale(p, barScreenY)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.BackgroundColor3 = color3
		frame.BackgroundTransparency = 0.7
		frame.ZIndex = 16
		frame.Parent = reel
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Rotation = rotation
		uIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(0.7, 0.5),
			NumberSequenceKeypoint.new(1, 1)
		})
		uIGradient.Parent = frame
		current.logicTweens:Create(
			frame,
			TweenInfo.new(v / 5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 4, true),
			{
				BackgroundTransparency = 0.4
			}
		):Play()
		return frame
	end

	local warning = createWarning(v4, 0)
	local warning2 = createWarning(v5, 180)
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(0.06, 0.03)
	textLabel.Position = UDim2.fromScale((barScreenBounds + v2) / 2, barScreenY - 0.06)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(100, 255, 200)
	textLabel.TextStrokeTransparency = 0.2
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 40, 30)
	textLabel.Font = Enum.Font.Fondamento
	textLabel.TextScaled = true
	textLabel.Text = "CENTER!"
	textLabel.ZIndex = 17
	textLabel.Parent = reel
	current.logicTweens:Create(
		textLabel,
		TweenInfo.new(v / 5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 4, true),
		{
			TextTransparency = 0.3
		}
	):Play()
	current:WaitLogic(v)

	if warning.Parent then
		warning:Destroy()
	end

	if warning2.Parent then
		warning2:Destroy()
	end

	if textLabel.Parent then
		textLabel:Destroy()
	end

	if not (current.active and self.fightActive) then
		return
	end

	fx:PlaySound(script.WaveImpact, reel, true)
	current.fx:SpawnShake(current.reel_bar, 0.8, 0.8, 0.025, true)

	local function createWave(p: number, p2: number, p3: number)
		local frame = Instance.new("Frame")
		frame.Size = UDim2.fromScale(v3, 0.3)
		frame.Position = UDim2.fromScale(p2, barScreenY)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.BackgroundColor3 = color2
		frame.BackgroundTransparency = 0.15
		frame.ZIndex = 18
		frame.Parent = reel
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Rotation = 270
		uIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.6, 0.1),
			NumberSequenceKeypoint.new(1, 0.9)
		})
		uIGradient.Parent = frame
		local uICorner = Instance.new("UICorner", frame)
		uICorner.CornerRadius = UDim.new(0, 4)
		local v6 = p3 == 0
		local frame2 = Instance.new("Frame")
		frame2.Size = UDim2.fromScale(0.04, 1.15)
		frame2.Position = UDim2.fromScale(v6 and 1 or 0, 0.5)
		frame2.AnchorPoint = Vector2.new(0.5, 0.55)
		frame2.BackgroundColor3 = Color3.fromRGB(180, 230, 255)
		frame2.BackgroundTransparency = 0.2
		frame2.ZIndex = frame.ZIndex + 1
		frame2.Parent = frame
		local uICorner_2 = Instance.new("UICorner", frame2)
		uICorner_2.CornerRadius = UDim.new(0, 3)
		local uIGradient2 = Instance.new("UIGradient")
		uIGradient2.Rotation = 270
		uIGradient2.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.5, 0.3),
			NumberSequenceKeypoint.new(1, 1)
		})
		uIGradient2.Parent = frame2
		self:AddWaterTexture(frame, p3 == 0 and 1 or -1)
		current.logicTweens:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.fromScale(p, barScreenY)
		}):Play()
		return frame
	end

	local wave = createWave(v4, barScreenBounds - v3, 0)
	local wave2 = createWave(v5, v2 + v3, 180)
	self:SpawnSplash(self:BarToScreenX(0.4), color2)
	self:SpawnSplash(self:BarToScreenX(0.6), color2)
	current:WaitLogic(0.25)

	if current.active and self.fightActive then
		local v6

		if current.barPosition >= 0.4 then
			v6 = current.barPosition <= 0.6
		else
			v6 = false
		end

		if v6 then
			self:SpawnDodgeText()
		else
			self:DamageHealth((config.WaveDamage or 20) * 1.5)
			self:HitEffect(color2)
			fx:PlaySound(script.SplashSound, reel, true)
			self.lastWaveHit = true
			self.waveImmunityUntil = os.clock() + 3
			local modifier = current:CreateModifier("accel", "multiply")
			modifier.Value = -1
			current:DelayLogic(1.5, function()
				modifier:Destroy()
			end)
		end

		local lastTime = os.clock()
		local v7 = nil
		local onLogicStepConnection = nil
		onLogicStepConnection = current.OnLogicStep:Connect(function(p)
			if current.active and self.fightActive and not (os.clock() - lastTime > 1.5) then
				if current.barPosition < 0.4 or current.barPosition > 0.6 then
					self:DamageHealth(5 * p)

					if not v7 then
						v7 = current:CreateModifier("accel", "multiply")
						v7.Value = 0.6
					end
				elseif v7 then
					v7:Destroy()
					v7 = nil
				end
			else
				if v7 then
					v7:Destroy()
					v7 = nil
				end

				onLogicStepConnection:Disconnect()
			end
		end)
		current:DelayLogic(1.5, function()
			if onLogicStepConnection.Connected then
				onLogicStepConnection:Disconnect()
			end

			if v7 then
				v7:Destroy()
				v7 = nil
			end

			local function fadeWave(wave3)
				if not wave3.Parent then
					return
				end

				current.logicTweens:Create(wave3, TweenInfo.new(0.8), {
					BackgroundTransparency = 1
				}):Play()
				current:DelayLogic(0.85, function()
					if wave3.Parent then
						wave3:Destroy()
					end
				end)
			end

			fadeWave(wave)
			fadeWave(wave2)
		end)
	else
		if wave.Parent then
			wave:Destroy()
		end

		if wave2.Parent then
			wave2:Destroy()
		end
	end
end

function PoseidonGodFight:SpawnWhirlpool(p: number)
	local current = self.current

	if not (current and current.active and self.fightActive) then
		return
	end

	local config = self.config
	local v = (config.WhirlpoolSpiralTime or 2) * self:GetPhaseSpeedMult()
	local whirlpoolDamage = config.WhirlpoolDamage or 20
	local whirlpoolSize = config.WhirlpoolSize or 0.1
	local reel = current.reel
	local barScreenY = self:GetBarScreenY()
	local barToScreenX = self:BarToScreenX(p)
	local v2 = self.random:NextNumber(0, 1) > 0.5 and 1 or -1
	local number = self.random:NextNumber(6, 12)
	local number2 = self.random:NextNumber(0.08, 0.16)
	local v3 = barScreenY - self.random:NextNumber(0.28, 0.42)
	local number3 = self.random:NextNumber(-0.08, 0.08)
	local v4 = self.random:NextNumber(0, 1) < 0.3
	local number4 = self.random:NextNumber(0.3, 0.5)
	local v5, v6

	if v4 then
		v5 = math.clamp(
			p + self.random:NextNumber(0.1, 0.25) * (self.random:NextNumber(0, 1) > 0.5 and 1 or -1),
			0.08,
			0.92
		)
		v6 = self:BarToScreenX(v5)
	else
		v5 = p
		v6 = barToScreenX
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Size = UDim2.fromScale(0.07, 0.07)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://101772115966704"
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.ZIndex = 18
	imageLabel.Rotation = 0
	imageLabel.Parent = reel
	fx:PlaySound(script.WhirlpoolSpawn, reel, true)
	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.Size = UDim2.fromScale(2.2, 2.2)
	imageLabel2.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.Image = "rbxassetid://12159555294"
	imageLabel2.ImageColor3 = color2
	imageLabel2.ImageTransparency = 0.5
	imageLabel2.ScaleType = Enum.ScaleType.Fit
	imageLabel2.ZIndex = 17
	imageLabel2.Parent = imageLabel
	local total = 0
	local v7 = barToScreenX
	local v8 = p
	local v9 = false
	local total2 = 0
	local onLogicStepConnection = nil
	onLogicStepConnection = current.OnLogicStep:Connect(function(p2)
		if current.active and self.fightActive then
			total += p2
			local v10 = math.clamp(total / v, 0, 1)

			if v4 and not v9 and number4 <= v10 then
				v9 = true
				v7 = v6
				v8 = v5
			end

			local v11 = number2 * (1 - v10 * v10)
			local v12 = total * number * v2
			local v13 = v7 + number3 * (1 - v10) + math.cos(v12) * v11
			local v14 = v3 + (barScreenY - 0.03 - v3) * (v10 * v10)
			imageLabel.Position = UDim2.fromScale(v13, v14)
			imageLabel.Rotation += 300 * v2 * p2
			local v16 = (1 - v10) * 0.5 + 0.6
			imageLabel.Size = UDim2.fromScale(v16 * 0.07, v16 * 0.07)
			imageLabel2.ImageTransparency = math.sin(total * 4) * 0.2 + 0.3
			local v17 = ((1 - v10) * 0.5 + 0.5) * 2.2
			imageLabel2.Size = UDim2.fromScale(v17, v17)
			total2 += p2

			if total2 >= 0.08 then
				total2 = 0
				local imageLabel3 = Instance.new("ImageLabel")
				imageLabel3.Size = imageLabel.Size
				imageLabel3.Position = imageLabel.Position
				imageLabel3.AnchorPoint = Vector2.new(0.5, 0.5)
				imageLabel3.BackgroundTransparency = 1
				imageLabel3.Image = "rbxassetid://101772115966704"
				imageLabel3.ImageTransparency = 0.5
				imageLabel3.ScaleType = Enum.ScaleType.Fit
				imageLabel3.Rotation = imageLabel.Rotation
				imageLabel3.ZIndex = 17
				imageLabel3.Parent = reel
				current.logicTweens:Create(imageLabel3, TweenInfo.new(0.3), {
					ImageTransparency = 1,
					Size = imageLabel3.Size + UDim2.fromScale(0.01, 0.01)
				}):Play()
				current:DelayLogic(0.35, function()
					if imageLabel3.Parent then
						imageLabel3:Destroy()
					end
				end)
			end

			if v10 >= 1 then
				onLogicStepConnection:Disconnect()
				fx:PlaySound(script.WhirlpoolImpact, reel, true)
				local v18, v19 = self:CheckHitScreenX(v7, whirlpoolSize)

				if v18 then
					self:DamageHealth(whirlpoolDamage)
					self:HitEffect(color2)
					fx:PlaySound(script.SplashSound, reel, true)
					current.fx:SpawnShake(current.reel_bar, 0.6, 0.8, 0.02, true)
				elseif v19 then
					self:SpawnDodgeText()
				end

				self:SpawnSplash(v7, color2)
				current.logicTweens:Create(
					imageLabel,
					TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						Size = UDim2.fromScale(0.12, 0.12),
						ImageTransparency = 1
					}
				):Play()
				current:DelayLogic(0.35, function()
					if imageLabel.Parent then
						imageLabel:Destroy()
					end
				end)
			end
		else
			onLogicStepConnection:Disconnect()

			if imageLabel.Parent then
				imageLabel:Destroy()
			end
		end
	end)
end

function PoseidonGodFight:RunAmbientParticles()
	local current = self.current
	local reel = current.reel
	local v = {}

	local function spawnBubble()
		local number = self.random:NextNumber(0.012, 0.025)
		local v2 = self.random:NextNumber(0, 1) > 0.5
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "WaterBubble"
		imageLabel.Size = UDim2.fromScale(number, number)
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = "rbxassetid://REPLACE_WITH_BUBBLE_ID"
		imageLabel.ImageColor3 = color2
		imageLabel.ImageTransparency = 1
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.ZIndex = 2
		imageLabel.Parent = reel
		TweenService:Create(imageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
			ImageTransparency = self.random:NextNumber(0.5, 0.75)
		}):Play()
		local v3 = {
			gui = imageLabel,
			x = v2 and -0.05 or 1.05,
			y = self.random:NextNumber(0.3, 0.95),
			speedX = self.random:NextNumber(0.025, 0.055) * (v2 and 1 or -1),
			drift = self.random:NextNumber(0, 6.283185307179586),
			driftSpeed = self.random:NextNumber(1.5, 3),
			driftAmount = self.random:NextNumber(0.004, 0.01),
			fadingOut = false
		}
		table.insert(v, v3)
		return v3
	end

	for _ = 1, 8 do
		local spawnBubble_2 = spawnBubble()
		spawnBubble_2.x = self.random:NextNumber(0.05, 0.95)
	end

	local onLogicStepConnection = current.OnLogicStep:Connect(function(p)
		if not (current.active and self.fightActive) then
			return
		end

		for i = #v, 1, -1 do
			local v2 = v[i]
			v2.x += v2.speedX * p
			v2.drift += v2.driftSpeed * p
			local v3 = math.sin(v2.drift) * v2.driftAmount
			v2.gui.Position = UDim2.fromScale(v2.x, v2.y + v3)
			local v4

			if v2.speedX > 0 and v2.x > 0.9 then
				v4 = true
			elseif v2.speedX < 0 then
				v4 = v2.x < 0.1
			else
				v4 = false
			end

			if v4 and not v2.fadingOut then
				v2.fadingOut = true
				TweenService:Create(v2.gui, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {
					ImageTransparency = 1
				}):Play()
			end

			local v5

			if v2.speedX > 0 and v2.x > 1.15 then
				v5 = true
			elseif v2.speedX < 0 then
				v5 = v2.x < -0.15
			else
				v5 = false
			end

			if not v5 then
				continue
			end

			if v2.gui.Parent then
				v2.gui:Destroy()
			end

			table.remove(v, i)
			spawnBubble()
		end
	end)
	self.reelTrove:Add(onLogicStepConnection)
	self.reelTrove:Add(function()
		for _, v2 in v do
			if v2.gui.Parent then
				v2.gui:Destroy()
			end
		end
	end)
end

function PoseidonGodFight:RunTridents()
	local current = self.current
	local config = self.config

	while current.active and self.fightActive do
		local v = os.clock() - self.fightStartTime
		local v2 = (config.TridentRamp or 0.02) * v
		current:WaitLogic((math.max(
			0.8,
			self.random:NextNumber(config.TridentMinInterval, config.TridentMaxInterval) * self:GetPhaseSpeedMult() - v2
		)))

		if not (current.active and self.fightActive) then
			break
		end

		local v3 = self.currentPhase >= 2 and 2 or 1

		for i = 1, v3 do
			if current.active and self.fightActive then
				task.spawn(self.SpawnTrident, self, self:GetBiasedTargetX(0.08, 0.92))

				if i < v3 then
					current:WaitLogic(0.25)
				end
			else
				break
			end
		end
	end
end

function PoseidonGodFight:RunWaves()
	local current = self.current
	local config = self.config

	while current.active and self.fightActive do
		local v = os.clock() - self.fightStartTime
		local v2 = (config.WaveRamp or 0.01) * v
		current:WaitLogic((math.max(
			3,
			self.random:NextNumber(config.WaveMinInterval, config.WaveMaxInterval) * self:GetPhaseSpeedMult() - v2
		)))

		if not (current.active and self.fightActive) then
			break
		end

		if self.currentPhase >= 4 and self.random:NextNumber(0, 1) < 0.35 then
			task.spawn(self.SpawnDoubleWave, self)
		else
			local lastWaveSide = self.random:NextNumber(0, 1) > 0.5

			if self.currentPhase >= 2 and not self.lastWaveHit and self.random:NextNumber(0, 1) < 0.6 then
				lastWaveSide = current.barPosition < 0.5
			end

			if self.lastWaveHit and self.lastWaveSide ~= nil then
				lastWaveSide = not self.lastWaveSide
			end

			self.lastWaveSide = lastWaveSide
			self.lastWaveHit = false
			task.spawn(self.SpawnWave, self, lastWaveSide)
		end
	end
end

function PoseidonGodFight:RunWhirlpools()
	local current = self.current
	local config = self.config
	local whirlpoolMinInterval = config.WhirlpoolMinInterval or 4
	local whirlpoolMaxInterval = config.WhirlpoolMaxInterval or 8

	while current.active and self.fightActive do
		local v = os.clock() - self.fightStartTime
		local v2 = (config.WhirlpoolRamp or 0.01) * v
		current:WaitLogic((math.max(
			2,
			self.random:NextNumber(whirlpoolMinInterval, whirlpoolMaxInterval) * self:GetPhaseSpeedMult() - v2
		)))

		if current.active and self.fightActive then
			task.spawn(self.SpawnWhirlpool, self, self:GetBiasedTargetX(0.1, 0.9))

			if self.currentPhase >= 3 and self.random:NextNumber(0, 1) < 0.2 then
				current:DelayLogic(0.5, function()
					if current.active and self.fightActive then
						task.spawn(self.SpawnWhirlpool, self, self.random:NextNumber(0.1, 0.9))
					end
				end)
			end
		else
			break
		end
	end
end

function PoseidonGodFight:Morph(p, object2)
	local config = self.config
	local isGodFight = config.IsGodFight == true
	task.spawn(ContentProvider.PreloadAsync, ContentProvider, {
		"rbxassetid://82317421402458",
		"rbxassetid://99534224346344",
		"rbxassetid://101772115966704",
		"rbxassetid://12159555294",
		"rbxassetid://73800640689903",
		"rbxassetid://REPLACE_WITH_BUBBLE_ID",
		"rbxassetid://106241417570647"
	})
	self.maxHealth = config.MaxHealth or 200
	self.health = self.maxHealth
	self.fightActive = false
	self.fightStartTime = 0
	self.currentPhase = 0
	self.random = object2:GetRandom(8)
	self.waveSlowed = false
	self.lastWaveHit = false
	self.lastWaveSide = nil
	self.waveImmunityUntil = 0

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
			p2.GodName = config.GodName or "Poseidon"
			p2.EndingHealth = self.health / self.maxHealth
			return p2
		end)
	end

	task.spawn(function()
		object2:WaitUntilReady()
		self.fightActive = true
		self.fightStartTime = os.clock()
		self.currentPhase = 1
		task.spawn(self.RunTridents, self)
		task.spawn(self.RunWaves, self)
		task.spawn(self.RunWhirlpools, self)
		self:RunAmbientParticles()

		if not isGodFight then
			object2.OnMinigameEnd:Once(function()
				self.fightActive = false
			end)
			return
		end

		local fightDuration = config.FightDuration or 60
		self:ShowPhaseText("Poseidon strikes!")
		task.spawn(function()
			object2:WaitLogic(fightDuration * 0.33)

			if not self.fightActive then
				return
			end

			self.currentPhase = 2
			self:ShowPhaseText("The tides rise!")
			fx:PlaySound(script.PhaseTransition, object2.reel, true)
			object2:WaitLogic(fightDuration * 0.33)

			if not self.fightActive then
				return
			end

			self.currentPhase = 3
			self:ShowPhaseText("The storm surges!")
			fx:PlaySound(script.PhaseTransition, object2.reel, true)
			object2.fx:SpawnShake(object2.reel_bar, 0.3, 1, 0.02, false)
			object2:WaitLogic(fightDuration * 0.17)

			if not self.fightActive then
				return
			end

			self.currentPhase = 4
			self:ShowPhaseText("Poseidon's wrath!")
			fx:PlaySound(script.PhaseTransition, object2.reel, true)
			object2.fx:SpawnShake(object2.reel_bar, 0.5, 2, 0.02, true)
		end)
		self.reelTrove:Add(object2.OnLogicStep:Connect(function(p2)
			if not (self.fightActive and object2.active) then
				return
			end

			if self.healthFill then
				local uDim2 = UDim2.fromScale(self:GetHealthPercent(), 1)
				self.healthFill.Size = self.healthFill.Size:Lerp(uDim2, (math.min(p2 * 12, 1)))
				local healthPercent = self:GetHealthPercent()
				local healthBarColor = config.HealthBarColor or Color3.fromRGB(30, 140, 220)
				local healthFill = self.healthFill

				if healthPercent < 0.25 then
					healthBarColor = healthBarColor:Lerp(
						Color3.fromRGB(255, 0, 0),
						math.abs((math.sin(os.clock() * 4))) * 0.5
					)
				end

				healthFill.BackgroundColor3 = healthBarColor
			end

			if self.healthDamageFill then
				local healthPercent = self:GetHealthPercent()
				local scale = self.healthDamageFill.Size.X.Scale
				local healthDamageFill = self.healthDamageFill

				if healthPercent < scale then
					healthPercent = math.max(scale - p2 * 0.5, healthPercent)
				end

				healthDamageFill.Size = UDim2.fromScale(healthPercent, 1)
			end

			if self.healthText then
				self.healthText.Text = `{math.ceil(self:GetHealthPercent() * 100)}%`
			end

			local v = math.max(0, fightDuration - (os.clock() - self.fightStartTime))

			if self.timerLabel then
				local v2 = math.ceil(v)
				self.timerLabel.Text = `{v2} Second{v2 == 1 and "" or "s"}`
				local timerLabel = self.timerLabel
				local textColor

				if v <= 10 then
					textColor = Color3.fromRGB(180, 220, 255):Lerp(
						Color3.fromRGB(100, 180, 255),
						(math.abs((math.sin(os.clock() * 3))))
					)
				else
					textColor = Color3.fromRGB(180, 220, 255)
				end

				timerLabel.TextColor3 = textColor
			end

			if v <= 0 then
				self:OnFightComplete()
			end
		end))
	end)
end

setmetatable(PoseidonGodFight, module)
return PoseidonGodFight