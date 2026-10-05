local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Maid = require(game.ReplicatedStorage.Util.Maid)
local SewerSystem = require(game.ReplicatedStorage.Modules.World.SewerSystem)
local v = {
	RootPart = true,
	Crane = true,
	Rope = true,
	Platform = true
}
local v2 = {}
local positions = {}
local v3 = nil
local position = nil
local Cranes = {
	LoadForLocations = { "Fountain City" },
	Maid = Maid.new()
}

local function buildRig(model)
	if not model:IsA("Model") then
		return nil
	end

	local rootPart = model:FindFirstChild("RootPart")
	local platform = model:FindFirstChild("Platform")
	local platformMotor6D = platform and platform:FindFirstChild("PlatformMotor6D")
	local crane = model:FindFirstChild("Crane")
	local rope = model:FindFirstChild("Rope")
	local controller = rootPart and rootPart:FindFirstChild("Controller")
	local arm = controller and controller:FindFirstChild("Arm")
	local top = arm and arm:FindFirstChild("Top")
	local armCog = controller and controller:FindFirstChild("ArmCog")
	local groundCog = controller and controller:FindFirstChild("GroundCog")

	if not (rootPart and rootPart:IsA("BasePart") and platform and platform:IsA("BasePart") and platformMotor6D and platformMotor6D:IsA("Motor6D") and crane and crane:IsA("BasePart") and rope and rope:IsA("BasePart") and controller and top and armCog and groundCog) then
		return nil
	end

	if rootPart.Anchored then
		crane.Anchored = false
		rope.Anchored = false
	end

	local position2 = rootPart.Position
	local inverse = rootPart.CFrame:Inverse()
	local seed = math.floor((math.abs(position2.X * 73.856 + position2.Z * 19.349))) % 1000000
	local props = {}

	for _, part in model:GetChildren() do
		if not part:IsA("BasePart") or v[part.Name] then
			continue
		end

		local cFrame = part.CFrame
		table.insert(props, {
			part = part,
			rest = cFrame,
			restLocal = inverse * cFrame
		})
	end

	local manualLift = model.Name == SewerSystem.FOUNTAIN_CRANE_NAME
	local attribute = model:GetAttribute(SewerSystem.CRANE_IDLE_ROPE_DROP_ATTRIBUTE)
	local manualIdleDrop = (not manualLift or typeof(attribute) ~= "number") and 0 or attribute
	return {
		model = model,
		root = rootPart,
		controller = controller,
		platform = platform,
		platformRest = platform.CFrame,
		platformRestLocal = inverse * platform.CFrame,
		platformMotor = platformMotor6D,
		platformC0 = platformMotor6D.C0,
		crane = crane,
		rope = rope,
		top = top,
		armCog = armCog,
		groundCog = groundCog,
		props = props,
		manualLift = manualLift,
		manualIdleDrop = manualIdleDrop,
		manualLiftAlpha = manualLift and model:GetAttribute(SewerSystem.CRANE_LIFT_ATTRIBUTE) == true and 1 or 0,
		phase = (position2.X * 0.37 + position2.Z * 0.13) % 19,
		culled = false,
		seed = seed,
		swivelPhase = (position2.X * 0.71 + position2.Z * 0.29) % 16,
		slotK = -1,
		prevTarget = 0,
		target = 0,
		turnStart = 0,
		turnDur = 1.5,
		yaw = 0,
		sag = 0,
		sagVel = 0
	}
end

local function rigValid(data)
	for _, v4 in data.props do
		if v4.part.Parent == nil then
			return false
		end
	end

	if data.model.Parent == nil or data.root.Parent == nil or data.controller.Parent == nil or data.platform.Parent == nil or data.platformMotor.Parent == nil or data.crane.Parent == nil or data.rope.Parent == nil or data.top.Parent == nil or data.armCog.Parent == nil then
		return false
	else
		return data.groundCog.Parent ~= nil
	end
end

local function applyRig(data, p: number, p2: number, p3: number, p4: number?)
	local v4 = p + p3
	local v5 = (p4 or p) + p3
	local cframe = CFrame.Angles(0, p2, 0)
	data.controller.Transform = cframe
	data.top.Transform = CFrame.new(0, v4, 0)
	local v6 = p * 0.35 + p2 * 6
	data.armCog.Transform = CFrame.Angles(0, v6, 0)
	data.groundCog.Transform = CFrame.Angles(0, v6 * 0.52, 0)
	local v7 = cframe * CFrame.new(0, -v5, 0)

	if data.platform.Anchored then
		data.platform.CFrame = data.root.CFrame * v7 * data.platformRestLocal
	else
		data.platformMotor.Transform = data.platformC0:Inverse() * v7 * data.platformC0
	end

	for _, v8 in data.props do
		v8.part.CFrame = data.root.CFrame * v7 * v8.restLocal
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyManualLift(p, manualLiftAlpha: number)
	local v4 = -SewerSystem.CRANE_LIFT_HEIGHT * manualLiftAlpha
	applyRig(p, p.manualIdleDrop + v4, 0, 0, v4)
end

local function releaseRig(data)
	for _, v4 in data.props do
		if v4.part.Parent then
			v4.part.CFrame = v4.rest
		end
	end

	if data.platform.Parent then
		if data.platform.Anchored then
			data.platform.CFrame = data.platformRest
		else
			data.platformMotor.Transform = CFrame.identity
		end
	end

	v2[data.model] = nil
end

local function resetRigs()
	for _, v4 in v2 do
		if rigValid(v4) then
			v4.culled = false
			v4.yaw = 0
			v4.sag = 0
			v4.sagVel = 0

			if v4.manualLift then
				v4.manualLiftAlpha = v4.model:GetAttribute(SewerSystem.CRANE_LIFT_ATTRIBUTE) == true and 1 or 0
				applyManualLift(v4, v4.manualLiftAlpha) -- equivalent call inferred; original call site unknown
			else
				applyRig(v4, 0, 0, 0)
			end
		else
			releaseRig(v4)
		end
	end
end

local function hoistOffset(p: number)
	local v4 = p % 19

	if v4 < 6 then
		return 0
	end

	local v5 = v4 - 6

	if v5 < 5 then
		local v6 = v5 / 5
		return v6 * 10 * v6 * (3 - v6 * 2)
	end

	local v6 = v5 - 5

	if v6 < 3 then
		return 10
	end

	local v7 = (v6 - 3) / 5
	return (1 - v7 * v7 * (3 - v7 * 2)) * 10
end

local function collectOccupants()
	table.clear(positions)
	v3 = nil
	position = nil

	for _, v4 in Players:GetPlayers() do
		local character = v4.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			continue
		end

		table.insert(positions, humanoidRootPart.Position)

		if v4 ~= Players.LocalPlayer then
			continue
		end

		v3 = character
		position = humanoidRootPart.Position
	end
end

local function insidePlatform(cframe: CFrame, vector: Vector3)
	local pointToObjectSpace = cframe:PointToObjectSpace(vector)
	return math.abs(pointToObjectSpace.X) <= 21 and math.abs(pointToObjectSpace.Z) <= 21 and pointToObjectSpace.Y > 1 and pointToObjectSpace.Y < 15
end

local function platformOccupancy(p)
	local cFrame = p.platform.CFrame
	local count = 0

	for _, v4 in positions do
		local pointToObjectSpace = cFrame:PointToObjectSpace(v4)
		local v5

		if math.abs(pointToObjectSpace.X) <= 21 and math.abs(pointToObjectSpace.Z) <= 21 and pointToObjectSpace.Y > 1 then
			v5 = pointToObjectSpace.Y < 15
		else
			v5 = false
		end

		if v5 then
			count += 1
		end
	end

	return count
end

local function localRides(p)
	local v4 = position

	if not (v4 and v3) then
		return false
	end

	local pointToObjectSpace = p.platform.CFrame:PointToObjectSpace(v4)
	return math.abs(pointToObjectSpace.X) <= 21 and math.abs(pointToObjectSpace.Z) <= 21 and pointToObjectSpace.Y > 1 and pointToObjectSpace.Y < 15
end

local function carryRider(p, yaw: number)
	local v4 = v3

	if not (v4 and v4.Parent) then
		return
	end

	local cFrame = p.root.CFrame
	local cframe = cFrame * CFrame.Angles(0, yaw, 0)
	v4:PivotTo(cFrame * CFrame.Angles(0, p.yaw, 0) * cframe:Inverse() * v4:GetPivot())
end

-- equivalent calls inferred from this helper; original call sites unknown
local function slotTarget(seed: number, p: number)
	local v4 = 0.35 + 0.65 * Random.new(seed + p * 7919):NextNumber()
	return (p % 2 == 0 and 1 or -1) * 0.20943951023931956 * v4
end

local function refreshSlot(state, slotK: number)
	state.slotK = slotK
	state.prevTarget = slotTarget(state.seed, slotK - 1)
	state.target = slotTarget(state.seed, slotK)
	state.turnStart = Random.new(state.seed + slotK * 104729):NextNumber() * 8
	state.turnDur = math.clamp(math.abs(state.target - state.prevTarget) / 0.05235987755982989, 1.5, 8)
end

local function scheduledYaw(data, p: number)
	local v4 = p - data.swivelPhase
	local slotK = math.floor(v4 / 16)

	if slotK ~= data.slotK then
		refreshSlot(data, slotK)
	end

	local v6 = (v4 - slotK * 16 - data.turnStart) / data.turnDur

	if v6 <= 0 then
		return data.prevTarget
	end

	if v6 >= 1 then
		return data.target
	end

	return data.prevTarget + (data.target - data.prevTarget) * v6 * v6 * (3 - 2 * v6)
end

local function updateSwivel(p, p2: number, p3: number)
	local yaw2 = scheduledYaw(p, p2)
	local v5 = yaw2 - p.yaw
	local v6 = p3 * 0.20943951023931956

	if math.abs(v5) <= v6 then
		p.yaw = yaw2
		return
	end

	local yaw = p.yaw

	if not (v5 > 0) then
		v6 = -v6
	end

	p.yaw = yaw + v6
end

local function stepAll(p: number)
	local v4 = math.min(p, 0.1)
	local currentCamera = workspace.CurrentCamera
	local position2 = currentCamera and currentCamera.CFrame.Position
	local serverTimeNow = workspace:GetServerTimeNow()
	collectOccupants()
	local v5 = false

	for _, v6 in v2 do
		if rigValid(v6) then
			if v6.manualLift then
				local v7 = v6.model:GetAttribute(SewerSystem.CRANE_LIFT_ATTRIBUTE) == true and 1 or 0
				local manualLiftAlpha = v6.manualLiftAlpha
				local v8 = v4 / SewerSystem.CRANE_LIFT_TIME

				if manualLiftAlpha < v7 then
					manualLiftAlpha = math.min(manualLiftAlpha + v8, v7)
				elseif v7 < manualLiftAlpha then
					manualLiftAlpha = math.max(manualLiftAlpha - v8, v7)
				end

				v6.manualLiftAlpha = manualLiftAlpha
				applyManualLift(v6, manualLiftAlpha) -- equivalent call inferred; original call site unknown
			else
				if position2 then
					local magnitude = (v6.root.Position - position2).Magnitude

					if v6.culled then
						if magnitude < 750 then
							v6.culled = false
							v6.yaw = scheduledYaw(v6, serverTimeNow)
						end
					elseif magnitude > 850 then
						v6.culled = true
						applyRig(v6, 0, v6.yaw, 0)
					end
				elseif v6.culled then
					v6.culled = false
					v6.yaw = scheduledYaw(v6, serverTimeNow)
				end

				if not v6.culled then
					local cFrame = v6.platform.CFrame
					local count = 0

					for _, v7 in positions do
						local pointToObjectSpace = cFrame:PointToObjectSpace(v7)
						local v8

						if math.abs(pointToObjectSpace.X) <= 21 and math.abs(pointToObjectSpace.Z) <= 21 and pointToObjectSpace.Y > 1 then
							v8 = pointToObjectSpace.Y < 15
						else
							v8 = false
						end

						if v8 then
							count += 1
						end
					end

					local v7 = not v5

					if v7 then
						local v8 = position

						if v8 and v3 then
							local pointToObjectSpace = v6.platform.CFrame:PointToObjectSpace(v8)

							if math.abs(pointToObjectSpace.X) <= 21 and math.abs(pointToObjectSpace.Z) <= 21 and pointToObjectSpace.Y > 1 then
								v7 = pointToObjectSpace.Y < 15
							else
								v7 = false
							end
						else
							v7 = false
						end
					end

					local v8 = (math.min(count, 1) * 6 - v6.sag) * 16 - v6.sagVel * 5
					v6.sagVel += v8 * v4
					v6.sag += v6.sagVel * v4
					local yaw = v6.yaw
					local yaw3 = scheduledYaw(v6, serverTimeNow)
					local v10 = yaw3 - v6.yaw
					local v11 = v4 * 0.20943951023931956

					if math.abs(v10) <= v11 then
						v6.yaw = yaw3
					else
						local yaw2 = v6.yaw

						if not (v10 > 0) then
							v11 = -v11
						end

						v6.yaw = yaw2 + v11
					end

					local v13 = (serverTimeNow + v6.phase) % 19
					local v14

					if v13 < 6 then
						v14 = 0
					else
						local v15 = v13 - 6

						if v15 < 5 then
							local v16 = v15 / 5
							v14 = v16 * 10 * v16 * (3 - v16 * 2)
						else
							local v16 = v15 - 5

							if v16 < 3 then
								v14 = 10
							else
								local v17 = (v16 - 3) / 5
								v14 = (1 - v17 * v17 * (3 - v17 * 2)) * 10
							end
						end
					end

					applyRig(v6, v14, v6.yaw, v6.sag)

					if v7 and v6.yaw ~= yaw then
						carryRider(v6, yaw)
						v5 = true
					end
				end
			end
		else
			releaseRig(v6)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addRig(child)
	if v2[child] then
		return
	end

	local rig = buildRig(child)

	if rig then
		v2[child] = rig
		rig.yaw = scheduledYaw(rig, workspace:GetServerTimeNow())
	end
end

function Cranes.RegionEntered(p)
	p.Maid:GiveTask(task.spawn(function()
		local fountain = workspace:WaitForChild("Map"):WaitForChild("Fountain", 30)

		if not fountain then
			return
		end

		local cranes = fountain:WaitForChild("Cranes", 30)

		if not cranes then
			return
		end

		for _, child in cranes:GetChildren() do
			addRig(child) -- equivalent call inferred; original call site unknown
		end

		p.Maid:GiveTask(cranes.ChildAdded:Connect(addRig))
		p.Maid:GiveTask(cranes.ChildRemoved:Connect(function(child)
			local v4 = v2[child]

			if v4 then
				releaseRig(v4)
			end
		end))
		local serverTimeNow = workspace:GetServerTimeNow()

		for _, v4 in v2 do
			v4.yaw = scheduledYaw(v4, serverTimeNow)
		end

		p.Maid:GiveTask(RunService.PreAnimation:Connect(stepAll))
	end))
end

function Cranes.RegionLeaving(_)
	resetRigs()
end

return Cranes