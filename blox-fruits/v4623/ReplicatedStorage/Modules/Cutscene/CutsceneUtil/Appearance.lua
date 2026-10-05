local Graphics = require(game.ReplicatedStorage.Util.Graphics)
require(script.Parent.Parent.Types)
local v = {}
local v2 = {}
local frozen = table.freeze({
	"HeadColor3",
	"LeftArmColor3",
	"LeftLegColor3",
	"RightArmColor3",
	"RightLegColor3",
	"TorsoColor3"
})
local frozen2 = table.freeze({
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
})

function v2.contentUrl(p: string)
	return Graphics.SmartScale(p)
end

function v2.findProxy(instance, childName: string)
	local stringValue = instance:FindFirstChild(childName)

	if stringValue and stringValue:IsA("StringValue") then
		return stringValue
	end

	return nil
end

function v2.ensureProxy(parent, name: string, p: string)
	local stringValue = parent:FindFirstChild(name)

	if stringValue and stringValue:IsA("StringValue") then
		return stringValue
	end

	if stringValue then
		stringValue:Destroy()
	end

	local stringValue2 = Instance.new("StringValue")
	stringValue2.Name = name
	stringValue2.Value = p
	stringValue2.Parent = parent
	return stringValue2
end

function v2.ensureClothing(parent, className: string)
	local firstChildWhichIsA = parent:FindFirstChildWhichIsA(className)

	if firstChildWhichIsA then
		return firstChildWhichIsA
	end

	local instance = Instance.new(className)
	instance.Parent = parent
	return instance
end

function v2.restoreClothing(p, p2: string)
	local proxy = v2.findProxy(p, (`Proxy_{p2}`))

	if not proxy then
		return
	end

	local clothing = v2.ensureClothing(p, p2)
	local v3 = p2 == "Shirt" and "ShirtTemplate" or "PantsTemplate"
	local attribute = proxy:GetAttribute(v3)
	local color3 = proxy:GetAttribute("Color3")

	if typeof(attribute) == "string" then
		clothing[v3] = v2.contentUrl(attribute)
	end

	if typeof(color3) == "Color3" then
		clothing.Color3 = color3
	end
end

function v2.setClothing(p, p2: string, p3: string?, color: Color3?)
	if p3 == nil and color == nil then
		return
	end

	local proxy = v2.ensureProxy(p, `Proxy_{p2}`, p2)
	local clothing = v2.ensureClothing(p, p2)
	local v3 = p2 == "Shirt" and "ShirtTemplate" or "PantsTemplate"

	if p3 then
		proxy:SetAttribute(v3, p3)
		clothing[v3] = v2.contentUrl(p3)
	end

	if color then
		proxy:SetAttribute("Color3", color)
		clothing.Color3 = color
	end
end

function v2.findFace(instance)
	local head = instance:FindFirstChild("Head", true)

	if not (head and head:IsA("BasePart")) then
		return nil
	end

	local face = head:FindFirstChild("face")

	if face and face:IsA("Decal") then
		return face
	end

	return head:FindFirstChildWhichIsA("Decal")
end

function v2.setFace(instance, faceId: string)
	instance:SetAttribute("FaceId", faceId)
	local face = v2.findFace(instance)

	if face then
		face.Texture = v2.contentUrl(faceId)
		return
	end

	local head = instance:FindFirstChild("Head", true)

	if not (head and head:IsA("BasePart")) then
		return
	end

	local decal = Instance.new("Decal")
	decal.Name = "face"
	decal.Face = Enum.NormalId.Front
	decal.Texture = v2.contentUrl(faceId)
	decal.Parent = head
end

function v2.toMeshType(value)
	if typeof(value) == "EnumItem" and value.EnumType == Enum.MeshType then
		return value
	end

	if typeof(value) == "string" then
		return Enum.MeshType[value]
	end

	return nil
end

function v2.applyMeshProperties(instance, p)
	local meshId = instance:GetAttribute("MeshId")
	local meshType = v2.toMeshType(instance:GetAttribute("MeshType"))
	local offset = instance:GetAttribute("Offset")
	local scale = instance:GetAttribute("Scale")
	local textureId = instance:GetAttribute("TextureId")
	local vertexColor = instance:GetAttribute("VertexColor")

	if typeof(meshId) == "string" then
		p.MeshId = meshId
	end

	if meshType then
		p.MeshType = meshType
	end

	if typeof(offset) == "Vector3" then
		p.Offset = offset
	end

	if typeof(scale) == "Vector3" then
		p.Scale = scale
	end

	if typeof(textureId) == "string" then
		p.TextureId = v2.contentUrl(textureId)
	end

	if typeof(vertexColor) == "Vector3" then
		p.VertexColor = vertexColor
	end
end

function v2.restoreAccessoryMeshes(folder)
	for _, descendant in folder:GetDescendants() do
		if descendant.Name ~= "Proxy_SpecialMesh" then
			continue
		end

		local specialMesh = descendant.Parent and descendant.Parent:FindFirstChildWhichIsA("SpecialMesh")

		if specialMesh then
			v2.applyMeshProperties(descendant, specialMesh)
		end
	end
end

function v2.findAccessoryName(p, p2)
	local parent = p.Parent

	while parent and parent ~= p2 do
		if parent:IsA("Accessory") or parent:IsA("Hat") then
			return parent.Name
		else
			parent = parent.Parent
		end
	end

	return nil
end

function v2.getMeshOverride(p, instance, p2)
	local accessoryName = v2.findAccessoryName(instance, p)
	local v3

	if instance.Parent then
		v3 = instance.Parent.Name
	end

	return p2[accessoryName or ""] or p2[instance.Name] or p2[v3 or ""] or p2["*"]
end

function v2.setMeshOverride(p, data)
	local v3 = assert(p.Parent)
	local proxy = v2.ensureProxy(v3, "Proxy_SpecialMesh", "SpecialMesh")

	if data.MeshId ~= nil then
		proxy:SetAttribute("MeshId", data.MeshId)
	end

	if data.MeshType ~= nil then
		proxy:SetAttribute("MeshType", data.MeshType.Name)
	end

	if data.Offset ~= nil then
		proxy:SetAttribute("Offset", data.Offset)
	end

	if data.Scale ~= nil then
		proxy:SetAttribute("Scale", data.Scale)
	end

	if data.TextureId ~= nil then
		proxy:SetAttribute("TextureId", data.TextureId)
	end

	if data.VertexColor ~= nil then
		proxy:SetAttribute("VertexColor", data.VertexColor)
	end

	v2.applyMeshProperties(proxy, p)
end

function v2.findBodyColors(instance)
	return instance:FindFirstChildWhichIsA("BodyColors")
end

function v2.ensureBodyColors(parent)
	local bodyColors = v2.findBodyColors(parent)

	if bodyColors then
		return bodyColors
	end

	local bodyColors2 = Instance.new("BodyColors")
	bodyColors2.Name = "Body Colors"
	bodyColors2.Parent = parent
	return bodyColors2
end

function v2.toColor3(p)
	if typeof(p) == "Color3" then
		return p
	end

	if typeof(p) == "BrickColor" then
		return p.Color
	end

	return nil
end

function v2.restoreBodyColors(instance)
	local v3 = v2.findProxy(instance, "Proxy_BodyColors") or v2.findProxy(instance, "Proxy_Body Colors")
	local color3sByAttributeName = {}

	for _, attributeName in frozen do
		local v4

		if v3 then
			v4 = v3:GetAttribute(attributeName)
		end

		local v5 = v4 or instance:GetAttribute(attributeName)
		local color3 = v2.toColor3(v5)

		if color3 then
			color3sByAttributeName[attributeName] = color3
		end
	end

	if next(color3sByAttributeName) == nil then
		return
	end

	local bodyColors = v2.ensureBodyColors(instance)

	for k, v4 in color3sByAttributeName do
		bodyColors[k] = v4
	end
end

function v2.setBodyColors(p, items)
	local bodyColors = v2.ensureBodyColors(p)
	local proxy = v2.ensureProxy(p, "Proxy_BodyColors", "BodyColors")

	for k, item in items do
		local color3 = v2.toColor3(item)

		if not (color3 and table.find(frozen, k)) then
			continue
		end

		proxy:SetAttribute(k, color3)
		bodyColors[k] = color3
	end
end

function v2.applyCompositeTexture(instance, compositeTextureId: string)
	instance:SetAttribute("CompositeTextureId", compositeTextureId)

	for _, part in instance:GetChildren() do
		if part:IsA("MeshPart") and frozen2[part.Name] then
			part.TextureID = v2.contentUrl(compositeTextureId)
		end
	end
end

function v.restore(instance)
	v2.restoreClothing(instance, "Shirt")
	v2.restoreClothing(instance, "Pants")
	local faceId = instance:GetAttribute("FaceId")

	if typeof(faceId) == "string" then
		v2.setFace(instance, faceId)
	end

	v2.restoreBodyColors(instance)
	v2.restoreAccessoryMeshes(instance)
	local compositeTextureId = instance:GetAttribute("CompositeTextureId")

	if typeof(compositeTextureId) == "string" and compositeTextureId ~= "" then
		v2.applyCompositeTexture(instance, compositeTextureId)
	end
end

function v.apply(folder, data)
	if data.Attributes then
		for k, attribute in data.Attributes do
			folder:SetAttribute(k, attribute)
		end

		v.restore(folder)
	end

	v2.setClothing(folder, "Shirt", data.ShirtTemplate, data.ShirtColor3)
	v2.setClothing(folder, "Pants", data.PantsTemplate, data.PantsColor3)

	if data.FaceId ~= nil then
		v2.setFace(folder, data.FaceId)
	end

	if data.BodyColors then
		v2.setBodyColors(folder, data.BodyColors)
	end

	if data.AccessoryMeshes then
		for _, specialMesh in folder:GetDescendants() do
			if not specialMesh:IsA("SpecialMesh") then
				continue
			end

			local meshOverride = v2.getMeshOverride(folder, specialMesh, data.AccessoryMeshes)

			if meshOverride then
				v2.setMeshOverride(specialMesh, meshOverride)
			end
		end
	end

	if data.CompositeTextureId ~= nil then
		v2.applyCompositeTexture(folder, data.CompositeTextureId)
	end
end

return table.freeze(v)