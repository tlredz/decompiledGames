local createVector = vector.create
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Audio = require(ReplicatedStorage.Shared.Audio)
local EggEnergyOrbField = require(ReplicatedStorage.Shared.Eggs.EggEnergyOrbField)
local Flash = require(ReplicatedStorage.Client.UI.VFX.Flash)
local Shake = require(ReplicatedStorage.Client.Shake)
local Trove = require(ReplicatedStorage.Packages.Trove)
local VFX = require(ReplicatedStorage.Shared.Utils.VFX)
local particles = ReplicatedStorage.Assets.Particles
local eggs = ReplicatedStorage.Assets.Models.Eggs
local riftTradeIn = ReplicatedStorage.Assets.VFX.RiftTradeIn
local v = {
	Light = Color3.fromRGB(255, 209, 74),
	Dark = Color3.fromRGB(168, 26, 22)
}
local v2 = {
	Light = { Color3.fromRGB(255, 250, 214), Color3.fromRGB(255, 198, 44) },
	Dark = { Color3.fromRGB(196, 40, 30), Color3.fromRGB(84, 6, 12) }
}
local color = Color3.new(1, 1, 1)
local v3 = {}
local random = Random.new()
local v4 = nil

local function fuseTrack(p)
	local success, result = pcall(Audio.Play, "rbxassetid://77717392679794", p.Center, {
		Volume = 1
	})

	if not success or typeof(result) ~= "Instance" then
		return
	end

	p.Trove:Add(function()
		result:Stop()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function debris()
	return Workspace:FindFirstChild("Transient") or Workspace
end

local function bezier(vector2: Vector3, vector3: Vector3, vector4: Vector3, p: number)
	local v5 = 1 - p
	return vector2 * (v5 * v5) + vector3 * (v5 * 2 * p) + vector4 * (p * p)
end

local function lerp(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

local function backOut(p: number)
	local v5 = p - 1
	return v5 * 2.70158 * v5 * v5 + 1 + v5 * 1.70158 * v5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function quadIn(p: number)
	return TweenService:GetValue(p, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function quadInOut(p: number)
	return TweenService:GetValue(p, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cubicIn(p: number)
	return TweenService:GetValue(p, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)
end

local function freeze(folder)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Massless = true
		part.LocalTransparencyModifier = 0
	end
end

local function detach(folder)
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") or descendant:IsA("NoCollisionConstraint") or descendant:IsA("Constraint") then
			descendant:Destroy()
		elseif descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") then
			descendant.Enabled = false
		elseif descendant:IsA("ProximityPrompt") then
			descendant.Enabled = false
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function normalizeProp(clone, p: number)
	clone.PrimaryPart = nil
	local boundingBox, v5 = clone:GetBoundingBox()
	clone.WorldPivot = boundingBox
	local v6 = math.max(v5.X, v5.Y, v5.Z)

	if v6 > 0.01 then
		clone:ScaleTo((math.clamp(clone:GetScale() * (p / v6), 0.01, 50)))
	end
end

local object = setmetatable({}, {
	__mode = "k"
})
local object2 = setmetatable({}, {
	__mode = "k"
})
local object3 = setmetatable({}, {
	__mode = "k"
})
local object4 = setmetatable({}, {
	__mode = "k"
})

local function switchable(instance)
	return instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") or instance:IsA("Light") or instance:IsA("Highlight") or instance:IsA("Fire") or instance:IsA("Smoke") or instance:IsA("Sparkles")
end

local function hideItem(descendant)
	if descendant:IsA("BasePart") then
		object4[descendant] = true
		descendant.LocalTransparencyModifier = 1
	elseif descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") then
		if object[descendant] == nil then
			object[descendant] = descendant.Enabled
		end

		descendant.Enabled = false
	elseif descendant:IsA("Decal") then
		if object3[descendant] == nil then
			object3[descendant] = descendant.Transparency
		end

		descendant.Transparency = 1
	elseif switchable(descendant) then
		if object2[descendant] == nil then
			object2[descendant] = descendant.Enabled
		end

		descendant.Enabled = false

		if descendant:IsA("ParticleEmitter") then
			descendant:Clear()
		end
	end
end

local function showItem(descendant)
	if descendant:IsA("BasePart") then
		object4[descendant] = nil
		descendant.LocalTransparencyModifier = 0
	elseif descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") then
		local v5 = object[descendant]
		descendant.Enabled = v5 == nil or v5
		object[descendant] = nil
	elseif descendant:IsA("Decal") then
		local v5 = object3[descendant]
		descendant.Transparency = v5 == nil and 0 or v5
		object3[descendant] = nil
	elseif switchable(descendant) then
		local v5 = object2[descendant]
		descendant.Enabled = v5 == nil or v5
		object2[descendant] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setToolVisibility(folder, flag: boolean)
	if not folder then
		return
	end

	for _, descendant in folder:GetDescendants() do
		if flag then
			hideItem(descendant)
		else
			showItem(descendant)
		end
	end
end

local function eggTemplate(p: string?, p2: string)
	local v5 = p or "Fused " .. p2
	local model = eggs:FindFirstChild(v5)

	if model and model:IsA("Model") then
		return model
	end

	warn("[ShrineFusionSequence] missing fused egg model:", v5)
	return nil
end

local function fallbackProp(color2: Color3)
	local model = Instance.new("Model")
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Material = Enum.Material.Neon
	part.Color = color2
	part.Size = createVector(2.6, 2.6, 2.6)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Parent = model
	model.WorldPivot = part.CFrame
	return model
end

local function tintEmitters(folder, color2: Color3, color3: Color3)
	local colorSequence = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color2),
		ColorSequenceKeypoint.new(0.4, color2:Lerp(color3, 0.65)),
		ColorSequenceKeypoint.new(1, color3)
	})

	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
			continue
		end

		effect.Color = colorSequence
	end
end

local function chargeHost(color2: Color3)
	local assetAnimation = particles:FindFirstChild("AssetAnimation")
	local part

	if assetAnimation then
		part = assetAnimation:FindFirstChild("Part")
	end

	local parent

	if part and part:IsA("BasePart") then
		parent = part:Clone()

		for _, emitter in parent:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Color = ColorSequence.new(color2)
			end
		end
	else
		parent = Instance.new("Part")
		parent.Size = createVector(0.1, 0.1, 0.1)
		parent.Transparency = 1
	end

	parent.Anchored = true
	parent.CanCollide = false
	parent.CanQuery = false
	parent.CanTouch = false
	parent.CastShadow = false
	local selected = parent:FindFirstChild("Enable")

	if not selected then
		selected = Instance.new("Attachment")
		selected.Name = "Enable"
		selected.Parent = parent
	end

	local emit = parent:FindFirstChild("Emit")

	if emit and emit:IsA("Attachment") then
		return parent, selected, emit
	end

	return parent, selected, nil
end

local function rootOf(instance)
	if not instance then
		return nil
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	return nil
end

local function orbitOffset(p, p2: number, p3: number, p4: number)
	local v5 = (p.PlaneU * math.cos(p2) + p.PlaneV * math.sin(p2)) * p3

	if p4 > 0.001 then
		return CFrame.fromAxisAngle(p.PlaneU, p4) * v5
	end

	return v5
end

local function hideNewTools(p, data, tool)
	if not tool:IsA("Tool") or tool == data.Tool or data.Arrived or data.NewTools[tool] then
		return
	end

	setToolVisibility(tool, true) -- equivalent call inferred; original call site unknown
	local descendantAddedConnection = tool.DescendantAdded:Connect(function(descendant)
		if not data.Arrived then
			hideItem(descendant)
		end
	end)
	data.NewTools[tool] = descendantAddedConnection
	p.Trove:Add(descendantAddedConnection)
end

local function sweepTools(state, player)
	local character = player.Character

	if not character or player.Arrived then
		return
	end

	for _, child in character:GetChildren() do
		hideNewTools(state, player, child)
	end

	setToolVisibility(player.Tool, true) -- equivalent call inferred; original call site unknown
end

local function buildSide(data, name: string, instance)
	local character

	if Players.LocalPlayer then
		character = Players.LocalPlayer.Character
	end

	local v5 = {
		Name = name,
		Character = instance,
		Color = v[name],
		Arrived = false,
		NewTools = {},
		Mine = 0
	}
	local mine

	if instance == nil then
		mine = false
	else
		mine = instance == character or instance == data.TrackCharacter
	end

	v5.Mine = mine
	local pad = data.Pads[name]
	local model = nil

	if instance then
		local tool = instance:FindFirstChildOfClass("Tool")

		if tool then
			v5.Tool = tool
			model = tool:FindFirstChildOfClass("Model")
			v5.ToolWatch = tool.DescendantAdded:Connect(function(descendant)
				if not data.Dead then
					hideItem(descendant)
				end
			end)
			data.Trove:Add(v5.ToolWatch)
		end

		data.Trove:Connect(instance.ChildAdded, function(p2)
			hideNewTools(data, v5, p2)
		end)
	end

	local pivot, clone

	if model then
		pivot = model:GetPivot()
		clone = model:Clone()
	else
		pivot = pad.CFrame * CFrame.new(0, 3, 0)
		local fusedCategory = data.FusedCategory
		local tier = data.Tier
		local v7 = fusedCategory or "Fused " .. tier
		local model2 = eggs:FindFirstChild(v7)

		if not (model2 and model2:IsA("Model")) then
			warn("[ShrineFusionSequence] missing fused egg model:", v7)
			model2 = nil
		end

		if model2 then
			clone = model2:Clone()
		else
			clone = fallbackProp(v5.Color)
		end
	end

	detach(clone)
	freeze(clone)
	normalizeProp(clone, 6.2) -- equivalent call inferred; original call site unknown
	clone:PivotTo(pivot)
	clone.Parent = data.Container
	v5.Prop = clone
	v5.Origin = pivot.Position
	setToolVisibility(v5.Tool, true) -- equivalent call inferred; original call site unknown
	local v7, v8, hostEmit = chargeHost(v5.Color)
	v7.CFrame = CFrame.new(pivot.Position)
	v7.Parent = data.Container
	v5.Host = v7
	v5.HostEnable = v8
	v5.HostEmit = hostEmit
	local attachment = Instance.new("Attachment")
	attachment.Position = createVector(0, 3.1, 0)
	attachment.Parent = v7
	local attachment2 = Instance.new("Attachment")
	attachment2.Position = createVector(0, -3.1, 0)
	attachment2.Parent = v7
	local trail = Instance.new("Trail")
	trail.Attachment0 = attachment
	trail.Attachment1 = attachment2
	trail.Color = ColorSequence.new(v5.Color)
	trail.Transparency = NumberSequence.new(0.25, 1)
	trail.WidthScale = NumberSequence.new(1, 0)
	trail.Lifetime = 0.35
	trail.LightEmission = 1
	trail.LightInfluence = 0
	trail.FaceCamera = true
	trail.MinLength = 0
	trail.Parent = v7
	v5.Trail = trail
	local beam = Instance.new("Beam")
	beam.Attachment0 = v8
	beam.Attachment1 = data.CoreAttachment
	beam.Color = ColorSequence.new(v5.Color, color)
	beam.Transparency = NumberSequence.new(0.5)
	beam.Width0 = 0.05
	beam.Width1 = 0.25
	beam.LightEmission = 1
	beam.LightInfluence = 0
	beam.FaceCamera = true
	beam.Segments = 12
	beam.Parent = v7
	v5.Beam = beam
	v5.BeamSign = name == "Light" and 1 or -1
	local field = EggEnergyOrbField.new(data.Container, v5.Color)
	data.Trove:Add(field)
	v5.Field = field
	v5.Theta = name == "Light" and 0 or 3.141592653589793
	v5.Roll = random:NextNumber(0, 6.283185307179586)
	v5.BobPhase = name == "Light" and 0 or 2.199114857512855
	return v5
end

local function revealSide(state)
	state.Arrived = true

	if state.ToolWatch then
		state.ToolWatch:Disconnect()
	end

	setToolVisibility(state.Tool, false) -- equivalent call inferred; original call site unknown

	for k, newTool in state.NewTools do
		newTool:Disconnect()
		setToolVisibility(k, false) -- equivalent call inferred; original call site unknown
	end

	table.clear(state.NewTools)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function finish(state)
	if v4 ~= state then
		return
	end

	v4 = nil
	state.Dead = true
	revealSide(state.Sides.Light)
	revealSide(state.Sides.Dark)
	state.Trove:Clean()
end

local function propPivot(state, side, vector2: Vector3, p: number)
	local v5 = CFrame.lookAt(vector2, (Vector3.new(state.Center.X, vector2.Y, state.Center.Z))) * CFrame.Angles(
		side.Roll,
		0,
		0
	)

	if p > 0.001 then
		return v5 * CFrame.new(
			random:NextNumber(-1, 1) * 0.5 * p,
			random:NextNumber(-1, 1) * 0.5 * p,
			random:NextNumber(-1, 1) * 0.5 * p
		) * CFrame.Angles(math.rad(random:NextNumber(-1, 1) * 22 * p), 0, (math.rad(random:NextNumber(-1, 1) * 22 * p)))
	end

	return v5
end

local function pushImpulse(state, power: number)
	local impulses = state.Impulses

	if not impulses then
		return
	end

	local impulseSlot = state.ImpulseSlot or 1
	local impuls = impulses[impulseSlot]

	if not impuls then
		impuls = {}
		impulses[impulseSlot] = impuls
	end

	impuls.At = os.clock()
	impuls.Life = 0.34 * random:NextNumber(0.8, 1.3)
	impuls.Power = power
	impuls.Dir = Vector3.new(random:NextNumber(-1, 1), random:NextNumber(-1, 1), random:NextNumber(-0.4, 0.4))
	impuls.Spin = Vector3.new(random:NextNumber(-1, 1), random:NextNumber(-1, 1), random:NextNumber(-1, 1))
	state.ImpulseSlot = impulseSlot % 8 + 1
end

local function stepSession(state, p: number)
	if state.Dead or state.Resolving then
		state.CamPunch = math.max((state.CamPunch or 0) - p * 3, 0)
		state.CamRumble = math.max((state.CamRumble or 0) - p * 2, 0)
	else
		if not state.Shrine:IsDescendantOf(Workspace) then
			v3.Cancel()
			return
		end

		local serverTimeNow = Workspace:GetServerTimeNow()

		if state.EndsAt + 6 < serverTimeNow then
			v3.Cancel()
			return
		end

		local now = os.clock()
		local v5 = math.max(state.EndsAt - state.StartAt, 0.5)
		local v6 = math.clamp((serverTimeNow - state.StartAt) / v5, 0, 1)
		local v7 = math.clamp((serverTimeNow - state.StartAt) / state.LiftSeconds, 0, 1)
		local v8 = state.EndsAt - state.ShakeLead
		local v9 = math.clamp(
			(serverTimeNow - state.StartAt - state.LiftSeconds) / math.max(v8 - state.StartAt - state.LiftSeconds, 0.1),
			0,
			1
		)
		local v10 = math.clamp((serverTimeNow - v8) / state.ShakeLead, 0, 1)
		local shakeIntensity = cubicIn(v10) -- equivalent call inferred; original call site unknown
		state.ShakeIntensity = shakeIntensity
		state.CamRumble = v7 * (TweenService:GetValue(v9, Enum.EasingStyle.Cubic, Enum.EasingDirection.In) * 0.42000000000000004 + 0.04)

		if shakeIntensity > 0.02 then
			if (state.NextImpulse or 0) <= now then
				pushImpulse(state, shakeIntensity * 0.75 + 0.3)
				state.NextImpulse = now + (shakeIntensity * -0.265 + 0.34) * random:NextNumber(0.75, 1.3)
			end
		else
			state.NextImpulse = now
		end

		local v12 = quadIn(v9) -- equivalent call inferred; original call site unknown
		local v13 = v12 * 6.8 + 1.7
		state.Theta += v13 * p
		local v14 = v12 * -3.3 + 5.6

		if v10 > 0 then
			local value = TweenService:GetValue(
				math.min(v10 / 0.35, 1),
				Enum.EasingStyle.Quart,
				Enum.EasingDirection.In
			)
			v14 += (1.2 - v14) * value
		end

		local v15 = v12 * 0.24434609527920614
		local v17 = TweenService:GetValue(math.max(v9, v10), Enum.EasingStyle.Quad, Enum.EasingDirection.In) * 5.4 + 1.1

		if v10 > 0.12 and not state.Absorbing then
			state.Absorbing = true

			if not state.Participant then
				Shake.Play({
					Seconds = state.ShakeLead + 0.8,
					Magnitude = 0.8,
					Range = {
						Center = state.Center,
						Near = 24,
						Far = 90
					}
				})
			end

			for _, v18 in { "Light", "Dark" } do
				local v19 = state.Sides[v18].Field
				task.spawn(function()
					pcall(function()
						v19:Absorb(state.Center, state.ShakeLead * 0.8)
					end)
				end)
			end
		end

		for _, v18 in { "Light", "Dark" } do
			local side = state.Sides[v18]
			local v19 = state.Theta + (v18 == "Light" and 0 or 3.141592653589793)
			local v20 = math.sin(now * 2.6 + side.BobPhase) * 0.55 * (1 - v9 * 0.6) * (1 - v10)
			local center = state.Center
			local v21 = (state.PlaneU * math.cos(v19) + state.PlaneV * math.sin(v19)) * v14

			if v15 > 0.001 then
				v21 = CFrame.fromAxisAngle(state.PlaneU, v15) * v21
			end

			local v22 = center + v21 + Vector3.new(0, v20, 0)

			if v7 < 1 then
				local v23 = quadInOut(v7) -- equivalent call inferred; original call site unknown
				local origin = side.Origin
				local v24 = side.Origin + createVector(0, 3.2, 0)
				local v25 = 1 - v23
				v22 = origin * (v25 * v25) + v24 * (v25 * 2 * v23) + v22 * (v23 * v23)
			end

			side.Roll += v17 * p
			local pivot = propPivot(state, side, v22, shakeIntensity)
			side.Pivot = pivot

			if side.Prop.Parent then
				side.Prop:PivotTo(pivot)
			end

			side.Host.CFrame = CFrame.new(v22)
			side.Beam.Width0 = v6 * 0.3 + 0.05
			side.Beam.Width1 = v6 * 0.6000000000000001 + 0.2
			side.Beam.CurveSize0 = math.sin(now * 1.9 + side.BobPhase) * 3 * side.BeamSign
			side.Beam.CurveSize1 = math.cos(now * 1.6 + side.BobPhase) * 3 * -side.BeamSign

			if not state.Absorbing then
				side.Field:Step(v22, v6, p)
			end
		end

		local v18 = math.sin(now * (v6 * 10 + 6)) * 0.07 + 1
		local v19 = (TweenService:GetValue(v6, Enum.EasingStyle.Quad, Enum.EasingDirection.In) * 0.95 + 0.55) * v18 + shakeIntensity * 0.4
		state.Core.Size = createVector(1, 1, 1) * v19
		state.Core.CFrame = CFrame.new(state.Center)
		local lerped = v.Light:Lerp(v.Dark, math.sin(now * 3) * 0.5 + 0.5)
		state.Core.Color = lerped:Lerp(color, v6 * 0.14 + shakeIntensity * 0.3)
	end
end

local function flight(state, player)
	local prop = player.Prop

	if not (prop and prop.Parent) then
		revealSide(player)
		return
	end

	player.Trail.Enabled = true
	local position = prop:GetPivot().Position
	local scale = prop:GetScale()
	local eggScale = player.EggScale or scale
	local total = 0

	while total < 1.15 do
		total += RunService.RenderStepped:Wait()

		if state.Dead or not prop.Parent then
			break
		end

		local v5 = math.min(total / 1.15, 1)
		local v6 = v5 * v5
		local character = player.Character
		local humanoidRootPart

		if character then
			humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				humanoidRootPart = nil
			end
		end

		local v7

		if humanoidRootPart then
			v7 = humanoidRootPart.Position + createVector(0, 1.5, 0)
		else
			v7 = position
		end

		local v8 = (position + v7) * 0.5
		local magnitude = ((position - v7) * createVector(1, 0, 1)).Magnitude
		local vector2 = Vector3.new(v8.X, math.max(position.Y, v7.Y) + magnitude * 0.5 + 2.5, v8.Z)
		local v9 = 1 - v6
		local flightAt = position * (v9 * v9) + vector2 * (v9 * 2 * v6) + v7 * (v6 * v6)
		local vector3 = Vector3.new(v7.X, flightAt.Y, v7.Z)
		local v11

		if (flightAt - vector3).Magnitude < 0.001 then
			v11 = CFrame.new(flightAt)
		else
			v11 = CFrame.lookAt(flightAt, vector3)
		end

		prop:PivotTo(v11 * CFrame.Angles(v6 * 2 * 3.141592653589793 * 2, 0, 0))
		player.Host.CFrame = CFrame.new(flightAt)
		player.FlightAt = flightAt
		local v12 = math.min(v5 / 0.22, 1) - 1
		local v13 = v12 * 2.70158 * v12 * v12 + 1 + v12 * 1.70158 * v12
		local v14 = scale + (eggScale - scale) * v13
		local v15 = math.clamp((v5 - 0.55) / 0.45, 0, 1)
		prop:ScaleTo((math.max(v14 * (1 - v15 * v15 * v15), 0.01)))
	end

	player.Trail.Enabled = false
	player.FlightAt = nil
	revealSide(player)

	if state.Dead then
		return
	end

	local character = player.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			humanoidRootPart = nil
		end
	end

	if humanoidRootPart then
		position = humanoidRootPart.Position + createVector(0, 1, 0)
	end

	local aura = riftTradeIn:FindFirstChild("Aura")

	if aura and aura:IsA("Model") then
		local clone = aura:Clone()
		freeze(clone)
		clone:PivotTo(CFrame.new(position))
		local v5 = v2[player.Name] or v2.Light
		tintEmitters(clone, v5[1], v5[2])
		clone.Parent = state.Container.Parent

		for _, part in clone:GetDescendants() do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 1
			end
		end

		VFX.EmitTree(clone, true)
		VFX.Discard(clone, 2.5)
	end

	if prop.Parent then
		prop:Destroy()
	end
end

local function resolvePayoff(state, callback)
	sweepTools(state, state.Sides.Light)
	sweepTools(state, state.Sides.Dark)
	local pivots = {}

	for _, v5 in { "Light", "Dark" } do
		local side = state.Sides[v5]
		local pivot

		if side.Pivot then
			pivot = side.Pivot
		else
			local center = state.Center
			local v6 = v5 == "Light" and 0 or 3.141592653589793
			pivot = CFrame.new(center + (state.PlaneU * math.cos(v6) + state.PlaneV * math.sin(v6)) * 1.2)
		end

		pivots[v5] = pivot
	end

	if state.Participant then
		pcall(Flash.Play, {
			Attack = 0.06,
			Decay = 0.22
		})
	end

	state.CamPunch = 1
	pushImpulse(state, 1.4)
	pushImpulse(state, 1)
	task.delay(0.08, pushImpulse, state, 1.15)
	task.delay(0.19, pushImpulse, state, 0.8)
	task.delay(0.33, pushImpulse, state, 0.55)
	task.delay(0.52, pushImpulse, state, 0.35)

	if not state.Participant then
		Shake.Play({
			Seconds = 0.7,
			Magnitude = 1,
			Range = {
				Center = state.Center,
				Near = 24,
				Far = 90
			}
		})
	end

	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Size = createVector(2, 2, 2)
	part.Transparency = 0.45
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CFrame = CFrame.new(state.Center)
	part.Parent = state.Container.Parent
	TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = createVector(13, 13, 13),
		Transparency = 1
	}):Play()
	VFX.Discard(part, 0.7)
	local part2 = Instance.new("Part")
	part2.Shape = Enum.PartType.Cylinder
	part2.Material = Enum.Material.Neon
	part2.Color = color
	part2.Size = createVector(36, 4.2, 4.2)
	part2.Transparency = 0.3
	part2.Anchored = true
	part2.CanCollide = false
	part2.CanQuery = false
	part2.CanTouch = false
	part2.CastShadow = false
	part2.CFrame = CFrame.new(state.Center) * CFrame.Angles(0, 0, 1.5707963267948966)
	part2.Parent = state.Container.Parent
	TweenService:Create(part2, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = createVector(36, 0.3, 0.3),
		Transparency = 1
	}):Play()
	VFX.Discard(part2, 0.75)
	local bigHitGroundAttach = particles:FindFirstChild("BigHitGroundAttach")

	if bigHitGroundAttach then
		local part3 = Instance.new("Part")
		part3.Size = createVector(0.1, 0.1, 0.1)
		part3.Transparency = 1
		part3.Anchored = true
		part3.CanCollide = false
		part3.CanQuery = false
		part3.CanTouch = false
		part3.CFrame = CFrame.new(state.Center.X, state.GroundY, state.Center.Z)
		part3.Parent = state.Container.Parent
		local clone_2 = bigHitGroundAttach:Clone()
		clone_2.Parent = part3
		VFX.EmitTree(part3, true)
		VFX.Discard(part3, 2)
	end

	TweenService:Create(state.Core, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
		Size = createVector(0.05, 0.05, 0.05),
		Transparency = 1
	}):Play()
	local fusedCategory = state.FusedCategory
	local tier = state.Tier
	local v5 = fusedCategory or "Fused " .. tier
	local model = eggs:FindFirstChild(v5)

	if not (model and model:IsA("Model")) then
		warn("[ShrineFusionSequence] missing fused egg model:", v5)
		model = nil
	end

	for _, v6 in { "Light", "Dark" } do
		local side = state.Sides[v6]

		if side.Prop.Parent then
			side.Prop:Destroy()
		end

		local clone

		if model then
			clone = model:Clone()
		else
			clone = fallbackProp(side.Color)
		end

		freeze(clone)
		normalizeProp(clone, 3.6) -- equivalent call inferred; original call site unknown
		clone:PivotTo(pivots[v6])
		clone.Parent = state.Container
		side.Prop = clone
		side.EggScale = clone:GetScale()
		clone:ScaleTo((math.max(side.EggScale * 0.12, 0.01)))

		if side.HostEmit then
			VFX.EmitTree(side.HostEmit, true)
		end

		for _, emitter in side.Host:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		side.Beam.Enabled = false
		side.Trail.Enabled = true
		side.RollStart = side.Roll
	end

	local theta = state.Theta
	local v6 = math.ceil((theta + 7.853981633974483) / 6.283185307179586) * 6.283185307179586
	local v7 = {}

	for _, v8 in { "Light", "Dark" } do
		v7[v8] = math.ceil(state.Sides[v8].Roll / 6.283185307179586) * 6.283185307179586
	end

	local v8 = state.Center - createVector(0, 1.4, 0)
	local total = 0

	while total < 1.8 do
		total += RunService.RenderStepped:Wait()

		if state.Dead then
			break
		end

		local v9 = math.min(total / 1.8, 1)
		local value = TweenService:GetValue(v9, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		state.Theta = theta + (v6 - theta) * value
		local v10 = TweenService:GetValue(v9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) * 1.4000000000000001 + 1.2
		local v11 = 0.24434609527920614 * (1 - value)
		local lerped = state.Center:Lerp(v8, quadInOut(v9))
		local v12 = math.clamp(1 - v9 / 0.3, 0, 1)
		state.ShakeIntensity = v12 * 0.7
		state.CamRumble = v12 * 0.46
		local v13 = math.min(v9 / 0.4, 1) - 1
		local v14 = v13 * 2.70158 * v13 * v13 + 1 + v13 * 1.70158 * v13

		for _, v15 in { "Light", "Dark" } do
			local side = state.Sides[v15]
			local v16 = state.Theta + (v15 == "Light" and 0 or 3.141592653589793)
			local v17 = (state.PlaneU * math.cos(v16) + state.PlaneV * math.sin(v16)) * v10

			if v11 > 0.001 then
				v17 = CFrame.fromAxisAngle(state.PlaneU, v11) * v17
			end

			local v18 = lerped + v17
			local rollStart = side.RollStart
			side.Roll = rollStart + (v7[v15] - rollStart) * value
			local pivot = propPivot(state, side, v18, v12 * 0.5)
			side.Pivot = pivot

			if side.Prop.Parent then
				side.Prop:PivotTo(pivot)
				side.Prop:ScaleTo((math.max(side.EggScale * (v14 * 0.88 + 0.12), 0.01)))
			end

			side.Host.CFrame = CFrame.new(v18)
		end
	end

	state.ShakeIntensity = 0
	state.CamRumble = 0
	local v9 = {}

	for _, v10 in { "Light", "Dark" } do
		local v11 = v10 == "Light" and 1 or -1
		v9[v10] = v8 + state.PlaneU * (v11 * 2.6)
	end

	local total2 = 0

	while total2 < 1.9 do
		total2 += RunService.RenderStepped:Wait()

		if state.Dead then
			break
		end

		local now = os.clock()
		local v11 = quadIn(math.clamp((total2 - 1.5) / 0.4, 0, 1)) -- equivalent call inferred; original call site unknown

		for _, v12 in { "Light", "Dark" } do
			local side = state.Sides[v12]
			local v13 = math.sin(now * 2.3 + side.BobPhase) * 0.24 * (1 - v11)
			local v14 = v9[v12] + Vector3.new(0, v13 - v11 * 0.45, 0)
			local v15 = (1 - v11) * 0.12217304763960307
			local pivot = CFrame.lookAt(v14, (Vector3.new(state.Center.X, v14.Y, state.Center.Z))) * CFrame.Angles(
				math.sin(now * 1.7 + side.BobPhase) * v15,
				0,
				math.cos(now * 1.3 + side.BobPhase) * v15
			)
			side.Pivot = pivot

			if side.Prop.Parent then
				side.Prop:PivotTo(pivot)
				side.Prop:ScaleTo((math.max(side.EggScale * (v11 * -0.14 + 1), 0.01)))
			end

			side.Host.CFrame = CFrame.new(v14)
		end
	end

	state.FlightStartAt = os.clock()

	for k, v10 in { "Light", "Dark" } do
		local v11 = k
		local v12 = state.Sides[v10]
		task.spawn(function()
			if v11 > 1 then
				task.wait(0.15)
			end

			if v12.HostEmit then
				VFX.EmitTree(v12.HostEmit, true)
			end

			flight(state, v12)
		end)
	end

	local total3 = 0

	while total3 < 2.8 do
		task.wait(0.05)
		total3 += 0.05

		if state.Sides.Light.Arrived and state.Sides.Dark.Arrived then
			break
		end
	end

	finish(state) -- equivalent call inferred; original call site unknown

	if callback then
		task.spawn(callback)
	end
end

function v3.IsPlaying()
	return v4 ~= nil
end

function v3.ActiveShrine()
	if v4 then
		return v4.Shrine
	end

	return nil
end

function v3.IsResolving()
	return v4 ~= nil and v4.Resolving == true
end

function v3.FlightFocus()
	local v5 = v4

	if not (v5 and v5.FlightStartAt) then
		return nil
	end

	local v6 = os.clock() - v5.FlightStartAt

	if v6 < 0.15 then
		return v5.Sides.Light.FlightAt
	end

	if v6 < 0.3 then
		return v5.Sides.Dark.FlightAt or v5.Sides.Light.FlightAt
	end

	return nil
end

function v3.Begin(data)
	local shrine = data.Shrine

	if typeof(shrine) ~= "Instance" or not shrine:IsDescendantOf(Workspace) then
		return false
	end

	local lightPad = shrine:FindFirstChild("LightPad")
	local darkPad = shrine:FindFirstChild("DarkPad")

	if not (lightPad and lightPad:IsA("BasePart") and darkPad and darkPad:IsA("BasePart")) then
		return false
	end

	if v4 then
		local v5 = v4
		v4 = nil
		v5.Dead = true
		v5.Trove:Clean()
	end

	local v5 = {
		Trove = Trove.new(),
		Shrine = shrine,
		Tier = data.Tier,
		FusedCategory = data.FusedCategory,
		Participant = data.Participant == true,
		TrackCharacter = data.TrackCharacter,
		StartAt = Workspace:GetServerTimeNow(),
		EndsAt = data.EndsAt,
		Pads = {
			Light = lightPad,
			Dark = darkPad
		},
		Sides = {},
		Theta = 0,
		ShakeIntensity = 0,
		CamPunch = 0,
		CamRumble = 0,
		Impulses = table.create(8),
		ImpulseSlot = 1,
		NextImpulse = 0,
		Dead = false,
		Resolving = false,
		Absorbing = false
	}
	local v6 = math.max(v5.EndsAt - v5.StartAt, 1)
	v5.LiftSeconds = math.clamp(v6 * 0.16, 0.35, 1.1)
	v5.ShakeLead = math.clamp(v6 * 0.24, 0.5, 1.3)
	local v7 = (lightPad.Position - darkPad.Position) * createVector(1, 0, 1)
	v5.PlaneU = not (v7.Magnitude > 0.01) and createVector(1, 0, 0) or v7.Unit
	v5.PlaneV = v5.PlaneU:Cross(createVector(0, 1, 0))
	v5.Center = (lightPad.Position + darkPad.Position) * 0.5 + createVector(0, 5.5, 0)
	v5.GroundY = math.max(lightPad.Position.Y + lightPad.Size.Y * 0.5, darkPad.Position.Y + darkPad.Size.Y * 0.5)
	local folder = Instance.new("Folder")
	folder.Name = "ShrineFusionSequence"
	folder.Parent = data.Parent or debris()
	v5.Trove:Add(folder)
	v5.Container = folder
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Size = createVector(0.55, 0.55, 0.55)
	part.Transparency = 0.3
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.CFrame = CFrame.new(v5.Center)
	part.Parent = folder
	v5.Core = part
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	v5.CoreAttachment = attachment
	v5.Sides.Light = buildSide(v5, "Light", data.LightCharacter)
	v5.Sides.Dark = buildSide(v5, "Dark", data.DarkCharacter)
	v5.Trove:Add(function()
		revealSide(v5.Sides.Light)
		revealSide(v5.Sides.Dark)
	end)
	v4 = v5
	v5.Trove:Connect(RunService.RenderStepped, function(p)
		stepSession(v5, p)
	end)
	fuseTrack(v5)
	return true
end

function v3.Payoff(callback)
	local v5 = v4

	if v5 and not (v5.Resolving or v5.Dead) then
		v5.Resolving = true
		task.spawn(function()
			local success, result = pcall(resolvePayoff, v5, callback)

			if not success then
				warn("ShrineFusionSequence payoff failed:", result)
				finish(v5) -- equivalent call inferred; original call site unknown

				if callback then
					task.spawn(callback)
				end
			end
		end)
		return true
	else
		return false
	end
end

function v3.Cancel()
	local v5 = v4

	if v5 and not v5.Resolving then
		v5.Dead = true
		task.spawn(function()
			local scale = v5.Sides.Light.Prop:GetScale()
			local scale2 = v5.Sides.Dark.Prop:GetScale()
			local total = 0

			while total < 0.3 do
				local v6 = RunService.RenderStepped:Wait()
				total += v6
				local v7 = math.min(total / 0.3, 1)
				local v8 = math.max(1 - TweenService:GetValue(v7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), 0.01)

				for _, v9 in { "Light", "Dark" } do
					local side = v5.Sides[v9]

					if not side.Prop.Parent then
						continue
					end

					local prop = side.Prop
					local v10

					if v9 == "Light" then
						v10 = scale
					else
						v10 = scale2
					end

					prop:ScaleTo((math.max(v10 * v8, 0.01)))
					side.Prop:PivotTo(side.Prop:GetPivot() * CFrame.new(0, -v6 * 2, 0))
				end

				v5.Core.Size = createVector(1, 1, 1) * math.max((1 - v7) * 1.5, 0.05)
				v5.ShakeIntensity = 0
				v5.CamRumble = 0
			end

			finish(v5) -- equivalent call inferred; original call site unknown
		end)
	end
end

pcall(function()
	RunService:BindToRenderStep("ShrineFusionSequenceHold", Enum.RenderPriority.Last.Value, function()
		for k in object4 do
			if k.Parent then
				k.LocalTransparencyModifier = 1
			else
				object4[k] = nil
			end
		end
	end)
end)
pcall(function()
	RunService:BindToRenderStep("ShrineFusionSequenceShake", Enum.RenderPriority.Camera.Value + 1, function()
		local v5 = v4

		if not v5 or not v5.Participant or GuiService.ReducedMotionEnabled then
			return
		end

		local v6 = math.clamp(
			math.max((v5.ShakeIntensity or 0) * 0.75, (v5.CamRumble or 0) * 0.35) + (v5.CamPunch or 0),
			0,
			1.6
		)
		local v7 = math.clamp(math.max(v5.ShakeIntensity or 0, v5.CamRumble or 0), 0, 1)
		local v8 = createVector(0, 0, 0)
		local v9 = createVector(0, 0, 0)
		local impulses = v5.Impulses

		if impulses then
			local now = os.clock()

			for _, impuls in impulses do
				local v10 = (now - impuls.At) / impuls.Life

				if not (v10 >= 0 and v10 < 1) then
					continue
				end

				local v11 = (1 - v10) * (1 - v10) * math.cos(v10 * 3.141592653589793 * 3)
				v8 += impuls.Dir * (impuls.Power * v11)
				v9 += impuls.Spin * (impuls.Power * v11)
			end
		end

		local v10 = v8.Magnitude > 0.001 or v9.Magnitude > 0.001

		if v6 <= 0.005 and v7 <= 0.01 and not v10 then
			return
		end

		local currentCamera = Workspace.CurrentCamera

		if not currentCamera or currentCamera.CameraType ~= Enum.CameraType.Scriptable then
			return
		end

		local v11 = os.clock() * 9
		local v12 = v6 * 0.15
		local v13 = math.rad(v6 * 1.6)
		currentCamera.CFrame = currentCamera.CFrame * CFrame.new(
			math.noise(v11, 0, 37.4) * 2 * v12,
			math.noise(0, v11, 42.1) * 2 * v12,
			0
		) * CFrame.Angles(
			math.noise(v11, 46.5, 0) * 2 * v13,
			math.noise(50.7, 0, v11) * 2 * v13,
			math.noise(v11 * 0.7, 0, 59) * v13
		)

		if v7 > 0.01 then
			local v14 = os.clock() * 31
			local v15 = v7 * 0.085
			local v16 = math.rad(v7 * 0.95)
			currentCamera.CFrame = currentCamera.CFrame * CFrame.new(
				math.noise(v14, 40.699999999999996, 0) * 2 * v15,
				math.noise(0, 45.3, v14) * 2 * v15,
				0
			) * CFrame.Angles(math.noise(v14, 0, 48.599999999999994) * 2 * v16, math.noise(55.2, v14, 0) * 2 * v16, 0)
		end

		if v10 then
			currentCamera.CFrame = currentCamera.CFrame * CFrame.new(v8 * 0.44) * CFrame.Angles(
				math.rad(v9.X * 2.6),
				math.rad(v9.Y * 2.6),
				(math.rad(v9.Z * 2.6 * 0.7))
			)
		end
	end)
end)
return table.freeze(v3)