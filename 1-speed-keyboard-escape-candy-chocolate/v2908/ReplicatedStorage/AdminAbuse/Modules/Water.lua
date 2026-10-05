local createVector = vector.create
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartyEvent = require(script.Parent.Parent.PartyEvent)
local GravityManager = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("GravityManager"))
local ParticleZone = require(ReplicatedStorage.Utilities.Events.ParticleZone)
local LightingSnapshot = require(ReplicatedStorage.Utilities.Events.LightingSnapshot)
local v = PartyEvent.new({
	Sounds = { "rbxassetid://124895160162220" }
})

function v.OnStart(_, state, _, _, p)
	local janitor = state.janitor
	GravityManager.set("Water", 40, 10)
	LightingSnapshot.acquireShared()
	LightingSnapshot.capture({ "ClockTime", "Ambient", "OutdoorAmbient" }):apply({
		ClockTime = 14,
		Ambient = Color3.fromRGB(200, 220, 255),
		OutdoorAmbient = Color3.fromRGB(180, 210, 255)
	})
	local v2 = janitor:Add(Instance.new("ColorCorrectionEffect"))
	v2.Name = "WaterColorCorrection"
	v2.Brightness = 0.02
	v2.Contrast = 0.05
	v2.Saturation = 0.15
	v2.TintColor = Color3.fromRGB(140, 200, 255)
	v2.Parent = Lighting
	local zonePart = ParticleZone.new({
		diameter = 40
	})
	zonePart:setup(janitor, CFrame.new(p.CFrame.Position))
	state.zonePart = zonePart
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxassetid://137027945265090"
	particleEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 230, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 180, 255))
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.7, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.9),
		NumberSequenceKeypoint.new(0.5, 1.6),
		NumberSequenceKeypoint.new(1, 0.3)
	})
	particleEmitter.LockedToPart = true
	particleEmitter.LightEmission = 0.5
	particleEmitter.LightInfluence = 0.5
	particleEmitter.Speed = NumberRange.new(2, 8)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Lifetime = NumberRange.new(2.5, 5)
	particleEmitter.Rate = 50
	particleEmitter.RotSpeed = NumberRange.new(-30, 30)
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.Parent = zonePart.part
	local particleEmitter2 = Instance.new("ParticleEmitter")
	particleEmitter2.Texture = "rbxassetid://120860976556927"
	particleEmitter2.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 190, 80)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 120, 50))
	})
	particleEmitter2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.8, 0.2),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter2.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(0.5, 1),
		NumberSequenceKeypoint.new(1, 0.3)
	})
	particleEmitter2.LightEmission = 0.2
	particleEmitter2.LightInfluence = 0.8
	particleEmitter2.Speed = NumberRange.new(1, 5)
	particleEmitter2.SpreadAngle = Vector2.new(180, 180)
	particleEmitter2.Lifetime = NumberRange.new(2, 4)
	particleEmitter2.Rate = 18
	particleEmitter2.LockedToPart = true
	particleEmitter2.RotSpeed = NumberRange.new(-20, 20)
	particleEmitter2.Rotation = NumberRange.new(0, 360)
	particleEmitter2.Parent = zonePart.part
	local crab = ReplicatedStorage.Assets.Events:FindFirstChild("Crab")
	state.playerCrabs = {}

	local function spawnCrabsForPlayer(p2)
		local userId = p2.UserId

		if state.playerCrabs[userId] or not (crab and crab:IsA("Model")) then
			return
		end

		local v4 = {}

		for i = 1, 8 do
			local v5 = (i - 1) / 8 * 3.141592653589793 * 2
			local folder = janitor:Add(crab:Clone())

			for _, part in folder:GetDescendants() do
				if not part:IsA("BasePart") then
					continue
				end

				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.Massless = true
			end

			folder.Parent = workspace
			table.insert(v4, {
				model = folder,
				baseAngle = v5,
				phaseOffset = v5
			})
		end

		state.playerCrabs[userId] = v4
	end

	for _, v4 in Players:GetPlayers() do
		spawnCrabsForPlayer(v4)
	end

	janitor:Add(Players.PlayerAdded:Connect(function(player)
		spawnCrabsForPlayer(player)
	end))
	janitor:Add(Players.PlayerRemoving:Connect(function(player)
		local playerCrab = state.playerCrabs[player.UserId]

		if playerCrab then
			for _, v4 in playerCrab do
				if v4.model and v4.model.Parent then
					v4.model:Destroy()
				end
			end

			state.playerCrabs[player.UserId] = nil
		end
	end))

	if not crab then
		warn("[Water] Modèle \"Crab\" introuvable dans Assets/Events")
	end

	local fishData = {}
	local events = ReplicatedStorage.Assets.Events
	local fish = events:FindFirstChild("Fish")
	local water = events:FindFirstChild("Water")
	local fishBox = water and water:FindFirstChild("FishBox")

	if fish and fishBox then
		for _ = 1, 8 do
			local folder = janitor:Add(fish:Clone())

			for _, part in folder:GetDescendants() do
				if not part:IsA("BasePart") then
					continue
				end

				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.CastShadow = false
				part.Massless = true
			end

			folder.Parent = workspace
			local X = fishBox.Position.X
			local Y = fishBox.Position.Y
			local Z = fishBox.Position.Z
			local v5 = fishBox.Size.X * 0.4
			local v6 = fishBox.Size.Y * 0.4
			local v7 = fishBox.Size.Z * 0.4
			table.insert(fishData, {
				model = folder,
				pos = Vector3.new(
					X + (math.random() - 0.5) * 2 * v5,
					Y + (math.random() - 0.5) * 2 * v6,
					Z + (math.random() - 0.5) * 2 * v7
				),
				vel = Vector3.new((math.random() - 0.5) * 7, (math.random() - 0.5) * 7 * 0.3, (math.random() - 0.5) * 7),
				noiseOffset = math.random() * 100
			})
		end
	else
		if not fish then
			warn("[Water] Modèle \"Fish\" introuvable dans Assets/Events")
		end

		if not fishBox then
			warn("[Water] Part \"FishBox\" introuvable dans Assets/Events/Water")
		end
	end

	state.fishData = fishData
	state.fishBox = fishBox
end

function v.OnRender(_, state, fishLastTime, _, _, p)
	if state.zonePart then
		state.zonePart:update(p.CFrame.Position)
	end

	if state.fishBox and state.fishData then
		local fishBox = state.fishBox
		local X = fishBox.Position.X
		local Y = fishBox.Position.Y
		local Z = fishBox.Position.Z
		local v2 = fishBox.Size.X * 0.45
		local v3 = fishBox.Size.Y * 0.45
		local v4 = fishBox.Size.Z * 0.45
		local v5 = math.min(fishLastTime - (state.fishLastTime or fishLastTime), 0.1)
		state.fishLastTime = fishLastTime

		for _, v6 in state.fishData do
			if not (v6.model and v6.model.Parent) then
				continue
			end

			local noiseOffset = v6.noiseOffset
			local v7 = fishLastTime * 0.35
			local v8 = math.noise(v7, 0, noiseOffset) * 10
			local v9 = math.noise(0, v7, noiseOffset + 10) * 10 * 0.25
			local v10 = math.noise(0, 0, v7 + noiseOffset * 0.7) * 10
			local v11 = v6.pos.X - X
			local v12 = v6.pos.Y - Y
			local v13 = v6.pos.Z - Z
			local v14 = math.abs(v11)

			if v2 * 0.75 < v14 then
				v8 -= math.sign(v11) * 10
			end

			local v15 = math.abs(v12)

			if v3 * 0.75 < v15 then
				v9 -= math.sign(v12) * 10
			end

			local v16 = math.abs(v13)

			if v4 * 0.75 < v16 then
				v10 -= math.sign(v13) * 10
			end

			local vel = v6.vel + Vector3.new(v8, v9, v10) * v5

			if vel.Magnitude > 7 then
				vel = vel.Unit * 7
			end

			v6.vel = vel
			local v18 = v6.pos + vel * v5
			v6.pos = Vector3.new(
				math.clamp(v18.X, X - v2, X + v2),
				math.clamp(v18.Y, Y - v3, Y + v3),
				(math.clamp(v18.Z, Z - v4, Z + v4))
			)

			if not (vel.Magnitude > 0.1) then
				continue
			end

			local v19 = math.abs((vel.Unit:Dot(createVector(0, 1, 0)))) > 0.98 and createVector(0, 0, 1) or createVector(
				0,
				1,
				0
			)
			v6.model:PivotTo(CFrame.lookAt(v6.pos, v6.pos + vel.Unit, v19))
		end
	end

	local position = p.CFrame.Position
	local v2 = {}

	for _, v3 in Players:GetPlayers() do
		local playerCrab = state.playerCrabs[v3.UserId]

		if not playerCrab then
			continue
		end

		local character = v3.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and not ((humanoidRootPart.Position - position).Magnitude > 150) then
			table.insert(v2, {
				crabs = playerCrab,
				root = humanoidRootPart,
				dist = (humanoidRootPart.Position - position).Magnitude
			})
		else
			for _, v4 in playerCrab do
				if v4.model and v4.model.Parent then
					v4.model:PivotTo(CFrame.new(0, -10000, 0))
				end
			end
		end
	end

	table.sort(v2, function(a, b)
		return a.dist < b.dist
	end)
	local total = 0

	for _, v3 in v2 do
		if total + 8 > 50 then
			for _, crab in v3.crabs do
				if crab.model and crab.model.Parent then
					crab.model:PivotTo(CFrame.new(0, -10000, 0))
				end
			end
		else
			total += 8
			local position2 = v3.root.Position

			for _, crab in v3.crabs do
				if not (crab.model and crab.model.Parent) then
					continue
				end

				local v4 = crab.baseAngle + fishLastTime * 0.3
				local v5 = math.abs((math.sin(fishLastTime * 14.66 + crab.phaseOffset))) * 1
				local v6 = math.sin(fishLastTime * 14.66 * 0.5 + crab.phaseOffset) * 0.12
				local v7 = position2.X + math.cos(v4) * 10
				local v8 = position2.Z + math.sin(v4) * 10
				local v9 = position2.Y + v5
				crab.model:PivotTo(CFrame.new(v7, v9, v8) * CFrame.Angles(0, v4 + 3.141592653589793, 0) * CFrame.Angles(
					v6,
					0,
					v6 * 0.5
				))
			end
		end
	end
end

function v.OnStop(_, _)
	GravityManager.release("Water")
	LightingSnapshot.releaseShared()
end

return v