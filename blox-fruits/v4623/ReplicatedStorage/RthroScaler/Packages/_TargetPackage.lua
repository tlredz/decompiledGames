local CharacterHelper = require(script.CharacterHelper)
local v = {}
local TargetPackage = {}

for _, v2 in pairs({
	"LeftLowerArm",
	"RightLowerArm",
	"LeftUpperArm",
	"RightUpperArm",
	"LeftLowerLeg",
	"RightLowerLeg",
	"LeftUpperLeg",
	"RightUpperLeg",
	"RightHand",
	"LeftHand",
	"LeftFoot",
	"RightFoot",
	"UpperTorso",
	"LowerTorso",
	"Head",
	"HumanoidRootPart"
}) do
	v[v2] = true
end

local function readValueBase(instance, childName: string, value)
	local child = instance:FindFirstChild(childName)

	if child then
		value = child.Value or value
	end

	return value
end

local function matchHeadToMesh(head, specialMesh)
	for _, attachment in head:GetChildren() do
		if not attachment:IsA("Attachment") or specialMesh:FindFirstChild(attachment.Name) then
			continue
		end

		local vector3Value = Instance.new("Vector3Value")
		vector3Value.Name = attachment.Name
		vector3Value.Value = attachment.Position
		vector3Value.Parent = specialMesh
	end

	local avatarPartScaleType = head:FindFirstChild("AvatarPartScaleType")

	if avatarPartScaleType and not specialMesh:FindFirstChild("AvatarPartScaleType") then
		local clone = avatarPartScaleType:Clone()
		clone.Parent = specialMesh
	end
end

local function setHeight(instance, height: number, p: number, flag: boolean, flag2: boolean)
	local head = instance:FindFirstChild("Head")
	local humanoid = instance:FindFirstChildWhichIsA("Humanoid")
	local rootPart = humanoid and humanoid.RootPart
	assert(head, "Unable to find Head.")
	assert(humanoid, "Unable to find Humanoid.")
	assert(rootPart, "Unable to find Humanoid.RootPart.")
	local v2 = rootPart.CFrame * CFrame.new(0, -(humanoid.HipHeight + rootPart.Size.Y / 2), 0)
	local v3 = p / height
	local bodyHeightScale = humanoid:FindFirstChild("BodyHeightScale")
	local v4 = v3 * (bodyHeightScale and bodyHeightScale.Value or 1)
	local specialMesh = head:FindFirstChildWhichIsA("SpecialMesh")
	local v5

	if specialMesh then
		v5 = specialMesh.MeshType == Enum.MeshType.FileMesh
	else
		v5 = false
	end

	if specialMesh then
		matchHeadToMesh(head, specialMesh)
	end

	local originalSizesByAccessory = {}

	for _, accessory in instance:GetChildren() do
		if not accessory:IsA("Accessory") or accessory:GetAttribute("IgnoreScale") then
			continue
		end

		local basePart = accessory:FindFirstChildWhichIsA("BasePart")
		local originalSize = basePart and basePart:FindFirstChild("OriginalSize")

		if not (basePart and originalSize) then
			continue
		end

		for _, child in basePart:GetChildren() do
			if child.Name == "AccessoryWeld" or child.Name == "AccessoryRigidConstraint" then
				child:Destroy()
			end
		end

		accessory.Parent = nil
		originalSizesByAccessory[accessory] = originalSize
	end

	for _, folder in instance:GetChildren() do
		if not v[folder.Name] then
			continue
		end

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("Motor6D") and not descendant:GetAttribute("IgnoreScale") then
				descendant.C0 = descendant.C0.Rotation + descendant.C0.Position * v4
				descendant.C1 = descendant.C1.Rotation + descendant.C1.Position * v4
			elseif descendant:IsA("Attachment") then
				descendant.Position *= v4
				local originalPosition = descendant:FindFirstChild("OriginalPosition")

				if originalPosition then
					originalPosition.Value *= v4
				end
			elseif descendant:IsA("Vector3Value") and descendant.Name == "OriginalSize" then
				local parent = descendant.Parent

				if parent:IsA("BasePart") then
					local mass = parent:GetMass()
					parent.Size *= v4
					descendant.Value *= v4

					if not flag then
						local mass2 = parent:GetMass()
						local currentPhysicalProperties = parent.CurrentPhysicalProperties
						local v6 = mass / (mass2 / currentPhysicalProperties.Density)
						parent.CustomPhysicalProperties = PhysicalProperties.new(
							v6,
							currentPhysicalProperties.Friction,
							currentPhysicalProperties.Elasticity,
							currentPhysicalProperties.FrictionWeight,
							currentPhysicalProperties.ElasticityWeight
						)
					end
				elseif specialMesh and parent == specialMesh then
					local parent2 = parent.Parent

					for _, vector3Value in parent:GetChildren() do
						if not vector3Value:IsA("Vector3Value") then
							continue
						end

						local attachment = parent2:FindFirstChild(vector3Value.Name)

						if attachment and attachment:IsA("Attachment") then
							vector3Value.Value *= v4
						end
					end

					if v5 and parent:IsA("SpecialMesh") then
						parent.Scale *= v4
						descendant.Value *= v4
					end
				end
			end
		end
	end

	for k, v6 in originalSizesByAccessory do
		v6.Value *= v4
		humanoid:AddAccessory(k)
	end

	humanoid.HipHeight *= v4

	if not flag2 then
		rootPart.CFrame = v2 * CFrame.new(0, rootPart.Size.Y / 2 + humanoid.HipHeight, 0)
	end
end

function TargetPackage.raw(p, p2: number)
	setHeight(p, CharacterHelper.getHeight(p), p2)
end

function TargetPackage.classic(instance, lastClassicScale: number, flag: boolean?)
	local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		humanoidRootPart:GetAttribute("CharacterSizeScale")
		humanoidRootPart:GetAttribute("CharacterSizeScaleNumber")
		humanoidRootPart:SetAttribute("LastClassicScale", lastClassicScale)
	end

	setHeight(
		instance,
		CharacterHelper.getHeight(instance),
		CharacterHelper.getClassicHeight() * lastClassicScale * (instance:GetAttribute("CharacterSize") or 1),
		false,
		flag
	)
end

function TargetPackage.classicIgnoreHrp(p, p2: number)
	setHeight(p, CharacterHelper.getHeight(p), CharacterHelper.getClassicHeight() * p2, false, true)
end

function TargetPackage.classicKeepDensity(p, p2: number)
	setHeight(p, CharacterHelper.getHeight(p), CharacterHelper.getClassicHeight() * p2, true)
end

function TargetPackage.relative(p, p2: number)
	local height = CharacterHelper.getHeight(p)
	setHeight(p, height, height * p2)
end

return TargetPackage