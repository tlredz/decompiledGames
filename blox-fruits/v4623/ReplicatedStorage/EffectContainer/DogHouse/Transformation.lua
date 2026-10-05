local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local Util = require(game.ReplicatedStorage.Util)
local Effect = require(game.ReplicatedStorage.Effect)
local FX = require(game.ReplicatedStorage.FX)
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local transformation = FX:WaitForChild("DogHouse").Transformation
local start = transformation.Start
local redExplosion = transformation.RedExplosion

local function getDogHouseParts(part)
	local parts = {}

	if part:IsA("BasePart") then
		table.insert(parts, part)
	end

	for _, part2 in ipairs(part:GetDescendants()) do
		if part2:IsA("BasePart") then
			table.insert(parts, part2)
		end
	end

	return parts
end

local function muteBackgroundMusic(duration: number, flag: boolean?)
	local volumesBySound = {}

	local function tryMute(sound)
		if not sound:IsA("Sound") or not sound.Playing or sound.Volume <= 0 or not sound.Looped and sound.TimeLength < 8 then
			return
		end

		volumesBySound[sound] = sound.Volume
		TweenService:Create(sound, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Volume = 0
		}):Play()
	end

	for _, descendant in ipairs(SoundService:GetDescendants()) do
		tryMute(descendant)
	end

	for _, descendant in ipairs(workspace:GetDescendants()) do
		tryMute(descendant)
	end

	if flag then
		return
	end

	task.delay(duration, function()
		for k, volume in pairs(volumesBySound) do
			if k and k.Parent then
				TweenService:Create(k, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Volume = volume
				}):Play()
			end
		end
	end)
end

local function grayscaleScreen(duration: number)
	local v = Lighting:FindFirstChild("IndraPhase2Grayscale")

	if not v then
		v = Instance.new("ColorCorrectionEffect")
		v.Name = "IndraPhase2Grayscale"
		v.Parent = Lighting
	end

	v.Enabled = true
	v.Saturation = 0
	v.Contrast = 0
	v.Brightness = 0
	v.TintColor = Color3.new(1, 1, 1)
	TweenService:Create(v, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Saturation = -1,
		Contrast = 0.18,
		Brightness = -0.04
	}):Play()
	task.delay(duration, function()
		if not (v and v.Parent) then
			return
		end

		local tween = TweenService:Create(v, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Saturation = 0,
			Contrast = 0,
			Brightness = 0
		})
		tween:Play()
		tween.Completed:Once(function()
			if v and v.Parent then
				Debris:AddItem(v, 0.1)
			end
		end)
	end)
end

local function shakeDogHouse(dogHouseParts, shakeDuration: number, shakeStrength: number)
	local cFrames = {}

	for _, v in ipairs(dogHouseParts) do
		cFrames[v] = v.CFrame
	end

	local lastTime = os.clock()
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v = os.clock() - lastTime

		if shakeDuration <= v then
			renderSteppedConnection:Disconnect()

			for k, cFrame in pairs(cFrames) do
				if k and k.Parent then
					k.CFrame = cFrame
				end
			end
		else
			local v3 = shakeStrength * (1 + v / shakeDuration * 1.75)
			local vector2 = Vector3.new(
				(math.random() - 0.5) * v3,
				(math.random() - 0.5) * v3 * 0.6,
				(math.random() - 0.5) * v3
			)
			local cframe = CFrame.Angles(
				math.rad((math.random() - 0.5) * v3 * 2),
				math.rad((math.random() - 0.5) * v3 * 2),
				(math.rad((math.random() - 0.5) * v3 * 2))
			)

			for k, v4 in pairs(cFrames) do
				if k and k.Parent then
					k.CFrame = v4 * CFrame.new(vector2) * cframe
				end
			end
		end
	end)
end

local function explodeDogHouse(dogHouseParts, position: Vector3)
	for _, v in ipairs(dogHouseParts) do
		if not (v and v.Parent) then
			continue
		end

		Util.Sound:Play("TigerFt_FSkill_Explode_03", position)
		local clone = v:Clone()
		clone.Anchored = false
		clone.CanCollide = false
		clone.CanTouch = false
		clone.CanQuery = false
		clone.Massless = true
		clone.CFrame = v.CFrame
		clone.Parent = _WorldOrigin
		v.LocalTransparencyModifier = 1
		local vector2 = clone.Position - position

		if vector2.Magnitude < 2 then
			vector2 = Vector3.new(math.random() - 0.5, math.random() * 0.8 + 0.4, math.random() - 0.5)
		end

		local unit = (vector2.Unit + Vector3.new(
			(math.random() - 0.5) * 0.8,
			math.random() * 0.65,
			(math.random() - 0.5) * 0.8
		)).Unit
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(1000000000, 1000000000, 1000000000)
		bodyVelocity.Velocity = unit * math.random(35, 95) + Vector3.new(0, math.random(35, 85), 0)
		bodyVelocity.Parent = clone
		Debris:AddItem(bodyVelocity, 0.18)
		local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
		bodyAngularVelocity.MaxTorque = createVector(1000000000, 1000000000, 1000000000)
		bodyAngularVelocity.AngularVelocity = Vector3.new(
			math.random(-12, 12),
			math.random(-12, 12),
			math.random(-12, 12)
		)
		bodyAngularVelocity.Parent = clone
		Debris:AddItem(bodyAngularVelocity, 0.35)
		task.delay(0.45 + math.random() * 0.25, function()
			if clone and clone.Parent then
				TweenService:Create(clone, TweenInfo.new(0.45), {
					Size = createVector(0, 0, 0)
				}):Play()
			end
		end)
		Debris:AddItem(clone, 1.35)
	end
end

local function emitAll(folder, value: number?)
	for _, effect in ipairs(folder:GetDescendants()) do
		if effect:IsA("ParticleEmitter") then
			effect:Emit(effect:GetAttribute("EmitCount") or value or 25)
		elseif effect:IsA("Beam") or effect:IsA("Trail") then
			effect.Enabled = true
			local v = effect
			task.delay(0.35, function()
				if v and v.Parent then
					v.Enabled = false
				end
			end)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setEmitterSize(auraCircle, p: number)
	auraCircle.Size = NumberSequence.new(p)
end

local function setNamedParticles(folder, p: string, enabled: boolean)
	for _, emitter in ipairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") and emitter.Name == p then
			emitter.Enabled = enabled
		end
	end
end

local function setReadyParticles(folder, enabled: boolean)
	for _, emitter in ipairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") and (emitter.Name == "Flare" or emitter.Name == "Lines") then
			emitter.Enabled = enabled
		end
	end
end

local function playRedExplosion(humanoidRootPart)
	local clone = redExplosion:Clone()
	clone.CFrame = humanoidRootPart.CFrame
	clone.Parent = _WorldOrigin

	for _, emitter in ipairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit()
		end
	end

	Debris:AddItem(clone, 3)
end

local function waitForChargeReady(folder)
	while folder.Parent and not folder:GetAttribute("ReadyToExplode") do
		folder:GetAttributeChangedSignal("ReadyToExplode"):Wait()
	end
end

local function explosionLightingFlash()
	local v = Lighting:FindFirstChild("IndraPhase2Grayscale")

	if not v then
		v = Instance.new("ColorCorrectionEffect")
		v.Name = "IndraPhase2Grayscale"
		v.Parent = Lighting
	end

	v.Enabled = true
	v.Saturation = -0.25
	v.Contrast = 0.45
	v.Brightness = 0.25
	v.TintColor = Color3.fromRGB(255, 30, 30)
	task.wait(0.045)

	if not (v and v.Parent) then
		return
	end

	v.Saturation = 0
	v.Contrast = 0.65
	v.Brightness = 1
	v.TintColor = Color3.fromRGB(255, 255, 255)
	task.wait(0.04)

	if v and v.Parent then
		v.Enabled = false
		v:Destroy()
	end
end

local function Charge(p: number, humanoidRootPart, folder)
	if p == 1 then
		local clone = start:Clone()
		clone.Parent = _WorldOrigin
		clone.CFrame = humanoidRootPart.CFrame
		clone.Anchored = false
		clone.CanCollide = false
		clone.CanTouch = false
		clone.CanQuery = false
		clone:SetAttribute("ReadyToExplode", false)
		local weld = Instance.new("Weld")
		weld.Part0 = humanoidRootPart
		weld.Part1 = clone
		weld.Parent = clone
		local charge = clone:FindFirstChild("Charge", true)
		local done = clone:FindFirstChild("Done", true)

		if not charge then
			return clone
		end

		setNamedParticles(charge, "First", true)
		setNamedParticles(clone, "First", true)
		Util.Sound:Play("HydraHiss2", humanoidRootPart)
		task.spawn(function()
			task.wait(0.1)

			if not clone.Parent then
				return
			end

			local auraCircle = charge:FindFirstChild("AuraCircle", true)

			if auraCircle and auraCircle:IsA("ParticleEmitter") then
				auraCircle.Enabled = true
				local v = { 50, 25, 10 }

				for i, v2 in ipairs(v) do
					if not clone.Parent then
						return
					end

					setEmitterSize(auraCircle, v2) -- equivalent call inferred; original call site unknown
					auraCircle:Emit(1)

					if i < #v then
						task.wait(0.5)
					end
				end
			end

			setNamedParticles(charge, "First", false)
			setNamedParticles(clone, "First", false)

			if done then
				setReadyParticles(done, true)
			end

			task.wait(1)

			if clone.Parent then
				clone:SetAttribute("ReadyToExplode", true)
			end
		end)
		return clone
	elseif p == 3 and folder and folder.Parent then
		for _, emitter in ipairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		Debris:AddItem(folder, 1.5)
	end
end

return function(player)
	local character = player.Character

	if not character then
		return
	end

	local accessory = player.Accessory or character:FindFirstChild("Accessory")

	if not accessory then
		return
	end

	local dogHouse = accessory:FindFirstChild("DogHouse")
	local accessoryRoot = accessory:FindFirstChild("Root") or character:FindFirstChild("HumanoidRootPart")

	if not dogHouse then
		return
	end

	local dogHouseParts = getDogHouseParts(dogHouse)

	if #dogHouseParts <= 0 then
		return
	end

	local duration = player.Duration or 2.4
	local shakeDuration = player.ShakeDuration or 1.65
	local shakeStrength = player.ShakeStrength or 0.35
	local explosionDelay = player.ExplosionDelay or 1.65
	local _ = player.KeepMusicMuted
	local position

	if accessoryRoot and accessoryRoot:IsA("BasePart") then
		position = accessoryRoot.Position
	else
		position = dogHouseParts[1].Position
	end

	grayscaleScreen(duration + 0.5)
	pcall(function()
		Effect.new("ShakeCam"):play({
			7,
			30,
			0.15,
			duration
		})
	end)
	local folder = Charge(1, player.Character.HumanoidRootPart)
	shakeDogHouse(dogHouseParts, shakeDuration, shakeStrength)

	if folder then
		waitForChargeReady(folder)
	else
		task.wait(explosionDelay)
	end

	pcall(function()
		Effect.new("ShakeCam"):play({
			10,
			45,
			0.1,
			1.1
		})
	end)
	task.spawn(explosionLightingFlash)
	explodeDogHouse(dogHouseParts, position)
	playRedExplosion(player.Character.HumanoidRootPart)
	local _ = player.Character.HumanoidRootPart

	if folder and folder.Parent then
		for _, emitter in ipairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		Debris:AddItem(folder, 1.5)
	end
end