local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local darkWisp = script:WaitForChild("DarkWisp")
local v = {}
local renderSteppedConnection = nil
local folder = nil
local flag = false

local function setEmittersEnabled(folder2, enabled: boolean)
	for _, effect in ipairs(folder2:GetDescendants()) do
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = enabled
		elseif effect:IsA("Trail") then
			effect.Enabled = enabled
		elseif effect:IsA("Beam") then
			effect.Enabled = enabled
		end
	end
end

local function randomPointInArea(part)
	local halfSize = part.Size / 2
	local v3 = (math.random() - 0.5) * 2 * halfSize.X
	local v4 = (math.random() - 0.5) * 2 * halfSize.Z
	local pointToWorldSpace = part.CFrame:PointToWorldSpace((Vector3.new(v3, 0, v4)))
	return (Vector3.new(pointToWorldSpace.X, part.Position.Y + 3, pointToWorldSpace.Z))
end

local function newWanderDirection()
	local v2 = math.random() * 3.141592653589793 * 2
	return Vector3.new(math.cos(v2), 0, (math.sin(v2))), 2 + math.random() * 4
end

local function spawnDarkWisps()
	if flag then
		return
	end

	local tagged = CollectionService:GetTagged("HadesWispArea")

	if #tagged == 0 then
		return
	end

	folder = Instance.new("Folder")
	folder.Name = "SoulScourgeWisps"
	folder.Parent = Workspace
	local v2 = math.max(1, (math.ceil(50 / #tagged)))
	local count = 0

	for _, part in ipairs(tagged) do
		if not part:IsA("BasePart") then
			continue
		end

		for _ = 1, v2 do
			count += 1

			if count > 50 then
				break
			end

			local pos = randomPointInArea(part)
			local v4 = math.random() * 3.141592653589793 * 2
			local vector2 = Vector3.new(math.cos(v4), 0, (math.sin(v4)))
			local wanderTimer = 2 + math.random() * 4
			local v6 = (math.random() - 0.5) * 2 * 10
			local clone = darkWisp:Clone()
			clone.Name = `DarkWisp_{count}`
			clone.Anchored = true
			clone.CanCollide = false
			clone.CastShadow = false
			clone.CFrame = CFrame.new(pos)
			setEmittersEnabled(clone, false)
			clone.Parent = folder
			local v7 = math.random() * 4
			task.delay(v7, function()
				if not clone.Parent then
					return
				end

				setEmittersEnabled(clone, true)
			end)
			table.insert(v, {
				Part = clone,
				Pos = pos,
				BaseY = pos.Y + v6,
				FacingAngle = math.random() * 3.141592653589793 * 2,
				Speed = 1.5 + math.random() * 2,
				WanderDir = vector2,
				WanderTimer = wanderTimer,
				NoisePhase = math.random() * 1000,
				Area = part
			})
		end

		if count >= 50 then
			break
		end
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		for _, v3 in ipairs(v) do
			v3.WanderTimer -= dt

			if v3.WanderTimer <= 0 then
				local v4 = math.random() * 3.141592653589793 * 2
				local vector2 = Vector3.new(math.cos(v4), 0, (math.sin(v4)))
				local wanderTimer = 2 + math.random() * 4
				v3.WanderDir = vector2
				v3.WanderTimer = wanderTimer
			end

			local area = v3.Area
			local pointToObjectSpace = area.CFrame:PointToObjectSpace((Vector3.new(v3.Pos.X, area.Position.Y, v3.Pos.Z)))
			local halfSize = area.Size / 2
			local v5 = halfSize.X - math.abs(pointToObjectSpace.X)
			local v6 = halfSize.Z - math.abs(pointToObjectSpace.Z)
			local vector2 = createVector(0, 0, 0)

			if v5 <= 0 or v6 <= 0 then
				local vector3 = Vector3.new(area.Position.X - v3.Pos.X, 0, area.Position.Z - v3.Pos.Z)
				vector2 = not (vector3.Magnitude > 0) and createVector(0, 0, 0) or vector3.Unit * 10
			else
				if v5 < 5 then
					vector2 += Vector3.new(-math.sign(pointToObjectSpace.X) * (1 - v5 / 5) * 3, 0, 0)
				end

				if v6 < 5 then
					vector2 += Vector3.new(0, 0, -math.sign(pointToObjectSpace.Z) * (1 - v6 / 5) * 3)
				end

				if vector2.Magnitude > 0 then
					local vectorToWorldSpace = area.CFrame:VectorToWorldSpace(vector2)
					vector2 = Vector3.new(vectorToWorldSpace.X, 0, vectorToWorldSpace.Z)
				end
			end

			local v7 = v3.WanderDir + vector2
			local unit

			if v7.Magnitude > 0.01 then
				unit = v7.Unit
			else
				unit = v3.WanderDir
			end

			v3.Pos = Vector3.new(
				v3.Pos.X + unit.X * v3.Speed * dt,
				v3.BaseY + math.sin(v3.NoisePhase) * 0.8,
				v3.Pos.Z + unit.Z * v3.Speed * dt
			)
			v3.NoisePhase += dt * 1.5
			v3.FacingAngle = math.atan2(unit.X, unit.Z)
			v3.Part.CFrame = CFrame.new(v3.Pos) * CFrame.Angles(0, v3.FacingAngle, 0)
		end
	end)
end

local function clearDarkWisps()
	flag = true

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	for _, v2 in ipairs(v) do
		if v2.Part and v2.Part.Parent then
			setEmittersEnabled(v2.Part, false)
		end
	end

	task.delay(3, function()
		for _, v2 in ipairs(v) do
			if v2.Part and v2.Part.Parent then
				v2.Part:Destroy()
			end
		end

		table.clear(v)

		if folder then
			folder:Destroy()
			folder = nil
		end

		flag = false
	end)
end

return {
	Start = function(_)
		Workspace:GetAttributeChangedSignal("SoulScourgeActive"):Connect(function()
			if Workspace:GetAttribute("SoulScourgeActive") then
				spawnDarkWisps()
			else
				clearDarkWisps()
			end
		end)

		if Workspace:GetAttribute("SoulScourgeActive") then
			spawnDarkWisps()
		end
	end
}