local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local IndependenceDayConfig = require(script.Parent.IndependenceDayConfig)
local FireworksController = {}
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local childrenByChildName = {}

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function easeOutQuad(p: number)
	return 1 - (1 - p) ^ 2
end

local function quadBezier(vector2: Vector3, vector3: Vector3, vector4: Vector3, p: number)
	return vector2:Lerp(vector3, p):Lerp(vector3:Lerp(vector4, p), p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cubicBezier(vector2: Vector3, vector3: Vector3, vector4: Vector3, vector5: Vector3, p: number)
	return vector2:Lerp(vector3, p):Lerp(vector3:Lerp(vector4, p), p):Lerp(
		vector3:Lerp(vector4, p):Lerp(vector4:Lerp(vector5, p), p),
		p
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sidewaysOffset(p: number, p2: number, p3: number)
	local v5 = p + math.random() * (p2 - p)
	return (Vector3.new(math.cos(p3) * v5, 0, math.sin(p3) * v5))
end

local function orientToDirection(position: Vector3, vector2: Vector3, cFrame: CFrame)
	if vector2.Magnitude < 0.001 then
		return CFrame.new(position) * (cFrame - cFrame.Position)
	end

	local unit = vector2.Unit
	local rightVector = (not (math.abs((unit:Dot(createVector(0, 1, 0)))) > 0.98) and createVector(0, 1, 0) or cFrame.RightVector):Cross(unit)

	if rightVector.Magnitude < 0.0001 then
		rightVector = cFrame.RightVector
	end

	return CFrame.fromMatrix(position, rightVector.Unit, unit)
end

local function setFireEnabled(instance, enabled: boolean)
	local fireAttach = instance:FindFirstChild("FireAttach")

	if not fireAttach then
		warn("[FireworksController - missing FireAttach on]", instance:GetFullName())
		return
	end

	for _, child in fireAttach:GetChildren() do
		if child:IsA("Fire") or child:IsA("ParticleEmitter") then
			child.Enabled = enabled
		end
	end
end

local function burstVfx(part)
	local explosion = part:FindFirstChild("Explosion")

	if not explosion then
		warn("[FireworksController - missing Explosion attachment on]", part:GetFullName())
		return
	end

	for _, emitter in explosion:GetChildren() do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or IndependenceDayConfig.FIREWORK_DEFAULT_EMIT_COUNT)
		end
	end
end

local function getSfxSubfolder(childName: string)
	local v5 = childrenByChildName[childName]

	if v5 and v5.Parent then
		return v5
	end

	local adminAbuse = ReplicatedStorage:FindFirstChild("AdminAbuse")
	local independenceDay = adminAbuse and adminAbuse:FindFirstChild("IndependenceDay")
	local SFX = independenceDay and independenceDay:FindFirstChild("SFX")
	local child = SFX and SFX:FindFirstChild(childName)

	if child then
		childrenByChildName[childName] = child
		return child
	end

	warn("[FireworksController - missing ReplicatedStorage.AdminAbuse.IndependenceDay.SFX." .. childName .. "]")
	return nil
end

local function playRandomSfxAt(instance, position: Vector3)
	if not instance then
		return
	end

	local sounds = {}

	for _, sound in instance:GetChildren() do
		if sound:IsA("Sound") then
			table.insert(sounds, sound)
		end
	end

	if #sounds == 0 then
		warn("[FireworksController - no Sound children in]", instance:GetFullName())
		return
	end

	local v5 = sounds[math.random(1, #sounds)]
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CFrame = CFrame.new(position)
	part.Parent = workspace
	local clone = v5:Clone()
	clone.Parent = part
	clone:Play()
	clone.Ended:Once(function()
		pcall(function()
			part:Destroy()
		end)
	end)
	Debris:AddItem(part, 12)
end

local function getBasicFolder(instance)
	local scriptables = instance:FindFirstChild("Scriptables")
	local fireworks = scriptables and scriptables:FindFirstChild("Fireworks")
	local basic = fireworks and fireworks:FindFirstChild("Basic")

	if basic then
		return basic
	end

	warn("[FireworksController - Scriptables/Fireworks/Basic not found]")
	return nil
end

local function getSparklesEmitter(instance)
	local explosion = instance:FindFirstChild("Explosion")
	local sparkles = explosion and explosion:FindFirstChild("Sparkles")

	if sparkles and sparkles:IsA("ParticleEmitter") then
		return sparkles
	end

	return nil
end

local function getSmokeEmitter(instance)
	local explosion = instance:FindFirstChild("Explosion")
	local smokeParticle = explosion and explosion:FindFirstChild("SmokeParticle")

	if smokeParticle and smokeParticle:IsA("ParticleEmitter") then
		return smokeParticle
	end

	return nil
end

local function getRigs(basic)
	local parts = {}

	for _, part in basic:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		if not v2[part] then
			v2[part] = part.CFrame
		end

		local explosion = part:FindFirstChild("Explosion")
		local sparkles = explosion and explosion:FindFirstChild("Sparkles")

		if not (sparkles and sparkles:IsA("ParticleEmitter")) then
			sparkles = nil
		end

		local explosion2 = part:FindFirstChild("Explosion")
		local smokeParticle = explosion2 and explosion2:FindFirstChild("SmokeParticle")

		if not (smokeParticle and smokeParticle:IsA("ParticleEmitter")) then
			smokeParticle = nil
		end

		if sparkles and not v3[sparkles] then
			v3[sparkles] = sparkles.Color
		end

		if smokeParticle and not v4[smokeParticle] then
			v4[smokeParticle] = smokeParticle.Color
		end

		table.insert(parts, part)
	end

	return parts
end

local function applyFireworkColor(part, color: Color3?)
	if not color then
		return nil
	end

	local explosion = part:FindFirstChild("Explosion")
	local sparkles = explosion and explosion:FindFirstChild("Sparkles")

	if not (sparkles and sparkles:IsA("ParticleEmitter")) then
		sparkles = nil
	end

	if not sparkles then
		warn("[FireworksController - missing Explosion.Sparkles on]", part:GetFullName())
		return nil
	end

	if not v3[sparkles] then
		v3[sparkles] = sparkles.Color
	end

	sparkles.Color = ColorSequence.new(color)
	return sparkles
end

local function applySmokeColor(part, color: Color3?)
	if not color then
		return nil
	end

	local explosion = part:FindFirstChild("Explosion")
	local smokeParticle = explosion and explosion:FindFirstChild("SmokeParticle")

	if not (smokeParticle and smokeParticle:IsA("ParticleEmitter")) then
		smokeParticle = nil
	end

	if not smokeParticle then
		warn("[FireworksController - missing Explosion.SmokeParticles on]", part:GetFullName())
		return nil
	end

	if not v4[smokeParticle] then
		v4[smokeParticle] = smokeParticle.Color
	end

	smokeParticle.Color = ColorSequence.new(color)
	return smokeParticle
end

local function getOrCreateDebrisFolder(instance)
	local scriptables = instance:FindFirstChild("Scriptables")
	local debris = scriptables:FindFirstChild("Debris")

	if debris and debris:IsA("Folder") then
		return debris
	end

	local folder = Instance.new("Folder")
	folder.Name = "Debris"
	folder.Parent = scriptables
	return folder
end

function FireworksController:LaunchFirework(p)
	if not (self and self:IsA("BasePart")) then
		warn("[FireworksController.LaunchFirework - Incorrect part arg]")
		return
	end

	if v[self] then
		return
	end

	v[self] = true
	local cFrame = self.CFrame
	local position = cFrame.Position
	setFireEnabled(self, true)
	playRandomSfxAt(getSfxSubfolder("LaunchSounds"), position)
	local v5 = math.random(IndependenceDayConfig.MIN_FIREWORK_HEIGHT, IndependenceDayConfig.MAX_FIREWORK_HEIGHT)
	local v6 = math.random() * 3.141592653589793 * 2
	local FIREWORK_CURVE_ANGLE_JITTER_DEG = math.rad(IndependenceDayConfig.FIREWORK_CURVE_ANGLE_JITTER_DEG)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function jitteredAngle()
		return v6 + (math.random() * 2 - 1) * FIREWORK_CURVE_ANGLE_JITTER_DEG
	end

	local v7 = position + Vector3.new(0, v5 * (0.25 + math.random() * 0.15), 0)
	local FIREWORK_CURVE1_MIN_OFFSET = IndependenceDayConfig.FIREWORK_CURVE1_MIN_OFFSET
	local FIREWORK_CURVE1_MAX_OFFSET = IndependenceDayConfig.FIREWORK_CURVE1_MAX_OFFSET
	local v8 = jitteredAngle() -- equivalent call inferred; original call site unknown
	local v9 = v7 + sidewaysOffset(FIREWORK_CURVE1_MIN_OFFSET, FIREWORK_CURVE1_MAX_OFFSET, v8)
	local v10 = position + Vector3.new(0, v5 * (0.6 + math.random() * 0.2), 0)
	local FIREWORK_CURVE2_MIN_OFFSET = IndependenceDayConfig.FIREWORK_CURVE2_MIN_OFFSET
	local FIREWORK_CURVE2_MAX_OFFSET = IndependenceDayConfig.FIREWORK_CURVE2_MAX_OFFSET
	local v11 = jitteredAngle() -- equivalent call inferred; original call site unknown
	local v12 = v10 + sidewaysOffset(FIREWORK_CURVE2_MIN_OFFSET, FIREWORK_CURVE2_MAX_OFFSET, v11)
	local v13 = position + Vector3.new(0, v5, 0)
	local FIREWORK_END_DRIFT_MIN = IndependenceDayConfig.FIREWORK_END_DRIFT_MIN
	local FIREWORK_END_DRIFT_MAX = IndependenceDayConfig.FIREWORK_END_DRIFT_MAX
	local v14 = jitteredAngle() -- equivalent call inferred; original call site unknown
	local v15 = v13 + sidewaysOffset(FIREWORK_END_DRIFT_MIN, FIREWORK_END_DRIFT_MAX, v14)
	local FIREWORK_ASCEND_DURATION = IndependenceDayConfig.FIREWORK_ASCEND_DURATION
	local total = 0
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		total += dt
		local v16 = math.clamp(total / FIREWORK_ASCEND_DURATION, 0, 1)
		local v21 = easeOutQuad(v16)
		local vector2 = cubicBezier(position, v9, v12, v15, v21) -- equivalent call inferred; original call site unknown
		local v27 = easeOutQuad(math.clamp(v16 + 0.02, 0, 1))
		local vector3 = cubicBezier(position, v9, v12, v15, v27) -- equivalent call inferred; original call site unknown
		self.CFrame = orientToDirection(vector2, vector3 - vector2, cFrame)

		if v16 < 1 then
			return
		end

		heartbeatConnection:Disconnect()
		self.Transparency = 1
		setFireEnabled(self, false)
		local v28 = applyFireworkColor(self, p and p.color)
		local v29 = applySmokeColor(self, p and p.color)
		burstVfx(self)
		playRandomSfxAt(getSfxSubfolder("PopSounds"), vector2)
		task.delay(IndependenceDayConfig.FIREWORK_RESET_DELAY, function()
			v[self] = nil

			if p and p.isClone then
				v2[self] = nil

				if v28 then
					v3[v28] = nil
				end

				if v29 then
					v4[v29] = nil
				end

				self:Destroy()
			else
				self.CFrame = cFrame
				self.Transparency = 0

				if v28 then
					v28.Color = v3[v28]
				end

				if v29 then
					v29.Color = v4[v29]
				end
			end
		end)
	end)
end

function FireworksController.FireRandom(instance)
	if not instance then
		warn("[FireworksController.FireRandom - Missing mapClone arg]")
		return
	end

	local scriptables = instance:FindFirstChild("Scriptables")
	local fireworks = scriptables and scriptables:FindFirstChild("Fireworks")
	local basic = fireworks and fireworks:FindFirstChild("Basic")

	if not basic then
		warn("[FireworksController - Scriptables/Fireworks/Basic not found]")
		basic = nil
	end

	if not basic then
		return
	end

	local v5 = {}

	for _, v6 in getRigs(basic) do
		if not v[v6] then
			table.insert(v5, v6)
		end
	end

	if #v5 == 0 then
		warn("[FireworksController.FireRandom - No available firework rigs]")
	else
		FireworksController.LaunchFirework(v5[math.random(1, #v5)])
	end
end

function FireworksController.FireMany(instance, p: number, list)
	if not instance then
		warn("[FireworksController.FireMany - Missing mapClone arg]")
		return
	end

	local scriptables = instance:FindFirstChild("Scriptables")
	local fireworks = scriptables and scriptables:FindFirstChild("Fireworks")
	local basic = fireworks and fireworks:FindFirstChild("Basic")

	if not basic then
		warn("[FireworksController - Scriptables/Fireworks/Basic not found]")
		basic = nil
	end

	if not basic then
		return
	end

	local rigs = getRigs(basic)

	if #rigs == 0 then
		warn("[FireworksController.FireMany - No firework rigs placed]")
		return
	end

	local v5

	if list == nil then
		v5 = false
	else
		v5 = #list > 0
	end

	for _ = 1, p do
		local color

		if v5 then
			local v7 = list[math.random(1, #list)]
			color = IndependenceDayConfig.FIREWORK_COLORS[v7]
		end

		local rigs2 = {}

		for _, rig in rigs do
			if not v[rig] then
				table.insert(rigs2, rig)
			end
		end

		if #rigs2 > 0 then
			FireworksController.LaunchFirework(rigs2[math.random(1, #rigs2)], {
				color = color
			})
		else
			local rig = rigs[math.random(1, #rigs)]
			local clone = rig:Clone()
			clone.CFrame = v2[rig] or rig.CFrame
			clone.Transparency = 0
			setFireEnabled(clone, false)
			local explosion = rig:FindFirstChild("Explosion")
			local sparkles = explosion and explosion:FindFirstChild("Sparkles")

			if not (sparkles and sparkles:IsA("ParticleEmitter")) then
				sparkles = nil
			end

			local explosion2 = clone:FindFirstChild("Explosion")
			local sparkles2 = explosion2 and explosion2:FindFirstChild("Sparkles")

			if not (sparkles2 and sparkles2:IsA("ParticleEmitter")) then
				sparkles2 = nil
			end

			if sparkles and sparkles2 and v3[sparkles] then
				sparkles2.Color = v3[sparkles]
			end

			local explosion3 = rig:FindFirstChild("Explosion")
			local smokeParticle = explosion3 and explosion3:FindFirstChild("SmokeParticle")

			if not (smokeParticle and smokeParticle:IsA("ParticleEmitter")) then
				smokeParticle = nil
			end

			local explosion4 = clone:FindFirstChild("Explosion")
			local smokeParticle2 = explosion4 and explosion4:FindFirstChild("SmokeParticle")

			if not (smokeParticle2 and smokeParticle2:IsA("ParticleEmitter")) then
				smokeParticle2 = nil
			end

			if smokeParticle and smokeParticle2 and v4[smokeParticle] then
				smokeParticle2.Color = v4[smokeParticle]
			end

			local scriptables2 = instance:FindFirstChild("Scriptables")
			local parent = scriptables2:FindFirstChild("Debris")

			if not (parent and parent:IsA("Folder")) then
				parent = Instance.new("Folder")
				parent.Name = "Debris"
				parent.Parent = scriptables2
			end

			clone.Parent = parent
			v2[clone] = clone.CFrame
			FireworksController.LaunchFirework(clone, {
				isClone = true,
				color = color
			})
		end
	end
end

return FireworksController