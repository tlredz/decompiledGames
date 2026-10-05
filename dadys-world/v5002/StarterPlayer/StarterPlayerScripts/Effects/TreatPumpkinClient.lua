local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TreatPumpkinCore = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Gameplay"):WaitForChild("TreatPumpkinCore"))
local sharedUtils = ReplicatedStorage:WaitForChild("SharedUtils")
local CollectPresentation = require(sharedUtils:WaitForChild("HolidayPuzzles"):WaitForChild("CollectPresentation"))
local attr = TreatPumpkinCore.Attr
local localPlayer = Players.LocalPlayer
local color = Color3.fromRGB(255, 150, 40)
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 200, 80), Color3.fromRGB(255, 110, 20))
local v = {
	min = 1.15,
	max = 1.45
}
local v2 = {
	min = 8.377580409572781,
	max = 14.660765716752369
}
local cframe = CFrame.Angles(0, 3.141592653589793, 0)
local v3 = {}

local function log(_, ...) end

-- equivalent calls inferred from this helper; original call sites unknown
local function randomBetween(p)
	return p.min + math.random() * (p.max - p.min)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playSound(p)
	task.spawn(function()
		pcall(function()
			local Audio = require(sharedUtils:WaitForChild("Audio"))
			Audio:Play("Sounds.Toon.Looey.Ability.Pop", p)
		end)
	end)
end

local function burstAt(worldPosition, p, p2)
	local attachment = Instance.new("Attachment")
	attachment.Name = "TreatPumpkinBurst"
	attachment.WorldPosition = worldPosition
	attachment.Parent = Workspace.Terrain

	if p > 0 then
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Texture = "rbxassetid://130947809595971"
		particleEmitter.Color = ColorSequence.new(color)
		particleEmitter.LightEmission = 1
		particleEmitter.Size = NumberSequence.new(0.5, 0)
		particleEmitter.Lifetime = NumberRange.new(0.35, 0.7)
		particleEmitter.Speed = NumberRange.new(4, 9)
		particleEmitter.SpreadAngle = Vector2.new(180, 180)
		particleEmitter.Rate = 0
		particleEmitter.Parent = attachment
		particleEmitter:Emit(p)
	end

	if p2 then
		p2.Parent = attachment
		playSound(p2) -- equivalent call inferred; original call site unknown
	end

	Debris:AddItem(attachment, 2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function anchorOf(part)
	if part:IsA("BasePart") then
		return part
	end

	return part.PrimaryPart or part:FindFirstChildWhichIsA("BasePart", true)
end

local function isEffect(instance)
	return instance:IsA("Light") or instance:IsA("ParticleEmitter") or instance:IsA("Fire") or instance:IsA("Smoke") or instance:IsA("Sparkles") or instance:IsA("Beam") or instance:IsA("Trail")
end

local function collectServerCopy(folder)
	local descendants = folder:GetDescendants()
	table.insert(descendants, folder)
	local instances = {}
	local result = {}

	for _, instance in ipairs(descendants) do
		if instance:IsA("BasePart") then
			table.insert(instances, instance)
		elseif instance:IsA("Decal") or instance:IsA("Texture") then
			table.insert(result, {
				instance = instance,
				property = "Transparency",
				hidden = 1,
				shown = instance.Transparency
			})
		elseif isEffect(instance) then
			table.insert(result, {
				instance = instance,
				property = "Enabled",
				hidden = false,
				shown = instance.Enabled
			})
		end
	end

	return instances, result
end

local function setServerCopyHidden(state, p)
	for _, serverPart in ipairs(state.serverParts) do
		if serverPart.Parent then
			serverPart.LocalTransparencyModifier = p and 1 or 0
		end
	end

	for _, override in ipairs(state.overrides) do
		if not override.instance.Parent then
			continue
		end

		local instance = override.instance
		local property = override.property
		local v4

		if p then
			v4 = override.hidden
		else
			v4 = override.shown
		end

		instance[property] = v4
	end
end

local function inertCopy(model)
	local extentsSize = model:IsA("Model") and model:GetExtentsSize() or model.Size
	local mesh, v4 = CollectPresentation.cloneMesh(model, (math.max(extentsSize.X, extentsSize.Y, extentsSize.Z)))
	local descendants = mesh:GetDescendants()
	table.insert(descendants, mesh)

	for _, part in ipairs(descendants) do
		for _, tag in ipairs(CollectionService:GetTags(part)) do
			CollectionService:RemoveTag(part, tag)
		end

		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = 0
		end
	end

	return mesh, v4
end

local function buildCopy(state)
	local copy, setScale2 = inertCopy(state.piece)
	copy.Name = "TreatPumpkinLocal"
	local parent = anchorOf(copy) -- equivalent call inferred; original call site unknown

	if not parent then
		copy:Destroy()
		error("the piece has no parts to draw")
	end

	local pointLight = Instance.new("PointLight")
	pointLight.Color = color
	pointLight.Brightness = 0.9
	pointLight.Range = 6
	pointLight.Parent = parent
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxassetid://130947809595971"
	particleEmitter.Color = ColorSequence.new(color)
	particleEmitter.LightEmission = 1
	particleEmitter.Size = NumberSequence.new(0.25, 0)
	particleEmitter.Lifetime = NumberRange.new(0.5, 0.9)
	particleEmitter.Speed = NumberRange.new(0.3, 1)
	particleEmitter.Rate = 3
	particleEmitter.Parent = parent
	local attachment = Instance.new("Attachment")
	attachment.Position = createVector(0, 0.35, 0)
	attachment.Parent = parent
	local attachment2 = Instance.new("Attachment")
	attachment2.Position = createVector(0, -0.35, 0)
	attachment2.Parent = parent
	local trail = Instance.new("Trail")
	trail.Attachment0 = attachment
	trail.Attachment1 = attachment2
	trail.Color = colorSequence
	trail.Transparency = NumberSequence.new(0.2, 1)
	trail.Lifetime = 0.18
	trail.LightEmission = 1
	trail.FaceCamera = true
	trail.Enabled = false
	trail.Parent = parent
	state.copy = copy
	state.setScale = setScale2
	state.trail = trail
	state.scale = 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setScale(state, scale)
	if math.abs(scale - state.scale) > 0.001 then
		state.setScale(scale)
		state.scale = scale
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function show(state)
	if state.copy and not state.copy.Parent then
		state.copy.Parent = Workspace
	end
end

local function rootOfUser(p)
	local playerByUserId = Players:GetPlayerByUserId(p)

	if not playerByUserId then
		return nil, nil
	end

	local inGamePlayers = Workspace:FindFirstChild("InGamePlayers")
	local v4 = inGamePlayers and inGamePlayers:FindFirstChild(playerByUserId.Name) or playerByUserId.Character
	return v4 and v4:FindFirstChild("HumanoidRootPart"), playerByUserId
end

local function portalWorldOf(door)
	local back = door and door.Parent and door:FindFirstChild("Back")
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if not (back and playerGui) then
		return nil, nil
	end

	for _, surfaceGui in ipairs(playerGui:GetChildren()) do
		if not (surfaceGui:IsA("SurfaceGui") and surfaceGui.Enabled and surfaceGui.Adornee == back) then
			continue
		end

		local clip = surfaceGui:FindFirstChild("Clip")
		local scene = clip and clip:FindFirstChild("Scene")
		local worldModel = scene and scene:FindFirstChildOfClass("WorldModel")

		if worldModel then
			return worldModel, back
		end
	end

	return nil, nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearRoll(p)
	if p.rollCopy then
		p.rollCopy:Destroy()
		p.rollCopy = nil
	end
end

local function stepRoll(state, p)
	if not state.rollCopy then
		local parent, rollBack2 = portalWorldOf(state.door)

		if not parent then
			return
		end

		state.rollCopy = inertCopy(state.piece)
		state.rollCopy.Name = "TreatPumpkinRolling"
		state.rollBack = rollBack2
		state.rollCopy.Parent = parent
	end

	local rollBack = state.rollBack
	local pointToObjectSpace = (rollBack.CFrame * cframe):PointToObjectSpace(state.from)
	local v4 = -rollBack.Size.Y / 2 + state.lift
	local vector2 = Vector3.new(pointToObjectSpace.X + state.rollSway, v4, -TreatPumpkinCore.ROLL_DEPTH)
	local vector3 = Vector3.new(pointToObjectSpace.X, v4, -(state.lift + 0.05))
	local lerped = vector2:Lerp(
		vector3,
		(TreatPumpkinCore.rollAlpha((p + TreatPumpkinCore.ROLL_SECONDS) / TreatPumpkinCore.ROLL_SECONDS))
	)
	local unit = (vector3 - vector2).Unit
	local unit2 = (createVector(0, 1, 0)):Cross(unit).Unit
	local v5 = (lerped - vector2).Magnitude / math.max(state.lift, 0.1)
	state.rollCopy:PivotTo(CFrame.new(lerped) * CFrame.fromAxisAngle(unit2, v5) * state.rest.Rotation)
end

local function beginCollect(state, attribute)
	clearRoll(state) -- equivalent call inferred; original call site unknown
	show(state) -- equivalent call inferred; original call site unknown
	local playerByUserId = Players:GetPlayerByUserId(attribute)
	local humanoidRootPart

	if playerByUserId then
		local inGamePlayers = Workspace:FindFirstChild("InGamePlayers")
		local v4 = inGamePlayers and inGamePlayers:FindFirstChild(playerByUserId.Name) or playerByUserId.Character
		humanoidRootPart = v4 and v4:FindFirstChild("HumanoidRootPart")
	else
		playerByUserId = nil
	end

	local position = state.copy:GetPivot().Position
	state.collect = {
		start = os.clock(),
		from = position,
		root = humanoidRootPart,
		spin = math.random() * 2 * 3.141592653589793
	}
	state.trail.Enabled = true
	log("collect by %s", playerByUserId and playerByUserId.Name or tostring(attribute))
end

local function stepCollect(state)
	local collect = state.collect
	local v4 = (os.clock() - collect.start) / state.flyIn
	local v5 = collect.from + Vector3.new(0, TreatPumpkinCore.HOP_HEIGHT, 0)
	local root = collect.root
	local v6

	if root and root.Parent then
		v6 = root.Position + createVector(0, 0.5, 0)
	else
		v6 = v5 + createVector(0, 3, 0)
	end

	if v4 >= 1 then
		burstAt(v6, 16)
		state.copy:Destroy()
		state.copy = nil
		state.finished = true
	else
		local flyInAt, v7, scale = TreatPumpkinCore.flyInAt(v4)
		local v9

		if v7 <= 0 then
			v9 = collect.from + Vector3.new(0, flyInAt, 0)
		else
			local v10 = v5:Lerp(v6, 0.5) + createVector(0, 1.5, 0)
			v9 = v5:Lerp(v10, v7):Lerp(v10:Lerp(v6, v7), v7)
		end

		setScale(state, scale) -- equivalent call inferred; original call site unknown
		state.copy:PivotTo(CFrame.new(v9) * CFrame.Angles(0, collect.spin + 15.707963267948966 * v4, 0))
	end
end

local function step(state)
	if state.collect then
		stepCollect(state)
		return
	end

	local attribute = state.piece.Parent and state.piece:GetAttribute(attr.CollectedBy)

	if attribute then
		beginCollect(state, attribute)
		stepCollect(state)
	else
		local v4 = Workspace:GetServerTimeNow() - state.launchAt

		if v4 < 0 then
			if -TreatPumpkinCore.ROLL_SECONDS <= v4 then
				stepRoll(state, v4)
			end
		else
			clearRoll(state) -- equivalent call inferred; original call site unknown
			local rest = state.rest

			if v4 < state.flight then
				if not state.launched then
					state.launched = true
					show(state) -- equivalent call inferred; original call site unknown

					if v4 < 0.25 then
						burstAt(state.from, 6, {
							Volume = 0.3,
							PlaybackSpeed = randomBetween(v)
						})
					end
				end

				local v5 = v4 / state.flight
				local v6 = state.from:Lerp(rest.Position, v5) + Vector3.new(
					0,
					TreatPumpkinCore.arcHeight(v5, state.arc),
					0
				)
				local cframe2 = CFrame.fromAxisAngle(state.tumbleAxis, state.tumbleRate * state.flight * (1 - v5))
				setScale(state, TreatPumpkinCore.launchScale(v5)) -- equivalent call inferred; original call site unknown
				state.copy:PivotTo(CFrame.new(v6) * rest.Rotation * cframe2)
			else
				show(state) -- equivalent call inferred; original call site unknown
				local v5 = v4 - state.flight
				local bounceSeconds = TreatPumpkinCore.bounceSeconds()

				if v5 < bounceSeconds then
					if not state.landed then
						state.landed = true
						burstAt(rest.Position, 4)
					end

					local bounceAt, scale = TreatPumpkinCore.bounceAt(v5)
					setScale(state, scale) -- equivalent call inferred; original call site unknown
					state.copy:PivotTo(rest + Vector3.new(0, bounceAt, 0))
				else
					local v6 = v5 - bounceSeconds
					setScale(state, 1) -- equivalent call inferred; original call site unknown
					state.copy:PivotTo(CFrame.new(rest.Position + Vector3.new(0, TreatPumpkinCore.bobAt(v6), 0)) * CFrame.Angles(
						0,
						TreatPumpkinCore.IDLE_TURN * v6,
						0
					) * rest.Rotation)
				end
			end
		end
	end
end

local function drop(p)
	local v4 = v3[p]

	if not v4 or v4.collect and v4.copy then
		return
	end

	v3[p] = nil
	clearRoll(v4) -- equivalent call inferred; original call site unknown

	if v4.copy then
		if v4.copy.Parent then
			burstAt(v4.copy:GetPivot().Position, 4)
		end

		v4.copy:Destroy()
	end
end

local function fail(state, result)
	warn(("[TreatPumpkinClient] %s: %s"):format(state.piece:GetFullName(), (tostring(result))))
	state.failed = true
	clearRoll(state) -- equivalent call inferred; original call site unknown

	if state.copy then
		state.copy:Destroy()
		state.copy = nil
	end

	if state.serverParts then
		setServerCopyHidden(state, false)
	end
end

local function begin(state)
	local piece = state.piece

	for _, v4 in ipairs({
		"From",
		"LaunchAt",
		"Flight",
		"Arc",
		"FlyIn"
	}) do
		if piece:GetAttribute(attr[v4]) == nil then
			error("missing attribute " .. attr[v4])
		end
	end

	state.from = piece:GetAttribute(attr.From)
	state.launchAt = piece:GetAttribute(attr.LaunchAt)
	state.flight = math.max(piece:GetAttribute(attr.Flight), 0.05)
	state.arc = piece:GetAttribute(attr.Arc)
	state.flyIn = math.max(piece:GetAttribute(attr.FlyIn), 0.05)
	state.rest = piece:GetPivot()

	if piece:IsA("Model") then
		local boundingBox, v4 = piece:GetBoundingBox()
		state.lift = state.rest.Position.Y - (boundingBox.Position.Y - v4.Y / 2)
	else
		state.lift = piece.Size.Y / 2
	end

	local child = piece:FindFirstChild(TreatPumpkinCore.DoorLink)
	state.door = child and child.Value
	state.rollSway = (math.random() * 2 - 1) * 1
	state.tumbleAxis = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
	state.tumbleRate = randomBetween(v2)
	buildCopy(state)
	local serverParts, overrides = collectServerCopy(piece)
	state.serverParts = serverParts
	state.overrides = overrides
	setServerCopyHidden(state, true)
end

local function adopt(instance)
	if v3[instance] or not (instance:IsA("Model") or instance:IsA("BasePart")) then
		return
	end

	local v4 = {
		piece = instance
	}
	v3[instance] = v4
	local success, result = pcall(begin, v4)

	if not success then
		fail(v4, result)
	end
end

RunService.RenderStepped:Connect(function()
	for k, v4 in pairs(v3) do
		if v4.finished then
			v3[k] = nil
		elseif not v4.failed and v4.copy then
			local success, result = pcall(step, v4)

			if not success then
				fail(v4, result)
			end
		end
	end
end)

for _, v4 in ipairs(CollectionService:GetTagged(TreatPumpkinCore.Tag)) do
	adopt(v4)
end

CollectionService:GetInstanceAddedSignal(TreatPumpkinCore.Tag):Connect(adopt)
CollectionService:GetInstanceRemovedSignal(TreatPumpkinCore.Tag):Connect(drop)