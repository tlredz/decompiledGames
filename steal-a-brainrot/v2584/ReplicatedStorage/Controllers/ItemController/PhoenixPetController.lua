local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
game:GetService("Lighting")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local _ = workspace.CurrentCamera
local controllers = ReplicatedStorage:WaitForChild("Controllers")
require(controllers.CharacterController)
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local remoteEvent = Net:RemoteEvent("UseItem")
local v = {}
local v2 = {}

local function smoothAlpha(p, value)
	return 1 - math.exp(-math.clamp(value, 0, 60) * p)
end

local function StartOrbitFor(instance)
	if v[instance] or not (instance and instance.Parent) then
		return
	end

	local ownerUserId = instance:GetAttribute("OwnerUserId")
	local startTime = instance:GetAttribute("StartTime") or workspace:GetServerTimeNow()

	if not ownerUserId then
		return
	end

	local playerByUserId = Players:GetPlayerByUserId(ownerUserId)

	if not (playerByUserId and playerByUserId.Character) then
		return
	end

	local humanoidRootPart = playerByUserId.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local pivot = instance:GetPivot()
	v[instance] = RunService.RenderStepped:Connect(function(dt)
		if instance.Parent then
			humanoidRootPart = playerByUserId.Character and playerByUserId.Character:FindFirstChild("HumanoidRootPart") or humanoidRootPart

			if not humanoidRootPart then
				return
			end

			local v3 = 0 + 1.0471975511965976 * (workspace:GetServerTimeNow() - startTime)
			local v4 = math.cos(v3) * 6
			local v5 = math.sin(v3) * 6
			local position = (humanoidRootPart.CFrame * CFrame.new(v4, 4, v5)).Position
			local v6 = humanoidRootPart.Position + createVector(0, 4, 0)
			local cframe = CFrame.lookAt(position, v6)
			local v7 = 1 - math.exp(-14 * dt)
			local v8 = 1 - math.exp(-18 * dt)
			pivot = pivot:Lerp(
				CFrame.new(cframe.Position) * CFrame.fromMatrix(
					createVector(0, 0, 0),
					cframe.RightVector,
					cframe.UpVector
				),
				v7
			)
			pivot = pivot:Lerp(cframe, v8)
			instance:PivotTo(pivot)
			local position2 = instance:GetPivot().Position
			local v9 = 1e999
			local v10 = nil

			for _, v11 in Players:GetPlayers() do
				if not (v11 ~= localPlayer and v11.Character) then
					continue
				end

				local humanoidRootPart2 = v11.Character:FindFirstChild("HumanoidRootPart")
				local humanoid = v11.Character:FindFirstChildOfClass("Humanoid")

				if not (humanoidRootPart2 and humanoid and humanoid.Health > 0) then
					continue
				end

				local magnitude = (humanoidRootPart2.Position - position2).Magnitude

				if not (magnitude <= 25 and magnitude < v9) then
					continue
				end

				v10 = humanoidRootPart2
				v9 = magnitude
			end

			if v10 then
				local vector2 = Vector3.new(v10.Position.X, position2.Y, v10.Position.Z)
				instance:PivotTo((CFrame.lookAt(position2, vector2)))
			end
		else
			v[instance]:Disconnect()
			v[instance] = nil
		end
	end)
end

local function EmitParticules(folder)
	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 5)
		end
	end
end

remoteEvent.OnClientEvent:Connect(function(p, p2)
	if p ~= "SpawnPhoenix" then
		return
	end

	StartOrbitFor(p2)
end)
remoteEvent.OnClientEvent:Connect(function(p: string, data)
	if p ~= "CreatePhoenixShoot" then
		return
	end

	local UUID = data.UUID
	local origin = data.Origin
	local direction = data.Direction
	local shootSpeed = data.ShootSpeed
	local clone = script.phoenixprojectile:Clone()
	clone.CFrame = CFrame.lookAt(origin, origin + direction)
	clone.CanCollide = false
	clone.Anchored = false
	clone.CanQuery = false
	clone.Parent = workspace
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Name = "FlightPower"
	bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
	bodyVelocity.Velocity = direction * shootSpeed
	bodyVelocity.Parent = clone
	local clone2 = script:FindFirstChild("Shoot") and script.Shoot:Clone()

	if clone2 then
		clone2.Parent = clone
		clone2:Play()
		task.delay(1, function()
			clone2:Destroy()
		end)
	end

	Debris:AddItem(clone, 2)
	clone.Destroying:Once(function()
		v2[UUID] = nil
	end)
	v2[UUID] = clone
	clone.Touched:Connect(function(otherPart)
		if not otherPart then
			return
		end

		local model = otherPart:FindFirstAncestorOfClass("Model")

		if not model then
			return
		end

		local playerFromCharacter = Players:GetPlayerFromCharacter(model)

		if playerFromCharacter and playerFromCharacter ~= localPlayer then
			if playerFromCharacter:GetAttribute("Web") then
				return
			end

			local clone3 = script.fireshoot:Clone()
			clone3.CFrame = model:GetPivot()
			clone3.Anchored = true
			clone3.Parent = workspace
			task.spawn(function()
				EmitParticules(clone3)
				Debris:AddItem(clone3, 1)
			end)
			clone:Destroy()
		end
	end)
end)
remoteEvent.OnClientEvent:Connect(function(p: string, p2)
	if p ~= "DestroyPhoenixBullet" then
		return
	end

	local UUID = p2.UUID

	if v2[UUID] then
		v2[UUID]:Destroy()
		v2[UUID] = nil
	end
end)
task.spawn(function()
	for _, model in workspace:GetChildren() do
		if not (model:IsA("Model") and model:GetAttribute("OwnerUserId") and model:GetAttribute("IsPhoenix")) then
			continue
		end

		StartOrbitFor(model)
	end
end)
return {}