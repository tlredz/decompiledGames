local createVector = vector.create
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PartyEvent = require(script.Parent.Parent.PartyEvent)
local ZoneSystem = require(ReplicatedStorage.ZoneSystem)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local LightingSnapshot = require(ReplicatedStorage.Utilities.Events.LightingSnapshot)
local ParticleZone = require(ReplicatedStorage.Utilities.Events.ParticleZone)
local AlienRemotes = require(script.Parent.Parent.AlienRemotes)
local v = nil
local renderSteppedConnection = nil

local function collectParts(folder)
	local result = {}

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			table.insert(result, part)
		end
	end

	if folder:IsA("BasePart") then
		table.insert(result, folder)
	end

	return result
end

local function partContains(instance, vector2: Vector3)
	local pointToObjectSpace = instance.CFrame:PointToObjectSpace(vector2)
	local v2 = instance.Size * 0.5
	return math.abs(pointToObjectSpace.X) <= v2.X and math.abs(pointToObjectSpace.Y) <= v2.Y and math.abs(pointToObjectSpace.Z) <= v2.Z
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function smoothstep(p: number)
	return p * p * (3 - p * 2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bodyPosition(part)
	if part:IsA("BasePart") then
		return part.Position
	end

	return part:GetPivot().Position
end

local function animatedCF(state, p: number)
	local v2 = p + state.phaseOffset
	local v3 = math.sin(v2 * 0.6) * 2.5
	local v4 = p * 1 + state.phaseOffset
	local v5 = v2 * 0.6
	local v6 = math.cos(v5) * 6
	local v7 = math.sin(v5) * 6
	local v8 = math.sin(v2 * 0.6 * 0.5) * 0.075
	return state.basePivot * CFrame.new(v6, v3, v7) * CFrame.Angles(v8, v4, 0)
end

local function applyFade(p, p2: number, flag: boolean)
	for k, v2 in p.baseTransparency do
		if not k.Parent then
			continue
		end

		local transparency

		if flag then
			transparency = 1 + (v2 - 1) * p2
		else
			transparency = v2 + (1 - v2) * p2
		end

		k.Transparency = transparency
	end
end

local function pickBasePivot(data, instance, p: number, pivotToBottom: number)
	local v2 = instance.Size * 0.5
	local spawnPart = data.spawnPart

	for _ = 1, 25 do
		local v3 = (math.random() * 2 - 1) * v2.X * 0.8
		local v4 = (math.random() * 2 - 1) * v2.Z * 0.8
		local position = (instance.CFrame * CFrame.new(v3, 0, v4)).Position
		local v5

		if spawnPart then
			local v6 = position.X - spawnPart.Position.X
			local v7 = position.Z - spawnPart.Position.Z
			v5 = v6 * v6 + v7 * v7 < 3025
		else
			v5 = false
		end

		if v5 then
			continue
		end

		local flag = true

		for _, ufo in data.ufos do
			local v7 = position.X - ufo.basePivot.Position.X
			local v8 = position.Z - ufo.basePivot.Position.Z

			if not (v7 * v7 + v8 * v8 < 900) then
				continue
			end

			flag = false
			break
		end

		if flag then
			return CFrame.new(position.X, p + pivotToBottom + 2.5, position.Z)
		end
	end

	return nil
end

local function makeUfo(data, spawnZone)
	if data.stopped then
		return
	end

	local spawnCtx = data.spawnCtx
	local v2 = spawnZone.Size * 0.5
	local v4 = pickBasePivot(data, spawnZone, spawnZone.Position.Y - v2.Y, spawnCtx.pivotToBottom)

	if not v4 then
		return
	end

	local clone = spawnCtx.template:Clone()
	local parts = collectParts(clone)
	local transparencies = {}

	for _, v6 in parts do
		v6.Anchored = true
		v6.CanCollide = false
		v6.CanQuery = false
		v6.Massless = true
		transparencies[v6] = v6.Transparency
		v6.Transparency = 1
	end

	clone:PivotTo(v4)
	clone.Parent = workspace
	table.insert(data.ufos, {
		model = clone,
		parts = parts,
		ray = clone:FindFirstChild("Ray"),
		body = clone:FindFirstChild("Ufo") or clone,
		spawnZone = spawnZone,
		basePivot = v4,
		phaseOffset = math.random() * 3.141592653589793 * 2,
		baseTransparency = transparencies,
		CF = v4,
		state = "fade-in",
		elapsedTime = 0,
		age = 0,
		lifetime = 30 + (math.random() * 2 - 1) * 8
	})
end

local function updateUfo(ufo, now: number, p: number)
	ufo.elapsedTime += p
	ufo.age += p
	local state = ufo.state

	if state == "fade-in" then
		ufo.CF = animatedCF(ufo, now)
		local v2 = math.clamp(ufo.elapsedTime / 0.6, 0, 1)
		applyFade(ufo, v2, true)

		if v2 >= 1 then
			ufo.state = "patrol"
			ufo.elapsedTime = 0
		end
	elseif state == "patrol" then
		ufo.CF = animatedCF(ufo, now)

		if ufo.age >= ufo.lifetime then
			ufo.state = "fade-out"
			ufo.elapsedTime = 0
		end
	elseif state == "static-in" then
		local v3 = smoothstep(math.clamp(ufo.elapsedTime / 0.25, 0, 1))
		ufo.CF = animatedCF(ufo, now):Lerp(ufo.staticCF, v3)

		if ufo.elapsedTime >= 0.25 then
			ufo.state = "static"
			ufo.elapsedTime = 0
		end
	elseif state == "static" then
		ufo.CF = ufo.staticCF
	elseif state == "static-out" then
		local v3 = smoothstep(math.clamp(ufo.elapsedTime / 0.5, 0, 1))
		ufo.CF = ufo.staticCF:Lerp(animatedCF(ufo, now), v3)

		if ufo.elapsedTime >= 0.5 then
			ufo.state = "patrol"
			ufo.elapsedTime = 0
		end
	elseif state == "fade-out" then
		ufo.CF = animatedCF(ufo, now)
		local v2 = math.clamp(ufo.elapsedTime / 0.5, 0, 1)
		applyFade(ufo, v2, false)

		if v2 >= 1 then
			if ufo.model.Parent then
				ufo.model:Destroy()
			end

			return true
		end
	end

	if ufo.model.Parent then
		ufo.model:PivotTo(ufo.CF)
	end

	return false
end

local function beginAbduction(p, ufo, humanoid, humanoidRootPart)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://131978461743688"
	sound.Volume = 1.5
	sound.Parent = humanoidRootPart
	sound:Play()
	p.abduct = {
		ufo = ufo,
		hrp = humanoidRootPart,
		humanoid = humanoid,
		holdCF = humanoidRootPart.CFrame,
		sound = sound
	}
	humanoid.PlatformStand = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function endAbduction(p, flag: boolean)
	local abduct = p.abduct

	if not abduct then
		return
	end

	p.abduct = nil

	if abduct.humanoid and abduct.humanoid.Parent then
		abduct.humanoid.PlatformStand = false
	end

	if flag then
		AlienRemotes.AlienAbductRequest:fire()
	end
end

local function setupAtmosphere(p)
	local atmoJanitor = p.atmoJanitor
	local currentCamera = workspace.CurrentCamera
	local position = currentCamera and currentCamera.CFrame.Position or createVector(0, 0, 0)
	LightingSnapshot.acquireShared()
	LightingSnapshot.capture({
		"Brightness",
		"Ambient",
		"OutdoorAmbient",
		"FogEnd",
		"FogColor"
	}):apply({
		Brightness = 1,
		Ambient = Color3.fromRGB(12, 30, 18),
		OutdoorAmbient = Color3.fromRGB(18, 40, 24),
		FogColor = Color3.fromRGB(10, 28, 16),
		FogEnd = 550
	})
	local v2 = atmoJanitor:Add(Instance.new("ColorCorrectionEffect"))
	v2.Name = "AlienColorCorrection"
	v2.Brightness = -0.12
	v2.Contrast = 0.15
	v2.Saturation = 0.25
	v2.TintColor = Color3.fromRGB(120, 235, 140)
	v2.Parent = Lighting
	local atmoZone = ParticleZone.new({
		diameter = 60
	})
	atmoZone:setup(atmoJanitor, CFrame.new(position))
	p.atmoZone = atmoZone
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 255, 190)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 200, 90))
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6),
		NumberSequenceKeypoint.new(0.5, 0.8),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Size = NumberSequence.new(0.4, 0.15)
	particleEmitter.LightEmission = 1
	particleEmitter.LightInfluence = 0
	particleEmitter.Speed = NumberRange.new(0.5, 2)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Lifetime = NumberRange.new(2.5, 5)
	particleEmitter.Rate = 30
	particleEmitter.LockedToPart = true
	particleEmitter.Parent = atmoZone.part
end

local function buildWorld()
	local alien = ReplicatedStorage.Assets.Events:FindFirstChild("Alien")
	local UFO = alien and alien:FindFirstChild("UFO")

	if not UFO then
		warn("[Alien] Modèle \"UFO\" introuvable dans Assets/Events/Alien")
		return false
	end

	local zones = ZoneSystem.GetZonesById("Lobby")

	if #zones == 0 then
		warn("[Alien] Aucune zone Lobby (ZoneId=\"Lobby\") trouvée")
		return false
	end

	local Y, Y2

	if UFO:IsA("Model") then
		local boundingBox, v2 = UFO:GetBoundingBox()
		Y = boundingBox.Position.Y
		Y2 = v2.Y
	else
		Y = UFO.Position.Y
		Y2 = UFO.Size.Y
	end

	local pivotToBottom = UFO:GetPivot().Position.Y - (Y - Y2 * 0.5)
	v = {
		ufos = {},
		spawnPart = workspace:FindFirstChild("SpawnLocation", true),
		spawnCtx = {
			template = UFO,
			pivotToBottom = pivotToBottom
		},
		atmoJanitor = Janitor.new(),
		atmoZone = nil,
		abduct = nil,
		hunter = nil,
		stopped = false,
		lastNow = nil
	}
	setupAtmosphere(v)

	for _, zone in zones do
		for _ = 1, 8 do
			makeUfo(v, zone)
		end
	end

	return true
end

local function teardownWorld()
	local v2 = v

	if not v2 then
		return
	end

	v = nil
	v2.stopped = true

	if v2.abduct and v2.abduct.humanoid and v2.abduct.humanoid.Parent then
		v2.abduct.humanoid.PlatformStand = false
	end

	if v2.hunter and v2.hunter.model then
		v2.hunter.model:Destroy()
		v2.hunter = nil
	end

	LightingSnapshot.releaseShared(0.5)
	v2.atmoJanitor:Cleanup()
	local ufos = v2.ufos

	for _, ufo in ufos do
		ufo.state = "fade-out"
		ufo.elapsedTime = 0
	end

	if #ufos == 0 then
		return
	end

	task.spawn(function()
		repeat
			local v3 = RunService.RenderStepped:Wait()
			local v4 = false

			for _, ufo in ufos do
				if not (ufo.model and ufo.model.Parent) then
					continue
				end

				ufo.elapsedTime += v3
				local v5 = math.clamp(ufo.elapsedTime / 0.5, 0, 1)
				applyFade(ufo, v5, false)

				if v5 >= 1 then
					ufo.model:Destroy()
				else
					v4 = true
				end
			end
		until not v4
	end)
end

local function updateFrame()
	local v2 = v

	if not v2 then
		return
	end

	local now = os.clock()
	local v3 = math.min(now - (v2.lastNow or now), 0.1)
	v2.lastNow = now
	local currentCamera = workspace.CurrentCamera

	if v2.atmoZone and currentCamera then
		v2.atmoZone:update(currentCamera.CFrame.Position)
	end

	for i = #v2.ufos, 1, -1 do
		local ufo = v2.ufos[i]

		if ufo.model and ufo.model.Parent then
			if updateUfo(ufo, now, v3) then
				table.remove(v2.ufos, i)
				local spawnZone = ufo.spawnZone
				task.delay(5, function()
					makeUfo(v2, spawnZone)
				end)
			end
		else
			table.remove(v2.ufos, i)
		end
	end

	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local abduct = v2.abduct

	if abduct then
		local ufo = abduct.ufo
		local hrp = abduct.hrp

		if ufo.model and ufo.model.Parent and hrp and hrp.Parent then
			hrp.AssemblyLinearVelocity = createVector(0, 0, 0)

			if ufo.state == "static-in" then
				hrp.CFrame = abduct.holdCF
			elseif ufo.state == "static" then
				local v4 = 1 - math.exp(v3 * -6)
				local cFrame = hrp.CFrame
				local v5 = bodyPosition(ufo.body) -- equivalent call inferred; original call site unknown
				hrp.CFrame = cFrame:Lerp(CFrame.new(v5), v4)

				if ufo.elapsedTime >= 1 then
					ufo.state = "static-out"
					ufo.elapsedTime = 0
					endAbduction(v2, true) -- equivalent call inferred; original call site unknown
				end
			end
		else
			endAbduction(v2, false) -- equivalent call inferred; original call site unknown
		end
	else
		if not humanoidRootPart then
			return
		end

		local spawnPart = v2.spawnPart

		if spawnPart and (humanoidRootPart.Position - spawnPart.Position).Magnitude < 40 or (not humanoid or humanoid.Health <= 0) then
			return
		end

		for _, ufo in v2.ufos do
			if not (ufo.state == "patrol" and ufo.ray and ufo.ray.Parent) then
				continue
			end

			local ray = ufo.ray
			local position = humanoidRootPart.Position
			local pointToObjectSpace = ray.CFrame:PointToObjectSpace(position)
			local v4 = ray.Size * 0.5
			local v5

			if math.abs(pointToObjectSpace.X) <= v4.X and math.abs(pointToObjectSpace.Y) <= v4.Y then
				v5 = math.abs(pointToObjectSpace.Z) <= v4.Z
			else
				v5 = false
			end

			if not v5 then
				continue
			end

			ufo.state = "static-in"
			ufo.elapsedTime = 0
			ufo.staticCF = ufo.CF
			beginAbduction(v2, ufo, humanoid, humanoidRootPart)
			return
		end
	end
end

local function startWorld()
	if v then
		return
	end

	if buildWorld() then
		renderSteppedConnection = RunService.RenderStepped:Connect(updateFrame)
	end
end

local function stopWorld()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	teardownWorld()
end

local v2 = PartyEvent.new({
	DisplayName = "Alien",
	NeedsDuration = true,
	DefaultDurationSeconds = 600,
	MaxDurationSeconds = 1200,
	Sounds = { "rbxassetid://1835904215", "rbxassetid://132952035129361" }
})

function v2.OnStart(_, _, _, _, _)
	if v then
		return
	end

	if buildWorld() then
		renderSteppedConnection = RunService.RenderStepped:Connect(updateFrame)
	end
end

if RunService:IsClient() then
	AlienRemotes.AlienStop:connect(stopWorld)
end

return v2