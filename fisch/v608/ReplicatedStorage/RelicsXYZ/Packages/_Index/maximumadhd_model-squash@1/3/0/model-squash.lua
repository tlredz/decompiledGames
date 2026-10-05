local parent = script.Parent
local Squash = require(parent.Squash)
local PropSquash = require(script.PropSquash)
local ArraySquash = require(parent.ArraySquash)
local DeferredPatcher = require(script.DeferredPatcher)
game:GetService("AssetService")
local ReflectionService = game:GetService("ReflectionService")
local Filters = require(script.Filters)
local I32 = ArraySquash.Accumulated.I32
local string = Squash.string()
local vlq = Squash.vlq()
local v = {}
local propertiesOfClasses = {}
v.Instance = {
	Tags = function(instance, items)
		for _, tag in items do
			instance:AddTag(tag)
		end
	end,
	Attributes = function(instance, items)
		for k, item in items do
			instance:SetAttribute(k, item)
		end
	end
}
v.MeshPart = {
	MeshId = function(p, p2: string)
		local content = Content.fromUri(p2)
		DeferredPatcher.PatchMeshPart(p, "MeshContent", content)
	end,
	FluidFidelity = function(p, p2)
		DeferredPatcher.PatchMeshPart(p, "FluidFidelity", p2)
	end,
	RenderFidelity = function(p, p2)
		DeferredPatcher.PatchMeshPart(p, "RenderFidelity", p2)
	end,
	CollisionFidelity = function(p, p2)
		DeferredPatcher.PatchMeshPart(p, "CollisionFidelity", p2)
	end
}

local function getProperties(p: string)
	local propertiesOfClass = propertiesOfClasses[p]

	if propertiesOfClass == nil then
		propertiesOfClass = ReflectionService:GetPropertiesOfClass(p)
		propertiesOfClasses[p] = propertiesOfClass
	end

	return propertiesOfClass
end

local function canSerialize(data)
	local name = data.Name
	local owner = data.Owner
	local selected = Filters[owner] and Filters[owner][name]

	if selected ~= nil then
		return selected
	end

	local display = data.Display
	return data.Permits.Write ~= nil and not (display and display.DeprecationMessage) and data.Serialized
end

local function serialize(folder)
	local cursor = Squash.cursor()
	local descendants = folder:GetDescendants()
	table.insert(descendants, 1, folder)
	local v2 = {}
	local v3 = {}
	local classNames = {}

	for k, descendant in descendants do
		local className = descendant.ClassName
		local v4 = v2[className]

		if not v4 then
			local v5 = #classNames + 1
			classNames[v5] = className
			v2[className] = {
				Index = v5,
				ObjectIds = {}
			}
			v4 = v2[className]
		end

		v3[descendant] = k
		descendant:SetAttribute("__msref", k)
		table.insert(v4.ObjectIds, k)
	end

	local v4 = {}

	for k, v5 in classNames do
		local v6 = v2[v5]
		local objectIds = v6.ObjectIds
		local propertiesOfClass = propertiesOfClasses[v5]

		if propertiesOfClass == nil then
			propertiesOfClass = ReflectionService:GetPropertiesOfClass(v5)
			propertiesOfClasses[v5] = propertiesOfClass
		end

		for _, v7 in propertiesOfClass do
			local name = v7.Name
			local owner = v7.Owner
			local serialized = Filters[owner] and Filters[owner][name]

			if serialized == nil then
				local display = v7.Display

				if v7.Permits.Write == nil then
					serialized = false
				else
					serialized = not (display and display.DeprecationMessage) and v7.Serialized
				end
			end

			if not serialized then
				continue
			end

			local name2 = v7.Name
			local engineType = v7.Type.EngineType
			local typeIndex = PropSquash.TypeEnum[engineType]

			if typeIndex == nil then
				local typeAlias = PropSquash.TypeAliases[engineType]

				if typeAlias then
					typeIndex = PropSquash.TypeEnum[typeAlias]
				end
			end

			if typeIndex == nil then
				continue
			end

			local v9 = {
				Name = name2,
				ClassIndex = k,
				TypeIndex = typeIndex,
				Values = {}
			}

			for _, objectId in ipairs(objectIds) do
				local v10 = descendants[objectId][name2]
				table.insert(v9.Values, v10)
			end

			table.insert(v4, v9)
		end

		local tagsByObjectId = {}
		local attributesByObjectId = {}

		for _, objectId in ipairs(objectIds) do
			local descendant = descendants[objectId]
			local attributes = descendant:GetAttributes()
			local tags = descendant:GetTags()

			if #tags > 0 then
				tagsByObjectId[objectId] = tags
			end

			if next(attributes) then
				attributesByObjectId[objectId] = attributes
			end
		end

		for k2, v7 in {
			Tags = tagsByObjectId,
			Attributes = attributesByObjectId
		} do
			if not next(v7) then
				continue
			end

			local v8 = {
				Name = k2,
				ClassIndex = k,
				TypeIndex = PropSquash.TypeEnum[k2],
				Values = {}
			}

			for i, objectId in ipairs(v6.ObjectIds) do
				v8.Values[i] = v7[objectId] or {}
			end

			table.insert(v4, v8)
		end
	end

	local v5 = {}

	for k, _ in descendants do
		local parent2 = descendants[k].Parent
		v5[k] = not parent2 and 0 or v3[parent2] or 0
	end

	I32.ser(cursor, v5)

	for i = #v4, 1, -1 do
		local v6 = v4[i]
		local values = v6.Values
		local typeId = PropSquash.TypeIds[v6.TypeIndex]
		PropSquash.CompressArray(cursor, typeId, values)
		vlq.ser(cursor, v6.TypeIndex)
		vlq.ser(cursor, v6.ClassIndex)
		string.ser(cursor, v6.Name)
	end

	vlq.ser(cursor, #v4)

	for i = #classNames, 1, -1 do
		local v6 = classNames[i]
		local v7 = v2[v6]
		I32.ser(cursor, v7.ObjectIds)
		vlq.ser(cursor, v7.Index)
		string.ser(cursor, v6)
	end

	vlq.ser(cursor, #classNames)
	vlq.ser(cursor, 1)
	string.ser(cursor, "RBXMSQSH")

	for _, descendant in descendants do
		descendant:SetAttribute("__msref", nil)
	end

	return Squash.tobuffer(cursor)
end

local function deserialize(buf: buffer)
	local frombuffer = Squash.frombuffer(buf)
	assert(string.des(frombuffer) == "RBXMSQSH", "ModelSquash - Provided buffer is not a valid ModelSquash buffer!")

	if vlq.des(frombuffer) ~= 1 then
		error("ModelSquash - Unsupported format version! (Expected 1)")
	end

	local v2 = {}
	local v3 = {}

	for _ = 1, vlq.des(frombuffer) do
		local des = string.des(frombuffer)
		local des2 = vlq.des(frombuffer)
		local des3 = I32.des(frombuffer)

		for _, de in des3 do
			local name = des
			local success, result = pcall(function()
				return Instance.new(name)
			end)

			if success then
				v2[de] = result
			else
				warn("ModelSquash - Could not create instance of class:", des, "Error:", result)
			end
		end

		v3[des2] = {
			Name = des,
			ObjectIds = des3
		}
	end

	for _ = 1, vlq.des(frombuffer) do
		local des = string.des(frombuffer)
		local des2 = vlq.des(frombuffer)
		local des3 = vlq.des(frombuffer)
		local typeId = PropSquash.TypeIds[des3]
		local v4 = v3[des2]
		local objectIds = v4.ObjectIds
		local decompressArray, v5 = PropSquash.DecompressArray(frombuffer, typeId)
		local v6 = decompressArray and v5 or {}

		for i, objectId in ipairs(objectIds) do
			local v7 = v2[objectId]
			local v8 = v6[i]

			if v7 then
				if typeId == "Ref" then
					v8 = v2[v8]
				end

				local v9 = nil

				for className, v11 in v do
					if not (v7:IsA(className) and v11[des]) then
						continue
					end

					v9 = v11[des]
					break
				end

				if v9 then
					v9(v7, v8)
				else
					local v11 = v7
					local v12 = des

					if not pcall(function()
						v11[v12] = v8
					end) then
						warn("ModelSquash - Could not set property value:", v4.Name, des, v8)
					end
				end
			else
				warn("ModelSquash - Could not find instance for objectId:", objectId, "Class:", v4.Name)
			end
		end
	end

	local des = I32.des(frombuffer)

	for i, v4 in ipairs(v2) do
		local de = des[i]

		if de > 0 then
			v4.Parent = v2[de]
		end
	end

	return v2[1]
end

local function getTypeIndexFromEngineType(p: string)
	local v2 = PropSquash.TypeEnum[p]

	if v2 == nil then
		local typeAlias = PropSquash.TypeAliases[p]

		if typeAlias then
			return PropSquash.TypeEnum[typeAlias]
		end
	end

	return v2
end

return table.freeze({
	ser = serialize,
	des = deserialize,
	Serialize = serialize,
	Deserialize = deserialize,
	GetTypeIndexFromEngineType = getTypeIndexFromEngineType
})