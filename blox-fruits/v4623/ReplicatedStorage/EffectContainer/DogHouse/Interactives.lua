local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function hasAncestorNamed(parent, p: string)
	while parent do
		if parent.Name == p then
			return true
		else
			parent = parent.Parent
		end
	end

	return false
end

local function getBounds(folder)
	local vector2 = createVector(1e999, 1e999, 1e999)
	local vector3 = createVector(-1e999, -1e999, -1e999)
	local flag = false

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local cFrame = part.CFrame
		local size = part.Size
		local v = {
			cFrame * Vector3.new(-size.X / 2, -size.Y / 2, -size.Z / 2),
			cFrame * Vector3.new(-size.X / 2, -size.Y / 2, size.Z / 2),
			cFrame * Vector3.new(-size.X / 2, size.Y / 2, -size.Z / 2),
			cFrame * Vector3.new(-size.X / 2, size.Y / 2, size.Z / 2),
			cFrame * Vector3.new(size.X / 2, -size.Y / 2, -size.Z / 2),
			cFrame * Vector3.new(size.X / 2, -size.Y / 2, size.Z / 2),
			cFrame * Vector3.new(size.X / 2, size.Y / 2, -size.Z / 2),
			cFrame * Vector3.new(size.X / 2, size.Y / 2, size.Z / 2)
		}
		flag = true

		for _, v2 in ipairs(v) do
			vector2 = Vector3.new(math.min(vector2.X, v2.X), math.min(vector2.Y, v2.Y), (math.min(vector2.Z, v2.Z)))
			vector3 = Vector3.new(math.max(vector3.X, v2.X), math.max(vector3.Y, v2.Y), (math.max(vector3.Z, v2.Z)))
		end
	end

	if flag then
		return vector2, vector3
	end

	return nil, nil
end

local function pointInsideXZ(vector2: Vector3, vector3: Vector3, vector4: Vector3, value: number?)
	local v = value or 0
	return vector2.X >= vector3.X - v and vector2.X <= vector4.X + v and vector2.Z >= vector3.Z - v and vector2.Z <= vector4.Z + v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function prepVisualPart(instance)
	instance.Anchored = true
	instance.CanCollide = true
	instance.CanTouch = false
	instance.CanQuery = false
	instance.Massless = true
end

local function setupTrampoline(folder, list, connections)
	local bounds, max = getBounds(folder)

	if not (bounds and max) then
		return
	end

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = true
		part.CanTouch = true
		part.CanQuery = true
	end

	local v2 = max - bounds
	local center = (bounds + max) * 0.5
	local part = Instance.new("Part")
	part.Name = "DogHouseTrampolineHitbox"
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = true
	part.CanQuery = false
	part.Transparency = 1
	part.Size = Vector3.new(math.max(v2.X, 12), 5, (math.max(v2.Z, 12)))
	part.CFrame = CFrame.new(center.X, max.Y + 1.75, center.Z)
	part.Parent = folder
	table.insert(list, {
		Min = bounds,
		Max = max,
		TopY = max.Y,
		Center = center,
		Hitbox = part,
		LastBallBounce = {}
	})
	local nowsByHumanoidRootPart = {}
	table.insert(connections, (part.Touched:Connect(function(otherPart)
		if not (otherPart and otherPart.Parent) then
			return
		end

		local model = otherPart:FindFirstAncestorOfClass("Model")

		if not model then
			return
		end

		local humanoid = model:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")

		if not (humanoid and humanoidRootPart and humanoidRootPart:IsA("BasePart")) or humanoidRootPart.Position.Y < part.Position.Y - 4 then
			return
		end

		local now = os.clock()

		if nowsByHumanoidRootPart[humanoidRootPart] and now - nowsByHumanoidRootPart[humanoidRootPart] < 0.22 then
			return
		end

		nowsByHumanoidRootPart[humanoidRootPart] = now
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
		humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
			assemblyLinearVelocity.X * 1.05,
			math.max(assemblyLinearVelocity.Y, 225),
			assemblyLinearVelocity.Z * 1.05
		)
	end)))
end

local function buildBallRaycastParams(folder, instance)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	local filterDescendantsInstances = { instance }
	local characters = workspace:FindFirstChild("Characters")

	if characters then
		table.insert(filterDescendantsInstances, characters)
	end

	local enemies = workspace:FindFirstChild("Enemies")

	if enemies then
		table.insert(filterDescendantsInstances, enemies)
	end

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local parent = part
		local v2

		while true do
			if not parent then
				v2 = false
				break
			end

			if parent.Name == "GiantBall1" then
				v2 = true
				break
			else
				parent = parent.Parent
			end
		end

		if not v2 then
			local parent2 = part
			local v3

			while true do
				if not parent2 then
					v3 = false
					break
				end

				if parent2.Name == "GiantBall2" then
					v3 = true
					break
				else
					parent2 = parent2.Parent
				end
			end

			if not v3 then
				local parent3 = part
				local v4

				while true do
					if not parent3 then
						v4 = false
						break
					end

					if parent3.Name == "GiantBall3" then
						v4 = true
						break
					else
						parent3 = parent3.Parent
					end
				end

				if not v4 then
					local parent4 = part
					local v5

					while true do
						if not parent4 then
							v5 = false
							break
						end

						if parent4.Name == "VolleyBall" then
							v5 = true
							break
						else
							parent4 = parent4.Parent
						end
					end

					if not v5 and part.Name ~= "VolleyBall" and part.Name ~= "DogHouseTrampolineHitbox" then
						continue
					end
				end
			end
		end

		table.insert(filterDescendantsInstances, part)
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	return raycastParams
end

local function makeFakeBall(part, data, p)
	prepVisualPart(part) -- equivalent call inferred; original call site unknown
	local radius = math.max(part.Size.X, part.Size.Y, part.Size.Z) * 0.5
	local cFrame = part.CFrame
	local position = cFrame.Position
	return {
		Part = part,
		Position = position,
		Velocity = createVector(0, 0, 0),
		Rotation = cFrame.Rotation,
		SpawnPosition = position,
		GroundY = position.Y,
		Radius = radius,
		RaycastParams = buildBallRaycastParams(p, part),
		PushPower = data.PushPower or 95,
		MaxSpeed = data.MaxSpeed or 95,
		Friction = data.Friction or 0.975,
		Gravity = data.Gravity or 155,
		GroundBounce = data.GroundBounce or 0.52,
		WallBounce = data.WallBounce or 0.65,
		MaxDistance = data.MaxDistance or 130,
		LastPlayerPush = 0
	}
end

local function applyPlayerPushToBall(state, players, p: number)
	local part = state.Part

	if not (part and part.Parent) then
		return
	end

	local position = state.Position
	local radius = state.Radius

	for _, v in ipairs(players) do
		local character = v.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoid and humanoid.Health > 0) then
			continue
		end

		local v2 = position - humanoidRootPart.Position
		local vector2 = Vector3.new(v2.X, 0, v2.Z)
		local magnitude = vector2.Magnitude
		local v3 = radius + 7

		if not (magnitude > 0.05 and magnitude <= v3) then
			continue
		end

		local unit = vector2.Unit
		local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
		local v4 = math.clamp(
			Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude / 28,
			0.45,
			1.65
		)
		local v5 = math.clamp((v3 - magnitude) / v3, 0.2, 1)
		state.Velocity += unit * state.PushPower * v4 * v5 * p

		if humanoidRootPart.Position.Y > position.Y + radius * 0.25 then
			state.Velocity += Vector3.new(0, p * 24, 0)
		end

		state.LastPlayerPush = os.clock()
	end
end

local function applyTrampolineToBall(state, list)
	local part = state.Part

	if not (part and part.Parent) then
		return
	end

	local position = state.Position
	local radius = state.Radius

	for _, v in ipairs(list) do
		if not (v.Hitbox and v.Hitbox.Parent) then
			continue
		end

		local min = v.Min
		local max = v.Max
		local v2 = radius * 0.25 or 0
		local v3

		if position.X >= min.X - v2 and position.X <= max.X + v2 and position.Z >= min.Z - v2 then
			v3 = position.Z <= max.Z + v2
		else
			v3 = false
		end

		if not (v3 and position.Y - radius <= v.TopY + 4 and state.Velocity.Y <= 25) then
			continue
		end

		local v4 = v.LastBallBounce[part] or 0
		local now = os.clock()

		if not (now - v4 >= 0.22) then
			continue
		end

		v.LastBallBounce[part] = now
		state.Position = Vector3.new(position.X, v.TopY + radius + 3, position.Z)
		state.Velocity = Vector3.new(state.Velocity.X * 1.05, math.max(state.Velocity.Y, 155), state.Velocity.Z * 1.05)
	end
end

local function clampBallToSpawnArea(state)
	local position = state.Position
	local spawnPosition = state.SpawnPosition
	local vector2 = Vector3.new(position.X - spawnPosition.X, 0, position.Z - spawnPosition.Z)
	local magnitude = vector2.Magnitude

	if magnitude <= state.MaxDistance or magnitude <= 0.01 then
		return
	end

	local unit = vector2.Unit
	local v = unit * state.MaxDistance
	state.Position = Vector3.new(spawnPosition.X + v.X, position.Y, spawnPosition.Z + v.Z)
	local vector3 = Vector3.new(state.Velocity.X, 0, state.Velocity.Z)
	local dot = vector3:Dot(unit)

	if dot > 0 then
		local v2 = vector3 - unit * dot * (1 + state.WallBounce)
		state.Velocity = Vector3.new(v2.X, state.Velocity.Y, v2.Z)
	end
end

local function resolveWallCollision(data, position: Vector3, vector2: Vector3, vector3: Vector3)
	local v = vector2 - position
	local vector4 = Vector3.new(v.X, 0, v.Z)

	if vector4.Magnitude <= 0.01 then
		return vector2, vector3
	end

	local v2 = math.max(1, data.Radius + -1.5)
	local v3 = position + Vector3.new(0, math.clamp(data.Radius * 0.28, 2, 12), 0)
	local spherecast = workspace:Spherecast(v3, v2, vector4, data.RaycastParams)

	if not spherecast then
		return vector2, vector3
	end

	local instance = spherecast.Instance

	if instance and instance:IsA("BasePart") and instance.CanCollide == false or math.abs(spherecast.Normal.Y) > 0.65 then
		return vector2, vector3
	end

	local v4 = position + vector4.Unit * math.max(spherecast.Distance - 0.35, 0)
	local vector5 = Vector3.new(v4.X, vector2.Y, v4.Z)
	local vector6 = Vector3.new(spherecast.Normal.X, 0, spherecast.Normal.Z)

	if vector6.Magnitude < 0.01 then
		return vector5, (Vector3.new(0, vector3.Y, 0))
	end

	local unit = vector6.Unit
	local vector7 = Vector3.new(vector3.X, 0, vector3.Z)
	local v5 = (vector7 - unit * (2 * vector7:Dot(unit))) * data.WallBounce
	local vector8 = Vector3.new(v5.X, vector3.Y, v5.Z)
	return vector5 + unit * 0.35, vector8
end

local function stepFakeBall(state, p: number)
	local part = state.Part

	if not (part and part.Parent) then
		return false
	end

	local v = state.Velocity + Vector3.new(0, -state.Gravity * p, 0)
	local vector2 = Vector3.new(v.X * state.Friction, v.Y, v.Z * state.Friction)
	local vector3 = Vector3.new(vector2.X, 0, vector2.Z)

	if vector3.Magnitude > state.MaxSpeed then
		local v2 = vector3.Unit * state.MaxSpeed
		vector2 = Vector3.new(v2.X, vector2.Y, v2.Z)
	end

	local position = state.Position
	local wallCollision, vector4 = resolveWallCollision(state, position, position + vector2 * p, vector2)

	if wallCollision.Y < state.GroundY then
		wallCollision = Vector3.new(wallCollision.X, state.GroundY, wallCollision.Z)

		if vector4.Y < -8 then
			vector4 = Vector3.new(vector4.X * 0.92, -vector4.Y * state.GroundBounce, vector4.Z * 0.92)
		else
			vector4 = Vector3.new(vector4.X, 0, vector4.Z)
		end
	end

	state.Position = wallCollision
	state.Velocity = vector4
	clampBallToSpawnArea(state)
	local vector5 = Vector3.new(state.Velocity.X, 0, state.Velocity.Z)
	local magnitude = vector5.Magnitude

	if magnitude > 0.05 then
		local vector6 = Vector3.new(-vector5.Z, 0, vector5.X)

		if vector6.Magnitude > 0.01 then
			local v3 = magnitude * p / math.max(state.Radius, 1)
			state.Rotation = CFrame.fromAxisAngle(vector6.Unit, v3) * state.Rotation
		end
	end

	part.CFrame = CFrame.new(state.Position) * state.Rotation
	return true
end

local function setupFakeBalls(folder, map)
	local result = {}

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local parent = part
		local v

		while true do
			if not parent then
				v = false
				break
			end

			if parent.Name == "GiantBall1" then
				v = true
				break
			else
				parent = parent.Parent
			end
		end

		if not v then
			local parent2 = part
			local v2

			while true do
				if not parent2 then
					v2 = false
					break
				end

				if parent2.Name == "GiantBall2" then
					v2 = true
					break
				else
					parent2 = parent2.Parent
				end
			end

			if not v2 then
				local parent3 = part
				local v3

				while true do
					if not parent3 then
						v3 = false
						break
					end

					if parent3.Name == "GiantBall3" then
						v3 = true
						break
					else
						parent3 = parent3.Parent
					end
				end

				if not v3 then
					if part.Name ~= "VolleyBall" then
						local parent4 = part
						local v4

						while true do
							if not parent4 then
								v4 = false
								break
							end

							if parent4.Name == "VolleyBall" then
								v4 = true
								break
							else
								parent4 = parent4.Parent
							end
						end

						if not v4 then
							continue
						end
					end

					table.insert(result, (makeFakeBall(part, {
						PushPower = 135,
						MaxSpeed = 125,
						Friction = 0.982,
						Gravity = 135,
						GroundBounce = 0.68,
						WallBounce = 0.72,
						MaxDistance = 150
					}, map)))
					continue
				end
			end
		end

		table.insert(result, (makeFakeBall(part, {
			PushPower = 95,
			MaxSpeed = 95,
			Friction = 0.975,
			Gravity = 155,
			GroundBounce = 0.52,
			WallBounce = 0.65,
			MaxDistance = 130
		}, map)))
	end

	return result
end

return function(p)
	local map = p and p.Map

	if not (map and map:IsA("Model") and map:GetAttribute("DogHouseInteractivesReady") ~= true) then
		return
	end

	map:SetAttribute("DogHouseInteractivesReady", true)
	local interior = map:FindFirstChild("Interior")

	if not interior then
		return
	end

	local v = {}
	local v2 = {}

	for _, descendant in ipairs(interior:GetDescendants()) do
		if descendant.Name == "Trampoline" then
			setupTrampoline(descendant, v, v2)
		end
	end

	local v3 = setupFakeBalls(interior, map)
	local v4 = true
	local players = Players:GetPlayers()
	local total = 0
	table.insert(v2, Players.PlayerAdded:Connect(function(player)
		table.insert(players, player)
	end))
	table.insert(v2, Players.PlayerRemoving:Connect(function(player)
		for i = #players, 1, -1 do
			if players[i] == player then
				table.remove(players, i)
			end
		end
	end))
	table.insert(v2, map.Destroying:Connect(function()
		v4 = false

		for _, connection in ipairs(v2) do
			if connection.Connected then
				connection:Disconnect()
			end
		end

		table.clear(v2)
		table.clear(v3)
		table.clear(v)
	end))
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if v4 and map.Parent then
			local v5 = math.min(dt, 0.05)
			total += v5

			if total >= 0.05 then
				total = 0
				players = Players:GetPlayers()
			end

			for i = #v3, 1, -1 do
				local v6 = v3[i]

				if v6.Part and v6.Part.Parent then
					applyPlayerPushToBall(v6, players, v5)
					applyTrampolineToBall(v6, v)

					if not stepFakeBall(v6, v5) then
						table.remove(v3, i)
					end
				else
					table.remove(v3, i)
				end
			end
		else
			if heartbeatConnection and heartbeatConnection.Connected then
				heartbeatConnection:Disconnect()
			end

			for _, connection in ipairs(v2) do
				if connection.Connected then
					connection:Disconnect()
				end
			end
		end
	end)
	table.insert(v2, heartbeatConnection)
end