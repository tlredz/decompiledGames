local createVector = vector.create
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local localPlayer = Players.LocalPlayer
local color = Color3.fromRGB(91, 255, 118)
local color2 = Color3.fromRGB(36, 140, 58)
local color3 = Color3.fromRGB(175, 220, 250)
local v = {
	CHECK_INTERVAL = 0.5,
	IDLE_SHAKE_INTERVAL = 6,
	IDLE_SHAKE_RANGE = 120,
	IDLE_SHAKE_DURATION = 1,
	IDLE_SHAKE_POSITION = 0.35,
	IDLE_SHAKE_ROTATION = 0.006108652381980153,
	HIT_SHAKE_DURATION = 0.45,
	HIT_SHAKE_POSITION = 1.1,
	HIT_SHAKE_ROTATION = 0.015707963267948967,
	REFUSE_SHAKE_DURATION = 0.25,
	REFUSE_SHAKE_POSITION = 0.35,
	REFUSE_SHAKE_ROTATION = 0.004363323129985824,
	SHAKE_FREQUENCY = 12,
	FLASH_TIME = TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
}
local _ = {
	TIME = 2.5,
	ARC = 60,
	AURA_RATE = 10
}
local _ = {
	FOV = 74,
	FADE_TIME = 0.45,
	START_BACK = 118,
	START_UP = 62,
	END_BACK = 88,
	END_UP = 44,
	LOOK_UP = 10,
	OPEN_HOLD = 0.6,
	DRIFT_TIME = 2.6,
	CLOSE_HOLD = 0.7,
	AWAKEN_WAIT = 2,
	AWAKEN_SETTLE = 0.35
}
local v2 = nil
local flag = false
local v3 = false
local flag2 = false
local children = {}
local frozenDefenseYetiDefeatedChangedConnection = nil
local children2 = {}
local v4 = {}
local v5 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function easeInOut(p: number)
	return -(math.cos(3.141592653589793 * p) - 1) / 2
end

local function lerpN(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

local function flatUnit(vector2: Vector3, vector3: Vector3)
	local vector4 = Vector3.new(vector2.X, 0, vector2.Z)

	if vector4.Magnitude > 0.001 then
		return vector4.Unit
	end

	return vector3
end

local function getCharacterRoot()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	return nil
end

local function getControls()
	local success, result = pcall(function()
		local playerScripts = localPlayer:WaitForChild("PlayerScripts", 5)
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
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return nil, nil
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FrozenDefenseTorchCinematic"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 60
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

local function panTo(vector2: Vector3, vector3: Vector3, p: number, p2: number)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local cFrame = currentCamera.CFrame
	local fieldOfView = currentCamera.FieldOfView
	local cframe = CFrame.lookAt(vector2, vector3)
	local lastTime = os.clock()

	while true do
		local v6 = math.clamp((os.clock() - lastTime) / p, 0, 1)
		local v7 = easeInOut(v6) -- equivalent call inferred; original call site unknown
		local currentCamera2 = workspace.CurrentCamera

		if not currentCamera2 then
			break
		end

		currentCamera2.CameraType = Enum.CameraType.Scriptable
		currentCamera2.CFrame = cFrame:Lerp(cframe, v7)
		currentCamera2.FieldOfView = fieldOfView + (p2 - fieldOfView) * v7

		if v6 >= 1 then
			break
		else
			RunService.RenderStepped:Wait()
		end
	end
end

local function getLocationsFolder()
	local map = workspace:FindFirstChild("Map")
	local ice = map and map:FindFirstChild("Ice")
	local bonusMoment_Locations = ice and ice:FindFirstChild("BonusMoment_Locations", true)

	if bonusMoment_Locations then
		return bonusMoment_Locations
	end

	if map then
		return map:FindFirstChild("BonusMoment_Locations", true)
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rockPresent(p: number)
	local v6 = children[p]

	if v6 then
		return v6:GetAttribute("FrozenDefenseRockPresent") ~= false
	end

	return false
end

local function sortByPosition(vector2: Vector3, vector3: Vector3)
	if math.abs(vector2.X - vector3.X) > 0.001 then
		return vector2.X < vector3.X
	end

	return vector2.Z < vector3.Z
end

local function addCrackEmitter(parent)
	if parent:FindFirstChild("CrackEmit") then
		return
	end

	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "CrackEmit"
	particleEmitter.Enabled = false
	particleEmitter.Rate = 0
	particleEmitter.Lifetime = NumberRange.new(0.4, 1)
	particleEmitter.Speed = NumberRange.new(10, 28)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Size = NumberSequence.new(2, 0)
	particleEmitter.Color = ColorSequence.new(color, color2)
	particleEmitter.LightEmission = 0.7
	particleEmitter.Brightness = 3
	particleEmitter.Acceleration = createVector(0, -30, 0)
	particleEmitter.Parent = parent
end

local function resolveTargets()
	local v6

	if #children > 0 then
		v6 = #children2 > 0
	else
		v6 = false
	end

	if v6 then
		for _, v8 in children do
			if v8:IsDescendantOf(workspace) then
				continue
			end

			v6 = false
			break
		end
	end

	if v6 then
		return true
	end

	table.clear(children)
	table.clear(children2)
	local map = workspace:FindFirstChild("Map")
	local ice = map and map:FindFirstChild("Ice")
	local bonusMoment_Locations = ice and ice:FindFirstChild("BonusMoment_Locations", true)

	if not bonusMoment_Locations then
		if map then
			bonusMoment_Locations = map:FindFirstChild("BonusMoment_Locations", true)
		else
			bonusMoment_Locations = nil
		end
	end

	if not bonusMoment_Locations then
		return false
	end

	for _, child in bonusMoment_Locations:GetChildren() do
		if child.Name == "iceRock" and child:IsA("BasePart") then
			table.insert(children, child)
		elseif child.Name == "Torch" and child:IsA("Model") then
			table.insert(children2, child)
		end
	end

	table.sort(children, function(a, b)
		local position = a.Position
		local position2 = b.Position

		if math.abs(position.X - position2.X) > 0.001 then
			return position.X < position2.X
		end

		return position.Z < position2.Z
	end)
	table.sort(children2, function(a, b)
		local position = a:GetPivot().Position
		local position2 = b:GetPivot().Position

		if math.abs(position.X - position2.X) > 0.001 then
			return position.X < position2.X
		end

		return position.Z < position2.Z
	end)

	for _, v7 in children do
		addCrackEmitter(v7)
	end

	return #children > 0
end

local function torchFlame(instance)
	local particles = instance:FindFirstChild("Particles")

	if particles and particles:IsA("BasePart") then
		return particles
	end

	return nil
end

local v6 = {}
local renderSteppedConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function stopShake(p: number)
	local v7 = v6[p]

	if not v7 then
		return
	end

	v6[p] = nil

	if v7.rock.Parent then
		v7.rock.CFrame = v7.rest
	end

	if next(v6) == nil and renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

local function stopAllShakes()
	local v7 = {}

	for k in v6 do
		table.insert(v7, k)
	end

	for _, v8 in v7 do
		stopShake(v8) -- equivalent call inferred; original call site unknown
	end
end

local function stepShakes(p: number)
	local v7 = {}

	for k, v8 in v6 do
		v8.elapsed += p

		if v8.elapsed >= v8.duration or not v8.rock.Parent then
			table.insert(v7, k)
		else
			local SHAKE_FREQUENCY = v.SHAKE_FREQUENCY
			local elapsed = v8.elapsed
			local v9 = 1 - elapsed / v8.duration
			local v10 = Vector3.new(
				math.noise(elapsed * SHAKE_FREQUENCY, 0, 0),
				math.noise(0, elapsed * SHAKE_FREQUENCY * 1.15, 0) * 0.55,
				math.noise(0, 0, elapsed * SHAKE_FREQUENCY * 0.9)
			) * v8.position * v9
			local cframe = CFrame.Angles(
				math.noise(elapsed * SHAKE_FREQUENCY * 1.2, 4, 0) * v8.rotation * v9,
				math.noise(0, elapsed * SHAKE_FREQUENCY, 8) * v8.rotation * 0.65 * v9,
				math.noise(12, 0, elapsed * SHAKE_FREQUENCY * 1.1) * v8.rotation * v9
			)
			v8.rock.CFrame = v8.rest * CFrame.new(v10) * cframe
		end
	end

	for _, v8 in v7 do
		stopShake(v8) -- equivalent call inferred; original call site unknown
	end
end

local function startShake(p: number, duration: number, position: number, rotation: number, priority: number)
	local rock = children[p]

	if rock and rock.Parent and not v4[p] then
		-- equivalent call inferred; original call site unknown
		if rockPresent(p) then
			local v8 = v6[p]

			if v8 then
				if priority < v8.priority then
					return
				end

				v8.elapsed = 0
				v8.duration = duration
				v8.position = position
				v8.rotation = rotation
				v8.priority = priority
			else
				v6[p] = {
					rock = rock,
					rest = rock.CFrame,
					elapsed = 0,
					duration = duration,
					position = position,
					rotation = rotation,
					priority = priority
				}

				if not renderSteppedConnection then
					renderSteppedConnection = RunService.RenderStepped:Connect(stepShakes)
				end
			end
		end
	end
end

local v7 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseFlash(p: number)
	local v8 = v7[p]

	if not v8 then
		return
	end

	v7[p] = nil
	v8.tween:Cancel()
	v8.highlight:Destroy()
end

local function flashRock(value: number, color4: Color3)
	local v8 = children[value]

	if not (v8 and v8.Parent) then
		return
	end

	releaseFlash(value) -- equivalent call inferred; original call site unknown
	local highlight = Instance.new("Highlight")
	highlight.Name = "RockHitFeedback"
	highlight.Adornee = v8
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = color4
	highlight.OutlineColor = color4
	highlight.FillTransparency = 0.35
	highlight.OutlineTransparency = 0
	highlight.Parent = v8
	local tween = TweenService:Create(highlight, v.FLASH_TIME, {
		FillTransparency = 1,
		OutlineTransparency = 1
	})
	v7[value] = {
		highlight = highlight,
		tween = tween
	}
	tween.Completed:Connect(function()
		local v9 = v7[value]

		if v9 and v9.tween == tween then
			releaseFlash(value) -- equivalent call inferred; original call site unknown
		end
	end)
	tween:Play()
end

local function emitBurst(position: Vector3, p: number, color4: Color3, p2: number)
	local part = Instance.new("Part")
	part.Name = "CurseBurst"
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Position = position
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Enabled = false
	particleEmitter.Rate = 0
	particleEmitter.Lifetime = NumberRange.new(0.4, 1.2)
	particleEmitter.Speed = NumberRange.new(p2 * 0.4, p2)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Size = NumberSequence.new(2.5, 0)
	particleEmitter.Color = ColorSequence.new(color4)
	particleEmitter.LightEmission = 0.8
	particleEmitter.Brightness = 4
	particleEmitter.Acceleration = createVector(0, -18, 0)
	particleEmitter.Parent = part
	part.Parent = workspace
	particleEmitter:Emit(p)
	Debris:AddItem(part, 3)
end

local function spawnIceShards(position: Vector3, p: number, Y: number, p2: number, color4: Color3?)
	for _ = 1, p2 do
		local part = Instance.new("Part")
		part.Name = "RockShard"
		part.Material = Enum.Material.Ice
		part.Color = color4 or color3
		part.Transparency = 0.1
		part.Size = Vector3.new(1 + math.random() * 3, 1 + math.random() * 3, 1 + math.random() * 3)
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		local v8 = math.random() * 2 * 3.141592653589793
		local vector2 = Vector3.new(math.cos(v8), 0, (math.sin(v8)))
		local v9 = (math.random() - 0.3) * Y * 0.5
		part.CFrame = CFrame.new(position + vector2 * p * 0.85 + createVector(0, 1, 0) * v9) * CFrame.Angles(
			math.random() * 3.141592653589793,
			math.random() * 3.141592653589793,
			math.random() * 3.141592653589793
		)
		part.Parent = workspace
		part.AssemblyLinearVelocity = vector2 * (25 + math.random() * 25) + createVector(0, 1, 0) * (18 + math.random() * 18)
		part.AssemblyAngularVelocity = Vector3.new(
			(math.random() - 0.5) * 12,
			(math.random() - 0.5) * 12,
			(math.random() - 0.5) * 12
		)
		TweenService:Create(part, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 1), {
			Transparency = 1
		}):Play()
		Debris:AddItem(part, 2)
	end
end

local function emitCracks(p: number, p2: number)
	local folder = children[p]

	if not (folder and folder.Parent) then
		return
	end

	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") and emitter.Name == "CrackEmit" then
			emitter:Emit(p2)
		end
	end
end

local function emitCurseSurge(p: number, p2: number)
	local v8 = children[p]
	local aura2

	if v8 then
		aura2 = v8:FindFirstChild("Aura2")
	end

	if not aura2 then
		return
	end

	for _, emitter in aura2:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(p2)
		end
	end
end

local function isEffect(descendant)
	return descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") or descendant:IsA("Fire") or descendant:IsA("Smoke") or descendant:IsA("Sparkles") or descendant:IsA("Light")
end

local function authoredValue(p, p2: string)
	local v8 = v5[p]

	if v8 == nil then
		v8 = p[p2]
		v5[p] = v8
	end

	return v8
end

local function setRockEffectsActive(p: number, flag3: boolean)
	local folder = children[p]

	if not folder then
		return
	end

	for _, descendant in folder:GetDescendants() do
		if descendant.Name == "CrackEmit" then
			continue
		end

		if isEffect(descendant) then
			local enabled

			if flag3 then
				enabled = v5[descendant]

				if enabled == nil then
					enabled = descendant.Enabled
					v5[descendant] = enabled
				end
			else
				enabled = flag3
			end

			descendant.Enabled = enabled
		elseif descendant:IsA("Decal") then
			local transparency

			if flag3 then
				transparency = v5[descendant]

				if transparency == nil then
					transparency = descendant.Transparency
					v5[descendant] = transparency
				end
			else
				transparency = 1
			end

			descendant.Transparency = transparency
		elseif descendant:IsA("Sound") then
			local playing

			if flag3 then
				playing = v5[descendant]

				if playing == nil then
					playing = descendant.Playing
					v5[descendant] = playing
				end
			else
				playing = flag3
			end

			descendant.Playing = playing
		end
	end
end

local function hideRock(p: number)
	local folder = children[p]

	if not folder then
		return
	end

	stopShake(p) -- equivalent call inferred; original call site unknown
	releaseFlash(p) -- equivalent call inferred; original call site unknown
	setRockEffectsActive(p, false)
	folder.LocalTransparencyModifier = 1
	folder.CanCollide = false

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.LocalTransparencyModifier = 1
		part.CanCollide = false
	end
end

local function setTorchLit(p: number, enabled: boolean)
	local v8 = children2[p]

	if not (v8 and v8.Parent) then
		return
	end

	local particles = v8:FindFirstChild("Particles")

	if not (particles and particles:IsA("BasePart")) then
		particles = nil
	end

	for _, descendant in (particles or v8):GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = enabled
		elseif descendant:IsA("Light") then
			descendant.Enabled = enabled
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function extinguishTorches()
	for i = 1, #children2 do
		setTorchLit(i, false)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bossDefeated()
	return localPlayer:GetAttribute("FrozenDefenseYetiDefeated") == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function watchBossDefeat()
	if frozenDefenseYetiDefeatedChangedConnection then
		return
	end

	frozenDefenseYetiDefeatedChangedConnection = localPlayer:GetAttributeChangedSignal("FrozenDefenseYetiDefeated"):Connect(function()
		if bossDefeated() then
			extinguishTorches() -- equivalent call inferred; original call site unknown
		end
	end)

	if bossDefeated() then
		extinguishTorches() -- equivalent call inferred; original call site unknown
	end
end

local function lightTorch(p: number, flag3: boolean)
	local v8 = children2[p]

	if not (v8 and v8.Parent) or localPlayer:GetAttribute("FrozenDefenseYetiDefeated") == true then
		return
	end

	setTorchLit(p, true)
	local particles = v8:FindFirstChild("Particles")

	if not (particles and particles:IsA("BasePart")) then
		particles = nil
	end

	if not (flag3 and particles) then
		return
	end

	for _, emitter in particles:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(25)
		end
	end

	emitBurst(particles.Position, 60, color, 30)
	Sound:Play("IcebergExplosion", particles.Position, nil, 1.5, 0.35)
end

local function moveCloud(clone, position: Vector3, position2: Vector3, p: number, p2: number)
	local lastTime = os.clock()

	while true do
		local v8 = math.clamp((os.clock() - lastTime) / p2, 0, 1)
		local v9 = easeInOut(v8) -- equivalent call inferred; original call site unknown

		if not clone.Parent then
			break
		end

		clone.Position = position:Lerp(position2, v9) + createVector(0, 1, 0) * (p * math.sin(v9 * 3.141592653589793))

		if v8 >= 1 then
			break
		else
			RunService.RenderStepped:Wait()
		end
	end
end

local function sendCurseToTorch(p: number)
	local v8 = children[p]
	local v9 = children2[p]
	local aura2

	if v8 then
		aura2 = v8:FindFirstChild("Aura2")
	end

	local particles

	if v9 then
		particles = v9:FindFirstChild("Particles")

		if not (particles and particles:IsA("BasePart")) then
			particles = nil
		end
	end

	if not (particles and aura2 and aura2:IsA("BasePart")) then
		lightTorch(p, true)
		return
	end

	local clone = aura2:Clone()
	clone.Name = "ReleasedCurse"
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone.CastShadow = false
	clone.Transparency = 1
	clone.LocalTransparencyModifier = 0
	clone.Position = aura2.Position

	for _, emitter in clone:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true

		if emitter.Name == "Aura" then
			emitter.Rate = 10
		end
	end

	clone.Parent = workspace
	moveCloud(clone, aura2.Position, particles.Position, 60, 2.5)

	for _, emitter in clone:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	Debris:AddItem(clone, 3)
	lightTorch(p, true)
end

local function shatterRock(p: number, flag3: boolean)
	if v4[p] then
		return
	end

	v4[p] = true
	local v8 = children[p]

	if v8 and flag3 then
		local v9 = math.max(v8.Size.X, v8.Size.Z) * 0.5
		Sound:Play("IcebergExplosion", v8.Position, nil, 0.9, 1)
		emitCracks(p, 90)
		emitCurseSurge(p, 8)
		spawnIceShards(v8.Position, v9, v8.Size.Y, 26, color)
		emitBurst(v8.Position, 160, color, 95)
	end

	if flag3 then
		task.spawn(sendCurseToTorch, p)
		task.delay(0.15, hideRock, p)
	else
		hideRock(p)
		local v9 = children2[p]

		if v9 and v9.Parent then
			if bossDefeated() then
				return
			end

			setTorchLit(p, true)
			local particles = v9:FindFirstChild("Particles")

			if particles and particles:IsA("BasePart") then
				return
			end
		end
	end
end

local function waitForAwakening()
	local total = 0

	while not flag2 and total < 2 do
		total += RunService.Heartbeat:Wait()
	end

	if flag2 then
		task.wait(0.35)
	end
end

local function torchCentroid()
	local v8 = createVector(0, 0, 0)
	local count = 0

	for _, v9 in children2 do
		local particles = v9:FindFirstChild("Particles")

		if not (particles and particles:IsA("BasePart")) then
			particles = nil
		end

		if not particles then
			continue
		end

		v8 += particles.Position
		count += 1
	end

	if count > 0 then
		return v8 / count
	end

	return createVector(0, 0, 0)
end

local function runTorchCutscene(vector2: Vector3?)
	for i = 1, #children2 do
		local v8 = children2[i]

		if not (v8 and v8.Parent and localPlayer:GetAttribute("FrozenDefenseYetiDefeated") ~= true) then
			continue
		end

		setTorchLit(i, true)
		local particles = v8:FindFirstChild("Particles")

		if particles and particles:IsA("BasePart") then
		end
	end

	local v8 = torchCentroid()
	local v9 = vector2 or v8

	if v8.Magnitude < 0.001 then
		v8 = v9
	end

	if v8.Magnitude < 0.001 then
		v3 = false
		return
	end

	local success, result = pcall(function()
		local playerScripts = localPlayer:WaitForChild("PlayerScripts", 5)
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

	local currentCamera = workspace.CurrentCamera
	local fieldOfView = not currentCamera and 74 or currentCamera.FieldOfView
	local cameraType

	if currentCamera then
		cameraType = currentCamera.CameraType
	else
		cameraType = Enum.CameraType.Custom
	end

	local fade2, v11 = makeFade()
	local success2, result2 = pcall(function()
		if result then
			pcall(function()
				result:Disable()
			end)
		end

		local v12 = v9 - v8
		local vector3 = Vector3.new(v12.X, 0, v12.Z)
		local v13 = not (vector3.Magnitude > 0.001) and createVector(0, 0, 1) or vector3.Unit
		local v14 = v8:Lerp(v9, 0.5) + createVector(0, 10, 0)
		local v15 = v14 + v13 * 118 + createVector(0, 62, 0)
		local v16 = v14 + v13 * 88 + createVector(0, 44, 0)
		fade(fade2, 0, 0.45)
		local currentCamera2 = workspace.CurrentCamera

		if currentCamera2 then
			currentCamera2.CameraType = Enum.CameraType.Scriptable
			currentCamera2.FieldOfView = 74
			currentCamera2.CFrame = CFrame.lookAt(v15, v14)
		end

		fade(fade2, 1, 0.45)
		task.wait(0.6)
		panTo(v16, v14, 2.6, 74)
		task.wait(0.7)
		fade(fade2, 0, 0.45)
	end)

	if not success2 then
		warn("[Frozen Defense] torch cutscene error:", result2)
	end

	local currentCamera2 = workspace.CurrentCamera

	if currentCamera2 then
		currentCamera2.FieldOfView = fieldOfView

		if cameraType == Enum.CameraType.Scriptable then
			cameraType = Enum.CameraType.Custom
		end

		currentCamera2.CameraType = cameraType
	end

	if result then
		pcall(function()
			result:Enable()
		end)
	end

	waitForAwakening()
	fade(fade2, 1, 0.45)

	if v11 then
		v11:Destroy()
	end

	v3 = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function watchRocks(p)
	local total = 0
	local total2 = 0
	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt

		if total < v.CHECK_INTERVAL then
			return
		end

		total = 0
		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			humanoidRootPart = nil
		end

		if not humanoidRootPart then
			return
		end

		local v8 = 1e999
		local v9 = nil

		for k, v10 in children do
			if v4[k] then
				continue
			end

			-- equivalent call inferred; original call site unknown
			if not rockPresent(k) then
				continue
			end

			local magnitude = (humanoidRootPart.Position - v10.Position).Magnitude

			if not (magnitude < v8) then
				continue
			end

			v9 = k
			v8 = magnitude
		end

		if not v9 then
			return
		end

		local v10 = children[v9]
		total2 += v.CHECK_INTERVAL

		if total2 >= v.IDLE_SHAKE_INTERVAL and v8 <= v.IDLE_SHAKE_RANGE then
			total2 = 0
			startShake(v9, v.IDLE_SHAKE_DURATION, v.IDLE_SHAKE_POSITION, v.IDLE_SHAKE_ROTATION, 1)
			emitCracks(v9, 4)
			Sound:Play("IceShoot", v10.Position, nil, 0.5, 0.2)
		end
	end)
	p.Trove:Add(heartbeatConnection)
	p.Trove:Add(stopAllShakes)
end

local function watchPresence(p)
	for k, v8 in children do
		local v9 = k
		p.Trove:Add(v8:GetAttributeChangedSignal("FrozenDefenseRockPresent"):Connect(function()
			-- equivalent call inferred; original call site unknown
			if rockPresent(v9) then
				if v4[v9] then
					task.defer(hideRock, v9)
				else
					task.defer(setRockEffectsActive, v9, true)
				end
			else
				stopShake(v9) -- equivalent call inferred; original call site unknown
				releaseFlash(v9) -- equivalent call inferred; original call site unknown
				setRockEffectsActive(v9, false)
			end
		end))
	end
end

return {
	DataName = script.Name,
	OnLoad = function(object)
		v2 = object
		flag = false
		flag2 = false
		table.clear(v4)
		object:FireServer("Init")
		task.delay(4, function()
			if v2 == object and not (object.Completed or flag) then
				object:FireServer("Init")
			end
		end)
	end,
	RemoteEvents = {
		Setup = function(p, list)
			if flag then
				return
			end

			flag = true

			if resolveTargets() then
				watchBossDefeat() -- equivalent call inferred; original call site unknown

				if type(list) == "table" then
					for i = 1, #children do
						if list[i] == true then
							shatterRock(i, false)
						end
					end
				end

				for i = 1, #children do
					if v4[i] then
						continue
					end

					local v9 = rockPresent(i) -- equivalent call inferred; original call site unknown
					setRockEffectsActive(i, v9)
				end

				watchRocks(p) -- equivalent call inferred; original call site unknown
				watchPresence(p)
			end
		end,
		RockHit = function(_, value, value2, value3)
			if typeof(value) ~= "number" or v4[value] then
				return
			end

			local v8 = children[value]

			if not v8 then
				return
			end

			local v9 = (typeof(value2) ~= "number" or typeof(value3) ~= "number" or not (value3 > 0)) and 0.5 or value2 / value3
			Sound:Play("IceShoot", v8.Position, nil, 0.9 + 0.4 * v9, 0.55)
			emitCracks(value, math.floor(v9 * 20) + 8)
			flashRock(value, color)
			startShake(value, v.HIT_SHAKE_DURATION, v.HIT_SHAKE_POSITION, v.HIT_SHAKE_ROTATION, 3)
			spawnIceShards(v8.Position, math.max(v8.Size.X, v8.Size.Z) * 0.5, v8.Size.Y, 6, color)
		end,
		RockRefused = function(_, value)
			if typeof(value) ~= "number" or v4[value] then
				return
			end

			local v8 = children[value]

			if not v8 then
				return
			end

			Sound:Play("IceShoot", v8.Position, nil, 0.5, 0.35)
			startShake(value, v.REFUSE_SHAKE_DURATION, v.REFUSE_SHAKE_POSITION, v.REFUSE_SHAKE_ROTATION, 2)
			flashRock(value, Color3.fromRGB(150, 190, 215))
		end,
		RockDestroyed = function(_, value)
			if typeof(value) ~= "number" then
				return
			end

			shatterRock(value, true)
		end,
		RocksRestored = function(_)
			table.clear(v4)

			for i = 1, #children do
				local folder = children[i]

				if folder then
					stopShake(i) -- equivalent call inferred; original call site unknown
					releaseFlash(i) -- equivalent call inferred; original call site unknown
					folder.LocalTransparencyModifier = 0

					for _, part in folder:GetDescendants() do
						if part:IsA("BasePart") then
							part.LocalTransparencyModifier = 0
						end
					end

					local v9 = rockPresent(i) -- equivalent call inferred; original call site unknown
					setRockEffectsActive(i, v9)
				end

				setTorchLit(i, false)
			end
		end,
		TorchesLit = function(p, p2)
			if v2 ~= p or v3 then
				return
			end

			v3 = true

			if typeof(p2) ~= "Vector3" then
				p2 = nil
			end

			task.spawn(runTorchCutscene, p2)
		end,
		BossAwakening = function(p)
			if v2 ~= p then
				return
			end

			flag2 = true
		end
	}
}