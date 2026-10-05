local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local localPlayer = nil
local v = nil
local animation = nil
local animation2 = nil
local v2 = false
local v3 = {}
local v4 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function killLocalPlayer()
	local v5 = localPlayer
	local character

	if v5 then
		character = v5.Character
	end

	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	if humanoid and humanoid.Health > 0 then
		humanoid.Health = 0
	end
end

local function onHitboxTouched(p)
	if localPlayer and p.Parent == localPlayer.Character then
		killLocalPlayer() -- equivalent call inferred; original call site unknown
	end
end

local function getLivingPlayerPosition()
	local v5 = localPlayer
	local character

	if v5 then
		character = v5.Character
	end

	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoid and humanoid.Health > 0 and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart.Position
	end

	return nil
end

local function isInZone(instance, vector2: Vector3)
	local pointToObjectSpace = instance.CFrame:PointToObjectSpace(vector2)
	return math.abs(pointToObjectSpace.X) <= instance.Size.X / 2 and math.abs(pointToObjectSpace.Z) <= instance.Size.Z / 2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolvePhase(flag: boolean, dot: number)
	if flag then
		return "Chasing"
	end

	if dot > 144 then
		return "Returning"
	end

	return "Idle"
end

local function checkZoneReady(part)
	if not part:IsA("BasePart") then
		return false, nil, "G2W1_NPC1_AttackZone tag must be placed on a BasePart"
	end

	local G2W1_NPC1 = ReplicatedStorage:FindFirstChild("G2W1_NPC1")

	if G2W1_NPC1 and G2W1_NPC1:IsA("Model") then
		return true, {
			zone = part,
			template = G2W1_NPC1,
			spawnCFrame = G2W1_NPC1:GetPivot()
		}, ""
	end

	return false, nil, "ReplicatedStorage.G2W1_NPC1 is missing"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function preloadTemplate(template)
	if not v2 and animation and animation2 then
		v2 = true
		task.spawn(function()
			ContentProvider:PreloadAsync({ animation, animation2, template })
		end)
	end
end

local function applyPhaseTransition(state, phase: string)
	if phase == "Chasing" or phase == "Returning" then
		state.root.Anchored = false
		local humanoid = state.humanoid
		humanoid.WalkSpeed = 170

		if not state.chaseMusic.IsPlaying then
			state.chaseMusic:Play()
		end

		state.walkTrack:Play()
		state.idleTrack:Stop()
	else
		state.root.Anchored = true
		state.humanoid:Move(createVector(0, 0, 0))
		state.root.AssemblyLinearVelocity = createVector(0, 0, 0)

		if state.chaseMusic.IsPlaying then
			state.chaseMusic:Stop()
		end

		state.walkTrack:Stop(0.1)
		state.idleTrack:Play()
	end

	state.currentState = phase
end

local function applyNpcSetup(data)
	preloadTemplate(data.template) -- equivalent call inferred; original call site unknown
	local clone = data.template:Clone()
	clone:PivotTo(data.spawnCFrame)
	clone.Parent = Workspace
	local humanoidRootPart = clone.HumanoidRootPart
	local humanoid = clone.Humanoid
	local hitbox = clone.Hitbox
	local chaseMusic = humanoidRootPart.ChaseMusic
	local v5 = humanoid:FindFirstChildOfClass("Animator")

	if v5 == nil then
		v5 = Instance.new("Animator")
		v5.Parent = humanoid
	end

	humanoidRootPart.Anchored = true
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	local track = v5:LoadAnimation(animation)
	local track2 = v5:LoadAnimation(animation2)
	track2:Play()
	local touchedConnection = hitbox.Touched:Connect(onHitboxTouched)
	local janitor = Janitor.new()
	janitor:Add(touchedConnection)
	janitor:Add(clone)
	v3[data.zone] = {
		zone = data.zone,
		model = clone,
		root = humanoidRootPart,
		humanoid = humanoid,
		walkTrack = track,
		idleTrack = track2,
		chaseMusic = chaseMusic,
		spawnCFrame = data.spawnCFrame,
		currentState = "Idle",
		janitor = janitor
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function teardownNpc(k)
	v4[k] = nil
	local v5 = v3[k]

	if v5 then
		v5.janitor:Destroy()
		v3[k] = nil
	end
end

local function queueZone(part)
	if v3[part] == nil and v4[part] == nil then
		if part:IsA("BasePart") then
			v4[part] = {
				nextRetry = 0,
				warnAt = os.clock() + 10,
				warned = false
			}
		else
			logger:warn("G2W1_NPC1_AttackZone tag must be placed on a BasePart", part:GetFullName())
		end
	end
end

local function retryPending(now: number)
	for k, v5 in v4 do
		if k.Parent == nil then
			v4[k] = nil
		elseif v5.nextRetry <= now then
			v5.nextRetry = now + 0.5
			local v6, v7, v8 = checkZoneReady(k)

			if v6 and v7 then
				applyNpcSetup(v7)
				v4[k] = nil
			elseif v5.warnAt <= now and not v5.warned then
				v5.warned = true
				logger:warn(v8, k:GetFullName())
			end
		end
	end
end

local function applyNpcTick(data)
	local livingPlayerPosition = getLivingPlayerPosition()
	local vector2 = (data.root.Position - data.spawnCFrame.Position) * createVector(1, 0, 1)
	local v5

	if livingPlayerPosition == nil then
		v5 = false
	else
		local zone = data.zone
		local pointToObjectSpace = zone.CFrame:PointToObjectSpace(livingPlayerPosition)

		if math.abs(pointToObjectSpace.X) <= zone.Size.X / 2 then
			v5 = math.abs(pointToObjectSpace.Z) <= zone.Size.Z / 2
		else
			v5 = false
		end
	end

	local phase = resolvePhase(v5, vector2:Dot(vector2)) -- equivalent call inferred; original call site unknown

	if phase ~= data.currentState then
		applyPhaseTransition(data, phase)
	end

	if data.currentState == "Chasing" and livingPlayerPosition then
		data.humanoid:MoveTo(livingPlayerPosition)
	elseif data.currentState == "Returning" then
		data.humanoid:MoveTo(data.spawnCFrame.Position)
	end
end

local function updateNpcs()
	retryPending(os.clock())

	for k, v5 in v3 do
		if k.Parent and v5.model.Parent then
			applyNpcTick(v5)
		elseif k.Parent then
			teardownNpc(k) -- equivalent call inferred; original call site unknown
			queueZone(k)
		else
			teardownNpc(k) -- equivalent call inferred; original call site unknown
		end
	end
end

local function startClient()
	localPlayer = Players.LocalPlayer
	animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://180426354"
	animation2 = Instance.new("Animation")
	animation2.AnimationId = "rbxassetid://180435571"

	for _, v5 in CollectionService:GetTagged("G2W1_NPC1_AttackZone") do
		queueZone(v5)
	end

	retryPending(os.clock())
	local connection = CollectionService:GetInstanceAddedSignal("G2W1_NPC1_AttackZone"):Connect(queueZone)
	local connection2 = CollectionService:GetInstanceRemovedSignal("G2W1_NPC1_AttackZone"):Connect(teardownNpc)
	v = Janitor.new()
	v:Add(connection)
	v:Add(connection2)
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if RunService:IsClient() then
			startClient()
		end
	end,
	OnUpdate = function()
		if RunService:IsClient() then
			updateNpcs()
		end
	end
})
return {}