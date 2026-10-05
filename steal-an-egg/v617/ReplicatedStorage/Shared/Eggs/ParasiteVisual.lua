local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local MonsterParasite = require(ReplicatedStorage.Data.MonsterParasite)
local MonsterParasiteWindow = require(ReplicatedStorage.Shared.Util.MonsterParasiteWindow)
local PartBounds = require(ReplicatedStorage.Shared.Utils.PartBounds)
local v = {}
local v2 = nil
local object = setmetatable({}, {
	__mode = "k"
})

local function resolveTemplate()
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local models

	if assets then
		models = assets:FindFirstChild("Models")
	end

	local child

	if models then
		child = models:FindFirstChild(MonsterParasite.AssetsFolderName)
	end

	local model

	if child then
		model = child:FindFirstChild(MonsterParasite.ParasiteModelName)
	end

	if model and model:IsA("Model") and model.PrimaryPart then
		return model
	end

	return nil
end

local function getIdleAnimation()
	local v3 = v2

	if v3 ~= nil then
		return v3
	end

	v3 = Instance.new("Animation")
	v3.Name = "ParasiteIdle"
	v3.AnimationId = `rbxassetid://{MonsterParasite.ParasiteIdleAnimationId}`
	v2 = v3
	return v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stripEditorOnly(clone)
	local initialPoses = clone:FindFirstChild("InitialPoses")

	if initialPoses then
		initialPoses:Destroy()
	end

	local animSaves = clone:FindFirstChild("AnimSaves")

	if animSaves then
		animSaves:Destroy()
	end
end

local function configureParts(folder, anchored: boolean)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = anchored
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Massless = true
	end
end

local function partInside(ancestor, instance)
	return instance ~= nil and instance:IsDescendantOf(ancestor)
end

local function destroyIfExternalJoint(instance, instance2, instance3, ancestor)
	if instance.Name == "ParasiteEggWeld" then
		instance:Destroy()
	else
		local v3

		if instance2 == nil then
			v3 = false
		else
			v3 = instance2:IsDescendantOf(ancestor)
		end

		if v3 then
			local v4

			if instance3 == nil then
				v4 = false
			else
				v4 = instance3:IsDescendantOf(ancestor)
			end

			if not v4 then
				instance:Destroy()
			end
		else
			instance:Destroy()
		end
	end
end

local function stripExternalJointsAndBillboards(folder)
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BillboardGui") then
			descendant:Destroy()
		elseif descendant:IsA("Attachment") and descendant.Name == "MonsterParasiteIconAnchor" then
			descendant:Destroy()
		elseif descendant:IsA("Motor6D") or descendant:IsA("Weld") or descendant:IsA("WeldConstraint") then
			local part0 = descendant.Part0
			local part1 = descendant.Part1

			if descendant.Name ~= "ParasiteEggWeld" then
				local v3

				if part0 == nil then
					v3 = false
				else
					v3 = part0:IsDescendantOf(folder)
				end

				if v3 then
					local v4

					if part1 == nil then
						v4 = false
					else
						v4 = part1:IsDescendantOf(folder)
					end

					if v4 then
						continue
					end
				end
			end

			descendant:Destroy()
		end
	end
end

local function weldToEgg(primaryPart, primaryPart2)
	local parasiteEggWeld = primaryPart2:FindFirstChild("ParasiteEggWeld")

	if parasiteEggWeld then
		parasiteEggWeld:Destroy()
	end

	local motor6D = Instance.new("Motor6D")
	motor6D.Name = "ParasiteEggWeld"
	motor6D.Part0 = primaryPart
	motor6D.Part1 = primaryPart2
	motor6D.C0 = primaryPart.CFrame:Inverse() * primaryPart2.CFrame
	motor6D.Parent = primaryPart2
	return motor6D
end

local function poseDrift(instance)
	local primaryPart = instance.PrimaryPart
	local bone

	if primaryPart then
		bone = primaryPart:FindFirstChildWhichIsA("Bone")
	end

	if primaryPart == nil or bone == nil then
		return createVector(0, 0, 0)
	end

	return bone.TransformedWorldCFrame.Position - (primaryPart.CFrame * bone.CFrame).Position
end

local function poseTransform(instance)
	local primaryPart = instance.PrimaryPart
	local bone

	if primaryPart then
		bone = primaryPart:FindFirstChildWhichIsA("Bone")
	end

	if primaryPart == nil or bone == nil then
		return CFrame.identity
	end

	return primaryPart.CFrame:Inverse() * bone.TransformedWorldCFrame * bone.CFrame:Inverse()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function poseMoved(cframe: CFrame?, cframe2: CFrame)
	if cframe == nil then
		return true
	end

	return (cframe.RightVector - cframe2.RightVector).Magnitude + (cframe.UpVector - cframe2.UpVector).Magnitude + (cframe.LookVector - cframe2.LookVector).Magnitude > 0.001 or (cframe.Position - cframe2.Position).Magnitude > 0.001
end

local function visibleParts(folder)
	local parts = {}

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") and part.Transparency < 1 then
			table.insert(parts, part)
		end
	end

	return parts
end

local function resolveSeat(instance, p, instance2)
	local primaryPart = instance2.PrimaryPart

	if primaryPart == nil or not instance:IsDescendantOf(Workspace) then
		return nil
	end

	local filterDescendantsInstances = visibleParts(instance)
	local v4 = visibleParts(instance2)

	if #filterDescendantsInstances == 0 or #v4 == 0 then
		return nil
	end

	local rotation = p.CFrame.Rotation
	local v5, v6 = PartBounds(filterDescendantsInstances, rotation)

	if v6.Magnitude < 0.001 then
		return nil
	end

	local v7, v8 = PartBounds(v4, primaryPart.CFrame.Rotation)
	local pointToObjectSpace = primaryPart.CFrame:PointToObjectSpace(v7.Position)
	local upVector = rotation.UpVector
	local rightVector = rotation.RightVector
	local lookVector = rotation.LookVector
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	raycastParams.RespectCanCollide = false
	local magnitude = v6.Magnitude
	local parasiteCrownOffset = MonsterParasite.ParasiteCrownOffset
	local v9 = v5.Position + rightVector * (parasiteCrownOffset.X * v6.X) + lookVector * (parasiteCrownOffset.Y * v6.Z) + upVector * magnitude
	local v10 = upVector * -magnitude

	-- equivalent calls inferred from this helper; original call sites unknown
	local function probe(vector2: Vector3)
		return Workspace:Raycast(v9 + vector2, v10, raycastParams)
	end

	local v11 = probe(createVector(0, 0, 0)) -- equivalent call inferred; original call site unknown

	if v11 == nil then
		return nil
	end

	local dot = (v9 - v11.Position):Dot(upVector)
	local v12 = math.min(v8.X, v8.Z) * 0.4

	for _, v13 in {
		rightVector * v12,
		rightVector * -v12,
		lookVector * v12,
		lookVector * -v12
	} do
		local v14 = probe(v13) -- equivalent call inferred; original call site unknown

		if v14 then
			dot = math.min(dot, (v9 + v13 - v14.Position):Dot(upVector))
		end
	end

	local cframe = CFrame.fromMatrix(createVector(0, 0, 0), upVector:Cross(-lookVector), upVector, -lookVector)
	local primaryPart2 = instance2.PrimaryPart
	local bone

	if primaryPart2 then
		bone = primaryPart2:FindFirstChildWhichIsA("Bone")
	end

	local identity

	if primaryPart2 == nil or bone == nil then
		identity = CFrame.identity
	else
		identity = primaryPart2.CFrame:Inverse() * bone.TransformedWorldCFrame * bone.CFrame:Inverse()
	end

	local cframe2 = cframe * identity.Rotation:Inverse()
	return cframe2 + (v9 - upVector * (dot - v8.Y * 0.04999999999999999) - cframe2:VectorToWorldSpace(identity * pointToObjectSpace))
end

local function removeIcon(folder)
	for _, descendant in folder:GetDescendants() do
		if not (descendant:IsA("BillboardGui") or descendant:IsA("Attachment") and descendant.Name == "MonsterParasiteIconAnchor") then
			continue
		end

		descendant:Destroy()
	end
end

local object2 = setmetatable({}, {
	__mode = "k"
})

local function holdSeat(p, instance, p2, instance2)
	if instance2.PrimaryPart == nil then
		return
	end

	local v3 = (object2[p2] or 0) + 1
	object2[p2] = v3
	local v4 = nil
	local v5 = false
	local v6 = nil
	local flag = false
	local v7 = os.clock() + 30
	local postSimulationConnection = nil
	postSimulationConnection = RunService.PostSimulation:Connect(function()
		if object2[p2] ~= v3 or p2.Parent == nil or instance.Parent == nil or instance2.Parent == nil then
			postSimulationConnection:Disconnect()
			return
		end

		if flag then
			postSimulationConnection:Disconnect()
			return
		end

		local primaryPart = instance2.PrimaryPart
		local bone

		if primaryPart then
			bone = primaryPart:FindFirstChildWhichIsA("Bone")
		end

		local identity

		if primaryPart == nil or bone == nil then
			identity = CFrame.identity
		else
			identity = primaryPart.CFrame:Inverse() * bone.TransformedWorldCFrame * bone.CFrame:Inverse()
		end

		local v9 = poseMoved(v4, identity) and resolveSeat(p, instance, instance2)

		if v9 then
			v4 = identity
			local v10 = v5

			if not v10 then
				v10 = poseMoved(CFrame.identity, identity)
			end

			v5 = v10
			p2.C0 = instance.CFrame:Inverse() * v9
		end

		local now = os.clock()

		if v6 == nil and v5 then
			v6 = now + 0.35
		end

		if (v6 or v7) <= now then
			flag = true
		end
	end)
end

local function seatWhenReachable(instance, p, instance2, p2)
	if instance2.PrimaryPart == nil then
		return
	end

	local ancestryChangedConnection = nil
	ancestryChangedConnection = instance.AncestryChanged:Connect(function()
		if p2.Parent == nil or instance2.Parent ~= instance then
			ancestryChangedConnection:Disconnect()
			return
		end

		local seat = resolveSeat(instance, p, instance2)

		if seat == nil then
			return
		end

		ancestryChangedConnection:Disconnect()
		p2.C0 = p.CFrame:Inverse() * seat
		holdSeat(instance, p, p2, instance2)
	end)
end

local function attachOutline(instance)
	if instance:FindFirstChild(MonsterParasite.ParasiteHighlightName) then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = MonsterParasite.ParasiteHighlightName
	highlight.Adornee = instance
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = MonsterParasite.ParasiteHighlightColor
	highlight.FillTransparency = MonsterParasite.ParasiteHighlightFillTransparency
	highlight.OutlineColor = MonsterParasite.ParasiteHighlightColor
	highlight.OutlineTransparency = MonsterParasite.ParasiteHighlightTransparency
	highlight.Parent = instance
end

local function playIdle(instance)
	local function tryPlay()
		if instance.Parent == nil or not instance:IsDescendantOf(Workspace) then
			return false
		end

		local animator = instance:FindFirstChildWhichIsA("Animator", true)

		if animator == nil or not animator:IsA("Animator") then
			warn((`[MonsterParasite] Missing Animator in {instance:GetFullName()}`))
			return true
		end

		local v3 = v2

		if v3 == nil then
			v3 = Instance.new("Animation")
			v3.Name = "ParasiteIdle"
			v3.AnimationId = `rbxassetid://{MonsterParasite.ParasiteIdleAnimationId}`
			v2 = v3
		end

		local animationId = v3.AnimationId

		for _, v4 in animator:GetPlayingAnimationTracks() do
			local animation = v4.Animation

			if animation and animation.AnimationId == animationId then
				return true
			end
		end

		local success, result = pcall(function()
			local animator2 = animator
			local v4 = v2

			if v4 ~= nil then
				return animator2:LoadAnimation(v4)
			end

			v4 = Instance.new("Animation")
			v4.Name = "ParasiteIdle"
			v4.AnimationId = `rbxassetid://{MonsterParasite.ParasiteIdleAnimationId}`
			v2 = v4
			return animator2:LoadAnimation(v4)
		end)

		if not success then
			warn((`[MonsterParasite] Failed to load parasite idle: {result}`))
			return true
		end

		result.Looped = true
		result.Priority = Enum.AnimationPriority.Idle
		result:Play()
		return true
	end

	if tryPlay() then
		return
	end

	local ancestryChangedConnection = nil
	ancestryChangedConnection = instance.AncestryChanged:Connect(function()
		if tryPlay() then
			ancestryChangedConnection:Disconnect()
		end
	end)
end

local function decorate(parent)
	local model = parent:FindFirstChild(MonsterParasite.ParasiteVisualName)

	if model and model:IsA("Model") then
		attachOutline(model)
		removeIcon(model)
		playIdle(model)
		return model
	else
		local template = resolveTemplate()
		local primaryPart = parent.PrimaryPart

		if template == nil or primaryPart == nil then
			return nil
		end

		local clone = template:Clone()
		clone.Name = MonsterParasite.ParasiteVisualName
		stripEditorOnly(clone) -- equivalent call inferred; original call site unknown
		clone:ScaleTo(template:GetScale() * parent:GetScale() * MonsterParasite.ParasiteScaleMultiplier)
		configureParts(clone, true)
		local parasiteCrownOffset = MonsterParasite.ParasiteCrownOffset
		local size = primaryPart.Size
		clone:PivotTo(primaryPart.CFrame * CFrame.new(
			parasiteCrownOffset.X * size.X,
			size.Y * 0.5,
			parasiteCrownOffset.Y * size.Z
		))
		local primaryPart2 = clone.PrimaryPart
		assert(primaryPart2 ~= nil, "Parasite template requires a PrimaryPart")
		local seat = resolveSeat(parent, primaryPart, clone)

		if seat then
			clone:PivotTo(seat * (primaryPart2.CFrame:Inverse() * clone:GetPivot()))
		end

		clone.Parent = parent
		local v3 = weldToEgg(primaryPart, primaryPart2)
		holdSeat(parent, primaryPart, v3, clone)

		if seat == nil and clone.PrimaryPart ~= nil then
			local ancestryChangedConnection = nil
			ancestryChangedConnection = parent.AncestryChanged:Connect(function()
				if v3.Parent == nil or clone.Parent ~= parent then
					ancestryChangedConnection:Disconnect()
					return
				end

				local seat2 = resolveSeat(parent, primaryPart, clone)

				if seat2 == nil then
					return
				end

				ancestryChangedConnection:Disconnect()
				v3.C0 = primaryPart.CFrame:Inverse() * seat2
				holdSeat(parent, primaryPart, v3, clone)
			end)
		end

		configureParts(clone, false)
		attachOutline(clone)
		playIdle(clone)
		return clone
	end
end

local function applyDecoration(parent)
	if object[parent] == true and MonsterParasiteWindow.IsActive() then
		return (decorate(parent))
	end

	v.Clear(parent)
	return nil
end

function v.PoseDrift(instance)
	local primaryPart = instance.PrimaryPart
	local bone

	if primaryPart then
		bone = primaryPart:FindFirstChildWhichIsA("Bone")
	end

	if primaryPart == nil or bone == nil then
		return createVector(0, 0, 0)
	end

	return bone.TransformedWorldCFrame.Position - (primaryPart.CFrame * bone.CFrame).Position
end

function v.Clear(folder)
	local child = folder:FindFirstChild(MonsterParasite.ParasiteVisualName, true)

	if child then
		child:Destroy()
	end

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BillboardGui") and descendant.Name == MonsterParasite.ParasiteBillboardName then
			descendant:Destroy()
		elseif descendant:IsA("Highlight") and descendant.Name == MonsterParasite.ParasiteHighlightName then
			descendant:Destroy()
		end
	end
end

function v.PrepareYankClone(instance)
	if instance.PrimaryPart == nil then
		return nil
	end

	local pivot = instance:GetPivot()
	local clone = instance:Clone()
	stripEditorOnly(clone) -- equivalent call inferred; original call site unknown
	stripExternalJointsAndBillboards(clone)
	configureParts(clone, true)
	clone.Parent = Workspace
	clone:PivotTo(pivot)
	playIdle(clone)
	instance:Destroy()
	return clone
end

function v.Attach(parent, flag: boolean?)
	object[parent] = flag == true or nil

	if object[parent] == true and MonsterParasiteWindow.IsActive() then
		return (decorate(parent))
	end

	v.Clear(parent)
	return nil
end

MonsterParasiteWindow.Changed:Connect(function()
	for k in object do
		if k.Parent == nil then
			continue
		end

		if object[k] == true and MonsterParasiteWindow.IsActive() then
			decorate(k)
		else
			v.Clear(k)
		end
	end
end)
return table.freeze(v)