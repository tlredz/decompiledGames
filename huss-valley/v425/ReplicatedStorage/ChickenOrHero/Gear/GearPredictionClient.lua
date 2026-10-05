local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local assets = chickenOrHero.Gear:WaitForChild("Assets")
local gearEvent = chickenOrHero.Gear:WaitForChild("GearEvent")
local AirhornCone = require(chickenOrHero.Gear:WaitForChild("AirhornCone"))
local GearCatalog = require(chickenOrHero.Gear:WaitForChild("GearCatalog"))
local GearPredictionClient = {
	FX = Instance.new("BindableEvent"),
	Cancel = Instance.new("BindableEvent")
}
local folder = Instance.new("Folder")
folder.Name = "PredictedGearPresentation"
folder.Parent = workspace
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {
	BananaPeel = 15.75,
	PocketDoor = 6,
	BowlingBall = 2,
	RufusLeash = 0.45,
	InflatableDecoy = 7
}
local v7 = {
	BowlingBall = 42,
	RufusLeash = 65,
	InflatableDecoy = 26
}
local v8 = {
	BananaPeel = "BananaThrow",
	RescueKit = "Rescue",
	Adrenaline = "Adrenaline",
	EmergencyAirhorn = "Airhorn",
	RocketShoes = "Rocket",
	InflatableDecoy = "DecoyInflate",
	PocketDoor = "DoorSlam",
	RufusLeash = "LeashThrow",
	BowlingBall = "BowlingUse"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function flat(p)
	local v9 = p * createVector(1, 0, 1)
	return v9.Magnitude > 0.01 and v9.Unit or createVector(0, 0, 1)
end

local function count(items)
	local count2 = 0

	for _ in items do
		count2 += 1
	end

	return count2
end

local function params()
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.RespectCanCollide = true
	local filterDescendantsInstances = { folder }

	for _, v10 in Players:GetPlayers() do
		if v10.Character then
			table.insert(filterDescendantsInstances, v10.Character)
		end
	end

	for _, v10 in CollectionService:GetTagged("PredictedGearVisual") do
		table.insert(filterDescendantsInstances, v10)
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	return raycastParams
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pivot(model)
	return model:IsA("Model") and model:GetPivot() or model.CFrame
end

-- equivalent calls inferred from this helper; original call sites unknown
local function move(model, display)
	if model:IsA("Model") then
		model:PivotTo(display)
	else
		model.CFrame = display
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function descendants(folder2)
	local descendants2 = folder2:GetDescendants()
	table.insert(descendants2, folder2)
	return descendants2
end

local function cloneVisual(instance, p)
	if not instance then
		return
	end

	local archivable = instance.Archivable
	instance.Archivable = true
	local success, result = pcall(function()
		return instance:Clone()
	end)
	instance.Archivable = archivable

	if not (success and result) then
		return
	end

	local descendants2 = descendants(result) -- equivalent call inferred; original call site unknown

	for _, instance2 in descendants2 do
		for _, tag in CollectionService:GetTags(instance2) do
			CollectionService:RemoveTag(instance2, tag)
		end

		if instance2:IsA("LuaSourceContainer") or instance2:IsA("Sound") or instance2:IsA("ProximityPrompt") or instance2:IsA("ForceField") then
			instance2:Destroy()
		elseif instance2:IsA("BasePart") then
			instance2.Anchored = not p or instance2.Name == "HumanoidRootPart"
			instance2.CanCollide = false
			instance2.CanTouch = false
			instance2.CanQuery = false
			instance2.Massless = true
			instance2.LocalTransparencyModifier = 0
		elseif instance2:IsA("Humanoid") then
			instance2.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			instance2.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		end
	end

	result.Name = "PredictedVisual"
	result.Parent = folder
	local humanoid = p and result:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return result
	end

	local v10 = humanoid:FindFirstChildOfClass("Animator")

	if not v10 then
		v10 = Instance.new("Animator")
		v10.Parent = humanoid
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://127439035853059"
	pcall(function()
		local track = v10:LoadAnimation(animation)
		track.Looped = true
		track.Priority = Enum.AnimationPriority.Movement
		track:Play(0.08)
	end)
	animation:Destroy()
	return result
end

local function restore(p)
	for instance, v9 in p.hidden or {} do
		if not instance.Parent then
			continue
		end

		if instance:IsA("BasePart") then
			instance.LocalTransparencyModifier = v9
		elseif instance:IsA("Decal") or instance:IsA("Texture") then
			instance.Transparency = v9
		else
			instance.Enabled = v9
		end
	end

	if p.added then
		p.added:Disconnect()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function remove(p)
	if p.proxy then
		p.proxy:Destroy()
	end

	restore(p)

	if v[p.id] == p then
		v[p.id] = nil
	end
end

local function hide(p, instance)
	p.hidden = {}

	local function one(instance2)
		if p.hidden[instance2] ~= nil then
			return
		end

		if instance2:IsA("BasePart") then
			p.hidden[instance2] = instance2.LocalTransparencyModifier
			instance2.LocalTransparencyModifier = 1
		elseif instance2:IsA("Decal") or instance2:IsA("Texture") then
			p.hidden[instance2] = instance2.Transparency
			instance2.Transparency = 1
		elseif instance2:IsA("ParticleEmitter") or instance2:IsA("Trail") or instance2:IsA("Beam") or instance2:IsA("Light") or instance2:IsA("BillboardGui") then
			p.hidden[instance2] = instance2.Enabled
			instance2.Enabled = false
		end
	end

	local descendants2 = descendants(instance) -- equivalent call inferred; original call site unknown

	for _, v10 in descendants2 do
		one(v10)
	end

	p.added = instance.DescendantAdded:Connect(one)
end

local function plan(childName, p)
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local direction = flat(humanoidRootPart.CFrame.LookVector) -- equivalent call inferred; original call site unknown

	if childName == "RocketShoes" and typeof(p) == "Vector3" then
		direction = flat(p)
	end

	local v10 = {
		item = childName,
		origin = humanoidRootPart.Position,
		direction = direction,
		character = character
	}
	local v11 = params()

	if childName == "BananaPeel" then
		local part = assets:FindFirstChild("BananaPeel")

		if not (part and part:IsA("BasePart")) then
			return
		end

		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 10,
			createVector(0, -8, 0),
			v11
		)

		if not raycastResult or raycastResult.Normal.Y < 0.65 then
			return
		end

		v10.hand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm") or humanoidRootPart
		v10.origin = v10.hand.Position - v10.hand.CFrame.UpVector * v10.hand.Size.Y * 0.35
		local v12 = raycastResult.Position + raycastResult.Normal * (part.Size.Y * 0.5 + 0.06)
		local v13 = humanoidRootPart.CFrame.LookVector - raycastResult.Normal * humanoidRootPart.CFrame.LookVector:Dot(raycastResult.Normal)
		local v14 = v13.Magnitude < 0.01 and createVector(0, 0, 1) or v13
		v10.landing = CFrame.lookAt(v12, v12 + v14, raycastResult.Normal)
		return v10
	elseif childName == "PocketDoor" then
		local raycastResult = workspace:Raycast(humanoidRootPart.Position + direction * 5, createVector(0, -9, 0), v11)

		if not raycastResult or raycastResult.Normal.Y < 0.85 then
			return
		end

		v10.origin = raycastResult.Position + createVector(0, 3.8, 0)
		v10.cf = CFrame.lookAt(v10.origin, v10.origin + direction)
		return v10
	elseif childName == "BowlingBall" then
		local raycastResult = workspace:Raycast(humanoidRootPart.Position + direction * 3, createVector(0, -9, 0), v11)

		if not raycastResult then
			return
		end

		v10.origin = raycastResult.Position + createVector(0, 1.05, 0)
		return v10
	else
		if childName ~= "InflatableDecoy" then
			return v10
		end

		local v12 = humanoidRootPart.Position + humanoidRootPart.CFrame.RightVector * 2.7
		local raycastResult = workspace:Raycast(v12, createVector(0, -9, 0), v11)

		if not raycastResult then
			return
		end

		local raycastResult2 = workspace:Raycast(humanoidRootPart.Position, createVector(0, -9, 0), v11)
		v10.origin = Vector3.new(
			v12.X,
			raycastResult.Position.Y + (raycastResult2 and math.clamp(
				humanoidRootPart.Position.Y - raycastResult2.Position.Y,
				2,
				5
			) or 3),
			v12.Z
		)
		return v10
	end
end

local function build(state, p)
	if v6[state.item] then
		local count2 = 0

		for _ in v do
			count2 += 1
		end

		if not (count2 >= 64) then
			state.proxy = cloneVisual(
				p or state.item == "InflatableDecoy" and state.character or assets:FindFirstChild(state.item),
				state.item == "InflatableDecoy"
			)

			if not state.proxy then
				return
			end

			state.started = state.started or workspace:GetServerTimeNow()
			state.duration = v6[state.item]
			state.speed = v7[state.item] or 0
			state.distance = 0
			local proxy = (state.item == "BananaPeel" or state.item == "RufusLeash") and (state.proxy:IsA("BasePart") and state.proxy or state.proxy:FindFirstChildWhichIsA(
				"BasePart",
				true
			))

			if proxy then
				local trail = state.proxy:FindFirstChildWhichIsA("Trail", true)

				if trail then
					state.trail = trail
				else
					local attachment = Instance.new("Attachment")
					attachment.Position = createVector(-0.2, 0, 0)
					attachment.Parent = proxy
					local attachment2 = Instance.new("Attachment")
					attachment2.Position = createVector(0.2, 0, 0)
					attachment2.Parent = proxy
					local trail2 = Instance.new("Trail")
					trail2.Attachment0 = attachment
					trail2.Attachment1 = attachment2
					trail2.Lifetime = 0.25
					trail2.Color = ColorSequence.new(state.item == "BananaPeel" and Color3.fromRGB(255, 214, 90) or Color3.fromRGB(
						119,
						229,
						255
					))
					trail2.Transparency = NumberSequence.new(0.1, 1)
					trail2.FaceCamera = true
					trail2.LightEmission = 0.85
					trail2.Parent = proxy
					state.trail = trail2
				end
			end

			local proxy2 = state.item == "BowlingBall" and (state.proxy:IsA("BasePart") and state.proxy or state.proxy:FindFirstChildWhichIsA(
				"BasePart",
				true
			))

			if proxy2 then
				local sound = Instance.new("Sound")
				sound.Name = "BowlingRoll"
				sound.SoundId = "rbxassetid://9125752846"
				sound.Volume = 0.35
				sound.RollOffMaxDistance = 100
				sound.RollOffMinDistance = 7
				sound.RollOffMode = Enum.RollOffMode.InverseTapered
				sound.PlaybackSpeed = 3
				sound.Looped = true
				sound.Parent = proxy2
				sound:Play()
			end

			state.position = state.origin
			state.display = state.cf or CFrame.lookAt(state.origin, state.origin + state.direction)

			if state.item == "PocketDoor" and state.proxy:IsA("BasePart") then
				state.proxy.Size = createVector(5.2, 7.2, 0.7)
			end

			move(state.proxy, state.display) -- equivalent call inferred; original call site unknown
			v[state.id] = state
			return state
		end
	end
end

local v9 = nil

local function stopRocket(p)
	local v10 = v9

	if not v10 or p and v10.id ~= p then
		return
	end

	v9 = nil
	v10.velocity:Destroy()
	v10.attachment:Destroy()

	if v10.root.Parent and v10.character == localPlayer.Character then
		v10.root.AssemblyLinearVelocity = createVector(0, 1, 0) * v10.root.AssemblyLinearVelocity.Y
	end
end

local function startRocket(requestId, character, direction)
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart or humanoidRootPart.Anchored or typeof(direction) ~= "Vector3" then
		return
	end

	stopRocket()
	local direction2 = flat(direction) -- equivalent call inferred; original call site unknown
	local attachment = Instance.new("Attachment")
	attachment.Name = "PredictedRocketAttachment"
	attachment.Parent = humanoidRootPart
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Name = "PredictedRocketVelocity"
	linearVelocity.Attachment0 = attachment
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
	linearVelocity.PrimaryTangentAxis = createVector(1, 0, 0)
	linearVelocity.SecondaryTangentAxis = createVector(0, 0, 1)
	linearVelocity.PlaneVelocity = Vector2.new(direction2.X, direction2.Z) * 64
	linearVelocity.ForceLimitsEnabled = true
	linearVelocity.ForceLimitMode = Enum.ForceLimitMode.Magnitude
	linearVelocity.MaxForce = math.max(1, humanoidRootPart.AssemblyMass) * 2500
	linearVelocity.Parent = humanoidRootPart
	humanoidRootPart.AssemblyLinearVelocity = direction2 * 64 + createVector(0, 1, 0) * humanoidRootPart.AssemblyLinearVelocity.Y
	v9 = {
		id = requestId,
		root = humanoidRootPart,
		character = character,
		direction = direction2,
		velocity = linearVelocity,
		attachment = attachment,
		ends = workspace:GetServerTimeNow() + 0.42
	}
end

local function airhornReport()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return nil
	end

	local position = humanoidRootPart.Position
	local direction = flat(humanoidRootPart.CFrame.LookVector) -- equivalent call inferred; original call site unknown
	local v11 = {
		at = workspace:GetServerTimeNow(),
		origin = position,
		direction = direction,
		targets = {}
	}
	local adminMatchMode = chickenOrHero.Game.Session:GetAttribute("AdminMatchMode")
	local v12 = adminMatchMode == "CrossyRoad" or adminMatchMode == "DonkeyKong" or adminMatchMode == "FFACatchers"
	local v13 = params()

	for _, v14 in Players:GetPlayers() do
		local character2 = v14.Character
		local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")

		if not (v14 ~= localPlayer and humanoidRootPart2 and v14:GetAttribute("RunState") == "Active" and (v12 or v14:GetAttribute("GameRole") == "Catcher")) then
			continue
		end

		if v14:GetAttribute("FFAInvincible") == true or not AirhornCone.contains(
			position,
			direction,
			humanoidRootPart2.Position
		) or workspace:Raycast(position, humanoidRootPart2.Position - position, v13) then
			continue
		end

		table.insert(v11.targets, {
			userId = v14.UserId,
			position = humanoidRootPart2.Position
		})

		if #v11.targets >= 32 then
			break
		end
	end

	return v11
end

local v10 = 0

function GearPredictionClient.request(p, p2, p3)
	local serverTimeNow = workspace:GetServerTimeNow()

	if serverTimeNow < v10 or p3 == "UseAbility" and serverTimeNow < (localPlayer:GetAttribute("AbilityReadyAt") or 0) or p3 == "Use" and serverTimeNow < (localPlayer:GetAttribute("GearReadyAt") or 0) then
		return nil
	end

	v10 = serverTimeNow + 0.6
	local v11

	if p == "EmergencyAirhorn" then
		v11 = airhornReport() or nil
	end

	local GUID = HttpService:GenerateGUID(false)
	local v12 = {
		item = p,
		character = localPlayer.Character,
		started = workspace:GetServerTimeNow(),
		emitted = {}
	}
	local count2 = 0

	for _ in v2 do
		count2 += 1
	end

	if count2 >= 24 then
		local started = nil
		local v13 = nil

		for k, v14 in v2 do
			if not (not started or v14.started < started) then
				continue
			end

			started = v14.started
			v13 = k
		end

		if v13 then
			v2[v13] = nil
		end
	end

	v2[GUID] = v12
	v5[GUID] = v12
	local count3 = 0

	for _ in v5 do
		count3 += 1
	end

	if count3 > 128 then
		local started = nil
		local v13 = nil

		for k, v14 in v5 do
			if not (not started or v14.started < started) then
				continue
			end

			started = v14.started
			v13 = k
		end

		if v13 then
			v5[v13] = nil
		end
	end

	local success, result = pcall(function()
		local v13 = plan(p, p2)
		local humanoidRootPart = v12.character and v12.character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if v13 then
			v13.id = GUID
			v13.predicted = true
			v13.started = v12.started
			build(v13)
		end

		local origin = v13 and v13.origin or humanoidRootPart.Position

		for _, kind in (p == "BananaPeel" or p == "RescueKit" or p == "Adrenaline") and { v8[p] } or { "Use", v8[p] } do
			if not kind then
				continue
			end

			v12.emitted[kind] = true
			local FX = GearPredictionClient.FX
			local v15 = {
				kind = kind,
				item = p,
				position = origin,
				direction = 0,
				character = 0,
				cf = 0,
				requestId = 0,
				ownerId = 0
			}
			local direction = v13 and v13.direction

			if not direction then
				direction = flat(humanoidRootPart.CFrame.LookVector)
			end

			v15.direction = direction
			v15.character = kind == "DecoyInflate" and v13 and v13.proxy or v12.character
			v15.cf = v13 and v13.cf
			v15.requestId = GUID
			v15.ownerId = localPlayer.UserId
			FX:Fire(v15)
		end
	end)

	if not success then
		warn("Gear visual prediction skipped:", result)
	end

	gearEvent:FireServer(p3, (p3 == "StudioUseItem" or p3 == "StudioUseAbility") and p or nil, p2, GUID, nil, v11)
	return GUID
end

local v11 = {
	Use = true
}

for _, v12 in v8 do
	v11[v12] = true
end

function GearPredictionClient.consumeFX(data)
	return type(data) == "table" and data.ownerId == localPlayer.UserId and type(data.requestId) == "string" and v11[data.kind] == true
end

local function bind(server)
	if not v3[server] then
		local count2 = 0

		for _ in v3 do
			count2 += 1
		end

		if not (count2 >= 128) then
			v3[server] = true
			task.spawn(function()
				for _ = 1, 120 do
					if not CollectionService:HasTag(server, "PredictedGearVisual") then
						v3[server] = nil
						return
					end

					if server:IsDescendantOf(workspace) and server:GetAttribute("GearRequestId") and server:GetAttribute("GearOrigin") then
						break
					else
						task.wait(0.05)
					end
				end

				v3[server] = nil

				if not server:IsDescendantOf(workspace) then
					return
				end

				local gearRequestId = server:GetAttribute("GearRequestId")
				local gearOrigin = server:GetAttribute("GearOrigin")
				local gearVisualKind = server:GetAttribute("GearVisualKind")

				if type(gearRequestId) ~= "string" or typeof(gearOrigin) ~= "Vector3" or not v6[gearVisualKind] then
					return
				end

				local v12

				if server:GetAttribute("GearOwnerId") == localPlayer.UserId then
					v12 = v5[gearRequestId]
				else
					v12 = false
				end

				local v13 = v[gearRequestId]

				if v13 and v13.item ~= gearVisualKind then
					remove(v13) -- equivalent call inferred; original call site unknown
					v13 = nil
				end

				if v13 and v13.server then
					return
				end

				if gearVisualKind == "RufusLeash" and v12 and not v13 and workspace:GetServerTimeNow() - v12.started >= 0.45 then
					server:Destroy()
					return
				end

				local v14 = v13 or build({
					id = gearRequestId,
					item = gearVisualKind,
					origin = gearOrigin,
					direction = server:GetAttribute("GearDirection") or createVector(0, 0, 1),
					started = v12 and v12.started or server:GetAttribute("GearSpawnedAt"),
					predicted = v12 ~= nil,
					landing = server:GetAttribute("GearLanding"),
					cf = server:GetAttribute("GearTargetCFrame")
				}, server)

				if not v14 then
					return
				end

				v14.server = server
				v14.origin = gearOrigin
				v14.direction = server:GetAttribute("GearDirection") or v14.direction
				v14.landing = server:GetAttribute("GearLanding") or v14.landing
				v14.cf = server:GetAttribute("GearTargetCFrame") or v14.cf
				v14.duration = server:GetAttribute("GearDuration") or v14.duration
				v14.speed = server:GetAttribute("GearSpeed") or v14.speed
				v14.serverStarted = server:GetAttribute("GearSpawnedAt") or v14.started

				if not v14.predicted then
					v14.started = v14.serverStarted
				end

				local playerByUserId = Players:GetPlayerByUserId(server:GetAttribute("GearOwnerId") or 0)
				local character = playerByUserId and playerByUserId.Character

				if v14.item == "BananaPeel" and character then
					v14.hand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
				end

				local model = server
				v14.serverLast = pivot(model)
				v14.serverChanged = workspace:GetServerTimeNow()

				if v14.item == "BowlingBall" and v4[gearRequestId] then
					v14.authoritativeCF = v4[gearRequestId].cf
					v14.authoritativeAt = v4[gearRequestId].received
					v14.authoritativeTime = v4[gearRequestId].serverTime
				end

				hide(v14, server)
			end)
		end
	end
end

CollectionService:GetInstanceAddedSignal("PredictedGearVisual"):Connect(bind)

for _, v12 in CollectionService:GetTagged("PredictedGearVisual") do
	if v3[v12] then
		continue
	end

	local count2 = 0

	for _ in v3 do
		count2 += 1
	end

	if count2 >= 128 then
		continue
	end

	v3[v12] = true
	local server = v12
	task.spawn(function()
		for i = 1, 120 do
			if not CollectionService:HasTag(server, "PredictedGearVisual") then
				v3[server] = nil
				return
			end

			if server:IsDescendantOf(workspace) and server:GetAttribute("GearRequestId") and server:GetAttribute("GearOrigin") then
				break
			else
				task.wait(0.05)
			end
		end

		v3[server] = nil

		if not server:IsDescendantOf(workspace) then
			return
		end

		local gearRequestId = server:GetAttribute("GearRequestId")
		local gearOrigin = server:GetAttribute("GearOrigin")
		local gearVisualKind = server:GetAttribute("GearVisualKind")

		if type(gearRequestId) ~= "string" or typeof(gearOrigin) ~= "Vector3" or not v6[gearVisualKind] then
			return
		end

		local v14

		if server:GetAttribute("GearOwnerId") == localPlayer.UserId then
			v14 = v5[gearRequestId]
		else
			v14 = false
		end

		local v15 = v[gearRequestId]

		if v15 and v15.item ~= gearVisualKind then
			remove(v15) -- equivalent call inferred; original call site unknown
			v15 = nil
		end

		if v15 and v15.server then
			return
		end

		if gearVisualKind == "RufusLeash" and v14 and not v15 and workspace:GetServerTimeNow() - v14.started >= 0.45 then
			server:Destroy()
			return
		end

		local v16 = v15 or build({
			id = gearRequestId,
			item = gearVisualKind,
			origin = gearOrigin,
			direction = server:GetAttribute("GearDirection") or createVector(0, 0, 1),
			started = v14 and v14.started or server:GetAttribute("GearSpawnedAt"),
			predicted = v14 ~= nil,
			landing = server:GetAttribute("GearLanding"),
			cf = server:GetAttribute("GearTargetCFrame")
		}, server)

		if not v16 then
			return
		end

		v16.server = server
		v16.origin = gearOrigin
		v16.direction = server:GetAttribute("GearDirection") or v16.direction
		v16.landing = server:GetAttribute("GearLanding") or v16.landing
		v16.cf = server:GetAttribute("GearTargetCFrame") or v16.cf
		v16.duration = server:GetAttribute("GearDuration") or v16.duration
		v16.speed = server:GetAttribute("GearSpeed") or v16.speed
		v16.serverStarted = server:GetAttribute("GearSpawnedAt") or v16.started

		if not v16.predicted then
			v16.started = v16.serverStarted
		end

		local playerByUserId = Players:GetPlayerByUserId(server:GetAttribute("GearOwnerId") or 0)
		local character = playerByUserId and playerByUserId.Character

		if v16.item == "BananaPeel" and character then
			v16.hand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
		end

		local model = server
		v16.serverLast = pivot(model)
		v16.serverChanged = workspace:GetServerTimeNow()

		if v16.item == "BowlingBall" and v4[gearRequestId] then
			v16.authoritativeCF = v4[gearRequestId].cf
			v16.authoritativeAt = v4[gearRequestId].received
			v16.authoritativeTime = v4[gearRequestId].serverTime
		end

		hide(v16, server)
	end)
end

gearEvent.OnClientEvent:Connect(function(p, data)
	if p == "BowlingPosition" then
		if type(data) == "table" and type(data.requestId) == "string" and typeof(data.cf) == "CFrame" then
			local serverTimeNow = workspace:GetServerTimeNow()
			v4[data.requestId] = {
				cf = data.cf,
				received = serverTimeNow,
				serverTime = data.serverTime
			}
			local v12 = v[data.requestId]

			if v12 and v12.item == "BowlingBall" then
				v12.authoritativeCF = data.cf
				v12.authoritativeAt = serverTimeNow
				v12.authoritativeTime = data.serverTime
			end
		end
	else
		if p ~= "PredictionResult" or type(data) ~= "table" then
			return
		end

		local v12 = v2[data.requestId]

		if not v12 then
			return
		end

		if data.accepted == true then
			v12.accepted = true

			if data.item == v12.item then
				if v12.item == "RocketShoes" and typeof(data.direction) == "Vector3" then
					startRocket(data.requestId, v12.character, data.direction)
				end

				local v13 = v[data.requestId]

				if v13 then
					if typeof(data.direction) == "Vector3" then
						v13.direction = data.direction
					end

					if typeof(data.landing) == "CFrame" then
						v13.landing = data.landing
					end

					if typeof(data.cf) == "CFrame" then
						v13.cf = data.cf
					end

					if v13.item ~= "BananaPeel" and typeof(data.position) == "Vector3" then
						v13.origin = data.position
					end
				end
			else
				stopRocket(data.requestId)
				local v13 = v[data.requestId]

				if v13 and v13.item == v12.item then
					remove(v13) -- equivalent call inferred; original call site unknown
				end

				GearPredictionClient.Cancel:Fire({
					character = v12.character,
					item = v12.item,
					requestId = data.requestId
				})
				v12.item = data.item
				v12.emitted = {}
			end
		else
			stopRocket(data.requestId)
			local v13 = v[data.requestId]

			if v13 then
				remove(v13) -- equivalent call inferred; original call site unknown
			end

			GearPredictionClient.Cancel:Fire({
				character = v12.character,
				item = v12.item,
				requestId = data.requestId
			})
			v2[data.requestId] = nil
		end
	end
end)

local function target(state, serverTimeNow, p, p2)
	local v12 = serverTimeNow - state.started

	if state.trail then
		local trail = state.trail
		local enabled

		if state.item == "BananaPeel" then
			if v12 >= 0.18 then
				enabled = v12 < 0.75
			else
				enabled = false
			end
		else
			enabled = true
		end

		trail.Enabled = enabled
	end

	if state.server and state.item ~= "BananaPeel" and state.item ~= "PocketDoor" then
		if state.item == "BowlingBall" and state.authoritativeCF and serverTimeNow - (state.authoritativeAt or 0) < 0.25 then
			return state.authoritativeCF
		end

		local serverLast = pivot(state.server) -- equivalent call inferred; original call site unknown

		if (serverLast.Position - state.serverLast.Position).Magnitude > 0.005 or serverLast.LookVector:Dot(state.serverLast.LookVector) < 0.9999 then
			state.serverLast = serverLast
			state.serverChanged = serverTimeNow
		end

		if state.item == "BowlingBall" or state.item ~= "RufusLeash" and state.item ~= "InflatableDecoy" then
			return serverLast
		end

		local v14 = math.min(0.08, serverTimeNow - state.serverChanged) * state.speed

		if state.item == "RufusLeash" then
			local v15 = math.clamp(
				(serverLast.Position - state.origin):Dot(state.direction),
				0,
				GearCatalog.Items.RufusLeash.ThrowRange
			)
			serverLast += state.origin + state.direction * v15 - serverLast.Position
			v14 = math.min(v14, GearCatalog.Items.RufusLeash.ThrowRange - v15)
		end

		if v14 > 0.001 then
			local spherecast = workspace:Spherecast(
				serverLast.Position,
				state.item == "BowlingBall" and 0.8 or 0.2,
				state.direction * v14,
				p2
			)

			if spherecast then
				v14 = math.max(0, spherecast.Distance - 0.03)
			end
		end

		local v15 = serverLast + state.direction * v14

		if state.item == "BowlingBall" then
			local raycastResult = workspace:Raycast(v15.Position + createVector(0, 2, 0), createVector(-0, -5, -0), p2)

			if raycastResult then
				return v15 + createVector(0, 1, 0) * (raycastResult.Position.Y + 1.05 - v15.Position.Y)
			end
		end

		return v15
	elseif state.item == "BananaPeel" and state.landing then
		if state.server and v12 < 0.18 then
			state.origin = (pivot(state.server)).Position
		end

		if v12 < 0.18 then
			if state.hand and state.hand.Parent then
				state.origin = state.hand.Position - state.hand.CFrame.UpVector * state.hand.Size.Y * 0.35
			end

			return CFrame.new(state.origin)
		else
			local v13 = math.clamp((v12 - 0.18) / 0.57, 0, 1)
			local v14 = state.origin:Lerp(state.landing.Position, v13) + createVector(0, 1, 0) * (v13 * 14 * (1 - v13))
			return CFrame.new(v14) * state.landing.Rotation * CFrame.Angles(
				-12.566370614359172 * (1 - v13),
				0,
				math.sin(v13 * 3.141592653589793) * 0.4
			)
		end
	elseif state.item == "PocketDoor" and state.cf then
		if not (state.server and v12 >= 0.2) then
			local value = TweenService:GetValue(
				math.clamp(v12 / 0.2, 0, 1),
				Enum.EasingStyle.Back,
				Enum.EasingDirection.Out
			)
			return (state.cf * CFrame.new(-2.6, 0, 0) * CFrame.Angles(0, 1.3962634015954636, 0) * CFrame.new(2.6, 0, 0)):Lerp(
				state.cf,
				value
			)
		end

		if state.predicted and serverTimeNow - (state.serverStarted or state.started) < 0.2 then
			return state.cf
		end

		return pivot(state.server)
	else
		local v13 = state.speed * p

		if state.item == "RufusLeash" then
			state.distance = math.clamp(
				(state.position - state.origin):Dot(state.direction),
				0,
				GearCatalog.Items.RufusLeash.ThrowRange
			)
			state.position = state.origin + state.direction * state.distance
			v13 = math.min(v13, (math.max(0, GearCatalog.Items.RufusLeash.ThrowRange - state.distance)))
		end

		local v14 = state.direction * v13
		local v15

		if v13 > 0 then
			v15 = workspace:Raycast(state.position, v14, p2)
		else
			v15 = false
		end

		if not v15 then
			state.position += v14
			state.distance += v14.Magnitude

			if state.item == "RufusLeash" then
				state.distance = math.min(state.distance, GearCatalog.Items.RufusLeash.ThrowRange)
				state.position = state.origin + state.direction * state.distance
			end
		end

		local raycastResult = state.item == "BowlingBall" and workspace:Raycast(
			state.position + createVector(0, 2, 0),
			createVector(-0, -5, -0),
			p2
		)

		if raycastResult then
			state.position = Vector3.new(state.position.X, raycastResult.Position.Y + 1.05, state.position.Z)
		end

		return CFrame.lookAt(state.position, state.position + state.direction) * (state.item == "BowlingBall" and CFrame.Angles(
			-state.distance,
			0,
			0
		) or CFrame.identity)
	end
end

RunService.RenderStepped:Connect(function(dt)
	local serverTimeNow = workspace:GetServerTimeNow()
	local v12 = v9

	if v12 then
		if v12.ends <= serverTimeNow or v12.character ~= localPlayer.Character or not v12.root.Parent or v12.character:GetAttribute("Ragdolled") then
			stopRocket(v12.id)
		else
			local v13 = v12.direction * (math.min(dt, 0.08) * 64 + 1.5)
			local spherecast = workspace:Spherecast(v12.root.Position, 1.1, v13, (params()))
			v12.velocity.PlaneVelocity = spherecast and Vector2.zero or Vector2.new(v12.direction.X, v12.direction.Z) * 64
		end
	end

	local v13 = next(v) and params() or nil

	for _, v14 in v do
		if v14.proxy.Parent and (not v14.server or v14.server:IsDescendantOf(workspace)) and (v14.server or not (serverTimeNow - v14.started > math.min(
			v14.duration,
			3
		))) then
			local display = target(v14, serverTimeNow, math.min(dt, 0.1), v13)

			if (v14.item ~= "BowlingBall" or not (v14.server and display)) and v14.server then
				display = v14.display:Lerp(display, 1 - math.exp(-30 * dt)) or display
			end

			v14.display = display

			if v14.item == "RufusLeash" then
				local v16 = math.clamp(
					(v14.display.Position - v14.origin):Dot(v14.direction),
					0,
					GearCatalog.Items.RufusLeash.ThrowRange
				)
				v14.display += v14.origin + v14.direction * v16 - v14.display.Position
			end

			move(v14.proxy, v14.display) -- equivalent call inferred; original call site unknown

			if v14.item == "BowlingBall" and localPlayer:GetAttribute("InMatch") and localPlayer:GetAttribute("GameRole") == "Runner" then
				local character = localPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
				local position = v14.authoritativeCF and v14.authoritativeCF.Position or v14.display.Position

				if humanoidRootPart and math.abs(humanoidRootPart.Position.Y - position.Y) <= 5.5 and (Vector3.new(
					humanoidRootPart.Position.X,
					0,
					humanoidRootPart.Position.Z
				) - Vector3.new(position.X, 0, position.Z)).Magnitude <= 3.4 and serverTimeNow - (v14.lastHitReport or -1e999) >= 0.16 then
					v14.lastHitReport = serverTimeNow
					gearEvent:FireServer(
						"BowlingHitReport",
						v14.id,
						humanoidRootPart.Position,
						nil,
						v14.authoritativeTime or serverTimeNow
					)
				end
			end
		else
			remove(v14) -- equivalent call inferred; original call site unknown
		end
	end

	for k, v14 in v4 do
		if serverTimeNow - v14.received > 4 then
			v4[k] = nil
		end
	end

	for k, v14 in v5 do
		if serverTimeNow - v14.started > 90 then
			v5[k] = nil
		end
	end

	for k, v14 in v2 do
		if v14.accepted or not (serverTimeNow - v14.started > 3) then
			if serverTimeNow - v14.started > 20 then
				v2[k] = nil
			end
		else
			GearPredictionClient.Cancel:Fire({
				character = v14.character,
				item = v14.item,
				requestId = k
			})
			local v15 = v[k]

			if v15 and not v15.server then
				remove(v15) -- equivalent call inferred; original call site unknown
			end

			v2[k] = nil
		end
	end
end)
localPlayer.CharacterRemoving:Connect(function()
	for _, v12 in v do
		if not v2[v12.id] then
			continue
		end

		remove(v12) -- equivalent call inferred; original call site unknown
	end

	for k, v12 in v2 do
		GearPredictionClient.Cancel:Fire({
			character = v12.character,
			item = v12.item,
			requestId = k
		})
	end

	table.clear(v2)
end)
return GearPredictionClient