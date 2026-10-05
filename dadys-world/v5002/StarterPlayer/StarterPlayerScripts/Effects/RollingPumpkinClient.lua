local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local modules = ReplicatedStorage:WaitForChild("Modules")
local sharedUtils = ReplicatedStorage:WaitForChild("SharedUtils")
local RollingPumpkinCore = require(modules:WaitForChild("Gameplay"):WaitForChild("RollingPumpkinCore"))
local Audio = require(sharedUtils:WaitForChild("Audio"))
local CameraAuthority = require(sharedUtils:WaitForChild("CameraAuthority"))
local CameraShaker = require(modules:WaitForChild("External"):WaitForChild("CameraShaker"))
local SoundGroupManager = require(modules:WaitForChild("Audio"):WaitForChild("SoundGroupManager"))
local ScreenEffectsSetting = require(modules:WaitForChild("ClientUI"):WaitForChild("ScreenEffectsSetting"))
local handover = RollingPumpkinCore.Handover

if not handover then
	warn("[RollingPumpkinClient] RollingPumpkinCore has no Handover table: this Studio is running an out-of-date copy of ReplicatedStorage.Modules.Gameplay.RollingPumpkinCore")
	return
end

local v = { "rbxassetid://73214559247140", "rbxassetid://73358128217993" }
local v2 = {}

local function readHandover(serverCopy)
	local attributes = {}

	for k, attributeName in pairs(handover) do
		if not (k ~= "Tag" and k ~= "Body") then
			continue
		end

		local attribute = serverCopy:GetAttribute(attributeName)

		if attribute == nil then
			return nil
		else
			attributes[k] = attribute
		end
	end

	return attributes
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startingGrowth(data)
	if Workspace:GetServerTimeNow() - data.HandedOverAt > 1 then
		return data.GrowDistance
	end

	return data.Grown
end

local function poseAt(position, facing, p, p2, radians)
	local supportHeight = RollingPumpkinCore.supportHeight(p2.Y / 2, p2.Z / 2, radians)
	return CFrame.new(position.X, p + supportHeight, position.Z) * CFrame.lookAt(createVector(0, 0, 0), facing) * CFrame.Angles(
		-radians,
		0,
		0
	)
end

local v3 = nil

local function getShaker()
	if not v3 then
		v3 = CameraShaker.new(Enum.RenderPriority.Camera.Value + 1, function(p)
			local currentCamera = Workspace.CurrentCamera

			if currentCamera then
				currentCamera.CFrame *= p
			end
		end)
		v3:Start()
	end

	return v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function listenerPosition()
	local character = Players.LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		return humanoidRootPart.Position
	end

	local currentCamera = Workspace.CurrentCamera
	return currentCamera and currentCamera.CFrame.Position or nil
end

local function shakeFrom(p, p2, p3, p4, p5, p6, p7)
	local v4 = listenerPosition() -- equivalent call inferred; original call site unknown

	if not v4 then
		return 0
	end

	local v5 = p2 * RollingPumpkinCore.rumbleFalloff((p - v4).Magnitude, 120)

	if v5 < 0.05 then
		return 0
	end

	local rumble = ScreenEffectsSetting.profile().rumble

	if rumble > 0 and not CameraAuthority.isClaimed() then
		if not v3 then
			v3 = CameraShaker.new(Enum.RenderPriority.Camera.Value + 1, function(p8)
				local currentCamera = Workspace.CurrentCamera

				if currentCamera then
					currentCamera.CFrame *= p8
				end
			end)
			v3:Start()
		end

		v3:ShakeOnce(v5 * rumble, p3, p4, p5, p6, p7)
	end

	return v5
end

local function thump(p, p2)
	shakeFrom(p2, 2 * p.width / p.fullWidth, 9, 0.02, 0.4, createVector(0.12, 0.18, 0.12), createVector(0.8, 0.4, 1.6))
end

local function startRollSound(instance)
	local basePart = instance:FindFirstChildWhichIsA("BasePart", true)

	if not basePart then
		return
	end

	local v4 = Audio:Acquire(v[math.random(#v)], {
		Name = "RollingPumpkinRoll",
		Looped = true,
		Volume = 0.5,
		PlaybackSpeed = 0.95 + math.random() * 0.10000000000000009,
		RollOffMode = Enum.RollOffMode.Linear,
		RollOffMinDistance = 6,
		RollOffMaxDistance = 70,
		Parent = basePart
	})

	if v4 then
		SoundGroupManager.AssignSFXSound(v4)
	end
end

local function isEffect(descendant)
	return descendant:IsA("Light") or descendant:IsA("ParticleEmitter") or descendant:IsA("Fire") or descendant:IsA("Smoke") or descendant:IsA("Sparkles") or descendant:IsA("Beam") or descendant:IsA("Trail")
end

local function buildCopy(serverCopy)
	local clone = serverCopy:Clone()

	if not clone then
		return nil, nil
	end

	local descendants = clone:GetDescendants()
	table.insert(descendants, clone)
	local result = {}

	for _, instance in ipairs(descendants) do
		for _, tag in ipairs(CollectionService:GetTags(instance)) do
			CollectionService:RemoveTag(instance, tag)
		end

		if instance:IsA("LuaSourceContainer") or instance:IsA("ObjectValue") then
			instance:Destroy()
		elseif instance:IsA("BasePart") then
			instance.Anchored = true
			instance.CanCollide = false
			instance.CanTouch = false
			instance.CanQuery = false
			instance.LocalTransparencyModifier = 0
		elseif instance:IsA("Light") then
			table.insert(result, {
				light = instance,
				range = instance.Range
			})
		end
	end

	clone.Name = "RollingPumpkinLocal"
	return clone, result
end

local function collectServerCopy(folder)
	local descendants = {}
	local result = {}

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			table.insert(descendants, descendant)
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			table.insert(result, {
				instance = descendant,
				property = "Transparency",
				hidden = 1,
				shown = descendant.Transparency
			})
		elseif isEffect(descendant) then
			table.insert(result, {
				instance = descendant,
				property = "Enabled",
				hidden = false,
				shown = descendant.Enabled
			})
		end
	end

	return descendants, result
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

local function setWidth(state, width)
	local v4 = state.baseScale * width / state.doorwayWidth
	local success, result = pcall(function()
		state.copy:ScaleTo(v4)
	end)

	if not success then
		warn(("[RollingPumpkinClient] could not scale the copy: %s"):format((tostring(result))))
	end

	for _, light in ipairs(state.lights) do
		light.light.Range = light.range * width / state.doorwayWidth
	end

	state.width = width
end

local function tryBegin(state)
	local serverCopy = state.serverCopy
	local child = serverCopy:FindFirstChild(handover.Body)
	local body = child and child.Value

	if not (body and body:IsA("BasePart") and body.Parent) then
		return
	end

	local humanoid = body.Parent:FindFirstChildOfClass("Humanoid")
	local v4 = readHandover(serverCopy)

	if not (humanoid and v4) then
		return
	end

	local copy, lights = buildCopy(serverCopy)

	if not copy then
		error("the server prop could not be cloned")
	end

	local success, result = pcall(function()
		return copy:GetScale()
	end)
	state.body = body
	state.humanoid = humanoid
	state.copy = copy
	state.lights = lights
	state.baseScale = not (success and result > 0 and result) and 1 or result
	state.doorwayWidth = v4.DoorwayWidth
	state.fullWidth = v4.FullWidth
	state.growDistance = v4.GrowDistance
	state.extentsPerWidth = v4.ExtentsPerWidth
	state.faceTurn = v4.FaceTurn
	local grown = startingGrowth(v4) -- equivalent call inferred; original call site unknown
	state.grown = grown
	state.radians = v4.Radians
	state.forward = v4.Forward
	state.facing = v4.Facing
	state.travelled = 0
	state.rumble = 0
	state.width = v4.DoorwayWidth
	state.last = body.Position
	local serverParts, overrides = collectServerCopy(serverCopy)
	state.serverParts = serverParts
	state.overrides = overrides
	local widthAt = RollingPumpkinCore.widthAt(state.grown, state.doorwayWidth, state.fullWidth, state.growDistance)

	if math.abs(widthAt - state.width) > 0.001 then
		setWidth(state, widthAt)
	end

	copy.Parent = Workspace
	setServerCopyHidden(state, true)
	local success2, result2 = pcall(startRollSound, copy)

	if not success2 then
		warn(("[RollingPumpkinClient] roll sound failed: %s"):format((tostring(result2))))
	end
end

local function step(state, p)
	for _, serverPart in ipairs(state.serverParts) do
		serverPart.LocalTransparencyModifier = 1
	end

	local body = state.body

	if not body.Parent then
		return
	end

	local position = body.Position
	local v4 = position.X - state.last.X
	local v5 = position.Z - state.last.Z
	state.last = position
	local v6 = math.sqrt(v4 * v4 + v5 * v5)
	local v7 = state.extentsPerWidth * state.width

	if v6 > 0.001 then
		state.travelled += v6
		local deltaRadians = RollingPumpkinCore.deltaRadians(v6, RollingPumpkinCore.rollRadius(v7.Y / 2, v7.Z / 2))
		state.radians += deltaRadians
		local rumble, v9 = RollingPumpkinCore.consumeRumble(state.rumble, deltaRadians)
		state.rumble = rumble

		if v9 then
			local success, result = pcall(thump, state, position)

			if not success then
				warn(("[RollingPumpkinClient] thump failed: %s"):format((tostring(result))))
			end
		end
	end

	local v8, v9, v10, v11 = RollingPumpkinCore.stepHeadings(
		state.forward.X,
		state.forward.Z,
		state.facing.X,
		state.facing.Z,
		v4,
		v5,
		p,
		state.faceTurn
	)
	state.forward = Vector3.new(v8, 0, v9)
	state.facing = Vector3.new(v10, 0, v11)
	local widthAt = RollingPumpkinCore.widthAt(
		state.grown + state.travelled,
		state.doorwayWidth,
		state.fullWidth,
		state.growDistance
	)

	if math.abs(widthAt - state.width) > 0.001 then
		setWidth(state, widthAt)
		v7 = state.extentsPerWidth * widthAt
	end

	local v12 = position.Y - body.Size.Y / 2 - state.humanoid.HipHeight
	state.copy:PivotTo((poseAt(position, state.facing, v12, v7, state.radians)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function drop(k)
	local v4 = v2[k]
	v2[k] = nil

	if v4 and v4.copy then
		v4.copy:Destroy()
	end
end

local function fail(state, result)
	warn(("[RollingPumpkinClient] %s: %s"):format(state.serverCopy:GetFullName(), (tostring(result))))
	state.failed = true

	if state.copy then
		state.copy:Destroy()
		state.copy = nil
	end

	if state.serverParts then
		setServerCopyHidden(state, false)
	end
end

local function adopt(model)
	if v2[model] or not model:IsA("Model") then
		return
	end

	v2[model] = {
		serverCopy = model
	}
end

RunService.RenderStepped:Connect(function(dt)
	for k, v4 in pairs(v2) do
		if k.Parent then
			if not v4.failed then
				local success, result = pcall(v4.copy and step or tryBegin, v4, dt)

				if not success then
					fail(v4, result)
				end
			end
		else
			drop(k) -- equivalent call inferred; original call site unknown
		end
	end
end)

for _, model in ipairs(CollectionService:GetTagged(handover.Tag)) do
	if v2[model] or not model:IsA("Model") then
		continue
	end

	v2[model] = {
		serverCopy = model
	}
end

CollectionService:GetInstanceAddedSignal(handover.Tag):Connect(adopt)
CollectionService:GetInstanceRemovedSignal(handover.Tag):Connect(drop)
CollectionService:GetInstanceAddedSignal(RollingPumpkinCore.BurstTag):Connect(function(part)
	if not part:IsA("BasePart") then
		return
	end

	local success, result = pcall(
		shakeFrom,
		part.Position,
		2.5,
		18,
		0.01,
		0.55,
		createVector(0.2, 0.4, 0.2),
		createVector(3.2, 1.8, 4.2)
	)

	if not success then
		warn(("[RollingPumpkinClient] burst kick failed: %s"):format((tostring(result))))
	end
end)