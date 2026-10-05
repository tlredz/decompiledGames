local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartBounds = require(ReplicatedStorage.Shared.Utils.PartBounds)
local Checksum = require(ReplicatedStorage.Shared.Utils.Checksum)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local Log = require(ReplicatedStorage.Packages.Log)
local v = Log.new()
local t = require(ReplicatedStorage.Packages.t)
local palette2 = {
	Darker = Color3.fromRGB(216, 158, 0),
	Lighter = Color3.fromRGB(251, 255, 0)
}
local palette3 = {
	Darker = Color3.fromRGB(134, 134, 134),
	Lighter = Color3.fromRGB(192, 192, 192)
}
local palette4 = {
	Darker = Color3.fromRGB(25, 0, 38),
	Lighter = Color3.fromRGB(47, 0, 70)
}
local random = Random.new()
local v5 = nil
local Visuals = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getFxContainer(childName: string)
	local mutations = ReplicatedStorage:FindFirstChild("Mutations")
	assert(mutations, "Mutations folder is missing from ReplicatedStorage")
	local child = mutations:FindFirstChild(childName)
	assert(child, (`Mutation FX container "{childName}" not found in Mutations`))
	return child
end

local function shouldSkipColoring(instance)
	return instance:GetAttribute("MutationsDontModify") == true or instance:GetAttribute("DontAddTexture") == true or instance:GetAttribute("IsEye") == true or instance:GetAttribute("MutationFXDontRender") == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureUnionUsePartColor(part)
	if not part:IsA("UnionOperation") then
		return
	end

	if part:GetAttribute("Cleanup_OriginalUserPartColor") == nil then
		part:SetAttribute("Cleanup_OriginalUserPartColor", part.UsePartColor)
	end

	part.UsePartColor = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreUnionUsePartColor(part)
	if not part:IsA("UnionOperation") then
		return
	end

	local cleanup_OriginalUserPartColor = part:GetAttribute("Cleanup_OriginalUserPartColor")

	if typeof(cleanup_OriginalUserPartColor) ~= "boolean" then
		return
	end

	part.UsePartColor = cleanup_OriginalUserPartColor
	part:SetAttribute("Cleanup_OriginalUserPartColor", nil)
end

local function rollColor(object, p)
	return p.Darker:Lerp(p.Lighter, object:NextNumber())
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyPaletteColor(descendant, palette)
	ensureUnionUsePartColor(descendant) -- equivalent call inferred; original call site unknown
	local v6 = v5 or random
	descendant.Color = palette.Darker:Lerp(palette.Lighter, v6:NextNumber())
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getMaterialByName(attribute: string)
	for _, v6 in Enum.Material:GetEnumItems() do
		if v6.Name == attribute then
			return v6
		end
	end

	return nil
end

local function getStoredOriginalMaterial(part)
	for _, attributeName in { "Mutation_OriginalMaterial", "OriginalMaterial", "Original_Material" } do
		local attribute = part:GetAttribute(attributeName)

		if typeof(attribute) == "string" then
			local materialByName = getMaterialByName(attribute) -- equivalent call inferred; original call site unknown

			if materialByName then
				return materialByName
			end
		elseif typeof(attribute) == "EnumItem" and attribute.EnumType == Enum.Material then
			return attribute
		end
	end

	return nil
end

local function getStoredOriginalMaterialVariant(instance)
	local mutation_OriginalMaterialVariant = instance:GetAttribute("Mutation_OriginalMaterialVariant")

	if typeof(mutation_OriginalMaterialVariant) == "string" then
		return mutation_OriginalMaterialVariant
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setAndSaveMaterial(descendant, plastic)
	if not descendant:GetAttribute("Mutation_OriginalMaterial") then
		descendant:SetAttribute("Mutation_OriginalMaterial", descendant.Material.Name)
	end

	descendant.Material = plastic
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setAndSaveMaterialVariant(instance, materialVariant: string)
	if not instance:GetAttribute("Mutation_OriginalMaterialVariant") then
		instance:SetAttribute("Mutation_OriginalMaterialVariant", instance.MaterialVariant)
	end

	instance.MaterialVariant = materialVariant
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hasMetalVisual(instance)
	return instance:HasTag("GoldenVisual") or instance:HasTag("SilverVisual")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setMetalMaterialVariant(instance)
	setAndSaveMaterialVariant(instance, "StudsMetallic") -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPartVolume(p)
	local size = p.Size
	return size.X * size.Y * size.Z
end

local function collectMetalSizeGroups(folder)
	local parts = {}

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") or not (part.Transparency < 1) or part:HasTag("Effect") or part:GetAttribute("MutationsDontModify") == true then
			continue
		end

		if not (part:GetAttribute("DontAddTexture") ~= true and part:GetAttribute("IsEye") ~= true and part:GetAttribute("MutationFXDontRender") ~= true) then
			continue
		end

		table.insert(parts, part)
	end

	table.sort(parts, function(a, b)
		local partVolume = getPartVolume(a) -- equivalent call inferred; original call site unknown
		return getPartVolume(b) < partVolume
	end)
	local result = {}
	local total = 0

	for _, v6 in parts do
		local partVolume = getPartVolume(v6) -- equivalent call inferred; original call site unknown
		local v7 = result[#result]

		if v7 and math.abs(v7.PartVolume - partVolume) <= 0.001 then
			table.insert(v7.Parts, v6)
			v7.Weight += partVolume
		else
			table.insert(result, {
				Parts = { v6 },
				PartVolume = partVolume,
				Weight = partVolume
			})
		end

		total += partVolume
	end

	table.sort(result, function(a, b)
		return a.Weight > b.Weight
	end)
	return result, total
end

local function getSilverComboParts(folder, p: number)
	local v6, v7 = collectMetalSizeGroups(folder)
	local random2 = Random.new(Visuals.SeedFor(p, "GoldenSilverPartition"))
	local v8 = v7 / 2
	local v9 = v7 / 2
	local result = {}

	for _, v10 in v6 do
		local v11

		if math.abs(v8 - v9) <= 0.001 then
			v11 = random2:NextNumber() < 0.5
		else
			v11 = v9 < v8
		end

		if v11 then
			for _, part in v10.Parts do
				result[part] = true
			end

			v8 -= v10.Weight
		else
			v9 -= v10.Weight
		end
	end

	return result
end

local function getNamedSurfaceAppearance(folder, p: string)
	local v6 = nil

	for _, surfaceAppearance in folder:GetDescendants() do
		if not (surfaceAppearance:IsA("SurfaceAppearance") and surfaceAppearance.Name == p) then
			continue
		end

		assert(v6 == nil, (`{folder:GetFullName()} contains multiple {p} SurfaceAppearances`))
		v6 = surfaceAppearance
	end

	assert(v6 ~= nil, (`{folder:GetFullName()} must contain a {p} SurfaceAppearance`))
	return v6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getTextureOverrideVisualModel(instance)
	if instance.Name == "Model" then
		return instance
	end

	local model = instance:FindFirstChild("Model")
	local v6

	if model == nil then
		v6 = false
	else
		v6 = model:IsA("Model")
	end

	assert(v6, (`{instance:GetFullName()} enables TexturesOverride but has no direct Model child`))
	return model
end

local function getOriginalSurfaceAppearance(folder, meshPart, namedSurfaceAppearance, namedSurfaceAppearance2, namedSurfaceAppearance3)
	local v6 = nil

	for _, surfaceAppearance in folder:GetDescendants() do
		if not (surfaceAppearance:IsA("SurfaceAppearance") and surfaceAppearance:GetAttribute("Mutation_OriginalSurfaceAppearance") == true) then
			continue
		end

		assert(v6 == nil, (`{folder:GetFullName()} contains multiple original SurfaceAppearances`))
		v6 = surfaceAppearance
	end

	if v6 == nil then
		for _, surfaceAppearance in meshPart:GetChildren() do
			if not (surfaceAppearance:IsA("SurfaceAppearance") and surfaceAppearance ~= namedSurfaceAppearance and surfaceAppearance ~= namedSurfaceAppearance2 and surfaceAppearance ~= namedSurfaceAppearance3) then
				continue
			end

			assert(v6 == nil, (`{meshPart:GetFullName()} contains multiple original SurfaceAppearances`))
			v6 = surfaceAppearance
		end
	end

	assert(v6 ~= nil, (`{meshPart:GetFullName()} must contain its original SurfaceAppearance`))
	v6:SetAttribute("Mutation_OriginalSurfaceAppearance", true)
	return v6
end

local function getTextureOverrideBindings(model)
	local models = {}

	if model:IsA("Model") and model:GetAttribute("TexturesOverride") == true then
		table.insert(models, model)
	end

	for _, model2 in model:GetDescendants() do
		if model2:IsA("Model") and model2:GetAttribute("TexturesOverride") == true then
			table.insert(models, model2)
		end
	end

	if #models == 0 then
		return nil
	end

	local v6 = {}
	local result = {}

	for _, v7 in models do
		local textureOverrideVisualModel = getTextureOverrideVisualModel(v7) -- equivalent call inferred; original call site unknown

		if v6[textureOverrideVisualModel] then
			continue
		end

		v6[textureOverrideVisualModel] = true
		local meshPart = textureOverrideVisualModel:FindFirstChildWhichIsA("MeshPart", true)
		assert(
			meshPart ~= nil,
			(`{textureOverrideVisualModel:GetFullName()} must contain a MeshPart for texture overrides`)
		)
		local namedSurfaceAppearance = getNamedSurfaceAppearance(textureOverrideVisualModel, "GoldTextureOverride")
		local namedSurfaceAppearance2 = getNamedSurfaceAppearance(textureOverrideVisualModel, "SilverTextureOverride")
		local namedSurfaceAppearance3 = getNamedSurfaceAppearance(
			textureOverrideVisualModel,
			"GoldSilverTextureOverride"
		)
		table.insert(result, {
			VisualModel = textureOverrideVisualModel,
			TargetMesh = meshPart,
			Original = getOriginalSurfaceAppearance(
				textureOverrideVisualModel,
				meshPart,
				namedSurfaceAppearance,
				namedSurfaceAppearance2,
				namedSurfaceAppearance3
			),
			Golden = namedSurfaceAppearance,
			Silver = namedSurfaceAppearance2,
			GoldenSilver = namedSurfaceAppearance3
		})
	end

	assert(#result > 0, (`{model:GetFullName()} enables TexturesOverride but has no texture override bindings`))
	return result
end

local function getActiveSurfaceAppearance(p)
	local v6 = nil

	for _, surfaceAppearance in p.TargetMesh:GetChildren() do
		if not surfaceAppearance:IsA("SurfaceAppearance") then
			continue
		end

		assert(v6 == nil, (`{p.TargetMesh:GetFullName()} contains multiple active SurfaceAppearances`))
		v6 = surfaceAppearance
	end

	assert(v6 ~= nil, (`{p.TargetMesh:GetFullName()} must contain one active SurfaceAppearance`))
	return v6
end

local function setActiveSurfaceAppearance(p, instance)
	local activeSurfaceAppearance = getActiveSurfaceAppearance(p)

	if activeSurfaceAppearance == instance then
		return
	end

	local hasTag = activeSurfaceAppearance:HasTag("Cleanup_Rainbow")

	if hasTag then
		activeSurfaceAppearance:RemoveTag("RainbowPart")
		activeSurfaceAppearance:RemoveTag("Cleanup_Rainbow")
	end

	activeSurfaceAppearance.Parent = p.VisualModel
	instance.Parent = p.TargetMesh

	if hasTag then
		instance:AddTag("RainbowPart")
		instance:AddTag("Cleanup_Rainbow")
	end
end

local function applyMetalTextureOverride(textureOverrideBindings, selectAppearance, visualTag: string?, appearanceColor: Color3?)
	for _, item in textureOverrideBindings do
		local v6 = selectAppearance(item)

		if visualTag ~= nil then
			v6:AddTag(visualTag)
		end

		if appearanceColor ~= nil then
			if v6:GetAttribute("Metal_OriginalSurfaceColor") == nil then
				v6:SetAttribute("Metal_OriginalSurfaceColor", v6.Color)
			end

			v6.Color = appearanceColor
		end

		setActiveSurfaceAppearance(item, v6)
	end
end

local function removeMetalTextureOverride(textureOverrideBindings, selectAppearance, selectPartnerAppearance, visualTag: string, partnerVisualTag: string)
	for _, item in textureOverrideBindings do
		local v6 = selectAppearance(item)

		if not v6:HasTag(visualTag) then
			continue
		end

		v6:RemoveTag(visualTag)
		local metal_OriginalSurfaceColor = v6:GetAttribute("Metal_OriginalSurfaceColor")

		if typeof(metal_OriginalSurfaceColor) == "Color3" then
			v6.Color = metal_OriginalSurfaceColor
			v6:SetAttribute("Metal_OriginalSurfaceColor", nil)
		end

		local v7 = selectPartnerAppearance(item)

		if v7:HasTag(partnerVisualTag) then
			setActiveSurfaceAppearance(item, v7)
		else
			setActiveSurfaceAppearance(item, item.Original)
		end
	end
end

local function hasVisualTag(folder, tag: string)
	for _, descendant in folder:GetDescendants() do
		if descendant:HasTag(tag) then
			return true
		end
	end

	return false
end

local function getStoredOriginalColor(instance)
	local originalColor = instance:GetAttribute("OriginalColor")

	if typeof(originalColor) == "Color3" then
		return originalColor
	end

	return nil
end

local function cloneFxInto(parent, childName: string, tag: string, flag: boolean?)
	t.strict(t.instanceIsA("BasePart"))(parent)
	t.strict(t.string)(childName)
	t.strict(t.string)(tag)
	local fxContainer = getFxContainer(childName) -- equivalent call inferred; original call site unknown

	for _, child in fxContainer:GetChildren() do
		local clone = child:Clone()
		clone.Parent = parent

		if flag then
			clone.Enabled = true
		end

		clone:AddTag(tag)
		clone:AddTag("Effect")
	end
end

local function destroyTagged(folder, tag: string, flag: boolean?)
	local v6

	if flag then
		v6 = folder:GetDescendants()
	else
		v6 = folder:GetChildren()
	end

	for _, v7 in v6 do
		if v7:HasTag(tag) then
			v7:Destroy()
		end
	end
end

local v6 = {
	FxFolder = "Golden",
	CleanupTag = "Cleanup_GoldenFX",
	VisualTag = "GoldenVisual",
	PartnerVisualTag = "SilverVisual",
	Palette = palette2,
	AppearanceColor = nil,
	SelectAppearance = function(p)
		return p.Golden
	end,
	SelectPartnerAppearance = function(p)
		return p.Silver
	end
}
local v7 = {
	FxFolder = "Silver",
	CleanupTag = "Cleanup_SilverFX",
	VisualTag = "SilverVisual",
	PartnerVisualTag = "GoldenVisual",
	Palette = palette3,
	AppearanceColor = nil,
	SelectAppearance = function(p)
		return p.Silver
	end,
	SelectPartnerAppearance = function(p)
		return p.Golden
	end
}
local v8 = {
	FxFolder = "Golden",
	CleanupTag = "Cleanup_BlackFX",
	VisualTag = "BlackVisual",
	PartnerVisualTag = "GoldenVisual",
	Palette = palette4,
	AppearanceColor = palette4.Lighter,
	SelectAppearance = function(p)
		return p.Golden
	end,
	SelectPartnerAppearance = function(p)
		return p.Golden
	end
}

local function clearMetal(folder, p, data)
	if p then
		destroyTagged(p, data.CleanupTag)
	end

	local textureOverrideBindings = getTextureOverrideBindings(folder)

	if textureOverrideBindings ~= nil then
		removeMetalTextureOverride(
			textureOverrideBindings,
			data.SelectAppearance,
			data.SelectPartnerAppearance,
			data.VisualTag,
			data.PartnerVisualTag
		)
		return
	end

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part:HasTag(data.VisualTag)) then
			continue
		end

		part:RemoveTag(data.VisualTag)
		local mutation_OriginalColor = part:GetAttribute("Mutation_OriginalColor")

		if typeof(mutation_OriginalColor) == "Color3" then
			part.Color = mutation_OriginalColor
		end

		local storedOriginalMaterial = getStoredOriginalMaterial(part)

		if storedOriginalMaterial then
			part.Material = storedOriginalMaterial
		end

		local mutation_OriginalMaterialVariant = part:GetAttribute("Mutation_OriginalMaterialVariant")

		if typeof(mutation_OriginalMaterialVariant) ~= "string" then
			mutation_OriginalMaterialVariant = nil
		end

		if mutation_OriginalMaterialVariant then
			part.MaterialVariant = mutation_OriginalMaterialVariant
		end

		restoreUnionUsePartColor(part) -- equivalent call inferred; original call site unknown
	end
end

local function applyMetal(folder, parent2, data, childName: string?, p2: string?)
	clearMetal(folder, parent2, data)

	if parent2 then
		cloneFxInto(parent2, data.FxFolder, data.CleanupTag)
	end

	local textureOverrideBindings = getTextureOverrideBindings(folder)

	if textureOverrideBindings ~= nil then
		applyMetalTextureOverride(textureOverrideBindings, data.SelectAppearance, data.VisualTag, data.AppearanceColor)
		return
	end

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") and not descendant:HasTag("Effect") and descendant:GetAttribute("MutationsDontModify") ~= true and descendant:GetAttribute("DontAddTexture") ~= true and descendant:GetAttribute("IsEye") ~= true and descendant:GetAttribute("MutationFXDontRender") ~= true then
			applyPaletteColor(descendant, data.Palette) -- equivalent call inferred; original call site unknown
			setAndSaveMaterial(descendant, Enum.Material.Plastic)
			setMetalMaterialVariant(descendant) -- equivalent call inferred; original call site unknown
			descendant:AddTag(data.VisualTag)

			if descendant:IsA("MeshPart") then
				descendant.TextureID = ""
			end
		elseif descendant:IsA("SurfaceAppearance") then
			local parent = descendant.Parent

			if parent and parent:GetAttribute("MutationsDontModify") ~= true and parent:GetAttribute("DontAddTexture") ~= true and parent:GetAttribute("IsEye") ~= true and parent:GetAttribute("MutationFXDontRender") ~= true then
				descendant:Destroy()
			end
		end
	end

	if parent2 and childName and p2 then
		local mutations = ReplicatedStorage:FindFirstChild("Mutations")

		if mutations and mutations:FindFirstChild(childName) then
			cloneFxInto(parent2, childName, p2, true)
		end
	end
end

local function tintModel(folder, color: Color3, p: number)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") or part:HasTag("NoTint") then
			continue
		end

		local originalColor = part:GetAttribute("OriginalColor")

		if typeof(originalColor) ~= "Color3" then
			originalColor = nil
		end

		if not originalColor then
			part:SetAttribute("OriginalColor", part.Color)
		end

		part.Color = (originalColor or part.Color):Lerp(color, p)
		local surfaceAppearance = part:FindFirstChildOfClass("SurfaceAppearance")

		if surfaceAppearance then
			if surfaceAppearance:GetAttribute("Tint_OriginalSurfaceColor") == nil then
				surfaceAppearance:SetAttribute("Tint_OriginalSurfaceColor", surfaceAppearance.Color)
			end

			surfaceAppearance.Color = color
		elseif part:IsA("MeshPart") and part.TextureID ~= "" then
			part:SetAttribute("Tint_OriginalTextureId", part.TextureID)
			part.TextureID = ""
		end
	end
end

local function clearTint(folder)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") or part:HasTag("NoTint") then
			continue
		end

		local originalColor = part:GetAttribute("OriginalColor")

		if typeof(originalColor) ~= "Color3" then
			originalColor = nil
		end

		if originalColor then
			part:SetAttribute("OriginalColor", nil)
			part.Color = originalColor
		end

		local surfaceAppearance = part:FindFirstChildOfClass("SurfaceAppearance")
		local tint_OriginalSurfaceColor

		if surfaceAppearance then
			tint_OriginalSurfaceColor = surfaceAppearance:GetAttribute("Tint_OriginalSurfaceColor")
		end

		if surfaceAppearance and typeof(tint_OriginalSurfaceColor) == "Color3" then
			surfaceAppearance.Color = tint_OriginalSurfaceColor
			surfaceAppearance:SetAttribute("Tint_OriginalSurfaceColor", nil)
		end

		local tint_OriginalTextureId = part:GetAttribute("Tint_OriginalTextureId")

		if not (part:IsA("MeshPart") and typeof(tint_OriginalTextureId) == "string") then
			continue
		end

		part.TextureID = tint_OriginalTextureId
		part:SetAttribute("Tint_OriginalTextureId", nil)
	end
end

function Visuals.SeedFor(p: number, p2: string)
	return (math.max(Checksum.PathSeed("MutationVisual", p, p2) % 2147483647, 1))
end

function Visuals.WithVisualRandom(p, callback)
	local v9 = v5

	if p ~= nil then
		v5 = p
	end

	local success, result = pcall(callback)
	v5 = v9

	if not success then
		error(result, 0)
	end
end

function Visuals.GetFXPart(folder)
	if not folder then
		warn("Mutations.Visuals.GetFXPart | No item given")
		return nil
	end

	local fXPart = folder:FindFirstChild("FXPart")

	if fXPart and fXPart:IsA("BasePart") then
		return fXPart
	end

	local handle = nil

	if folder:IsA("Tool") then
		handle = folder:FindFirstChild("Handle") or folder:FindFirstChild("Segment1")
	elseif folder:IsA("Model") then
		handle = folder.PrimaryPart
	end

	if handle then
		local parts = {}

		for _, part in ipairs(folder:GetDescendants()) do
			if not (part:IsA("BasePart") and part.Transparency < 1 and part:GetAttribute("MutationFXDontRender") ~= true) then
				continue
			end

			table.insert(parts, part)
		end

		local boundingBox, size

		if #parts > 0 then
			boundingBox, size = PartBounds(parts)
		else
			boundingBox, size = folder:GetBoundingBox()
		end

		local part = Instance.new("Part")
		part.Name = "FXPart"
		part.CFrame = boundingBox
		part.Size = size
		part.Transparency = 1
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Anchored = false
		part.Massless = true
		part.Parent = folder
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = part
		weldConstraint.Part1 = handle
		weldConstraint.Parent = part
		return part
	else
		local formatted = `Mutations.Visuals.GetFXPart | No primary part found for item '{folder.Name}'`

		if Constants.IS_STUDIO then
			error(formatted)
		else
			v:AtError():Log(formatted)
		end

		return nil
	end
end

function Visuals.ApplyGolden(p, p2)
	applyMetal(p, p2, v6)
end

function Visuals.ClearGolden(p, p2)
	clearMetal(p, p2, v6)
end

function Visuals.ApplyBlack(p, parent, p3: string?, p4: string?)
	applyMetal(p, parent, v8, p3, p4)
end

function Visuals.ClearBlack(p, p2)
	clearMetal(p, p2, v8)
end

function Visuals.ApplySilver(p, p2)
	applyMetal(p, p2, v7)
end

function Visuals.ClearSilver(p, p2)
	clearMetal(p, p2, v7)
end

function Visuals.ShouldApplyMetalCombo(folder, p: string)
	if p == "Golden" then
		for _, descendant in folder:GetDescendants() do
			if descendant:HasTag("SilverVisual") then
				return true
			end
		end
	else
		if p ~= "Silver" then
			return false
		end

		for _, descendant in folder:GetDescendants() do
			if descendant:HasTag("GoldenVisual") then
				return true
			end
		end
	end

	return false
end

function Visuals.ApplyMetalCombo(folder, p: number)
	local textureOverrideBindings = getTextureOverrideBindings(folder)

	if textureOverrideBindings == nil then
		local silverComboParts = getSilverComboParts(folder, p)
		local random2 = Random.new(Visuals.SeedFor(p, v6.FxFolder))
		local random3 = Random.new(Visuals.SeedFor(p, v7.FxFolder))

		for _, part in folder:GetDescendants() do
			if not part:IsA("BasePart") or part:HasTag("Effect") or part:GetAttribute("MutationsDontModify") == true or part:GetAttribute("DontAddTexture") == true then
				continue
			end

			if not (part:GetAttribute("IsEye") ~= true and part:GetAttribute("MutationFXDontRender") ~= true) then
				continue
			end

			ensureUnionUsePartColor(part) -- equivalent call inferred; original call site unknown
			local color

			if silverComboParts[part] then
				local palette = palette3
				color = palette.Darker:Lerp(palette.Lighter, random3:NextNumber())
			else
				local palette = palette2
				color = palette.Darker:Lerp(palette.Lighter, random2:NextNumber())
			end

			part.Color = color
		end
	else
		for _, textureOverrideBinding in textureOverrideBindings do
			setActiveSurfaceAppearance(textureOverrideBinding, textureOverrideBinding.GoldenSilver)
		end
	end
end

function Visuals.ApplyRainbow(folder, p)
	Visuals.ClearRainbow(folder, p)

	if p then
		cloneFxInto(p, "Rainbow", "Cleanup_RainbowFX")
	end

	local textureOverrideBindings = getTextureOverrideBindings(folder)

	if textureOverrideBindings == nil then
		for _, part in folder:GetDescendants() do
			if not (part:IsA("BasePart") and part:GetAttribute("DontAddTexture") ~= true) then
				continue
			end

			ensureUnionUsePartColor(part) -- equivalent call inferred; original call site unknown
			part:AddTag("RainbowPart")
			part:AddTag("Cleanup_Rainbow")

			if not hasMetalVisual(part) then
				continue
			end

			setMetalMaterialVariant(part) -- equivalent call inferred; original call site unknown
		end
	else
		for _, textureOverrideBinding in textureOverrideBindings do
			local activeSurfaceAppearance = getActiveSurfaceAppearance(textureOverrideBinding)
			activeSurfaceAppearance:AddTag("RainbowPart")
			activeSurfaceAppearance:AddTag("Cleanup_Rainbow")
		end
	end
end

function Visuals.ClearRainbow(folder, p)
	if p then
		destroyTagged(p, "Cleanup_RainbowFX")
	end

	local textureOverrideBindings = getTextureOverrideBindings(folder)

	if textureOverrideBindings == nil then
		for _, part in folder:GetDescendants() do
			if not (part:IsA("BasePart") and part:HasTag("Cleanup_Rainbow")) then
				continue
			end

			restoreUnionUsePartColor(part) -- equivalent call inferred; original call site unknown
			part:RemoveTag("RainbowPart")
			part:RemoveTag("Cleanup_Rainbow")

			if not hasMetalVisual(part) then
				continue
			end

			setMetalMaterialVariant(part) -- equivalent call inferred; original call site unknown
		end
	else
		for _, textureOverrideBinding in textureOverrideBindings do
			for _, v9 in {
				textureOverrideBinding.Original,
				textureOverrideBinding.Golden,
				textureOverrideBinding.Silver,
				textureOverrideBinding.GoldenSilver
			} do
				if not v9:HasTag("Cleanup_Rainbow") then
					continue
				end

				v9:RemoveTag("RainbowPart")
				v9:RemoveTag("Cleanup_Rainbow")
			end
		end
	end
end

function Visuals.ApplyTint(p, color: Color3, p2: number)
	tintModel(p, color, p2)
end

function Visuals.ClearTint(p)
	clearTint(p)
end

function Visuals.ApplyBloom(p, parent, childName: string, p3: string, color: Color3, value: number?)
	Visuals.ClearBloom(p, parent, p3)

	if parent then
		local mutations = ReplicatedStorage:FindFirstChild("Mutations")

		if mutations and mutations:FindFirstChild(childName) then
			cloneFxInto(parent, childName, p3, true)
		end
	end

	tintModel(p, color, value or 0.65)
end

function Visuals.ClearBloom(p, p2, p3: string)
	clearTint(p)

	if p2 then
		destroyTagged(p2, p3, true)
	end

	destroyTagged(p, p3, true)
end

return Visuals