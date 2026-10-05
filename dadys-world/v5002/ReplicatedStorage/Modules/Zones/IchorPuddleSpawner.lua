local createVector = vector.create
local IchorPuddleSpawner = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local ZoneModifierManager = require(ServerScriptService:WaitForChild("ZoneModifierManager"))
require(ReplicatedStorage.Modules.Zones:WaitForChild("ZonePlacementManager"))
local v = nil
pcall(function()
	local SoundGroupManager = require(ReplicatedStorage.Modules.Audio.SoundGroupManager)
	v = SoundGroupManager
end)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local v2 = {}

local function pointInPartXZ(p, instance)
	local pointToObjectSpace = instance.CFrame:PointToObjectSpace(p)
	local v3 = instance.Size * 0.5
	return math.abs(pointToObjectSpace.X) <= v3.X and math.abs(pointToObjectSpace.Z) <= v3.Z
end

-- equivalent calls inferred from this helper; original call sites unknown
local function partHasNoGrowFlag(part)
	if not part then
		return false
	end

	if part:GetAttribute("NoTisha") or part:GetAttribute("NoFinn") then
		return true
	end

	return CollectionService:HasTag(part, "NoTisha") or CollectionService:HasTag(part, "NoFinn")
end

function IchorPuddleSpawner.IsNoGrowZone(part)
	if not (part and part:IsA("BasePart")) then
		return false
	end

	-- equivalent call inferred; original call site unknown
	if partHasNoGrowFlag(part) then
		return true
	end

	for _, tag in ipairs({ "NoFinn", "NoTisha" }) do
		for _, part2 in ipairs(CollectionService:GetTagged(tag)) do
			if part2 == part or not part2:IsA("BasePart") or CollectionService:HasTag(part2, "TishaCleanable") then
				continue
			end

			local position = part.Position
			local pointToObjectSpace = part2.CFrame:PointToObjectSpace(position)
			local v3 = part2.Size * 0.5
			local v4

			if math.abs(pointToObjectSpace.X) <= v3.X then
				v4 = math.abs(pointToObjectSpace.Z) <= v3.Z
			else
				v4 = false
			end

			if v4 then
				return true
			end
		end
	end

	return false
end

local function tagPuddleZone(zone, p)
	if not zone then
		return
	end

	CollectionService:AddTag(zone, "TishaCleanable")

	if IchorPuddleSpawner.IsNoGrowZone(zone) then
		CollectionService:AddTag(zone, "NoTisha")
	end

	if p then
		local objectValue = Instance.new("ObjectValue")
		objectValue.Name = "PuddleVisual"
		objectValue.Value = p
		objectValue.Parent = zone
	end
end

local v3 = {
	[0] = 0.25,
	[1] = 0.25,
	[2] = 0.5,
	[3] = 0.75,
	[4] = 1,
	[5] = 1.25
}
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local object = setmetatable({}, {
	__mode = "k"
})

local function ensureBaseData(object2, zone)
	local v4 = object[object2]

	if v4 then
		if zone then
			v4.zone = zone
		end

		return v4
	else
		local v5 = {
			zone = zone,
			baseModelScale = object2:GetScale(),
			baseZoneSize = zone.Size
		}
		object[object2] = v5
		return v5
	end
end

local function applyPuddleScale(folder, p)
	local v4 = object[folder]

	if not (v4 and folder and folder.Parent) then
		return
	end

	local v5 = p or tweenInfo
	local zone = v4.zone
	local stage = folder:GetAttribute("Stage")
	local v6 = stage == nil and 1 or v3[stage] or 1

	if v4.scaleTween then
		pcall(function()
			v4.scaleTween:Cancel()
		end)
	end

	if v4.scaleConn then
		v4.scaleConn:Disconnect()
	end

	if v4.scaleProxy then
		v4.scaleProxy:Destroy()
	end

	local numberValue = Instance.new("NumberValue")
	numberValue.Value = folder:GetScale()
	local changedConnection = numberValue.Changed:Connect(function(p2)
		if folder.Parent then
			folder:ScaleTo(p2)
		end
	end)
	local tween = TweenService:Create(numberValue, v5, {
		Value = v4.baseModelScale * v6
	})
	v4.scaleProxy = numberValue
	v4.scaleConn = changedConnection
	v4.scaleTween = tween
	tween.Completed:Connect(function()
		changedConnection:Disconnect()
		numberValue:Destroy()

		if v4.scaleTween == tween then
			local v7 = v4
			local v8 = v4
			v4.scaleProxy = nil
			v7.scaleConn = nil
			v8.scaleTween = nil
		end
	end)
	tween:Play()

	if zone and zone.Parent then
		TweenService:Create(zone, v5, {
			Size = Vector3.new(v4.baseZoneSize.X * v6, v4.baseZoneSize.Y, v4.baseZoneSize.Z * v6)
		}):Play()
	end
end

local function setupPuddleStaging(folder, zone)
	if not (folder and zone) then
		return
	end

	local v4 = object[folder]

	if v4 then
		if zone then
			v4.zone = zone
		end
	else
		object[folder] = {
			zone = zone,
			baseModelScale = folder:GetScale(),
			baseZoneSize = zone.Size
		}
	end

	local transparenciesByPart = {}

	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			transparenciesByPart[part] = part.Transparency
		end
	end

	local function setVisible(enabled)
		for _, descendant in ipairs(folder:GetDescendants()) do
			if descendant:IsA("BasePart") then
				TweenService:Create(descendant, tweenInfo, {
					Transparency = not enabled and 1 or transparenciesByPart[descendant] or 0
				}):Play()
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Enabled = enabled
			elseif descendant:IsA("Sound") then
				if enabled then
					descendant:Play()
				else
					descendant:Stop()
				end
			end
		end
	end

	local function setTouchable(p)
		if not zone.Parent then
			return
		end

		if p and not CollectionService:HasTag(zone, "IchorPuddleZone") then
			CollectionService:AddTag(zone, "IchorPuddleZone")
		elseif not p and CollectionService:HasTag(zone, "IchorPuddleZone") then
			CollectionService:RemoveTag(zone, "IchorPuddleZone")
		end
	end

	local thread = nil
	folder:SetAttribute("Stage", 4)
	folder:GetAttributeChangedSignal("Stage"):Connect(function()
		local stage = folder:GetAttribute("Stage") or 4
		local enabled = stage >= 1
		applyPuddleScale(folder)
		setVisible(enabled)
		setTouchable(enabled)

		if stage <= 0 then
			if thread then
				task.cancel(thread)
				thread = nil
			end

			thread = task.spawn(function()
				while folder.Parent do
					task.wait(45)

					if not folder.Parent then
						break
					end

					local stage2 = folder:GetAttribute("Stage") or 0

					if stage2 >= 4 then
						break
					end

					folder:SetAttribute("Stage", stage2 + 1)

					if stage2 + 1 >= 4 then
						break
					end
				end

				thread = nil
			end)
		end
	end)
end

local function TrackIchorSpillMastery()
	local editData = ReplicatedStorage:FindFirstChild("editData")

	if not editData then
		warn("IchorPuddleSpawner: editData not found for mastery tracking")
		return
	end

	local ActionEvent = require(ReplicatedStorage.SharedUtils.ActionEvent)

	for _, child in pairs(workspace.InGamePlayers:GetChildren()) do
		local v4 = child
		local success, result = pcall(function()
			local playerFromCharacter = Players:GetPlayerFromCharacter(v4)

			if not playerFromCharacter then
				return
			end

			local moduleName = v4:WaitForChild("Config"):WaitForChild("ModuleName")
			ActionEvent:Record(playerFromCharacter, "ExperiencedFloorEvent", "IchorSpill")
			editData:Invoke(playerFromCharacter, function(p)
				if p then
					local v5 = false

					for k, v7 in pairs(p.Data.Mastery) do
						if v7.Name ~= moduleName.Value then
							continue
						end

						v5 = v7
						break
					end

					if v5 then
						for k, v7 in pairs(v5.RequirementList) do
							if v7.Name ~= "IchorSpill" then
								continue
							end

							v7.Current += 1

							if v7.Current >= v7.Amount then
								v7.Current = v7.Amount
							end
						end
					end
				end
			end)
		end)

		if not success then
			warn(result)
		end
	end
end

function IchorPuddleSpawner.CleanupPuddles()
	local model = workspace.CurrentRoom and workspace.CurrentRoom:FindFirstChildOfClass("Model")
	local puddles = model and model:FindFirstChild("Puddles")

	if puddles then
		puddles:Destroy()
	end

	local puddles2 = workspace.CurrentRoom and workspace.CurrentRoom:FindFirstChild("Puddles")

	if puddles2 then
		puddles2:Destroy()
	end

	v2 = {}
end

function IchorPuddleSpawner.SpawnPuddles(_)
	local cardModifiers = workspace.Info and workspace.Info:FindFirstChild("CardModifiers")

	if cardModifiers and cardModifiers:FindFirstChild("BlockIchorLeaks") then
		print("[IchorPuddleSpawner] Blocked by Iced Over card (frozen over for the holidays)")
		return {}
	end

	IchorPuddleSpawner.CleanupPuddles()
	local model = workspace.CurrentRoom and workspace.CurrentRoom:FindFirstChildOfClass("Model")
	local name = model and model.Name or "Unknown"
	local v4 = GetTriggerZoneSpawnPositions()

	if #v4 == 0 then
		warn("IchorPuddleSpawner: No valid trigger zone spawn positions found")
		return {}
	end

	local visualModels = {}
	local v6 = {}

	for _, v7 in ipairs(v4) do
		local v8 = v7.floorPosition + createVector(0, 0.1, 0)
		local visual = SpawnIchorPuddleVisual(v8, false, v7.floorPosition, nil)

		if visual then
			table.insert(visualModels, visual)
			local manualZone = visual:FindFirstChild("ManualZone")
			local size = createVector(12, 8, 12)
			local floorPosition = v7.floorPosition

			if manualZone then
				if manualZone:IsA("BasePart") then
					size = manualZone.Size
					local pointToObjectSpace = visual:GetPivot():PointToObjectSpace(manualZone.Position)
					floorPosition = v7.floorPosition + Vector3.new(pointToObjectSpace.X, 0.1, pointToObjectSpace.Z)
					manualZone.Transparency = 1
					manualZone.CanCollide = false
					manualZone.CanTouch = false
				else
					warn("IchorPuddleSpawner: ManualZone is not a BasePart, it's a", manualZone.ClassName)
				end
			end

			table.insert(v6, {
				position = floorPosition,
				size = size,
				visual = visual,
				puddleIndex = #visualModels
			})

			if v7.hasCeiling then
				local v10 = SpawnIchorPuddleVisual(v7.position, true, v7.floorPosition, v7.ceilingCFrame)

				if v10 then
					table.insert(visualModels, v10)
				else
					warn("IchorPuddleSpawner: Failed to create ceiling visual")
				end
			end
		else
			warn("IchorPuddleSpawner: Failed to create floor visual at", v7.floorPosition)
		end
	end

	local v7 = {
		searchRadius = 25,
		maxAttempts = 50,
		enforceSpacing = true,
		allowPartialSuccess = true
	}
	local zones = {}

	for _, v8 in ipairs(v6) do
		local zone = ZoneModifierManager.CreateZone("IchorPuddleZone", v8.position, v8.size, v7)

		if zone then
			table.insert(zones, zone)
			tagPuddleZone(zone, v8.visual)
			setupPuddleStaging(v8.visual, zone)
		else
			warn("IchorPuddleSpawner: Failed to create zone!")
		end
	end

	v2 = {
		zones = zones,
		visualModels = visualModels
	}
	TrackIchorSpillMastery()
	print("IchorPuddleSpawner: Spawned", #zones, "ichor zones with", #visualModels, "visual models in", name)
	return zones
end

function GetTriggerZoneSpawnPositions()
	local currentRoom = workspace:FindFirstChild("CurrentRoom")

	if not currentRoom then
		warn("IchorPuddleSpawner: No CurrentRoom found")
		return {}
	end

	local model = currentRoom:FindFirstChildOfClass("Model")

	if not model then
		warn("IchorPuddleSpawner: No room model found in CurrentRoom")
		return {}
	end

	local triggerZones = model:FindFirstChild("TriggerZones")

	if not triggerZones or #triggerZones:GetChildren() == 0 then
		warn("IchorPuddleSpawner: No TriggerZones folder found or it's empty")
		return {}
	end

	local count = 0
	local count2 = 0
	local v4 = {}

	for _, child in ipairs(triggerZones:GetChildren()) do
		if child.Name ~= "TriggerZone" then
			continue
		end

		local v5 = child:IsA("BasePart") and child or child:FindFirstChildWhichIsA("BasePart", true)

		if v5 then
			local CollectionService2 = game:GetService("CollectionService")

			if CollectionService2:HasTag(v5, "Obstacle") then
				count += 1
				continue
			end
		end

		count2 += 1
		local ceilingTriggerZone = child:FindFirstChild("CeilingTriggerZone")
		local hasCeiling = ceilingTriggerZone ~= nil
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
				warn("IchorPuddleSpawner: Could not determine floor position for TriggerZone")
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
			local CollectionService2 = game:GetService("CollectionService")

			if CollectionService2:HasTag(instance, "Floor") then
				local position2 = raycastResult.Position
				local cFrame = nil
				local position3

				if hasCeiling then
					local primaryPart = nil

					if ceilingTriggerZone:IsA("BasePart") then
						position3 = ceilingTriggerZone.Position
						primaryPart = ceilingTriggerZone
					elseif ceilingTriggerZone:IsA("Model") and ceilingTriggerZone.PrimaryPart then
						primaryPart = ceilingTriggerZone.PrimaryPart
						position3 = ceilingTriggerZone.PrimaryPart.Position
					else
						local basePart = ceilingTriggerZone:FindFirstChildWhichIsA("BasePart", true)

						if basePart then
							position3 = basePart.Position
							primaryPart = basePart
						else
							position3 = position2
						end
					end

					if primaryPart then
						cFrame = primaryPart.CFrame
						position3 -= createVector(0, 0.1, 0)
					end
				else
					position3 = position2
				end

				table.insert(v4, {
					position = position3,
					floorPosition = position2,
					hasCeiling = hasCeiling,
					ceilingCFrame = cFrame,
					triggerZone = child
				})
			end
		else
			warn("IchorPuddleSpawner: No floor found beneath trigger zone at", position, "- skipping")
		end
	end

	for i = #v4, 2, -1 do
		local v5 = math.random(i)
		local v6 = v4[v5]
		local v7 = v4[i]
		v4[i] = v6
		v4[v5] = v7
	end

	local result = {}

	for i = 1, math.min(15, #v4) do
		table.insert(result, v4[i])
	end

	return result
end

function SpawnIchorPuddleVisual(position, p, _, p2, instance, p3)
	local clone

	if instance then
		clone = instance:Clone()
	else
		local ichorPuddlesCeiling

		if p then
			ichorPuddlesCeiling = ReplicatedStorage:WaitForChild("Parts"):FindFirstChild("IchorPuddlesCeiling") or ServerStorage:FindFirstChild("IchorPuddlesCeiling") or workspace:FindFirstChild("IchorPuddlesCeiling") or ReplicatedStorage:FindFirstChild("IchorPuddlesCeiling")
		else
			ichorPuddlesCeiling = ReplicatedStorage:WaitForChild("Parts"):FindFirstChild("IchorPuddles") or ServerStorage:FindFirstChild("IchorPuddles") or workspace:FindFirstChild("IchorPuddles") or ReplicatedStorage:FindFirstChild("IchorPuddles")
		end

		if not ichorPuddlesCeiling then
			warn("IchorPuddleSpawner: Puddle folder not found for", p and "ceiling" or "floor", "version")
			return nil
		end

		local children = {}

		for _, child in ipairs(ichorPuddlesCeiling:GetChildren()) do
			if child.Name:match("Ichor_Puddle_") then
				table.insert(children, child)
			end
		end

		if #children == 0 then
			warn("IchorPuddleSpawner: No puddle models found in folder")
			return nil
		else
			clone = children[math.random(1, #children)]:Clone()
		end
	end

	if p and p2 then
		if clone.PrimaryPart then
			clone:SetPrimaryPartCFrame(p2 + (position - p2.Position))
		else
			clone:PivotTo(p2 + (position - p2.Position))
		end
	elseif clone.PrimaryPart then
		clone:SetPrimaryPartCFrame(CFrame.new(position))
	else
		clone:PivotTo(CFrame.new(position))
	end

	local size = nil
	local primaryPart

	if p3 then
		primaryPart = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)

		if primaryPart then
			size = primaryPart.Size
			primaryPart.Size = createVector(0, 0, 0)
		end
	end

	local CollectionService2 = game:GetService("CollectionService")
	CollectionService2:AddTag(clone, p and "Ceiling" or "Floor")
	local model = workspace.CurrentRoom and workspace.CurrentRoom:FindFirstChildOfClass("Model")

	if model then
		local parent = model:FindFirstChild("Puddles")

		if not parent then
			parent = Instance.new("Folder")
			parent.Name = "Puddles"
			parent.Parent = model
		end

		clone.Parent = parent

		if primaryPart and size then
			TweenService:Create(primaryPart, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Size = size
			}):Play()
		end

		InitializeAnimations(clone)
		local ichorPuddleTop = clone:FindFirstChild("IchorPuddleTop")

		if ichorPuddleTop then
			InitializeAnimations(ichorPuddleTop)
		end

		for _, descendant in ipairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
			elseif descendant:IsA("BasePart") then
				descendant.CanCollide = false
				descendant.CanTouch = false
			end
		end

		local primaryPart2 = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)

		if primaryPart2 then
			local v5 = Audio:Play("Sounds.ZoneEvents.IchorPuddle.Drip", {
				Volume = 0.4,
				Looped = true,
				RollOffMode = Enum.RollOffMode.Linear,
				RollOffMinDistance = 10,
				RollOffMaxDistance = 50,
				Parent = primaryPart2
			})

			if v5 then
				v5.Name = "IchorDripSound"

				if v then
					v.AssignSound(v5, "Environmental")
					return clone
				end
			end
		else
			warn("IchorPuddleSpawner: Could not find root part for puddle to attach audio")
		end

		return clone
	else
		warn("IchorPuddleSpawner: No room model found, cannot parent puddle")
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

function GetBassieStyleSpawnPositions()
	return {}
end

function SpawnCeilingIchor(_)
	return nil
end

function IchorPuddleSpawner.GetSpawnPositions()
	return GetTriggerZoneSpawnPositions()
end

function IchorPuddleSpawner.SpawnSinglePuddleVisual(p)
	if typeof(p) ~= "Vector3" then
		warn("[IchorPuddleSpawner] SpawnSinglePuddleVisual: floorPosition must be a Vector3")
		return nil
	end

	local finnIchorPuddle = ReplicatedStorage:WaitForChild("Parts"):FindFirstChild("FinnIchorPuddle")

	if not finnIchorPuddle then
		warn("[IchorPuddleSpawner] SpawnSinglePuddleVisual: FinnIchorPuddle missing from ReplicatedStorage.Parts; falling back to default ichor puddle pool")
	end

	local v4 = p + createVector(0, 0.1, 0)
	local v5 = SpawnIchorPuddleVisual(v4, false, p, nil, finnIchorPuddle, true)

	if not v5 then
		warn("[IchorPuddleSpawner] SpawnSinglePuddleVisual: failed to create visual")
		return nil
	end

	local manualZone = v5:FindFirstChild("ManualZone")

	if manualZone and manualZone:IsA("BasePart") then
		manualZone.Transparency = 1
		manualZone.CanCollide = false
		manualZone.CanTouch = false
	end

	return v5
end

local tweenInfo2 = TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)

function IchorPuddleSpawner.ShrinkOutPuddleVisual(folder)
	if not (folder and folder.Parent) or folder:GetAttribute("ShrinkingOut") then
		return
	end

	folder:SetAttribute("ShrinkingOut", true)

	for _, emitter in ipairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	local primaryPart = folder.PrimaryPart or folder:FindFirstChildWhichIsA("BasePart", true)

	if not primaryPart then
		folder:Destroy()
		return
	end

	local tween = TweenService:Create(primaryPart, tweenInfo2, {
		Size = createVector(0, 0, 0)
	})
	tween.Completed:Once(function()
		if folder.Parent then
			folder:Destroy()
		end
	end)
	tween:Play()
end

function IchorPuddleSpawner.FadeOutPuddleVisual(folder)
	if not (folder and folder.Parent) or folder:GetAttribute("FadingOut") then
		return
	end

	folder:SetAttribute("FadingOut", true)
	local tweenInfo3 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local v4 = false

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			TweenService:Create(descendant, tweenInfo3, {
				Transparency = 1
			}):Play()
			v4 = true
		elseif descendant:IsA("ParticleEmitter") then
			descendant.Enabled = false
		elseif descendant:IsA("Sound") then
			descendant:Stop()
		end
	end

	Debris:AddItem(folder, v4 and 0.5 or 0)
end

function IchorPuddleSpawner.CreatePuddleZoneFromVisual(instance, total)
	if not instance then
		return nil
	end

	local manualZone = instance:FindFirstChild("ManualZone")
	local size

	if manualZone and manualZone:IsA("BasePart") then
		size = manualZone.Size
		local pointToObjectSpace = instance:GetPivot():PointToObjectSpace(manualZone.Position)
		total += Vector3.new(pointToObjectSpace.X, 0.1, pointToObjectSpace.Z)
	else
		size = createVector(12, 8, 12)
	end

	local zone = ZoneModifierManager.CreateZone("IchorPuddleZone", total, size, {
		searchRadius = 25,
		maxAttempts = 50,
		enforceSpacing = true,
		allowPartialSuccess = true
	})

	if not zone then
		warn("[IchorPuddleSpawner] CreatePuddleZoneFromVisual: CreateZone returned nil")
		return zone
	end

	tagPuddleZone(zone, instance)
	IchorPuddleSpawner.WatchPuddleTeardown(zone, instance)
	return zone
end

function IchorPuddleSpawner.SpawnSinglePuddle(p)
	local singlePuddleVisual = IchorPuddleSpawner.SpawnSinglePuddleVisual(p)

	if singlePuddleVisual then
		return {
			zonePart = IchorPuddleSpawner.CreatePuddleZoneFromVisual(singlePuddleVisual, p),
			visual = singlePuddleVisual
		}
	end

	warn("[IchorPuddleSpawner] SpawnSinglePuddle: failed to create visual")
	return nil
end

local function sphereIntersectsBox(p, p2, cFrame, size)
	local pointToObjectSpace = cFrame:PointToObjectSpace(p)
	local v4 = size * 0.5
	return (pointToObjectSpace - Vector3.new(
		math.clamp(pointToObjectSpace.X, -v4.X, v4.X),
		math.clamp(pointToObjectSpace.Y, -v4.Y, v4.Y),
		(math.clamp(pointToObjectSpace.Z, -v4.Z, v4.Z))
	)).Magnitude <= p2
end

local v4 = nil

local function getIchorDropController()
	if v4 == nil then
		local success, result = pcall(function()
			return require(ServerScriptService.MonsterAI.Modules.IchorDropController)
		end)
		v4 = success and result or false
	end

	return v4 or nil
end

local function fadePuddleVisual(folder, duration)
	if not (folder and folder.Parent) then
		return
	end

	local tweenInfo3 = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			TweenService:Create(descendant, tweenInfo3, {
				Transparency = 1
			}):Play()
		elseif descendant:IsA("ParticleEmitter") then
			descendant.Enabled = false
		elseif descendant:IsA("Sound") then
			descendant:Stop()
		end
	end

	Debris:AddItem(folder, duration)
end

local function despawnPuddleZone(instance, p)
	CollectionService:RemoveTag(instance, "TishaCleanable")

	if v4 == nil then
		local success, result = pcall(function()
			return require(ServerScriptService.MonsterAI.Modules.IchorDropController)
		end)
		v4 = success and result or false
	end

	local v5 = v4 or nil
	print("[FINN-CLEAN-DBG] despawnPuddleZone:", instance:GetFullName(), "| controller resolved:", v5 ~= nil)

	if v5 then
		local success, result = pcall(v5.notifyPuddleCleaned, instance)

		if not success then
			warn("[FINN-CLEAN-DBG] notifyPuddleCleaned ERRORED:", result)
		end
	end

	local puddleVisual = instance:FindFirstChild("PuddleVisual")
	fadePuddleVisual(puddleVisual and puddleVisual.Value, p)
	ZoneModifierManager.RemoveZone(instance)
end

function IchorPuddleSpawner.WatchPuddleTeardown(instance, instance2)
	if instance and instance2 then
		instance.Destroying:Connect(function()
			if v4 == nil then
				local success, result = pcall(function()
					return require(ServerScriptService.MonsterAI.Modules.IchorDropController)
				end)
				v4 = success and result or false
			end

			local v5 = v4 or nil

			if v5 then
				pcall(v5.notifyPuddleCleaned, instance)
			end
		end)
		instance2.Destroying:Connect(function()
			if instance.Parent then
				print("[FinnIchor] puddle visual destroyed out-of-band - tearing down its hazard zone")
				despawnPuddleZone(instance, 0)
			end
		end)
	end
end

function IchorPuddleSpawner.DespawnPuddlesInRadius(p, p2, value, value2)
	local v5 = value or 0.1
	local count = 0
	local v6 = value2 or 1

	for _, v7 in ipairs(CollectionService:GetTagged("TishaCleanable")) do
		local part = v7
		local success, result = pcall(function()
			if not (part:IsA("BasePart") and part.Parent and sphereIntersectsBox(p, p2, part.CFrame, part.Size)) then
				return
			end

			local v8 = (part.Size * createVector(1, 0, 1)).Magnitude * 0.5

			if v8 <= 0 or 1 - (((p - part.Position) * createVector(1, 0, 1)).Magnitude - p2) / v8 < v5 then
				return
			end

			local puddleVisual = part:FindFirstChild("PuddleVisual")
			local value3 = puddleVisual and puddleVisual.Value

			if value3 and value3:GetAttribute("Stage") ~= nil then
				print("[FINN-CLEAN-DBG] pulse hit STAGED puddle:", part.Name, "stage:", value3:GetAttribute("Stage"))

				if (value3:GetAttribute("Stage") or 0) > 0 then
					value3:SetAttribute("Stage", 0)
					count += 1
				end
			else
				despawnPuddleZone(part, v6)
				count += 1
			end
		end)

		if not success then
			warn("[IchorPuddleSpawner] DespawnPuddlesInRadius: failed on", v7 and v7.Name, "-", result)
		end
	end

	return count
end

function IchorPuddleSpawner.IsPuddleGrowable(part)
	if not (part and part:IsA("BasePart") and part.Parent) then
		return false
	end

	local puddleVisual = part:FindFirstChild("PuddleVisual")
	local value = puddleVisual and puddleVisual.Value

	if not (value and value.Parent) then
		return false
	end

	local stage = value:GetAttribute("Stage")
	return stage ~= nil and stage >= 1 and stage < 5
end

function IchorPuddleSpawner.GrowPuddle(instance)
	if not IchorPuddleSpawner.IsPuddleGrowable(instance) then
		return false
	end

	local value = instance:FindFirstChild("PuddleVisual").Value
	value:SetAttribute("Stage", value:GetAttribute("Stage") + 1)
	return true
end

return IchorPuddleSpawner