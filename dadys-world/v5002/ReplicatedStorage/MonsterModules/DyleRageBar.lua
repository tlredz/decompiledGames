local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local DyleRageBar = {}
DyleRageBar.__index = DyleRageBar
local v = {
	{
		speed = 0,
		color = Color3.fromRGB(255, 182, 193)
	},
	{
		speed = 20,
		color = Color3.fromRGB(255, 160, 170)
	},
	{
		speed = 40,
		color = Color3.fromRGB(255, 130, 140)
	},
	{
		speed = 60,
		color = Color3.fromRGB(255, 100, 110)
	},
	{
		speed = 80,
		color = Color3.fromRGB(255, 70, 80)
	},
	{
		speed = 90,
		color = Color3.fromRGB(255, 40, 50)
	},
	{
		speed = 100,
		color = Color3.fromRGB(255, 20, 30)
	}
}

function DyleRageBar.new(instance, options)
	local object = setmetatable({}, DyleRageBar)
	object.character = instance
	object.config = options or {}
	instance:SetAttribute("DyleSpeedPercent", 0)
	object.humanoid = instance:WaitForChild("Humanoid", 10)
	object.hrp = instance:WaitForChild("HumanoidRootPart", 10)

	if object.humanoid and object.hrp then
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
		object.currentSpeedPercent = 0
		object.currentSpeedValue = 0
		object.barSpeedPercent = 0
		object.barSpeedValue = 0
		object.lastLostInterestTime = 0
		object.isDecaying = false
		object.speedOverride = nil
		object.speedOverrideEndTime = 0
		object.barFillRate = options.GaugeFillRate or object.speedBuildRate
		object.shakeThreshold = options.GaugeShakeThreshold or DyleMonster.GaugeShakeThreshold or 70
		object.pulseThreshold = options.GaugePulseThreshold or DyleMonster.GaugePulseThreshold or 80
		object.flickerThreshold = options.GaugeFlickerThreshold or DyleMonster.GaugeFlickerThreshold or 80
		object.shakeTime = 0
		object.isShaking = false
		object.lastChaseState = false
		object.hasSetRunAnimation = false
		object.currentAnimationState = "Idle"
		object.lastSpeedThreshold = "walk"
		object.speedValue = Instance.new("IntValue")
		object.speedValue.Name = "Speed"
		object.speedValue.Value = 0
		object.speedValue.Parent = instance
		object:createRageBar()
		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "DyleSpeedControlActive"
		boolValue.Value = true
		boolValue.Parent = instance
		object:startSpeedControl()
		local DyleGeneratorDetector = require(ReplicatedStorage.MonsterModules.DyleGeneratorDetector)
		object.generatorDetector = DyleGeneratorDetector.new(instance, nil, object)
		local DyleParticleEffects = require(ReplicatedStorage.MonsterModules.DyleParticleEffects)
		object.particleEffects = DyleParticleEffects.new(instance, options)

		if DyleMonster.SmartBoneEnabled then
			local DyleSmartBoneController = require(ReplicatedStorage.MonsterModules.DyleSmartBoneController)
			object.smartBoneController = DyleSmartBoneController.new(instance, options)
		end

		local DyleAnimationController = require(ReplicatedStorage.MonsterModules.DyleAnimationController)
		object.animationController = DyleAnimationController.new(instance, DyleMonster)
		object.attackConnection = instance:GetAttributeChangedSignal("Attacking"):Connect(function()
			if instance:GetAttribute("Attacking") then
				object.character:SetAttribute("IsAttacking", true)
				object.character:SetAttribute("LastAttackTime", tick())

				if object.resetSpeedOnAttack then
					if object.attackSpeedResetDelay > 0 then
						task.delay(object.attackSpeedResetDelay, function()
							if object.character:GetAttribute("Attacking") then
								object:resetSpeed()
							end
						end)
					else
						object:resetSpeed()
					end
				end
			else
				object.character:SetAttribute("IsAttacking", false)
			end
		end)
		object.destroyConnection = instance:GetPropertyChangedSignal("Parent"):Connect(function()
			if instance.Parent == nil then
				object:cleanup()
			end
		end)
		return object
	else
		warn("DyleRageBar: Failed to find required character components")
		object:cleanup()
		return nil
	end
end

function DyleRageBar:createRageBar()
	local gaugePositionReference = self.character:FindFirstChild("GaugePositionReference")
	local hrp = self.hrp
	local studsOffset

	if gaugePositionReference and gaugePositionReference:IsA("ObjectValue") and gaugePositionReference.Value then
		hrp = gaugePositionReference.Value
		studsOffset = createVector(0, 0, 0)
	else
		studsOffset = createVector(0, 1, 4)
	end

	local v3 = self.hrp:FindFirstChild("RageGUI")

	if not v3 then
		local parts = ReplicatedStorage:FindFirstChild("Parts")

		if parts then
			local rageGUI = parts:FindFirstChild("RageGUI")

			if rageGUI then
				v3 = rageGUI:Clone()
				v3.Parent = self.hrp
				local maxFrame = v3:FindFirstChild("MaxFrame")

				if maxFrame then
					maxFrame.BackgroundColor3 = Color3.fromRGB(128, 128, 128)
					maxFrame.BackgroundTransparency = 0.3
					local currentFrame = maxFrame:FindFirstChild("CurrentFrame")

					if currentFrame then
						currentFrame.BackgroundColor3 = v[1].color
						currentFrame.BackgroundTransparency = 0
					end
				end
			end
		end
	end

	if v3 then
		v3.Adornee = hrp
		v3.StudsOffset = studsOffset
		v3.MaxDistance = 75
		local maxFrame = v3:FindFirstChild("MaxFrame")

		if maxFrame then
			maxFrame.BackgroundColor3 = Color3.fromRGB(128, 128, 128)
			maxFrame.BackgroundTransparency = 0.3
			local currentFrame = maxFrame:FindFirstChild("CurrentFrame")

			if currentFrame then
				currentFrame.BackgroundColor3 = v[1].color
			end
		end
	else
		v3 = Instance.new("BillboardGui")
		v3.Name = "RageGUI"
		v3.Size = UDim2.new(6, 0, 1, 0)
		v3.StudsOffset = studsOffset
		v3.AlwaysOnTop = false
		v3.LightInfluence = 0
		v3.MaxDistance = 75
		v3.ResetOnSpawn = false
		v3.Enabled = true
		v3.Adornee = hrp
		v3.Parent = self.hrp
		local frame = Instance.new("Frame")
		frame.Name = "MaxFrame"
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.Position = UDim2.new(0, 0, 0, 0)
		frame.BackgroundColor3 = Color3.fromRGB(128, 128, 128)
		frame.BackgroundTransparency = 0.3
		frame.BorderSizePixel = 0
		frame.Parent = v3
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(0.3, 0)
		uICorner.Parent = frame
		local frame2 = Instance.new("Frame")
		frame2.Name = "CurrentFrame"
		frame2.Size = UDim2.new(0, 0, 1, 0)
		frame2.Position = UDim2.new(0, 0, 0, 0)
		frame2.BackgroundColor3 = v[1].color
		frame2.BackgroundTransparency = 0
		frame2.BorderSizePixel = 0
		frame2.Parent = frame
		local uICorner2 = Instance.new("UICorner")
		uICorner2.CornerRadius = UDim.new(0.3, 0)
		uICorner2.Parent = frame2
	end

	self.rageGUI = v3
	self.maxFrame = v3:FindFirstChild("MaxFrame")
	self.currentFrame = self.maxFrame and self.maxFrame:FindFirstChild("CurrentFrame")

	if not (self.maxFrame and self.currentFrame) then
		warn("DyleRageBar: Failed to find MaxFrame or CurrentFrame in RageGUI")
		return
	end

	self.originalGUIPosition = v3.StudsOffset
	self.originalMaxFrameSize = self.maxFrame.Size
	self:startVisualEffects()
end

function DyleRageBar.lerp(_, p, p2, p3)
	return p * (1 - p3) + p2 * p3
end

function DyleRageBar:lerpColor(data, data2, p)
	return Color3.new(self:lerp(data.R, data2.R, p), self:lerp(data.G, data2.G, p), self:lerp(data.B, data2.B, p))
end

function DyleRageBar:getColorForSpeed(p)
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

function DyleRageBar:updateBarVisual()
	if not (self.currentFrame and self.maxFrame) then
		return
	end

	local v2 = math.clamp(self.barSpeedValue, 0, 100)
	local v3 = v2 / 100
	local tweenInfo = TweenInfo.new(0.275, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	TweenService:Create(self.currentFrame, tweenInfo, {
		Size = UDim2.new(math.clamp(v3, 0, 1), 0, 1, 0)
	}):Play()
	local colorForSpeed = self:getColorForSpeed(v2)
	TweenService:Create(self.currentFrame, tweenInfo, {
		BackgroundColor3 = colorForSpeed
	}):Play()
	self.isShaking = self.shakeThreshold <= v2

	if self.pulseThreshold <= v2 then
		self:pulseEffect()
	end
end

function DyleRageBar:pulseEffect()
	if not self.currentFrame then
		return
	end

	local tween = TweenService:Create(
		self.currentFrame,
		TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{
			BackgroundTransparency = 0.3
		}
	)
	tween:Play()
	tween.Completed:Connect(function()
		if self.currentFrame and self.currentFrame.Parent then
			TweenService:Create(
				self.currentFrame,
				TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					BackgroundTransparency = 0
				}
			):Play()
		end
	end)
end

function DyleRageBar:startVisualEffects()
	self.effectConnection = RunService.Heartbeat:Connect(function(dt)
		if not (self.rageGUI and self.maxFrame) then
			return
		end

		if self.maxFrame.BackgroundColor3 ~= Color3.fromRGB(128, 128, 128) then
			self.maxFrame.BackgroundColor3 = Color3.fromRGB(128, 128, 128)
		end

		if self.isShaking then
			self.shakeTime += dt
			local currentSpeedValue = self.currentSpeedValue
			local v2 = 8 * ((currentSpeedValue - self.shakeThreshold) / (100 - self.shakeThreshold))
			local v3 = 1 + currentSpeedValue / 100 * 2
			local v4 = math.sin(self.shakeTime * 30 * v3) * v2
			local v5 = math.cos(self.shakeTime * 25 * v3) * v2 * 0.5
			self.rageGUI.StudsOffset = Vector3.new(
				self.originalGUIPosition.X + v4 * 0.01,
				self.originalGUIPosition.Y + v5 * 0.01,
				self.originalGUIPosition.Z
			)

			if currentSpeedValue >= 90 then
				local v6 = math.sin(self.shakeTime * 20 * v3) * 0.05 + 1
				self.maxFrame.Size = UDim2.new(
					self.originalMaxFrameSize.X.Scale * v6,
					self.originalMaxFrameSize.X.Offset,
					self.originalMaxFrameSize.Y.Scale,
					self.originalMaxFrameSize.Y.Offset
				)
			end
		else
			self.rageGUI.StudsOffset = self.originalGUIPosition
			self.maxFrame.Size = self.originalMaxFrameSize
		end
	end)
end

function DyleRageBar:startSpeedControl()
	self.heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if not (self.character and self.character.Parent) then
			self:cleanup()
			return
		end

		local currentSpeedPercent = self.currentSpeedPercent
		local barSpeedPercent = self.barSpeedPercent
		local chasing = self.character:GetAttribute("Chasing")
		local alerted = self.character:GetAttribute("Alerted")
		local lostInterest = self.character:GetAttribute("LostInterest")

		if (chasing or alerted) and not lostInterest then
			if alerted and currentSpeedPercent < 0.5 then
				currentSpeedPercent = 0.5
				barSpeedPercent = 0.5
			else
				currentSpeedPercent = math.min(1, currentSpeedPercent + self.speedBuildRate * dt)
				barSpeedPercent = math.min(1, barSpeedPercent + self.barFillRate * dt)
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
				barSpeedPercent = math.max(0, barSpeedPercent - self.speedDecayRate * dt)
			end
		end

		self.currentSpeedPercent = currentSpeedPercent
		self.currentSpeedValue = currentSpeedPercent * 100
		self.speedValue.Value = self.currentSpeedValue
		self.barSpeedPercent = barSpeedPercent
		self.barSpeedValue = barSpeedPercent * 100
		self:updateBarVisual()
		self:updateWalkSpeed()
		self:updateAnimationTempo()

		if self.animationController then
			self.animationController:update(
				chasing and not lostInterest,
				self.character:GetAttribute("Attacking"),
				self.currentSpeedPercent
			)
		end
	end)
end

function DyleRageBar:resetSpeed()
	self.currentSpeedPercent = 0
	self.currentSpeedValue = 0
	self.barSpeedPercent = 0
	self.barSpeedValue = 0
	self.speedValue.Value = 0
	self.isDecaying = false
	self:updateBarVisual()
	self:updateWalkSpeed()
end

function DyleRageBar:updateWalkSpeed()
	if not (self.humanoid and self.character and self.character.Parent) then
		return
	end

	local v2 = self.maxSpeed - self.baseSpeed
	local speedOverride = self.baseSpeed + v2 * self.currentSpeedPercent

	if self.speedOverride ~= nil then
		if tick() < self.speedOverrideEndTime then
			speedOverride = self.speedOverride
		else
			self.speedOverride = nil
			self.speedOverrideEndTime = 0
		end
	end

	local walkSpeed = self.humanoid.WalkSpeed
	local speedDebuff = self.character:FindFirstChild("SpeedDebuff")

	if speedDebuff and speedDebuff:FindFirstChild("Multiplier") then
		speedOverride *= speedDebuff.Multiplier.Value
	end

	local springFeverSpeedBoost = self.character:GetAttribute("SpringFeverSpeedBoost")

	if springFeverSpeedBoost and springFeverSpeedBoost ~= 1 then
		speedOverride *= springFeverSpeedBoost
	end

	self.humanoid.WalkSpeed = speedOverride
	self.character:SetAttribute("DyleSpeedPercent", self.currentSpeedPercent)

	if math.abs(walkSpeed - speedOverride) > 0.5 then
		self.character:SetAttribute("DyleSpeedChanged", tick())
	end
end

function DyleRageBar:setSpeedOverride(speedOverride, p)
	self.speedOverride = speedOverride
	self.speedOverrideEndTime = tick() + p
	self:updateWalkSpeed()
end

function DyleRageBar:clearSpeedOverride()
	self.speedOverride = nil
	self.speedOverrideEndTime = 0
	self:updateWalkSpeed()
end

function DyleRageBar:updateAnimationSpeed()
	local lastAnimSpeed = math.max(1, self.currentSpeedPercent <= 0 and 1 or 1 + self.currentSpeedPercent * 1.5)

	if not self.lastAnimSpeed or math.abs(lastAnimSpeed - self.lastAnimSpeed) > 0.05 then
		self.lastAnimSpeed = lastAnimSpeed
		local animationSpeed = game.ReplicatedStorage:FindFirstChild("Events") and game.ReplicatedStorage.Events:FindFirstChild("AnimationSpeed")

		if animationSpeed then
			local _ = self.currentSpeedPercent <= 0.1
			animationSpeed:FireAllClients(self.character, lastAnimSpeed)
		end
	end
end

function DyleRageBar:updateClockAndMusic()
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
		return
	end

	local currentSpeedPercent = self.currentSpeedPercent

	if result.UpdateClockFaceAnimation then
		result.UpdateClockFaceAnimation(self.character, currentSpeedPercent)
	end

	if result.UpdateMusicTempo then
		if currentSpeedPercent > 0.1 or not self.character:GetAttribute("MusicSpeedLogged") then
			self.character:SetAttribute("MusicSpeedLogged", true)
		end

		result.UpdateMusicTempo(self.character, currentSpeedPercent)
	end
end

function DyleRageBar:updateAnimationTempo()
	if not self.character:GetAttribute("TempoDebugStarted") then
		self.character:SetAttribute("TempoDebugStarted", true)
	end

	if not self.config.ScaleAnimationTempo then
		warn("DyleRageBar: ScaleAnimationTempo is false, skipping tempo updates")
		return
	end

	self:updateAnimationState()
	self:updateAnimationSpeed()
	self:updateClockAndMusic()
end

function DyleRageBar:updateAnimationState()
	local DyleMonster = require(ReplicatedStorage.MonsterData.DyleMonster)

	if not DyleMonster.ClockHandsEnabled then
		return
	end

	local lastSpeedThreshold = self.currentSpeedPercent < 0.33 and "slow" or self.currentSpeedPercent < 0.66 and "normal" or "fast"

	if lastSpeedThreshold ~= self.lastSpeedThreshold then
		self.lastSpeedThreshold = lastSpeedThreshold

		if DyleMonster.UpdateClockFaceAnimation then
			DyleMonster.UpdateClockFaceAnimation(self.character, self.currentSpeedPercent)
		end
	end
end

function DyleRageBar:cleanup()
	if self.character and self.character.Parent then
		pcall(function()
			self.character:SetAttribute("DyleRemoved", true)
			self.character:SetAttribute("DyleSpeedPercent", nil)
		end)
	end

	local dyleSpeedControlActive = self.character and self.character:FindFirstChild("DyleSpeedControlActive")

	if dyleSpeedControlActive then
		pcall(function()
			dyleSpeedControlActive:Destroy()
		end)
	end

	if self.heartbeatConnection then
		self.heartbeatConnection:Disconnect()
		self.heartbeatConnection = nil
	end

	if self.effectConnection then
		self.effectConnection:Disconnect()
		self.effectConnection = nil
	end

	if self.attackConnection then
		self.attackConnection:Disconnect()
		self.attackConnection = nil
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

	if self.speedValue then
		self.speedValue:Destroy()
		self.speedValue = nil
	end

	if self.humanoid then
		self.humanoid.WalkSpeed = self.baseSpeed
	end

	if self.rageGUI then
		self.rageGUI:Destroy()
		self.rageGUI = nil
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

	if self.animationController then
		self.animationController:cleanup()
		self.animationController = nil
	end
end

return DyleRageBar