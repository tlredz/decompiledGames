local InsertService = game:GetService("InsertService")
local ReflectionService = game:GetService("ReflectionService")
local CollectionService = game:GetService("CollectionService")
local v = {
	WorldAxis = true,
	WorldSecondaryAxis = true,
	WorldPosition = true,
	WorldOrientation = true,
	WorldCFrame = true,
	TransformedWorldCFrame = true,
	BrickColor = true,
	MeshContent = true
}
local v2 = {
	["MeshPart.MeshId"] = true,
	["MeshPart.CollisionFidelity"] = true,
	["MeshPart.RenderFidelity"] = true
}
local InstanceSerializer = {}

local function canRead(p)
	return p ~= nil
end

local function canWrite(p)
	return p ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hasToReference(instance)
	return instance:IsA("MeshPart") and (instance.DoubleSided or instance.HasSkinnedMesh) or instance:IsA("SurfaceAppearance")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isPropertyModified(instance, name: string)
	local success, result = pcall(instance.IsPropertyModified, instance, name)
	return success and result
end

local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function resetPlanClear(p: string)
	local v7 = v5[p]

	if v7 then
		task.cancel(v7)
	end

	v5[p] = task.delay(300, function()
		v5[p] = nil
		v3[p] = nil
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resetMeshClear(p: string)
	local v7 = v6[p]

	if v7 then
		task.cancel(v7)
	end

	v6[p] = task.delay(300, function()
		v6[p] = nil
		local v8 = v4[p]

		if v8 then
			v8:Destroy()
			v4[p] = nil
		end
	end)
end

local function getClassPlan(p: string)
	local v7 = v3[p]

	if v7 then
		return v7
	end

	local byName = {}
	local candidates = {}

	for _, v10 in ReflectionService:GetPropertiesOfClass(p) do
		byName[v10.Name] = v10

		if v10.Permits.Read == nil or v[v10.Name] then
			continue
		end

		table.insert(candidates, {
			name = v10.Name,
			writable = v10.Permits.Write ~= nil or v2[`{p}.{v10.Name}`] == true
		})
	end

	local v10 = {
		candidates = candidates,
		byName = byName
	}
	v3[p] = v10
	resetPlanClear(p) -- equivalent call inferred; original call site unknown
	return v10
end

function InstanceSerializer.clearReflectionCache()
	for _, v7 in v5 do
		task.cancel(v7)
	end

	table.clear(v5)
	table.clear(v3)
end

function InstanceSerializer.getChangedProperties(instance)
	local result = {}

	for _, candidate in getClassPlan(instance.ClassName).candidates do
		if not isPropertyModified(instance, candidate.name) then
			continue
		end

		if not candidate.writable then
			error((`Can't set modified property {instance.ClassName}.{candidate.name}`))
		end

		result[candidate.name] = instance[candidate.name]
	end

	return result
end

function InstanceSerializer.getProperties(p: string)
	return getClassPlan(p).byName
end

-- equivalent calls inferred from this helper; original call sites unknown
local function generateId(p)
	p.IdCounter += 1
	return string.format("%X", p.IdCounter)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function useReference(rawSerialize, data)
	if rawSerialize.Id then
		return rawSerialize.Id
	end

	local id = generateId(data) -- equivalent call inferred; original call site unknown
	rawSerialize.Id = id
	return id
end

function InstanceSerializer.rawSerialize(instance, data)
	local reference = data.References[instance]

	if reference then
		return reference
	end

	local v7 = {}
	data.References[instance] = v7

	if hasToReference(instance) then
		local v8 = generateId(data) -- equivalent call inferred; original call site unknown
		v7.IsRaw = true
		v7.Id = v8
		v7.Properties = {
			Name = instance.Name
		}
		local instance2 = Instance.fromExisting(instance)
		instance2.Name = v8
		data.CarryInstances[v8] = instance2
	else
		local tags = CollectionService:GetTags(instance)
		local attributes = instance:GetAttributes()
		v7.ClassName = instance.ClassName
		v7.Tags = next(tags) and tags
		v7.Attributes = next(attributes) and attributes
		local changedProperties = InstanceSerializer.getChangedProperties(instance)

		for k, changedProperty in changedProperties do
			if not (typeof(changedProperty) == "Instance" and (k ~= "Parent" or instance ~= data.Main)) then
				continue
			end

			assert(
				changedProperty:IsDescendantOf(data.Main) or changedProperty == data.Main,
				(`Instance referenced at property isn't inside main instance: {instance:GetFullName()}.{k}`)
			)
			local v8 = useReference(InstanceSerializer.rawSerialize(changedProperty, data), data) -- equivalent call inferred; original call site unknown
			changedProperties[k] = v8
		end

		v7.Properties = changedProperties
	end

	local children = {}

	for _, child in instance:GetChildren() do
		table.insert(children, InstanceSerializer.rawSerialize(child, data))
	end

	v7.Children = children
	return v7
end

function InstanceSerializer.serialize(main)
	local v7 = {
		Main = main,
		IdCounter = 0,
		References = {},
		CarryInstances = {}
	}
	return InstanceSerializer.rawSerialize(main, v7), v7.CarryInstances
end

local function meshKeyOf(data)
	local meshId = data.MeshId or data.MeshContent and data.MeshContent.Uri

	if not meshId then
		return nil, nil
	end

	local collisionFidelity = data.CollisionFidelity or Enum.CollisionFidelity.Default
	local renderFidelity = data.RenderFidelity or Enum.RenderFidelity.Automatic
	return `{meshId}|{tostring(collisionFidelity)}|{tostring(renderFidelity)}`, meshId
end

local function createMeshPart(properties)
	local meshId = properties.MeshId or properties.MeshContent and properties.MeshContent.Uri
	local v7

	if meshId then
		local collisionFidelity = properties.CollisionFidelity or Enum.CollisionFidelity.Default
		local renderFidelity = properties.RenderFidelity or Enum.RenderFidelity.Automatic
		v7 = `{meshId}|{tostring(collisionFidelity)}|{tostring(renderFidelity)}`
	else
		meshId = nil
	end

	assert(v7 and meshId, "createMeshPart called without MeshId/MeshContent")
	local v8 = v4[v7]

	if not v8 then
		v8 = InsertService:CreateMeshPartAsync(
			meshId,
			properties.CollisionFidelity or Enum.CollisionFidelity.Default,
			properties.RenderFidelity or Enum.RenderFidelity.Automatic
		)
		v4[v7] = v8
	end

	resetMeshClear(v7) -- equivalent call inferred; original call site unknown
	return v8:Clone()
end

function InstanceSerializer.prefetchMeshes(p, value: number?)
	local properties = {}
	local v7 = {}
	local scan

	scan = function(instance)
		if not instance.IsRaw and instance.ClassName == "MeshPart" then
			local properties2 = instance.Properties
			local meshId = properties2.MeshId or properties2.MeshContent and properties2.MeshContent.Uri
			local v8

			if meshId then
				local collisionFidelity = properties2.CollisionFidelity or Enum.CollisionFidelity.Default
				local renderFidelity = properties2.RenderFidelity or Enum.RenderFidelity.Automatic
				v8 = `{meshId}|{tostring(collisionFidelity)}|{tostring(renderFidelity)}`
			end

			if v8 and not (v4[v8] or v7[v8]) then
				v7[v8] = true
				table.insert(properties, instance.Properties)
			end
		end

		if instance.Children then
			for _, v8 in instance.Children do
				scan(v8)
			end
		end
	end

	scan(p)

	if #properties == 0 then
		return
	end

	local v8 = 0

	for _ = 1, math.min(value or 10, #properties) do
		v8 += 1
		task.spawn(function()
			while true do
				local v9 = table.remove(properties)

				if not v9 then
					break
				end

				pcall(function()
					local v11 = v9
					local meshId = v11.MeshId or v11.MeshContent and v11.MeshContent.Uri
					local v12

					if meshId then
						local collisionFidelity = v11.CollisionFidelity or Enum.CollisionFidelity.Default
						local renderFidelity = v11.RenderFidelity or Enum.RenderFidelity.Automatic
						v12 = `{meshId}|{tostring(collisionFidelity)}|{tostring(renderFidelity)}`
					end

					if v12 and not v4[v12] then
						v4[v12] = InsertService:CreateMeshPartAsync(
							v9.MeshId or v9.MeshContent.Uri,
							v9.CollisionFidelity or Enum.CollisionFidelity.Default,
							v9.RenderFidelity or Enum.RenderFidelity.Automatic
						)
						resetMeshClear(v12) -- equivalent call inferred; original call site unknown
					end
				end)
			end

			v8 -= 1
		end)
	end

	while v8 > 0 do
		task.wait()
	end
end

function InstanceSerializer.rawDeserialize(instance, clones)
	local v7 = clones[instance]

	if v7 then
		return v7
	end

	local clone, className

	if instance.IsRaw then
		clone = clones.CarryInstances[assert(instance.Id)]:Clone()
		className = clone.ClassName
	else
		className = instance.ClassName
		local properties = instance.Properties

		if className == "MeshPart" and (properties.MeshId or properties.MeshContent) then
			clone = createMeshPart(properties)
		else
			clone = Instance.new(instance.ClassName)
		end
	end

	if instance.Id then
		clones[instance.Id] = clone
	end

	clones[instance] = clone
	local properties = InstanceSerializer.getProperties(className)
	local properties2 = {}

	for k, property in instance.Properties do
		if v[k] or v2[`{className}.{k}`] then
			continue
		end

		if properties[k].Type.ScriptType == "Instance" then
			if not clones.PropertyInstanceReferences[instance] then
				clones.PropertyInstanceReferences[instance] = {}
			end

			clones.PropertyInstanceReferences[instance][k] = property
		else
			properties2[k] = property
		end
	end

	for k, v8 in properties2 do
		clone[k] = v8
	end

	if instance.Children then
		for _, v8 in instance.Children do
			local rawDeserialize = InstanceSerializer.rawDeserialize(v8, clones)
			rawDeserialize.Parent = clone
		end
	end

	if instance.Tags then
		for _, tag in instance.Tags do
			CollectionService:AddTag(clone, tag)
		end
	end

	if instance.Attributes then
		for k, attribute in instance.Attributes do
			if k:sub(1, 4) ~= "RBX_" then
				clone:SetAttribute(k, attribute)
			end
		end
	end

	if clones.Main ~= instance then
		return clone
	end

	for k, propertyInstanceReference in clones.PropertyInstanceReferences do
		for k2, v8 in propertyInstanceReference do
			clones[k][k2] = clones[v8]
		end
	end

	table.clear(clones)
	return clone
end

function InstanceSerializer.deserialize(main, options)
	InstanceSerializer.prefetchMeshes(main)
	return InstanceSerializer.rawDeserialize(main, {
		Main = main,
		PropertyInstanceReferences = {},
		CarryInstances = options or {}
	})
end

return InstanceSerializer