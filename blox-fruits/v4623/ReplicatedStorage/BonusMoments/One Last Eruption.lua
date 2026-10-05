local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local Effect = require(game.ReplicatedStorage.Effect)
local Util = require(game.ReplicatedStorage.Util)
local DialogueController = require(game.ReplicatedStorage.DialogueController)
local _ = {
	SOUND = "Magma1.MagmaSmallSummon",
	SOUND_RADIUS = 70,
	VOLUME = 0.7,
	STAGGER = 0.12,
	FADE = 0.5,
	EMBERS = 26,
	SMASH_SIZE = 13,
	SMASH_DURATION = 0.8,
	DUST_SIZE = 15,
	RING_SIZE = 20,
	SHAKE = 1.6,
	SHAKE_RANGE = 120
}
local _ = {
	FADE = 0.55,
	EMBERS = 10,
	DUST_SIZE = 9,
	LIGHT_FADE = 0.4
}
local v = {
	SOUND = "Magma1.MagmaClapExplosion",
	BOOM_SOUND = "Explosions.ExplosionHeavy",
	SOUND_RADIUS = 90,
	SMOKE_COLOR = Color3.fromRGB(58, 46, 42),
	ROCK_COLOR = Color3.fromRGB(64, 54, 50),
	SCALE = 1.7,
	LIFETIME = 2.2,
	FIRE_EMIT = 60,
	FIRE_SPEED = 150,
	FIRE_SCALE = 1.7,
	SMASH_SIZE = 22,
	SMASH_DURATION = 0.9,
	DUST_SIZE = 34,
	SHOCK_SIZE = 58,
	RING_RADIUS = 26,
	ROCKS = 3,
	ROCK_SCALE = 0.16,
	ROCK_DURATION = 1.7,
	ROCK_ARC = 0.6,
	ROCK_MIN_DISTANCE = 18,
	ROCK_DISTANCE_SPREAD = 30,
	ROCK_SHAKE_DISTANCE = 70,
	SHAKE = 6.5,
	EMBERS = 60,
	LIGHT_FLASH = 7,
	LIGHT_FADE = 0.8,
	VENT_LIFETIME = 2.5
}
local _ = {
	MAX = 22,
	PER_PART = 3,
	MIN_SCALE = 0.22,
	MAX_SCALE = 0.42,
	SPEED = 55,
	LIFT = 45,
	SPIN = 12,
	MIN_SIZE = 1,
	MAX_SIZE = 6,
	FADE = 1.6,
	LIFETIME = 2.4
}
local color = Color3.fromRGB(58, 48, 44)
local color2 = Color3.fromRGB(255, 90, 20)
local color3 = Color3.fromRGB(252, 70, 24)
local color4 = Color3.fromRGB(255, 226, 170)
local v2 = nil
local v3 = {}
local v4 = {}
local v5 = 1
local random = Random.new()
local flag = false
local v6 = nil
local v7 = nil
local v8 = nil
local v9 = nil

local function getRoot()
	local character = Players.LocalPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	return nil
end

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

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.RespectCanCollide = true
raycastParams.IgnoreWater = true

local function snapToGround(cframe: CFrame)
	local filterDescendantsInstances = {}

	for _, childName in { "NPCs", "Characters", "Enemies" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(filterDescendantsInstances, child)
		end
	end

	for _, v11 in v3 do
		if v11.model.Parent then
			table.insert(filterDescendantsInstances, v11.model)
		end
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local upVector = cframe.UpVector
	local v11 = cframe.Position + upVector * 150
	local raycastResult = workspace:Raycast(v11, -upVector * 550, raycastParams)

	if raycastResult then
		return CFrame.new(raycastResult.Position) * cframe.Rotation
	end

	return cframe
end

local function nearSummit()
	local currentCamera = workspace.CurrentCamera
	return currentCamera ~= nil and (currentCamera.CFrame.Position - createVector(-5636, 200, 8631)).Magnitude <= 1400
end

-- equivalent calls inferred from this helper; original call sites unknown
local function shake(SHAKE: number, p: number, p2: number, p3: number, vector2: Vector3?)
	local currentCamera = workspace.CurrentCamera
	local v10

	if currentCamera == nil then
		v10 = false
	else
		v10 = (currentCamera.CFrame.Position - createVector(-5636, 200, 8631)).Magnitude <= 1400
	end

	if not v10 then
		return
	end

	Util.CameraShaker:ShakeOnce(SHAKE, p, p2, p3, createVector(1, 1, 1), vector2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopSustained()
	if v7 then
		pcall(function()
			v7:StartFadeOut(1)
		end)
		v7 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startSustained()
	if v7 then
		return
	end

	v7 = Util.CameraShaker:StartShake(1.2, 3, 1.5)
end

local function buildSustained(p: number)
	local v10 = v7

	if not v10 then
		return
	end

	local lastTime = os.clock()

	while v7 == v10 do
		local v11 = math.clamp((os.clock() - lastTime) / p, 0, 1)
		v10.Magnitude = v11 * 2.3 + 1.2

		if v11 >= 1 then
			break
		else
			task.wait(0.1)
		end
	end
end

local v10 = nil

local function getGeyserTemplate()
	if v10 ~= nil then
		return v10 or nil
	end

	local lavaGeyser = script:WaitForChild("LavaGeyser", 5)

	if not (lavaGeyser and lavaGeyser:IsA("Model")) then
		lavaGeyser = false
	end

	v10 = lavaGeyser
	return v10 or nil
end

local function findGeyserPart(folder, list: string)
	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") and part.Name:lower():sub(1, #list) == list then
			return part
		end
	end

	return nil
end

local function localBounds(folder, cframe: CFrame)
	local v11 = createVector(1e999, 1e999, 1e999)
	local v12 = createVector(-1e999, -1e999, -1e999)
	local descendants = folder:GetDescendants()

	if folder:IsA("BasePart") then
		table.insert(descendants, folder)
	end

	for _, part in descendants do
		if not part:IsA("BasePart") then
			continue
		end

		local objectSpace = cframe:ToObjectSpace(part.CFrame)
		local halfSize = part.Size / 2
		local rightVector = objectSpace.RightVector
		local upVector = objectSpace.UpVector
		local lookVector = objectSpace.LookVector
		local vector2 = Vector3.new(
			math.abs(rightVector.X * halfSize.X) + math.abs(upVector.X * halfSize.Y) + math.abs(lookVector.X * halfSize.Z),
			math.abs(rightVector.Y * halfSize.X) + math.abs(upVector.Y * halfSize.Y) + math.abs(lookVector.Y * halfSize.Z),
			math.abs(rightVector.Z * halfSize.X) + math.abs(upVector.Z * halfSize.Y) + math.abs(lookVector.Z * halfSize.Z)
		)
		v11 = v11:Min(objectSpace.Position - vector2)
		v12 = v12:Max(objectSpace.Position + vector2)
	end

	return v11, v12
end

local function placeOnGround(instance, cframe: CFrame, p: number, value: number?)
	local v11 = cframe.Rotation * CFrame.Angles(0, p, 0)
	local pivot = instance:GetPivot()
	instance:PivotTo(CFrame.new(pivot.Position) * v11 * pivot.Rotation)
	local v12 = CFrame.new(instance:GetPivot().Position) * v11
	local v13, v14 = localBounds(instance, v12)

	if v13.X > v14.X then
		return v11
	end

	local v15 = v12 * Vector3.new((v13.X + v14.X) / 2, v13.Y, (v13.Z + v14.Z) / 2)
	instance:PivotTo(instance:GetPivot() + (cframe.Position - v15) - v11.UpVector * (value or 0.5))
	return v11
end

local function buildFissure(cframe: CFrame, i: number, flag2: boolean)
	local random2 = Random.new(i * 7919)

	if v10 == nil then
		local lavaGeyser = script:WaitForChild("LavaGeyser", 5)

		if not (lavaGeyser and lavaGeyser:IsA("Model")) then
			lavaGeyser = false
		end

		v10 = lavaGeyser
	end

	local v11

	if v10 then
		v11 = v10
	end

	local v12

	if v11 then
		v12 = v11:Clone()
	else
		v12 = Instance.new("Model")
	end

	v12.Name = "MagmaFissure"

	for _, part in v12:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end

	local v13 = placeOnGround(v12, cframe, random2:NextNumber(-3.141592653589793, 3.141592653589793))
	local geyserPart = findGeyserPart(v12, "invis")

	if geyserPart then
		geyserPart.Transparency = 1
		geyserPart.CastShadow = false
	end

	local geyserPart2 = findGeyserPart(v12, "lava")
	local color5

	if geyserPart2 then
		color5 = geyserPart2.Color
	else
		color5 = color2
	end

	local v14 = CFrame.new(cframe.Position) * v13
	local v15, v16 = localBounds(geyserPart2 or v12, v14)
	local v17

	if v15.X > v16.X then
		v17 = cframe.Position + v13.UpVector * 0.4
	else
		v17 = v14 * Vector3.new((v15.X + v16.X) / 2, v16.Y, (v15.Z + v16.Z) / 2)
	end

	local part = Instance.new("Part")
	part.Name = "Vent"
	part.Size = createVector(0.3, 0.3, 0.3)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.CFrame = CFrame.new(v17) * v13
	part.Parent = v12
	local pointLight = Instance.new("PointLight")
	pointLight.Color = color2
	pointLight.Range = 16
	pointLight.Brightness = 1.4
	pointLight.Parent = part
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "Embers"
	particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 150, 40))
	particleEmitter.LightEmission = 1
	particleEmitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0) })
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Lifetime = NumberRange.new(0.7, 1.4)
	particleEmitter.Rate = 3
	particleEmitter.Speed = NumberRange.new(6, 14)
	particleEmitter.SpreadAngle = Vector2.new(22, 22)
	particleEmitter.Acceleration = createVector(0, -22, 0)
	particleEmitter.Parent = part
	local transparenciesByPart = {}

	for _, part2 in v12:GetDescendants() do
		if part2:IsA("BasePart") and part2 ~= geyserPart and part2 ~= part then
			transparenciesByPart[part2] = part2.Transparency
		end
	end

	if flag2 then
		if geyserPart then
			geyserPart.Transparency = 0
		end

		if geyserPart2 then
			geyserPart2.Color = color
		end

		pointLight.Brightness = 0
		particleEmitter.Rate = 0
		particleEmitter.Enabled = false
	end

	v12.Parent = workspace
	return {
		model = v12,
		cframe = cframe,
		vent = part,
		crust = geyserPart,
		lava = geyserPart2,
		lavaColor = color5,
		light = pointLight,
		embers = particleEmitter,
		shell = transparenciesByPart,
		sealed = flag2,
		destroyed = false,
		damage = 0,
		flash = -1e999,
		phase = random2:NextNumber() * 3.141592653589793 * 2
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function crustTarget(state)
	if state.sealed then
		return 0
	end

	return 1 - state.damage * 0.55
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setFissureDamage(state, value: number)
	state.damage = math.clamp(value, 0, 1)

	if state.crust then
		state.crust.Transparency = crustTarget(state)
	end
end

local function reformFissure(fissure)
	for k, transparency in fissure.shell do
		k.Transparency = 1
		TweenService:Create(k, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
			Transparency = transparency
		}):Play()
	end

	local crust = fissure.crust

	if crust then
		local transparency = crust.Transparency
		crust.Transparency = 1
		TweenService:Create(crust, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
			Transparency = transparency
		}):Play()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function openFissure(state, flag2: boolean)
	if not state.sealed then
		return
	end

	state.sealed = false
	local crust = state.crust
	local lava = state.lava
	local transparency = crustTarget(state) -- equivalent call inferred; original call site unknown
	state.embers.Rate = 3
	state.embers.Enabled = true

	if flag2 then
		state.flash = os.clock()
		state.embers:Emit(26)

		if crust then
			TweenService:Create(crust, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
				Transparency = transparency
			}):Play()
		end

		if lava then
			lava.Color = state.lavaColor
		end

		local cframe = state.cframe
		local position = state.vent.Position
		Util.Sound:Play("Magma1.MagmaSmallSummon", position, 70, 1, 0.7)
		Effect.new("GroundSmash"):play({
			Size = 13,
			Position = cframe.Position,
			Normal = cframe.UpVector,
			Color = v.ROCK_COLOR,
			Duration = 0.8
		})
		Effect.new("DustExplosion"):play({
			CFrame = CFrame.new(position),
			Size = { 4, 15 },
			Duration = 0.9,
			ColorSequence = ColorSequence.new(color2, color3)
		})
		Effect.new("ExpandRing"):play({
			Origin = CFrame.lookAt(cframe.Position, cframe.Position + cframe.UpVector),
			Color = color2,
			Size = { createVector(4, 4, 1), createVector(20, 20, 1) },
			Duration = 0.55
		})
		local currentCamera = workspace.CurrentCamera

		if currentCamera and (currentCamera.CFrame.Position - position).Magnitude <= 120 then
			Util.CameraShaker:ShakeOnce(1.6, 7, 0.05, 0.5, createVector(1, 1, 1))
		end
	else
		if crust then
			crust.Transparency = transparency
		end

		if lava then
			lava.Color = state.lavaColor
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function dropFissure(p)
	p.model:Destroy()
	p.vent:Destroy()
end

local function sealFissure(state, flag2: boolean)
	if state.sealed then
		return
	end

	state.sealed = true
	local crust = state.crust
	local lava = state.lava
	state.embers.Enabled = false
	state.embers.Rate = 0

	if flag2 then
		state.embers:Emit(10)

		if crust then
			TweenService:Create(crust, TweenInfo.new(0.55, Enum.EasingStyle.Quad), {
				Transparency = 0
			}):Play()
		end

		if lava then
			TweenService:Create(lava, TweenInfo.new(0.55), {
				Color = color
			}):Play()
		end

		TweenService:Create(state.light, TweenInfo.new(0.4), {
			Brightness = 0
		}):Play()
		Effect.new("DustExplosion"):play({
			CFrame = CFrame.new(state.vent.Position),
			Size = { 3, 9 },
			Duration = 0.9,
			ColorSequence = ColorSequence.new(v.SMOKE_COLOR, v.ROCK_COLOR)
		})
	else
		if crust then
			crust.Transparency = 0
		end

		if lava then
			lava.Color = color
		end

		state.light.Brightness = 0
	end
end

local function hitFissure(state, p: number, p2: number)
	if state.destroyed then
		return
	end

	local v11 = math.clamp(p / math.max(p2, 1), 0, 1)
	setFissureDamage(state, v11) -- equivalent call inferred; original call site unknown
	state.flash = os.clock()
	state.embers:Emit(18)
	Util.Sound:Play("TreeBreak", state.vent.Position, 18, v11 * 0.35 + 0.85, 0.45)
	local currentCamera = workspace.CurrentCamera

	if currentCamera and (currentCamera.CFrame.Position - state.vent.Position).Magnitude <= 70 then
		Util.CameraShaker:ShakeOnce(1.4, 8, 0.05, 0.35, createVector(1, 1, 1))
	end
end

local function modelParts(folder)
	local parts = {}

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			table.insert(parts, part)
		end
	end

	return parts
end

local function largestPartColor(model)
	local v11 = 0
	local v12 = nil

	for _, v13 in modelParts(model) do
		if v13.Transparency >= 1 then
			continue
		end

		local v14 = v13.Size.X * v13.Size.Y * v13.Size.Z

		if not (v11 < v14) then
			continue
		end

		v12 = v13
		v11 = v14
	end

	if v12 then
		return v12.Color
	end

	return nil
end

local function shatterFissure(model, position: Vector3)
	local count = 0

	for _, v11 in modelParts(model) do
		if count >= 22 then
			break
		end

		if v11.Transparency >= 1 then
			continue
		end

		for _ = 1, 3 do
			if count >= 22 then
				break
			end

			count += 1
			local clone = v11:Clone()

			for _, descendant in clone:GetDescendants() do
				if not (descendant:IsA("BasePart") or descendant:IsA("JointInstance") or descendant:IsA("Constraint") or descendant:IsA("Attachment") or descendant:IsA("LuaSourceContainer") or descendant:IsA("Sound")) then
					continue
				end

				descendant:Destroy()
			end

			local halfSize = v11.Size / 2
			local vector2 = Vector3.new(
				random:NextNumber(-halfSize.X, halfSize.X),
				random:NextNumber(-halfSize.Y, halfSize.Y),
				random:NextNumber(-halfSize.Z, halfSize.Z)
			)
			local cFrame = v11.CFrame * CFrame.new(vector2)
			local size = v11.Size * random:NextNumber(0.22, 0.42)
			local v15 = math.max(size.X, size.Y, size.Z)

			if v15 > 6 then
				size *= 6 / v15
			elseif v15 < 1 then
				size *= 1 / v15
			end

			clone.Name = "MagmaFissureChunk"
			clone.Size = size
			clone.CFrame = cFrame
			clone.Transparency = 0
			clone.Anchored = false
			clone.CanCollide = false
			clone.CanQuery = false
			clone.CanTouch = false
			clone.Massless = true
			clone.CastShadow = false
			clone.LocalTransparencyModifier = 0
			clone.Parent = effectsParent()
			clone.AssemblyLinearVelocity = flatUnit(cFrame.Position - position) * random:NextNumber(27.5, 55) + Vector3.new(
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

local function shootLavaRock(position: Vector3)
	local number = random:NextNumber(-3.141592653589793, 3.141592653589793)
	local v11 = v.ROCK_MIN_DISTANCE + random:NextNumber() * v.ROCK_DISTANCE_SPREAD
	local position2 = snapToGround(CFrame.new(position + Vector3.new(math.cos(number) * v11, 0, math.sin(number) * v11))).Position
	Effect.new("Volcano"):play({
		Mode = "Shoot",
		StartPosition = position,
		EndPosition = position2,
		Duration = v.ROCK_DURATION,
		Scale = v.ROCK_SCALE,
		ArcScale = v.ROCK_ARC,
		SimpleArc = true,
		ShakeDistance = v.ROCK_SHAKE_DISTANCE,
		SoundRadius = v.SOUND_RADIUS,
		CraterAnywhere = true
	})
end

local function explodeFissure(position: Vector3, cframe: CFrame, color5: Color3)
	local position2 = cframe.Position
	local upVector = cframe.UpVector
	Util.Sound:Play(v.SOUND, position, v.SOUND_RADIUS, 0.9, 1)
	Util.Sound:Play(v.BOOM_SOUND, position, v.SOUND_RADIUS, 0.85, 1)
	Effect.new("MeteorExplosion"):play({
		SmokeColor = v.SMOKE_COLOR,
		Origin = CFrame.new(position) * CFrame.Angles(0, random:NextNumber(-3.141592653589793, 3.141592653589793), 0),
		Scale = v.SCALE,
		Lifetime = v.LIFETIME
	})
	Effect.new("FireExplosion"):play({
		Position = position,
		Emit = v.FIRE_EMIT,
		Speed = v.FIRE_SPEED,
		Scale = v.FIRE_SCALE
	})
	Effect.new("GroundSmash"):play({
		Size = v.SMASH_SIZE,
		Position = position2,
		Normal = upVector,
		Color = color5,
		Duration = v.SMASH_DURATION
	})
	Effect.new("DustExplosion"):play({
		CFrame = CFrame.new(position),
		Size = { 8, v.DUST_SIZE },
		Duration = 1.1,
		ColorSequence = ColorSequence.new(color2, color3)
	})
	Effect.new("ExpandRing"):play({
		Origin = CFrame.lookAt(position2, position2 + upVector),
		Color = color2,
		Size = { createVector(8, 8, 1), (Vector3.new(v.SHOCK_SIZE, v.SHOCK_SIZE, 1)) },
		Duration = 0.6
	})

	for i = 1, 2 do
		local ringWind = Effect.new("RingWind")
		local v11 = {
			CFrame = CFrame.new(position2 + upVector * (i * 3)),
			Transparency = { 0.15, 1 },
			Radius = { 8, v.RING_RADIUS + i * 10 },
			Duration = i * 0.15 + 0.7,
			Color = 0
		}
		local color6

		if i % 2 == 0 then
			color6 = color3
		else
			color6 = color2
		end

		v11.Color = color6
		ringWind:play(v11)
	end

	for _ = 1, v.ROCKS do
		shootLavaRock(position)
	end

	shake(v.SHAKE, 9, 0.06, 1.6, nil) -- equivalent call inferred; original call site unknown
end

local function retireVent(data)
	data.embers:Emit(v.EMBERS)
	data.embers.Enabled = false
	data.embers.Rate = 0
	data.light.Brightness = v.LIGHT_FLASH
	TweenService:Create(data.light, TweenInfo.new(v.LIGHT_FADE), {
		Brightness = 0,
		Range = 0
	}):Play()
	data.vent.Parent = effectsParent()
	Util.Debris:AddItem(data.vent, v.VENT_LIFETIME)
end

local function destroyFissure(state)
	if state.destroyed then
		return
	end

	state.destroyed = true
	local position = state.vent.Position
	local color5 = largestPartColor(state.model) or v.ROCK_COLOR
	shatterFissure(state.model, position)
	retireVent(state)
	state.model:Destroy()
	explodeFissure(position, state.cframe, color5)
end

local function applyState(flag2: boolean, list, list2, flag3: boolean)
	for i = 1, #v4 do
		local v11 = v3[i]

		if list[i] then
			if v11 then
				v3[i] = nil
				dropFissure(v11) -- equivalent call inferred; original call site unknown
			end
		else
			local v12 = (list2[i] or 0) / math.max(v5, 1)

			if v11 then
				setFissureDamage(v11, v12) -- equivalent call inferred; original call site unknown

				if flag2 then
					if flag3 then
						task.delay((i - 1) * 0.12, openFissure, v11, true)
					else
						openFissure(v11, false) -- equivalent call inferred; original call site unknown
					end
				else
					sealFissure(v11, flag3)
				end
			else
				local fissure = buildFissure(snapToGround(v4[i]), i, not flag2)
				v3[i] = fissure
				setFissureDamage(fissure, v12) -- equivalent call inferred; original call site unknown

				if flag3 then
					reformFissure(fissure)
				end
			end
		end
	end
end

local function scatterPoint(object)
	local number = object:NextNumber(-3.141592653589793, 3.141592653589793)
	local v11 = 120 + object:NextNumber() * 700
	local vector2 = Vector3.new(-5636 + math.cos(number) * v11, 200, 8631 + math.sin(number) * v11)
	local position = snapToGround(CFrame.new(vector2)).Position

	if position.Y >= 160 then
		return (Vector3.new(vector2.X, 10, vector2.Z))
	end

	return position
end

local function getControls()
	local success, result = pcall(function()
		local playerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts", 5)
		local playerModule = playerScripts and playerScripts:WaitForChild("PlayerModule", 5)

		if not playerModule then
			return nil
		end

		local module = require(playerModule)
		return (module:GetControls())
	end)

	if success then
		return result
	end

	return nil
end

local function makeFade()
	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return nil, nil
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "OneLastEruptionCinematic"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 62
	screenGui.Parent = playerGui
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	return frame, screenGui
end

local function fade(fade2, backgroundTransparency: number, duration: number)
	if not fade2 then
		task.wait(duration)
		return
	end

	local tween = TweenService:Create(fade2, TweenInfo.new(duration), {
		BackgroundTransparency = backgroundTransparency
	})
	tween:Play()
	tween.Completed:Wait()
end

local function playFade(fade2, backgroundTransparency: number, duration: number)
	if not fade2 then
		return
	end

	TweenService:Create(fade2, TweenInfo.new(duration), {
		BackgroundTransparency = backgroundTransparency
	}):Play()
end

local function lerpV(vector2: Vector3, vector3: Vector3, p: number)
	return vector2 + (vector3 - vector2) * p
end

local function solveShot(data, p: number, p2: number)
	if data.solve then
		return data.solve(p, p2)
	end

	local camStart = data.camStart or createVector(0, 0, 0)
	local lookStart = data.lookStart or createVector(0, 0, 0)
	return
		camStart + ((data.camEnd or camStart) - camStart) * p,
		lookStart + ((data.lookEnd or lookStart) - lookStart) * p
end

local function releaseCamera(custom, fieldOfView: number)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local character = Players.LocalPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	if humanoid then
		currentCamera.CameraSubject = humanoid
	end

	currentCamera.FieldOfView = fieldOfView

	if custom == Enum.CameraType.Scriptable then
		custom = Enum.CameraType.Custom
	end

	for i = 1, 5 do
		currentCamera.CameraType = custom

		if currentCamera.CameraType == custom then
			break
		end

		if i < 5 then
			task.wait(0.1)
		end
	end
end

local function runShots(list)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera or #list == 0 or flag then
		return
	end

	local v11 = {}
	v6 = v11
	flag = true
	local character = Players.LocalPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	else
		humanoid = nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function aborted()
		if v6 ~= v11 then
			return true
		end

		return Players.LocalPlayer.Character ~= character or humanoid == nil or humanoid.Health <= 0
	end

	local success, result = pcall(function()
		local playerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts", 5)
		local playerModule = playerScripts and playerScripts:WaitForChild("PlayerModule", 5)

		if not playerModule then
			return nil
		end

		local module = require(playerModule)
		return (module:GetControls())
	end)

	if not success then
		result = nil
	end

	if result then
		pcall(function()
			result:Disable()
		end)
	end

	local cameraType = currentCamera.CameraType
	local fieldOfView = currentCamera.FieldOfView
	local fade2, v12 = makeFade()
	fade(fade2, 0, 0.3)
	local v13 = aborted() -- equivalent call inferred; original call site unknown

	if not v13 then
		for k, v15 in list do
			local currentCamera2 = workspace.CurrentCamera

			if currentCamera2 then
				currentCamera2.CameraType = Enum.CameraType.Scriptable
				currentCamera2.FieldOfView = v15.fov
				local v16, v17

				if v15.solve then
					v16, v17 = v15.solve(0, 0)
				else
					local camStart = v15.camStart or createVector(0, 0, 0)
					local lookStart = v15.lookStart or createVector(0, 0, 0)
					v16 = camStart + ((v15.camEnd or camStart) - camStart) * 0
					v17 = lookStart + ((v15.lookEnd or lookStart) - lookStart) * 0
				end

				currentCamera2.CFrame = CFrame.lookAt(v16, v17)

				if k == 1 then
					playFade(fade2, 1, 0.4)
				end

				local v18 = k == #list
				local lastTime = os.clock()
				local v19 = false

				while true do
					if v6 ~= v11 or Players.LocalPlayer.Character ~= character or humanoid == nil or humanoid.Health <= 0 then
						v13 = true
						break
					end

					local v20 = os.clock() - lastTime
					local v21 = math.clamp(v20 / v15.duration, 0, 1)
					local currentCamera3 = workspace.CurrentCamera

					if not currentCamera3 then
						v13 = true
						break
					end

					currentCamera3.CameraType = Enum.CameraType.Scriptable
					local v22, v23

					if v15.solve then
						v22, v23 = v15.solve(v21, v20)
					else
						local camStart = v15.camStart or createVector(0, 0, 0)
						local lookStart = v15.lookStart or createVector(0, 0, 0)
						v22 = camStart + ((v15.camEnd or camStart) - camStart) * v21
						v23 = lookStart + ((v15.lookEnd or lookStart) - lookStart) * v21
					end

					currentCamera3.CFrame = CFrame.lookAt(v22, v23)
					currentCamera3.FieldOfView = v15.fov

					if v18 and not v19 and v15.duration - 0.3 <= v20 then
						playFade(fade2, 0, 0.3)
						v19 = true
					end

					if v21 >= 1 then
						break
					else
						RunService.RenderStepped:Wait()
					end
				end

				if v13 then
					break
				end
			else
				v13 = true
				break
			end
		end
	end

	releaseCamera(cameraType, fieldOfView)

	if result then
		pcall(function()
			result:Enable()
		end)
	end

	if not v13 then
		fade(fade2, 1, 0.4)
	end

	if v12 then
		v12:Destroy()
	end

	if v6 == v11 then
		v6 = nil
		flag = false
	end
end

local function awayFromSummit()
	local character = Players.LocalPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = nil
	end

	local v11 = ((not humanoidRootPart and createVector(-5316, 200, 8631) or humanoidRootPart.Position) - createVector(
		-5636,
		200,
		8631
	)) * createVector(1, 0, 1)
	local vector2 = not (v11.Magnitude > 1) and createVector(1, 0, 0) or v11.Unit
	return vector2, vector2:Cross(createVector(0, 1, 0))
end

local function runEruptionCinematic()
	if flag then
		return
	end

	local character = Players.LocalPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	if humanoid and not (humanoid.Health <= 0) then
		local character2 = Players.LocalPlayer.Character
		local humanoidRootPart

		if character2 then
			humanoidRootPart = character2:FindFirstChild("HumanoidRootPart")
		end

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			humanoidRootPart = nil
		end

		if humanoidRootPart then
			local character3 = Players.LocalPlayer.Character
			local humanoidRootPart2

			if character3 then
				humanoidRootPart2 = character3:FindFirstChild("HumanoidRootPart")
			end

			if not (humanoidRootPart2 and humanoidRootPart2:IsA("BasePart")) then
				humanoidRootPart2 = nil
			end

			local v11 = ((not humanoidRootPart2 and createVector(-5316, 200, 8631) or humanoidRootPart2.Position) - createVector(
				-5636,
				200,
				8631
			)) * createVector(1, 0, 1)
			local vector2 = not (v11.Magnitude > 1) and createVector(1, 0, 0) or v11.Unit
			local cross = vector2:Cross(createVector(0, 1, 0))
			runShots({
				{
					camStart = createVector(-5636, 200, 8631) + vector2 * 380 + createVector(0, 70, 0) - cross * 50,
					camEnd = createVector(-5636, 200, 8631) + vector2 * 330 + createVector(0, 90, 0) + cross * 50,
					lookStart = createVector(-5636, 210, 8631),
					lookEnd = createVector(-5636, 230, 8631),
					fov = 70,
					duration = 5
				},
				{
					fov = 76,
					duration = 6.5,
					solve = function(p: number, p2: number)
						local v13 = CFrame.Angles(0, p2 * 0.10471975511965978, 0) * vector2
						local v14 = p * 210 + 330
						local v15 = p * 130 + 70
						return
							createVector(-5636, 200, 8631) + v13 * v14 + createVector(0, 1, 0) * v15,
							createVector(-5636, 200, 8631) + createVector(0, 1, 0) * (p * 90 + 40)
					end
				}
			})
		end
	end
end

local function launchMeteor(random2)
	local number = random2:NextNumber(-3.141592653589793, 3.141592653589793)
	local v11 = random2:NextNumber() * 14
	local startPosition = createVector(-5636, 200, 8631) + Vector3.new(
		math.cos(number) * v11,
		random2:NextNumber(0, 14),
		math.sin(number) * v11
	)
	Effect.new("Volcano"):play({
		Mode = "Shoot",
		StartPosition = startPosition,
		EndPosition = scatterPoint(random2),
		Duration = random2:NextNumber(2.6, 4.4),
		Scale = 0.6 + random2:NextNumber() * 1,
		ArcScale = 0.75 + random2:NextNumber() * 0.6,
		SimpleArc = true,
		ShakeDistance = 90,
		SoundRadius = 55,
		CraterAnywhere = true
	})
end

local function runBarrage()
	local v11 = {}
	v9 = v11
	local random2 = Random.new()
	Util.Sound:Play("Magma1.MagmaEruption", createVector(-5636, 200, 8631), 900)
	Util.Sound:Play("Explosions.ExplosionHeavy", nil, nil, 0.8, 1)

	for _ = 1, 12 do
		launchMeteor(random2)
	end

	local currentCamera = workspace.CurrentCamera
	local v12

	if currentCamera == nil then
		v12 = false
	else
		v12 = (currentCamera.CFrame.Position - createVector(-5636, 200, 8631)).Magnitude <= 1400
	end

	local v13

	if v12 then
		v13 = Util.CameraShaker:StartShake(9, 7, 0.15, createVector(0.35, 0.35, 0.35))
	end

	local now = os.clock()
	local v14 = now + random2:NextNumber(0.55, 1.2)

	while v9 == v11 do
		local now2 = os.clock()
		local v15 = now2 - now

		if v15 >= 11 then
			break
		end

		local v16 = 1 - v15 / 11

		if v13 then
			v13.Magnitude = 3 + 6 * v16
		end

		if v14 <= now2 then
			v14 = now2 + random2:NextNumber(0.55, 1.2)
			local v17 = 6 * (0.6 + 0.4 * v16)
			local currentCamera2 = workspace.CurrentCamera
			local v18

			if currentCamera2 == nil then
				v18 = false
			else
				v18 = (currentCamera2.CFrame.Position - createVector(-5636, 200, 8631)).Magnitude <= 1400
			end

			if v18 then
				Util.CameraShaker:ShakeOnce(v17, 9, 0.05, 1.4, createVector(1, 1, 1), createVector(1, 1, 3))
			end
		end

		local v17 = 1 + 2 * (v15 / 11)
		task.wait(random2:NextNumber(0.12, 0.3) * v17)

		if v9 ~= v11 then
			break
		end

		launchMeteor(random2)
	end

	if v13 then
		v13:StartFadeOut(3)
	end

	if v9 == v11 then
		v9 = nil
	end
end

local function tameBloom()
	local childAddedConnection = Lighting.ChildAdded:Connect(function(bloomEffect)
		if not bloomEffect:IsA("BloomEffect") then
			return
		end

		bloomEffect.Intensity = 0.04
		bloomEffect.Size = 6
	end)
	task.delay(2, function()
		if childAddedConnection then
			childAddedConnection:Disconnect()
			childAddedConnection = nil
		end
	end)
end

local function playBigEruption()
	v8 = nil
	tameBloom()
	Effect.new("Volcano"):play({
		Mode = "Eruption",
		StartPosition = createVector(-5636, 200, 8631),
		EndPosition = createVector(-5636, 20, 8631)
	})

	if DialogueController.Active then
		pcall(function()
			DialogueController.close()
		end)
	end

	task.spawn(runEruptionCinematic)
	startSustained() -- equivalent call inferred; original call site unknown
	task.spawn(buildSustained, 5)
	task.delay(5, function()
		stopSustained() -- equivalent call inferred; original call site unknown
		local currentCamera = workspace.CurrentCamera
		local v11

		if currentCamera == nil then
			v11 = false
		else
			v11 = (currentCamera.CFrame.Position - createVector(-5636, 200, 8631)).Magnitude <= 1400
		end

		if v11 then
			Util.CameraShaker:ShakeOnce(8, 10, 0.1, 3, createVector(1, 1, 1), createVector(1, 1, 3))
		end

		task.spawn(runBarrage)
	end)
end

local function cleanupAll()
	for _, v11 in v3 do
		dropFissure(v11) -- equivalent call inferred; original call site unknown
	end

	v3 = {}
	stopSustained() -- equivalent call inferred; original call site unknown
	v8 = nil
	v9 = nil
	v6 = nil
	flag = false
	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	local oneLastEruptionCinematic

	if playerGui then
		oneLastEruptionCinematic = playerGui:FindFirstChild("OneLastEruptionCinematic")
	end

	if oneLastEruptionCinematic then
		oneLastEruptionCinematic:Destroy()
	end

	for _, model in workspace:GetChildren() do
		if model:IsA("Model") and model.Name == "MagmaFissure" then
			model:Destroy()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startLoops(maid)
	maid:GiveTask(RunService.Heartbeat:Connect(function()
		if v2 ~= maid or maid.Completed then
			return
		end

		local now = os.clock()

		for _, v11 in v3 do
			if v11.destroyed or v11.sealed then
				continue
			end

			local v12 = math.sin(now * 1.6 + v11.phase) * 0.5 + 0.5
			local v13 = math.max(0, 1 - (now - v11.flash) / 0.22)
			local v14 = 1 - v11.damage * 0.5
			v11.light.Brightness = (v12 * 1.8 + 0.8) * v14 + v13 * 5

			if v11.lava then
				v11.lava.Color = v11.lavaColor:Lerp(color4, v12 * 0.25 + v13 * 0.75)
			end
		end
	end))
end

local OneLastEruption = {}
OneLastEruption.DataName = script.Name

function OneLastEruption.OnLoad(object)
	v2 = object
	cleanupAll()
	startLoops(object) -- equivalent call inferred; original call site unknown
	object:FireServer("Init")
	task.delay(4, function()
		if v2 == object and #v4 == 0 and not object.Completed then
			object:FireServer("Init")
		end
	end)
end

OneLastEruption.RemoteEvents = {
	Setup = function(p, items, value)
		if not p or p ~= v2 or typeof(items) ~= "table" then
			return
		end

		if typeof(value) == "number" and value > 0 then
			v5 = value
		end

		local v11 = {}

		for k, item in items do
			if not (typeof(k) == "number" and typeof(item) == "CFrame") then
				continue
			end

			v11[k] = item
		end

		v4 = v11
	end,
	State = function(p, p2, p3, p4, p5)
		if not p or p ~= v2 then
			return
		end

		if #v4 == 0 or typeof(p3) ~= "table" or typeof(p4) ~= "table" then
			return
		end

		applyState(p2 == true, p3, p4, p5 == true)
	end,
	FissureHit = function(p, value, value2, value3)
		if not p or p ~= v2 then
			return
		end

		local v11

		if typeof(value) == "number" then
			v11 = v3[value]
		end

		if not v11 then
			return
		end

		local v13 = typeof(value2) ~= "number" and 1 or value2

		if typeof(value3) ~= "number" then
			value3 = v5
		end

		hitFissure(v11, v13, value3)
	end,
	Destroyed = function(p, value)
		if not p or p ~= v2 then
			return
		end

		local v11

		if typeof(value) == "number" then
			v11 = v3[value]
		end

		if v11 then
			v3[value] = nil
			destroyFissure(v11)
		end
	end,
	BigPending = function(p, value)
		if not p or p ~= v2 then
			return
		end

		local v11 = typeof(value) ~= "number" and 6 or value
		local v12 = {}
		v8 = v12
		task.delay(math.max(v11 - 6, 0), function()
			if v8 ~= v12 or v2 ~= p then
				return
			end

			startSustained() -- equivalent call inferred; original call site unknown
		end)
	end,
	BigEruption = function(p)
		if not p or p ~= v2 then
			return
		end

		task.spawn(playBigEruption)
	end
}

function OneLastEruption.OnComplete(p, _, p2)
	if v2 ~= p then
		return
	end

	cleanupAll()

	if p2 then
		v2 = nil
		v4 = {}
	end
end

return OneLastEruption