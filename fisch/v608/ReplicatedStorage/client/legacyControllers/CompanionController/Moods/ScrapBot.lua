local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CompanionBehavior = require(script.Parent.Parent.CompanionBehavior)
local FishModel = require(ReplicatedStorage.shared.modules.FishModel)
local assets = require(ReplicatedStorage.shared.utils.assets)
local Net = require(ReplicatedStorage.packages.Net)
local remoteEvent = Net:RemoteEvent("Companion/ScrapBot/Collected")
local remoteEvent2 = Net:RemoteEvent("Companion/ScrapBot/Delivered")
local v = {
	Wander = {
		Chance = 35,
		Interval = 12
	},
	Dance = {
		Chance = 15,
		Interval = 25
	},
	Confused = {
		Chance = 12,
		Interval = 30
	},
	SixSeven = {
		Chance = 5,
		Interval = 45
	},
	Dive = {
		Chance = 0,
		Interval = 1e999
	}
}
local v2 = {
	Dance = "Dance",
	Confused = "Confused",
	SixSeven = "SixSeven"
}
local cframe = CFrame.Angles(0, 1.5707963267948966, 0)
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.RespectCanCollide = false
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true
raycastParams.RespectCanCollide = true

local function buildFloorExclusions()
	local world = workspace:FindFirstChild("world")
	local result = {}

	for _, v3 in {
		workspace:FindFirstChild("active"),
		workspace:FindFirstChild("zones"),
		world and world:FindFirstChild("npcs"),
		world and world:FindFirstChild("spawns"),
		world and world:FindFirstChild("water")
	} do
		if v3 then
			table.insert(result, v3)
		end
	end

	return result
end

raycastParams.FilterDescendantsInstances = buildFloorExclusions()
local ScrapBot = {}
ScrapBot.__index = ScrapBot
setmetatable(ScrapBot, CompanionBehavior)

function ScrapBot.new(p)
	local v3 = CompanionBehavior.new(p)
	setmetatable(v3, ScrapBot)
	v3:RegisterMoods(v)
	v3.moodStartTime = 0
	v3.wanderPhaseGen = 0
	v3.wanderSpots = {}
	v3.wanderSpotIndex = 0
	v3._wanderEnded = false
	v3.emotePhaseGen = 0
	v3._emoteEnded = false
	v3.danceActive = false
	v3.danceAngle = 0
	v3.danceRadius = 5
	v3.danceTargetRadius = 5
	v3.danceYOffset = 0
	v3.danceSpin = 0
	v3.danceDirection = 1
	v3.danceBobPhase = 0
	v3.danceElapsed = 0
	v3.divePhaseGen = 0
	v3.diveOrigin = createVector(0, 0, 0)
	v3.diveReturnPos = nil
	v3.diveVolume = nil
	v3.diveWaterTarget = createVector(0, 0, 0)
	v3.diveEntryPoint = createVector(0, 0, 0)
	v3.divePayload = nil
	v3.diveFishUid = nil
	v3.diveFishName = nil
	v3.diveItemName = nil
	v3.diveGrabAt = nil
	v3.diveGrabDuration = nil
	v3.diveHitbox = nil
	v3.diveTargetLostSince = nil
	v3.diveHoldCFrame = nil
	v3.diveHeldModel = nil
	v3.diveHeldGen = 0
	v3.diveHoldingItem = false
	v3.diveHoverPhase = 0
	v3.diveSearching = false
	v3.diveGrabbed = false
	v3.diveSubmerged = false
	v3._diveEnded = false
	v3.arcActive = false
	v3.arcStart = createVector(0, 0, 0)
	v3.arcTarget = createVector(0, 0, 0)
	v3.arcHeight = 5
	v3.arcLandSound = "Dive"
	v3.arcDuration = 0
	v3.arcElapsed = 0
	v3.arcOnComplete = nil
	v3.waterSwim = nil
	v3.settleState = nil
	return v3
end

function ScrapBot:_UseHoldAnimation()
	if self.diveHoldingItem then
		return self.companion.Animations.HoldItem ~= nil
	end

	return false
end

function ScrapBot:GetWalkAnimation()
	if self:_UseHoldAnimation() then
		return "HoldItem"
	end

	if self.companion.Animations.Walk then
		return "Walk"
	end

	return "Run"
end

function ScrapBot:GetSwimAnimation()
	if self:_UseHoldAnimation() then
		return "HoldItem"
	end

	if self.companion.Animations.Swim then
		return "Swim"
	end

	return (self:GetWalkAnimation())
end

function ScrapBot:_PlayIfPresent(p: string, p2: string?)
	if self.companion.Animations[p] then
		self:PlayAnimation(p)
	elseif p2 and self.companion.Animations[p2] then
		self:PlayAnimation(p2)
	end
end

function ScrapBot:EmitParticles(p2: string, p3: number)
	local part = Instance.new("Part")
	part.Name = "ScrapBotFXAnchor"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(0.1, 0.1, 0.1)
	part.Position = self.companion.RootPart.Position
	part.Parent = workspace
	local flag = false

	for _, emitter in self.companion.Model:GetDescendants() do
		if not (emitter:IsA("ParticleEmitter") and string.find(string.lower(emitter.Name), p2)) then
			continue
		end

		local clone = emitter:Clone()
		clone.Parent = part
		clone:Emit(p3)
		flag = true
	end

	if flag then
		task.delay(3, function()
			if part and part.Parent then
				part:Destroy()
			end
		end)
	else
		part:Destroy()
	end
end

function ScrapBot:_FindHoldAttachment()
	for _, attachment in self.companion.Model:GetDescendants() do
		if attachment:IsA("Attachment") and attachment.Name == "Mouth" then
			return attachment
		end
	end

	return nil
end

function ScrapBot:_ResolveItemAsset(model, childName: string)
	if model:IsA("Model") then
		return model
	end

	local model2 = model:FindFirstChild(childName)

	if model2 and model2:IsA("Model") then
		return model2
	end

	for _, model3 in model:GetChildren() do
		if model3:IsA("Model") and model3.Name ~= "RenderContainer" then
			return model3
		end
	end

	return nil
end

function ScrapBot:_BuildItemModel(p: string)
	local async = assets.getAsync("item", p)

	if not async then
		return nil
	end

	local _ResolveItemAsset = self:_ResolveItemAsset(async, p)

	if not _ResolveItemAsset then
		return nil
	end

	local clone = _ResolveItemAsset:Clone()
	local primaryPart = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart")

	if not primaryPart then
		clone:Destroy()
		return nil
	end

	clone.PrimaryPart = primaryPart

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("Script") or descendant:IsA("LocalScript") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = false
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
			descendant.Massless = true
			descendant.CastShadow = false
		end
	end

	for _, part in clone:GetDescendants() do
		if not (part:IsA("BasePart") and part ~= primaryPart) then
			continue
		end

		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = primaryPart
		weldConstraint.Part1 = part
		weldConstraint.Parent = primaryPart
	end

	self:_FitHeldModel(clone)
	return clone
end

function ScrapBot:_FitHeldModel(instance)
	local extentsSize = instance:GetExtentsSize()
	local v3 = math.max(extentsSize.X, extentsSize.Y, extentsSize.Z)

	if v3 <= 0 then
		return
	end

	if v3 > 3 then
		instance:ScaleTo(3 / v3 * instance:GetScale())
	elseif v3 < 1 then
		instance:ScaleTo(1 / v3 * instance:GetScale())
	end
end

function ScrapBot:_BuildFishModel(name: string)
	return FishModel.Create({
		Name = name,
		ItemData = {
			Name = name
		},
		ResizeArgs = {
			MaxSize = 3
		},
		RemoveScripts = true,
		CastShadow = false
	})
end

function ScrapBot:SpawnHeldItem(p: string, flag: boolean)
	local _FindHoldAttachment = self:_FindHoldAttachment()

	if not _FindHoldAttachment then
		return false
	end

	self:ClearHeldModel()
	local diveHeldGen = self.diveHeldGen
	task.spawn(function()
		local diveHeldModel

		if flag then
			diveHeldModel = self:_BuildFishModel(p)
		else
			diveHeldModel = self:_BuildItemModel(p)
		end

		if not diveHeldModel then
			if flag then
				diveHeldModel = self:_BuildItemModel(p)
			else
				diveHeldModel = self:_BuildFishModel(p)
			end
		end

		if not (diveHeldModel and diveHeldModel.PrimaryPart) then
			warn((`[ScrapBot] no held model built for "{p}" (isFish={tostring(flag)})`))
			return
		end

		if self.diveHeldGen ~= diveHeldGen or not _FindHoldAttachment.Parent then
			diveHeldModel:Destroy()
			return
		end

		local parent = _FindHoldAttachment.Parent
		diveHeldModel:PivotTo(_FindHoldAttachment.WorldCFrame * cframe)
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = parent
		weldConstraint.Part1 = diveHeldModel.PrimaryPart
		weldConstraint.Parent = diveHeldModel.PrimaryPart
		diveHeldModel.Name = "ScrapBotHeldItem"
		diveHeldModel.Parent = self.companion.Model
		self.diveHeldModel = diveHeldModel
	end)
	return true
end

function ScrapBot:ClearHeldModel()
	self.diveHeldGen += 1
	self.diveHoldingItem = false

	if self.diveHeldModel then
		self.diveHeldModel:Destroy()
		self.diveHeldModel = nil
	end
end

function ScrapBot:_GetFloorY(vector2: Vector3, p: number)
	local raycastResult = workspace:Raycast(vector2, Vector3.new(0, -p, 0), raycastParams)

	if raycastResult then
		return raycastResult.Position.Y
	end

	return nil
end

function ScrapBot:_MaxSearchDepth(data)
	if data.HasFloor then
		return (math.min(14, (data.SurfaceY - data.FloorY) * 0.5))
	end

	return 10
end

function ScrapBot:_FindWaterVolume(vector2: Vector3)
	local zones = workspace:FindFirstChild("zones")
	local fishing = zones and zones:FindFirstChild("fishing")

	if not fishing then
		return nil
	end

	overlapParams.FilterDescendantsInstances = { fishing }
	local partBoundsInRadius = workspace:GetPartBoundsInRadius(vector2, 60, overlapParams)
	local v3 = 1e999
	local v4 = nil

	for _, zone in partBoundsInRadius do
		local v6 = zone.Size * 0.5
		local pointToObjectSpace = zone.CFrame:PointToObjectSpace(vector2)
		local vector3 = Vector3.new(
			math.clamp(pointToObjectSpace.X, -v6.X, v6.X),
			math.clamp(pointToObjectSpace.Y, -v6.Y, v6.Y),
			(math.clamp(pointToObjectSpace.Z, -v6.Z, v6.Z))
		)
		local pointToWorldSpace = zone.CFrame:PointToWorldSpace(vector3)
		local magnitude = (pointToWorldSpace - vector2).Magnitude

		if v3 <= magnitude then
			continue
		end

		local pointToWorldSpace2 = zone.CFrame:PointToWorldSpace((Vector3.new(vector3.X, v6.Y, vector3.Z)))
		local Y = pointToWorldSpace2.Y
		local _GetFloorY = self:_GetFloorY(pointToWorldSpace2, zone.Size.Y)
		local floorY = _GetFloorY or Y - zone.Size.Y

		if Y - floorY < 4 then
			continue
		end

		v4 = {
			Zone = zone,
			Point = pointToWorldSpace,
			SurfaceY = Y,
			FloorY = floorY,
			HasFloor = _GetFloorY ~= nil
		}
		v3 = magnitude
	end

	return v4
end

function ScrapBot:_SwimPointIn(p, vector2: Vector3)
	local v3 = math.min(6, self:_MaxSearchDepth(p))
	local v4 = math.clamp(p.SurfaceY - v3, p.FloorY + 2, p.SurfaceY - 2)
	return (Vector3.new(vector2.X, v4, vector2.Z))
end

function ScrapBot:_ClampToZone(p, vector2: Vector3)
	local zone = p.Zone
	local v3 = zone.Size * 0.5
	local pointToObjectSpace = zone.CFrame:PointToObjectSpace(vector2)
	local vector3 = Vector3.new(
		math.clamp(pointToObjectSpace.X, -v3.X, v3.X),
		math.clamp(pointToObjectSpace.Y, -v3.Y, v3.Y),
		(math.clamp(pointToObjectSpace.Z, -v3.Z, v3.Z))
	)
	return zone.CFrame:PointToWorldSpace(vector3)
end

function ScrapBot:_DiveEntryPoint()
	local diveVolume = self.diveVolume
	local position = self.companion.RootPart.Position
	local surfaceY

	if diveVolume then
		surfaceY = diveVolume.SurfaceY
	else
		surfaceY = self.diveWaterTarget.Y
	end

	local v3 = (self.diveWaterTarget - position) * createVector(1, 0, 1)
	local vector2

	if v3.Magnitude < 1 then
		local v4 = math.random() * 3.141592653589793 * 2
		vector2 = Vector3.new(math.cos(v4), 0, (math.sin(v4)))
	else
		vector2 = v3.Unit
	end

	local v4 = self.diveWaterTarget + vector2 * 8

	if diveVolume then
		v4 = self:_ClampToZone(diveVolume, v4)
	end

	return (Vector3.new(v4.X, surfaceY + -0.5, v4.Z))
end

function ScrapBot:_DivePoint()
	local diveVolume = self.diveVolume

	if diveVolume then
		return self:_SwimPointIn(diveVolume, self.diveWaterTarget)
	end

	return self.diveWaterTarget
end

function ScrapBot:_IsSubmerged(p2)
	return self.companion.RootPart.Position.Y < p2.SurfaceY - 2
end

function ScrapBot:_OwnerPosition()
	local character = self.companion.Owner.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	return humanoidRootPart and humanoidRootPart.Position
end

function ScrapBot:_OwnerDistance()
	local _OwnerPosition = self:_OwnerPosition()

	if _OwnerPosition then
		return (self.companion.RootPart.Position - _OwnerPosition).Magnitude
	end

	return nil
end

function ScrapBot:_OwnerFrontPosition()
	local character = self.companion.Owner.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		return humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 9
	end

	return nil
end

function ScrapBot:_ExitPoint()
	local diveVolume = self.diveVolume

	if not diveVolume then
		return nil
	end

	local _OwnerPosition = self:_OwnerPosition()

	if _OwnerPosition then
		return self:_ClampToZone(diveVolume, _OwnerPosition)
	end

	return nil
end

function ScrapBot:_ResolveHitbox()
	if self.diveHitbox and self.diveHitbox.Parent then
		return self.diveHitbox
	end

	local diveFishUid = self.diveFishUid

	if not diveFishUid then
		return nil
	end

	for _, part in CollectionService:GetTagged("RoamingFishHitbox") do
		if not (part:IsA("BasePart") and part:GetAttribute("UID") == diveFishUid) then
			continue
		end

		self.diveHitbox = part
		return part
	end

	return nil
end

function ScrapBot:_ResolveHeldName()
	if self.divePayload == "Material" then
		return self.diveItemName
	end

	if self.divePayload ~= "Fish" then
		return nil
	end

	if self.diveFishName then
		return self.diveFishName
	end

	local _ResolveHitbox = self:_ResolveHitbox()
	local fishName = _ResolveHitbox and _ResolveHitbox:GetAttribute("FishName")

	if typeof(fishName) == "string" then
		return fishName
	end

	return nil
end

function ScrapBot:_RollSearchDepth(p)
	local v3 = p.FloorY + 2
	local v4 = p.SurfaceY - 2

	if v4 <= v3 then
		return v3
	end

	local _MaxSearchDepth = self:_MaxSearchDepth(p)
	local v5 = math.min(3, _MaxSearchDepth)
	local v6 = math.clamp(p.SurfaceY - v5, v3, v4)
	local v7 = math.clamp(p.SurfaceY - _MaxSearchDepth, v3, v4)

	if v6 <= v7 then
		return v6
	end

	return v7 + math.random() * (v6 - v7)
end

function ScrapBot:_RollSearchPoint()
	local v3 = math.random() * 3.141592653589793 * 2
	local v4 = 4 + math.random() * 4
	local v5 = self.diveWaterTarget + Vector3.new(math.cos(v3) * v4, 0, math.sin(v3) * v4)
	local diveVolume = self.diveVolume

	if not diveVolume then
		return v5
	end

	if not self.diveSubmerged then
		return (Vector3.new(v5.X, self:_RollSearchDepth(diveVolume), v5.Z))
	end

	local v6 = (math.random() * 2 - 1) * 4
	local v7 = math.clamp(self.diveWaterTarget.Y + v6, diveVolume.FloorY + 2, diveVolume.SurfaceY - 2)
	return (Vector3.new(v5.X, v7, v5.Z))
end

function ScrapBot:StartArc(arcTarget: Vector3, arcOnComplete, p: number?, value: string?)
	self:StopMoving()
	local position = self.companion.RootPart.Position
	local magnitude = (arcTarget - position).Magnitude
	self.arcActive = true
	self.arcStart = position
	self.arcTarget = arcTarget
	self.arcHeight = p or math.clamp(magnitude * 0.4, 5, 16)
	self.arcLandSound = value or "Dive"
	self.arcDuration = math.max(magnitude / 22, 0.9)
	self.arcElapsed = 0
	self.arcOnComplete = arcOnComplete

	if self:_UseHoldAnimation() then
		self:PlayAnimation("HoldItem")
	else
		self:PlayAnimation(self.companion.Animations.Jump and "Jump" or self:GetWalkAnimation())
	end

	self:PlaySound("Jump", true)
	self:EmitParticles("jump", 5)
end

function ScrapBot:StopArc()
	self.arcActive = false
	self.arcOnComplete = nil
end

function ScrapBot:_TickArc(p: number)
	if not self.arcActive then
		return
	end

	self.arcElapsed += p
	local v3 = math.min(self.arcElapsed / self.arcDuration, 1)
	local v4 = self.arcStart:Lerp(self.arcTarget, v3) + Vector3.new(0, 4 * self.arcHeight * v3 * (1 - v3), 0)
	local v5 = (self.arcTarget - self.arcStart) * createVector(1, 0, 1)

	if v5.Magnitude > 0.001 then
		self.companion.RootPart.CFrame = CFrame.lookAt(v4, v4 + v5.Unit) * CFrame.Angles(0, 0, 0)
	else
		self.companion.RootPart.CFrame = CFrame.new(v4) * self.companion.RootPart.CFrame.Rotation
	end

	if v3 >= 1 then
		local arcOnComplete = self.arcOnComplete
		self:StopArc()
		self:PlaySound(self.arcLandSound, true)

		if self.arcLandSound == "Dive" then
			self:EmitParticles("splash", 5)
		end

		if arcOnComplete then
			arcOnComplete()
		end
	end
end

function ScrapBot:StartWaterSwim(vector2: Vector3, speed: number, onArrive, trackFn)
	self:StopMoving()
	self.waterSwim = {
		position = self.companion.RootPart.Position,
		target = vector2,
		speed = speed,
		arriveRadius = 2,
		trackFn = trackFn,
		onArrive = onArrive
	}
	self:PlayAnimation(self:GetSwimAnimation())
end

function ScrapBot:StopWaterSwim()
	self.waterSwim = nil
end

function ScrapBot:_TickWaterSwim(p: number)
	local waterSwim = self.waterSwim

	if not waterSwim then
		return
	end

	local target = waterSwim.trackFn and waterSwim.trackFn()

	if target then
		waterSwim.target = target
	end

	local v4 = waterSwim.target - waterSwim.position
	local magnitude = v4.Magnitude
	local v5 = waterSwim.speed * p

	if magnitude <= v5 then
		waterSwim.position = waterSwim.target
	else
		waterSwim.position += v4.Unit * v5
	end

	local rootPart = self.companion.RootPart
	local vector2 = Vector3.new(v4.X, 0, v4.Z)

	if vector2.Magnitude > 0.001 then
		local v6 = vector2.Magnitude * 0.8390996311772799
		local unit = Vector3.new(v4.X, math.clamp(v4.Y, -v6, v6), v4.Z).Unit
		rootPart.CFrame = CFrame.lookAt(waterSwim.position, waterSwim.position + unit) * CFrame.Angles(0, 0, 0)
	else
		rootPart.CFrame = CFrame.new(waterSwim.position) * rootPart.CFrame.Rotation
	end

	if magnitude <= waterSwim.arriveRadius then
		local onArrive = waterSwim.onArrive
		self.waterSwim = nil

		if onArrive then
			onArrive()
		end
	end
end

function ScrapBot:_StartSettleToOwner(onComplete)
	local rootPart = self.companion.RootPart
	local cFrame = rootPart.CFrame
	local _OwnerPosition = self:_OwnerPosition()
	local targetCF

	if _OwnerPosition then
		local v4 = (_OwnerPosition - rootPart.Position) * createVector(1, 0, 1)

		if v4.Magnitude > 0.001 then
			targetCF = CFrame.lookAt(rootPart.Position, rootPart.Position + v4.Unit) * CFrame.Angles(0, 0, 0)
		else
			targetCF = cFrame
		end
	else
		targetCF = cFrame
	end

	self.settleState = {
		elapsed = 0,
		startCF = cFrame,
		targetCF = targetCF,
		onComplete = onComplete
	}
end

function ScrapBot:_TickSettle(p: number)
	local settleState = self.settleState

	if not settleState then
		return
	end

	settleState.elapsed += p
	local v3 = math.min(settleState.elapsed / 0.25, 1)
	self.companion.RootPart.CFrame = settleState.startCF:Lerp(settleState.targetCF, v3)

	if v3 >= 1 then
		local onComplete = settleState.onComplete
		self.settleState = nil

		if onComplete then
			onComplete()
		end
	end
end

function ScrapBot.Update(object, p: number)
	if object.activeMood then
		return nil
	end

	local state = object.companion.State

	if state == "Walking" or state == "Jumping" then
		return nil
	end

	return object:RollMoods(p)
end

function ScrapBot:StartMood(activeMood: string, p)
	self.activeMood = activeMood
	self.moodStartTime = tick()
	self._wanderEnded = false
	self._diveEnded = false
	self._emoteEnded = false

	if activeMood == "Wander" then
		self:StartWander(p)
	elseif activeMood == "Dive" then
		self:StartDive(p)
	elseif activeMood == "Dance" then
		self:StartDance()
	elseif activeMood == "Confused" then
		self:StartConfused()
	elseif v2[activeMood] then
		self:StartEmote(activeMood)
	end
end

function ScrapBot:UpdateMood(p: number)
	if not self.arcActive and not self.danceActive and self.waterSwim == nil and self.diveHoldCFrame == nil and self.settleState == nil then
		self:_TickMovement(p)
	end

	self:_TickArc(p)
	self:_TickWaterSwim(p)
	self:_TickSettle(p)
	self:_TickDance(p)

	if self.diveHoldCFrame and not (self.arcActive or self.settleState) then
		self.diveHoverPhase += p * 2.5
		local v3 = math.sin(self.diveHoverPhase) * 0.35
		self.companion.RootPart.CFrame = self.diveHoldCFrame + Vector3.new(0, v3, 0)
	end

	if self.activeMood == "Dive" then
		if self.diveSearching and not self.diveGrabbed then
			local diveGrabAt = self.diveGrabAt

			if diveGrabAt and diveGrabAt <= workspace:GetServerTimeNow() then
				self:EnterDivePhase("Grab")
			end
		end

		if (self.divePayload == "Fish" or self.divePayload == "Refine") and not self.diveGrabbed then
			local _ResolveHitbox = self:_ResolveHitbox()
			local _OwnerDistance = self:_OwnerDistance()
			local v3

			if _OwnerDistance == nil then
				v3 = false
			else
				v3 = _OwnerDistance > 60
			end

			if _ResolveHitbox and not v3 then
				self.diveTargetLostSince = nil
			elseif self.diveTargetLostSince then
				if tick() - self.diveTargetLostSince > 0.5 then
					self:EnterDivePhase("SwimBack")
				end
			else
				self.diveTargetLostSince = tick()
			end
		end

		if tick() - self.moodStartTime > 45 then
			return true
		end
	end

	if v2[self.activeMood] and tick() - self.moodStartTime > 20 or (self._wanderEnded or self._diveEnded or self._emoteEnded) then
		return true
	end

	return false
end

function ScrapBot:StopMood()
	if not self.activeMood then
		return
	end

	if self.activeMood == "Wander" then
		self:CleanupWander()
	elseif self.activeMood == "Dive" then
		self:CleanupDive()
	elseif self.activeMood == "Dance" then
		self:CleanupDance()
	elseif self.activeMood == "Confused" then
		self:CleanupConfused()
	elseif v2[self.activeMood] then
		self:CleanupEmote()
	end

	self.activeMood = nil
end

function ScrapBot:OnPhase(p: string, _)
	if p == "Grab" and self.activeMood == "Dive" then
		self:EnterDivePhase("Grab")
	end
end

function ScrapBot:RequestInterrupt()
	if self.danceActive then
		self.danceActive = false
		self:PlayAnimation(self:GetWalkAnimation())
	end

	CompanionBehavior.RequestInterrupt(self)
end

function ScrapBot:StartEmote(p: string)
	local v3 = v2[p]

	if not (v3 and self.companion.Animations[v3]) then
		self._emoteEnded = true
		return
	end

	self:StopMoving()
	self:SetState("MoodAction")
	self:SetFaceOwner(true)
	self:PlayAnimation(v3)
	self.emotePhaseGen += 1
	local emotePhaseGen = self.emotePhaseGen
	local v4 = 4 + math.random() * 3
	task.delay(v4, function()
		if self.activeMood == p and self.emotePhaseGen == emotePhaseGen then
			self._emoteEnded = true
		end
	end)
end

function ScrapBot:CleanupEmote()
	self.emotePhaseGen += 1
	self:StopMoving()
	self:SetFaceOwner(false)
	self._emoteEnded = false
end

function ScrapBot:StartDance()
	if not self.companion.Animations.Dance then
		self._emoteEnded = true
		return
	end

	local _OwnerPosition = self:_OwnerPosition()

	if not _OwnerPosition then
		self._emoteEnded = true
		return
	end

	self:StopMoving()
	self:SetState("MoodAction")
	self:SetFaceOwner(false)
	local rootPart = self.companion.RootPart
	local v3 = (rootPart.Position - _OwnerPosition) * createVector(1, 0, 1)

	if v3.Magnitude < 0.1 then
		self.danceAngle = math.random() * 3.141592653589793 * 2
		self.danceRadius = 5
	else
		self.danceAngle = math.atan2(v3.Z, v3.X)
		self.danceRadius = v3.Magnitude
	end

	self.danceTargetRadius = 5 + math.random() * 2
	self.danceYOffset = rootPart.Position.Y - _OwnerPosition.Y
	local _, danceSpin = rootPart.CFrame:ToOrientation()
	self.danceSpin = danceSpin
	self.danceDirection = math.random() > 0.5 and 1 or -1
	self.danceBobPhase = 0
	self.danceElapsed = 0
	self.danceActive = true
	self:PlayAnimation("Dance")
end

function ScrapBot:_TickDance(p: number)
	if not self.danceActive then
		return
	end

	local _OwnerPosition = self:_OwnerPosition()

	if _OwnerPosition then
		self.danceElapsed += p
		self.danceAngle += p * 1.2566370614359172 * self.danceDirection
		self.danceSpin += p * 1.0471975511965976 * self.danceDirection
		self.danceBobPhase += p * 3
		local v3 = math.min(p * 4, 1)
		self.danceRadius += (self.danceTargetRadius - self.danceRadius) * v3
		self.danceYOffset += (0 - self.danceYOffset) * v3
		local v4 = math.sin(self.danceBobPhase) * 0.25
		local v5 = _OwnerPosition + Vector3.new(
			math.cos(self.danceAngle) * self.danceRadius,
			self.danceYOffset + v4,
			math.sin(self.danceAngle) * self.danceRadius
		)
		local rootPart = self.companion.RootPart
		local targetRotation = CFrame.Angles(0, self.danceSpin, 0) * CFrame.Angles(0, 0, 0)
		rootPart.CFrame = CFrame.new(v5) * targetRotation
		self.companion.TargetRotation = targetRotation

		if self.danceElapsed >= 10 then
			self.danceActive = false
			self._emoteEnded = true
		end
	else
		self.danceActive = false
		self._emoteEnded = true
	end
end

function ScrapBot:CleanupDance()
	self:StopMoving()
	self:SetFaceOwner(false)
	self.danceActive = false
	self.danceElapsed = 0
	self._emoteEnded = false
end

function ScrapBot:StartConfused()
	if not self.companion.Animations.Confused then
		self._emoteEnded = true
		return
	end

	if not self:_OwnerFrontPosition() then
		self._emoteEnded = true
		return
	end

	self:SetState("MoodAction")
	self:EnterConfusedPhase("Approach")
end

function ScrapBot:EnterConfusedPhase(p: string)
	self.emotePhaseGen += 1
	local emotePhaseGen = self.emotePhaseGen

	local function stillValid()
		return self.activeMood == "Confused" and self.emotePhaseGen == emotePhaseGen
	end

	if p == "Approach" then
		self:SetFaceOwner(false)
		local v3 = {
			speed = 9,
			animation = self:GetWalkAnimation(),
			arriveRadius = 2,
			trackFn = function()
				return self:_OwnerFrontPosition()
			end,
			onArrive = function()
				local v4

				if self.activeMood == "Confused" then
					v4 = self.emotePhaseGen == emotePhaseGen
				else
					v4 = false
				end

				if v4 then
					self:EnterConfusedPhase("React")
				end
			end
		}
		self:MoveTo(createVector(0, 0, 0), v3)
	elseif p == "React" then
		self:StopMoving()
		self:SetFaceOwner(true)
		self:PlayAnimation("Confused")
		task.delay(3, function()
			local v3

			if self.activeMood == "Confused" then
				v3 = self.emotePhaseGen == emotePhaseGen
			else
				v3 = false
			end

			if v3 then
				self:EnterConfusedPhase("Retreat")
			end
		end)
	elseif p == "Retreat" then
		self:SetFaceOwner(false)
		local character = self.companion.Owner.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			local v3 = humanoidRootPart.CFrame.RightVector * (math.random() > 0.5 and 1 or -1)
			self:MoveTo(self.companion.RootPart.Position + v3 * 6, {
				speed = 7,
				animation = self:GetWalkAnimation(),
				arriveRadius = 1.5,
				onArrive = function()
					local v4

					if self.activeMood == "Confused" then
						v4 = self.emotePhaseGen == emotePhaseGen
					else
						v4 = false
					end

					if v4 then
						self._emoteEnded = true
					end
				end
			})
		else
			self._emoteEnded = true
		end
	end
end

function ScrapBot:CleanupConfused()
	self.emotePhaseGen += 1
	self:StopMoving()
	self:SetFaceOwner(false)
	self._emoteEnded = false
end

function ScrapBot:StartWander(p)
	self:SetState("MoodAction")
	self.wanderSpots = p.WanderSpots or {}
	self.wanderSpotIndex = 0

	if #self.wanderSpots == 0 then
		self._wanderEnded = true
	else
		self:EnterWanderPhase("WalkToNextSpot")
	end
end

function ScrapBot:EnterWanderPhase(p: string)
	self.wanderPhaseGen += 1
	local wanderPhaseGen = self.wanderPhaseGen

	local function stillValid()
		return self.activeMood == "Wander" and self.wanderPhaseGen == wanderPhaseGen
	end

	if p == "WalkToNextSpot" then
		self.wanderSpotIndex += 1

		if self.wanderSpotIndex > #self.wanderSpots then
			self._wanderEnded = true
		else
			self:MoveTo(self.wanderSpots[self.wanderSpotIndex], {
				speed = 6,
				animation = self:GetWalkAnimation(),
				arriveRadius = 1.5,
				onArrive = function()
					local v3

					if self.activeMood == "Wander" then
						v3 = self.wanderPhaseGen == wanderPhaseGen
					else
						v3 = false
					end

					if v3 then
						self:EnterWanderPhase("PauseAtSpot")
					end
				end
			})
		end
	elseif p == "PauseAtSpot" then
		self:StopMoving()
		self:_PlayIfPresent("SitIdle", "Idle")
		local v3 = 0.5 + math.random() * 1.3
		task.delay(v3, function()
			local v4

			if self.activeMood == "Wander" then
				v4 = self.wanderPhaseGen == wanderPhaseGen
			else
				v4 = false
			end

			if v4 then
				self:EnterWanderPhase("WalkToNextSpot")
			end
		end)
	end
end

function ScrapBot:CleanupWander()
	self:StopMoving()
	self.wanderSpots = {}
	self.wanderSpotIndex = 0
	self._wanderEnded = false
end

function ScrapBot:StartDive(data)
	local position = self.companion.RootPart.Position
	local _FindWaterVolume = self:_FindWaterVolume(data.WaterTarget or position)

	if not _FindWaterVolume then
		self._diveEnded = true
		return
	end

	self:SetState("MoodAction")
	self.diveOrigin = position
	self.diveReturnPos = position
	self.diveVolume = _FindWaterVolume
	self.diveWaterTarget = _FindWaterVolume.Point
	self.diveSubmerged = self:_IsSubmerged(_FindWaterVolume)

	if self.diveSubmerged then
		local _ClampToZone = self:_ClampToZone(_FindWaterVolume, position)
		self.diveEntryPoint = _ClampToZone
		self.diveWaterTarget = _ClampToZone
	else
		local _DiveEntryPoint = self:_DiveEntryPoint()
		self.diveEntryPoint = _DiveEntryPoint
		self.diveWaterTarget = Vector3.new(_DiveEntryPoint.X, _FindWaterVolume.Point.Y, _DiveEntryPoint.Z)
	end

	self.divePayload = data.Payload
	self.diveFishUid = data.FishUID
	self.diveFishName = data.FishName
	self.diveItemName = data.ItemName
	self.diveGrabAt = data.GrabAt or workspace:GetServerTimeNow() + 5
	self.diveGrabDuration = data.GrabDuration
	self.diveHitbox = nil
	self.diveTargetLostSince = nil
	self.diveHoldCFrame = nil
	self.diveHoldingItem = false
	self.diveHoverPhase = 0
	self.diveSearching = false
	self.diveGrabbed = false
	self.companion.MoodIgnoreGroundClamp = true
	self.companion.MoodUninterruptible = true
	self.companion.AllowWater = true
	self:EnterDivePhase("ArcIn")
end

function ScrapBot:EnterDivePhase(p: string)
	self.divePhaseGen += 1
	local divePhaseGen = self.divePhaseGen

	local function stillValid()
		return self.activeMood == "Dive" and self.divePhaseGen == divePhaseGen
	end

	if p == "ArcIn" then
		self.diveSearching = false
		self.diveHoldCFrame = nil

		if not self.diveSubmerged then
			self:StartArc(self.diveEntryPoint, function()
				local v3

				if self.activeMood == "Dive" then
					v3 = self.divePhaseGen == divePhaseGen
				else
					v3 = false
				end

				if not v3 then
					return
				end

				if self.divePayload == "Fish" or self.divePayload == "Refine" then
					self:EnterDivePhase("Chase")
				else
					self:EnterDivePhase("Search")
				end
			end, nil, "Dive")
		elseif self.divePayload == "Fish" or self.divePayload == "Refine" then
			self:EnterDivePhase("Chase")
		else
			self:EnterDivePhase("Search")
		end
	elseif p == "Search" then
		self.diveSearching = true
		self.diveHoldCFrame = nil
		local v3 = 7 + math.random() * 7
		self:StartWaterSwim(self:_RollSearchPoint(), v3, function()
			local v4

			if self.activeMood == "Dive" then
				v4 = self.divePhaseGen == divePhaseGen
			else
				v4 = false
			end

			if not v4 then
				return
			end

			self.diveHoldCFrame = self.companion.RootPart.CFrame
			local v5 = 0.5 + math.random() * 0.7
			task.delay(v5, function()
				local v6

				if self.activeMood == "Dive" then
					v6 = self.divePhaseGen == divePhaseGen
				else
					v6 = false
				end

				if v6 then
					self.diveHoldCFrame = nil
					self:EnterDivePhase("Search")
				end
			end)
		end)
	elseif p == "Chase" then
		self.diveSearching = false
		self.diveHoldCFrame = nil
		local _ResolveHitbox = self:_ResolveHitbox()

		if _ResolveHitbox then
			self:StartWaterSwim(_ResolveHitbox.Position, 14, function()
				local v3

				if self.activeMood == "Dive" then
					v3 = self.divePhaseGen == divePhaseGen
				else
					v3 = false
				end

				if v3 then
					self:EnterDivePhase("Grab")
				end
			end, function()
				local _ResolveHitbox2 = self:_ResolveHitbox()
				return _ResolveHitbox2 and _ResolveHitbox2.Position
			end)
		else
			self:EnterDivePhase("SwimBack")
		end
	elseif p == "Grab" then
		self.diveGrabbed = true
		self.diveSearching = false
		self:StopArc()
		self:StopWaterSwim()
		self:StopMoving()
		self.diveHoldCFrame = self.companion.RootPart.CFrame
		self:PlaySound("Happy", true)
		local _ResolveHeldName = self:_ResolveHeldName()

		if _ResolveHeldName then
			self.diveHoldingItem = self:SpawnHeldItem(_ResolveHeldName, self.divePayload == "Fish")
		end

		if self:_UseHoldAnimation() then
			self:PlayAnimation("HoldItem")
		else
			self:_PlayIfPresent("Wiggle", self:GetSwimAnimation())
		end

		local diveGrabDuration = self.diveGrabDuration or 1.2
		task.delay(diveGrabDuration, function()
			local v3

			if self.activeMood == "Dive" then
				v3 = self.divePhaseGen == divePhaseGen
			else
				v3 = false
			end

			if not v3 then
				return
			end

			if self.companion.IsOwner and self.diveFishUid and (self.divePayload == "Fish" or self.divePayload == "Refine") then
				remoteEvent:FireServer(self.diveFishUid, self.divePayload)
			end

			self.diveHoldCFrame = nil
			self:EnterDivePhase("SwimBack")
		end)
	elseif p == "SwimBack" then
		self.diveSearching = false
		self.diveHoldCFrame = nil
		local _ExitPoint = self:_ExitPoint()

		if not _ExitPoint then
			self:EnterDivePhase("Surface")
			return
		end

		local position = self.companion.RootPart.Position

		if (Vector3.new(_ExitPoint.X, 0, _ExitPoint.Z) - Vector3.new(position.X, 0, position.Z)).Magnitude < 8 then
			self:EnterDivePhase("Surface")
			return
		end

		local diveVolume = self.diveVolume
		local v3

		if diveVolume then
			v3 = self:_SwimPointIn(diveVolume, _ExitPoint)
		else
			v3 = Vector3.new(_ExitPoint.X, position.Y, _ExitPoint.Z)
		end

		self:StartWaterSwim(v3, 14, function()
			local v4

			if self.activeMood == "Dive" then
				v4 = self.divePhaseGen == divePhaseGen
			else
				v4 = false
			end

			if v4 then
				self:EnterDivePhase("Surface")
			end
		end)
	elseif p == "Surface" then
		self.diveSearching = false
		self.diveHoldCFrame = nil

		if self.diveSubmerged then
			self:EnterDivePhase("ArcOut")
			return
		end

		local diveVolume = self.diveVolume
		local position = self.companion.RootPart.Position
		local v3

		if diveVolume then
			v3 = diveVolume.SurfaceY
		else
			v3 = position.Y
		end

		self:StartWaterSwim(Vector3.new(position.X, v3 + -0.5, position.Z), 12, function()
			local v4

			if self.activeMood == "Dive" then
				v4 = self.divePhaseGen == divePhaseGen
			else
				v4 = false
			end

			if v4 then
				self:EnterDivePhase("ArcOut")
			end
		end)
	elseif p == "ArcOut" then
		self.diveSearching = false
		self.diveHoldCFrame = nil
		local _OwnerPosition = self:_OwnerPosition()
		local diveReturnPos = self.diveReturnPos

		if _OwnerPosition then
			local v3 = (self.companion.RootPart.Position - _OwnerPosition) * createVector(1, 0, 1)
			diveReturnPos = _OwnerPosition + (v3.Magnitude < 0.001 and createVector(1, 0, 0) or v3.Unit) * 5
		end

		if not diveReturnPos then
			self:EnterDivePhase("Settle")
			return
		end

		if (diveReturnPos - self.companion.RootPart.Position).Magnitude > 60 then
			self:EnterDivePhase("Settle")
			return
		end

		if not self.diveSubmerged then
			self:StartArc(diveReturnPos, function()
				local v3

				if self.activeMood == "Dive" then
					v3 = self.divePhaseGen == divePhaseGen
				else
					v3 = false
				end

				if v3 then
					self:EnterDivePhase("Settle")
				end
			end, nil, "Land")
			return
		end

		local diveVolume = self.diveVolume

		if diveVolume then
			diveReturnPos = self:_ClampToZone(diveVolume, diveReturnPos)
		end

		self:StartWaterSwim(diveReturnPos, 14, function()
			local v3

			if self.activeMood == "Dive" then
				v3 = self.divePhaseGen == divePhaseGen
			else
				v3 = false
			end

			if v3 then
				self:EnterDivePhase("Settle")
			end
		end)
	elseif p == "Settle" then
		self.companion.MoodIgnoreGroundClamp = false
		self.companion.AllowWater = false
		self.companion.MoodUninterruptible = false

		if self.companion.IsOwner and self.divePayload then
			remoteEvent2:FireServer(self.divePayload)
		end

		self:ClearHeldModel()
		self:_PlayIfPresent("Wiggle", "Idle")
		self:_StartSettleToOwner(function()
			local v3

			if self.activeMood == "Dive" then
				v3 = self.divePhaseGen == divePhaseGen
			else
				v3 = false
			end

			if v3 then
				self._diveEnded = true
			end
		end)
	end
end

function ScrapBot:CleanupDive()
	self:StopArc()
	self:StopWaterSwim()
	self:StopMoving()
	self.settleState = nil
	self.companion.MoodIgnoreGroundClamp = false
	self.companion.AllowWater = false
	self.companion.MoodUninterruptible = false
	self.companion.MoodPositionOverride = nil
	self.companion.MoodSmoothTime = nil
	self.diveReturnPos = nil
	self.diveVolume = nil
	self.diveEntryPoint = createVector(0, 0, 0)
	self.divePayload = nil
	self.diveFishUid = nil
	self.diveFishName = nil
	self.diveItemName = nil
	self.diveGrabAt = nil
	self.diveGrabDuration = nil
	self.diveHitbox = nil
	self.diveTargetLostSince = nil
	self.diveHoldCFrame = nil
	self.diveHoldingItem = false
	self.diveHoverPhase = 0
	self.diveSearching = false
	self.diveGrabbed = false
	self.diveSubmerged = false
	self._diveEnded = false
	self:ClearHeldModel()
end

function ScrapBot:Destroy()
	if self.activeMood then
		self:StopMood()
	end

	CompanionBehavior.Destroy(self)
end

return ScrapBot