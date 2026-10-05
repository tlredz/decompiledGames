local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Item = require(ServerStorage.SAM.Services.Adders.Item)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local FishingBar = require(ReplicatedStorage.CAM.Global.FishingBar)
local Analytics = require(ServerStorage.SAM.Services.Reporting.Analytics)
local AntiCheat = require(ServerStorage.SAM.AntiCheat)
local DataPathService = require(ServerStorage.SAM.Services.DataPathService)
local WorldEvents = require(ServerStorage.SAM.Utility.WorldEvents)
local drownedLine = WorldEvents.Get("DrownedLine")
local FishingHandler = require(ServerStorage.SAM.Services.FishingHandler)
local PromptHeld = require(ServerStorage.SAM.Utility.PromptHeld)
local ItemModels = require(ReplicatedStorage.CAM.Global.Collectibles.ItemModels)
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Item2 = require(ServerStorage.SAM.Services.Removers.Item)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local PlayerStatResolver = require(ReplicatedStorage.CAM.Global.PlayerStatResolver)
local Refinement = require(ReplicatedStorage.CAM.Global.Refinement)
local TitleService = require(ServerStorage.SAM.Services.TitleService)
local ServerClientPortal = require(ReplicatedStorage.CAM.Global.ServerClientPortal)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local v = {
	Common = "fish_common",
	Rare = "fish_rare",
	Legendary = "fish_legendary",
	Items = "fish_items"
}
local cast = script:FindFirstChild("Cast")
local unCast = script:FindFirstChild("UnCast")
local struggle = script:FindFirstChild("Struggle")

local function playRodSound(instance, childName: string)
	local humanoidRootPart

	if instance ~= nil then
		humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or nil
	end

	local sound = script:FindFirstChild(childName)

	if humanoidRootPart == nil or sound == nil or not sound:IsA("Sound") then
		return nil
	end

	local clone = sound:Clone()
	clone.Parent = humanoidRootPart
	clone:Play()

	if not clone.Looped then
		clone.Ended:Once(function()
			clone:Destroy()
		end)
	end

	return clone
end

local random = Random.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function generate_id()
	return random:NextNumber()
end

local count = 0
local RareFishingRodServer = {
	Id = {}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getAnimator(instance)
	local humanoid = instance and instance:FindFirstChildOfClass("Humanoid")
	return humanoid and humanoid:FindFirstChildOfClass("Animator")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopStruggle(state)
	if state.StruggleTrack ~= nil then
		state.StruggleTrack:Stop()
		state.StruggleTrack = nil
	end

	if state.StruggleSound ~= nil then
		state.StruggleSound:Stop()
		state.StruggleSound:Destroy()
		state.StruggleSound = nil
	end
end

local v2 = { "skill_stand_still", "pause_gameplay", "NR" }
local v3 = { "pause_gameplay" }

local function setFreeze(state, p, items)
	local getvaluesfolder = Utility.getvaluesfolder(p)

	if getvaluesfolder == nil then
		return
	end

	local freeze = state.Freeze
	state.Freeze = nil

	if items ~= nil then
		local freeze2 = {}

		for _, item in items do
			table.insert(freeze2, Utility.AddValue(getvaluesfolder, item))
		end

		state.Freeze = freeze2
	end

	if freeze ~= nil then
		for _, v4 in freeze do
			v4:Destroy()
		end
	end
end

local function resolveCastPosition(instance, vector2: Vector3?, castRadius: number)
	local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return nil
	end

	local position = humanoidRootPart.Position

	if vector2 == nil then
		return position + humanoidRootPart.CFrame.LookVector * castRadius
	end

	local vector3 = vector2 - position
	local vector4 = Vector3.new(vector3.X, 0, vector3.Z)

	if castRadius < vector4.Magnitude then
		local v4 = vector4.Unit * castRadius
		vector3 = Vector3.new(v4.X, vector3.Y, v4.Z)
	end

	return position + vector3
end

local function findWater(castPosition: Vector3, instance)
	local parents = {}

	for _, v4 in CollectionService:GetTagged("SwimParts") do
		table.insert(parents, v4.Parent or v4)
	end

	if #parents == 0 then
		return nil, nil
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = parents
	raycastParams.BruteForceAllSlow = true
	local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")
	local v4 = math.max(castPosition.Y, humanoidRootPart ~= nil and humanoidRootPart.Position.Y or castPosition.Y) + 50
	local vector2 = Vector3.new(castPosition.X, v4, castPosition.Z)
	local vector3 = Vector3.new(0, -(v4 - castPosition.Y + 25), 0)
	local raycastResult = workspace:Raycast(vector2, vector3, raycastParams)
	local instance2

	if raycastResult ~= nil then
		instance2 = raycastResult.Instance or nil
	end

	instance2 = nil

	if instance2 ~= nil and instance2.Name ~= "TouchPart" and instance2.Name == "Texture" then
		if instance2.Parent ~= nil then
			instance2 = instance2.Parent:FindFirstChild("TouchPart")
		end
	end

	if instance2 ~= nil and not CollectionService:HasTag(instance2, "SwimParts") then
		instance2 = nil
	end

	if instance2 ~= nil and raycastResult ~= nil then
		local raycastParams2 = RaycastParams.new()
		raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams2.FilterDescendantsInstances = { workspace.Debree, instance }
		local raycastResult2 = workspace:Raycast(vector2, vector3, raycastParams2)

		if raycastResult2 ~= nil and raycastResult2.Position.Y > raycastResult.Position.Y then
			instance2 = nil
		end
	end

	if raycastResult == nil then
		return instance2, nil
	end

	return instance2, raycastResult.Position
end

local function findRodTip(instance)
	local tool_Accessories = instance and instance:FindFirstChild("Tool_Accessories")
	local tip = tool_Accessories ~= nil and tool_Accessories:FindFirstChild("Tip", true) or nil

	if tip == nil or not tip:IsA("Attachment") then
		return nil
	end

	return tip
end

local function prepCatchPieces(folder, part)
	local descendants = folder:GetDescendants()

	if folder:IsA("BasePart") then
		table.insert(descendants, folder)
	end

	for _, part2 in descendants do
		if not part2:IsA("BasePart") then
			continue
		end

		part2.Anchored = false
		part2.CanCollide = false
		part2.CanTouch = false
		part2.CanQuery = false
		part2.Massless = true

		if part2 == part then
			continue
		end

		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = part
		weldConstraint.Part1 = part2
		weldConstraint.Parent = part2
	end
end

local function resolveBait(p, _: string)
	local v4 = DataPathService.Get(p, "Slot", "Misc/EquippedBaitId")

	if type(v4) ~= "number" or v4 == 0 then
		return nil
	end

	local item = Character_info_provider.GetItemFromId(p, v4)

	if item == nil then
		local v5 = DataPathService.Get(p, "Slot", "Misc/EquippedBait")

		if type(v5) ~= "string" or v5 == "" then
			return nil
		end

		local item2 = Items[v5]
		local baitTier

		if item2 ~= nil then
			baitTier = item2.BaitTier or nil
		end

		if baitTier == nil then
			return nil
		end

		local heldItem = Utility.HeldItem(Utility.GetData(p), v5)
		local id

		if heldItem ~= nil then
			id = heldItem:FindFirstChild("Id") or nil
		end

		if id == nil then
			return nil
		end

		DataPathService.Set(p, "Slot", "Misc/EquippedBaitId", id.Value)
		return v5, baitTier
	else
		local item2 = Items[item.Name]
		local baitTier

		if item2 ~= nil then
			baitTier = item2.BaitTier or nil
		end

		if baitTier == nil then
			return nil
		end

		return item.Name, baitTier
	end
end

local function cloneBaitRig(childName: string)
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local fishingModels

	if assets ~= nil then
		fishingModels = assets:FindFirstChild("Fishing Models") or nil
	end

	local baitModels

	if fishingModels ~= nil then
		baitModels = fishingModels:FindFirstChild("Bait Models") or nil
	end

	local child = baitModels ~= nil and baitModels:FindFirstChild(childName) or nil

	if child == nil then
		return nil
	end

	local clone = child:Clone()
	local root

	if clone:IsA("BasePart") then
		root = clone
	else
		root = clone:FindFirstChild("Root")
	end

	if root == nil or not root:IsA("BasePart") then
		clone:Destroy()
		return nil
	end

	local v4 = root:FindFirstChild("Tip")

	if v4 == nil or not v4:IsA("Attachment") then
		v4 = Instance.new("Attachment")
		v4.Name = "Tip"
		v4.Parent = root
	end

	return clone, root, v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyIdleBait(state)
	if state.IdleBaitModel ~= nil then
		state.IdleBaitModel:Destroy()
		state.IdleBaitModel = nil
	end
end

local function showIdleBait(p, instance, state, p2: string)
	if state.Casting or state.Casted or state.Uncasting or state.CatchModel ~= nil then
		destroyIdleBait(state) -- equivalent call inferred; original call site unknown
	else
		local bait = resolveBait(p, p2)

		if bait == nil then
			destroyIdleBait(state) -- equivalent call inferred; original call site unknown
		else
			if state.IdleBaitModel ~= nil and state.IdleBaitModel.Parent ~= nil and state.IdleBaitModel.Name == bait then
				return
			end

			destroyIdleBait(state) -- equivalent call inferred; original call site unknown
			local tool_Accessories = instance and instance:FindFirstChild("Tool_Accessories")
			local tip

			if tool_Accessories ~= nil then
				tip = tool_Accessories:FindFirstChild("Tip", true) or nil
			end

			if tip == nil or not tip:IsA("Attachment") then
				tip = nil
			end

			if tip == nil then
				return
			end

			local baitRig, parent, attachment = cloneBaitRig(bait)

			if baitRig == nil or parent == nil or attachment == nil then
				return
			end

			local v6 = tip.WorldPosition - createVector(0, 0.3, 0)
			baitRig:PivotTo(CFrame.new(v6) * attachment.CFrame:Inverse() * parent.CFrame:Inverse() * baitRig:GetPivot())
			prepCatchPieces(baitRig, parent)
			parent.Massless = false
			parent.CustomPhysicalProperties = PhysicalProperties.new(0.1, 0.3, 0.5)
			parent.CollisionGroup = "HumanoidsCollide"
			local ropeConstraint = Instance.new("RopeConstraint")
			ropeConstraint.Name = "FishingLine"
			ropeConstraint.Attachment0 = tip
			ropeConstraint.Attachment1 = attachment
			ropeConstraint.Length = 0.3
			ropeConstraint.Visible = true
			ropeConstraint.Thickness = 0.05
			ropeConstraint.Color = BrickColor.new("Institutional white")
			ropeConstraint.Parent = parent
			baitRig.Parent = workspace.Debree
			parent:SetNetworkOwner(p)
			state.IdleBaitModel = baitRig
		end
	end
end

local function launchBobber(p, instance, state)
	local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")
	local castPosition = state.CastPosition

	if humanoidRootPart == nil or castPosition == nil then
		return
	end

	local tool_Accessories = instance and instance:FindFirstChild("Tool_Accessories")
	local tip

	if tool_Accessories ~= nil then
		tip = tool_Accessories:FindFirstChild("Tip", true) or nil
	end

	if tip == nil or not tip:IsA("Attachment") then
		tip = nil
	end

	state.RodTip = tip

	if tip == nil then
		return
	end

	local worldPosition = tip.WorldPosition
	local v4 = math.max((castPosition - worldPosition).Magnitude / 45, 0.1)
	local vector2 = Vector3.new(0, -workspace.Gravity, 0)
	local calcvel = Utility.calcvel(castPosition, worldPosition, vector2, v4)
	local v5 = 0

	for i = 1, 10 do
		local v6 = v4 * (i / 10)
		local magnitude = (calcvel * v6 + vector2 * 0.5 * v6 * v6).Magnitude

		if v5 < magnitude then
			v5 = magnitude
		end
	end

	destroyIdleBait(state) -- equivalent call inferred; original call site unknown
	local v6 = nil
	local attachment = nil
	local bobberModel = nil

	if state.BaitName ~= nil then
		local baitRig, part, v10 = cloneBaitRig(state.BaitName)

		if baitRig ~= nil and part ~= nil and v10 ~= nil then
			baitRig:PivotTo(CFrame.new(worldPosition) * v10.CFrame:Inverse() * part.CFrame:Inverse() * baitRig:GetPivot())
			prepCatchPieces(baitRig, part)
			bobberModel = baitRig
			attachment = v10
			v6 = part
		end
	end

	if v6 == nil then
		v6 = Instance.new("Part")
		v6.Name = "FishingBobber"
		v6.Shape = Enum.PartType.Ball
		v6.Size = createVector(0.35, 0.35, 0.35)
		v6.Material = Enum.Material.SmoothPlastic
		v6.Transparency = 1
		v6.CanTouch = false
		v6.CanQuery = false
		v6.CFrame = CFrame.new(worldPosition)
		attachment = Instance.new("Attachment")
		attachment.Name = "LineAttachment"
		attachment.Parent = v6
		bobberModel = v6
	end

	local v9

	if v6 == nil or attachment == nil then
		v9 = false
	else
		v9 = bobberModel ~= nil
	end

	assert(v9)
	v6.CanCollide = false
	v6.CollisionGroup = "HumanoidsCollide"
	v6.Massless = false
	v6.CustomPhysicalProperties = PhysicalProperties.new(0.1, 0.3, 0.5)
	v6.AssemblyLinearVelocity = calcvel
	local ropeConstraint = Instance.new("RopeConstraint")
	ropeConstraint.Name = "FishingLine"
	ropeConstraint.Attachment0 = tip
	ropeConstraint.Attachment1 = attachment
	ropeConstraint.Length = v5 * 0.35
	ropeConstraint.Visible = true
	ropeConstraint.Thickness = 0.05
	ropeConstraint.Color = BrickColor.new("Institutional white")
	ropeConstraint.Parent = v6
	count += 1
	bobberModel.Name = `FishingLine_{count}`
	bobberModel.Parent = workspace.Debree
	v6:SetNetworkOwner(p)
	state.Bobber = v6
	state.BobberModel = bobberModel
	state.BobberName = bobberModel.Name
	TweenService:Create(ropeConstraint, TweenInfo.new(v4 * 0.5, Enum.EasingStyle.Linear), {
		Length = v5 * 1.05
	}):Play()
	task.delay(v4, function()
		if v6.Parent == nil or state.Bobber ~= v6 or state.Uncasting then
			return
		end

		v6.AssemblyLinearVelocity = createVector(0, 0, 0)
		v6.AssemblyAngularVelocity = createVector(0, 0, 0)
		local pivot = bobberModel:GetPivot()
		bobberModel:PivotTo(pivot.Rotation + (castPosition + createVector(0, 0.13, 0)) + (pivot.Position - v6.Position))
		v6.CanCollide = true
		local alignPosition = Instance.new("AlignPosition")
		alignPosition.Name = "FloatAlign"
		alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
		alignPosition.Attachment0 = attachment
		alignPosition.Position = castPosition + createVector(0, 0.13, 0)
		alignPosition.ForceRelativeTo = Enum.ActuatorRelativeTo.World
		alignPosition.ForceLimitMode = Enum.ForceLimitMode.PerAxis
		alignPosition.MaxAxesForce = createVector(0, 10000, 0)
		alignPosition.Parent = v6
		v6.AssemblyLinearVelocity = createVector(0, 0, 0)
		v6.AssemblyAngularVelocity = createVector(0, 0, 0)

		if state.WaterPart ~= nil then
			EffectsEvent.ToAllInRange(v6, "FishingCatchFX", "Splash", bobberModel.Name, true)
		end
	end)
end

local function destroyBobber(state)
	if state.BobberModel ~= nil then
		state.BobberModel:Destroy()
		state.BobberModel = nil
	end

	state.BobberName = nil

	if state.Bobber ~= nil then
		if state.Bobber.Parent ~= nil then
			state.Bobber:Destroy()
		end

		state.Bobber = nil
	end

	if state.CatchModel ~= nil then
		state.CatchModel:Destroy()
		state.CatchModel = nil
	end

	state.CatchRoot = nil
	state.HangPoint = nil
	state.CatchClickAt = nil

	if state.ReelPin ~= nil then
		state.ReelPin:Destroy()
		state.ReelPin = nil
	end
end

local function dropCatch(state)
	local catchModel = state.CatchModel
	local catchRoot = state.CatchRoot
	state.CatchModel = nil
	state.CatchRoot = nil
	state.HangPoint = nil
	state.CatchClickAt = nil

	if catchModel == nil or catchModel.Parent == nil then
		return
	end

	local fishingLine = catchModel:FindFirstChild("FishingLine", true)

	if fishingLine ~= nil then
		fishingLine:Destroy()
	end

	local catchPull = catchModel:FindFirstChild("CatchPull", true)

	if catchPull ~= nil then
		catchPull:Destroy()
	end

	catchModel.Parent = workspace.Debree
	local descendants = catchModel:GetDescendants()

	if catchModel:IsA("BasePart") then
		table.insert(descendants, catchModel)
	end

	for _, part in descendants do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = true
		part.CollisionGroup = "HumanoidsCollide"
	end

	if catchRoot ~= nil and catchRoot.Parent ~= nil then
		EffectsEvent.ToAllInRange(catchRoot, "FishingCatchFX", "Drop", catchModel.Name, 20)
	end

	Debris:AddItem(catchModel, 20)
end

local function isSwimming(instance)
	return instance ~= nil and (instance:GetAttribute("SwimState") or 0) > 0
end

local function isGrounded(instance)
	local humanoid = instance ~= nil and instance:FindFirstChildOfClass("Humanoid") or nil
	return humanoid ~= nil and humanoid.FloorMaterial ~= Enum.Material.Air
end

local function pinCharacter(instance, state)
	if state.ReelPin ~= nil then
		state.ReelPin:Destroy()
		state.ReelPin = nil
	end

	local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local part = Instance.new("Part")
	part.Name = "FishingReelPin"
	part.Size = createVector(0, 0, 0)
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.Anchored = true
	part.CFrame = humanoidRootPart.CFrame
	local weld = Instance.new("Weld")
	weld.Part0 = part
	weld.Part1 = humanoidRootPart
	weld.Parent = part
	part.Parent = workspace.Debree
	state.ReelPin = part
end

local function attachCatchModel(bobber, state, pendingCatch: string)
	local fishingLine = bobber:FindFirstChild("FishingLine")

	if fishingLine == nil or not fishingLine:IsA("RopeConstraint") then
		return false
	end

	local attachment1 = fishingLine.Attachment1

	if attachment1 == nil then
		return false
	end

	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local fishingModels

	if assets ~= nil then
		fishingModels = assets:FindFirstChild("Fishing Models") or nil
	end

	local fishModels

	if fishingModels ~= nil then
		fishModels = fishingModels:FindFirstChild("Fish Models") or nil
	end

	local child

	if fishModels ~= nil then
		child = fishModels:FindFirstChild(pendingCatch) or nil
	end

	local clone, basePart, attachment

	if child == nil then
		local unEquipped = ItemModels.Get(pendingCatch, "UnEquipped")

		if unEquipped == nil or not unEquipped:IsA("Model") then
			return false
		end

		clone = unEquipped:Clone()
		clone:ScaleTo(0.5)
		basePart = clone:FindFirstChildWhichIsA("BasePart", true)

		if basePart == nil then
			clone:Destroy()
			return false
		end

		local boundingBox, v5 = clone:GetBoundingBox()
		clone.PrimaryPart = nil
		clone.WorldPivot = boundingBox
		clone:PivotTo(CFrame.new(attachment1.WorldPosition - Vector3.new(0, v5.Y * 0.5 + 0.1, 0)) * boundingBox.Rotation)
		attachment = Instance.new("Attachment")
		attachment.Name = "Tip"
		attachment.Parent = basePart
		attachment.WorldPosition = attachment1.WorldPosition
	else
		clone = child:Clone()

		if clone:IsA("BasePart") then
			basePart = clone
		else
			basePart = clone:FindFirstChild("Root")
		end

		if basePart == nil or not basePart:IsA("BasePart") then
			clone:Destroy()
			return false
		end

		attachment = basePart:FindFirstChild("Tip")

		if attachment == nil or not attachment:IsA("Attachment") then
			attachment = Instance.new("Attachment")
			attachment.Name = "Tip"
			attachment.Parent = basePart
		end

		clone:PivotTo(attachment1.WorldCFrame * attachment.CFrame:Inverse() * basePart.CFrame:Inverse() * clone:GetPivot())
	end

	prepCatchPieces(clone, basePart)
	basePart.Massless = false
	basePart.CustomPhysicalProperties = PhysicalProperties.new(0.1, 0.3, 0.5)
	count += 1
	clone.Name = `FishingCatch_{count}`
	clone:SetAttribute("CatchItem", pendingCatch)
	fishingLine.Attachment1 = attachment
	fishingLine.Parent = basePart
	local prompt = Utility.CreatePrompt({
		ActionText = "Collect",
		ObjectText = pendingCatch,
		HoldDuration = 2,
		Parent = basePart
	})
	local v5 = false
	local promptHeld = PromptHeld(prompt)
	prompt.Triggered:Connect(function(player)
		if v5 or clone.Parent == nil or not promptHeld(player) then
			return
		end

		v5 = true
		local position = basePart.Position
		EffectsEvent.ToAllInRange(position, "QuestPickup", position)
		Item(player, pendingCatch, 1, nil, nil, nil, "Fishing")

		if state.CatchModel == clone then
			state.CatchModel = nil
			state.CatchRoot = nil
		end

		clone:Destroy()
	end)
	clone.Parent = workspace.Debree
	state.CatchModel = clone
	state.CatchRoot = basePart
	local bobberModel = state.BobberModel or bobber
	state.BobberModel = nil
	state.Bobber = nil
	bobberModel:Destroy()
	return true
end

local function hangPointOf(rodTip)
	local parent = rodTip.Parent

	if parent == nil then
		return nil
	end

	local v4 = parent:FindFirstChild("FishingHangPoint")

	if v4 ~= nil and v4:IsA("Attachment") then
		return v4
	end

	v4 = Instance.new("Attachment")
	v4.Name = "FishingHangPoint"
	v4.Parent = parent
	v4.WorldPosition = rodTip.WorldPosition - createVector(0, 0.3, 0)
	return v4
end

local function catchDistance(p)
	local catchRoot = p.CatchRoot
	local hangPoint = p.HangPoint
	local tip

	if not (catchRoot == nil or catchRoot.Parent == nil) then
		tip = catchRoot:FindFirstChild("Tip") or nil
	end

	if tip == nil or hangPoint == nil or hangPoint.Parent == nil then
		return nil
	end

	return (tip.WorldPosition - hangPoint.WorldPosition).Magnitude
end

local function pullCatch(state)
	local catchRoot = state.CatchRoot
	local rodTip = state.RodTip
	local tip

	if catchRoot ~= nil then
		tip = catchRoot:FindFirstChild("Tip") or nil
	end

	local v4

	if rodTip ~= nil then
		v4 = hangPointOf(rodTip) or nil
	end

	if catchRoot == nil or tip == nil or v4 == nil then
		return
	end

	state.HangPoint = v4
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Name = "CatchPull"
	alignPosition.Mode = Enum.PositionAlignmentMode.TwoAttachment
	alignPosition.Attachment0 = tip
	alignPosition.Attachment1 = v4
	alignPosition.MaxVelocity = 150
	alignPosition.MaxForce = 10000
	alignPosition.Responsiveness = 35
	alignPosition.Parent = catchRoot
	local fishingLine = catchRoot:FindFirstChild("FishingLine")

	if fishingLine ~= nil and fishingLine:IsA("RopeConstraint") then
		local part = Instance.new("Part")
		part.Name = "CatchLineAnchor"
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Transparency = 1
		part.Size = createVector(0.1, 0.1, 0.1)
		part.CFrame = CFrame.new(rodTip.WorldPosition)
		local attachment = Instance.new("Attachment")
		attachment.Parent = part
		part.Parent = workspace.Debree
		fishingLine.Attachment0 = attachment
		task.spawn(function()
			while state.CatchRoot == catchRoot and fishingLine.Parent == catchRoot do
				part.CFrame = CFrame.new(rodTip.WorldPosition)
				local v5 = state
				local catchRoot2 = v5.CatchRoot
				local hangPoint = v5.HangPoint
				local tip2

				if not (catchRoot2 == nil or catchRoot2.Parent == nil) then
					tip2 = catchRoot2:FindFirstChild("Tip") or nil
				end

				local magnitude

				if not (tip2 == nil or hangPoint == nil or hangPoint.Parent == nil) then
					magnitude = (tip2.WorldPosition - hangPoint.WorldPosition).Magnitude
				end

				if magnitude == nil then
					break
				end

				fishingLine.Length = math.max(magnitude * 1.2 + 0.5, 0.3)
				task.wait()
			end

			part:Destroy()
		end)
	end
end

local function finishCatchPull(state, instance, attachment)
	local v4 = os.clock() + 4

	while state.CatchModel == instance and os.clock() < v4 do
		local catchRoot = state.CatchRoot
		local hangPoint = state.HangPoint
		local tip

		if not (catchRoot == nil or catchRoot.Parent == nil) then
			tip = catchRoot:FindFirstChild("Tip") or nil
		end

		local magnitude

		if not (tip == nil or hangPoint == nil or hangPoint.Parent == nil) then
			magnitude = (tip.WorldPosition - hangPoint.WorldPosition).Magnitude
		end

		if magnitude == nil or magnitude <= 0.5 then
			break
		else
			task.wait(0.05)
		end
	end

	local catchRoot = state.CatchRoot
	local hangPoint = state.HangPoint

	if state.CatchModel ~= instance or instance.Parent == nil or catchRoot == nil or catchRoot.Parent == nil or hangPoint == nil then
		return
	end

	local catchRoot2 = state.CatchRoot
	local hangPoint2 = state.HangPoint
	local tip

	if not (catchRoot2 == nil or catchRoot2.Parent == nil) then
		tip = catchRoot2:FindFirstChild("Tip") or nil
	end

	local magnitude

	if not (tip == nil or hangPoint2 == nil or hangPoint2.Parent == nil) then
		magnitude = (tip.WorldPosition - hangPoint2.WorldPosition).Magnitude
	end

	local tip2 = catchRoot:FindFirstChild("Tip")

	if magnitude ~= nil and magnitude > 0.5 and tip2 ~= nil then
		instance:PivotTo(CFrame.new(hangPoint.WorldPosition) * tip2.CFrame:Inverse() * catchRoot.CFrame:Inverse() * instance:GetPivot())
		catchRoot.AssemblyLinearVelocity = createVector(0, 0, 0)
		catchRoot.AssemblyAngularVelocity = createVector(0, 0, 0)
	end

	local fishingLine = catchRoot:FindFirstChild("FishingLine")

	if fishingLine ~= nil then
		fishingLine:Destroy()
	end

	local ropeConstraint = Instance.new("RopeConstraint")
	ropeConstraint.Name = "FishingLine"
	ropeConstraint.Attachment0 = attachment
	ropeConstraint.Attachment1 = hangPoint
	ropeConstraint.Length = 0.3
	ropeConstraint.Visible = true
	ropeConstraint.Thickness = 0.05
	ropeConstraint.Color = BrickColor.new("Institutional white")
	ropeConstraint.Parent = catchRoot
	state.CatchClickAt = os.clock() + 0.6
end

local function cast2(p, instance, state, p2: string, vector2: Vector3?)
	state.Casting = true
	dropCatch(state)
	destroyBobber(state)
	local bait, baitTier = resolveBait(p, p2)
	state.BaitName = bait
	state.BaitTier = baitTier
	state.CastPosition = resolveCastPosition(
		instance,
		vector2,
		FishingHandler.GetCombinedStats(p2, state.BaitName).CastRadius
	)

	if state.CastPosition ~= nil then
		local water, castPosition2 = findWater(state.CastPosition, instance)
		state.WaterPart = water

		if water ~= nil and castPosition2 ~= nil then
			state.CastPosition = castPosition2
		end
	end

	setFreeze(state, instance, v2)
	pinCharacter(instance, state)
	local v5 = RareFishingRodServer.Id[p.UserId]
	local animator = getAnimator(instance) -- equivalent call inferred; original call site unknown

	if animator ~= nil and cast ~= nil then
		local track = animator:LoadAnimation(cast)
		track:Play()
		state.CastTrack = track
	end

	local tool_Accessories = instance and instance:FindFirstChild("Tool_Accessories")
	local tip

	if tool_Accessories ~= nil then
		tip = tool_Accessories:FindFirstChild("Tip", true) or nil
	end

	if tip == nil or not tip:IsA("Attachment") then
		tip = nil
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local worldPosition = tip ~= nil and tip.WorldPosition or humanoidRootPart ~= nil and humanoidRootPart.Position or nil
	local castPosition = state.CastPosition
	local v6 = (worldPosition == nil or castPosition == nil or not ((castPosition - worldPosition).Magnitude < 20)) and "PS2fishingCASTlong" or "PS2fishingCASTfast"
	task.delay(0, function()
		if RareFishingRodServer.Id[p.UserId] ~= v5 then
			return
		end

		playRodSound(instance, v6)
	end)
	task.wait(0.3)

	if RareFishingRodServer.Id[p.UserId] ~= v5 then
		return
	end

	state.Casted = true
	launchBobber(p, instance, state)
	task.wait(0.7)

	if RareFishingRodServer.Id[p.UserId] ~= v5 then
		return
	end

	if state.ReelPin ~= nil then
		state.ReelPin:Destroy()
		state.ReelPin = nil
	end

	setFreeze(state, instance, v3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelCast(_, p, state)
	if state.CastTrack then
		state.CastTrack:Stop()
		state.CastTrack = nil
	end

	if state.ReelPin ~= nil then
		state.ReelPin:Destroy()
		state.ReelPin = nil
	end

	if Utility.getvaluesfolder(p) ~= nil then
		local freeze = state.Freeze
		state.Freeze = nil

		if freeze ~= nil then
			for _, v4 in freeze do
				v4:Destroy()
			end
		end
	end

	state.Casting = nil
	state.CastPosition = nil
	state.WaterPart = nil
end

local function uncast(p, instance, state, p2: string)
	if state.Uncasting then
		while state.Uncasting do
			task.wait()
		end
	else
		if not state.Casted then
			return
		end

		state.Uncasting = true
		setFreeze(state, instance, v2)
		stopStruggle(state) -- equivalent call inferred; original call site unknown

		if state.CastTrack then
			state.CastTrack:Stop()
			state.CastTrack = nil
		end

		local animator = getAnimator(instance) -- equivalent call inferred; original call site unknown

		if animator ~= nil and unCast ~= nil then
			animator:LoadAnimation(unCast):Play()
		end

		playRodSound(instance, "PS2fishingRECALL")

		if state.WaterPart ~= nil and state.BobberName ~= nil and state.Bobber ~= nil then
			EffectsEvent.ToAllInRange(state.Bobber, "FishingCatchFX", "Splash", state.BobberName, false)
		end

		if state.BiteToken ~= nil then
			state.BiteToken = nil
			state.BiteVerdict = nil

			if state.Portal ~= nil then
				state.Portal:ToClient("BiteCancel")
			end
		end

		local bobber = state.Bobber
		local pendingCatch = state.PendingCatch
		state.PendingCatch = nil

		if pendingCatch ~= nil and bobber ~= nil then
			if state.ReelPin ~= nil then
				state.ReelPin:Destroy()
				state.ReelPin = nil
			end

			if attachCatchModel(bobber, state, pendingCatch) then
				local catchRoot = state.CatchRoot

				if catchRoot ~= nil then
					catchRoot:SetNetworkOwner(nil)
					catchRoot.AssemblyLinearVelocity = createVector(0, 0, 0)
					catchRoot.AssemblyAngularVelocity = createVector(0, 0, 0)
					local v4 = Items[pendingCatch] == nil and 1 or Items[pendingCatch].Rarity or 1
					EffectsEvent.ToAllInRange(catchRoot, "FishingCatchFX", "Ring", state.CatchModel.Name, v4)
				end
			else
				Item(p, pendingCatch, 1, nil, nil, nil, "Fishing")
			end
		end

		if state.CatchModel == nil then
			pinCharacter(instance, state)
		end

		local bobber2 = state.Bobber or state.CatchRoot

		if bobber2 ~= nil then
			task.delay(0.3, function()
				if bobber2.Parent == nil then
					return
				end

				local setNetworkOwner = bobber2.SetNetworkOwner
				local v5

				if state.CatchModel == nil then
					v5 = p
				end

				pcall(setNetworkOwner, bobber2, v5)
				local floatAlign = bobber2:FindFirstChild("FloatAlign")

				if floatAlign ~= nil then
					floatAlign:Destroy()
				end

				local fishingLine = bobber2:FindFirstChild("FishingLine")

				if fishingLine ~= nil then
					if state.CatchModel == nil then
						TweenService:Create(fishingLine, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {
							Length = 0
						}):Play()
					else
						pullCatch(state)
					end
				end
			end)
		end

		local v4 = RareFishingRodServer.Id[p.UserId]
		task.wait(1.4)

		if RareFishingRodServer.Id[p.UserId] ~= v4 then
			return
		end

		if state.CatchModel == nil or state.CatchModel.Parent == nil then
			destroyBobber(state)
		else
			if state.ReelPin ~= nil then
				state.ReelPin:Destroy()
				state.ReelPin = nil
			end

			if state.RodTip ~= nil then
				task.spawn(finishCatchPull, state, state.CatchModel, state.RodTip)
			end
		end

		if Utility.getvaluesfolder(instance) ~= nil then
			local freeze = state.Freeze
			state.Freeze = nil

			if freeze ~= nil then
				for _, v5 in freeze do
					v5:Destroy()
				end
			end
		end

		state.Casted = nil
		state.Casting = nil
		state.Uncasting = nil
		state.CastPosition = nil
		state.WaterPart = nil
		state.RodTip = nil

		if state.CatchModel == nil then
			showIdleBait(p, instance, state, p2)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startBiteLoop(p, instance, state, p2: string)
	local v4 = RareFishingRodServer.Id[p.UserId]
	task.spawn(function()
		local combinedStats = FishingHandler.GetCombinedStats(p2, state.BaitName)
		local v5 = PlayerStatResolver.GetStat(p, "Bite Speed Factor") or 0
		local v6 = math.max(combinedStats.BiteSpeedMultiplier * (1 + v5), 0.05)
		task.wait(random:NextNumber(4, 9) / v6)

		if RareFishingRodServer.Id[p.UserId] ~= v4 or not state.Casted or state.Uncasting or state.Portal == nil then
			return
		end

		local biteToken = generate_id() -- equivalent call inferred; original call site unknown
		state.BiteToken = biteToken
		state.BiteVerdict = nil
		state.BiteAt = os.clock()
		state.Portal:ToClient("Bite", biteToken)
		setFreeze(state, instance, v2)
		pinCharacter(instance, state)
		local animator = getAnimator(instance) -- equivalent call inferred; original call site unknown

		if animator ~= nil and struggle ~= nil then
			local track = animator:LoadAnimation(struggle)
			track:Play()
			state.StruggleTrack = track
		end

		state.StruggleSound = playRodSound(instance, "PS2fishingSTRUGGLEloop")

		while RareFishingRodServer.Id[p.UserId] == v4 and state.Casted and not state.Uncasting and state.Portal ~= nil do
			local biteVerdict = state.BiteVerdict

			if biteVerdict == nil then
				task.wait(0.1)
			else
				state.BiteToken = nil
				state.BiteVerdict = nil
				stopStruggle(state) -- equivalent call inferred; original call site unknown

				if RareFishingRodServer.Id[p.UserId] ~= v4 or not state.Casted or state.Uncasting then
					break
				end

				if state.BaitName ~= nil then
					Item2(p, state.BaitName, 1)
				end

				local v10

				if biteVerdict == true then
					v10 = random:NextNumber() < combinedStats.CatchChance
				else
					v10 = false
				end

				if v10 then
					local v11 = PlayerStatResolver.GetStat(p, "Fishing Luck Factor") or 0
					local heldMultiplier = Refinement.GetHeldMultiplier(p, p2)
					state.PendingCatch = FishingHandler.Roll(
						p2,
						state.BaitTier or 0,
						v11,
						state.BaitName,
						heldMultiplier
					)
				elseif state.Portal ~= nil then
					state.Portal:ToClient("BiteMissed")
				end

				local outcome

				if state.PendingCatch ~= nil then
					outcome = "Caught"
				elseif v10 then
					outcome = "Empty"
				elseif biteVerdict == true then
					outcome = "Slipped"
				else
					outcome = "Lost"
				end

				Analytics.Track(p, "FishingBite", {
					Bait = state.BaitName or "None",
					Outcome = outcome
				})
				local v12

				if state.PendingCatch ~= nil then
					v12 = FishingHandler.CategoryOf(state.PendingCatch)
				end

				local v13

				if v12 ~= nil then
					v13 = v[v12]
				end

				if v13 ~= nil then
					TitleService.AddProgress(p, v13)
				end

				if drownedLine ~= nil then
					drownedLine.ReportBite(p, outcome, state.BaitName)
				end

				RareFishingRodServer.Id[p.UserId] = random:NextNumber()
				uncast(p, instance, state, p2)
				break
			end
		end
	end)
end

local function forceCleanup(p, instance, state)
	RareFishingRodServer.Id[p.UserId] = random:NextNumber()

	if state.BiteToken ~= nil and state.Portal ~= nil then
		state.Portal:ToClient("BiteCancel")
	end

	state.BiteToken = nil
	state.BiteVerdict = nil
	state.PendingCatch = nil
	stopStruggle(state) -- equivalent call inferred; original call site unknown

	if state.CastTrack then
		state.CastTrack:Stop()
		state.CastTrack = nil
	end

	dropCatch(state)
	destroyIdleBait(state) -- equivalent call inferred; original call site unknown
	destroyBobber(state)

	if Utility.getvaluesfolder(instance) ~= nil then
		local freeze = state.Freeze
		state.Freeze = nil

		if freeze ~= nil then
			for _, v4 in freeze do
				v4:Destroy()
			end
		end
	end

	state.Casted = nil
	state.Casting = nil
	state.Uncasting = nil
	state.CastPosition = nil
	state.WaterPart = nil
	state.RodTip = nil
end

function RareFishingRodServer.check(p, _, p2, _: string)
	if p2.Uncasting then
		return false
	end

	if Checker.check(p) then
		return true
	end

	return false
end

function RareFishingRodServer.Equipped(p, instance, state, p2: string)
	if state.Portal ~= nil then
		state.Portal:Destroy()
		state.Portal = nil
	end

	local portal = ServerClientPortal.Create(p, "FishingRod", -1)
	state.Portal = portal
	portal:Connect(function(p3, p4)
		if p3 == nil or state.BiteToken ~= p3 then
			return
		end

		local v5 = os.clock() - state.BiteAt
		local fastestWin = FishingBar.FastestWin(FishingBar.Fill)

		if p4 == true and v5 < fastestWin * 0.5 and state.BiteVerdict == nil then
			AntiCheat.Report(p, "FishingWin", {
				detail = string.format("won %.1f s after the bite (the bar takes %.1f s)", v5, fastestWin)
			})
		end

		state.BiteVerdict = p4 == true and fastestWin * 0.9 <= v5
	end)

	if state.CancelDestroy then
		state.CancelDestroy()
		state.CancelDestroy = nil
	end

	local v5, cancelDestroy = ManuelCancel.new(p, -1)
	state.CancelDestroy = cancelDestroy

	if state.SwimWatch ~= nil then
		state.SwimWatch:Disconnect()
		state.SwimWatch = nil
	end

	state.SwimWatch = instance:GetAttributeChangedSignal("SwimState"):Connect(function()
		local v7 = instance
		local v8

		if v7 == nil then
			v8 = false
		else
			v8 = (v7:GetAttribute("SwimState") or 0) > 0
		end

		if not v8 or not (state.Casted or state.Casting) or state.Uncasting then
			return
		end

		RareFishingRodServer.Id[p.UserId] = random:NextNumber()

		if not state.Casting or state.Casted then
			uncast(p, instance, state, p2)
			return
		end

		cancelCast(nil, instance, state) -- equivalent call inferred; original call site unknown
	end)

	if state.MoveWatch ~= nil then
		state.MoveWatch:Disconnect()
		state.MoveWatch = nil
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart ~= nil then
		state.MoveWatch = humanoidRootPart:GetPropertyChangedSignal("CFrame"):Connect(function()
			if state.ReelPin ~= nil then
				return
			end

			forceCleanup(p, instance, state)
			showIdleBait(p, instance, state, p2)
		end)
	end

	if v5 then
		v5:Connect(function()
			if state.CancelDestroy then
				state.CancelDestroy()
				state.CancelDestroy = nil
			end

			forceCleanup(p, instance, state)
			local humanoid = instance and instance:FindFirstChildOfClass("Humanoid")

			if humanoid ~= nil and humanoid.Health <= 0 then
				return
			end

			SignalEvent.ToClient(p, "ForceEquip", 0)
		end)
	end

	local baitWatch = {}
	state.BaitWatch = baitWatch

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refresh()
		if state.BaitWatch ~= baitWatch then
			return
		end

		showIdleBait(p, instance, state, p2)
	end

	local data = Utility.GetData(p)
	local misc

	if data ~= nil then
		misc = data:FindFirstChild("Misc") or nil
	end

	local changedConnection = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function hookPref(valueBase)
		if changedConnection ~= nil then
			changedConnection:Disconnect()
			changedConnection = nil
		end

		if valueBase ~= nil and valueBase:IsA("ValueBase") then
			changedConnection = valueBase.Changed:Connect(refresh)
			table.insert(baitWatch, changedConnection)
		end
	end

	if misc ~= nil then
		hookPref(misc:FindFirstChild("EquippedBaitId")) -- equivalent call inferred; original call site unknown
		table.insert(baitWatch, misc.ChildAdded:Connect(function(child)
			if child.Name == "EquippedBaitId" then
				hookPref(child) -- equivalent call inferred; original call site unknown
				task.defer(refresh)
			end
		end))
		table.insert(baitWatch, misc.ChildRemoved:Connect(function(child)
			if child.Name == "EquippedBaitId" then
				if changedConnection ~= nil then
					changedConnection:Disconnect()
					changedConnection = nil
				end

				refresh() -- equivalent call inferred; original call site unknown
			end
		end))
	end

	local inventory

	if data ~= nil then
		inventory = data:FindFirstChild("Inventory") or nil
	end

	local inventory2

	if inventory ~= nil then
		inventory2 = inventory:FindFirstChild("Inventory") or nil
	end

	if inventory2 ~= nil then
		local function onEntry()
			task.defer(refresh)
		end

		table.insert(baitWatch, inventory2.ChildAdded:Connect(onEntry))
		table.insert(baitWatch, inventory2.ChildRemoved:Connect(onEntry))
	end

	task.defer(function()
		if state.BaitWatch ~= baitWatch then
			return
		end

		showIdleBait(p, instance, state, p2)
	end)
end

function RareFishingRodServer.UnEquipped(p, p2, state, p3: string)
	if not state.Uncasting then
		RareFishingRodServer.Id[p.UserId] = random:NextNumber()
	end

	if state.Casted or state.Uncasting then
		uncast(p, p2, state, p3)
	elseif state.Casting then
		cancelCast(nil, p2, state) -- equivalent call inferred; original call site unknown
	end

	dropCatch(state)
	destroyIdleBait(state) -- equivalent call inferred; original call site unknown
	destroyBobber(state)

	if state.BaitWatch ~= nil then
		for _, connection in state.BaitWatch do
			connection:Disconnect()
		end

		state.BaitWatch = nil
	end

	if state.SwimWatch ~= nil then
		state.SwimWatch:Disconnect()
		state.SwimWatch = nil
	end

	if state.MoveWatch ~= nil then
		state.MoveWatch:Disconnect()
		state.MoveWatch = nil
	end

	if state.CancelDestroy then
		state.CancelDestroy()
		state.CancelDestroy = nil
	end

	state.BiteToken = nil
	state.BiteVerdict = nil
	state.PendingCatch = nil

	if state.Portal ~= nil then
		state.Portal:Destroy()
		state.Portal = nil
	end
end

function RareFishingRodServer.MouseUp(p, instance, data, p2: string, vector2: Vector3?)
	if data.Uncasting or data.BiteToken ~= nil then
		return
	end

	if not (data.Casted or data.Casting) then
		local v4

		if instance == nil then
			v4 = false
		else
			v4 = (instance:GetAttribute("SwimState") or 0) > 0
		end

		if v4 then
			return
		end
	end

	if not (data.Casted or data.Casting) then
		local humanoid

		if instance ~= nil then
			humanoid = instance:FindFirstChildOfClass("Humanoid") or nil
		end

		local v4

		if humanoid == nil then
			v4 = false
		else
			v4 = humanoid.FloorMaterial ~= Enum.Material.Air
		end

		if not v4 then
			return
		end
	end

	RareFishingRodServer.Id[p.UserId] = random:NextNumber()

	if data.Casted then
		uncast(p, instance, data, p2)
	elseif data.Casting then
		cancelCast(nil, instance, data) -- equivalent call inferred; original call site unknown
	elseif data.CatchModel == nil then
		cast2(p, instance, data, p2, vector2)

		if data.Casted and (data.WaterPart == nil or data.RodTip == nil) then
			uncast(p, instance, data, p2)
		elseif data.Casted then
			startBiteLoop(p, instance, data, p2) -- equivalent call inferred; original call site unknown
		end
	else
		if os.clock() < (data.CatchClickAt or 1e999) then
			return
		end

		dropCatch(data)
		destroyBobber(data)
		showIdleBait(p, instance, data, p2)
	end
end

return RareFishingRodServer