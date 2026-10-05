local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local FootDustConfig = require(chickenOrHero:WaitForChild("Presentation"):WaitForChild("FootDustConfig"))
local MovementProfiles = require(chickenOrHero:WaitForChild("Movement"):WaitForChild("MovementProfiles"))
local v = {}
local total = 0
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.RespectCanCollide = true
pcall(function()
	raycastParams.CollisionGroup = "CoHRunner"
end)
local v2 = {
	[Enum.Material.Grass] = true,
	[Enum.Material.Ground] = true,
	[Enum.Material.Sand] = true,
	[Enum.Material.Mud] = true,
	[Enum.Material.LeafyGrass] = true
}

-- equivalent calls inferred from this helper; original call sites unknown
local function remove(p)
	local v3 = v[p]

	if v3 then
		for _, attachment in v3.attachments do
			attachment:Destroy()
		end

		v[p] = nil
	end
end

local function create(c, root)
	local v3 = {
		character = c,
		root = root,
		distance = 0,
		foot = 1,
		attachments = {},
		emitters = {}
	}

	for i = 1, 2 do
		local attachment = Instance.new("Attachment")
		attachment.Name = "CoHFootDust" .. i
		attachment.Parent = root
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Name = "Dust"
		particleEmitter.Texture = FootDustConfig.Texture
		particleEmitter.Rate = 0
		particleEmitter.Enabled = false
		particleEmitter.Lifetime = NumberRange.new(0.2, 0.38)
		particleEmitter.Speed = NumberRange.new(0.8, 1.8)
		particleEmitter.SpreadAngle = Vector2.new(45, 45)
		particleEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.18),
			NumberSequenceKeypoint.new(0.5, 0.65),
			NumberSequenceKeypoint.new(1, 0.95)
		})
		particleEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.65),
			NumberSequenceKeypoint.new(0.25, 0.72),
			NumberSequenceKeypoint.new(1, 1)
		})
		particleEmitter.Rotation = NumberRange.new(0, 360)
		particleEmitter.RotSpeed = NumberRange.new(-40, 40)
		particleEmitter.Acceleration = createVector(0, 0.8, 0)
		particleEmitter.Drag = 4
		particleEmitter.LightInfluence = 0.8
		particleEmitter.LightEmission = 0
		particleEmitter.LockedToPart = false
		particleEmitter.VelocityInheritance = 0
		particleEmitter.Parent = attachment
		v3.attachments[i] = attachment
		v3.emitters[i] = particleEmitter
	end

	return v3
end

local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total < FootDustConfig.UpdateInterval then
		return
	end

	local v3 = math.min(total, 0.2)
	total = 0
	local currentCamera = workspace.CurrentCamera

	if FootDustConfig.Enabled and currentCamera then
		local characters = {}
		local v4 = {}

		for _, v5 in Players:GetPlayers() do
			local character = v5.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if character then
				table.insert(characters, character)
			end

			if not (humanoidRootPart and humanoid) then
				continue
			end

			local magnitude = (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude

			if magnitude <= FootDustConfig.MaxDistance then
				table.insert(v4, {
					p = v5,
					c = character,
					root = humanoidRootPart,
					h = humanoid,
					distance = magnitude
				})
			end
		end

		raycastParams.FilterDescendantsInstances = characters
		table.sort(v4, function(a, b)
			return a.distance < b.distance
		end)
		local v5 = {}

		for k, v6 in v4 do
			if FootDustConfig.MaxCharacters < k then
				break
			end

			local p = v6.p
			local c = v6.c
			local root = v6.root
			local h = v6.h
			v5[p] = true
			local v7 = v[p]

			if v7 and v7.character ~= c then
				remove(p) -- equivalent call inferred; original call site unknown
				v7 = nil
			end

			local magnitude = (root.AssemblyLinearVelocity * createVector(1, 0, 1)).Magnitude
			local v8

			if h.Health > 0 then
				v8 = not (root.Anchored or h.Sit or h.PlatformStand or c:GetAttribute("MovementLocked") or c:GetAttribute("TackleActive"))

				if v8 then
					if h.FloorMaterial == Enum.Material.Air then
						v8 = false
					else
						v8 = MovementProfiles.get(p:GetAttribute("GameRole"), p).MaxSpeed * FootDustConfig.MinSpeedRatio <= magnitude
					end
				end
			else
				v8 = false
			end

			if v8 then
				if not v7 then
					v7 = create(c, root)
					v[p] = v7
				end

				v7.distance += magnitude * v3

				if not (v7.distance < FootDustConfig.StepDistance) then
					v7.distance %= FootDustConfig.StepDistance
					local v9 = c:FindFirstChild(v7.foot == 1 and "Left Leg" or "Right Leg") or c:FindFirstChild(v7.foot == 1 and "LeftFoot" or "RightFoot")
					local position = v9 and v9.Position or root.Position
					local raycastResult = workspace:Raycast(
						Vector3.new(position.X, root.Position.Y, position.Z),
						createVector(0, -6, 0),
						raycastParams
					)

					if raycastResult and (v2[raycastResult.Material] or raycastResult.Instance.Name == "Grass" or raycastResult.Instance:GetAttribute("FootDust") == true) and raycastResult.Normal.Y > 0.5 then
						local color = raycastResult.Instance:IsA("BasePart") and raycastResult.Instance.Color or Color3.fromRGB(
							135,
							119,
							86
						)
						v7.attachments[v7.foot].WorldPosition = raycastResult.Position + raycastResult.Normal * 0.12
						v7.emitters[v7.foot].Color = ColorSequence.new(Color3.fromRGB(152, 133, 101):Lerp(color, 0.25))
						v7.emitters[v7.foot]:Emit(FootDustConfig.ParticlesPerStep)
					end

					v7.foot = 3 - v7.foot
				end
			elseif v7 then
				v7.distance = 0
			end
		end

		for k in v do
			if v5[k] then
				continue
			end

			remove(k) -- equivalent call inferred; original call site unknown
		end
	else
		for k in v do
			remove(k) -- equivalent call inferred; original call site unknown
		end
	end
end)
local playerRemovingConnection = Players.PlayerRemoving:Connect(remove)
script.Destroying:Connect(function()
	heartbeatConnection:Disconnect()
	playerRemovingConnection:Disconnect()

	for k in v do
		remove(k) -- equivalent call inferred; original call site unknown
	end
end)