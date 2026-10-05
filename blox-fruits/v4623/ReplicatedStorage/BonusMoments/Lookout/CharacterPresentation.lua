local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Anims = require(ReplicatedStorage.Util.Anims)
local Graphics = require(ReplicatedStorage.Util.Graphics)
require(script.Parent.Finale.Types)
local v = {
	TemplateFolderName = "LookoutFinaleNPCs",
	TemplateWaitTime = 5,
	TemplateChildrenByVariant = {
		Success = {
			"Marine1",
			"Marine",
			"Pirate",
			"CanvanderEquipped",
			"Fruits"
		}
	},
	TemplateChildrenByFailureTemplate = {
		Fisherman = {
			"Marine1",
			"Marine",
			"Fisherman",
			"CanvanderEquipped",
			"Fish",
			"FishSlapEffect"
		},
		Doghouse = {
			"Marine1",
			"Marine",
			"Doghouse",
			"CanvanderEquipped",
			"Letters"
		}
	},
	CanvanderTemplateName = "CanvanderEquipped",
	FishingRodModelName = "NPCRod",
	FaceTextureByBundleId = {
		["147551965983540"] = "255828374",
		["114357694516233"] = "238984437",
		["171354436203665"] = "405706038",
		["48847223322759"] = "277939506",
		["1164"] = "209715003",
		["255535022429711"] = "141728515",
		["962"] = "7074749"
	},
	DragonHybridIdleAnimationId = "rbxassetid://134316320430222",
	MarineWeaponHoldWeight = 0.42,
	Animations = {
		Run = {
			Name = "NPC_Run",
			Looped = true,
			Priority = Enum.AnimationPriority.Movement,
			FadeTime = 0.1,
			Weight = 1,
			Speed = 1.1
		},
		Walk = {
			Name = "NPC_Walk",
			Looped = true,
			Priority = Enum.AnimationPriority.Movement,
			FadeTime = 0.1,
			Weight = 1,
			Speed = 1
		},
		Idle = {
			Name = "NPC_Idle",
			Looped = true,
			Priority = Enum.AnimationPriority.Idle,
			FadeTime = 0.1
		},
		PickupBend = {
			Name = "StunKneel",
			Looped = true,
			Priority = Enum.AnimationPriority.Action2,
			FadeTime = 0.15,
			Weight = 0.5
		},
		Eat = {
			Name = "FruitEat",
			Looped = false,
			Priority = Enum.AnimationPriority.Action4,
			FadeTime = 0.1,
			Weight = 1,
			Speed = 1
		},
		CrateHold = {
			Name = "Fishing_HoldingTreasureFixed",
			Looped = true,
			Priority = Enum.AnimationPriority.Action3,
			FadeTime = 0.15
		},
		CrateShake = {
			Name = "Fishing_OpenTreasureNew",
			Looped = true,
			Priority = Enum.AnimationPriority.Action4,
			FadeTime = 0.1,
			Weight = 1,
			Speed = 1.35
		},
		DriverIdle = {
			Name = "SteerIdle",
			Looped = true,
			Priority = Enum.AnimationPriority.Idle,
			FadeTime = 0.1,
			Weight = 1
		},
		FishermanRodIdle = {
			Name = "Fishing_RodEquipped",
			Looped = true,
			Priority = Enum.AnimationPriority.Action,
			FadeTime = 0.15,
			Weight = 1
		},
		FishingRodModelIdle = {
			Name = "Fishing_RodModel_Idle",
			Looped = true,
			Priority = Enum.AnimationPriority.Action,
			FadeTime = 0.15,
			Weight = 1
		},
		StunFlinch = {
			Name = "StunIdle2",
			Looped = false,
			Priority = Enum.AnimationPriority.Action4,
			FadeTime = 0.1,
			Weight = 1
		},
		ScaredIdle = {
			Name = "SlapArena_WeaknessIdle",
			Looped = true,
			Priority = Enum.AnimationPriority.Action3,
			FadeTime = 0.15,
			Weight = 0.15
		},
		FishSlap = {
			Name = "SlapArena_Swing",
			Looped = false,
			Priority = Enum.AnimationPriority.Action4,
			FadeTime = 0.05,
			Weight = 1
		},
		SlapVictim = {
			Name = "SlapArena_GotSlapped",
			Looped = false,
			Priority = Enum.AnimationPriority.Action4,
			FadeTime = 0.05,
			Weight = 1
		}
	},
	LimbPartNames = {
		UpperTorso = true,
		LowerTorso = true,
		RightUpperArm = true,
		RightLowerArm = true,
		RightHand = true,
		LeftUpperArm = true,
		LeftLowerArm = true,
		LeftHand = true,
		RightUpperLeg = true,
		RightLowerLeg = true,
		RightFoot = true,
		LeftUpperLeg = true,
		LeftLowerLeg = true,
		LeftFoot = true
	},
	Donors = {
		Marine = {
			PreferredNames = {
				"Marine",
				"Marine Recruiter",
				"Marine Leader",
				"Marines Boat Dealer"
			},
			Keyword = "marine",
			TeamSelectionName = "MenuMarine"
		},
		Marine1 = {
			PreferredNames = {
				"Marine",
				"Marine Recruiter",
				"Marine Leader",
				"Marines Boat Dealer"
			},
			Keyword = "marine",
			TeamSelectionName = "MenuMarine"
		},
		Pirate = {
			PreferredNames = { "Pirate Recruiter", "Pirate Adventurer" },
			Keyword = "pirate",
			TeamSelectionName = "MenuPirate"
		},
		Fisherman = {
			PreferredNames = { "Fisherman", "Angler" },
			Keyword = "fisher"
		},
		Doghouse = {
			PreferredNames = { "Doghouse" },
			Keyword = "doghouse"
		}
	}
}
local localPlayer = Players.LocalPlayer
local CharacterPresentation = {}
local object = setmetatable({}, {
	__mode = "k"
})

local function restoreOptimizedAppearance(result)
	local proxy_Shirt = result:FindFirstChild("Proxy_Shirt")
	local shirt = result:FindFirstChildWhichIsA("Shirt")

	if proxy_Shirt and proxy_Shirt:IsA("StringValue") and shirt then
		local shirtTemplate = proxy_Shirt:GetAttribute("ShirtTemplate")
		local color3 = proxy_Shirt:GetAttribute("Color3")

		if typeof(shirtTemplate) == "string" then
			shirt.ShirtTemplate = Graphics.SmartScale(shirtTemplate)
		end

		if typeof(color3) == "Color3" then
			shirt.Color3 = color3
		end
	end

	local proxy_Pants = result:FindFirstChild("Proxy_Pants")
	local pants = result:FindFirstChildWhichIsA("Pants")

	if proxy_Pants and proxy_Pants:IsA("StringValue") and pants then
		local pantsTemplate = proxy_Pants:GetAttribute("PantsTemplate")
		local color3 = proxy_Pants:GetAttribute("Color3")

		if typeof(pantsTemplate) == "string" then
			pants.PantsTemplate = Graphics.SmartScale(pantsTemplate)
		end

		if typeof(color3) == "Color3" then
			pants.Color3 = color3
		end
	end

	local faceId = result:GetAttribute("FaceId")
	local head = result:FindFirstChild("Head")
	local decal

	if head then
		decal = head:FindFirstChildWhichIsA("Decal")
	end

	if typeof(faceId) == "string" and decal then
		decal.Texture = Graphics.SmartScale(faceId)
	end

	for _, child in result:GetChildren() do
		if not (child:IsA("Accessory") or child:IsA("Hat")) then
			continue
		end

		for _, descendant in child:GetDescendants() do
			if descendant.Name ~= "Proxy_SpecialMesh" then
				continue
			end

			local specialMesh = descendant.Parent and descendant.Parent:FindFirstChildWhichIsA("SpecialMesh")

			if not specialMesh then
				continue
			end

			for _, attributeName in {
				"MeshId",
				"MeshType",
				"Offset",
				"Scale",
				"TextureId",
				"VertexColor"
			} do
				local attribute = descendant:GetAttribute(attributeName)

				if attributeName == "TextureId" and typeof(attribute) == "string" then
					attribute = Graphics.SmartScale(attribute)
				elseif attributeName == "MeshType" and typeof(attribute) == "string" then
					attribute = Enum.MeshType[attribute]
				end

				if attribute ~= nil then
					specialMesh[attributeName] = attribute
				end
			end
		end
	end

	local compositeTextureId = result:GetAttribute("CompositeTextureId")

	if typeof(compositeTextureId) == "string" and compositeTextureId ~= "" then
		for _, part in result:GetChildren() do
			if part:IsA("MeshPart") and v.LimbPartNames[part.Name] then
				part.TextureID = Graphics.SmartScale(compositeTextureId)
			end
		end
	end
end

local function sanitizeCharacter(folder)
	for _, descendant in folder:GetDescendants() do
		if not (descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") or descendant:IsA("Tool") or descendant:IsA("ProximityPrompt") or descendant:IsA("ClickDetector") or descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") or descendant:IsA("Highlight") or descendant:IsA("ForceField")) then
			continue
		end

		descendant:Destroy()
	end

	local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart", true) or folder:FindFirstChild("Torso", true) or folder:FindFirstChild(
		"UpperTorso",
		true
	)

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = folder:FindFirstChildWhichIsA("BasePart", true)
	end

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		folder.PrimaryPart = humanoidRootPart
	end

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = descendant == humanoidRootPart
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.CastShadow = false
			descendant.Massless = true
			descendant.AssemblyLinearVelocity = createVector(0, 0, 0)
			descendant.AssemblyAngularVelocity = createVector(0, 0, 0)
		elseif descendant:IsA("Humanoid") then
			descendant.AutoRotate = false
			descendant.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end
	end

	folder:SetAttribute("Optimized", true)
	return folder
end

local function createRigPart(parent, name: string, size: Vector3, color: Color3, value: number?)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.Transparency = value or 0
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Massless = true
	part.Parent = parent
	return part
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createMotor(part, name: string, part2, part3, C0: CFrame, C1: CFrame)
	local motor6D = Instance.new("Motor6D")
	motor6D.Name = name
	motor6D.Part0 = part2
	motor6D.Part1 = part3
	motor6D.C0 = C0
	motor6D.C1 = C1
	motor6D.Parent = part
end

local function createFallbackRig(childName)
	local model = Instance.new("Model")
	model.Name = `LookoutFinale{childName}`
	local color

	if childName == "Marine" or childName == "Marine1" then
		color = Color3.fromRGB(225, 235, 245)
	elseif childName == "Fisherman" then
		color = Color3.fromRGB(66, 113, 92)
	elseif childName == "Doghouse" then
		color = Color3.fromRGB(196, 38, 50)
	else
		color = Color3.fromRGB(116, 72, 44)
	end

	local color2 = Color3.fromRGB(226, 177, 131)
	local part = Instance.new("Part")
	part.Name = "HumanoidRootPart"
	part.Size = createVector(2, 2, 1)
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.Transparency = 1
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Massless = true
	part.Parent = model
	local part2 = Instance.new("Part")
	part2.Name = "Torso"
	part2.Size = createVector(2, 2, 1)
	part2.Color = color
	part2.Material = Enum.Material.SmoothPlastic
	part2.Transparency = 0
	part2.TopSurface = Enum.SurfaceType.Smooth
	part2.BottomSurface = Enum.SurfaceType.Smooth
	part2.CanCollide = false
	part2.CanTouch = false
	part2.CanQuery = false
	part2.CastShadow = false
	part2.Massless = true
	part2.Parent = model
	local part3 = Instance.new("Part")
	part3.Name = "Head"
	part3.Size = createVector(2, 1, 1)
	part3.Color = color2
	part3.Material = Enum.Material.SmoothPlastic
	part3.Transparency = 0
	part3.TopSurface = Enum.SurfaceType.Smooth
	part3.BottomSurface = Enum.SurfaceType.Smooth
	part3.CanCollide = false
	part3.CanTouch = false
	part3.CanQuery = false
	part3.CastShadow = false
	part3.Massless = true
	part3.Parent = model
	local part4 = Instance.new("Part")
	part4.Name = "Left Arm"
	part4.Size = createVector(1, 2, 1)
	part4.Color = color
	part4.Material = Enum.Material.SmoothPlastic
	part4.Transparency = 0
	part4.TopSurface = Enum.SurfaceType.Smooth
	part4.BottomSurface = Enum.SurfaceType.Smooth
	part4.CanCollide = false
	part4.CanTouch = false
	part4.CanQuery = false
	part4.CastShadow = false
	part4.Massless = true
	part4.Parent = model
	local part5 = Instance.new("Part")
	part5.Name = "Right Arm"
	part5.Size = createVector(1, 2, 1)
	part5.Color = color
	part5.Material = Enum.Material.SmoothPlastic
	part5.Transparency = 0
	part5.TopSurface = Enum.SurfaceType.Smooth
	part5.BottomSurface = Enum.SurfaceType.Smooth
	part5.CanCollide = false
	part5.CanTouch = false
	part5.CanQuery = false
	part5.CastShadow = false
	part5.Massless = true
	part5.Parent = model
	local part6 = Instance.new("Part")
	part6.Name = "Left Leg"
	part6.Size = createVector(1, 2, 1)
	part6.Color = color
	part6.Material = Enum.Material.SmoothPlastic
	part6.Transparency = 0
	part6.TopSurface = Enum.SurfaceType.Smooth
	part6.BottomSurface = Enum.SurfaceType.Smooth
	part6.CanCollide = false
	part6.CanTouch = false
	part6.CanQuery = false
	part6.CastShadow = false
	part6.Massless = true
	part6.Parent = model
	local part7 = Instance.new("Part")
	part7.Name = "Right Leg"
	part7.Size = createVector(1, 2, 1)
	part7.Color = color
	part7.Material = Enum.Material.SmoothPlastic
	part7.Transparency = 0
	part7.TopSurface = Enum.SurfaceType.Smooth
	part7.BottomSurface = Enum.SurfaceType.Smooth
	part7.CanCollide = false
	part7.CanTouch = false
	part7.CanQuery = false
	part7.CastShadow = false
	part7.Massless = true
	part7.Parent = model
	part.CFrame = CFrame.new(0, 3, 0)
	part2.CFrame = CFrame.new(0, 3, 0)
	part3.CFrame = CFrame.new(0, 4.5, 0)
	part4.CFrame = CFrame.new(-1.5, 3, 0)
	part5.CFrame = CFrame.new(1.5, 3, 0)
	part6.CFrame = CFrame.new(-0.5, 1, 0)
	part7.CFrame = CFrame.new(0.5, 1, 0)
	createMotor(part, "RootJoint", part, part2, CFrame.identity, CFrame.identity) -- equivalent call inferred; original call site unknown
	createMotor(part2, "Neck", part2, part3, CFrame.new(0, 1, 0), CFrame.new(0, -0.5, 0)) -- equivalent call inferred; original call site unknown
	createMotor(part2, "LeftShoulder", part2, part4, CFrame.new(-1, 0.5, 0), CFrame.new(0.5, 0.5, 0)) -- equivalent call inferred; original call site unknown
	createMotor(part2, "RightShoulder", part2, part5, CFrame.new(1, 0.5, 0), CFrame.new(-0.5, 0.5, 0)) -- equivalent call inferred; original call site unknown
	createMotor(part2, "Left Hip", part2, part6, CFrame.new(-0.5, -1, 0), CFrame.new(0, 1, 0)) -- equivalent call inferred; original call site unknown
	createMotor(part2, "Right Hip", part2, part7, CFrame.new(0.5, -1, 0), CFrame.new(0, 1, 0)) -- equivalent call inferred; original call site unknown
	model.PrimaryPart = part
	part.Anchored = true
	return model
end

local function findNpcDonor(preferredNames, keyword: string)
	for _, v2 in { workspace:FindFirstChild("NPCs"), ReplicatedStorage:FindFirstChild("NPCs") } do
		if not v2 then
			continue
		end

		for _, childName in preferredNames do
			local model = v2:FindFirstChild(childName)

			if model and model:IsA("Model") then
				return model
			end
		end

		local v3 = string.lower(keyword)

		for _, model in v2:GetChildren() do
			if model:IsA("Model") and string.find(string.lower(model.Name), v3, 1, true) then
				return model
			end
		end
	end

	return nil
end

local function playStoredAnimation(p, data)
	if not Anims:GetRaw(data.Name) then
		return nil
	end

	local success, result = pcall(function()
		local v2 = Anims:Get(p, data.Name)
		v2.Looped = data.Looped
		v2.Priority = data.Priority

		if data.Speed ~= nil then
			v2:Play(data.FadeTime, data.Weight or 1, data.Speed)
			return v2
		end

		if data.Weight == nil then
			v2:Play(data.FadeTime)
			return v2
		end

		v2:Play(data.FadeTime, data.Weight)
		return v2
	end)

	if success then
		return result
	end

	return nil
end

local function isExpectedTemplateFolder(folder, p, p2, p3: string)
	if not folder or not folder:IsA("Folder") or folder:GetAttribute("Variant") ~= p or folder:GetAttribute("FailureTemplate") ~= p2 or folder:GetAttribute("TemplateKey") ~= p3 then
		return false
	end

	local v2

	if p == "Failure" then
		v2 = v.TemplateChildrenByFailureTemplate[assert(p2)]
	else
		v2 = v.TemplateChildrenByVariant[p]
	end

	for _, childName in v2 do
		if not folder:FindFirstChild(childName) then
			return false
		end
	end

	return true
end

local function weldNestedModelToRoot(result, childName: string)
	local model = result:FindFirstChild(childName)
	local humanoidRootPart = result:FindFirstChild("HumanoidRootPart", true)

	if not (model and model:IsA("Model") and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return
	end

	for _, part in model:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Name = "LookoutActorWeld"
		weldConstraint.Part0 = humanoidRootPart
		weldConstraint.Part1 = part
		weldConstraint.Parent = part
	end
end

function CharacterPresentation.resolveTemplateFolder(flag: boolean, p, p2, p3: string?)
	if not (flag and p3) then
		return nil
	end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild(
		"PlayerGui",
		v.TemplateWaitTime
	)

	if not playerGui then
		return nil
	end

	local v2 = os.clock() + v.TemplateWaitTime
	local child

	while true do
		child = playerGui:FindFirstChild(v.TemplateFolderName)

		if isExpectedTemplateFolder(child, p, p2, p3) then
			break
		end

		task.wait()

		if v2 <= os.clock() then
			return nil
		end
	end

	return child
end

function CharacterPresentation.clone(childName, instance)
	local donor = v.Donors[childName]
	local model

	if instance then
		model = instance:FindFirstChild(childName)
	end

	local teamSelectionName = donor.TeamSelectionName
	local model2

	if teamSelectionName then
		model2 = ReplicatedStorage:FindFirstChild(teamSelectionName)
	else
		model2 = nil
	end

	if model and model:IsA("Model") then
		model2 = model
	elseif not (model2 and model2:IsA("Model")) then
		model2 = findNpcDonor(donor.PreferredNames, donor.Keyword)
	end

	if not model2 then
		return (sanitizeCharacter(createFallbackRig(childName)))
	end

	local archivable = model2.Archivable
	local success, result = pcall(function()
		model2.Archivable = true
		return model2:Clone()
	end)
	model2.Archivable = archivable

	if success and result and result:IsA("Model") then
		result.Name = `LookoutFinale{childName}`

		if childName == "Doghouse" then
			weldNestedModelToRoot(result, "Anchor")
		end

		restoreOptimizedAppearance(result)
		return (sanitizeCharacter(result))
	end

	return (sanitizeCharacter(createFallbackRig(childName)))
end

function CharacterPresentation.setFace(instance, p: string)
	local head = instance:FindFirstChild("Head", true)

	if not (head and head:IsA("BasePart")) then
		return
	end

	local v2 = head:FindFirstChild("face")

	if not (v2 and v2:IsA("Decal")) then
		v2 = head:FindFirstChildWhichIsA("Decal")
	end

	if not v2 then
		v2 = Instance.new("Decal")
		v2.Name = "face"
		v2.Face = Enum.NormalId.Front
		v2.Parent = head
	end

	local formatted = `rbxassetid://{v.FaceTextureByBundleId[p] or p}`
	v2.Name = "face"
	v2.Face = Enum.NormalId.Front
	v2.Color3 = Color3.new(1, 1, 1)
	v2.Transparency = 0
	v2.Texture = formatted
	instance:SetAttribute("FaceId", formatted)
end

function CharacterPresentation.equipCanvander(parent, instance)
	local model = instance and instance:FindFirstChild(v.CanvanderTemplateName)

	if not (model and model:IsA("Model")) then
		return false
	end

	local referenceRightHand = model:FindFirstChild("ReferenceRightHand")
	local right = model:FindFirstChild("Right")
	local rightHand = parent:FindFirstChild("RightHand", true) or parent:FindFirstChild("Right Arm", true)

	if not (referenceRightHand and referenceRightHand:IsA("BasePart") and right and rightHand and rightHand:IsA("BasePart")) then
		return false
	end

	local clone = right:Clone()
	clone.Name = "Canvander"
	clone.Parent = parent

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") then
			descendant:Destroy()
		end
	end

	local cFrame = rightHand.CFrame

	if rightHand.Name == "Right Arm" then
		cFrame *= CFrame.new(0, -rightHand.Size.Y * 0.38, 0)
	end

	local count = 0

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		count += 1
		part.CFrame = cFrame * referenceRightHand.CFrame:ToObjectSpace(part.CFrame)
		part.Anchored = false
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.CastShadow = false
		part.Massless = true
		part.AssemblyLinearVelocity = createVector(0, 0, 0)
		part.AssemblyAngularVelocity = createVector(0, 0, 0)
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Name = "LookoutCanvanderWeld"
		weldConstraint.Part0 = rightHand
		weldConstraint.Part1 = part
		weldConstraint.Parent = part
	end

	if count ~= 0 then
		return true
	end

	clone:Destroy()
	return false
end

function CharacterPresentation.equipFishingRod(parent)
	local fishReplicated = ReplicatedStorage:FindFirstChild("FishReplicated")
	local nPCFishClient = fishReplicated and fishReplicated:FindFirstChild("NPCFishClient")
	local nPCRod = nPCFishClient and nPCFishClient:FindFirstChild("NPCRod")
	local leftHand = parent:FindFirstChild("LeftHand", true) or parent:FindFirstChild("Left Arm", true)

	if not (nPCRod and nPCRod:IsA("Model") and leftHand and leftHand:IsA("BasePart")) then
		return nil
	end

	local model = parent:FindFirstChild(nPCRod.Name)

	if model and model:IsA("Model") then
		return model
	end

	local clone = nPCRod:Clone()
	local rootPart = clone:FindFirstChild("RootPart")

	if not (rootPart and rootPart:IsA("Motor6D")) then
		clone:Destroy()
		return nil
	end

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = false
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.CastShadow = false
		part.Massless = true
		part.AssemblyLinearVelocity = createVector(0, 0, 0)
		part.AssemblyAngularVelocity = createVector(0, 0, 0)
	end

	clone.Parent = parent
	rootPart.Part0 = leftHand
	return clone
end

function CharacterPresentation.hideWeapon(instance)
	local canvander = instance:FindFirstChild("Canvander")

	if not canvander then
		return
	end

	if canvander:IsA("BasePart") then
		canvander.Transparency = 1
	end

	for _, part in canvander:GetDescendants() do
		if part:IsA("BasePart") then
			part.Transparency = 1
		end
	end
end

function CharacterPresentation.poseSurrender(folder)
	for _, motor6D in folder:GetDescendants() do
		if not motor6D:IsA("Motor6D") then
			continue
		end

		if motor6D.Name == "LeftShoulder" or motor6D.Name == "Left Shoulder" then
			motor6D.Transform = CFrame.Angles(0, 0, -2.705260340591211)
		elseif motor6D.Name == "RightShoulder" or motor6D.Name == "Right Shoulder" then
			motor6D.Transform = CFrame.Angles(0, 0, 2.705260340591211)
		end
	end
end

function CharacterPresentation.playDragonHybridIdle(parent, p: number)
	local humanoid = parent:FindFirstChildWhichIsA("Humanoid")

	if not humanoid then
		return nil
	end

	local v2 = humanoid:FindFirstChildWhichIsA("Animator")

	if not v2 then
		v2 = Instance.new("Animator")
		v2.Parent = humanoid
	end

	local animation = Instance.new("Animation")
	animation.Name = "DragonHybridEquippedIdle"
	animation.AnimationId = v.DragonHybridIdleAnimationId
	animation.Parent = parent
	local success, result = pcall(function()
		return v2:LoadAnimation(animation)
	end)

	if not success then
		animation:Destroy()
		return nil
	end

	result.Looped = true
	result.Priority = Enum.AnimationPriority.Action
	result:Play(0.15, p)
	return result
end

function CharacterPresentation.playCombatIdle(p)
	return CharacterPresentation.playDragonHybridIdle(p, v.MarineWeaponHoldWeight)
end

function CharacterPresentation.playRun(p)
	local run = v.Animations.Run

	if not Anims:GetRaw(run.Name) then
		return nil
	end

	local success, result = pcall(function()
		local v2 = Anims:Get(p, run.Name)
		v2.Looped = run.Looped
		v2.Priority = run.Priority

		if run.Speed ~= nil then
			v2:Play(run.FadeTime, run.Weight or 1, run.Speed)
			return v2
		end

		if run.Weight == nil then
			v2:Play(run.FadeTime)
			return v2
		end

		v2:Play(run.FadeTime, run.Weight)
		return v2
	end)

	if success then
		return result
	end

	return nil
end

function CharacterPresentation.playWalk(p)
	local walk = v.Animations.Walk

	if not Anims:GetRaw(walk.Name) then
		return nil
	end

	local success, result = pcall(function()
		local v2 = Anims:Get(p, walk.Name)
		v2.Looped = walk.Looped
		v2.Priority = walk.Priority

		if walk.Speed ~= nil then
			v2:Play(walk.FadeTime, walk.Weight or 1, walk.Speed)
			return v2
		end

		if walk.Weight == nil then
			v2:Play(walk.FadeTime)
			return v2
		end

		v2:Play(walk.FadeTime, walk.Weight)
		return v2
	end)

	if success then
		return result
	end

	return nil
end

function CharacterPresentation.playIdle(p)
	local idle = v.Animations.Idle

	if not Anims:GetRaw(idle.Name) then
		return nil
	end

	local success, result = pcall(function()
		local v2 = Anims:Get(p, idle.Name)
		v2.Looped = idle.Looped
		v2.Priority = idle.Priority

		if idle.Speed ~= nil then
			v2:Play(idle.FadeTime, idle.Weight or 1, idle.Speed)
			return v2
		end

		if idle.Weight == nil then
			v2:Play(idle.FadeTime)
			return v2
		end

		v2:Play(idle.FadeTime, idle.Weight)
		return v2
	end)

	if success then
		return result
	end

	return nil
end

function CharacterPresentation.playPickupBend(p)
	local pickupBend = v.Animations.PickupBend

	if not Anims:GetRaw(pickupBend.Name) then
		return nil
	end

	local success, result = pcall(function()
		local v2 = Anims:Get(p, pickupBend.Name)
		v2.Looped = pickupBend.Looped
		v2.Priority = pickupBend.Priority

		if pickupBend.Speed ~= nil then
			v2:Play(pickupBend.FadeTime, pickupBend.Weight or 1, pickupBend.Speed)
			return v2
		end

		if pickupBend.Weight == nil then
			v2:Play(pickupBend.FadeTime)
			return v2
		end

		v2:Play(pickupBend.FadeTime, pickupBend.Weight)
		return v2
	end)

	if success then
		return result
	end

	return nil
end

function CharacterPresentation.playEat(p)
	local eat = v.Animations.Eat

	if not Anims:GetRaw(eat.Name) then
		return nil
	end

	local success, result = pcall(function()
		local v2 = Anims:Get(p, eat.Name)
		v2.Looped = eat.Looped
		v2.Priority = eat.Priority

		if eat.Speed ~= nil then
			v2:Play(eat.FadeTime, eat.Weight or 1, eat.Speed)
			return v2
		end

		if eat.Weight == nil then
			v2:Play(eat.FadeTime)
			return v2
		end

		v2:Play(eat.FadeTime, eat.Weight)
		return v2
	end)

	if success then
		return result
	end

	return nil
end

function CharacterPresentation.playCrateHold(p)
	local crateHold = v.Animations.CrateHold

	if not Anims:GetRaw(crateHold.Name) then
		return nil
	end

	local success, result = pcall(function()
		local v2 = Anims:Get(p, crateHold.Name)
		v2.Looped = crateHold.Looped
		v2.Priority = crateHold.Priority

		if crateHold.Speed ~= nil then
			v2:Play(crateHold.FadeTime, crateHold.Weight or 1, crateHold.Speed)
			return v2
		end

		if crateHold.Weight == nil then
			v2:Play(crateHold.FadeTime)
			return v2
		end

		v2:Play(crateHold.FadeTime, crateHold.Weight)
		return v2
	end)

	if success then
		return result
	end

	return nil
end

function CharacterPresentation.playCrateShake(p)
	local crateShake = v.Animations.CrateShake

	if not Anims:GetRaw(crateShake.Name) then
		return nil
	end

	local success, result = pcall(function()
		local v2 = Anims:Get(p, crateShake.Name)
		v2.Looped = crateShake.Looped
		v2.Priority = crateShake.Priority

		if crateShake.Speed ~= nil then
			v2:Play(crateShake.FadeTime, crateShake.Weight or 1, crateShake.Speed)
			return v2
		end

		if crateShake.Weight == nil then
			v2:Play(crateShake.FadeTime)
			return v2
		end

		v2:Play(crateShake.FadeTime, crateShake.Weight)
		return v2
	end)

	if success then
		return result
	end

	return nil
end

function CharacterPresentation.playDriverIdle(p)
	local driverIdle = v.Animations.DriverIdle

	if not Anims:GetRaw(driverIdle.Name) then
		return nil
	end

	local success, result = pcall(function()
		local v2 = Anims:Get(p, driverIdle.Name)
		v2.Looped = driverIdle.Looped
		v2.Priority = driverIdle.Priority

		if driverIdle.Speed ~= nil then
			v2:Play(driverIdle.FadeTime, driverIdle.Weight or 1, driverIdle.Speed)
			return v2
		end

		if driverIdle.Weight == nil then
			v2:Play(driverIdle.FadeTime)
			return v2
		end

		v2:Play(driverIdle.FadeTime, driverIdle.Weight)
		return v2
	end)

	if success then
		return result
	end

	return nil
end

function CharacterPresentation.playFishermanRodIdle(p)
	local idle = v.Animations.Idle
	local result

	if Anims:GetRaw(idle.Name) then
		local success
		success, result = pcall(function()
			local v2 = Anims:Get(p, idle.Name)
			v2.Looped = idle.Looped
			v2.Priority = idle.Priority

			if idle.Speed ~= nil then
				v2:Play(idle.FadeTime, idle.Weight or 1, idle.Speed)
				return v2
			end

			if idle.Weight == nil then
				v2:Play(idle.FadeTime)
				return v2
			end

			v2:Play(idle.FadeTime, idle.Weight)
			return v2
		end)

		if not success then
			result = nil
		end
	end

	local fishermanRodIdle = v.Animations.FishermanRodIdle
	local result2

	if Anims:GetRaw(fishermanRodIdle.Name) then
		local success
		success, result2 = pcall(function()
			local v2 = Anims:Get(p, fishermanRodIdle.Name)
			v2.Looped = fishermanRodIdle.Looped
			v2.Priority = fishermanRodIdle.Priority

			if fishermanRodIdle.Speed ~= nil then
				v2:Play(fishermanRodIdle.FadeTime, fishermanRodIdle.Weight or 1, fishermanRodIdle.Speed)
				return v2
			end

			if fishermanRodIdle.Weight == nil then
				v2:Play(fishermanRodIdle.FadeTime)
				return v2
			end

			v2:Play(fishermanRodIdle.FadeTime, fishermanRodIdle.Weight)
			return v2
		end)

		if not success then
			result2 = nil
		end
	end

	if result2 then
		object[p] = result2
	end

	if result then
		return result2
	end

	return nil
end

function CharacterPresentation.playFishingRodModelIdle(p)
	local fishingRodModelIdle = v.Animations.FishingRodModelIdle

	if not Anims:GetRaw(fishingRodModelIdle.Name) then
		return nil
	end

	local success, result = pcall(function()
		local v2 = Anims:Get(p, fishingRodModelIdle.Name)
		v2.Looped = fishingRodModelIdle.Looped
		v2.Priority = fishingRodModelIdle.Priority

		if fishingRodModelIdle.Speed ~= nil then
			v2:Play(fishingRodModelIdle.FadeTime, fishingRodModelIdle.Weight or 1, fishingRodModelIdle.Speed)
			return v2
		end

		if fishingRodModelIdle.Weight == nil then
			v2:Play(fishingRodModelIdle.FadeTime)
			return v2
		end

		v2:Play(fishingRodModelIdle.FadeTime, fishingRodModelIdle.Weight)
		return v2
	end)

	if success then
		return result
	end

	return nil
end

function CharacterPresentation.destroyFishingRod(instance)
	local v2 = object[instance]

	if v2 then
		pcall(function()
			v2:Stop(0.1)
		end)
		object[instance] = nil
	end

	local child = instance:FindFirstChild(v.FishingRodModelName)

	if child then
		child:Destroy()
	end

	return CharacterPresentation.playIdle(instance)
end

function CharacterPresentation.playStunFlinch(p)
	local stunFlinch = v.Animations.StunFlinch

	if not Anims:GetRaw(stunFlinch.Name) then
		return nil
	end

	local success, result = pcall(function()
		local v2 = Anims:Get(p, stunFlinch.Name)
		v2.Looped = stunFlinch.Looped
		v2.Priority = stunFlinch.Priority

		if stunFlinch.Speed ~= nil then
			v2:Play(stunFlinch.FadeTime, stunFlinch.Weight or 1, stunFlinch.Speed)
			return v2
		end

		if stunFlinch.Weight == nil then
			v2:Play(stunFlinch.FadeTime)
			return v2
		end

		v2:Play(stunFlinch.FadeTime, stunFlinch.Weight)
		return v2
	end)

	if success then
		return result
	end

	return nil
end

function CharacterPresentation.playScaredIdle(p)
	local scaredIdle = v.Animations.ScaredIdle

	if not Anims:GetRaw(scaredIdle.Name) then
		return nil
	end

	local success, result = pcall(function()
		local v2 = Anims:Get(p, scaredIdle.Name)
		v2.Looped = scaredIdle.Looped
		v2.Priority = scaredIdle.Priority

		if scaredIdle.Speed ~= nil then
			v2:Play(scaredIdle.FadeTime, scaredIdle.Weight or 1, scaredIdle.Speed)
			return v2
		end

		if scaredIdle.Weight == nil then
			v2:Play(scaredIdle.FadeTime)
			return v2
		end

		v2:Play(scaredIdle.FadeTime, scaredIdle.Weight)
		return v2
	end)

	if success then
		return result
	end

	return nil
end

function CharacterPresentation.playFishSlap(p)
	local fishSlap = v.Animations.FishSlap

	if not Anims:GetRaw(fishSlap.Name) then
		return nil
	end

	local success, result = pcall(function()
		local v2 = Anims:Get(p, fishSlap.Name)
		v2.Looped = fishSlap.Looped
		v2.Priority = fishSlap.Priority

		if fishSlap.Speed ~= nil then
			v2:Play(fishSlap.FadeTime, fishSlap.Weight or 1, fishSlap.Speed)
			return v2
		end

		if fishSlap.Weight == nil then
			v2:Play(fishSlap.FadeTime)
			return v2
		end

		v2:Play(fishSlap.FadeTime, fishSlap.Weight)
		return v2
	end)

	if success then
		return result
	end

	return nil
end

function CharacterPresentation.playSlapVictim(p)
	local slapVictim = v.Animations.SlapVictim

	if not Anims:GetRaw(slapVictim.Name) then
		return nil
	end

	local success, result = pcall(function()
		local v2 = Anims:Get(p, slapVictim.Name)
		v2.Looped = slapVictim.Looped
		v2.Priority = slapVictim.Priority

		if slapVictim.Speed ~= nil then
			v2:Play(slapVictim.FadeTime, slapVictim.Weight or 1, slapVictim.Speed)
			return v2
		end

		if slapVictim.Weight == nil then
			v2:Play(slapVictim.FadeTime)
			return v2
		end

		v2:Play(slapVictim.FadeTime, slapVictim.Weight)
		return v2
	end)

	if success then
		return result
	end

	return nil
end

function CharacterPresentation.playPirateIdle(p, p2: string)
	local raw = Anims:GetRaw(p2)

	if raw and raw:IsA("Animation") then
		return (pcall(function()
			local v2 = Anims:Get(p, p2)
			v2.Looped = true
			v2.Priority = Enum.AnimationPriority.Idle
			v2:Play(0.15)
		end))
	end

	return false
end

return CharacterPresentation