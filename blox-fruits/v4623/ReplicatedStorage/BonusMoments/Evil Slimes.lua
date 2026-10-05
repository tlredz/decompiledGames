local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local Effect = require(game.ReplicatedStorage.Effect)
local Util = require(game.ReplicatedStorage.Util)
local _ = {
	ENEMY_NAME = "Evil Slime",
	ISLAND_MODEL_NAME = "Magma",
	LOCATIONS_FOLDER = "BonusMoment_Locations",
	GEYSER_NAME = "SlimeGeyser"
}
local v = {
	LAVA_COLOR = Color3.fromRGB(255, 122, 30),
	LAVA_DEEP_COLOR = Color3.fromRGB(252, 70, 24),
	RANGE = 320,
	WAIT = 20,
	RETRY = 0.5,
	LIGHT_RANGE = 26,
	LIGHT_BRIGHTNESS = 2.2,
	LIGHT_PULSE = 0.8,
	PULSE_SPEED = 1.7,
	ERUPTION_SOUND = "Magma1.MagmaEruption",
	SOUND_RADIUS = 90,
	ROCK_SCALE = 0.18,
	ROCK_DURATION = 1.9,
	ROCK_ARC = 0.6,
	ROCK_MIN_DISTANCE = 20,
	ROCK_DISTANCE_SPREAD = 34,
	ROCK_SHAKE_DISTANCE = 70
}
local v2 = {
	COLOR = Color3.fromRGB(88, 8, 6),
	GLOW_COLOR = Color3.fromRGB(255, 34, 18),
	BLEND = 0.85,
	TINT_TIME = 1.6,
	LIGHT_BRIGHTNESS = 0.9,
	LIGHT_PULSE = 0.7,
	PULSE_SPEED = 2.4,
	EMBER_RATE = 2,
	EMBERS = 40,
	SOUND_PITCH = 0.55,
	SOUND_VOLUME = 0.6,
	SHAKE_POWER = 0.2,
	SHAKE_TIME = 1.2,
	CAMERA = 1.6
}
local _ = {
	EMBERS = 30,
	SPARKS = 18,
	FLASH = 2.1,
	FLASH_TIME = 0.35,
	SHAKE_POWER = 0.26,
	SHAKE_TIME = 0.9,
	ROCK_SCALE = 0.26,
	ROCK_ARC = 0.75,
	SOUND_PITCH = 1.05,
	SOUND_VOLUME = 0.5
}
local _ = {
	FREQUENCY = 32,
	ROLL_PER_STUD = 6,
	HIT_POWER = 0.26,
	HIT_RAMP = 0.22,
	HIT_TIME = 0.36,
	HIT_SOUND = "Magma1.MagmaSmallSummon",
	HIT_EMBERS = 10,
	HIT_SPARKS = 7,
	HIT_FLASH = 1.1,
	HIT_FLASH_TIME = 0.22,
	HIT_CAMERA = 1.4,
	HIT_CAMERA_RAMP = 1.1,
	HIT_CAMERA_ROUGH = 13
}
local _ = {
	SOUND = "Magma1.MagmaSmallSummon",
	SOUND_RADIUS = 70,
	PITCH_MIN = 1.15,
	PITCH_SPREAD = 0.25,
	VOLUME = 0.5,
	RISE = 1.2,
	RING_RADIUS = 9,
	DUST_SIZE = 7,
	SHINE_SIZE = 9,
	CAMERA = 1.8
}
local v3 = {
	SOUND = "Magma1.MagmaClapExplosion",
	BOOM_SOUND = "Explosions.ExplosionHeavy",
	SMOKE_COLOR = Color3.fromRGB(58, 46, 42),
	ROCK_COLOR = Color3.fromRGB(64, 54, 50),
	SCALE = 2.6,
	LIFETIME = 2.4,
	FIRE_EMIT = 90,
	FIRE_SPEED = 210,
	FIRE_SCALE = 2.4,
	SMASH_SIZE = 34,
	SMASH_DURATION = 0.9,
	DUST_SIZE = 52,
	SHOCK_SIZE = 96,
	RING_RADIUS = 44,
	ROCKS = 4,
	SHAKE = 9,
	HIDE_REAPPLY_DELAYS = { 0.25, 1 }
}
local _ = {
	MAX = 28,
	PER_PART = 2,
	MIN_SCALE = 0.22,
	MAX_SCALE = 0.42,
	SPEED = 55,
	LIFT = 45,
	SPIN = 12,
	MIN_SIZE = 1,
	MAX_SIZE = 8,
	FADE = 1.6,
	LIFETIME = 2.4
}
local _ = {
	BREAK_EMBERS = 60,
	BREAK_SPARKS = 40,
	BREAK_FLASH = 7,
	RETIRE_FADE = 0.8,
	RETIRE_LIFETIME = 2.5
}
local v4 = {
	FX_SET = "MagmaGun",
	FX_FOLDER = "MagmaGunZ",
	BLAST_HEIGHT = 3.5,
	BLAST_SOUND = "BF_WPN_RefMusket_ScorchingBurstExplosion_01",
	SPLAT_SOUND = "BF_WPN_RefMusket_Scorching_Explosions_0%d_V2",
	SOUND_RADIUS = 95,
	SHAKE = 11,
	FLASH_RANGE = 110,
	FLASH_TIME = 0.2,
	FLOOR_FADE = 0.2,
	SHOCK_TIME = 0.55,
	SHOCK_FALLBACK = 32,
	ERUPTION_DELAY = 0.3,
	CLEANUP = 5,
	SEED_FLIGHT = 0.45,
	SEED_MIN_FLIGHT = 0.12,
	SEED_SCALE = 2.2,
	SEED_ARC = 4,
	SEED_ARC_SCALE = 0.35,
	SEED_RING = 11,
	SEED_PROBE_UP = 4,
	SEED_PROBE_DOWN = 14,
	SPLATS = 5,
	SPLAT_DEGREE = 55,
	SPLAT_SPEED = { 70, 150 },
	SPLAT_FALL = 200,
	SPLAT_FALL_TIME = 0.5,
	SPLAT_FORCE = 700000,
	SPLAT_PROBE = 5,
	SPLAT_LIFETIME = 2,
	SPLAT_CRUST_DELAY = 0.2,
	SPLAT_PAD_FADE = 1,
	VORTEX_DELAY = 0.2,
	VORTEX_TIME = 0.4,
	VORTEX_STEP = { 0.02, 0.06 },
	VORTEX_WIDTH = { 5, 20 },
	VORTEX_RISE = { 100, 250 },
	VORTEX_SPIN = { 800, 1200 },
	VORTEX_LIFE = { 0.15, 0.3 },
	VORTEX_TRAIL_LIFE = { 0.1, 0.2 }
}
local _ = {
	BLOB_NAME = "AwakenedBlob",
	BLOB_FOLDER = "MagmaFloors",
	BLOB_FLATTEN = 0.25,
	BLOB_SEED = 0.35,
	BLOB_RISE = 0.25,
	LIGHT_RANGE = 0.7,
	TIER_ATTRIBUTE = "EvilSlimeTier",
	BIG_TIER = 1,
	LIFT = 0.25,
	PROBE_UP = 4,
	PROBE_DOWN = 90,
	PROBE_TRIES = 5,
	SETTLE_TIME = 0.6,
	SETTLE_STEP = 0.1,
	HISS_SOUND = "SteamHiss",
	HISS_GAP = 0.9,
	HISS_RADIUS = 60
}
local profile2 = {
	STEP = 5.5,
	BLOB_SPREAD = { 8, 11 },
	BLOB_HEIGHT = 2,
	BLOB_LIGHT = 6,
	BLOB_LIFETIME = 3.25,
	BLOB_FADE = 1.2,
	HISS = true,
	POOL_SCALE = { 1, 1.6 },
	POOL_EMIT = 0.35,
	POOL_LIFETIME = 4
}
local v6 = nil
local heartbeatConnection = nil
local v7 = nil
local count = 0
local flag = false
local flag2 = false
local count2 = 0
local v8 = {}
local v9 = {}
local tweens = {}
local descendantAddedConnection = nil
local cFrames = {}
local heartbeatConnection2 = nil
local v10 = createVector(0, 0, 0)
local v11 = 0
local v12 = 0
local v13 = 1
local v14 = 0
local v15 = nil
local v16 = nil
local connections = {}
local v17 = {}
local count3 = 0
local v18 = 0
local random = Random.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function flatUnit(vector2: Vector3)
	local vector3 = Vector3.new(vector2.X, 0, vector2.Z)

	if vector3.Magnitude > 0.01 then
		return vector3.Unit
	end

	return createVector(0, 0, 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function effectsParent()
	return workspace:FindFirstChild("_WorldOrigin") or workspace.Terrain
end

local function excludedContainers()
	local children = {}

	for _, childName in {
		"Characters",
		"Enemies",
		"NPCs",
		"_WorldOrigin"
	} do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(children, child)
		end
	end

	return children
end

-- equivalent calls inferred from this helper; original call sites unknown
local function worldParams()
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = excludedContainers()
	raycastParams.IgnoreWater = true
	return raycastParams
end

local function groundAt(vector2: Vector3, value: number?, value2: number?)
	local workspace2 = workspace
	local raycastResult = workspace2:Raycast(
		vector2 + Vector3.new(0, value or 60, 0),
		Vector3.new(0, -(value2 or 400), 0),
		worldParams()
	)

	if raycastResult then
		return raycastResult.Position, raycastResult.Normal
	end

	return vector2, createVector(0, 1, 0)
end

local function snapToGround(vector2: Vector3)
	local workspace2 = workspace
	local raycastResult = workspace2:Raycast(vector2 + createVector(0, 60, 0), createVector(0, -400, 0), worldParams())

	if not raycastResult then
		return vector2
	end

	local position = raycastResult.Position
	local _ = raycastResult.Normal
	return position
end

local function setEmitters(folder, enabled: boolean)
	for _, effect in folder:GetDescendants() do
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = enabled
		elseif effect:IsA("Trail") then
			effect.Enabled = enabled
		end
	end
end

local function emitOnce(folder)
	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit((emitter:GetAttribute("EmitCount")))
		end
	end
end

local function magmaFX()
	if v15 then
		return v15
	end

	local success, result = pcall(function()
		local FX = require(game.ReplicatedStorage.FX)
		local v19 = FX:Get(v4.FX_SET)

		if v19 then
			return (v19:FindFirstChild(v4.FX_FOLDER))
		end

		return nil
	end)

	if success and result then
		v15 = result
	end

	return v15
end

local function stopTrail()
	count3 += 1

	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)
	table.clear(v17)
	local v19 = v16
	v16 = nil

	if v19 then
		for _, child in v19:GetChildren() do
			setEmitters(child, false)
		end

		Util.Debris:AddItem(v19, profile2.POOL_LIFETIME)
	end
end

local function blobTemplate(childName: string)
	local assets = game.ReplicatedStorage:FindFirstChild("Assets")
	local models

	if assets then
		models = assets:FindFirstChild("Models")
	end

	local magmaFloors

	if models then
		magmaFloors = models:FindFirstChild("MagmaFloors")
	end

	local model

	if magmaFloors then
		model = magmaFloors:FindFirstChild(childName)
	end

	if model and model:IsA("Model") then
		return model
	end

	return nil
end

local function dropBlob(parent, data, position: Vector3)
	local v19 = blobTemplate("AwakenedBlob")

	if not v19 then
		return
	end

	local clone = v19:Clone()
	local number = random:NextNumber(data.BLOB_SPREAD[1], data.BLOB_SPREAD[2])
	local vector2 = Vector3.new(number, data.BLOB_HEIGHT * 0.25, number)
	local v20 = {}

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local v21 = part.Size * vector2
		v20[part] = v21
		part.Size = v21 * 0.35
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
	end

	setEmitters(clone, false)
	local pointLight = clone:FindFirstChildWhichIsA("PointLight", true)

	if pointLight then
		pointLight.Brightness = 0
		pointLight.Range = 0
	end

	clone:PivotTo(CFrame.new(position) * CFrame.Angles(0, random:NextNumber(0, 6.283185307179586), 0))
	clone.Parent = parent
	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)

	for k, size in v20 do
		TweenService:Create(k, tweenInfo, {
			Size = size
		}):Play()
	end

	if pointLight then
		TweenService:Create(pointLight, tweenInfo, {
			Brightness = data.BLOB_LIGHT,
			Range = number * 0.7
		}):Play()
	end

	if data.HISS then
		local now = os.clock()

		if v18 <= now then
			v18 = os.clock() + 0.9
			Util.Sound:Play("SteamHiss", position, 60, 1, 0.5)
		end
	end

	task.delay(data.BLOB_LIFETIME - data.BLOB_FADE, function()
		local tweenInfo2 = TweenInfo.new(data.BLOB_FADE, Enum.EasingStyle.Quad)

		if pointLight then
			TweenService:Create(pointLight, tweenInfo2, {
				Brightness = 0,
				Range = 0
			}):Play()
		end

		for k in v20 do
			TweenService:Create(k, tweenInfo2, {
				Size = k.Size * 0.05
			}):Play()
		end
	end)
	Util.Debris:AddItem(clone, data.BLOB_LIFETIME)
end

local function trailGround(vector2: Vector3)
	local raycastParams = worldParams() -- equivalent call inferred; original call site unknown
	local v20 = vector2 + createVector(0, 4, 0)

	for _ = 1, 5 do
		local raycastResult = workspace:Raycast(v20, createVector(0, -90, 0), raycastParams)

		if not raycastResult then
			return nil, createVector(0, 1, 0)
		end

		local awakenedBlob = raycastResult.Instance:FindFirstAncestor("AwakenedBlob")

		if not awakenedBlob then
			return raycastResult.Position, raycastResult.Normal
		end

		raycastParams:AddToFilter(awakenedBlob)
	end

	return nil, createVector(0, 1, 0)
end

local function dropTrailBlob(p, folder, profile, position: Vector3)
	local v19, v20 = trailGround(position)

	if not v19 then
		return
	end

	dropBlob(folder, profile, v19 + createVector(0, 0.25, 0))

	if not (p and folder.Parent) then
		return
	end

	local clone = p.FloorMiniMagma:Clone()
	clone.Size *= random:NextNumber(profile.POOL_SCALE[1], profile.POOL_SCALE[2])
	clone.CFrame = CFrame.lookAt(v19, v19 + v20)
	clone.Parent = folder
	task.delay(profile.POOL_EMIT, function()
		setEmitters(clone, false)
	end)
	Util.Debris:AddItem(clone, profile.POOL_LIFETIME)
end

local function settleFor(p, p2: number, fn)
	local v19 = os.clock() + 0.6
	local v20 = fn(p)

	while v20 == nil and os.clock() < v19 and count3 == p2 do
		task.wait(0.1)
		v20 = fn(p)
	end

	return v20
end

-- equivalent calls inferred from this helper; original call sites unknown
local function trackSlime(model, p: number)
	task.spawn(function()
		local part = settleFor(model, p, function(instance)
			return instance:FindFirstChild("HumanoidRootPart")
		end)

		if not (part and part:IsA("BasePart")) then
			return
		end

		local v19 = settleFor(model, p, function(instance)
			return instance:GetAttribute("EvilSlimeTier")
		end)

		if count3 ~= p or not model.Parent or v19 ~= 1 then
			return
		end

		table.insert(v17, {
			model = model,
			root = part,
			profile = profile2,
			last = part.Position
		})
	end)
end

local function startTrail()
	stopTrail()
	local v19 = count3
	local enemies = workspace:FindFirstChild("Enemies")

	if not enemies then
		return
	end

	local v20 = v15
	task.spawn(function()
		if not v15 then
			local success, result = pcall(function()
				local FX = require(game.ReplicatedStorage.FX)
				local v21 = FX:Get(v4.FX_SET)

				if v21 then
					return (v21:FindFirstChild(v4.FX_FOLDER))
				end

				return nil
			end)

			if success and result then
				v15 = result
			end
		end

		local v21 = v15

		if count3 == v19 then
			v20 = v21
		end
	end)
	local folder = Instance.new("Folder")
	folder.Name = "EvilSlimeTrail"
	folder.Parent = effectsParent()
	v16 = folder

	for _, model in enemies:GetChildren() do
		if not (model:IsA("Model") and model.Name == "Evil Slime") then
			continue
		end

		trackSlime(model, v19) -- equivalent call inferred; original call site unknown
	end

	table.insert(connections, enemies.ChildAdded:Connect(function(model)
		if model:IsA("Model") and model.Name == "Evil Slime" then
			trackSlime(model, v19) -- equivalent call inferred; original call site unknown
		end
	end))
	table.insert(connections, RunService.Heartbeat:Connect(function()
		if not folder.Parent then
			stopTrail()
			return
		end

		for i = #v17, 1, -1 do
			local v21 = v17[i]

			if v21.model.Parent and v21.root.Parent then
				local position = v21.root.Position

				if not ((position - v21.last).Magnitude < v21.profile.STEP) then
					v21.last = position
					dropTrailBlob(v20, folder, v21.profile, position)
				end
			else
				table.remove(v17, i)
			end
		end
	end))
end

local function magmaImpact(data, parent, cFrame: CFrame)
	local clone = data.FloorMiniMagma:Clone()
	clone.CFrame = cFrame
	clone.Parent = parent
	local clone2 = data.MiniExplosions:Clone()
	clone2.CFrame = cFrame
	clone2.Parent = parent
	emitOnce(clone2)
	Util.Sound:Play(string.format(v4.SPLAT_SOUND, random:NextInteger(1, 3)), cFrame.Position, v4.SOUND_RADIUS, 1, 0.6)
	local clone3 = data.MiniFloorMagma:Clone()
	clone3.CFrame = cFrame
	clone3.Parent = parent
	task.delay(v4.SPLAT_CRUST_DELAY, function()
		setEmitters(clone3, false)

		if not parent.Parent then
			return
		end

		local clone4 = data.SmallVolcanoe:Clone()
		clone4.CFrame = cFrame
		clone4.Parent = parent
		emitOnce(clone4)
	end)
	task.delay(v4.SPLAT_PAD_FADE, function()
		setEmitters(clone, false)
	end)
end

local function magmaSeed(p, folder, position: Vector3, item: Vector3, p2: number)
	local SEED_PROBE_UP = v4.SEED_PROBE_UP
	local SEED_PROBE_DOWN = v4.SEED_PROBE_DOWN or 400
	local workspace2 = workspace
	local raycastResult = workspace2:Raycast(
		item + Vector3.new(0, SEED_PROBE_UP or 60, 0),
		Vector3.new(0, -SEED_PROBE_DOWN, 0),
		worldParams()
	)
	local normal

	if raycastResult then
		local _ = raycastResult.Position
		normal = raycastResult.Normal
	else
		normal = createVector(0, 1, 0)
	end

	local cframe = CFrame.lookAt(item, item + normal)
	local clone = p.MiniMagma:Clone()
	clone.Anchored = true
	clone.Size *= v4.SEED_SCALE
	clone.CFrame = CFrame.new(position)
	clone.Parent = folder
	local v20 = v4.SEED_ARC + (item - position).Magnitude * v4.SEED_ARC_SCALE
	local lastTime = os.clock()
	local heartbeatConnection3 = nil
	heartbeatConnection3 = RunService.Heartbeat:Connect(function()
		if folder.Parent then
			local v21 = math.clamp((os.clock() - lastTime) / p2, 0, 1)
			local lerped = position:Lerp(cframe.Position, v21)
			clone.CFrame = CFrame.new(lerped + Vector3.new(0, math.sin(v21 * 3.141592653589793) * v20, 0))

			if v21 < 1 then
				return
			end

			if heartbeatConnection3 then
				heartbeatConnection3:Disconnect()
				heartbeatConnection3 = nil
			end

			setEmitters(clone, false)
			magmaImpact(p, folder, cframe)
			Effect.new("RingWind"):play({
				CFrame = CFrame.new(cframe.Position + createVector(0, 1, 0)),
				Transparency = { 0.35, 1 },
				Radius = { 2, v4.SEED_RING },
				Duration = 0.45,
				Color = v.LAVA_COLOR
			})
		elseif heartbeatConnection3 then
			heartbeatConnection3:Disconnect()
			heartbeatConnection3 = nil
		end
	end)
end

local function magmaSplat(p, folder, cframe: CFrame)
	local clone = p.MiniMagma:Clone()
	clone.CFrame = cframe * CFrame.Angles(
		math.rad((random:NextNumber(-v4.SPLAT_DEGREE, v4.SPLAT_DEGREE))),
		math.rad((random:NextNumber(-v4.SPLAT_DEGREE, v4.SPLAT_DEGREE))),
		0
	)
	clone.Parent = folder
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = createVector(1, 1, 1) * v4.SPLAT_FORCE
	bodyVelocity.Velocity = clone.CFrame.LookVector * random:NextNumber(v4.SPLAT_SPEED[1], v4.SPLAT_SPEED[2])
	bodyVelocity.Parent = clone
	TweenService:Create(bodyVelocity, TweenInfo.new(v4.SPLAT_FALL_TIME, Enum.EasingStyle.Linear), {
		Velocity = Vector3.new(0, -v4.SPLAT_FALL, 0)
	}):Play()
	Util.Debris:AddItem(bodyVelocity, v4.SPLAT_FALL_TIME)
	local raycastParams = worldParams() -- equivalent call inferred; original call site unknown
	local lastTime = os.clock()
	local heartbeatConnection3 = nil
	heartbeatConnection3 = RunService.Heartbeat:Connect(function()
		if clone.Parent and folder.Parent then
			local assemblyLinearVelocity = clone.AssemblyLinearVelocity
			local v20

			if assemblyLinearVelocity.Magnitude > 0.01 then
				v20 = assemblyLinearVelocity.Unit
			else
				v20 = clone.CFrame.LookVector
			end

			local raycastResult = workspace:Raycast(clone.Position, v20 * v4.SPLAT_PROBE, raycastParams)

			if not raycastResult and os.clock() - lastTime < v4.SPLAT_LIFETIME then
				return
			end

			if heartbeatConnection3 then
				heartbeatConnection3:Disconnect()
				heartbeatConnection3 = nil
			end

			setEmitters(clone, false)

			if not raycastResult then
				return
			end

			magmaImpact(p, folder, CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal))
		elseif heartbeatConnection3 then
			heartbeatConnection3:Disconnect()
			heartbeatConnection3 = nil
		end
	end)
end

local function magmaVortex(p, parent, cframe: CFrame)
	task.wait(v4.VORTEX_DELAY)
	local v19 = os.clock() + v4.VORTEX_TIME

	while os.clock() < v19 and parent.Parent do
		local clone = p.Trail:Clone()
		clone.Trail.Lifetime = random:NextNumber(v4.VORTEX_TRAIL_LIFE[1], v4.VORTEX_TRAIL_LIFE[2])
		local number = random:NextNumber(0, 360)
		local number2 = random:NextNumber(v4.VORTEX_SPIN[1], v4.VORTEX_SPIN[2])
		local number3 = random:NextNumber(v4.VORTEX_RISE[1], v4.VORTEX_RISE[2])
		local number4 = random:NextNumber(v4.VORTEX_WIDTH[1], v4.VORTEX_WIDTH[2])
		local total = 0
		clone.CFrame = cframe * CFrame.new(
			math.sin((math.rad(number))) * number4,
			math.cos((math.rad(number))) * number4,
			0
		)
		clone.Parent = parent
		local number5 = random:NextNumber(v4.VORTEX_LIFE[1], v4.VORTEX_LIFE[2])
		local heartbeatConnection3 = nil
		local v24 = os.clock()
		heartbeatConnection3 = RunService.Heartbeat:Connect(function(dt: number)
			if clone.Parent then
				total += number3 * dt
				number += number2 * dt
				clone.CFrame = cframe * CFrame.new(
					math.sin((math.rad(number))) * number4,
					math.cos((math.rad(number))) * number4,
					-total
				)

				if number5 <= os.clock() - v24 and heartbeatConnection3 then
					heartbeatConnection3:Disconnect()
					heartbeatConnection3 = nil
				end
			elseif heartbeatConnection3 then
				heartbeatConnection3:Disconnect()
				heartbeatConnection3 = nil
			end
		end)
		task.wait(random:NextNumber(v4.VORTEX_STEP[1], v4.VORTEX_STEP[2]))
	end
end

local function magmaSplitBurst(vector2: Vector3, items, p: number, p2: number)
	local lastTime = os.clock()

	if not v15 then
		local success, result = pcall(function()
			local FX = require(game.ReplicatedStorage.FX)
			local v19 = FX:Get(v4.FX_SET)

			if v19 then
				return (v19:FindFirstChild(v4.FX_FOLDER))
			end

			return nil
		end)

		if success and result then
			v15 = result
		end
	end

	local v19 = v15

	if not v19 then
		return
	end

	local v20 = math.max(v4.SEED_MIN_FLIGHT, p - (os.clock() - lastTime))
	local SEED_PROBE_UP = v4.SEED_PROBE_UP
	local SEED_PROBE_DOWN = v4.SEED_PROBE_DOWN or 400
	local workspace2 = workspace
	local raycastResult = workspace2:Raycast(
		vector2 + Vector3.new(0, SEED_PROBE_UP or 60, 0),
		Vector3.new(0, -SEED_PROBE_DOWN, 0),
		worldParams()
	)
	local position, normal

	if raycastResult then
		position = raycastResult.Position
		normal = raycastResult.Normal
	else
		position = vector2
		normal = createVector(0, 1, 0)
	end

	local cframe = CFrame.lookAt(position, position + normal)
	local v22 = vector2 + Vector3.new(0, v4.BLAST_HEIGHT, 0)
	local folder = Instance.new("Folder")
	folder.Name = "EvilSlimeSplitFX"
	folder.Parent = effectsParent()
	Util.Debris:AddItem(folder, v4.CLEANUP)
	local clone = v19.AirExplosion:Clone()
	clone.CFrame = CFrame.new(v22)
	clone.Parent = folder
	emitOnce(clone)
	Util.Sound:Play(v4.BLAST_SOUND, v22, v4.SOUND_RADIUS, 1, 1)
	Util.CameraShaker:ShakeOnce(v4.SHAKE, 9, 0.06, 1.5)
	local currentCamera = workspace.CurrentCamera

	if currentCamera and (currentCamera.CFrame.Position - v22).Magnitude <= v4.FLASH_RANGE then
		local clone2 = v19.ColorCorrection:Clone()
		clone2.Parent = Lighting
		TweenService:Create(clone2, TweenInfo.new(v4.FLASH_TIME, Enum.EasingStyle.Linear), {
			TintColor = Color3.new(1, 1, 1),
			Brightness = 0
		}):Play()
		Util.Debris:AddItem(clone2, v4.FLASH_TIME)
	end

	Effect.new("ExpandRing"):play({
		Origin = cframe,
		Color = v.LAVA_COLOR,
		Size = { createVector(6, 6, 1), (Vector3.new(p2 * 2, p2 * 2, 1)) },
		Duration = v4.SHOCK_TIME
	})
	local clone2 = v19.FloorMagma:Clone()
	clone2.CFrame = cframe
	clone2.Parent = folder
	task.delay(v4.FLOOR_FADE, function()
		setEmitters(clone2, false)
	end)

	for _ = 1, v4.SPLATS do
		magmaSplat(v19, folder, cframe)
	end

	for _, item in items do
		magmaSeed(v19, folder, v22, item, v20)
	end

	task.spawn(magmaVortex, v19, folder, cframe)
	task.delay(v4.ERUPTION_DELAY, function()
		if not folder.Parent then
			return
		end

		local clone3 = v19.Volcanoe:Clone()
		clone3.CFrame = cframe
		clone3.Parent = folder
		emitOnce(clone3)
	end)
end

local function findGeyser()
	local map = workspace:FindFirstChild("Map")
	local magma

	if map then
		magma = map:FindFirstChild("Magma")
	end

	local bonusMoment_Locations

	if magma then
		bonusMoment_Locations = magma:FindFirstChild("BonusMoment_Locations", true)
	end

	if not bonusMoment_Locations and map then
		bonusMoment_Locations = map:FindFirstChild("BonusMoment_Locations", true)
	end

	if not bonusMoment_Locations then
		return nil
	end

	local slimeGeyser = bonusMoment_Locations:FindFirstChild("SlimeGeyser")

	if slimeGeyser and slimeGeyser:IsA("PVInstance") then
		return slimeGeyser
	end

	return nil
end

local function geyserParts(part)
	local parts = {}

	if part:IsA("BasePart") then
		table.insert(parts, part)
	end

	for _, part2 in part:GetDescendants() do
		if part2:IsA("BasePart") then
			table.insert(parts, part2)
		end
	end

	return parts
end

local function worldBounds(p)
	local v19 = createVector(1e999, 1e999, 1e999)
	local v20 = createVector(-1e999, -1e999, -1e999)

	for _, v21 in geyserParts(p) do
		local cFrame = v21.CFrame
		local halfSize = v21.Size / 2
		local rightVector = cFrame.RightVector
		local upVector = cFrame.UpVector
		local lookVector = cFrame.LookVector
		local vector2 = Vector3.new(
			math.abs(rightVector.X * halfSize.X) + math.abs(upVector.X * halfSize.Y) + math.abs(lookVector.X * halfSize.Z),
			math.abs(rightVector.Y * halfSize.X) + math.abs(upVector.Y * halfSize.Y) + math.abs(lookVector.Y * halfSize.Z),
			math.abs(rightVector.Z * halfSize.X) + math.abs(upVector.Z * halfSize.Y) + math.abs(lookVector.Z * halfSize.Z)
		)
		v19 = v19:Min(cFrame.Position - vector2)
		v20 = v20:Max(cFrame.Position + vector2)
	end

	return v19, v20
end

local function ventPosition(instance)
	local v19, v20 = worldBounds(instance)

	if v19.X > v20.X then
		return instance:GetPivot().Position
	end

	return (Vector3.new((v19.X + v20.X) / 2, v20.Y, (v19.Z + v20.Z) / 2))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function basePosition(geyser)
	local v19, v20 = worldBounds(geyser)

	if v19.X > v20.X then
		return geyser:GetPivot().Position
	end

	return (Vector3.new((v19.X + v20.X) / 2, v19.Y, (v19.Z + v20.Z) / 2))
end

local function largestPartColor(geyser)
	local v19 = 0
	local v20 = nil

	for _, v21 in geyserParts(geyser) do
		if v21.Transparency >= 1 then
			continue
		end

		local v22 = v21.Size.X * v21.Size.Y * v21.Size.Z

		if not (v19 < v22) then
			continue
		end

		v20 = v21
		v19 = v22
	end

	if v20 then
		return v20.Color
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function geyserAnchor()
	local v19 = v7

	if v19 then
		return v19.position
	end

	local geyser = findGeyser()

	if geyser then
		local v20, v21 = worldBounds(geyser)

		if v20.X > v21.X then
			return geyser:GetPivot().Position
		end

		return (Vector3.new((v20.X + v21.X) / 2, v21.Y, (v20.Z + v21.Z) / 2))
	elseif v6 then
		return v6.Position
	else
		return nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreShakeBases()
	for k, cFrame in cFrames do
		if k.Parent then
			k.CFrame = cFrame
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopGeyserShake()
	if heartbeatConnection2 then
		heartbeatConnection2:Disconnect()
		heartbeatConnection2 = nil
	end

	restoreShakeBases() -- equivalent call inferred; original call site unknown
	table.clear(cFrames)
	v11 = 0
	v12 = 0
end

local function captureShakeBases()
	for k in cFrames do
		if k.Parent then
			continue
		end

		table.clear(cFrames)
		break
	end

	if next(cFrames) then
		return true
	end

	local geyser = findGeyser()

	if not geyser then
		return false
	end

	for _, v19 in geyserParts(geyser) do
		if v19.Anchored then
			cFrames[v19] = v19.CFrame
		end
	end

	if not next(cFrames) then
		return false
	end

	v10 = basePosition(geyser) -- equivalent call inferred; original call site unknown
	return true
end

local function updateGeyserShake()
	local now = os.clock()
	local v19 = v12 - now

	if v19 <= 0 or flag then
		if heartbeatConnection2 then
			heartbeatConnection2:Disconnect()
			heartbeatConnection2 = nil
		end

		restoreShakeBases() -- equivalent call inferred; original call site unknown
	else
		local v20 = v19 / v13 * v11
		local v21 = now - v14
		local v22 = math.sin(v21 * 32) * v20
		local v23 = math.sin(v21 * 32 * 1.37 + 1.1) * v20
		local cframe = CFrame.new(v10)
		local v24 = cframe * CFrame.Angles(math.rad(v23 * 6), 0, (math.rad(-v22 * 6))) * cframe:Inverse()

		for k, v25 in cFrames do
			if k.Parent then
				k.CFrame = v24 * (CFrame.new(v22, 0, v23) * v25)
			end
		end
	end
end

local function shakeGeyser(p: number, p2: number)
	if flag or p <= 0 or p2 <= 0 or not captureShakeBases() then
		return
	end

	local now = os.clock()
	v11 = math.max(p, not (now < v12) and 0 or v11 * ((v12 - now) / v13))
	v13 = p2
	v12 = now + p2
	v14 = now

	if not heartbeatConnection2 then
		heartbeatConnection2 = RunService.Heartbeat:Connect(updateGeyserShake)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyAmbience()
	count += 1

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if v7 then
		v7.vent:Destroy()
		v7 = nil
	end
end

local function retireAmbience()
	local v19 = v7

	if not v19 then
		return
	end

	count += 1

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	v7 = nil
	v19.embers:Emit(60)
	v19.sparks:Emit(40)
	v19.embers.Enabled = false
	v19.sparks.Enabled = false
	v19.embers.Rate = 0
	v19.sparks.Rate = 0
	v19.light.Brightness = 7
	TweenService:Create(v19.light, TweenInfo.new(0.8), {
		Brightness = 0,
		Range = 0
	}):Play()
	Util.Debris:AddItem(v19.vent, 2.5)
end

local function darkenAmbience(state)
	state.exposed = true
	state.embers.Rate = v2.EMBER_RATE
	state.embers.Color = ColorSequence.new(v2.GLOW_COLOR, v2.COLOR)
	state.sparks.Enabled = false
	TweenService:Create(state.light, TweenInfo.new(v2.TINT_TIME), {
		Color = v2.GLOW_COLOR
	}):Play()
end

local function buildAmbience(geyser)
	local position

	if geyser then
		local v19, v20 = worldBounds(geyser)

		if v19.X > v20.X then
			position = geyser:GetPivot().Position
		else
			position = Vector3.new((v19.X + v20.X) / 2, v20.Y, (v19.Z + v20.Z) / 2)
		end
	elseif v6 then
		position = v6.Position
	end

	if not position then
		return nil
	end

	local part = Instance.new("Part")
	part.Name = "SlimeGeyserVent"
	part.Size = createVector(0.4, 0.4, 0.4)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.CFrame = CFrame.new(position)
	local pointLight = Instance.new("PointLight")
	pointLight.Color = v.LAVA_COLOR
	pointLight.Range = v.LIGHT_RANGE
	pointLight.Brightness = v.LIGHT_BRIGHTNESS
	pointLight.Parent = part
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "Embers"
	particleEmitter.Color = ColorSequence.new(v.LAVA_COLOR, v.LAVA_DEEP_COLOR)
	particleEmitter.LightEmission = 1
	particleEmitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.9), NumberSequenceKeypoint.new(1, 0) })
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Lifetime = NumberRange.new(0.9, 1.8)
	particleEmitter.Rate = 5
	particleEmitter.Speed = NumberRange.new(8, 18)
	particleEmitter.SpreadAngle = Vector2.new(24, 24)
	particleEmitter.Acceleration = createVector(0, -26, 0)
	particleEmitter.Parent = part
	local particleEmitter2 = Instance.new("ParticleEmitter")
	particleEmitter2.Name = "Sparks"
	particleEmitter2.Color = ColorSequence.new(Color3.fromRGB(255, 236, 190), v.LAVA_COLOR)
	particleEmitter2.LightEmission = 1
	particleEmitter2.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(
			1,
			0
		) })
	particleEmitter2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter2.Lifetime = NumberRange.new(0.4, 1)
	particleEmitter2.Rate = 9
	particleEmitter2.Speed = NumberRange.new(14, 30)
	particleEmitter2.SpreadAngle = Vector2.new(40, 40)
	particleEmitter2.Acceleration = createVector(0, -60, 0)
	particleEmitter2.Parent = part
	part.Parent = workspace.Terrain
	local v19 = {
		vent = part,
		light = pointLight,
		embers = particleEmitter,
		sparks = particleEmitter2,
		position = position,
		phase = random:NextNumber() * 3.141592653589793 * 2,
		exposed = false,
		flashUntil = 0,
		flashPower = 0,
		flashSpan = 1
	}

	if flag2 then
		darkenAmbience(v19)
	end

	return v19
end

local function shootLavaRock(vector2: Vector3, position: Vector3?, p: number?, p2: number?, p3: number?)
	if not position then
		local number = random:NextNumber(-3.141592653589793, 3.141592653589793)
		local v19 = v.ROCK_MIN_DISTANCE + random:NextNumber() * v.ROCK_DISTANCE_SPREAD
		position = vector2 + Vector3.new(math.cos(number) * v19, 0, math.sin(number) * v19)
		local workspace2 = workspace
		local raycastResult = workspace2:Raycast(
			position + createVector(0, 60, 0),
			createVector(0, -400, 0),
			worldParams()
		)

		if raycastResult then
			position = raycastResult.Position
			local _ = raycastResult.Normal
		end
	end

	Effect.new("Volcano"):play({
		Mode = "Shoot",
		StartPosition = vector2,
		EndPosition = position,
		Duration = p or v.ROCK_DURATION,
		Scale = p2 or v.ROCK_SCALE,
		ArcScale = p3 or v.ROCK_ARC,
		SimpleArc = true,
		ShakeDistance = v.ROCK_SHAKE_DISTANCE,
		SoundRadius = v.SOUND_RADIUS,
		CraterAnywhere = true
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function flashGeyser(p, flashPower: number, flashSpan: number)
	p.flashPower = flashPower
	p.flashSpan = flashSpan
	p.flashUntil = os.clock() + flashSpan
end

local function knockGeyser(p: number, p2: number)
	local v19 = not (p2 > 1) and 1 or (p - 1) / (p2 - 1)
	shakeGeyser(0.26 + v19 * 0.22, 0.36)
	local v20 = v7

	if v20 then
		v20.embers:Emit(10)
		v20.sparks:Emit(7)
		flashGeyser(v20, 1.1, 0.22) -- equivalent call inferred; original call site unknown
	end

	local v21 = geyserAnchor() -- equivalent call inferred; original call site unknown

	if v21 then
		Util.Sound:Play("Magma1.MagmaSmallSummon", v21, v.SOUND_RADIUS, v19 * 0.35 + 0.85, 0.45)
	end

	Util.CameraShaker:ShakeOnce(1.4 + v19 * 1.1, 13, 0.02, 0.36)
end

local function tintGeyser(geyser)
	local tweenInfo = TweenInfo.new(v2.TINT_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

	for _, v19 in geyserParts(geyser) do
		if v19.Transparency >= 1 then
			continue
		end

		local v20 = v9[v19] or v19.Color
		v9[v19] = v20
		local tween = TweenService:Create(v19, tweenInfo, {
			Color = v20:Lerp(v2.COLOR, v2.BLEND)
		})
		table.insert(tweens, tween)
		tween:Play()
	end
end

local function restoreTints()
	for _, v19 in tweens do
		v19:Cancel()
	end

	table.clear(tweens)

	for k, color in v9 do
		if k.Parent then
			k.Color = color
		end
	end

	table.clear(v9)
end

local function exposeGeyser()
	if flag or flag2 then
		return
	end

	flag2 = true
	local geyser = findGeyser()

	if geyser then
		tintGeyser(geyser)
	end

	local v19 = v7

	if v19 then
		v19.embers:Emit(v2.EMBERS)
		flashGeyser(v19, 1.1, 0.22) -- equivalent call inferred; original call site unknown
		darkenAmbience(v19)
	end

	local v20 = geyserAnchor() -- equivalent call inferred; original call site unknown

	if v20 then
		Util.Sound:Play(v.ERUPTION_SOUND, v20, v.SOUND_RADIUS, v2.SOUND_PITCH, v2.SOUND_VOLUME)
	end

	shakeGeyser(v2.SHAKE_POWER, v2.SHAKE_TIME)
	Util.CameraShaker:ShakeOnce(v2.CAMERA, 9, 0.05, 1)
end

local function applyGeyserInstance(instance, flag3: boolean)
	if instance:IsA("BasePart") then
		if flag3 then
			if not v8[instance] then
				v8[instance] = {
					CanCollide = instance.CanCollide,
					CanTouch = instance.CanTouch,
					CanQuery = instance.CanQuery
				}
			end

			instance.LocalTransparencyModifier = 1
			instance.CanCollide = false
			instance.CanTouch = false
			instance.CanQuery = false
		else
			instance.LocalTransparencyModifier = 0
			local v19 = v8[instance]

			if v19 then
				instance.CanCollide = v19.CanCollide
				instance.CanTouch = v19.CanTouch
				instance.CanQuery = v19.CanQuery
				v8[instance] = nil
			end
		end
	elseif instance:IsA("Decal") then
		instance.LocalTransparencyModifier = flag3 and 1 or 0
	end
end

local function restoreGeyser()
	count2 += 1

	if descendantAddedConnection then
		descendantAddedConnection:Disconnect()
		descendantAddedConnection = nil
	end

	stopGeyserShake() -- equivalent call inferred; original call site unknown
	restoreTints()
	flag2 = false

	if not flag then
		return
	end

	flag = false

	for k, v19 in v8 do
		if not k.Parent then
			continue
		end

		k.LocalTransparencyModifier = 0
		k.CanCollide = v19.CanCollide
		k.CanTouch = v19.CanTouch
		k.CanQuery = v19.CanQuery
	end

	table.clear(v8)
	local geyser = findGeyser()

	if geyser then
		for _, decal in geyser:GetDescendants() do
			if decal:IsA("Decal") then
				decal.LocalTransparencyModifier = 0
			end
		end
	end
end

local function shatterGeyser(geyser, vector2: Vector3)
	local count4 = 0

	for _, v19 in geyserParts(geyser) do
		if count4 >= 28 then
			break
		end

		if v19.Transparency >= 1 then
			continue
		end

		for _ = 1, 2 do
			if count4 >= 28 then
				break
			end

			count4 += 1
			local clone = v19:Clone()

			for _, descendant in clone:GetDescendants() do
				if not (descendant:IsA("BasePart") or descendant:IsA("JointInstance") or descendant:IsA("Constraint") or descendant:IsA("Attachment") or descendant:IsA("LuaSourceContainer") or descendant:IsA("Sound")) then
					continue
				end

				descendant:Destroy()
			end

			local halfSize = v19.Size / 2
			local vector3 = Vector3.new(
				random:NextNumber(-halfSize.X, halfSize.X),
				random:NextNumber(-halfSize.Y, halfSize.Y),
				random:NextNumber(-halfSize.Z, halfSize.Z)
			)
			local cFrame = v19.CFrame * CFrame.new(vector3)
			local size = v19.Size * random:NextNumber(0.22, 0.42)
			local v23 = math.max(size.X, size.Y, size.Z)

			if v23 > 8 then
				size *= 8 / v23
			elseif v23 < 1 then
				size *= 1 / v23
			end

			clone.Name = "SlimeGeyserChunk"
			clone.Size = size
			clone.CFrame = cFrame
			clone.Anchored = false
			clone.CanCollide = false
			clone.CanQuery = false
			clone.CanTouch = false
			clone.Massless = true
			clone.CastShadow = false
			clone.LocalTransparencyModifier = 0
			clone.Parent = effectsParent()
			clone.AssemblyLinearVelocity = flatUnit(cFrame.Position - vector2) * random:NextNumber(27.5, 55) + Vector3.new(
				0,
				random:NextNumber(22.5, 45),
				0
			)
			clone.AssemblyAngularVelocity = Vector3.new(
				random:NextNumber(-12, 12),
				random:NextNumber(-12, 12),
				random:NextNumber(-12, 12)
			)
			TweenService:Create(clone, TweenInfo.new(1.6, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			Util.Debris:AddItem(clone, 2.4)
		end
	end
end

local function explodeGeyser(position: Vector3, position2: Vector3, ROCK_COLOR: Color3)
	Util.Sound:Play(v3.SOUND, position, v.SOUND_RADIUS, 0.9, 1)
	Util.Sound:Play(v3.BOOM_SOUND, position, v.SOUND_RADIUS, 0.85, 1)
	Effect.new("MeteorExplosion"):play({
		SmokeColor = v3.SMOKE_COLOR,
		Origin = CFrame.new(position) * CFrame.Angles(0, random:NextNumber(-3.141592653589793, 3.141592653589793), 0),
		Scale = v3.SCALE,
		Lifetime = v3.LIFETIME
	})
	Effect.new("FireExplosion"):play({
		Position = position,
		Emit = v3.FIRE_EMIT,
		Speed = v3.FIRE_SPEED,
		Scale = v3.FIRE_SCALE
	})
	Effect.new("GroundSmash"):play({
		Size = v3.SMASH_SIZE,
		Position = position2,
		Normal = createVector(0, 1, 0),
		Color = ROCK_COLOR,
		Duration = v3.SMASH_DURATION
	})
	Effect.new("DustExplosion"):play({
		CFrame = CFrame.new(position),
		Size = { 8, v3.DUST_SIZE },
		Duration = 1.1,
		ColorSequence = ColorSequence.new(v.LAVA_COLOR, v.LAVA_DEEP_COLOR)
	})
	Effect.new("ExpandRing"):play({
		Origin = CFrame.lookAt(position2, position2 + createVector(0, 1, 0)),
		Color = v.LAVA_COLOR,
		Size = { createVector(8, 8, 1), (Vector3.new(v3.SHOCK_SIZE, v3.SHOCK_SIZE, 1)) },
		Duration = 0.6
	})

	for i = 1, 2 do
		local ringWind = Effect.new("RingWind")
		local v19 = {
			CFrame = CFrame.new(position2 + Vector3.new(0, i * 3, 0)),
			Transparency = { 0.15, 1 },
			Radius = { 8, v3.RING_RADIUS + i * 10 },
			Duration = i * 0.15 + 0.7,
			Color = 0
		}
		local color

		if i % 2 == 0 then
			color = v.LAVA_DEEP_COLOR
		else
			color = v.LAVA_COLOR
		end

		v19.Color = color
		ringWind:play(v19)
	end

	for _ = 1, v3.ROCKS do
		shootLavaRock(position)
	end

	Util.CameraShaker:ShakeOnce(v3.SHAKE, 9, 0.06, 1.6)
end

local function crackGeyser()
	if flag then
		return
	end

	local geyser = findGeyser()
	local position2 = geyserAnchor() -- equivalent call inferred; original call site unknown

	if not position2 then
		return
	end

	stopGeyserShake() -- equivalent call inferred; original call site unknown
	flag = true
	count2 += 1
	local v20 = count2
	local position

	if geyser then
		local v21, v22 = worldBounds(geyser)

		if v21.X > v22.X then
			position = geyser:GetPivot().Position
		else
			position = Vector3.new((v21.X + v22.X) / 2, v21.Y, (v21.Z + v22.Z) / 2)
		end
	else
		local workspace2 = workspace
		local raycastResult = workspace2:Raycast(
			position2 + createVector(0, 60, 0),
			createVector(0, -400, 0),
			worldParams()
		)

		if raycastResult then
			position = raycastResult.Position
			local _ = raycastResult.Normal
		else
			position = position2
		end
	end

	local ROCK_COLOR

	if geyser then
		ROCK_COLOR = largestPartColor(geyser) or v3.ROCK_COLOR
	else
		ROCK_COLOR = v3.ROCK_COLOR
	end

	if geyser then
		shatterGeyser(geyser, position2)

		local function hideAll()
			for _, v21 in geyserParts(geyser) do
				applyGeyserInstance(v21, true)
			end

			for _, decal in geyser:GetDescendants() do
				if decal:IsA("Decal") then
					applyGeyserInstance(decal, true)
				end
			end
		end

		hideAll()

		for _, duration in v3.HIDE_REAPPLY_DELAYS do
			task.delay(duration, function()
				if flag and count2 == v20 then
					hideAll()
				end
			end)
		end

		descendantAddedConnection = geyser.DescendantAdded:Connect(function(descendant)
			if flag and count2 == v20 then
				applyGeyserInstance(descendant, true)
			end
		end)
	end

	explodeGeyser(position2, position, ROCK_COLOR)
	retireAmbience()
end

local function updateAmbience()
	local v19 = v7

	if not v19 then
		return
	end

	local currentCamera = workspace.CurrentCamera
	local position

	if currentCamera then
		position = currentCamera.CFrame.Position
	end

	local enabled

	if position == nil then
		enabled = false
	else
		enabled = (position - v19.position).Magnitude <= v.RANGE
	end

	v19.embers.Enabled = enabled
	v19.sparks.Enabled = enabled and not v19.exposed

	if not enabled then
		return
	end

	local now = os.clock()
	local LIGHT_BRIGHTNESS

	if v19.exposed then
		LIGHT_BRIGHTNESS = v2.LIGHT_BRIGHTNESS
	else
		LIGHT_BRIGHTNESS = v.LIGHT_BRIGHTNESS
	end

	local LIGHT_PULSE

	if v19.exposed then
		LIGHT_PULSE = v2.LIGHT_PULSE
	else
		LIGHT_PULSE = v.LIGHT_PULSE
	end

	local v21

	if v19.exposed then
		v21 = v2.PULSE_SPEED
	else
		v21 = v.PULSE_SPEED
	end

	local v22 = math.sin((now + v19.phase) * v21) * LIGHT_PULSE
	local v23 = not (now < v19.flashUntil) and 0 or v19.flashPower * ((v19.flashUntil - now) / v19.flashSpan)
	v19.light.Brightness = LIGHT_BRIGHTNESS + v22 + v23
end

-- equivalent calls inferred from this helper; original call sites unknown
local function armAmbience()
	destroyAmbience() -- equivalent call inferred; original call site unknown
	local v19 = count
	task.spawn(function()
		local v20 = os.clock() + v.WAIT
		local geyser = findGeyser()

		while not geyser and os.clock() < v20 do
			task.wait(v.RETRY)

			if count ~= v19 then
				return
			end

			geyser = findGeyser()
		end

		if count ~= v19 then
			return
		end

		v7 = buildAmbience(geyser)

		if not v7 then
			return
		end

		heartbeatConnection = RunService.Heartbeat:Connect(updateAmbience)
	end)
end

local function popBurst(position: Vector3)
	Util.Sound:Play("Magma1.MagmaSmallSummon", position, 70, 1.15 + random:NextNumber() * 0.25, 0.5)
	Effect.new("ShineExplosion"):play({
		Position = position,
		Size = 9,
		Lifetime = { 0.2, 0.32 }
	})
	Effect.new("RingWind"):play({
		CFrame = CFrame.new(position),
		Transparency = { 0.35, 1 },
		Radius = { 2, 9 },
		Duration = 0.4,
		Color = v.LAVA_COLOR
	})
	Effect.new("DustExplosion"):play({
		CFrame = CFrame.new(position),
		Size = { 2, 7 },
		Duration = 0.45,
		ColorSequence = ColorSequence.new(v.LAVA_COLOR, v.LAVA_DEEP_COLOR)
	})
	Util.CameraShaker:ShakeOnce(1.8, 11, 0.02, 0.3)
end

local function slimeMeteor(vector2: Vector3, vector3: Vector3, duration: number)
	local v19 = v7

	if v19 then
		v19.embers:Emit(30)
		v19.sparks:Emit(18)
		flashGeyser(v19, 2.1, 0.35) -- equivalent call inferred; original call site unknown
	end

	Util.Sound:Play(v.ERUPTION_SOUND, vector2, v.SOUND_RADIUS, 1.05, 0.5)
	shakeGeyser(0.26, 0.9)
	shootLavaRock(vector2, vector3, duration, 0.26, 0.75)
	task.delay(duration, function()
		popBurst(vector3 + createVector(0, 1.2, 0))
	end)
end

local function cleanup(flag3: boolean?)
	stopTrail()

	if not flag3 then
		destroyAmbience() -- equivalent call inferred; original call site unknown
		restoreGeyser()
		v6 = nil
	end
end

return {
	DataName = script.Name,
	OnComplete = function(_, p, p2)
		stopTrail()

		if not p or p2 then
			destroyAmbience() -- equivalent call inferred; original call site unknown
			restoreGeyser()
			v6 = nil
		end
	end,
	RemoteEvents = {
		Setup = function(_, p)
			stopTrail()
			destroyAmbience() -- equivalent call inferred; original call site unknown
			restoreGeyser()
			v6 = nil

			if typeof(p) ~= "CFrame" then
				p = nil
			end

			v6 = p
			armAmbience() -- equivalent call inferred; original call site unknown
		end,
		SlimeMeteor = function(_, startPosition, p2, ROCK_DURATION)
			if typeof(startPosition) ~= "Vector3" or typeof(p2) ~= "Vector3" then
				return
			end

			if type(ROCK_DURATION) ~= "number" or not (ROCK_DURATION > 0) then
				ROCK_DURATION = v.ROCK_DURATION
			end

			slimeMeteor(startPosition, p2, ROCK_DURATION)
		end,
		GeyserExposed = function(_)
			exposeGeyser()
		end,
		GeyserHit = function(_, value, value2)
			knockGeyser(
				typeof(value) ~= "number" and 1 or value,
				(typeof(value2) ~= "number" or not (value2 > 0)) and 1 or value2
			)
		end,
		BattleStarted = function(_)
			crackGeyser()
			startTrail()
		end,
		SplitBurst = function(_, p, items, SEED_FLIGHT, SHOCK_FALLBACK)
			if typeof(p) ~= "Vector3" then
				return
			end

			local v19 = {}

			if type(items) == "table" then
				for _, item in items do
					if typeof(item) == "Vector3" then
						table.insert(v19, item)
					end
				end
			end

			if type(SEED_FLIGHT) ~= "number" or not (SEED_FLIGHT > 0) then
				SEED_FLIGHT = v4.SEED_FLIGHT
			end

			if type(SHOCK_FALLBACK) ~= "number" or not (SHOCK_FALLBACK > 0) then
				SHOCK_FALLBACK = v4.SHOCK_FALLBACK
			end

			magmaSplitBurst(p, v19, SEED_FLIGHT, SHOCK_FALLBACK)
		end
	}
}