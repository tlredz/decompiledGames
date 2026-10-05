local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Anims = require(ReplicatedStorage.Util.Anims)
local Deck = require(script.Parent.Deck)
local Scene = require(script.Parent.Parent.Scene)
local Timing = require(script.Parent.Timing)
require(script.Parent.Types)
local frozen = table.freeze({
	CrateScaleFactor = 0.8625,
	FruitScaleFactor = 0.675,
	FruitInCrateScale = 0.65,
	FruitCrateBackOffset = 8.5,
	FruitCrateLeftOffset = 5,
	FruitPileCount = 8,
	FruitTemplateFolder = "Fruits",
	GrabFruitTemplateName = "Dragon (East)-Dragon (East)",
	FloppySettleWobble = 0.18
})
local frozen2 = table.freeze({
	TemplateFolderName = frozen.FruitTemplateFolder,
	GrabTemplateName = frozen.GrabFruitTemplateName,
	ItemNamePrefix = "LookoutFinaleFruit",
	PileCount = frozen.FruitPileCount,
	RandomizeTemplates = false
})
local v = {}
local v2 = {}

function v.getLargestDimension(instance)
	if instance:IsA("BasePart") then
		return (math.max(instance.Size.X, instance.Size.Y, instance.Size.Z))
	end

	if not instance:IsA("Model") then
		return nil
	end

	local extentsSize = instance:GetExtentsSize()
	return (math.max(extentsSize.X, extentsSize.Y, extentsSize.Z))
end

function v2.findCargoDonor()
	local map = workspace:FindFirstChild("Map")

	if not map then
		return nil
	end

	for _, descendant in map:GetDescendants() do
		local name = string.lower(descendant.Name)

		if not (descendant:IsA("Model") or descendant:IsA("BasePart")) then
			continue
		end

		if not (string.find(name, "crate", 1, true) or string.find(name, "box", 1, true)) then
			continue
		end

		local largestDimension = v.getLargestDimension(descendant)

		if largestDimension and largestDimension > 0.1 and largestDimension <= 12 then
			return descendant
		end
	end

	return nil
end

function v.createFallbackCrate()
	local model = Instance.new("Model")
	model.Name = "LookoutFinaleCrate"
	local part = Instance.new("Part")
	part.Name = "CrateBody"
	part.Size = createVector(3.5, 3.5, 3.5)
	part.Color = Color3.fromRGB(124, 79, 42)
	part.Material = Enum.Material.WoodPlanks
	part.Anchored = true
	part.Parent = model

	for i = -1, 1, 2 do
		local part2 = Instance.new("Part")
		part2.Name = "CrateSlat"
		part2.Size = createVector(0.32, 3.7, 3.7)
		part2.Color = Color3.fromRGB(83, 51, 28)
		part2.Material = Enum.Material.WoodPlanks
		part2.Anchored = true
		part2.CFrame = part.CFrame * CFrame.new(i * 1.25, 0, 0)
		part2.Parent = model
	end

	model.PrimaryPart = part
	return model
end

function v.cloneOptimizedCrate()
	local optimizedCrate = workspace:FindFirstChild("OptimizedCrate", true)
	local parent = nil

	if optimizedCrate and (optimizedCrate:IsA("Model") or optimizedCrate:IsA("BasePart")) then
		local archivable = optimizedCrate.Archivable
		local success, result = pcall(function()
			optimizedCrate.Archivable = true
			return optimizedCrate:Clone()
		end)
		optimizedCrate.Archivable = archivable

		if success and result then
			if result:IsA("Model") then
				parent = result
			elseif result:IsA("BasePart") then
				parent = Instance.new("Model")
				result.Parent = parent
				parent.PrimaryPart = result
			end
		end
	end

	if not (parent and parent:FindFirstChildWhichIsA("BasePart", true)) then
		parent = v.createFallbackCrate()
		warn("[Lookout] workspace.OptimizedCrate was unavailable; using the fallback crate")
	end

	parent.Name = "LookoutFinaleFruitCrate"

	for k in parent:GetAttributes() do
		parent:SetAttribute(k, nil)
	end

	local primaryPart = nil

	for _, descendant in parent:GetDescendants() do
		for k in descendant:GetAttributes() do
			descendant:SetAttribute(k, nil)
		end

		if descendant:IsA("BaseScript") or descendant:IsA("ModuleScript") or descendant:IsA("Tool") then
			descendant:Destroy()
		elseif descendant:IsA("Seat") or descendant:IsA("VehicleSeat") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.CastShadow = false

			if not primaryPart or descendant.Size.Magnitude > primaryPart.Size.Magnitude then
				primaryPart = descendant
			end
		end
	end

	if not parent.PrimaryPart then
		parent.PrimaryPart = primaryPart
	end

	pcall(function()
		parent:ScaleTo(parent:GetScale() * frozen.CrateScaleFactor)
	end)
	return parent
end

function v2:cloneCargo()
	local folder

	if self then
		local archivable = self.Archivable
		local success, result = pcall(function()
			self.Archivable = true
			return self:Clone()
		end)
		self.Archivable = archivable
		folder = success and result or v.createFallbackCrate()
	else
		folder = v.createFallbackCrate()
	end

	local largestDimension = v.getLargestDimension(folder)

	if largestDimension and largestDimension > 0 then
		local v3 = math.clamp(3.5 / largestDimension, 0.2, 4)

		if folder:IsA("Model") then
			pcall(function()
				folder:ScaleTo(folder:GetScale() * v3)
			end)
		elseif folder:IsA("BasePart") then
			folder.Size *= v3
		end
	end

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.CastShadow = false
		end
	end

	if not folder:IsA("BasePart") then
		return folder
	end

	folder.Anchored = true
	folder.CanCollide = false
	folder.CanTouch = false
	folder.CanQuery = false
	folder.CastShadow = false
	return folder
end

function v2:pivotCargo(cFrame: CFrame)
	if self:IsA("Model") then
		self:PivotTo(cFrame)
		local boundingBox = self:GetBoundingBox()
		self:PivotTo(self:GetPivot() + (cFrame.Position - boundingBox.Position))
	elseif self:IsA("BasePart") then
		self.CFrame = cFrame
	end
end

function v.cloneFruit(instance)
	local clone = instance:Clone()

	for k in clone:GetAttributes() do
		clone:SetAttribute(k, nil)
	end

	for _, descendant in clone:GetDescendants() do
		for k in descendant:GetAttributes() do
			descendant:SetAttribute(k, nil)
		end

		if descendant:IsA("BaseScript") or descendant:IsA("ModuleScript") or descendant:IsA("Tool") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.CastShadow = false
			descendant.AssemblyLinearVelocity = createVector(0, 0, 0)
			descendant.AssemblyAngularVelocity = createVector(0, 0, 0)
		end
	end

	if not clone:FindFirstChildWhichIsA("BasePart", true) then
		clone:Destroy()
		return nil, nil
	end

	local largestDimension = v.getLargestDimension(clone)

	if largestDimension and largestDimension > 0 then
		local v3 = math.clamp(2.6 / largestDimension, 0.35, 1.5)
		pcall(function()
			clone:ScaleTo(clone:GetScale() * v3 * frozen.FruitScaleFactor)
		end)
	end

	local boundingBox, v3 = clone:GetBoundingBox()
	local v4 = math.clamp(math.max(v3.X, v3.Y, v3.Z) * 0.5, 1.2, 2.3)
	local part = Instance.new("Part")
	part.Name = "PhysicsRoot"
	part.Shape = Enum.PartType.Ball
	part.Size = createVector(1, 1, 1) * v4
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.CFrame = boundingBox
	part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.2, 0, 50, 100)
	part.Parent = clone
	clone.PrimaryPart = part
	local rootPart = clone:FindFirstChild("RootPart", true)

	if not (rootPart and rootPart:IsA("BasePart")) then
		rootPart = nil
	end

	local v5 = {}

	for _, jointInstance in clone:GetDescendants() do
		if not (jointInstance:IsA("JointInstance") and jointInstance.Part0 and jointInstance.Part1) then
			continue
		end

		v5[jointInstance.Part0] = true
		v5[jointInstance.Part1] = true
	end

	for _, part2 in clone:GetDescendants() do
		if not (part2:IsA("BasePart") and part2 ~= part) then
			continue
		end

		part2.Anchored = true
		part2.CanCollide = false
		part2.CanTouch = false
		part2.CanQuery = false
		part2.CastShadow = false
		part2.Massless = true

		if not (part2 == rootPart or rootPart == nil or not v5[part2]) then
			continue
		end

		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Name = "LookoutFruitWeld"
		weldConstraint.Part0 = part
		weldConstraint.Part1 = part2
		weldConstraint.Parent = part2
	end

	return clone, part
end

function v.playFruitIdle(parent)
	local idle = parent:FindFirstChild("Idle", true)

	if not (idle and idle:IsA("Animation")) then
		idle = parent:FindFirstChildWhichIsA("Animation", true)
	end

	if not idle then
		local animationId = parent:FindFirstChild("AnimationId", true)
		local raw

		if animationId and animationId:IsA("StringValue") then
			raw = Anims:GetRaw(animationId.Value)
		end

		if raw and raw:IsA("Animation") then
			idle = raw
		end
	end

	if not idle then
		return
	end

	local parent2 = parent:FindFirstChildWhichIsA("AnimationController", true)

	if not parent2 then
		parent2 = Instance.new("AnimationController")
		parent2.Name = "AnimationController"
		parent2.Parent = parent
	end

	local v4 = parent2:FindFirstChildWhichIsA("Animator")

	if not v4 then
		v4 = Instance.new("Animator")
		v4.Parent = parent2
	end

	pcall(function()
		local track = v4:LoadAnimation(idle)
		track.Looped = true
		track.Priority = Enum.AnimationPriority.Idle
		track:Play(0.1)
	end)
end

function v2.isFruitTouchingBoat(p)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { p.Boat }
	raycastParams.IgnoreWater = true
	raycastParams.RespectCanCollide = true
	local v3 = p.Root.Size.Y * 0.5 + 0.75
	return workspace:Raycast(p.Root.Position, createVector(-0, -1, -0) * v3, raycastParams) ~= nil
end

function v2.createFruitCrate(parent, instance, ship, vector2: Vector3, vector3: Vector3, vector4: Vector3, object, list, p2)
	local v3 = p2 or frozen2
	local optimizedCrate = v.cloneOptimizedCrate()
	optimizedCrate.Parent = parent
	local position = ship.Boat:GetPivot().Position
	local v4 = position + vector3 * ((vector2 - position):Dot(vector3) - frozen.FruitCrateBackOffset) - vector4 * frozen.FruitCrateLeftOffset
	local surfacePosition = Deck.getSurfacePosition(ship, v4)
	local _, v5 = optimizedCrate:GetBoundingBox()
	local v6 = math.max(v5.X, v5.Z) * 0.65
	local v7 = { -vector4 * v6 - vector3 * v6 * 0.18, vector4 * v6 - vector3 * v6 * 0.18, vector3 * v6 * 0.85 }
	local Y = surfacePosition.Y

	for k, v8 in v7 do
		local optimizedCrate2 = v.cloneOptimizedCrate()
		optimizedCrate2.Name = `LookoutFinaleDecorativeCrate_{k}`
		optimizedCrate2.Parent = parent
		local _, v9 = optimizedCrate2:GetBoundingBox()
		local v10 = Deck.getSurfacePosition(ship, v4 + v8) + createVector(0, 1, 0) * (v9.Y * 0.5 + 0.05)
		local v11 = CFrame.lookAt(v10, v10 + vector3) * CFrame.Angles(0, math.rad((object:NextNumber(-25, 25))), 0)
		v2.pivotCargo(optimizedCrate2, v11)
		local boundingBox, v12 = optimizedCrate2:GetBoundingBox()
		Y = math.max(Y, boundingBox.Y + v12.Y * 0.5)
	end

	local vector5 = Vector3.new(surfacePosition.X, Y + v5.Y * 0.5 - 0.08, surfacePosition.Z)
	local cframe = CFrame.lookAt(vector5, vector5 + vector3)
	v2.pivotCargo(optimizedCrate, cframe)
	local pivot = optimizedCrate:GetPivot()
	local boundingBox, size = optimizedCrate:GetBoundingBox()
	local fruitJumps = {}
	local result = {
		Crate = optimizedCrate,
		Ship = ship,
		FruitJumps = fruitJumps,
		GroundCFrame = pivot,
		CenterOffset = pivot:ToObjectSpace(boundingBox),
		Size = size,
		Forward = vector3,
		Right = vector4,
		Follower = nil,
		PickupFeet = nil,
		GrabFruit = nil
	}
	local folder = instance and instance:FindFirstChild(v3.TemplateFolderName)

	if not (folder and folder:IsA("Folder")) then
		return result, 0
	end

	local models = {}

	for _, model in folder:GetChildren() do
		if model:IsA("Model") then
			table.insert(models, model)
		end
	end

	table.sort(models, function(a, b)
		return a.Name < b.Name
	end)

	if #models == 0 then
		return result, 0
	end

	local model = folder:FindFirstChild(v3.GrabTemplateName)

	if not (model and model:IsA("Model")) then
		return result, 0
	end

	local v10 = {}

	for _, v11 in models do
		if v11 ~= model then
			table.insert(v10, v11)
		end
	end

	if #v10 == 0 then
		table.insert(v10, model)
	end

	local v11 = math.min(size.X * 0.18, 0.7)
	local v12 = math.min(size.Z * 0.18, 0.7)
	local v13 = math.min(size.Y * 0.14, 0.5)
	local pileCount = v3.PileCount or frozen.FruitPileCount
	local vectors = {}

	for i = 1, pileCount do
		local v14 = i - 1
		local v15 = v14 % 4
		local v16 = math.floor(v14 / 4)
		local v17 = v15 % 2 == 0 and -1 or 1
		local v18 = v15 < 2 and -1 or 1
		local v19 = v17 * v11
		local v20

		if v16 == 0 then
			v20 = -v13
		else
			v20 = v13
		end

		table.insert(vectors, (Vector3.new(v19, v20, v18 * v12)))
	end

	local count = 0

	for i = 1, math.min(pileCount, #vectors) do
		local v14

		if i == 1 then
			v14 = model
		elseif v3.RandomizeTemplates then
			v14 = v10[object:NextInteger(1, #v10)]
		else
			v14 = v10[(i - 2) % #v10 + 1]
		end

		local fruit, root = v.cloneFruit(v14)

		if not (fruit and root) then
			continue
		end

		local scale = fruit:GetScale()
		local v16 = fruit
		pcall(function()
			v16:ScaleTo(scale * frozen.FruitInCrateScale)
		end)
		fruit.Name = `{v3.ItemNamePrefix}_{v14.Name}`
		fruit.Parent = parent
		fruit:PivotTo(boundingBox * CFrame.new(vectors[i]) * CFrame.Angles(
			0,
			object:NextNumber(-3.141592653589793, 3.141592653589793),
			0
		))

		for _, part in fruit:GetDescendants() do
			if part:IsA("BasePart") and part ~= root then
				part.Anchored = false
			end
		end

		local grabFruit = {
			Root = root,
			Boat = ship.Boat,
			Forward = vector3,
			Right = vector4,
			Random = Random.new(object:NextInteger(1, 2147483647)),
			CrateOffset = pivot:ToObjectSpace(fruit:GetPivot()),
			Released = false,
			HasLanded = false,
			AnimationStarted = false,
			ReservedForGrab = i == 1,
			Grabbed = false,
			TargetScale = scale,
			FloppyLanding = v3.FloppyLanding == true,
			RestingRoll = not v3.FloppyLanding and 0 or object:NextInteger(0, 1) == 0 and -1.5707963267948966 or 1.5707963267948966,
			ReleaseRotation = nil
		}
		table.insert(list, grabFruit)
		table.insert(fruitJumps, grabFruit)

		if grabFruit.ReservedForGrab then
			result.GrabFruit = grabFruit
		end

		count += 1
	end

	return result, count
end

function v2.syncFruitCrate(p, cframe: CFrame)
	p.Crate:PivotTo(cframe)

	for _, fruitJump in p.FruitJumps do
		if fruitJump.Released then
			continue
		end

		local parent = fruitJump.Root.Parent

		if parent and parent:IsA("Model") then
			parent:PivotTo(cframe * fruitJump.CrateOffset)
		end
	end
end

function v.growReleasedFruit(data, instance)
	local scale = instance:GetScale()
	task.spawn(function()
		local total = 0

		while total < Timing.Shared.FruitGrowTime and data.Released and not data.Grabbed and instance:IsDescendantOf(workspace) do
			total += RunService.Heartbeat:Wait()
			local v3 = math.clamp(total / Timing.Shared.FruitGrowTime, 0, 1)
			local v4 = v3 * v3 * (3 - v3 * 2)
			local assemblyLinearVelocity = data.Root.AssemblyLinearVelocity

			if not pcall(function()
				instance:ScaleTo(scale + (data.TargetScale - scale) * v4)
			end) then
				return
			end

			data.Root.AssemblyLinearVelocity = assemblyLinearVelocity

			if not data.FloppyLanding then
				data.Root.AssemblyAngularVelocity = createVector(0, 0, 0)
			end
		end

		if instance:IsDescendantOf(workspace) and not data.Grabbed then
			pcall(function()
				instance:ScaleTo(data.TargetScale)
			end)
		end
	end)
end

function v2.releaseFruitCrate(data)
	local count = #data.FruitJumps

	for k, fruitJump in data.FruitJumps do
		if fruitJump.Released then
			continue
		end

		fruitJump.Released = true
		local releaseRotation

		if fruitJump.FloppyLanding then
			releaseRotation = fruitJump.Root.CFrame.Rotation
		end

		fruitJump.ReleaseRotation = releaseRotation
		local parent = fruitJump.Root.Parent

		if parent then
			for _, part in parent:GetDescendants() do
				if part:IsA("BasePart") then
					part.Anchored = false
				end
			end

			if parent:IsA("Model") and not fruitJump.AnimationStarted then
				fruitJump.AnimationStarted = true
				v.playFruitIdle(parent)
			end
		end

		if fruitJump.ReservedForGrab then
			fruitJump.Root.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.35, 0, 50, 100)
			fruitJump.Root.AssemblyLinearVelocity = createVector(-0, -2, -0)
		else
			local v4 = (not (count > 1) and 0 or (k - 2) / (count - 1)) * 3.141592653589793 * 2 + fruitJump.Random:NextNumber(
				-0.12,
				0.12
			)
			fruitJump.Root.AssemblyLinearVelocity = createVector(-0, -1, -0) * fruitJump.Random:NextNumber(1.5, 2.5) + data.Right * (math.cos(v4) * fruitJump.Random:NextNumber(
				3.5,
				5
			)) + data.Forward * (math.sin(v4) * fruitJump.Random:NextNumber(2.5, 4))
		end

		fruitJump.Root.AssemblyAngularVelocity = not fruitJump.FloppyLanding and createVector(0, 0, 0) or fruitJump.Forward * fruitJump.Random:NextNumber(
			-4.5,
			4.5
		) + fruitJump.Right * fruitJump.Random:NextNumber(-4.5, 4.5)
		fruitJump.Root.CanCollide = true

		if parent and parent:IsA("Model") then
			v.growReleasedFruit(fruitJump, parent)
		end
	end
end

function v.settleFloppyFruit(data, data2)
	local root = data2.Root

	if data2.Grabbed or not root:IsDescendantOf(workspace) then
		return
	end

	root.AssemblyLinearVelocity = createVector(0, 0, 0)
	root.AssemblyAngularVelocity = createVector(0, 0, 0)
	root.Anchored = true
	local cFrame = root.CFrame
	local cFrame2 = CFrame.new(cFrame.Position) * (data2.ReleaseRotation or cFrame.Rotation) * CFrame.Angles(
		0,
		0,
		data2.RestingRoll
	)
	local currentDialogueBeat = data.currentDialogueBeat()
	local total = 0

	while total < Timing.Shared.FloppySettleTime and data.canContinue(currentDialogueBeat) and not data2.Grabbed do
		total += RunService.Heartbeat:Wait()
		local v4 = math.clamp(total / Timing.Shared.FloppySettleTime, 0, 1)
		local v5 = v4 * v4 * (3 - v4 * 2)
		local v6 = math.sin(v4 * 3.141592653589793 * 4) * (1 - v4) * frozen.FloppySettleWobble
		root.CFrame = cFrame:Lerp(cFrame2, v5) * CFrame.Angles(v6, 0, 0)
	end

	if data.isLive() and not data2.Grabbed and root:IsDescendantOf(workspace) then
		root.CFrame = cFrame2
	end
end

function v2.startFruitLanding(p, items)
	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		if not p.isLive() then
			return
		end

		for _, item in items do
			if not item.Released or item.Grabbed or not item.Root:IsDescendantOf(workspace) then
				continue
			end

			if item.FloppyLanding then
				if not item.HasLanded and v2.isFruitTouchingBoat(item) then
					item.HasLanded = true
					task.spawn(v.settleFloppyFruit, p, item)
				end
			elseif not item.ReservedForGrab then
				item.Root.AssemblyAngularVelocity = createVector(0, 0, 0)

				if not item.HasLanded and v2.isFruitTouchingBoat(item) then
					item.HasLanded = true
				end
			end
		end
	end)
	p.giveConnection(heartbeatConnection)
end

function v2.getGroundedCrateCFrame(data, vector2: Vector3)
	local v3 = vector2 + createVector(0, 1, 0) * (data.Size.Y * 0.5 + 0.05)
	return CFrame.lookAt(v3, v3 + data.Forward) * data.CenterOffset:Inverse()
end

function v2.waitForGrabFruit(data, data2, p: number, marine, flag: boolean?)
	local grabFruit = data2.GrabFruit

	if not grabFruit then
		return nil
	end

	local currentDialogueBeat = data.currentDialogueBeat()
	local total = 0

	while total < p and data.canContinue(currentDialogueBeat) and not (grabFruit.Root:IsDescendantOf(workspace) and v2.isFruitTouchingBoat(grabFruit)) do
		total += RunService.Heartbeat:Wait()
	end

	if not (data.isLive() and grabFruit.Root:IsDescendantOf(workspace)) then
		return nil
	end

	if flag == false then
		if not v2.isFruitTouchingBoat(grabFruit) then
			local surfacePosition = Deck.getSurfacePosition(data2.Ship, grabFruit.Root.Position)
			grabFruit.Root.CFrame = CFrame.new(surfacePosition + createVector(0, 1, 0) * (grabFruit.Root.Size.Y * 0.55))
		end
	else
		local follower = data2.Follower

		if not marine then
			if follower then
				marine = follower.Marine
			else
				marine = nil
			end
		end

		if not marine then
			return nil
		end

		local v3 = Scene.flattenedUnit(marine:GetPivot().LookVector) or -data2.Forward
		local v4 = marine:GetPivot().Position + v3 * 1.65 + data2.Right * 0.35

		if Vector3.new(grabFruit.Root.Position.X - v4.X, 0, grabFruit.Root.Position.Z - v4.Z).Magnitude > 4 or not v2.isFruitTouchingBoat(grabFruit) then
			local surfacePosition = Deck.getSurfacePosition(data2.Ship, v4)
			grabFruit.Root.CFrame = CFrame.new(surfacePosition + createVector(0, 1, 0) * (grabFruit.Root.Size.Y * 0.55))
		end
	end

	grabFruit.Root.AssemblyLinearVelocity = createVector(0, 0, 0)
	grabFruit.Root.AssemblyAngularVelocity = createVector(0, 0, 0)
	grabFruit.Root.Anchored = true
	return grabFruit
end

return table.freeze(v2)