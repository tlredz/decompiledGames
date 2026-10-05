local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local stage11LocalNPC = ReplicatedStorage:WaitForChild("Stage11LocalNPC")

if not (stage11LocalNPC and stage11LocalNPC:IsA("Model")) then
	warn("[Stage11LocalNPC] Template Model introuvable : ReplicatedStorage.Stage11LocalNPC")
	return
end

local v = {}

local function getPositiveAttribute(attributeName: string, p: number)
	local attribute = stage11LocalNPC:GetAttribute(attributeName)

	if typeof(attribute) == "number" and attribute > 0 then
		return attribute
	end

	return p
end

local function isInsideZone(instance, position: Vector3)
	local pointToObjectSpace = instance.CFrame:PointToObjectSpace(position)
	return math.abs(pointToObjectSpace.X) <= instance.Size.X / 2 and math.abs(pointToObjectSpace.Y) <= math.max(
		instance.Size.Y / 2,
		30
	) and math.abs(pointToObjectSpace.Z) <= instance.Size.Z / 2
end

local function setState(state, state2: string)
	if state.state == state2 then
		return
	end

	state.state = state2

	if state.chaseSound then
		if state2 == "Chasing" and not state.chaseSound.IsPlaying then
			state.chaseSound:Play()
		elseif state2 ~= "Chasing" and state.chaseSound.IsPlaying then
			state.chaseSound:Stop()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanupZone(p)
	local v2 = v[p]

	if not v2 then
		return
	end

	v2.hitboxConnection:Disconnect()

	if v2.chaseSound then
		v2.chaseSound:Stop()
	end

	v2.model:Destroy()
	v[p] = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pivotFromRoot(p, cframe: CFrame)
	p.model:PivotTo(cframe * p.rootOffsetFromPivot:Inverse())
end

local function moveTowards(p, vector: Vector3, p2: number, p3: number, p4: number)
	local cFrame = p.root.CFrame
	local position = cFrame.Position
	local v2 = Vector3.new(vector.X, p.spawnRootCFrame.Position.Y, vector.Z) - position
	local magnitude = v2.Magnitude

	if magnitude <= p4 or magnitude <= 0.001 then
		return
	end

	local v3 = math.min(p2 * math.min(p3, 0.1), magnitude - p4)
	local v4 = position + v2.Unit * v3
	pivotFromRoot(p, CFrame.new(v4) * cFrame.Rotation) -- equivalent call inferred; original call site unknown
end

local function setupZone(part)
	if not part:IsA("BasePart") or v[part] then
		return
	end

	local clone = stage11LocalNPC:Clone()
	clone.Name = "Stage11LocalNPC_Local"
	local tornado = clone:FindFirstChild("Tornado", true)
	local hitbox = clone:FindFirstChild("Hitbox", true)
	local tornadoModelSpin = tornado and tornado:FindFirstChild("TornadoModelSpin")

	if tornado and tornado:IsA("BasePart") and hitbox and hitbox:IsA("BasePart") and tornadoModelSpin and tornadoModelSpin:IsA("BasePart") then
		for _, part2 in clone:GetDescendants() do
			if not part2:IsA("BasePart") then
				continue
			end

			part2.Anchored = true
			part2.CanCollide = false
		end

		hitbox.CanTouch = true
		local pivot = stage11LocalNPC:GetPivot()
		clone:PivotTo(pivot)
		local cFrame = tornado.CFrame
		local objectSpace = pivot:ToObjectSpace(cFrame)
		clone.Parent = workspace
		local chaseMusic = tornado:FindFirstChild("ChaseMusic", true)

		if not (chaseMusic and chaseMusic:IsA("Sound")) then
			chaseMusic = nil
		end

		if chaseMusic then
			chaseMusic.Looped = true
		end

		v[part] = {
			zone = part,
			model = clone,
			root = tornado,
			spinPart = tornadoModelSpin,
			spawnPivot = pivot,
			spawnRootCFrame = cFrame,
			rootOffsetFromPivot = objectSpace,
			hitboxConnection = hitbox.Touched:Connect(function(otherPart)
				local character = localPlayer.Character

				if not (character and otherPart:IsDescendantOf(character)) then
					return
				end

				local humanoid = character:FindFirstChildOfClass("Humanoid")

				if humanoid and humanoid.Health > 0 then
					humanoid.Health = 0
				end
			end),
			chaseSound = chaseMusic,
			state = "Idle"
		}
	else
		warn("[Stage11LocalNPC] Tornado, TornadoModelSpin ou Hitbox introuvable dans", stage11LocalNPC:GetFullName())
		clone:Destroy()
	end
end

RunService.PreRender:Connect(function(dt)
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	for k, v2 in v do
		if k:IsDescendantOf(workspace) and v2.model.Parent then
			local spinSpeed = stage11LocalNPC:GetAttribute("SpinSpeed")
			local v3 = (typeof(spinSpeed) ~= "number" or not (spinSpeed > 0)) and 180 or spinSpeed
			v2.spinPart.CFrame *= CFrame.Angles(0, math.rad(v3) * dt, 0)
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
				if v2.state ~= "Chasing" then
					v2.state = "Chasing"

					if v2.chaseSound and not v2.chaseSound.IsPlaying then
						v2.chaseSound:Play()
					end
				end

				local position = humanoidRootPart.Position
				local chaseSpeed = stage11LocalNPC:GetAttribute("ChaseSpeed")
				local v6 = (typeof(chaseSpeed) ~= "number" or not (chaseSpeed > 0)) and 22 or chaseSpeed
				local stopDistance = stage11LocalNPC:GetAttribute("StopDistance")
				moveTowards(
					v2,
					position,
					v6,
					dt,
					(typeof(stopDistance) ~= "number" or not (stopDistance > 0)) and 5 or stopDistance
				)
			else
				local v5 = v2.root.Position - v2.spawnRootCFrame.Position

				if Vector2.new(v5.X, v5.Z).Magnitude > 0.1 then
					if v2.state ~= "Returning" then
						v2.state = "Returning"

						if v2.chaseSound and v2.chaseSound.IsPlaying then
							v2.chaseSound:Stop()
						end
					end

					local position = v2.spawnRootCFrame.Position
					local returnSpeed = stage11LocalNPC:GetAttribute("ReturnSpeed")
					moveTowards(
						v2,
						position,
						(typeof(returnSpeed) ~= "number" or not (returnSpeed > 0)) and 32 or returnSpeed,
						dt,
						0
					)
				else
					v2.model:PivotTo(v2.spawnPivot)

					if v2.state ~= "Idle" then
						v2.state = "Idle"

						if v2.chaseSound and v2.chaseSound.IsPlaying then
							v2.chaseSound:Stop()
						end
					end
				end
			end
		else
			cleanupZone(k) -- equivalent call inferred; original call site unknown
		end
	end
end)

for _, v2 in CollectionService:GetTagged("World4Stage11LocalNPCAttackZone") do
	task.spawn(setupZone, v2)
end

CollectionService:GetInstanceAddedSignal("World4Stage11LocalNPCAttackZone"):Connect(function(p)
	task.spawn(setupZone, p)
end)
CollectionService:GetInstanceRemovedSignal("World4Stage11LocalNPCAttackZone"):Connect(function(part)
	if part:IsA("BasePart") then
		cleanupZone(part) -- equivalent call inferred; original call site unknown
	end
end)