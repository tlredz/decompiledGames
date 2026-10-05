local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local v = {
	Walk = "rbxassetid://104571570562605",
	Idle = "rbxassetid://123873530367173"
}
local stage2LocalNPC = ReplicatedStorage:WaitForChild("Stage2LocalNPC")

if not (stage2LocalNPC and stage2LocalNPC:IsA("Model")) then
	warn("[Stage2LocalNPC] Template Model introuvable : ReplicatedStorage.Stage2LocalNPC")
	return
end

local v2 = {}

local function isInsideZone(instance, position: Vector3)
	local pointToObjectSpace = instance.CFrame:PointToObjectSpace(position)
	return math.abs(pointToObjectSpace.X) <= instance.Size.X / 2 and math.abs(pointToObjectSpace.Y) <= math.max(
		instance.Size.Y / 2,
		30
	) and math.abs(pointToObjectSpace.Z) <= instance.Size.Z / 2
end

local function normalizeAnimationId(value)
	if typeof(value) == "number" then
		return "rbxassetid://" .. tostring((math.floor(value)))
	end

	if typeof(value) ~= "string" or value == "" then
		return nil
	end

	if string.match(value, "^%d+$") then
		return "rbxassetid://" .. value
	end

	return value
end

local function loadTrack(animator, clone, p: string)
	local animation = clone:FindFirstChild(p .. "Animation", true)
	local animationId

	if animation and animation:IsA("Animation") then
		animationId = animation.AnimationId

		if typeof(animationId) == "number" then
			animationId = "rbxassetid://" .. tostring((math.floor(animationId)))
		elseif typeof(animationId) == "string" and animationId ~= "" then
			if string.match(animationId, "^%d+$") then
				animationId = "rbxassetid://" .. animationId
			end
		else
			animationId = nil
		end
	end

	if animationId then
		local animation2 = Instance.new("Animation")
		animation2.AnimationId = animationId
		local track = animator:LoadAnimation(animation2)
		animation2:Destroy()
		track.Looped = true
		return track
	else
		local attribute = clone:GetAttribute(p .. "AnimationId")

		if typeof(attribute) == "number" then
			attribute = "rbxassetid://" .. tostring((math.floor(attribute)))
		elseif typeof(attribute) == "string" and attribute ~= "" then
			if string.match(attribute, "^%d+$") then
				attribute = "rbxassetid://" .. attribute
			end
		else
			attribute = nil
		end

		if attribute then
			local animation2 = Instance.new("Animation")
			animation2.AnimationId = attribute
			local track = animator:LoadAnimation(animation2)
			animation2:Destroy()
			track.Looped = true
			return track
		else
			local animationId2 = v[p]

			if not animationId2 then
				return nil
			end

			local animation2 = Instance.new("Animation")
			animation2.AnimationId = animationId2
			local track = animator:LoadAnimation(animation2)
			animation2:Destroy()
			track.Looped = true
			return track
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setState(state, state2: string)
	if state.state == state2 then
		return
	end

	state.state = state2

	if state2 == "Chasing" then
		if state.idleTrack and state.idleTrack.IsPlaying then
			state.idleTrack:Stop(0.2)
		end

		if state.walkTrack and not state.walkTrack.IsPlaying then
			state.walkTrack:Play(0.2)
		end

		if state.chaseMusic and not state.chaseMusic.IsPlaying then
			state.chaseMusic:Play()
		end
	else
		if state.walkTrack and state.walkTrack.IsPlaying then
			state.walkTrack:Stop(0.2)
		end

		if state.idleTrack and not state.idleTrack.IsPlaying then
			state.idleTrack:Play(0.2)
		end

		if state.chaseMusic and state.chaseMusic.IsPlaying then
			state.chaseMusic:Stop()
		end
	end
end

local function cleanupZone(p)
	local v3 = v2[p]

	if not v3 then
		return
	end

	v3.hitboxConnection:Disconnect()

	if v3.walkTrack then
		v3.walkTrack:Stop(0)
	end

	if v3.idleTrack then
		v3.idleTrack:Stop(0)
	end

	v3.model:Destroy()
	v2[p] = nil
end

local function setupZone(part)
	if not part:IsA("BasePart") or v2[part] then
		return
	end

	local clone = stage2LocalNPC:Clone()
	clone.Name = "Stage2LocalNPC_Local"
	local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")
	local humanoid = clone:FindFirstChildOfClass("Humanoid")
	local hitbox = clone:FindFirstChild("Hitbox", true)

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoid and hitbox and hitbox:IsA("BasePart") then
		local v3 = humanoid:FindFirstChildOfClass("Animator")

		if not v3 then
			v3 = Instance.new("Animator")
			v3.Parent = humanoid
		end

		for _, part2 in clone:GetDescendants() do
			if part2:IsA("BasePart") then
				part2.CanCollide = false
			end
		end

		humanoidRootPart.Anchored = true
		hitbox.CanTouch = true
		local pivot = stage2LocalNPC:GetPivot()
		clone:PivotTo(pivot)
		local cFrame = humanoidRootPart.CFrame
		clone.Parent = workspace
		local touchedConnection = hitbox.Touched:Connect(function(otherPart)
			local character = localPlayer.Character

			if not (character and otherPart:IsDescendantOf(character)) then
				return
			end

			local humanoid2 = character:FindFirstChildOfClass("Humanoid")

			if humanoid2 and humanoid2.Health > 0 then
				humanoid2.Health = 0
			end
		end)
		local chaseMusic = humanoidRootPart:FindFirstChild("ChaseMusic")

		if not (chaseMusic and chaseMusic:IsA("Sound")) then
			chaseMusic = nil
		end

		local v4 = {
			zone = part,
			model = clone,
			root = humanoidRootPart,
			humanoid = humanoid,
			hitboxConnection = touchedConnection,
			spawnCFrame = pivot,
			spawnRootCFrame = cFrame,
			walkTrack = loadTrack(v3, clone, "Walk"),
			idleTrack = loadTrack(v3, clone, "Idle"),
			chaseMusic = chaseMusic,
			state = ""
		}
		v2[part] = v4
		setState(v4, "Idle") -- equivalent call inferred; original call site unknown
	else
		warn("[Stage2LocalNPC] HumanoidRootPart, Humanoid ou Hitbox introuvable dans", stage2LocalNPC:GetFullName())
		clone:Destroy()
	end
end

local function moveTowards(p, position: Vector3, p2: number, dt: number, p3: number)
	local cFrame = p.root.CFrame
	local position2 = cFrame.Position
	local vector2 = Vector3.new(position.X, p.spawnRootCFrame.Position.Y, position.Z)
	local v3 = vector2 - position2
	local magnitude = v3.Magnitude

	if magnitude <= p3 or magnitude <= 0.001 then
		return
	end

	local v4 = math.min(p2 * dt, magnitude - p3)
	local v5 = position2 + v3.Unit * v4

	if (vector2 - v5).Magnitude <= 0.001 then
		p.root.CFrame = CFrame.new(vector2) * cFrame.Rotation
	else
		p.root.CFrame = CFrame.lookAt(v5, vector2, createVector(0, 1, 0))
	end
end

RunService.PreRender:Connect(function(dt)
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	for k, v3 in v2 do
		if k:IsDescendantOf(workspace) and v3.model.Parent then
			local v4 = humanoidRootPart and humanoidRootPart:IsA("BasePart")

			if v4 then
				if humanoid then
					if humanoid.Health > 0 then
						v4 = isInsideZone(k, humanoidRootPart.Position)
					else
						v4 = false
					end
				else
					v4 = humanoid
				end
			end

			if v4 and humanoidRootPart then
				setState(v3, "Chasing") -- equivalent call inferred; original call site unknown
				local chaseSpeed = stage2LocalNPC:GetAttribute("ChaseSpeed") or 22
				local stopDistance = stage2LocalNPC:GetAttribute("StopDistance") or 5
				moveTowards(v3, humanoidRootPart.Position, chaseSpeed, dt, stopDistance)
			elseif (v3.root.Position - v3.spawnRootCFrame.Position).Magnitude > 0.1 then
				setState(v3, "Returning") -- equivalent call inferred; original call site unknown
				local returnSpeed = stage2LocalNPC:GetAttribute("ReturnSpeed") or 32
				moveTowards(v3, v3.spawnRootCFrame.Position, returnSpeed, dt, 0)
			else
				v3.model:PivotTo(v3.spawnCFrame)
				setState(v3, "Idle") -- equivalent call inferred; original call site unknown
			end
		else
			cleanupZone(k)
		end
	end
end)
local tagged = CollectionService:GetTagged("World4Stage2LocalNPCAttackZone")

for _, v3 in tagged do
	task.spawn(setupZone, v3)
end

CollectionService:GetInstanceAddedSignal("World4Stage2LocalNPCAttackZone"):Connect(function(p)
	task.spawn(setupZone, p)
end)
CollectionService:GetInstanceRemovedSignal("World4Stage2LocalNPCAttackZone"):Connect(function(part)
	if part:IsA("BasePart") then
		cleanupZone(part)
	end
end)