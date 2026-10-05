local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local PlatformLeniency = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.PlatformLeniency)
local shaking = script:WaitForChild("Shaking")
local goingUp = script:WaitForChild("Going Up")
local emitWhenGoingDown = script:WaitForChild("EmitWhenGoingDown")
local sounds = script:WaitForChild("Sounds")
local pS2dungeonPILLARshake = sounds:WaitForChild("PS2dungeonPILLARshake")
local pS2dungeonPILLARdrop = sounds:WaitForChild("PS2dungeonPILLARdrop")
local pS2dungeonPILLARrise = sounds:WaitForChild("PS2dungeonPILLARrise")
local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local class = {}
class.__index = class

local function fadeOutParticle(p)
	if p == nil or p.Parent == nil then
		return
	end

	p.Enabled = false
	DebrisModule:AddItem(p, 3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startSound(instance, parent)
	local clone = instance:Clone()
	clone.Parent = parent
	clone:Play()
	return clone
end

local function stopSound(object)
	if object == nil or object.Parent == nil then
		return
	end

	object:Stop()
	DebrisModule:AddItem(object, 0.1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function emitSound(instance, parent)
	local clone = startSound(instance, parent) -- equivalent call inferred; original call site unknown
	DebrisModule:AddItem(clone, clone.TimeLength + 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function trackShake(p, position: Vector3, p2)
	local cam_Shaker = Cam_Shaker(position, p2)
	table.insert(p.Shakes, cam_Shaker)
	return cam_Shaker
end

local function stopAllShakes(state)
	for _, shake in state.Shakes do
		if shake:IsShaking() then
			shake:Stop()
		end
	end

	table.clear(state.Shakes)
end

function class:Reset(flag: boolean?)
	if not self.TouchPart then
		return
	end

	if flag then
		if self.Tween then
			self.Tween:Cancel()
			self.Tween = nil
		end

		stopAllShakes(self)
		local shakingFx = self.ShakingFx

		if shakingFx ~= nil and shakingFx.Parent ~= nil then
			shakingFx.Enabled = false
			DebrisModule:AddItem(shakingFx, 3)
		end

		self.ShakingFx = nil
		local goingUpFx = self.GoingUpFx

		if goingUpFx ~= nil and goingUpFx.Parent ~= nil then
			goingUpFx.Enabled = false
			DebrisModule:AddItem(goingUpFx, 3)
		end

		self.GoingUpFx = nil
		local shakeSound = self.ShakeSound

		if shakeSound ~= nil and shakeSound.Parent ~= nil then
			shakeSound:Stop()
			DebrisModule:AddItem(shakeSound, 0.1)
		end

		self.ShakeSound = nil
	end

	if self.StartCF then
		self.TouchPart.CFrame = self.StartCF
	end

	self.Falling = false
end

function class:Destroy()
	self.Stopped = true
	self:Reset(true)

	if self.Connections then
		for _, connection in self.Connections do
			connection:Disconnect()
		end

		self.Connections = nil
	end

	setmetatable(self, nil)
end

return function(instance, _, ancestor)
	local primaryPart = instance.PrimaryPart or instance:FindFirstChild("TouchPart")

	if not (primaryPart and primaryPart:IsA("BasePart")) then
		return
	end

	local effectPart = instance:FindFirstChild("EffectPart") or instance:FindFirstChild("EffectsPart")

	if not (effectPart and effectPart:IsA("BasePart")) then
		effectPart = nil
	end

	local object = setmetatable({
		Model = instance,
		TouchPart = primaryPart,
		EffectPart = effectPart,
		StartCF = primaryPart.CFrame,
		Falling = false,
		Stopped = false,
		Connections = {},
		Tween = nil,
		Shakes = {},
		ShakingFx = nil,
		GoingUpFx = nil,
		ShakeSound = nil
	}, class)

	local function trigger()
		if object.Falling or object.Stopped then
			return
		end

		object.Falling = true
		local startCF = object.StartCF
		local sustainTime = 2 * PlatformLeniency()
		trackShake(object, primaryPart.Position, {
			FadeInTime = 0.1,
			Frequency = 0.25,
			Amplitude = 0.25,
			SustainTime = sustainTime,
			FadeOutTime = 0.75,
			RotationInfluence = createVector(0.06, 0.06, 0.06),
			PositionInfluence = createVector(1, 1, 1)
		}) -- equivalent call inferred; original call site unknown
		local shakingFx = object.ShakingFx

		if shakingFx ~= nil and shakingFx.Parent ~= nil then
			shakingFx.Enabled = false
			DebrisModule:AddItem(shakingFx, 3)
		end

		if effectPart then
			local clone = shaking:Clone()
			clone.Enabled = true
			clone.Parent = effectPart
			object.ShakingFx = clone
		end

		local shakeSound = object.ShakeSound

		if shakeSound ~= nil and shakeSound.Parent ~= nil then
			shakeSound:Stop()
			DebrisModule:AddItem(shakeSound, 0.1)
		end

		object.ShakeSound = startSound(pS2dungeonPILLARshake, effectPart or primaryPart)
		task.spawn(function()
			local lastTime = os.clock()
			local v5 = -1e999
			local vector2 = createVector(0, 0, 0)
			local v6 = createVector(0, 0, 0)

			while not object.Stopped and os.clock() - lastTime < sustainTime do
				local now = os.clock()
				local v7 = 0.9 * ((now - lastTime) / sustainTime)

				if now - v5 >= 0.09 then
					local v8 = math.random() * 3.141592653589793 * 2
					local v9 = v7 * (0.5 + math.random() * 0.5)
					vector2 = Vector3.new(math.cos(v8) * v9, 0, math.sin(v8) * v9)
					v5 = now
				end

				v6 = v6:Lerp(vector2, 0.18)

				if object.TouchPart then
					object.TouchPart.CFrame = startCF * CFrame.new(v6)
				end

				task.wait()
			end

			if object.Stopped or not object.TouchPart then
				return
			end

			object.TouchPart.CFrame = startCF
			local shakingFx2 = object.ShakingFx

			if shakingFx2 ~= nil and shakingFx2.Parent ~= nil then
				shakingFx2.Enabled = false
				DebrisModule:AddItem(shakingFx2, 3)
			end

			object.ShakingFx = nil
			local shakeSound2 = object.ShakeSound

			if shakeSound2 ~= nil and shakeSound2.Parent ~= nil then
				shakeSound2:Stop()
				DebrisModule:AddItem(shakeSound2, 0.1)
			end

			object.ShakeSound = nil
			emitSound(pS2dungeonPILLARdrop, effectPart or primaryPart) -- equivalent call inferred; original call site unknown
			trackShake(object, startCF.Position, {
				FadeInTime = 0.1,
				Frequency = 0.3,
				Amplitude = 0.5,
				SustainTime = 0.1,
				FadeOutTime = 0.3,
				RotationInfluence = createVector(0.18, 0.18, 0.18),
				PositionInfluence = createVector(1.4, 1.4, 1.4)
			}) -- equivalent call inferred; original call site unknown

			if effectPart then
				for _, emitter in emitWhenGoingDown:GetChildren() do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local clone = emitter:Clone()
					clone.Parent = effectPart
					clone:Emit(clone:GetAttribute("EmitCount") or 1)
					DebrisModule:AddItem(clone, 4)
				end
			end

			object.Tween = TweenService:Create(object.TouchPart, tweenInfo, {
				CFrame = startCF * CFrame.new(0, -80, 0)
			})
			object.Tween:Play()
			task.wait(0.75)

			if object.Stopped or not object.TouchPart then
				return
			end

			task.wait(4.5)

			if object.Stopped or not object.TouchPart then
				return
			end

			local goingUpFx = object.GoingUpFx

			if goingUpFx ~= nil and goingUpFx.Parent ~= nil then
				goingUpFx.Enabled = false
				DebrisModule:AddItem(goingUpFx, 3)
			end

			local clone = goingUp:Clone()
			clone.Enabled = true
			clone.Parent = primaryPart
			object.GoingUpFx = clone
			emitSound(pS2dungeonPILLARrise, primaryPart) -- equivalent call inferred; original call site unknown
			trackShake(object, startCF.Position, {
				FadeInTime = 0.15,
				Frequency = 0.3,
				Amplitude = 0.5,
				SustainTime = 0.5,
				FadeOutTime = 0.4,
				RotationInfluence = createVector(0.15, 0.15, 0.15),
				PositionInfluence = createVector(2, 2, 2)
			}) -- equivalent call inferred; original call site unknown
			object.Tween = TweenService:Create(object.TouchPart, tweenInfo2, {
				CFrame = startCF
			})
			object.Tween:Play()
			task.wait(0.5)

			if object.Stopped or not object.TouchPart then
				return
			end

			local goingUpFx2 = object.GoingUpFx

			if goingUpFx2 ~= nil and goingUpFx2.Parent ~= nil then
				goingUpFx2.Enabled = false
				DebrisModule:AddItem(goingUpFx2, 3)
			end

			object.GoingUpFx = nil
			object.Tween = nil
			object.Falling = false
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function bindTouch(part)
		table.insert(object.Connections, part.Touched:Connect(function(otherPart)
			if not (otherPart and ancestor and otherPart:IsDescendantOf(ancestor)) then
				return
			end

			trigger()
		end))
	end

	local v = primaryPart
	table.insert(object.Connections, v.Touched:Connect(function(otherPart)
		if not (otherPart and ancestor and otherPart:IsDescendantOf(ancestor)) then
			return
		end

		trigger()
	end))
	table.insert(object.Connections, instance.ChildAdded:Connect(function(part)
		if part.Name ~= primaryPart.Name or not part:IsA("BasePart") then
			return
		end

		primaryPart = part
		object.TouchPart = part
		object.StartCF = part.CFrame
		object.Falling = false
		bindTouch(part) -- equivalent call inferred; original call site unknown
	end))
	return object
end