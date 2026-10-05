local ReplicatedStorage = game:GetService("ReplicatedStorage")
local assets = ReplicatedStorage:WaitForChild("Assets")
local HttpService = game:GetService("HttpService")
local MutationSkinService = {}
local object = setmetatable({}, {
	__mode = "k"
})
local v = {
	Seat = true,
	invisible_box = true,
	RootPart = true,
	HumanoidRootPart = true,
	InitialPoses = true,
	AnimSaves = true,
	MutationHitbox = true,
	SpawnMutationHitbox = true,
	RainbowOriginalSurfaces = true,
	OriginalSurfaceAppearance = true,
	MutationTextureOriginals = true
}

local function Eligible(instance, folder)
	local parent

	if instance:IsA("SpecialMesh") then
		parent = instance.Parent or instance
	else
		parent = instance
	end

	if not parent or not parent:IsA("BasePart") or parent.Transparency >= 1 then
		return false
	end

	local parent2 = instance

	while parent2 and parent2 ~= folder do
		if v[parent2.Name] then
			return false
		else
			parent2 = parent2.Parent
		end
	end

	return instance:IsA("BasePart") or instance:IsA("SpecialMesh")
end

local function Objects(folder)
	local descendants = { folder }

	for _, descendant in folder:GetDescendants() do
		table.insert(descendants, descendant)
	end

	return descendants
end

-- equivalent calls inferred from this helper; original call sites unknown
local function TextureProperty(instance)
	if instance:IsA("MeshPart") then
		return "TextureID"
	end

	if instance:IsA("SpecialMesh") then
		return "TextureId"
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function MeshId(instance)
	if instance:IsA("MeshPart") or instance:IsA("SpecialMesh") then
		return instance.MeshId:match("%d+") or instance.MeshId
	end

	return ""
end

local function Normalize(value)
	local match = tostring(value or ""):match("^%s*(.-)%s*$")

	if match:match("^%d+$") then
		match = "rbxassetid://" .. match or match
	end

	return match
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsAppearance(instance)
	return instance:IsA("SurfaceAppearance") or instance:IsA("Decal")
end

local function Restore(parent)
	local mutationTextureOriginals = parent:FindFirstChild("MutationTextureOriginals")

	if not mutationTextureOriginals then
		return
	end

	for _, child in parent:GetChildren() do
		if child:GetAttribute("MutationTextureApplied") then
			child:Destroy()
		end
	end

	for k, v2 in mutationTextureOriginals:GetAttributes() do
		if k == "Material" then
			v2 = Enum.Material[v2]
		end

		parent[k] = v2
	end

	for _, child in mutationTextureOriginals:GetChildren() do
		child.Parent = parent
	end

	mutationTextureOriginals:Destroy()
	parent:SetAttribute("MutationTextureApplied", nil)
end

local function Save(instance)
	local parent = instance:FindFirstChild("MutationTextureOriginals")

	if not parent then
		parent = Instance.new("Folder")
		parent.Name = "MutationTextureOriginals"
		local textureProperty = TextureProperty(instance) -- equivalent call inferred; original call site unknown

		if textureProperty then
			parent:SetAttribute(textureProperty, instance[textureProperty])
		end

		if instance:IsA("BasePart") then
			parent:SetAttribute("Color", instance.Color)
			parent:SetAttribute("Material", instance.Material.Name)
			parent:SetAttribute("MaterialVariant", instance.MaterialVariant)
			parent:SetAttribute("Reflectance", instance.Reflectance)
		elseif instance:IsA("SpecialMesh") then
			parent:SetAttribute("VertexColor", instance.VertexColor)
		end

		parent.Parent = instance
	end

	for _, child in instance:GetChildren() do
		if not IsAppearance(child) or child:GetAttribute("MutationTextureApplied") then
			continue
		end

		child.Parent = parent
	end

	return parent
end

local function Compatible(instance, instance2)
	local targetClass = instance:GetAttribute("TargetClass")

	if targetClass == instance2.ClassName then
		return true
	elseif targetClass == "MeshPart" or targetClass == "SpecialMesh" then
		return (instance2:IsA("MeshPart") and "TextureID" or instance2:IsA("SpecialMesh") and "TextureId" or nil) ~= nil
	else
		return false
	end
end

local function PathMatches(folder, parent, p)
	local targetPath = folder:GetAttribute("TargetPath")

	if not targetPath then
		return false
	end

	local success, result = pcall(HttpService.JSONDecode, HttpService, targetPath)

	if not success or type(result) ~= "table" then
		return false
	end

	for i = #result, 1, -1 do
		if not parent or parent == p or parent.Name ~= result[i].Name then
			return false
		end

		local ordinal = result[i].Ordinal or 1
		local count = 0

		for _, child in parent.Parent:GetChildren() do
			if not (child.Name == parent.Name and child.ClassName == parent.ClassName) then
				continue
			end

			count += 1

			if child == parent then
				break
			end
		end

		if count ~= ordinal then
			return false
		end

		parent = parent.Parent
	end

	return true
end

local function RecordFor(instance, instance2, folder)
	local v2 = nil
	local v3 = nil
	local v4 = nil

	for _, folder2 in instance:GetChildren() do
		if not (folder2:IsA("Folder") and folder2:GetAttribute("TargetClass")) then
			continue
		end

		local targetClass = folder2:GetAttribute("TargetClass")
		local v5

		if targetClass == instance2.ClassName then
			v5 = true
		elseif targetClass == "MeshPart" or targetClass == "SpecialMesh" then
			v5 = (instance2:IsA("MeshPart") and "TextureID" or instance2:IsA("SpecialMesh") and "TextureId" or nil) ~= nil
		else
			v5 = false
		end

		if not v5 then
			continue
		end

		local v6 = 0
		local targetMeshId = folder2:GetAttribute("TargetMeshId")

		if targetMeshId and targetMeshId ~= "" then
			local match = tostring(targetMeshId or ""):match("^%s*(.-)%s*$")

			if match:match("^%d+$") then
				match = "rbxassetid://" .. match or match
			end

			v6 = match:match("%d+") == MeshId(instance2) and 100 or v6
		end

		if PathMatches(folder2, instance2, folder) then
			v6 += 50
		end

		if instance2.Name == folder2:GetAttribute("TargetName") then
			v6 += 10
		end

		if not (v6 > 0) then
			continue
		end

		if v2 and not (v2 < v6) then
			if v6 == v2 then
				v4 = true
			end
		else
			v3 = folder2
			v2 = v6
			v4 = false
		end
	end

	if v3 and not v4 then
		return v3
	end

	if instance:GetAttribute("FormatVersion") then
		return nil
	end

	if (instance2:IsA("MeshPart") or instance2:IsA("SpecialMesh")) and (instance:FindFirstChild("TextureId") or instance:FindFirstChildWhichIsA("SurfaceAppearance")) then
		return instance
	end
end

function MutationSkinService.Get(childName, p)
	if type(childName) ~= "string" then
		return nil
	end

	local v2 = (p == "Gold" or p == "Golden") and "Golden" or p

	if type(v2) ~= "string" then
		return nil
	end

	local mutationTextures = assets:FindFirstChild("MutationTextures")
	local child = mutationTextures and mutationTextures:FindFirstChild(v2)
	return child and child:FindFirstChild(childName)
end

local function PetNameOf(instance, p)
	local petName = instance:GetAttribute("PetName") or instance.Name

	if MutationSkinService.Get(petName, p) then
		return petName
	end

	local match = petName:match("^(.+)Reveal$")

	if match and MutationSkinService.Get(match, p) then
		return match
	end

	return petName
end

local function Wear(instance, instance2, mutation)
	local v2 = mutation .. ":" .. instance2:GetFullName()

	if instance:GetAttribute("MutationTextureApplied") ~= v2 then
		Restore(instance)
	end

	Save(instance)

	if instance:GetAttribute("MutationTextureApplied") == v2 then
		return true
	end

	for _, child in instance:GetChildren() do
		if child:GetAttribute("MutationTextureApplied") then
			child:Destroy()
		end
	end

	local textureProperty = TextureProperty(instance) -- equivalent call inferred; original call site unknown
	local textureId = instance2:FindFirstChild("TextureId")

	if textureProperty then
		local v4

		if textureId and textureId:IsA("StringValue") then
			local match = tostring(textureId.Value or ""):match("^%s*(.-)%s*$")

			if match:match("^%d+$") then
				match = "rbxassetid://" .. match or match
			end

			v4 = match or ""
		else
			v4 = ""
		end

		instance[textureProperty] = v4
	end

	for _, attributeName in {
		"Color",
		"Material",
		"MaterialVariant",
		"Reflectance",
		"VertexColor"
	} do
		local attribute = instance2:GetAttribute(attributeName)

		if attribute == nil then
			continue
		end

		if attributeName == "Material" then
			attribute = Enum.Material[attribute]
		end

		if not (instance:IsA("BasePart") and attributeName ~= "VertexColor" or instance:IsA("SpecialMesh") and attributeName == "VertexColor") then
			continue
		end

		instance[attributeName] = attribute
	end

	for _, child in instance2:GetChildren() do
		if not IsAppearance(child) then
			continue
		end

		if child:IsA("SurfaceAppearance") and not instance:IsA("MeshPart") then
			if textureProperty and child.ColorMap ~= "" then
				instance[textureProperty] = child.ColorMap
			end
		else
			local clone = child:Clone()
			clone:SetAttribute("MutationTextureApplied", true)
			clone.Parent = instance
		end
	end

	instance:SetAttribute("MutationTextureApplied", v2)
	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Unwatch(p)
	local v2 = object[p]

	if v2 then
		for _, connection in v2.Connections do
			connection:Disconnect()
		end

		object[p] = nil
	end
end

function MutationSkinService.Apply(folder, mutation)
	if not folder then
		return false
	end

	local v2

	if mutation then
		local get = MutationSkinService.Get
		local petName = folder:GetAttribute("PetName") or folder.Name

		if not MutationSkinService.Get(petName, mutation) then
			local match = petName:match("^(.+)Reveal$")

			if match and MutationSkinService.Get(match, mutation) then
				petName = match
			end
		end

		v2 = get(petName, mutation)
	else
		v2 = mutation
	end

	local descendants = { folder }
	local v3 = false

	for _, descendant in folder:GetDescendants() do
		table.insert(descendants, descendant)
	end

	for _, instance in descendants do
		if instance:IsA("MeshPart") then
			local mutationSkinOriginalTextureID = instance:GetAttribute("MutationSkinOriginalTextureID")

			if mutationSkinOriginalTextureID ~= nil then
				instance.TextureID = mutationSkinOriginalTextureID
				instance:SetAttribute("MutationSkinOriginalTextureID", nil)
			end

			local originalSurfaceAppearance = instance:FindFirstChild("OriginalSurfaceAppearance")

			for _, surfaceAppearance in instance:GetChildren() do
				if surfaceAppearance:IsA("SurfaceAppearance") and surfaceAppearance:GetAttribute("MutationSkin") then
					surfaceAppearance:Destroy()
				end
			end

			if originalSurfaceAppearance then
				for _, child in originalSurfaceAppearance:GetChildren() do
					child.Parent = instance
				end

				originalSurfaceAppearance:Destroy()
			end
		end

		local v4 = v2 and Eligible(instance, folder) and RecordFor(v2, instance, folder)

		if v4 then
			v3 = Wear(instance, v4, mutation) or v3
		elseif instance:IsA("BasePart") or instance:IsA("SpecialMesh") then
			Restore(instance)
		end
	end

	if v2 then
		local v4 = object[folder]

		if not v4 then
			v4 = {
				Connections = {}
			}
			object[folder] = v4
			table.insert(v4.Connections, folder.DescendantAdded:Connect(function(instance)
				if not (instance:IsA("BasePart") or instance:IsA("SpecialMesh") or IsAppearance(instance)) or instance:GetAttribute("MutationTextureApplied") then
					return
				end

				local parent = instance.Parent

				while parent and parent ~= folder do
					if parent.Name == "MutationTextureOriginals" then
						return
					else
						parent = parent.Parent
					end
				end

				if v4.Pending then
					return
				end

				v4.Pending = true
				task.defer(function()
					v4.Pending = false

					if object[folder] == v4 then
						MutationSkinService.Apply(folder, v4.Mutation)
					end
				end)
			end))
			table.insert(v4.Connections, folder.Destroying:Connect(function()
				Unwatch(folder) -- equivalent call inferred; original call site unknown
			end))
		end

		v4.Mutation = mutation
		return v3
	else
		Unwatch(folder) -- equivalent call inferred; original call site unknown
		return false
	end
end

return MutationSkinService