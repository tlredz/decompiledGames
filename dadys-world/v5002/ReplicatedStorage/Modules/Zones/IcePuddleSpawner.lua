local createVector = vector.create
local IcePuddleSpawner = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
game:GetService("RunService")
game:GetService("Players")
local ZoneModifierManager = require(ServerScriptService:WaitForChild("ZoneModifierManager"))
require(ReplicatedStorage.Modules.Zones:WaitForChild("ZonePlacementManager"))
local v = {}

function IcePuddleSpawner.CleanupPuddles()
	local model = workspace.CurrentRoom and workspace.CurrentRoom:FindFirstChildOfClass("Model")
	local icePuddles = model and model:FindFirstChild("IcePuddles")

	if icePuddles then
		icePuddles:Destroy()
	end

	local icePuddles2 = workspace.CurrentRoom and workspace.CurrentRoom:FindFirstChild("IcePuddles")

	if icePuddles2 then
		icePuddles2:Destroy()
	end

	v = {}
end

function IcePuddleSpawner.SpawnPuddles(_)
	local cardModifiers = workspace.Info and workspace.Info:FindFirstChild("CardModifiers")

	if cardModifiers and cardModifiers:FindFirstChild("BlockIchorLeaks") then
		print("[IcePuddleSpawner] Blocked by Iced Over card (frozen over for the holidays)")
		return {}
	end

	IcePuddleSpawner.CleanupPuddles()
	local model = workspace.CurrentRoom and workspace.CurrentRoom:FindFirstChildOfClass("Model")
	local name = model and model.Name or "Unknown"
	local v2 = GetTriggerZoneSpawnPositions()

	if #v2 == 0 then
		warn("IcePuddleSpawner: No valid trigger zone spawn positions found")
		return {}
	end

	local visualModels = {}
	local v4 = {}

	for _, v5 in ipairs(v2) do
		local zoneType = math.random() < 0.85 and "IcePuddleZone" or "IceSkatingZone"
		local v7 = v5.floorPosition + createVector(0, 0.1, 0)
		local v8 = SpawnIcePuddleVisual(v7, v5.floorPosition, zoneType)

		if v8 then
			table.insert(visualModels, v8)
			local manualZone = v8:FindFirstChild("ManualZone")
			local size = zoneType == "IceSkatingZone" and createVector(10, 4, 10) or createVector(6, 4, 6)
			local floorPosition = v5.floorPosition

			if manualZone then
				if manualZone:IsA("BasePart") then
					size = manualZone.Size
					local pointToObjectSpace = v8:GetPivot():PointToObjectSpace(manualZone.Position)
					floorPosition = v5.floorPosition + Vector3.new(pointToObjectSpace.X, 0.1, pointToObjectSpace.Z)
					manualZone.Transparency = 1
					manualZone.CanCollide = false
					manualZone.CanTouch = false
				else
					warn("IcePuddleSpawner: ManualZone is not a BasePart, it's a", manualZone.ClassName)
				end
			end

			table.insert(v4, {
				position = floorPosition,
				size = size,
				zoneType = zoneType,
				puddleIndex = #visualModels
			})
		else
			warn("IcePuddleSpawner: Failed to create floor visual at", v5.floorPosition)
		end
	end

	local v5 = {
		searchRadius = 25,
		maxAttempts = 50,
		enforceSpacing = true,
		allowPartialSuccess = true
	}
	local zones = {}
	local count = 0
	local count2 = 0

	for _, v6 in ipairs(v4) do
		local zone = ZoneModifierManager.CreateZone(v6.zoneType, v6.position, v6.size, v5)

		if zone then
			table.insert(zones, zone)

			if v6.zoneType == "IcePuddleZone" then
				count2 += 1
			else
				count += 1
			end
		else
			warn("IcePuddleSpawner: Failed to create zone!")
		end
	end

	v = {
		zones = zones,
		visualModels = visualModels
	}
	print(
		"IcePuddleSpawner: Spawned",
		#zones,
		"ice zones (",
		count2,
		"boost,",
		count,
		"skating) with",
		#visualModels,
		"visuals in",
		name
	)
	return zones
end

function GetTriggerZoneSpawnPositions()
	local currentRoom = workspace:FindFirstChild("CurrentRoom")

	if not currentRoom then
		warn("IcePuddleSpawner: No CurrentRoom found")
		return {}
	end

	local model = currentRoom:FindFirstChildOfClass("Model")

	if not model then
		warn("IcePuddleSpawner: No room model found in CurrentRoom")
		return {}
	end

	local triggerZones = model:FindFirstChild("TriggerZones")

	if not triggerZones or #triggerZones:GetChildren() == 0 then
		warn("IcePuddleSpawner: No TriggerZones folder found or it's empty")
		return {}
	end

	local count = 0
	local count2 = 0
	local v2 = {}

	for _, child in ipairs(triggerZones:GetChildren()) do
		if child.Name ~= "TriggerZone" then
			continue
		end

		local v3 = child:IsA("BasePart") and child or child:FindFirstChildWhichIsA("BasePart", true)

		if v3 then
			local CollectionService = game:GetService("CollectionService")

			if CollectionService:HasTag(v3, "Obstacle") then
				count += 1
				continue
			end
		end

		count2 += 1
		local position

		if child:IsA("BasePart") then
			position = child.Position
		elseif child:IsA("Model") and child.PrimaryPart then
			position = child.PrimaryPart.Position
		else
			local basePart = child:FindFirstChildWhichIsA("BasePart", true)

			if basePart then
				position = basePart.Position
			else
				warn("IcePuddleSpawner: Could not determine floor position for TriggerZone")
				continue
			end
		end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		raycastParams.FilterDescendantsInstances = { child }
		local raycastResult = workspace:Raycast(
			position + createVector(0, 2, 0),
			createVector(0, -10, 0),
			raycastParams
		)

		if raycastResult then
			local instance = raycastResult.Instance
			local CollectionService = game:GetService("CollectionService")

			if CollectionService:HasTag(instance, "Floor") then
				local position2 = raycastResult.Position
				table.insert(v2, {
					position = position2,
					floorPosition = position2,
					triggerZone = child
				})
			else
				warn("IcePuddleSpawner: Hit part is not tagged as Floor:", instance.Name, "- skipping")
			end
		else
			warn("IcePuddleSpawner: No floor found beneath trigger zone at", position, "- skipping")
		end
	end

	for i = #v2, 2, -1 do
		local v3 = math.random(i)
		local v4 = v2[v3]
		local v5 = v2[i]
		v2[i] = v4
		v2[v3] = v5
	end

	local result = {}

	for i = 1, math.min(math.random(5, 7), #v2) do
		table.insert(result, v2[i])
	end

	return result
end

function SpawnIcePuddleVisual(position, _, value)
	local icePuddles = ReplicatedStorage:WaitForChild("Parts"):FindFirstChild("IcePuddles") or ServerStorage:FindFirstChild("IcePuddles") or workspace:FindFirstChild("IcePuddles") or ReplicatedStorage:FindFirstChild("IcePuddles")

	if not icePuddles then
		warn("IcePuddleSpawner: IcePuddles folder not found")
		return nil
	end

	local children = {}

	for _, child in ipairs(icePuddles:GetChildren()) do
		if not (child.Name:match("Ichor_Puddle_") or child.Name:match("Ice_Puddle_")) then
			continue
		end

		table.insert(children, child)
	end

	if #children == 0 then
		warn("IcePuddleSpawner: No ice puddle models found in folder")
		return nil
	end

	local clone = children[math.random(1, #children)]:Clone()

	if clone.PrimaryPart then
		clone:SetPrimaryPartCFrame(CFrame.new(position))
	else
		clone:PivotTo(CFrame.new(position))
	end

	local CollectionService = game:GetService("CollectionService")
	CollectionService:AddTag(clone, "IcePuddle_Visual")
	clone:SetAttribute("ZoneType", value or "IcePuddleZone")
	local model = workspace.CurrentRoom and workspace.CurrentRoom:FindFirstChildOfClass("Model")

	if model then
		local parent = model:FindFirstChild("IcePuddles")

		if not parent then
			parent = Instance.new("Folder")
			parent.Name = "IcePuddles"
			parent.Parent = model
		end

		clone.Parent = parent
		InitializeAnimations(clone)
		AddFrostEffects(clone)

		for _, descendant in ipairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
			elseif descendant:IsA("BasePart") then
				descendant.CanCollide = false
				descendant.CanTouch = false
			end
		end

		return clone
	else
		warn("IcePuddleSpawner: No room model found, cannot parent puddle")
		clone:Destroy()
		return nil
	end
end

function InitializeAnimations(instance)
	local animationController = instance:FindFirstChildOfClass("AnimationController", true)

	if not animationController then
		return
	end

	local idleAnimation = instance:FindFirstChild("IdleAnimation", true) or instance:FindFirstChild("Idle", true)
	local animator = idleAnimation and idleAnimation:IsA("Animation") and (animationController:FindFirstChild("Animator") or animationController:WaitForChild(
		"Animator",
		2
	))

	if animator then
		local track = animator:LoadAnimation(idleAnimation)
		track.Looped = true
		track:Play()
	end
end

function AddFrostEffects(instance)
	local primaryPart = instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart")

	if not primaryPart then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "FrostEffectsAttachment"
	attachment.Position = createVector(0, 0.5, 0)
	attachment.Parent = primaryPart
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "ColdMist"
	particleEmitter.Texture = "rbxassetid://243660364"
	particleEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 225, 250)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 210, 240)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 195, 230))
	})
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.3, 1.2),
		NumberSequenceKeypoint.new(0.7, 2),
		NumberSequenceKeypoint.new(1, 1.5)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.7),
		NumberSequenceKeypoint.new(0.2, 0.6),
		NumberSequenceKeypoint.new(0.6, 0.8),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.LightEmission = 0.1
	particleEmitter.LightInfluence = 0.9
	particleEmitter.Lifetime = NumberRange.new(1.5, 3)
	particleEmitter.Rate = 8
	particleEmitter.Speed = NumberRange.new(0.3, 1)
	particleEmitter.SpreadAngle = Vector2.new(30, 30)
	particleEmitter.Acceleration = createVector(0, 0.5, 0)
	particleEmitter.Drag = 2
	particleEmitter.RotSpeed = NumberRange.new(-20, 20)
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.EmissionDirection = Enum.NormalId.Top
	particleEmitter.Parent = attachment
	local particleEmitter2 = Instance.new("ParticleEmitter")
	particleEmitter2.Name = "IceSparkles"
	particleEmitter2.Texture = "rbxassetid://6490035152"
	particleEmitter2.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 230, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 220, 255))
	})
	particleEmitter2.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.1, 0.25),
		NumberSequenceKeypoint.new(0.5, 0.15),
		NumberSequenceKeypoint.new(1, 0)
	})
	particleEmitter2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.1, 0),
		NumberSequenceKeypoint.new(0.7, 0.3),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter2.LightEmission = 1
	particleEmitter2.LightInfluence = 0.1
	particleEmitter2.Lifetime = NumberRange.new(0.5, 1.2)
	particleEmitter2.Rate = 6
	particleEmitter2.Speed = NumberRange.new(0.1, 0.5)
	particleEmitter2.SpreadAngle = Vector2.new(180, 180)
	particleEmitter2.Acceleration = createVector(0, 0.2, 0)
	particleEmitter2.Drag = 3
	particleEmitter2.RotSpeed = NumberRange.new(-180, 180)
	particleEmitter2.Rotation = NumberRange.new(0, 360)
	particleEmitter2.EmissionDirection = Enum.NormalId.Top
	particleEmitter2.Parent = attachment
	local particleEmitter3 = Instance.new("ParticleEmitter")
	particleEmitter3.Name = "FrostCrystals"
	particleEmitter3.Texture = "rbxassetid://6490035152"
	particleEmitter3.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 240, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 220, 250))
	})
	particleEmitter3.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.3, 0.2),
		NumberSequenceKeypoint.new(1, 0.05)
	})
	particleEmitter3.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 0.2),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter3.LightEmission = 0.6
	particleEmitter3.LightInfluence = 0.5
	particleEmitter3.Lifetime = NumberRange.new(2, 4)
	particleEmitter3.Rate = 3
	particleEmitter3.Speed = NumberRange.new(0.2, 0.8)
	particleEmitter3.SpreadAngle = Vector2.new(60, 60)
	particleEmitter3.Acceleration = createVector(0, 0.3, 0)
	particleEmitter3.Drag = 1
	particleEmitter3.RotSpeed = NumberRange.new(-60, 60)
	particleEmitter3.Rotation = NumberRange.new(0, 360)
	particleEmitter3.EmissionDirection = Enum.NormalId.Top
	particleEmitter3.Parent = attachment
	return attachment
end

return IcePuddleSpawner