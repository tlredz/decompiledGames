local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local July14thAdminAbuseConfig = require(script.Parent.July14thAdminAbuseConfig)
local FireworksController = {}
local v = {}
local v2 = {}
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
	local v3 = p + math.random() * (p2 - p)
	return (Vector3.new(math.cos(p3) * v3, 0, math.sin(p3) * v3))
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
			emitter:Emit(emitter:GetAttribute("EmitCount") or July14thAdminAbuseConfig.FIREWORK_DEFAULT_EMIT_COUNT)
		end
	end
end

local function getSfxSubfolder(childName: string)
	local v3 = childrenByChildName[childName]

	if v3 and v3.Parent then
		return v3
	end

	local adminAbuse = ReplicatedStorage:FindFirstChild("AdminAbuse")
	local july14thAdminAbuse = adminAbuse and adminAbuse:FindFirstChild("July14thAdminAbuse")
	local SFX = july14thAdminAbuse and july14thAdminAbuse:FindFirstChild("SFX")
	local child = SFX and SFX:FindFirstChild(childName)

	if child then
		childrenByChildName[childName] = child
		return child
	end

	warn("[FireworksController - missing ReplicatedStorage.AdminAbuse.July14thAdminAbuse.SFX." .. childName .. "]")
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

	local v3 = sounds[math.random(1, #sounds)]
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CFrame = CFrame.new(position)
	part.Parent = workspace
	local clone = v3:Clone()
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

		table.insert(parts, part)
	end

	return parts
end

local function pickRandomFireworkColor(FIREWORK_COLOR_ORDER)
	if not (FIREWORK_COLOR_ORDER and #FIREWORK_COLOR_ORDER > 0 and FIREWORK_COLOR_ORDER) then
		FIREWORK_COLOR_ORDER = July14thAdminAbuseConfig.FIREWORK_COLOR_ORDER
	end

	local v3 = FIREWORK_COLOR_ORDER[math.random(1, #FIREWORK_COLOR_ORDER)]
	return July14thAdminAbuseConfig.FIREWORK_COLORS[v3]
end

local function applyFireworkColor(instance, color: Color3)
	local explosion = instance:FindFirstChild("Explosion")
	local sparkles = explosion and explosion:FindFirstChild("Sparkles")

	if not (sparkles and sparkles:IsA("ParticleEmitter")) then
		sparkles = nil
	end

	if sparkles then
		sparkles.Color = ColorSequence.new(color)
		return sparkles
	end

	warn("[FireworksController - missing Explosion.Sparkles on]", instance:GetFullName())
	return nil
end

local function applySmokeColor(instance, color: Color3)
	local explosion = instance:FindFirstChild("Explosion")
	local smokeParticle = explosion and explosion:FindFirstChild("SmokeParticle")

	if not (smokeParticle and smokeParticle:IsA("ParticleEmitter")) then
		smokeParticle = nil
	end

	if smokeParticle then
		smokeParticle.Color = ColorSequence.new(color)
		return smokeParticle
	end

	warn("[FireworksController - missing Explosion.SmokeParticles on]", instance:GetFullName())
	return nil
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
	local v3 = math.random(July14thAdminAbuseConfig.MIN_FIREWORK_HEIGHT, July14thAdminAbuseConfig.MAX_FIREWORK_HEIGHT)
	local v4 = math.random() * 3.141592653589793 * 2
	local FIREWORK_CURVE_ANGLE_JITTER_DEG = math.rad(July14thAdminAbuseConfig.FIREWORK_CURVE_ANGLE_JITTER_DEG)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function jitteredAngle()
		return v4 + (math.random() * 2 - 1) * FIREWORK_CURVE_ANGLE_JITTER_DEG
	end

	local v5 = position + Vector3.new(0, v3 * (0.25 + math.random() * 0.15), 0)
	local FIREWORK_CURVE1_MIN_OFFSET = July14thAdminAbuseConfig.FIREWORK_CURVE1_MIN_OFFSET
	local FIREWORK_CURVE1_MAX_OFFSET = July14thAdminAbuseConfig.FIREWORK_CURVE1_MAX_OFFSET
	local v6 = jitteredAngle() -- equivalent call inferred; original call site unknown
	local v7 = v5 + sidewaysOffset(FIREWORK_CURVE1_MIN_OFFSET, FIREWORK_CURVE1_MAX_OFFSET, v6)
	local v8 = position + Vector3.new(0, v3 * (0.6 + math.random() * 0.2), 0)
	local FIREWORK_CURVE2_MIN_OFFSET = July14thAdminAbuseConfig.FIREWORK_CURVE2_MIN_OFFSET
	local FIREWORK_CURVE2_MAX_OFFSET = July14thAdminAbuseConfig.FIREWORK_CURVE2_MAX_OFFSET
	local v9 = jitteredAngle() -- equivalent call inferred; original call site unknown
	local v10 = v8 + sidewaysOffset(FIREWORK_CURVE2_MIN_OFFSET, FIREWORK_CURVE2_MAX_OFFSET, v9)
	local v11 = position + Vector3.new(0, v3, 0)
	local FIREWORK_END_DRIFT_MIN = July14thAdminAbuseConfig.FIREWORK_END_DRIFT_MIN
	local FIREWORK_END_DRIFT_MAX = July14thAdminAbuseConfig.FIREWORK_END_DRIFT_MAX
	local v12 = jitteredAngle() -- equivalent call inferred; original call site unknown
	local v13 = v11 + sidewaysOffset(FIREWORK_END_DRIFT_MIN, FIREWORK_END_DRIFT_MAX, v12)
	local FIREWORK_ASCEND_DURATION = July14thAdminAbuseConfig.FIREWORK_ASCEND_DURATION
	local total = 0
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		total += dt
		local v14 = math.clamp(total / FIREWORK_ASCEND_DURATION, 0, 1)
		local v19 = easeOutQuad(v14)
		local vector2 = cubicBezier(position, v7, v10, v13, v19) -- equivalent call inferred; original call site unknown
		local v25 = easeOutQuad(math.clamp(v14 + 0.02, 0, 1))
		local vector3 = cubicBezier(position, v7, v10, v13, v25) -- equivalent call inferred; original call site unknown
		self.CFrame = orientToDirection(vector2, vector3 - vector2, cFrame)

		if v14 < 1 then
			return
		end

		heartbeatConnection:Disconnect()
		self.Transparency = 1
		setFireEnabled(self, false)
		local color = p and p.color

		if not color then
			local FIREWORK_COLOR_ORDER = July14thAdminAbuseConfig.FIREWORK_COLOR_ORDER
			local v26 = FIREWORK_COLOR_ORDER[math.random(1, #FIREWORK_COLOR_ORDER)]
			color = July14thAdminAbuseConfig.FIREWORK_COLORS[v26]
		end

		local v26 = self
		local explosion = v26:FindFirstChild("Explosion")
		local sparkles = explosion and explosion:FindFirstChild("Sparkles")

		if not (sparkles and sparkles:IsA("ParticleEmitter")) then
			sparkles = nil
		end

		if sparkles then
			sparkles.Color = ColorSequence.new(color)
		else
			warn("[FireworksController - missing Explosion.Sparkles on]", v26:GetFullName())
		end

		local v27 = self
		local explosion2 = v27:FindFirstChild("Explosion")
		local smokeParticle = explosion2 and explosion2:FindFirstChild("SmokeParticle")

		if not (smokeParticle and smokeParticle:IsA("ParticleEmitter")) then
			smokeParticle = nil
		end

		if smokeParticle then
			smokeParticle.Color = ColorSequence.new(color)
		else
			warn("[FireworksController - missing Explosion.SmokeParticles on]", v27:GetFullName())
		end

		burstVfx(self)
		playRandomSfxAt(getSfxSubfolder("PopSounds"), vector2)
		task.delay(July14thAdminAbuseConfig.FIREWORK_RESET_DELAY, function()
			v[self] = nil

			if p and p.isClone then
				v2[self] = nil
				self:Destroy()
			else
				self.CFrame = cFrame
				self.Transparency = 0
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

	local v3 = {}

	for _, v4 in getRigs(basic) do
		if not v[v4] then
			table.insert(v3, v4)
		end
	end

	if #v3 == 0 then
		warn("[FireworksController.FireRandom - No available firework rigs]")
	else
		FireworksController.LaunchFirework(v3[math.random(1, #v3)])
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

	for _ = 1, p do
		local FIREWORK_COLOR_ORDER

		if list and #list > 0 and list then
			FIREWORK_COLOR_ORDER = list
		else
			FIREWORK_COLOR_ORDER = July14thAdminAbuseConfig.FIREWORK_COLOR_ORDER
		end

		local v3 = FIREWORK_COLOR_ORDER[math.random(1, #FIREWORK_COLOR_ORDER)]
		local color = July14thAdminAbuseConfig.FIREWORK_COLORS[v3]
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