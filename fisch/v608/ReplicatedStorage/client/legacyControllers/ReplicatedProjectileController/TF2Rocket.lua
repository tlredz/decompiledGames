local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MeteorFireball = require(ReplicatedStorage.client.modules.MeteorFireball)
local SharedRocketLauncher = require(ReplicatedStorage.shared.modules.SharedRocketLauncher)
local TF2Rocket = {
	Tags = { SharedRocketLauncher.PROJECTILE_TAG },
	Objects = {},
	Data = {}
}
local debrisfx = workspace:WaitForChild("active"):WaitForChild("debrisfx")
local localPlayer = Players.LocalPlayer
local vector2 = nil
local now = 0

local function getLocalBody()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoid and not (humanoid.Health <= 0) and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoid, humanoidRootPart
	end

	return nil, nil
end

local function emitAll(folder)
	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 10)
		end
	end
end

local function stepBlastJump(p: number)
	if not vector2 then
		return
	end

	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoid or humanoid.Health <= 0 or not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoid = nil
		humanoidRootPart = nil
	end

	if not humanoid or not humanoidRootPart or humanoid.Sit then
		vector2 = nil
		return
	end

	local state = humanoid:GetState()
	local v

	if humanoid.FloorMaterial == Enum.Material.Air then
		v = false
	else
		v = os.clock() - now > 0.25
	end

	if v or state == Enum.HumanoidStateType.Swimming or state == Enum.HumanoidStateType.Climbing then
		vector2 = nil
		return
	end

	local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
	local vector3 = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)
	local vector4 = vector2

	if (vector3 - vector4).Magnitude > 10 then
		vector4 = vector3
	end

	local v2 = humanoid.MoveDirection * createVector(1, 0, 1)

	if v2.Magnitude > 0.01 then
		local unit = v2.Unit
		local v3 = SharedRocketLauncher.AIR_SPEED_CAP * SharedRocketLauncher.velocityScale() - vector4:Dot(unit)

		if v3 > 0 then
			vector4 += unit * math.min(
				SharedRocketLauncher.AIR_ACCELERATE * SharedRocketLauncher.AIR_WISH_SPEED * SharedRocketLauncher.accelerationScale() * p,
				v3
			)
		end
	end

	if vector4.Magnitude < humanoid.WalkSpeed then
		vector2 = nil
		return
	end

	vector2 = vector4
	humanoidRootPart.AssemblyLinearVelocity = Vector3.new(vector4.X, assemblyLinearVelocity.Y, vector4.Z)
end

local function applyKnockback(data)
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoid or humanoid.Health <= 0 or not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoid = nil
		humanoidRootPart = nil
	end

	if not humanoid or not humanoidRootPart or humanoid.Sit then
		return
	end

	local owner = data.Args.owner
	local playerByUserId = owner and Players:GetPlayerByUserId(owner)
	local humanoidRootPart2 = playerByUserId and playerByUserId.Character and playerByUserId.Character:FindFirstChild("HumanoidRootPart")
	local v = {
		explosion = data.Position.Position,
		victimPosition = humanoidRootPart.Position,
		attackerPosition = humanoidRootPart2 and humanoidRootPart2.Position,
		isSelf = owner == localPlayer.UserId,
		isDirectHit = false,
		airborne = SharedRocketLauncher.isAirborne(humanoid.Parent)
	}
	local pushVelocity = SharedRocketLauncher.getPushVelocity(v, SharedRocketLauncher.getDamage(v))

	if pushVelocity == createVector(0, 0, 0) then
		return
	end

	if not v.airborne and pushVelocity.Y > 0 then
		humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	end

	local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity + pushVelocity
	humanoidRootPart.AssemblyLinearVelocity = assemblyLinearVelocity
	vector2 = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)
	now = os.clock()
end

function TF2Rocket.Init()
	RunService.RenderStepped:Connect(function(dt: number)
		for k, object in TF2Rocket.Objects do
			local v = TF2Rocket.Data[k]

			if v.Velocity.Magnitude <= 0 then
				continue
			end

			local v2 = math.min(v.Velocity.Magnitude * dt, v.ExpectedDistance - v.TraveledDistance)
			object:PivotTo(object:GetPivot() + v.Velocity.Unit * v2)
			v.TraveledDistance += v2

			if v.TraveledDistance >= v.ExpectedDistance then
				v.Velocity = createVector(0, 0, 0)
			end
		end
	end)
	RunService.PreSimulation:Connect(stepBlastJump)
end

function TF2Rocket.ProjectileCreated(data)
	local clone = script.Rocket:Clone()
	clone:PivotTo(CFrame.lookAlong(data.Position.Position, data.Velocity))
	clone.Parent = debrisfx
	TF2Rocket.Objects[data.Id] = clone
	TF2Rocket.Data[data.Id] = data
	local tool = data.Args.tool
	local handle

	if typeof(tool) == "Instance" then
		handle = tool:FindFirstChild("Handle")
	else
		handle = false
	end

	if handle then
		local fire = handle:FindFirstChild("Fire")

		if fire and fire:IsA("Sound") then
			fire:Play()
		end

		local muzzle = handle:FindFirstChild("Muzzle")

		if muzzle then
			emitAll(muzzle)
		end
	end
end

function TF2Rocket.ProjectileStopped(data)
	local folder = TF2Rocket.Objects[data.Id]
	TF2Rocket.Objects[data.Id] = nil
	TF2Rocket.Data[data.Id] = nil
	local v = data.TraveledDistance <= data.Projectile.MaxDistance - 1

	if v then
		applyKnockback(data)
	end

	if folder then
		folder:PivotTo(CFrame.lookAlong(data.Position.Position, data.Velocity))

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.Transparency = 1
			elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Light") then
				descendant.Enabled = false
			end
		end

		task.delay(2, folder.Destroy, folder)
	end

	if not v then
		return
	end

	local position = data.Position.Position
	local clone = script.Explosion:Clone()
	clone.Position = position
	clone.Parent = debrisfx
	emitAll(clone)
	local explode = clone:FindFirstChild("Explode")

	if explode and explode:IsA("Sound") then
		explode:Play()
	end

	local light = clone:FindFirstChildWhichIsA("Light")

	if light then
		TweenService:Create(light, TweenInfo.new(0.4), {
			Brightness = 0
		}):Play()
	end

	MeteorFireball.Create(position, 10, 1)
	task.delay(3, clone.Destroy, clone)
end

return TF2Rocket