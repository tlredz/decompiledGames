local createVector = vector.create
local VolcanoScale = {
	InsideMultiplier = 0.75
}

function VolcanoScale.Factor(instance)
	if not instance then
		return 1
	end

	if instance:GetAttribute("InVolcano") == true or instance:GetAttribute("VolcanoApproach") == true then
		return VolcanoScale.InsideMultiplier
	end

	return 1
end

VolcanoScale.RideSpeedCap = 120

function VolcanoScale.SpeedCap(instance)
	return instance and instance:GetAttribute("InVolcano") == true and VolcanoScale.RideSpeedCap or 1e999
end

VolcanoScale.MeshDisableTag = "VolcanoMeshDisable"
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {}
local v2 = {}
local flag = false

function VolcanoScale.CollisionLevel(instance)
	if instance and instance:GetAttribute("InVolcano") == true and instance:GetAttribute("VolcanoValidated") == true then
		return "All"
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearCollisionState(p)
	local v3 = v[p]

	if not v3 then
		return
	end

	v[p] = nil

	for _, connection in v3.Connections do
		connection:Disconnect()
	end

	v3.Folder:Destroy()
end

local function AddCollisionPair(p, part, part2)
	if part == part2 or not part:IsA("BasePart") then
		return
	end

	local part3 = p.Parts[part]

	if not part3 then
		part3 = {}
		p.Parts[part] = part3
	end

	if part3[part2] then
		return
	end

	local noCollisionConstraint = Instance.new("NoCollisionConstraint")
	noCollisionConstraint.Name = "VolcanoShellBypass"
	noCollisionConstraint.Part0 = part
	noCollisionConstraint.Part1 = part2
	noCollisionConstraint.Parent = p.Folder
	part3[part2] = noCollisionConstraint
end

local function TrackShell(part)
	if not part:IsA("BasePart") or v2[part] or part:FindFirstAncestor("Volcano_Hide") == nil and not part:HasTag(VolcanoScale.MeshDisableTag) then
		return
	end

	v2[part] = true

	for _, v3 in v do
		for k in v3.Parts do
			AddCollisionPair(v3, k, part)
		end
	end
end

local function UntrackShell(instance)
	if not v2[instance] then
		return
	end

	v2[instance] = nil

	for _, v3 in v do
		for _, part in v3.Parts do
			local v4 = part[instance]

			if not v4 then
				continue
			end

			v4:Destroy()
			part[instance] = nil
		end
	end
end

local function StartCollisionTracking()
	if flag then
		return
	end

	flag = true

	for _, descendant in workspace:GetDescendants() do
		TrackShell(descendant)
	end

	workspace.DescendantAdded:Connect(TrackShell)
	workspace.DescendantRemoving:Connect(UntrackShell)
	local Observers = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Observers"))
	Observers.observeTag(VolcanoScale.MeshDisableTag, function(instance)
		TrackShell(instance)
		return function()
			if instance:FindFirstAncestor("Volcano_Hide") == nil then
				UntrackShell(instance)
			end
		end
	end, { workspace })
end

function VolcanoScale.SetInsideCollision(folder, p)
	if not RunService:IsServer() then
		return
	end

	if p then
		StartCollisionTracking()

		if v[folder] then
			return
		end

		local folder2 = Instance.new("Folder")
		folder2.Name = "VolcanoCollisionBypass"
		folder2.Parent = folder
		local v3 = {
			Folder = folder2,
			Parts = {},
			Connections = {}
		}
		v[folder] = v3

		local function AddPart(part)
			if not part:IsA("BasePart") then
				return
			end

			if not v3.Parts[part] then
				v3.Parts[part] = {}
			end

			for k in v2 do
				AddCollisionPair(v3, part, k)
			end
		end

		table.insert(v3.Connections, folder.DescendantAdded:Connect(AddPart))
		table.insert(v3.Connections, folder.DescendantRemoving:Connect(function(descendant)
			local part = v3.Parts[descendant]

			if not part then
				return
			end

			for _, v4 in part do
				v4:Destroy()
			end

			v3.Parts[descendant] = nil
		end))
		table.insert(v3.Connections, folder.Destroying:Connect(function()
			ClearCollisionState(folder) -- equivalent call inferred; original call site unknown
		end))

		for _, descendant in folder:GetDescendants() do
			AddPart(descendant)
		end
	else
		ClearCollisionState(folder) -- equivalent call inferred; original call site unknown
	end
end

VolcanoScale.MaxPetDimension = 8

function VolcanoScale.PetCap()
	local volcano = workspace:FindFirstChild("Volcano")
	local maxPetDimension = volcano and tonumber(volcano:GetAttribute("MaxPetDimension"))

	if maxPetDimension and maxPetDimension > 0 then
		return maxPetDimension
	end

	return VolcanoScale.MaxPetDimension
end

local object = setmetatable({}, {
	__mode = "k"
})
local v3 = {
	Seat = true,
	RootPart = true,
	HumanoidRootPart = true,
	invisible_box = true,
	InitialPoses = true,
	AnimSaves = true,
	MutationHitbox = true,
	SpawnMutationHitbox = true
}

function VolcanoScale.VisibleSize(folder)
	local pivot = folder:GetPivot()
	local v4 = nil
	local v5 = nil

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") or part.Transparency >= 1 then
			continue
		end

		local parent = part
		local v6 = false

		while parent and parent ~= folder do
			if v3[parent.Name] then
				v6 = true
				break
			else
				parent = parent.Parent
			end
		end

		if v6 then
			continue
		end

		local objectSpace = pivot:ToObjectSpace(part.CFrame)
		local xVector = objectSpace.XVector
		local yVector = objectSpace.YVector
		local zVector = objectSpace.ZVector
		local v7 = Vector3.new(
			math.abs(xVector.X) * part.Size.X + math.abs(yVector.X) * part.Size.Y + math.abs(zVector.X) * part.Size.Z,
			math.abs(xVector.Y) * part.Size.X + math.abs(yVector.Y) * part.Size.Y + math.abs(zVector.Y) * part.Size.Z,
			math.abs(xVector.Z) * part.Size.X + math.abs(yVector.Z) * part.Size.Y + math.abs(zVector.Z) * part.Size.Z
		) / 2
		local v8 = objectSpace.Position - v7
		local v9 = objectSpace.Position + v7

		if v4 then
			v4 = v4:Min(v8) or v8
		else
			v4 = v8
		end

		if v5 then
			v5 = v5:Max(v9) or v9
		else
			v5 = v9
		end
	end

	return v4 and v5 - v4 or createVector(0, 0, 0)
end

function VolcanoScale.VisibleWidth(p)
	return VolcanoScale.VisibleSize(p).X
end

function VolcanoScale.VisibleMaxDimension(p)
	local visibleSize = VolcanoScale.VisibleSize(p)
	return (math.max(visibleSize.X, visibleSize.Y, visibleSize.Z))
end

function VolcanoScale.Apply(instance, p, p2, p3)
	local v4 = p ~= 1

	if p3 == nil then
		p3 = v4
	end

	VolcanoScale.SetInsideCollision(instance, p3)
	local scale = instance:GetScale()
	local volcanoScaleFactor = instance:GetAttribute("VolcanoScaleFactor") or 1
	local v5 = object[instance]

	if v5 then
		if math.abs(scale - v5.LastScale) > math.max(scale, 1) * 1e-6 then
			v5.NaturalScale = scale / volcanoScaleFactor
		end
	else
		v5 = {
			DimensionPerScale = VolcanoScale.VisibleMaxDimension(instance) / scale,
			NaturalScale = scale / volcanoScaleFactor,
			LastScale = scale
		}
		object[instance] = v5
	end

	if p2 then
		v5.NaturalScale = math.max(v5.NaturalScale * p2, 0.01)
	end

	local v6 = v5.DimensionPerScale * v5.NaturalScale
	local petCap = VolcanoScale.PetCap()
	local v7 = v4 and petCap < v6 and petCap / v6 or 1
	local v8 = v5.NaturalScale * v7

	if math.abs(v8 - scale) > math.max(scale, 1) * 1e-7 then
		instance:ScaleTo(v8)
	end

	v5.LastScale = instance:GetScale()
	instance:SetAttribute("VolcanoScaleFactor", v7)
	return v5.LastScale / scale
end

local object2 = setmetatable({}, {
	__mode = "k"
})
local object3 = setmetatable({}, {
	__mode = "k"
})
local PreserveCharacterMass

PreserveCharacterMass = function(folder, volcanoScaleFactor)
	local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local v4 = object2[humanoidRootPart]

	if v4 then
		humanoidRootPart.CustomPhysicalProperties = v4.Custom
	end

	if volcanoScaleFactor == 1 then
		object2[humanoidRootPart] = nil
		return
	end

	if not v4 then
		object2[humanoidRootPart] = {
			Custom = humanoidRootPart.CustomPhysicalProperties
		}
	end

	local currentPhysicalProperties = humanoidRootPart.CurrentPhysicalProperties
	local v5 = humanoidRootPart:GetMass() / currentPhysicalProperties.Density

	if v5 <= 0 then
		return
	end

	local total = 0

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") or part:FindFirstAncestorOfClass("Tool") or not (not part.Massless or part == humanoidRootPart) then
			continue
		end

		total += part:GetMass()
	end

	local v6 = total * (1 / volcanoScaleFactor ^ 3 - 1)
	humanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(
		math.clamp(currentPhysicalProperties.Density + v6 / v5, 0.01, 100),
		currentPhysicalProperties.Friction,
		currentPhysicalProperties.Elasticity,
		currentPhysicalProperties.FrictionWeight,
		currentPhysicalProperties.ElasticityWeight
	)

	if object3[folder] then
		return
	end

	local v7 = false

	local function Refresh(part)
		if part:IsA("BasePart") and not v7 then
			v7 = true
			task.defer(function()
				v7 = false

				if folder.Parent then
					PreserveCharacterMass(folder, folder:GetAttribute("VolcanoScaleFactor") or 1)
				end
			end)
		end
	end

	local descendantAddedConnection = folder.DescendantAdded:Connect(Refresh)
	local descendantRemovingConnection = folder.DescendantRemoving:Connect(Refresh)
	object3[folder] = { descendantAddedConnection, descendantRemovingConnection }
	folder.Destroying:Connect(function()
		descendantAddedConnection:Disconnect()
		descendantRemovingConnection:Disconnect()
		object3[folder] = nil
	end)
end

function VolcanoScale.Character(instance, volcanoScaleFactor, p)
	if p == nil then
		p = volcanoScaleFactor ~= 1
	end

	VolcanoScale.SetInsideCollision(instance, p)
	local volcanoScaleFactor2 = instance:GetAttribute("VolcanoScaleFactor") or 1

	if volcanoScaleFactor2 == volcanoScaleFactor then
		return 1
	end

	local scalesByTool = {}

	for _, tool in instance:GetChildren() do
		if tool:IsA("Tool") then
			scalesByTool[tool] = tool:GetScale()
		end
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local hipHeight = humanoid and humanoid.HipHeight
	local walkSpeed = humanoid and humanoid.WalkSpeed
	local jumpPower = humanoid and humanoid.JumpPower
	local jumpHeight = humanoid and humanoid.JumpHeight
	local v4 = volcanoScaleFactor / volcanoScaleFactor2
	instance:ScaleTo(instance:GetScale() * v4)

	for k, v5 in scalesByTool do
		if k.Parent == instance then
			k:ScaleTo(v5)
		end
	end

	if humanoid then
		humanoid.HipHeight = hipHeight * v4
		humanoid.WalkSpeed = walkSpeed
		humanoid.JumpPower = jumpPower
		humanoid.JumpHeight = jumpHeight
	end

	PreserveCharacterMass(instance, volcanoScaleFactor)
	instance:SetAttribute("VolcanoScaleFactor", volcanoScaleFactor)
	return v4
end

return VolcanoScale