local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local module = require("./PassiveHandler")
local Sprite = require(script.Parent.Tidemourner.modules.Sprite)
local fx = require(ReplicatedStorage.shared.modules.fx)
local StormyLightningController = require(ReplicatedStorage.client.legacyControllers.StormyLightningController)
local color = Color3.fromRGB(255, 255, 100)
local color2 = Color3.fromRGB(120, 110, 40)
local color3 = Color3.fromRGB(80, 140, 255)
local color4 = Color3.fromRGB(255, 255, 100)
local ZeusGodFight = {
	CreateSilhouette = function(self)
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Size = UDim2.new(0.25, 0, 0.2, 0)
		imageLabel.Position = UDim2.new(0.5, 0, 0.06, 0)
		imageLabel.AnchorPoint = Vector2.new(0.5, 0)
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = "rbxassetid://120721872732996"
		imageLabel.ImageColor3 = color4
		imageLabel.ImageTransparency = 1
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.ZIndex = 2
		imageLabel.Parent = self.current.reel
		TweenService:Create(imageLabel, TweenInfo.new(3, Enum.EasingStyle.Sine), {
			ImageTransparency = 0.15
		}):Play()
		self.silhouette = imageLabel
	end,
	BarToScreenX = function(self, p2: number)
		local reel_bar = self.current.reel_bar
		local absolutePosition = reel_bar.AbsolutePosition
		local absoluteSize = reel_bar.AbsoluteSize
		local absoluteSize2 = self.current.reel.AbsoluteSize
		return (absolutePosition.X + p2 * absoluteSize.X) / absoluteSize2.X
	end,
	GetBarScreenY = function(self)
		return self.current.reel_bar.Position.Y.Scale
	end,
	CheckHitScreenX = function(self, p: number, value: number?)
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
	end,
	HitEffect = function(self, backgroundColor: Color3)
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
		local humanoidRootPart = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			task.spawn(StormyLightningController.Strike, StormyLightningController, humanoidRootPart.Position, {
				SkipStrikingLock = true,
				BoltColor = Color3.fromRGB(255, 255, 100),
				BoltThickness = 0.6,
				ShakeIntensity = 0.8,
				ShakeDuration = 0.15,
				NoPostFire = true,
				NoExplosion = true
			})
		end
	end,
	SpawnDodgeText = function(self)
		local current = self.current

		if not (current and current.active) then
			return
		end

		local barScreenY = self:GetBarScreenY()
		local barToScreenX = self:BarToScreenX(current.barPosition)
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(0.1, 0, 0.03, 0)
		textLabel.Position = UDim2.fromScale(barToScreenX, barScreenY - 0.04)
		textLabel.AnchorPoint = Vector2.new(0.5, 1)
		textLabel.BackgroundTransparency = 1
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 200)
		textLabel.TextStrokeTransparency = 0.3
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
	end,
	GetPhaseSpeedMult = function(self)
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
	end,
	GetBiasedTargetX = function(self, min: number, max: number)
		if self.random:NextNumber(0, 1) < 0.5 then
			return (math.clamp(self.current.barPosition + self.random:NextNumber(-0.15, 0.15), min, max))
		end

		return self.random:NextNumber(min, max)
	end,
	DamageHealth = function(self, p: number)
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
	end,
	GetHealthPercent = function(self)
		return (math.clamp(self.health / self.maxHealth, 0, 1))
	end,
	CreateHealthBar = function(self)
		local config = self.config
		local frame = Instance.new("Frame")
		frame.Name = "GodFightHealthBar"
		frame.Size = UDim2.new(1, 0, 0, 16)
		frame.Position = UDim2.new(0, 0, 1, 8)
		frame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
		frame.BackgroundTransparency = 0.2
		frame.ZIndex = 10
		local uICorner = Instance.new("UICorner", frame)
		uICorner.CornerRadius = UDim.new(0, 4)
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Color = Color3.fromRGB(120, 120, 30)
		uIStroke.Thickness = 2
		uIStroke.Transparency = 0.2
		uIStroke.Parent = frame
		local frame2 = Instance.new("Frame")
		frame2.Name = "DamageFill"
		frame2.Size = UDim2.fromScale(1, 1)
		frame2.BackgroundColor3 = config.HealthBarDamagedColor or Color3.fromRGB(100, 80, 15)
		frame2.BackgroundTransparency = 0.3
		frame2.ZIndex = 11
		local uICorner_2 = Instance.new("UICorner", frame2)
		uICorner_2.CornerRadius = UDim.new(0, 3)
		frame2.Parent = frame
		local frame3 = Instance.new("Frame")
		frame3.Name = "Fill"
		frame3.Size = UDim2.fromScale(1, 1)
		frame3.BackgroundColor3 = config.HealthBarColor or Color3.fromRGB(255, 255, 100)
		frame3.ZIndex = 12
		local uICorner_3 = Instance.new("UICorner", frame3)
		uICorner_3.CornerRadius = UDim.new(0, 3)
		frame3.Parent = frame
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.BackgroundTransparency = 1
		textLabel.TextColor3 = Color3.fromRGB(40, 30, 0)
		textLabel.TextStrokeTransparency = 0.8
		textLabel.Font = Enum.Font.Fondamento
		textLabel.TextScaled = true
		textLabel.Text = "SURVIVE"
		textLabel.ZIndex = 13
		textLabel.Parent = frame
		frame.Parent = self.current.reel_bar
		self.healthFill = frame3
		self.healthDamageFill = frame2
		self.healthText = textLabel
	end,
	CreateTimer = function(self)
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(0.5, 0, 0, 22)
		textLabel.Position = UDim2.new(0.5, 0, 1, 30)
		textLabel.AnchorPoint = Vector2.new(0.5, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 200)
		textLabel.TextStrokeTransparency = 0.2
		textLabel.TextStrokeColor3 = Color3.fromRGB(60, 50, 0)
		textLabel.TextScaled = true
		textLabel.Font = Enum.Font.Fondamento
		textLabel.Text = ""
		textLabel.ZIndex = 12
		textLabel.Parent = self.current.reel_bar
		self.timerLabel = textLabel
	end,
	CreateOverlay = function(self)
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
	end,
	ShowPhaseText = function(self, text: string)
		local current = self.current

		if not (current and current.active) then
			return
		end

		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(0.25, 0, 0.035, 0)
		textLabel.Position = UDim2.fromScale(0.5, 0.45)
		textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel.BackgroundTransparency = 1
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 150)
		textLabel.TextStrokeTransparency = 0.1
		textLabel.TextStrokeColor3 = Color3.fromRGB(60, 50, 0)
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
	end,
	OnFightComplete = function(self)
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
	end,
	OnFightFailed = function(self)
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
	end,
	CreateOrbs = function(self)
		self.orbs = {}
		self.orbSprites = {}
		local current = self.current
		local barScreenY = self:GetBarScreenY()

		for i = 1, 3 do
			local frame = Instance.new("Frame")
			frame.Name = "ZeusOrb_" .. i
			frame.Size = UDim2.new(0.06, 0, 0.06, 0)
			frame.AnchorPoint = Vector2.new(0.5, 0.5)
			frame.BackgroundTransparency = 1
			frame.ZIndex = 15
			frame.Parent = current.reel
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Size = UDim2.fromScale(2, 2)
			imageLabel.Position = UDim2.fromScale(0.5, 0.5)
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = "rbxassetid://12159555294"
			imageLabel.ImageColor3 = color3
			imageLabel.ImageTransparency = 0.5
			imageLabel.ScaleType = Enum.ScaleType.Fit
			imageLabel.ZIndex = 14
			imageLabel.Parent = frame
			local sprites = {}

			for i2 = 1, 3 do
				local imageLabel2 = Instance.new("ImageLabel")
				imageLabel2.Size = UDim2.fromScale(0.8, 0.8)
				imageLabel2.Position = UDim2.fromScale(0.5, 0.5)
				imageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
				imageLabel2.BackgroundTransparency = 1
				imageLabel2.Image = "rbxassetid://16334776490"
				imageLabel2.ImageColor3 = color3
				imageLabel2.ScaleType = Enum.ScaleType.Fit
				imageLabel2.ZIndex = i2 + 15
				imageLabel2.Rotation = (i2 - 1) * 120
				imageLabel2.Parent = frame
				local v2 = Sprite.new({
					gui = imageLabel2,
					frameWidth = 252,
					frameHeight = 252,
					columns = 4,
					rows = 4,
					startFrame = 1,
					endFrame = 16,
					fps = i2 * 2 + 14,
					loop = true,
					autoPlay = true
				})
				table.insert(sprites, v2)
				table.insert(self.orbSprites, v2)
			end

			local number = self.random:NextNumber(0.2, 0.8)
			local v2 = {
				gui = frame,
				sprites = sprites,
				glow = imageLabel,
				x = number,
				targetX = self.random:NextNumber(0.2, 0.8),
				baseY = barScreenY + -0.15,
				phase = self.random:NextNumber(0, 6.283185307179586),
				attacking = false,
				returning = false
			}
			frame.Position = UDim2.fromScale(self:BarToScreenX(number), v2.baseY)
			table.insert(self.orbs, v2)
		end
	end,
	UpdateOrbs = function(self, p: number)
		for _, orb in self.orbs do
			for _, sprite in orb.sprites do
				sprite:Update()
			end

			if orb.attacking or orb.returning then
				continue
			end

			local v = orb.targetX - orb.x

			if math.abs(v) < 0.01 then
				orb.targetX = self.random:NextNumber(0.15, 0.85)
			end

			orb.x += math.sign(v) * math.min(math.abs(v), p * 0.3)
			orb.phase += p * 3
			local v2 = math.sin(orb.phase) * 0.015
			orb.gui.Position = UDim2.fromScale(self:BarToScreenX(orb.x), orb.baseY + v2)

			for k, sprite in orb.sprites do
				sprite.Gui.Rotation += p * (40 + k * 15)
			end

			orb.glow.ImageTransparency = math.sin(orb.phase * 1.5) * 0.2 + 0.4
		end
	end,
	OrbAttack = function(self, state)
		if state.attacking then
			return
		end

		state.attacking = true
		local current = self.current
		local config = self.config
		local barScreenY = self:GetBarScreenY()
		local biasedTargetX = self:GetBiasedTargetX(0.1, 0.9)
		local barToScreenX = self:BarToScreenX(biasedTargetX)
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.Position = UDim2.new(biasedTargetX, 0, 0.5, 0)
		textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = "!"
		textLabel.Font = Enum.Font.GothamBlack
		textLabel.TextScaled = true
		textLabel.TextColor3 = color3
		textLabel.TextTransparency = 1
		textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
		textLabel.TextStrokeTransparency = 1
		textLabel.ZIndex = 18
		textLabel.Parent = current.reel_bar
		local uIScale = Instance.new("UIScale")
		uIScale.Scale = 2.5
		uIScale.Parent = textLabel
		local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		uIAspectRatioConstraint.AspectRatio = 1
		uIAspectRatioConstraint.Parent = textLabel
		self.current.logicTweens:Create(
			textLabel,
			TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				TextTransparency = 0,
				TextStrokeTransparency = 0.3
			}
		):Play()
		self.current.logicTweens:Create(uIScale, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()
		local orbWarningTime = config.OrbWarningTime or 0.5
		local lastTime = tick()
		local onLogicStepConnection = nil
		onLogicStepConnection = current.OnLogicStep:Connect(function()
			if not textLabel.Parent then
				onLogicStepConnection:Disconnect()
				return
			end

			local v = tick() - lastTime

			if orbWarningTime <= v then
				onLogicStepConnection:Disconnect()
				return
			end

			local v2 = 1 + v / orbWarningTime
			local v3 = math.sin(v * 30) * 2 * v2
			textLabel.Position = UDim2.new(biasedTargetX, v3, 0.5, -14 - v * 8)
		end)
		self.current.logicTweens:Create(state.glow, TweenInfo.new(orbWarningTime), {
			ImageTransparency = 0,
			Size = UDim2.fromScale(3, 3)
		}):Play()
		current:WaitLogic(orbWarningTime)
		self.current.logicTweens:Create(textLabel, TweenInfo.new(0.05), {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}):Play()
		current:DelayLogic(0.1, function()
			if textLabel.Parent then
				textLabel:Destroy()
			end
		end)

		if current.active and self.fightActive then
			local orbDashTime = config.OrbDashTime or 0.15
			local uDim = UDim2.fromScale(barToScreenX, barScreenY)
			local v = self.current.logicTweens:Create(
				state.gui,
				TweenInfo.new(orbDashTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					Position = uDim
				}
			)
			v:Play()
			v.Completed:Wait()

			if current.active and self.fightActive then
				local v2, v3 = self:CheckHitScreenX(barToScreenX, 0.05)

				if v2 then
					self:DamageHealth(config.OrbDamage)
					self:HitEffect(color3)
				elseif v3 then
					self:SpawnDodgeText()
				end

				current.fx:SpawnShake(current.reel_bar, 0.3, 1.5, 0.01, true)
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.Size = UDim2.fromScale(5, 5)
				imageLabel.Position = UDim2.fromScale(0.5, 0.5)
				imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				imageLabel.BackgroundTransparency = 1
				imageLabel.Image = "rbxassetid://12159555294"
				imageLabel.ImageColor3 = color3
				imageLabel.ImageTransparency = 0
				imageLabel.ScaleType = Enum.ScaleType.Fit
				imageLabel.ZIndex = 17
				imageLabel.Parent = state.gui
				self.current.logicTweens:Create(
					imageLabel,
					TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = UDim2.fromScale(8, 8),
						ImageTransparency = 1
					}
				):Play()
				current:DelayLogic(0.45, function()
					if imageLabel.Parent then
						imageLabel:Destroy()
					end
				end)
			end

			current:WaitLogic(0.15)
			state.attacking = false
			state.returning = true
			local number = self.random:NextNumber(0.2, 0.8)
			state.x = number
			state.targetX = number
			self.current.logicTweens:Create(
				state.glow,
				TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					ImageTransparency = 0.5,
					Size = UDim2.fromScale(2, 2)
				}
			):Play()
			local v2 = self.current.logicTweens:Create(
				state.gui,
				TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Position = UDim2.fromScale(self:BarToScreenX(number), state.baseY)
				}
			)
			v2.Completed:Once(function()
				state.returning = false
			end)
			v2:Play()
		else
			state.attacking = false
			TweenService:Create(state.glow, TweenInfo.new(0.3), {
				ImageTransparency = 0.5,
				Size = UDim2.fromScale(2, 2)
			}):Play()
		end
	end,
	SpawnSmite = function(self, p: number)
		local current = self.current

		if not (current and current.active and self.fightActive) then
			return
		end

		local config = self.config
		local v = (config.SmiteWindupTime or 1.2) * self:GetPhaseSpeedMult()
		local smiteWidth = config.SmiteWidth or 0.35
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0, 0, 1, 0)
		frame.Position = UDim2.fromScale(p, 0.5)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.BackgroundColor3 = color2
		frame.BackgroundTransparency = 0.6
		frame.ZIndex = 13
		frame.Parent = current.reel_bar
		local uICorner = Instance.new("UICorner", frame)
		uICorner.CornerRadius = UDim.new(0, 2)
		local frame2 = Instance.new("Frame")
		frame2.Size = UDim2.new(0, 0, 1, 0)
		frame2.Position = UDim2.fromScale(p, 0.5)
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.BackgroundColor3 = color
		frame2.BackgroundTransparency = 0.5
		frame2.ZIndex = 14
		frame2.Parent = current.reel_bar
		local uICorner_2 = Instance.new("UICorner", frame2)
		uICorner_2.CornerRadius = UDim.new(0, 2)
		self.current.logicTweens:Create(
			frame,
			TweenInfo.new(v * 0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = UDim2.new(smiteWidth * 1.2, 0, 1, 0)
			}
		):Play()
		self.current.logicTweens:Create(frame2, TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(smiteWidth, 0, 1, 0),
			BackgroundTransparency = 0.2
		}):Play()
		current:DelayLogic(v * 0.6, function()
			if not frame2.Parent then
				return
			end

			self.current.logicTweens:Create(
				frame2,
				TweenInfo.new(v * 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 3, true),
				{
					BackgroundTransparency = 0.1
				}
			):Play()
		end)
		current:WaitLogic(v)

		if frame.Parent then
			frame:Destroy()
		end

		if frame2.Parent then
			frame2:Destroy()
		end

		if not (current.active and self.fightActive) then
			return
		end

		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Size = UDim2.new(smiteWidth * 2.5, 0, 3, 0)
		imageLabel.Position = UDim2.fromScale(p, -0.1)
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = "rbxassetid://13771592635"
		imageLabel.ImageColor3 = color
		local uIScale = Instance.new("UIScale")
		uIScale.Scale = 3
		uIScale.Parent = imageLabel
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.ZIndex = 16
		imageLabel.Parent = current.reel_bar
		local v2 = Sprite.new({
			gui = imageLabel,
			frameWidth = 252,
			frameHeight = 252,
			columns = 4,
			rows = 4,
			startFrame = 1,
			endFrame = 16,
			fps = 24,
			loop = false,
			autoPlay = true
		})
		current.fx:SpawnShake(current.reel_bar, 0.8, 3, 0.015, true)
		local scale = current.reel_bar.Size.X.Scale
		local v3 = smiteWidth * scale / 2
		local v4 = self:BarToScreenX(p) - v3
		local v5 = self:BarToScreenX(p) + v3
		local v6 = (self.current.barSize or config.DodgeBarSize or 0.3) / 2
		local barToScreenX = self:BarToScreenX(current.barPosition)
		local v7 = barToScreenX - v6 * scale
		local v8 = barToScreenX + v6 * scale

		if v4 <= v8 and v7 <= v5 then
			self:DamageHealth(config.SmiteDamage)
			self:HitEffect(color)
		else
			local v9 = (config.NearMissRange or 0.06) * scale

			if v4 - v9 <= v8 and v7 <= v5 + v9 then
				self:SpawnDodgeText()
			end
		end

		local onLogicStepConnection = nil
		onLogicStepConnection = current.OnLogicStep:Connect(function()
			if not imageLabel.Parent then
				onLogicStepConnection:Disconnect()
				return
			end

			v2:Update()

			if not v2.Playing then
				onLogicStepConnection:Disconnect()
				TweenService:Create(imageLabel, TweenInfo.new(0.2), {
					ImageTransparency = 1
				}):Play()
				task.delay(0.25, function()
					if imageLabel.Parent then
						imageLabel:Destroy()
					end
				end)
			end
		end)
	end,
	RunOrbAttacks = function(self)
		local config = self.config

		while self.current.active and self.fightActive do
			local v = tick() - self.fightStartTime
			local v2 = (config.OrbRamp or 0.02) * v
			local v3 = math.max(0.8, config.OrbAttackInterval * self:GetPhaseSpeedMult() - v2)
			self.current:WaitLogic(v3)

			if not (self.current.active and self.fightActive) then
				break
			end

			local orbs = {}

			for _, orb in self.orbs do
				if not orb.attacking then
					table.insert(orbs, orb)
				end
			end

			if not (#orbs > 0) then
				continue
			end

			local v4 = orbs[self.random:NextInteger(1, #orbs)]
			task.spawn(self.OrbAttack, self, v4)
		end
	end,
	RunSmites = function(self)
		local config = self.config
		local v = true
		self.reelTrove:Add(self.current.OnLogicStep:Connect(function()
			if not (self.fightActive and self.current.active and v) then
				return
			end

			v = false
			local smiteChance = config.SmiteChance

			if self.currentPhase >= 4 then
				smiteChance += 20
			end

			if self.random:NextNumber(0, 100) < smiteChance then
				local integer = self.random:NextInteger(config.SmiteComboMin, config.SmiteComboMax)

				if self.currentPhase >= 4 then
					integer += 1
				end

				for i = 1, integer do
					if self.current.active and self.fightActive then
						task.spawn(self.SpawnSmite, self, self.random:NextNumber(0.15, 0.85))

						if i < integer then
							self.current:WaitLogic(config.SmiteComboDelay or 0.6)
						end
					else
						break
					end
				end
			end

			self.current:DelayLogic(config.SmiteInterval * self:GetPhaseSpeedMult(), function()
				v = true
			end)
		end))
	end,
	Morph = function(self, p, object2)
		local config = self.config
		local isGodFight = config.IsGodFight == true
		task.spawn(
			ContentProvider.PreloadAsync,
			ContentProvider,
			{ "rbxassetid://13771592635", "rbxassetid://16334776490" }
		)
		self.maxHealth = config.MaxHealth or 200
		self.health = self.maxHealth
		self.fightActive = false
		self.fightStartTime = 0
		self.currentPhase = 0
		self.random = object2:GetRandom(9)
		self.orbs = {}
		self.orbSprites = {}

		if isGodFight then
			object2:AddModifier("barSize", "force", config.DodgeBarSize or 0.3)
			object2.core.minigame.NoFail = true
			p.fish.Visible = false
			object2.reel_progspeed.Visible = false
			object2.reel_progress.Visible = false
			object2:AddModifier("progress", "force_final", 0.1)
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

				for _, orb in self.orbs do
					if orb.gui.Parent then
						orb.gui:Destroy()
					end
				end
			end)
			object2.BuildEndingData:BindAtPriority(1000, function(p2)
				p2.IsGodFight = true
				p2.GodName = config.GodName or "Zeus"
				p2.EndingHealth = self.health / self.maxHealth
				return p2
			end)
		end

		task.spawn(function()
			object2:WaitUntilReady()
			self.fightActive = true
			self.fightStartTime = tick()
			self.currentPhase = 1
			self:CreateOrbs()
			self.reelTrove:Add(RunService.RenderStepped:Connect(function(dt)
				if self.fightActive and object2.active then
					self:UpdateOrbs(dt)
				end
			end))
			task.spawn(self.RunOrbAttacks, self)
			task.spawn(self.RunSmites, self)

			if not isGodFight then
				object2.OnMinigameEnd:Once(function()
					self.fightActive = false
				end)
				return
			end

			local fightDuration = config.FightDuration or 45
			self:ShowPhaseText("Zeus strikes!")
			task.spawn(function()
				self.current:WaitLogic(fightDuration * 0.3)

				if not self.fightActive then
					return
				end

				self.currentPhase = 2
				self:ShowPhaseText("Thunder intensifies!")
				object2.fx:SpawnShake(object2.reel_bar, 0.3, 1, 0.02, false)
				self.current:WaitLogic(fightDuration * 0.3)

				if not self.fightActive then
					return
				end

				self.currentPhase = 3
				self:ShowPhaseText("Wrath of Olympus!")
				object2.fx:SpawnShake(object2.reel_bar, 0.5, 2, 0.02, true)
				self.current:WaitLogic(fightDuration * 0.2)

				if not self.fightActive then
					return
				end

				self.currentPhase = 4
				self:ShowPhaseText("Zeus's fury!")
				object2.fx:SpawnShake(object2.reel_bar, 0.7, 3, 0.02, true)
			end)
			self.reelTrove:Add(object2.OnLogicStep:Connect(function(p2)
				if not (self.fightActive and object2.active) then
					return
				end

				if self.healthFill then
					local uDim = UDim2.fromScale(self:GetHealthPercent(), 1)
					self.healthFill.Size = self.healthFill.Size:Lerp(uDim, (math.min(p2 * 12, 1)))
					local healthPercent = self:GetHealthPercent()
					local healthBarColor = config.HealthBarColor or Color3.fromRGB(255, 255, 100)
					local healthFill = self.healthFill

					if healthPercent < 0.25 then
						healthBarColor = healthBarColor:Lerp(
							Color3.fromRGB(255, 0, 0),
							math.abs((math.sin(tick() * 4))) * 0.5
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

				local v = math.max(0, fightDuration - (tick() - self.fightStartTime))

				if self.timerLabel then
					local v2 = math.ceil(v)
					self.timerLabel.Text = `{v2} Second{v2 == 1 and "" or "s"}`
					local timerLabel = self.timerLabel
					local textColor

					if v <= 10 then
						textColor = Color3.fromRGB(255, 255, 200):Lerp(
							Color3.fromRGB(255, 100, 100),
							(math.abs((math.sin(tick() * 3))))
						)
					else
						textColor = Color3.fromRGB(255, 255, 200)
					end

					timerLabel.TextColor3 = textColor
				end

				if v <= 0 then
					self:OnFightComplete()
				end
			end))
		end)
	end
}
setmetatable(ZeusGodFight, module)
return ZeusGodFight