local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local DyleSpeedGauge = {}
DyleSpeedGauge.__index = DyleSpeedGauge
local v = {
	{
		speed = 0,
		color = Color3.fromRGB(40, 40, 40)
	},
	{
		speed = 20,
		color = Color3.fromRGB(50, 30, 30)
	},
	{
		speed = 40,
		color = Color3.fromRGB(60, 35, 25)
	},
	{
		speed = 60,
		color = Color3.fromRGB(70, 40, 25)
	},
	{
		speed = 75,
		color = Color3.fromRGB(80, 45, 30)
	},
	{
		speed = 85,
		color = Color3.fromRGB(90, 35, 35)
	},
	{
		speed = 95,
		color = Color3.fromRGB(110, 25, 25)
	},
	{
		speed = 100,
		color = Color3.fromRGB(130, 15, 15)
	}
}

function DyleSpeedGauge.new(instance, options)
	local object = setmetatable({}, DyleSpeedGauge)
	object.character = instance
	object.config = options or {}
	instance:SetAttribute("DyleSpeedPercent", 0)
	object.humanoid = instance:WaitForChild("Humanoid", 10)
	object.head = instance:WaitForChild("Head", 10)

	if not (object.humanoid and object.head) then
		warn("DyleSpeedGauge: Failed to find required character components")
		return nil
	end

	local DyleMonster = require(ReplicatedStorage.MonsterData.DyleMonster)
	object.baseSpeed = options.BaseSpeed or DyleMonster.WalkSpeed or 9
	object.runSpeed = options.RunSpeed or DyleMonster.RunSpeed or 16
	local maxSpeedMultiplier = options.MaxSpeedMultiplier or DyleMonster.MaxSpeedMultiplier or 2.5
	object.maxSpeed = object.runSpeed * maxSpeedMultiplier
	object.speedBuildRate = options.SpeedBuildRate or DyleMonster.SpeedBuildRate or 0.05
	object.speedDecayRate = options.SpeedDecayRate or DyleMonster.SpeedDecayRate or 0.025
	object.decayDelay = options.DecayDelay or DyleMonster.DecayDelay or 3
	object.resetSpeedOnAttack = options.ResetSpeedOnAttack ~= false
	object.attackSpeedResetDelay = options.AttackSpeedResetDelay or 0
	object.shakeThreshold = options.GaugeShakeThreshold or DyleMonster.GaugeShakeThreshold or 70
	object.flickerThreshold = options.GaugeFlickerThreshold or DyleMonster.GaugeFlickerThreshold or 80
	object.pulseThreshold = options.GaugePulseThreshold or DyleMonster.GaugePulseThreshold or 90
	object.gaugeSize = options.GaugeSize or DyleMonster.GaugeSize or 8
	object.currentSpeedPercent = 0
	object.currentSpeedValue = 0
	object.gaugeSpeedPercent = 0
	object.gaugeSpeedValue = 0
	object.lastLostInterestTime = 0
	object.isDecaying = false
	object.gaugeFillRate = options.GaugeFillRate or object.speedBuildRate
	object.shakeTime = 0
	object.isShaking = false
	object.flickerTime = 0
	object.lastFlicker = 0
	object.lastChaseState = false
	object.hasSetRunAnimation = false
	object.currentAnimationState = "Idle"
	object.lastSpeedThreshold = "walk"
	local chaser = instance:WaitForChild("Chaser", 10)

	if not chaser then
		warn("DyleSpeedGauge: Failed to find Chaser folder")
		return nil
	end

	object.chaserCharacter = instance
	object.chaserValues = {
		getChasing = function()
			return instance:GetAttribute("Chasing")
		end,
		getAttacking = function()
			return instance:GetAttribute("Attacking")
		end,
		getAlerted = function()
			return instance:GetAttribute("Alerted")
		end
	}
	object.speedValue = Instance.new("IntValue")
	object.speedValue.Name = "Speed"
	object.speedValue.Value = 0
	object.speedValue.Parent = instance
	object:createSpeedGauge()
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "DyleSpeedControlActive"
	boolValue.Value = true
	boolValue.Parent = instance
	object:startSpeedControl()
	local DyleGeneratorDetector = require(ReplicatedStorage.MonsterModules.DyleGeneratorDetector)
	object.generatorDetector = DyleGeneratorDetector.new(instance, chaser)
	local DyleParticleEffects = require(ReplicatedStorage.MonsterModules.DyleParticleEffects)
	object.particleEffects = DyleParticleEffects.new(instance, options)
	local DyleMonster2 = require(ReplicatedStorage.MonsterData.DyleMonster)

	if DyleMonster2.SmartBoneEnabled then
		local DyleSmartBoneController = require(ReplicatedStorage.MonsterModules.DyleSmartBoneController)
		object.smartBoneController = DyleSmartBoneController.new(instance, options)
	end

	object.attackConnection = instance:GetAttributeChangedSignal("Attacking"):Connect(function()
		if instance:GetAttribute("Attacking") then
			local v2 = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DyleAttack")

			if not v2 then
				local events = ReplicatedStorage:FindFirstChild("Events")

				if events then
					v2 = Instance.new("RemoteEvent")
					v2.Name = "DyleAttack"
					v2.Parent = events
				end
			end

			if v2 then
				v2:FireAllClients(object.character)
			end

			object.character:SetAttribute("IsAttacking", true)

			if object.resetSpeedOnAttack then
				if not (object.attackSpeedResetDelay > 0) then
					object:resetSpeed()
					return
				end

				task.wait(object.attackSpeedResetDelay)

				if instance:GetAttribute("Attacking") then
					object:resetSpeed()
				end
			end
		else
			object.character:SetAttribute("IsAttacking", false)
		end
	end)
	local animateTower = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("AnimateTower")

	if animateTower then
		task.delay(0.1, function()
			if object.character and object.character.Parent then
				animateTower:FireAllClients(object.character, "Idle")
			end
		end)
	end

	object.destroyConnection = instance:GetPropertyChangedSignal("Parent"):Connect(function()
		if instance.Parent == nil then
			object:cleanup()
		end
	end)
	print("DyleSpeedGauge: Enhanced needle-based speed gauge system initialized for", instance.Name)
	return object
end

function DyleSpeedGauge:createSpeedGauge()
	local speedGauge = self.character:FindFirstChild("SpeedGauge")

	if speedGauge and speedGauge:IsA("BillboardGui") then
		speedGauge.Size = UDim2.new(self.gaugeSize, 0, self.gaugeSize, 0)
		print("DyleSpeedGauge: Using existing SpeedGauge from character, made bigger")
		local humanoidRootPart = self.character:WaitForChild("HumanoidRootPart")
		speedGauge.StudsOffset = Vector3.new(
			0,
			self.head.Position.Y - humanoidRootPart.Position.Y + self.head.Size.Y / 2 + 3,
			0
		)
		speedGauge.AlwaysOnTop = false
		speedGauge.LightInfluence = 0.3
		speedGauge.MaxDistance = 200
		speedGauge.ResetOnSpawn = false
		speedGauge.Enabled = true
		speedGauge.Adornee = humanoidRootPart
		self:setupGaugeReferences(speedGauge)
	else
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Name = "SpeedGauge"
		billboardGui.Size = UDim2.new(self.gaugeSize, 0, self.gaugeSize, 0)
		local humanoidRootPart = self.character:WaitForChild("HumanoidRootPart")
		billboardGui.StudsOffset = Vector3.new(
			0,
			self.head.Position.Y - humanoidRootPart.Position.Y + self.head.Size.Y / 2 + 3,
			0
		)
		billboardGui.AlwaysOnTop = false
		billboardGui.LightInfluence = 0.3
		billboardGui.MaxDistance = 200
		billboardGui.ResetOnSpawn = false
		billboardGui.Enabled = true
		billboardGui.Adornee = humanoidRootPart
		billboardGui.Parent = self.character
		local frame = Instance.new("Frame")
		frame.Name = "OuterFrame"
		frame.Size = UDim2.new(0.8, 0, 0.8, 0)
		frame.Position = UDim2.new(0.1, 0, 0.1, 0)
		frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		frame.BackgroundTransparency = 0.1
		frame.BorderSizePixel = 0
		frame.Rotation = 90
		frame.Parent = billboardGui
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(0.5, 0)
		uICorner.Parent = frame
		local frame2 = Instance.new("Frame")
		frame2.Name = "GaugeBackground"
		frame2.Size = UDim2.new(0.9, 0, 0.9, 0)
		frame2.Position = UDim2.new(0.05, 0, 0.05, 0)
		frame2.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		frame2.BackgroundTransparency = 0.15
		frame2.BorderSizePixel = 0
		frame2.Parent = frame
		local uICorner2 = Instance.new("UICorner")
		uICorner2.CornerRadius = UDim.new(0.5, 0)
		uICorner2.Parent = frame2
		local frame3 = Instance.new("Frame")
		frame3.Name = "GaugeFace"
		frame3.Size = UDim2.new(0.95, 0, 0.95, 0)
		frame3.Position = UDim2.new(0.025, 0, 0.025, 0)
		frame3.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
		frame3.BackgroundTransparency = 0.05
		frame3.BorderSizePixel = 0
		frame3.Rotation = -5
		frame3.Parent = frame2
		local uICorner3 = Instance.new("UICorner")
		uICorner3.CornerRadius = UDim.new(0.5, 0)
		uICorner3.Parent = frame3
		local v2 = {
			{
				value = 0,
				rotation = -45,
				color = Color3.fromRGB(20, 140, 60)
			},
			{
				value = 5,
				rotation = -31.5,
				color = Color3.fromRGB(30, 135, 55)
			},
			{
				value = 10,
				rotation = -18,
				color = Color3.fromRGB(40, 130, 50)
			},
			{
				value = 15,
				rotation = -4.5,
				color = Color3.fromRGB(50, 125, 45)
			},
			{
				value = 20,
				rotation = 9,
				color = Color3.fromRGB(60, 120, 40)
			},
			{
				value = 25,
				rotation = 22.5,
				color = Color3.fromRGB(70, 115, 35)
			},
			{
				value = 30,
				rotation = 36,
				color = Color3.fromRGB(80, 110, 30)
			},
			{
				value = 35,
				rotation = 49.5,
				color = Color3.fromRGB(90, 105, 25)
			},
			{
				value = 40,
				rotation = 63,
				color = Color3.fromRGB(100, 100, 20)
			},
			{
				value = 45,
				rotation = 76.5,
				color = Color3.fromRGB(110, 90, 20)
			},
			{
				value = 50,
				rotation = 90,
				color = Color3.fromRGB(120, 80, 20)
			},
			{
				value = 55,
				rotation = 103.5,
				color = Color3.fromRGB(130, 70, 20)
			},
			{
				value = 60,
				rotation = 117,
				color = Color3.fromRGB(140, 60, 20)
			},
			{
				value = 65,
				rotation = 130.5,
				color = Color3.fromRGB(150, 50, 20)
			},
			{
				value = 70,
				rotation = 144,
				color = Color3.fromRGB(160, 40, 20)
			},
			{
				value = 75,
				rotation = 157.5,
				color = Color3.fromRGB(170, 30, 20)
			},
			{
				value = 80,
				rotation = 171,
				color = Color3.fromRGB(180, 20, 20)
			},
			{
				value = 85,
				rotation = 184.5,
				color = Color3.fromRGB(170, 20, 30)
			},
			{
				value = 90,
				rotation = 198,
				color = Color3.fromRGB(160, 20, 40)
			},
			{
				value = 95,
				rotation = 211.5,
				color = Color3.fromRGB(150, 20, 50)
			},
			{
				value = 100,
				rotation = 225,
				color = Color3.fromRGB(180, 20, 20)
			}
		}

		for _, v3 in ipairs(v2) do
			local frame4 = Instance.new("Frame")
			frame4.Name = "Tick" .. tostring(v3.value)
			frame4.Size = UDim2.new(0.02, 0, 0.08, 0)
			frame4.Position = UDim2.new(0.49, 0, 0.05, 0)
			frame4.AnchorPoint = Vector2.new(0.5, 0)
			frame4.BackgroundColor3 = v3.color
			frame4.BackgroundTransparency = 0.3
			frame4.BorderSizePixel = 0
			frame4.Rotation = v3.rotation
			frame4.Parent = frame3
			local uIGradient = Instance.new("UIGradient")
			uIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, v3.color),
				ColorSequenceKeypoint.new(
					0.5,
					Color3.new(
						math.min(v3.color.R * 1.3, 1),
						math.min(v3.color.G * 1.3, 1),
						(math.min(v3.color.B * 1.3, 1))
					)
				),
				ColorSequenceKeypoint.new(1, v3.color)
			})
			uIGradient.Rotation = 90
			uIGradient.Parent = frame4
		end

		local v3 = {
			{
				text = "0",
				position = UDim2.new(0.2, 0, 0.7, 0)
			},
			{
				text = "25",
				position = UDim2.new(0.15, 0, 0.35, 0)
			},
			{
				text = "50",
				position = UDim2.new(0.5, 0, 0.15, 0)
			},
			{
				text = "75",
				position = UDim2.new(0.85, 0, 0.35, 0)
			},
			{
				text = "100",
				position = UDim2.new(0.8, 0, 0.7, 0)
			}
		}

		for _, v4 in ipairs(v3) do
			local textLabel = Instance.new("TextLabel")
			textLabel.Size = UDim2.new(0.15, 0, 0.1, 0)
			textLabel.Position = v4.position
			textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			textLabel.BackgroundTransparency = 1
			textLabel.Text = v4.text
			textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
			textLabel.TextTransparency = 0.1
			textLabel.TextScaled = true
			textLabel.Font = Enum.Font.Bodoni
			textLabel.TextStrokeTransparency = 0.3
			textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
			textLabel.Parent = frame3
		end

		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "SpeedText"
		textLabel.Size = UDim2.new(0.3, 0, 0.1, 0)
		textLabel.Position = UDim2.new(0.5, 0, 0.65, 0)
		textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = "SPEED"
		textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		textLabel.TextTransparency = 0.1
		textLabel.TextScaled = true
		textLabel.Font = Enum.Font.Bodoni
		textLabel.TextStrokeTransparency = 0.3
		textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		textLabel.Parent = frame3
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Name = "SpeedValue"
		textLabel2.Size = UDim2.new(0.2, 0, 0.15, 0)
		textLabel2.Position = UDim2.new(0.5, 0, 0.75, 0)
		textLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel2.BackgroundTransparency = 1
		textLabel2.Text = "0"
		textLabel2.TextColor3 = Color3.fromRGB(200, 200, 200)
		textLabel2.TextTransparency = 0.1
		textLabel2.TextScaled = true
		textLabel2.Font = Enum.Font.Bodoni
		textLabel2.TextStrokeTransparency = 0.3
		textLabel2.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		textLabel2.Parent = frame3
		local frame4 = Instance.new("Frame")
		frame4.Name = "NeedleContainer"
		frame4.Size = UDim2.new(1, 0, 1, 0)
		frame4.Position = UDim2.new(0.5, 0, 0.5, 0)
		frame4.AnchorPoint = Vector2.new(0.5, 0.5)
		frame4.BackgroundTransparency = 1
		frame4.Rotation = -138
		frame4.Parent = frame3
		local frame5 = Instance.new("Frame")
		frame5.Name = "Needle"
		frame5.Size = UDim2.new(0.03, 0, 0.4, 0)
		frame5.Position = UDim2.new(0.5, 0, 0.5, 0)
		frame5.AnchorPoint = Vector2.new(0.5, 1)
		frame5.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
		frame5.BackgroundTransparency = 0.1
		frame5.BorderSizePixel = 0
		frame5.Rotation = -2
		frame5.Parent = frame4
		local frame6 = Instance.new("Frame")
		frame6.Name = "Frame"
		frame6.Size = UDim2.new(1.5, 0, 0.1, 0)
		frame6.Position = UDim2.new(0.5, 0, 0, 0)
		frame6.AnchorPoint = Vector2.new(0.5, 1)
		frame6.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
		frame6.BackgroundTransparency = 0.2
		frame6.BorderSizePixel = 0
		frame6.Rotation = 45
		frame6.Parent = frame5
		local frame7 = Instance.new("Frame")
		frame7.Name = "CenterPivot"
		frame7.Size = UDim2.new(0.08, 0, 0.08, 0)
		frame7.Position = UDim2.new(0.5, 0, 0.5, 0)
		frame7.AnchorPoint = Vector2.new(0.5, 0.5)
		frame7.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
		frame7.BackgroundTransparency = 0.2
		frame7.BorderSizePixel = 0
		frame7.Rotation = 0
		frame7.Parent = frame3
		local uICorner4 = Instance.new("UICorner")
		uICorner4.CornerRadius = UDim.new(0.5, 0)
		uICorner4.Parent = frame7
		self.speedGauge = billboardGui
		self.outerFrame = frame
		self.gaugeBackground = frame2
		self.gaugeFace = frame3
		self.needleContainer = frame4
		self.needle = frame5
		self.centerPivot = frame7
		self.speedValueText = textLabel2
		self.originalBGPosition = frame2.Position
		self.originalOuterFrameSize = frame.Size
		self:startHorrorEffects()
	end
end

function DyleSpeedGauge:setupGaugeReferences(speedGauge)
	local outerFrame = speedGauge:FindFirstChild("OuterFrame")

	if not outerFrame then
		warn("DyleSpeedGauge: Could not find OuterFrame in existing gauge")
		return
	end

	local gaugeBackground = outerFrame:FindFirstChild("GaugeBackground")

	if not gaugeBackground then
		warn("DyleSpeedGauge: Could not find GaugeBackground in existing gauge")
		return
	end

	local gaugeFace = gaugeBackground:FindFirstChild("GaugeFace")

	if not gaugeFace then
		warn("DyleSpeedGauge: Could not find GaugeFace in existing gauge")
		return
	end

	local needleContainer = gaugeFace:FindFirstChild("NeedleContainer")

	if not needleContainer then
		warn("DyleSpeedGauge: Could not find NeedleContainer in existing gauge")
		return
	end

	local needle = needleContainer:FindFirstChild("Needle")

	if not needle then
		warn("DyleSpeedGauge: Could not find Needle in existing gauge")
		return
	end

	local speedValue = gaugeFace:FindFirstChild("SpeedValue")

	if not speedValue then
		warn("DyleSpeedGauge: Could not find SpeedValue text in existing gauge")
		return
	end

	outerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	outerFrame.BackgroundTransparency = 0.1
	gaugeBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	gaugeBackground.BackgroundTransparency = 0.15
	gaugeFace.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	gaugeFace.BackgroundTransparency = 0.05
	self.speedGauge = speedGauge
	self.outerFrame = outerFrame
	self.gaugeBackground = gaugeBackground
	self.gaugeFace = gaugeFace
	self.needleContainer = needleContainer
	self.needle = needle
	self.speedValueText = speedValue

	if gaugeBackground then
		self.originalBGPosition = gaugeBackground.Position
	end

	if outerFrame then
		self.originalOuterFrameSize = outerFrame.Size
	end

	self:startHorrorEffects()
	print("DyleSpeedGauge: Successfully set up references for existing gauge")
end

function DyleSpeedGauge.lerp(_, p, p2, p3)
	return p * (1 - p3) + p2 * p3
end

function DyleSpeedGauge:lerpColor(data, data2, p)
	return Color3.new(self:lerp(data.R, data2.R, p), self:lerp(data.G, data2.G, p), self:lerp(data.B, data2.B, p))
end

function DyleSpeedGauge:getColorForSpeed(p)
	for i = 1, #v - 1 do
		local v2 = v[i]
		local v3 = v[i + 1]

		if not (v2.speed <= p and p <= v3.speed) then
			continue
		end

		local v4 = (p - v2.speed) / (v3.speed - v2.speed)
		return self:lerpColor(v2.color, v3.color, v4)
	end

	return v[#v].color
end

function DyleSpeedGauge:updateGaugeVisual()
	if not (self.needleContainer and self.speedValueText and self.gaugeBackground) then
		warn("DyleSpeedGauge: Missing components in updateGaugeVisual, skipping update")
		return
	end

	local v2 = math.clamp(self.gaugeSpeedValue, 0, 100)
	local v3 = v2 / 100
	local lerped = self:lerp(-138, 138, v3)

	if self.needleContainer and self.needleContainer.Parent then
		local v4 = 0.5 - v3 * 0.4
		local tweenInfo = TweenInfo.new(v4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		TweenService:Create(self.needleContainer, tweenInfo, {
			Rotation = lerped
		}):Play()
	end

	if self.speedValueText and self.speedValueText.Parent then
		self.speedValueText.Text = tostring((math.floor(v2)))
	end

	if self.gaugeBackground and self.gaugeBackground.Parent then
		local colorForSpeed = self:getColorForSpeed(v2)
		local v4 = 0.5 - v3 * 0.4
		local tweenInfo = TweenInfo.new(v4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		TweenService:Create(self.gaugeBackground, tweenInfo, {
			BackgroundColor3 = colorForSpeed
		}):Play()
	end

	self.isShaking = self.shakeThreshold <= v2

	if self.pulseThreshold <= v2 and self.gaugeBackground and self.gaugeBackground.Parent then
		local tween = TweenService:Create(
			self.gaugeBackground,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				BackgroundTransparency = 0.6
			}
		)
		tween:Play()
		tween.Completed:Connect(function()
			if self.gaugeBackground and self.gaugeBackground.Parent then
				TweenService:Create(
					self.gaugeBackground,
					TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						BackgroundTransparency = 0.4
					}
				):Play()
			end
		end)
	end
end

function DyleSpeedGauge:startHorrorEffects()
	local total = 0
	self.horrorConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt

		if total < 0.03333333333333333 then
			return
		end

		total = 0

		if not (self.outerFrame and self.gaugeBackground and self.needleContainer) then
			return
		end

		if self.isShaking then
			self.shakeTime += dt
			local currentSpeedValue = self.currentSpeedValue
			local v2 = 12 * ((currentSpeedValue - self.shakeThreshold) / (100 - self.shakeThreshold))
			local v3 = 1 + currentSpeedValue / 100 * 2
			local v4 = math.sin(self.shakeTime * 40 * v3) * v2 * 0.8
			local v5 = math.cos(self.shakeTime * 15 * v3) * v2 * 0.6
			local v6 = (math.random() - 0.5) * v2 * 1.2
			local v7 = v4 + v5 + v6
			local v8 = math.cos(self.shakeTime * 35 * v3) * v2 + (math.random() - 0.5) * v2 * 0.8

			if self.outerFrame and self.outerFrame.Parent then
				self.outerFrame.Position = UDim2.new(0.1, v7, 0.1, v8)
			end

			if self.gaugeBackground and self.gaugeBackground.Parent and self.originalBGPosition then
				self.gaugeBackground.Position = UDim2.new(
					self.originalBGPosition.X.Scale,
					self.originalBGPosition.X.Offset + (math.random() - 0.5) * v2 * 0.5,
					self.originalBGPosition.Y.Scale,
					self.originalBGPosition.Y.Offset + (math.random() - 0.5) * v2 * 0.5
				)
			end

			if self.pulseThreshold <= currentSpeedValue then
				local v9 = math.sin(self.shakeTime * 30 * v3) * 0.1 + 1
				local rotation = math.sin(self.shakeTime * 45 * v3) * 5

				if self.outerFrame and self.outerFrame.Parent and self.originalOuterFrameSize then
					self.outerFrame.Size = UDim2.new(
						self.originalOuterFrameSize.X.Scale * v9,
						self.originalOuterFrameSize.X.Offset,
						self.originalOuterFrameSize.Y.Scale * v9,
						self.originalOuterFrameSize.Y.Offset
					)
					self.outerFrame.Rotation = rotation
				end

				if self.needleContainer and self.needleContainer.Parent then
					self.needleContainer.Rotation = self.needleContainer.Rotation + (math.random() - 0.5) * 3
				end
			end
		else
			if self.outerFrame and self.outerFrame.Parent then
				self.outerFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
				self.outerFrame.Rotation = 0
			end

			if self.gaugeBackground and self.gaugeBackground.Parent and self.originalBGPosition then
				self.gaugeBackground.Position = self.originalBGPosition
			end

			if self.outerFrame and self.outerFrame.Parent and self.originalOuterFrameSize then
				self.outerFrame.Size = self.originalOuterFrameSize
			end
		end

		self.flickerTime += dt
		local currentSpeedValue = self.currentSpeedValue
		local v2 = currentSpeedValue / 100
		local v3 = 0.05 + math.random() * 0.2
		local v4 = 1 - v2 * 0.8

		if self.flickerThreshold <= currentSpeedValue then
			local v5 = self.flickerTime - self.lastFlicker

			if v3 * v4 < v5 then
				self.lastFlicker = self.flickerTime

				if self.speedValueText and self.speedValueText.Parent then
					self.speedValueText.TextTransparency = 0.3 + math.random() * 0.6
				end

				if self.needle and self.needle.Parent then
					self.needle.BackgroundTransparency = math.random() * 0.4
				end

				if math.random() < 0.3 and self.outerFrame and self.outerFrame.Parent then
					self.outerFrame.BackgroundTransparency = 0.1 + math.random() * 0.4
				end

				task.spawn(function()
					task.wait(0.03)

					if self.speedValueText and self.speedValueText.Parent then
						self.speedValueText.TextTransparency = 0.1
					end

					if self.needle and self.needle.Parent then
						self.needle.BackgroundTransparency = 0.1
					end

					if self.outerFrame and self.outerFrame.Parent then
						self.outerFrame.BackgroundTransparency = 0.3
					end
				end)
			end
		end
	end)
end

function DyleSpeedGauge.horrorPulse(p)
	local v2 = p.currentSpeedValue / 100
	local v3 = 0.2 * (1 - v2 * 0.5)
	local v4 = 0.3 * (1 - v2 * 0.5)
	local tween = TweenService:Create(
		p.outerFrame,
		TweenInfo.new(v3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Size = UDim2.new(1.15, 0, 1.15, 0)
		}
	)
	tween:Play()
	tween.Completed:Connect(function()
		wait(0.1 * (1 - v2 * 0.5))
		TweenService:Create(p.outerFrame, TweenInfo.new(v4, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 1, 0)
		}):Play()
	end)
end

function DyleSpeedGauge:resetSpeed()
	self.currentSpeedPercent = 0
	self.currentSpeedValue = 0
	self.gaugeSpeedPercent = 0
	self.gaugeSpeedValue = 0
	self.speedValue.Value = 0
	self.isDecaying = false
	self:updateGaugeVisual()
	self:updateWalkSpeed()
	print("DyleSpeedGauge: Speed reset due to attack")
end

function DyleSpeedGauge:setSpeed(value)
	self.currentSpeedValue = math.clamp(value, 0, 100)
	self.speedValue.Value = self.currentSpeedValue
	self:updateGaugeVisual()
end

function DyleSpeedGauge:startSpeedControl()
	self.heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		local currentSpeedPercent = self.currentSpeedPercent
		local gaugeSpeedPercent = self.gaugeSpeedPercent
		local chasing = self.character:GetAttribute("Chasing")
		local alerted = self.character:GetAttribute("Alerted")
		local lostInterest = self.character:GetAttribute("LostInterest")

		if (chasing or alerted) and not lostInterest then
			if alerted and currentSpeedPercent < 0.5 then
				currentSpeedPercent = 0.6
				gaugeSpeedPercent = 0.6
			else
				currentSpeedPercent = math.min(1, currentSpeedPercent + self.speedBuildRate * dt)
				gaugeSpeedPercent = math.min(1, gaugeSpeedPercent + self.gaugeFillRate * dt)
			end

			self.isDecaying = false
		else
			if not self.isDecaying then
				if lostInterest then
					self.lastLostInterestTime = tick()
				end

				if tick() - self.lastLostInterestTime > self.decayDelay then
					self.isDecaying = true
				end
			end

			if self.isDecaying then
				currentSpeedPercent = math.max(0, currentSpeedPercent - self.speedDecayRate * dt)
				gaugeSpeedPercent = math.max(0, gaugeSpeedPercent - self.speedDecayRate * dt)
			end
		end

		self.currentSpeedPercent = currentSpeedPercent
		self.currentSpeedValue = currentSpeedPercent * 100
		self.speedValue.Value = self.currentSpeedValue
		self.gaugeSpeedPercent = gaugeSpeedPercent
		self.gaugeSpeedValue = gaugeSpeedPercent * 100
		self:updateGaugeVisual()
		self:updateWalkSpeed()
		self:updateAnimationTempo()
	end)
end

function DyleSpeedGauge:updateWalkSpeed()
	local v2 = self.maxSpeed - self.baseSpeed
	local walkSpeed = self.baseSpeed + v2 * self.currentSpeedPercent
	self.humanoid.WalkSpeed = walkSpeed
	self:updateAnimationSpeed()
	self:updateClockAndMusic()
	self.character:SetAttribute("DyleSpeedPercent", self.currentSpeedPercent)
end

function DyleSpeedGauge:updateAnimationSpeed()
	local lastAnimSpeed = math.max(1, self.currentSpeedPercent <= 0 and 1 or 1 + self.currentSpeedPercent * 1.5)

	if not self.lastAnimSpeed or math.abs(lastAnimSpeed - self.lastAnimSpeed) > 0.05 then
		self.lastAnimSpeed = lastAnimSpeed
		local animationSpeed = game.ReplicatedStorage:FindFirstChild("Events") and game.ReplicatedStorage.Events:FindFirstChild("AnimationSpeed")

		if animationSpeed then
			if self.currentSpeedPercent <= 0.1 then
				print("DyleSpeedGauge: Animation speed at low aggro:", lastAnimSpeed)
			end

			animationSpeed:FireAllClients(self.character, lastAnimSpeed)
		else
			warn("DyleSpeedGauge: AnimationSpeed event not found")
		end
	end
end

function DyleSpeedGauge:updateClockAndMusic()
	local monsterData = game.ReplicatedStorage:FindFirstChild("MonsterData")

	if not monsterData then
		return
	end

	local dyleMonster = monsterData:FindFirstChild("DyleMonster")

	if not dyleMonster then
		return
	end

	local success, result = pcall(require, dyleMonster)

	if not success then
		warn("DyleSpeedGauge: Failed to load DyleMonster module")
		return
	end

	local currentSpeedPercent = self.currentSpeedPercent

	if result.UpdateClockFaceAnimation then
		result.UpdateClockFaceAnimation(self.character, currentSpeedPercent)
	end

	if result.UpdateMusicTempo then
		result.UpdateMusicTempo(self.character, currentSpeedPercent)
	end
end

function DyleSpeedGauge:updateAnimationTempo()
	if not self.config.ScaleAnimationTempo then
		return
	end

	self:updateAnimationState()
	self:updateAnimationSpeed()
	self:updateClockAndMusic()
end

function DyleSpeedGauge:updateAnimationState()
	local animateTower = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("AnimateTower")
	local animationStop = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("AnimationStop")

	if not animateTower then
		warn("DyleSpeedGauge: AnimateTower event not found")
		return
	end

	local chasing = self.character:GetAttribute("Chasing")
	local alerted = self.character:GetAttribute("Alerted")
	local lostInterest = self.character:GetAttribute("LostInterest")
	local wandering = self.character:GetAttribute("Wandering")
	local currentAnimationState, lastSpeedThreshold

	if (chasing or alerted) and not lostInterest then
		currentAnimationState = "Run"
		lastSpeedThreshold = "run"
	elseif lostInterest then
		currentAnimationState = "LostInterest"
		lastSpeedThreshold = "idle"
	elseif wandering then
		currentAnimationState = "Walk"
		lastSpeedThreshold = "walk"
	else
		currentAnimationState = "Idle"
		lastSpeedThreshold = "idle"
	end

	if currentAnimationState ~= self.currentAnimationState then
		if animationStop and self.currentAnimationState ~= "Idle" then
			animationStop:FireAllClients(self.character, self.currentAnimationState)
		end

		animateTower:FireAllClients(self.character, currentAnimationState)
		self.currentAnimationState = currentAnimationState

		if currentAnimationState == "LostInterest" then
			local DyleMonster = require(ReplicatedStorage.MonsterData.DyleMonster)
			local lostInterestAnimationTime = DyleMonster.LostInterestAnimationTime or 2.5
			task.delay(lostInterestAnimationTime, function()
				if self.character and self.character.Parent and self.character:GetAttribute("LostInterest") then
					self.character:SetAttribute("LostInterest", false)

					if self.currentAnimationState == "LostInterest" then
						animateTower:FireAllClients(self.character, "Idle")
						self.currentAnimationState = "Idle"
					end
				end
			end)
		end
	end

	self.lastSpeedThreshold = lastSpeedThreshold
end

function DyleSpeedGauge:cleanup()
	self.character:SetAttribute("DyleRemoved", true)
	self.character:SetAttribute("DyleSpeedPercent", nil)
	local dyleSpeedControlActive = self.character:FindFirstChild("DyleSpeedControlActive")

	if dyleSpeedControlActive then
		dyleSpeedControlActive:Destroy()
	end

	if self.heartbeatConnection then
		self.heartbeatConnection:Disconnect()
		self.heartbeatConnection = nil
	end

	if self.horrorConnection then
		self.horrorConnection:Disconnect()
		self.horrorConnection = nil
	end

	local clockHands = self.character and self.character:FindFirstChild("ClockHands")

	if clockHands then
		local minuteHand = clockHands:FindFirstChild("MinuteHand")
		local hourHand = clockHands:FindFirstChild("HourHand")
		local rotationConnection = minuteHand and minuteHand:GetAttribute("RotationConnection")

		if rotationConnection then
			local RunService2 = game:GetService("RunService")
			RunService2:UnbindFromRenderStep(rotationConnection)
			minuteHand:SetAttribute("RotationConnection", nil)
		end

		local rotationConnection2 = hourHand and hourHand:GetAttribute("RotationConnection")

		if rotationConnection2 then
			local RunService2 = game:GetService("RunService")
			RunService2:UnbindFromRenderStep(rotationConnection2)
			hourHand:SetAttribute("RotationConnection", nil)
		end
	end

	if self.autoAnimateConnection then
		self.autoAnimateConnection:Disconnect()
		self.autoAnimateConnection = nil
	end

	if self.attackConnection then
		self.attackConnection:Disconnect()
		self.attackConnection = nil
	end

	if self.speedValue then
		self.speedValue:Destroy()
		self.speedValue = nil
	end

	if self.humanoid then
		self.humanoid.WalkSpeed = self.baseSpeed
	end

	if self.speedGauge then
		self.speedGauge:Destroy()
		self.speedGauge = nil
	end

	if self.destroyConnection then
		self.destroyConnection:Disconnect()
		self.destroyConnection = nil
	end

	if self.generatorDetector then
		self.generatorDetector:destroy()
		self.generatorDetector = nil
	end

	if self.particleEffects then
		self.particleEffects:destroy()
		self.particleEffects = nil
	end

	if self.smartBoneController then
		self.smartBoneController:destroy()
		self.smartBoneController = nil
	end

	print("DyleSpeedGauge: Enhanced needle-based cleanup completed for", self.character.Name)
end

return DyleSpeedGauge