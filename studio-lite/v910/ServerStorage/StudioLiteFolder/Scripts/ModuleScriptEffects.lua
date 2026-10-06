local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local parent = script.Parent.Parent
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0)
local setThrottle = parent:WaitForChild("Remotes"):WaitForChild("SetThrottle")
local onServerEventConnection = nil
local v = false
local now = 0
local v2 = 0
local v3 = 1
local baseEngineRPM = parent:GetAttribute("BaseEngineRPM") or 1500
local maxEngineRPM = parent:GetAttribute("MaxEngineRPM") or 5000
local v4 = maxEngineRPM - (maxEngineRPM - baseEngineRPM) / 4
local v5 = {
	{
		RPM = baseEngineRPM,
		MinRPM = 0,
		MaxRPM = baseEngineRPM + 250,
		Volume = 3,
		PitchModification = 1,
		SoundID = "rbxassetid://5257533692"
	},
	{
		RPM = 3000,
		MinRPM = baseEngineRPM + 250,
		MaxRPM = 3500,
		Volume = 1,
		PitchModification = 1,
		SoundID = "rbxassetid://5257534962"
	},
	{
		RPM = 4000,
		MinRPM = 3500,
		MaxRPM = 9000000000,
		Volume = 1,
		PitchModification = 1,
		SoundID = "rbxassetid://5257536258"
	}
}
local v6 = {}
local ModuleScriptEffects = {}
ModuleScriptEffects.__index = ModuleScriptEffects

function ModuleScriptEffects.new(instance, instance2, ignore)
	local object = setmetatable({}, ModuleScriptEffects)
	object.ignore = ignore
	object.base = instance:FindFirstChild("FloorPanel")
	object.attachmentContainer = object.base
	local v7 = {}
	table.insert(v7, instance:FindFirstChild("SuspensionFL"))
	table.insert(v7, instance:FindFirstChild("SuspensionFR"))
	table.insert(v7, instance:FindFirstChild("SuspensionRL"))
	table.insert(v7, instance:FindFirstChild("SuspensionRR"))

	local function createSound(soundId)
		local sound = Instance.new("Sound")
		sound.Volume = 0
		sound.Looped = true
		sound.SoundId = soundId
		sound.Parent = ignore.PrimaryPart

		if not sound.IsLoaded then
			sound.Loaded:Wait()
		end

		return sound
	end

	local function generateAudioInfo(soundId, RPM, minRPM, maxRPM, volume, pitchModification)
		local sound = Instance.new("Sound")
		sound.Volume = 0
		sound.Looped = true
		sound.SoundId = soundId
		sound.Parent = ignore.PrimaryPart

		if not sound.IsLoaded then
			sound.Loaded:Wait()
		end

		return {
			RPM = RPM,
			MinRPM = minRPM,
			MaxRPM = maxRPM,
			Volume = volume,
			PitchModification = pitchModification,
			SoundID = soundId,
			Sound = sound
		}
	end

	local function createSounds(_)
		local effects = ignore:FindFirstChild("Effects")
		local idle, engine, engineHigh

		if effects then
			idle = effects:FindFirstChild("Idle")
			engine = effects:FindFirstChild("Engine")
			engineHigh = effects:FindFirstChild("EngineHigh")
		end

		if not v6[1] then
			if idle then
				local v8 = v6
				local soundId = idle.SoundId
				local v9 = {
					RPM = baseEngineRPM,
					MinRPM = 0,
					MaxRPM = baseEngineRPM + 250,
					Volume = idle.Volume,
					PitchModification = idle.PlaybackSpeed,
					SoundID = soundId,
					Sound = 0
				}
				local sound = Instance.new("Sound")
				sound.Volume = 0
				sound.Looped = true
				sound.SoundId = soundId
				sound.Parent = ignore.PrimaryPart

				if not sound.IsLoaded then
					sound.Loaded:Wait()
				end

				v9.Sound = sound
				v8[1] = v9
			else
				local v8 = v6
				local soundID = v5[1].SoundID
				local v9 = {
					RPM = baseEngineRPM,
					MinRPM = 0,
					MaxRPM = baseEngineRPM + 250,
					Volume = v5[1].Volume,
					PitchModification = v5[1].PitchModification,
					SoundID = soundID,
					Sound = 0
				}
				local sound = Instance.new("Sound")
				sound.Volume = 0
				sound.Looped = true
				sound.SoundId = soundID
				sound.Parent = ignore.PrimaryPart

				if not sound.IsLoaded then
					sound.Loaded:Wait()
				end

				v9.Sound = sound
				v8[1] = v9
			end
		end

		if not v6[2] then
			if engine then
				local v8 = v6
				local soundId = engine.SoundId
				local v9 = {
					RPM = 3000,
					MinRPM = baseEngineRPM + 250,
					MaxRPM = 3500,
					Volume = engine.Volume,
					PitchModification = engine.PlaybackSpeed,
					SoundID = soundId,
					Sound = 0
				}
				local sound = Instance.new("Sound")
				sound.Volume = 0
				sound.Looped = true
				sound.SoundId = soundId
				sound.Parent = ignore.PrimaryPart

				if not sound.IsLoaded then
					sound.Loaded:Wait()
				end

				v9.Sound = sound
				v8[2] = v9
			else
				local v8 = v6
				local soundID = v5[2].SoundID
				local v9 = {
					RPM = 3000,
					MinRPM = baseEngineRPM + 250,
					MaxRPM = 3500,
					Volume = v5[2].Volume,
					PitchModification = v5[2].PitchModification,
					SoundID = soundID,
					Sound = 0
				}
				local sound = Instance.new("Sound")
				sound.Volume = 0
				sound.Looped = true
				sound.SoundId = soundID
				sound.Parent = ignore.PrimaryPart

				if not sound.IsLoaded then
					sound.Loaded:Wait()
				end

				v9.Sound = sound
				v8[2] = v9
			end
		end

		if not v6[3] then
			if engineHigh then
				local v8 = v6
				local soundId = engineHigh.SoundId
				local v9 = {
					RPM = 4000,
					MinRPM = 3500,
					MaxRPM = 9000000000,
					Volume = engineHigh.Volume,
					PitchModification = engineHigh.PlaybackSpeed,
					SoundID = soundId,
					Sound = 0
				}
				local sound = Instance.new("Sound")
				sound.Volume = 0
				sound.Looped = true
				sound.SoundId = soundId
				sound.Parent = ignore.PrimaryPart

				if not sound.IsLoaded then
					sound.Loaded:Wait()
				end

				v9.Sound = sound
				v8[3] = v9
			else
				v6[2].MaxRPM = 9000000000
			end
		end
	end

	local function createWheelData(wheel)
		local attachment = Instance.new("Attachment")
		attachment.Name = "EffectsCenter"
		attachment.Parent = object.attachmentContainer
		local attachment2 = Instance.new("Attachment")
		attachment2.Name = "EffectsR"
		attachment2.Parent = object.attachmentContainer
		local attachment3 = Instance.new("Attachment")
		attachment3.Name = "EffectsL"
		attachment3.Parent = object.attachmentContainer
		local tireTrail = instance2:FindFirstChild("TireTrail")
		local clone

		if tireTrail and tireTrail:IsA("Trail") then
			clone = tireTrail:Clone()
			clone.Parent = object.attachmentContainer
			clone.Attachment0 = attachment3
			clone.Attachment1 = attachment2
		end

		return {
			wheel = wheel,
			attCenter = attachment,
			attRight = attachment2,
			attLeft = attachment3,
			trail = clone,
			lastContact = 0
		}
	end

	object.wheels = {}

	for _, v8 in ipairs(v7) do
		local wheel = v8:FindFirstChild("Wheel")

		if wheel then
			table.insert(object.wheels, (createWheelData(wheel)))
		end
	end

	if #object.wheels == 0 then
		local children = instance:GetChildren()

		for i = 1, #children do
			if children[i].Name == "Wheel" then
				table.insert(object.wheels, (createWheelData(children[i])))
			end
		end
	end

	local vehicleSeat = parent:WaitForChild("Chassis"):WaitForChild("VehicleSeat")
	onServerEventConnection = setThrottle.OnServerEvent:Connect(function(player, p, p2)
		local occupant = vehicleSeat.Occupant

		if occupant and occupant.Parent == player.Character then
			object:SetThrottleEnabled(p, p2)
		end
	end)
	createSounds()
	local engineStart = instance2:FindFirstChild("EngineStart")

	if engineStart then
		object.ignitionMaxVolume = engineStart.Volume
		object.ignitionSound = engineStart:Clone()
		object.ignitionSound.Parent = instance.PrimaryPart
	end

	local engineStop = instance2:FindFirstChild("EngineStop")

	if engineStop then
		object.stopSound = engineStop:Clone()
		object.stopSound.Parent = instance.PrimaryPart
	end

	local accelerate = instance2:FindFirstChild("Accelerate")

	if accelerate then
		object.accelerateSoundVolume = accelerate.Volume
		object.accelerateSoundWeight = 0
		object.accelerateSound = accelerate:Clone()
		object.accelerateSound.Parent = instance.PrimaryPart
	end

	object.engineSoundWeight = 1
	object.igniting = false
	object.throttle = 0
	object.slideSpeed = 0
	object.disableTime = 0
	object.active = false
	return object
end

function ModuleScriptEffects:Enable()
	self.active = true

	if #self.wheels > 0 then
		self.disableTime = 0

		if self.heartbeatConn then
			self.heartbeatConn:Disconnect()
		end

		self.heartbeatConn = RunService.Heartbeat:Connect(function(dt)
			self:OnHeartbeat(dt)
		end)

		if self.ignitionSound and not self.igniting then
			self.igniting = true
			coroutine.wrap(function()
				self.ignitionSound.Volume = self.ignitionMaxVolume
				self.ignitionSound:Play()

				repeat
					RunService.Stepped:Wait()
				until not (self.igniting and self.ignitionSound.IsPlaying)

				self.igniting = false
			end)()
		end

		for i = 1, #v6 do
			v6[i].Sound:Play()
		end
	end
end

function ModuleScriptEffects:DisableInternal()
	self.active = false

	if self.heartbeatConn then
		self.heartbeatConn:Disconnect()
	end

	self.heartbeatConn = nil

	for i = 1, #v6 do
		if v6[i].Sound then
			v6[i].Sound:Stop()
		end
	end

	if self.stopSound then
		self.stopSound:Play()
	end

	if #self.wheels > 0 then
		for _, wheel in ipairs(self.wheels) do
			wheel.trail.Enabled = false
		end
	end

	self.disableTime = 0
end

function ModuleScriptEffects:Disable()
	if self.disableTime == 0 then
		self.disableTime = tick() + 0.5
	end
end

function ModuleScriptEffects:SetThrottleEnabled(p2, value)
	local v7 = value or 1
	v3 = v7

	if RunService:IsClient() then
		if p2 ~= v or tick() - now > 0.2 then
			now = tick()
			setThrottle:FireServer(p2, v7)
			v = p2
		end
	elseif self.active then
		v = p2
	else
		v = false
	end
end

function ModuleScriptEffects:OnHeartbeat(p)
	if self.ignore.Parent == nil then
		return
	end

	if self.disableTime > 0 and tick() > self.disableTime then
		self:DisableInternal()
		return
	end

	for _, wheel in ipairs(self.wheels) do
		local wheel2 = wheel.wheel

		for _, v9 in ipairs(wheel2:GetTouchingParts()) do
			if v9:IsDescendantOf(self.ignore) then
				continue
			end

			wheel.lastContact = tick()
			break
		end

		if tick() - wheel.lastContact <= 0.2 then
			local v9 = wheel2.Size.Y / 2
			local v10 = wheel2.Size.X / 2
			local v11 = wheel2.CFrame * CFrame.new(v10, 0, 0) - Vector3.new(0, v9 - 0.02, 0)
			local v12 = wheel2.CFrame * CFrame.new(-v10, 0, 0) - Vector3.new(0, v9 - 0.02, 0)
			wheel.attRight.WorldPosition = v12.p
			wheel.attLeft.WorldPosition = v11.p
			local v13 = v9 * self.base.CFrame:VectorToObjectSpace(wheel2.RotVelocity).X
			local enabled = math.abs(v13 - self.base.CFrame:VectorToObjectSpace(wheel2.Velocity).Z) / math.abs(v13) >= 0.4
			wheel.trail.Enabled = enabled
		else
			wheel.trail.Enabled = false
		end
	end

	local children = self.ignore.Constraints:GetChildren()
	local primaryPart = self.ignore.PrimaryPart

	if not primaryPart then
		return
	end

	local function getAvgAngularSpeed()
		local count = 0
		local total = 0

		for i = 1, #children do
			if not (primaryPart and children[i]:IsA("CylindricalConstraint")) then
				continue
			end

			local X = math.abs(primaryPart.CFrame:vectorToObjectSpace(children[i].Attachment1.Parent.RotVelocity).X)
			count += 1
			total += X
		end

		return total / count
	end

	if v and self.igniting then
		self.igniting = false

		if self.ignitionSound then
			TweenService:Create(self.ignitionSound, tweenInfo, {
				Volume = 1
			}):Play()
		end
	end

	local engineSoundWeight = 1

	if v then
		if v2 <= baseEngineRPM + 100 then
			local _ = self.accelerateSound.Playing
		end

		if self.accelerateSound.Playing then
			local v8 = baseEngineRPM + 400
			local v9 = baseEngineRPM + 600

			if v2 <= v8 then
				self.accelerateSoundWeight = 1
				engineSoundWeight = 0
			elseif v2 <= v9 then
				local accelerateSoundWeight = (v9 - v2) / (v9 - v8)
				engineSoundWeight = 1 - accelerateSoundWeight
				self.accelerateSoundWeight = accelerateSoundWeight
			else
				self.accelerateSoundWeight = 0

				if self.accelerateSound.Playing then
					self.accelerateSound:Stop()
				end
			end
		end
	end

	self.accelerateSound.Volume = self.accelerateSoundVolume * self.accelerateSoundWeight
	self.engineSoundWeight = engineSoundWeight
	math.abs(self.ignore.Constraints.MotorFL.AngularVelocity)
	local avgAngularSpeed = getAvgAngularSpeed()
	local lookVector = primaryPart.CFrame.LookVector
	local v8 = math.acos((math.clamp(Vector3.new(lookVector.x, 0, lookVector.z):Dot(lookVector), -1, 1)))
	local v9 = primaryPart.Velocity.Y > 0 and math.sin(math.min(v8, 0.7853981633974483) * 2) or 0
	local v10 = v
	local v11 = maxEngineRPM - v4
	local v12 = v10 and baseEngineRPM + (baseEngineRPM * math.min(avgAngularSpeed / 125, 1.5) + v9 * v11) or baseEngineRPM
	local v13 = math.clamp(v4 + v9 * v11, v4, maxEngineRPM)

	if v10 then
		v12 = v12 + v3 * (v13 - v12) or v12
	end

	local v14 = v12 - v2
	local v15 = v9 * 0.1 * 3
	local v16 = v2 + v14 * (v10 and 0.1 + v15 or 0.5) * p
	v2 = math.clamp(v16, math.min(baseEngineRPM, v13), v13)

	for i = 1, #v6 do
		local v17 = v6[i]
		local sound = v17.Sound
		local RPM = v17.RPM
		local minRPM = v17.MinRPM
		local maxRPM = v17.MaxRPM
		local v18

		if minRPM <= v16 and v16 <= maxRPM then
			v18 = 1
		elseif v16 < minRPM then
			v18 = 1 - (minRPM - v16) / (v17.Crossover or 250)
		else
			v18 = 1 - (v16 - maxRPM) / (v17.Crossover or 250)
		end

		local v19 = v18 * self.engineSoundWeight
		local playbackSpeed = v16 / RPM * v17.PitchModification
		sound.Volume = v19 * v17.Volume
		sound.PlaybackSpeed = playbackSpeed
	end
end

return ModuleScriptEffects