local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local module = require("./logger")
local Utility = {
	DEG_TO_RAD = 0.017453292519943295,
	BEZIER_TAG = "BezierParticle",
	SHOCKWAVE_TAG = "Shockwave",
	SCREENSHAKE_TAG = "CameraShake",
	ENABLED_VFX_TAG = "ConstantVFX",
	TEXTURE_LOAD_TAG = "LoadVFXTextures",
	RENDER_PRIORITY = Enum.RenderPriority.Camera.Value + 1,
	COLLISION_GROUPS = {
		StudioSelectable = {},
		ForgeDebris = {
			ForgeDebris = false
		},
		ForgeMouseIgnore = {
			StudioSelectable = false
		}
	},
	COPY_SPECIALMESH_PROPERTIES = {
		"MeshId",
		"MeshType",
		"Offset",
		"Scale",
		"TextureId",
		"VertexColor"
	},
	COPY_PART_PROPERTIES = {
		"CastShadow",
		"Color",
		"Material",
		"MaterialVariant",
		"Reflectance",
		"Shape",
		"FrontSurface",
		"BackSurface",
		"LeftSurface",
		"RightSurface",
		"TopSurface",
		"BottomSurface"
	},
	COPY_EXTENDED_PART_PROPERTIES = {
		"Size",
		"Transparency",
		"CanCollide",
		"CanQuery",
		"CanTouch",
		"CollisionGroup"
	}
}
local object = setmetatable({}, {
	__mode = "k"
})

function Utility.lock(p)
	if object[p] then
		return true
	end

	object[p] = coroutine.running()
	return false
end

function Utility.unlock(p, thread: thread?)
	local v = object[p]

	if coroutine.running() ~= v and thread ~= v then
		module.error("attempt to unlock an instance owned by a different thread")
	end

	object[p] = nil
end

function Utility.setCollisionGroups(items)
	local v = {}

	for k, item in items do
		PhysicsService:RegisterCollisionGroup(k)

		if not k:match("Studio") or RunService:IsStudio() then
			v[k] = item
		end
	end

	for k, v2 in v do
		for k2, v3 in v2 do
			if not k2:match("Studio") or RunService:IsStudio() then
				PhysicsService:CollisionGroupSetCollidable(k, k2, v3)
			end
		end
	end
end

local count = 0

function Utility.getRanomId()
	count += 1
	return (tostring(count))
end

function Utility.copyProperties(p, p2, items)
	for _, item in items do
		p2[item] = p[item]
	end
end

function Utility.lerp(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

function Utility.try(formatString: string, callback, ...)
	local v = { xpcall(callback, function(p)
			module.warn(string.format(formatString, p))
		end, ...) }
	return v[1], table.unpack(v, 2)
end

function Utility.reboundfn(duration: number, callback)
	local thread = nil
	return function(...)
		if thread then
			task.cancel(thread)
		end

		local v = { ... }
		thread = task.delay(duration, function()
			thread = nil
			callback(table.unpack(v))
		end)
	end
end

function Utility.randomUnitVector(vector2: Vector3, vector3: Vector3, p)
	local v = p or Random.new()
	return (Vector3.new(
		v:NextNumber(vector2.X, vector3.X),
		v:NextNumber(vector2.Y, vector3.Y),
		v:NextNumber(vector2.Z, vector3.Z)
	))
end

function Utility.getImpulseForce(vector2: Vector3, vector3: Vector3, p: number)
	return (vector3 - vector2) / p + Vector3.new(0, workspace.Gravity * p * 0.5, 0)
end

function Utility.isMeshVFX(model)
	return model and model:IsA("Model") and model:FindFirstChild("Start") and model.Start:IsA("BasePart") and model:FindFirstChild("End") and model.End:IsA("BasePart")
end

function Utility.cleanupScope(list)
	for _, connection in list do
		local typeName = typeof(connection)

		if typeName == "Instance" then
			connection:Destroy()
		elseif typeName == "RBXScriptConnection" then
			connection:Disconnect()
		elseif typeName == "thread" then
			if coroutine.status(connection) ~= "dead" then
				task.cancel(connection)
			end
		elseif typeName == "function" then
			task.spawn(connection)
		elseif typeName == "table" then
			Utility.cleanupScope(connection)
		end
	end

	table.clear(list)
end

function Utility.protectParent(connections, instance)
	table.insert(connections, instance.AncestryChanged:Connect(function(_, _)
		if instance.Parent == workspace.Terrain then
			return
		end

		instance.Parent = workspace.Terrain
	end))
end

function Utility.findFirstClassWithTag(instance, p: string, tag: string)
	if not instance or instance.Parent == game then
		return
	end

	if instance.ClassName == p and instance:HasTag(tag) then
		return instance
	end

	return Utility.findFirstClassWithTag(instance.Parent, p, tag)
end

function Utility.cloneParticleAncestry(instance, instances)
	if instance:FindFirstAncestorWhichIsA("BasePart") or instance:FindFirstAncestorOfClass("Attachment") then
		local findAncestor

		findAncestor = function(parent)
			if parent.Parent and (parent.Parent:IsA("BasePart") or parent.Parent:IsA("Attachment")) then
				parent = findAncestor(parent.Parent)
			end

			return parent
		end

		local recurse

		recurse = function(parent)
			local v = instances[parent]

			if v then
				if parent == instance then
					return v, instances[parent.Parent]
				end

				local parent2 = parent.Parent

				if parent2.Parent and (parent2.Parent:IsA("BasePart") or parent2.Parent:IsA("Attachment")) then
					parent2 = findAncestor(parent2.Parent)
				end

				return v, instances[parent2] or instances[parent]
			else
				local instance2 = Instance.fromExisting(parent)
				instance2.Archivable = false

				if instance2:IsA("BasePart") then
					instance2.Locked = true
				end

				if instances then
					instances[parent] = instance2
				end

				local v2

				if parent.Parent and (parent.Parent:IsA("BasePart") or parent.Parent:IsA("Attachment")) then
					local parent2, v4 = recurse(parent.Parent)
					v2 = v4 or instance2

					if parent2 then
						instance2.Parent = parent2
					end
				else
					v2 = instance2
				end

				return instance2, v2
			end
		end

		return recurse(instance.Parent)
	end
end

function Utility.getAttribute(instance, attributeName: string, p, flag: boolean?)
	local attribute = instance:GetAttribute(attributeName)

	if attribute == nil or typeof(attribute) ~= typeof(p) then
		attribute = p
	end

	if not flag then
		instance:SetAttribute(attributeName, attribute)
	end

	return attribute
end

function Utility.getRangeAttribute(instance, attributeName: string, range: NumberRange, range2: NumberRange?, flag: boolean?)
	local attribute = instance:GetAttribute(attributeName)

	if typeof(attribute) ~= "NumberRange" then
		attribute = range
	end

	if range2 then
		attribute = NumberRange.new(
			math.clamp(attribute.Min, range2.Min, range2.Max),
			(math.clamp(attribute.Max, range2.Min, range2.Max))
		)
	end

	if not flag then
		instance:SetAttribute(attributeName, attribute)
	end

	return attribute
end

function Utility.getEnumAttribute(instance, attributeName: string, p, list, flag: boolean?)
	local attribute = instance:GetAttribute(attributeName)

	if attribute == nil or not table.find(list, attribute) then
		attribute = p
	end

	if not flag then
		instance:SetAttribute(attributeName, attribute)
	end

	return attribute
end

function Utility.getMeshDecals(instance, instance2)
	local decals = {}
	local result = {}
	local decalsByDecal = {}

	local function filter(children)
		local decals2 = {}

		for _, decal in children do
			if decal:IsA("Decal") then
				table.insert(decals2, decal)
			end
		end

		return decals2
	end

	if Utility.getAttribute(instance, "Flipbook", false, true) then
		return filter(instance2:GetChildren()), result, decalsByDecal
	end

	local firstChild = instance:FindFirstChild("End")
	local start = instance:FindFirstChild("Start")

	if not firstChild then
		return decals, result, decalsByDecal
	end

	for _, decal in instance2:GetChildren() do
		if not decal:IsA("Decal") then
			continue
		end

		local decal2 = firstChild:FindFirstChild(decal.Name)

		if not (decal2 and decal2:IsA("Decal")) then
			continue
		end

		table.insert(decals, decal)
		decalsByDecal[decal] = decal2

		if decal:GetAttribute("FlipbookEnabled") then
			result[decal] = Utility.deserializeFlipbook(decal:GetAttribute("FlipbookTextures"))
		else
			table.insert(decals, decal)
		end
	end

	for _, decal in start:GetChildren() do
		if not decal:IsA("Decal") then
			continue
		end

		local children = decal:GetChildren()
		local count2 = 0

		for i = 1, #children do
			local v = i - count2

			if children[v]:IsA("Decal") then
				continue
			end

			table.remove(children, v)
			count2 += 1
		end

		if #children == 0 then
			continue
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function idx(value: string)
			return tonumber(value:match("%d+")) or 0
		end

		table.sort(children, function(a, b)
			return idx(a.Name) < idx(b.Name)
		end)
		local v = {}

		for _, v2 in children do
			table.insert(v, idx(v2.Texture))
			v2:Destroy()
		end

		local serializeFlipbook = Utility.serializeFlipbook(v)
		decal:SetAttribute("FlipbookEnabled", true)
		decal:SetAttribute("FlipbookTextures", buffer.tostring(serializeFlipbook))
	end

	return decals, result, decalsByDecal
end

function Utility.getBezierPoints(instance, flag: boolean)
	local children = instance:GetChildren()
	table.sort(children, function(a, b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)
	local vectors = {}
	local result = {}
	local vectors2 = {}

	local function vec(p)
		local pointToObjectSpace = instance.WorldCFrame:PointToObjectSpace(p.WorldPosition)
		local vector2 = vector.create(pointToObjectSpace.X, pointToObjectSpace.Y, pointToObjectSpace.Z)
		table.insert(vectors, vector2)

		if flag then
			vectors2[p] = vector2
			table.insert(result, p)
		end

		return vector2
	end

	for k, v in children do
		local T0 = v:FindFirstChild("T0")
		local T1 = v:FindFirstChild("T1")

		if k == 1 then
			local pointToObjectSpace = instance.WorldCFrame:PointToObjectSpace(v.WorldPosition)
			local vector2 = vector.create(pointToObjectSpace.X, pointToObjectSpace.Y, pointToObjectSpace.Z)
			table.insert(vectors, vector2)

			if flag then
				vectors2[v] = vector2
				table.insert(result, v)
			end
		end

		if k ~= 1 then
			if T1 then
				local pointToObjectSpace = instance.WorldCFrame:PointToObjectSpace(T1.WorldPosition)
				local vector2 = vector.create(pointToObjectSpace.X, pointToObjectSpace.Y, pointToObjectSpace.Z)
				table.insert(vectors, vector2)

				if flag then
					vectors2[T1] = vector2
					table.insert(result, T1)
				end
			else
				local pointToObjectSpace = instance.WorldCFrame:PointToObjectSpace(v.WorldPosition)
				local vector2 = vector.create(pointToObjectSpace.X, pointToObjectSpace.Y, pointToObjectSpace.Z)
				table.insert(vectors, vector2)

				if flag then
					vectors2[v] = vector2
					table.insert(result, v)
				end
			end
		end

		if k ~= 1 and k ~= #children then
			local pointToObjectSpace = instance.WorldCFrame:PointToObjectSpace(v.WorldPosition)
			local vector2 = vector.create(pointToObjectSpace.X, pointToObjectSpace.Y, pointToObjectSpace.Z)
			table.insert(vectors, vector2)

			if flag then
				vectors2[v] = vector2
				table.insert(result, v)
			end
		end

		if k ~= #children then
			if T0 then
				local pointToObjectSpace = instance.WorldCFrame:PointToObjectSpace(T0.WorldPosition)
				local vector2 = vector.create(pointToObjectSpace.X, pointToObjectSpace.Y, pointToObjectSpace.Z)
				table.insert(vectors, vector2)

				if flag then
					vectors2[T0] = vector2
					table.insert(result, T0)
				end
			else
				local pointToObjectSpace = instance.WorldCFrame:PointToObjectSpace(v.WorldPosition)
				local vector2 = vector.create(pointToObjectSpace.X, pointToObjectSpace.Y, pointToObjectSpace.Z)
				table.insert(vectors, vector2)

				if flag then
					vectors2[v] = vector2
					table.insert(result, v)
				end
			end
		end

		if k ~= #children then
			continue
		end

		local pointToObjectSpace = instance.WorldCFrame:PointToObjectSpace(v.WorldPosition)
		local vector2 = vector.create(pointToObjectSpace.X, pointToObjectSpace.Y, pointToObjectSpace.Z)
		table.insert(vectors, vector2)

		if not flag then
			continue
		end

		vectors2[v] = vector2
		table.insert(result, v)
	end

	return vectors, result, vectors2
end

function Utility.scaleNumberSequence(sequence, callback)
	if callback == 1 then
		return sequence
	end

	local numberSequenceKeypoints = {}

	for _, keypoint in sequence.Keypoints do
		local v, v2

		if typeof(callback) == "function" then
			v, v2 = callback(keypoint.Value, keypoint.Envelope)
		else
			v = keypoint.Value * callback
			v2 = keypoint.Envelope * callback
		end

		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(keypoint.Time, v, v2))
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

function Utility.serializePath(list)
	local buf = buffer.create(#list * 4 * 6)
	local total = 0

	for k, v in list do
		local scale = v.Position.X.Scale
		local scale2 = v.Position.Y.Scale

		if k ~= 1 then
			buffer.writef32(buf, total, scale + v.LeftTangent.X.Scale)
			buffer.writef32(buf, total + 4, scale2 + v.LeftTangent.Y.Scale)
			total += 8
		end

		buffer.writef32(buf, total, scale)
		buffer.writef32(buf, total + 4, scale2)
		total += 8

		if k == #list then
			continue
		end

		buffer.writef32(buf, total, scale + v.RightTangent.X.Scale)
		buffer.writef32(buf, total + 4, scale2 + v.RightTangent.Y.Scale)
		total += 8
	end

	return buf
end

function Utility.deserializePath(buffer2)
	if typeof(buffer2) == "string" then
		buffer2 = buffer.fromstring(buffer2) or buffer2
	end

	local v = buffer.len(buffer2) / 24
	local vectors = {}

	for i = 0, v - 1 do
		local v2 = i * 4 * 6
		table.insert(vectors, (vector.create(buffer.readf32(buffer2, v2), (buffer.readf32(buffer2, v2 + 4)))))

		if i == v - 1 then
			continue
		end

		local v3 = buffer.readf32(buffer2, v2 + 8)
		local v4 = buffer.readf32(buffer2, v2 + 12)
		local v5 = buffer.readf32(buffer2, v2 + 16)
		local v6 = buffer.readf32(buffer2, v2 + 20)
		table.insert(vectors, (vector.create(v3, v4)))
		table.insert(vectors, (vector.create(v5, v6)))
	end

	return vectors
end

function Utility.serializeFlipbook(list)
	local buf = buffer.create(#list * 8)

	for k, value in list do
		buffer.writef64(buf, (k - 1) * 8, value)
	end

	return buf
end

function Utility.deserializeFlipbook(buffer2)
	if typeof(buffer2) == "string" then
		buffer2 = buffer.fromstring(buffer2) or buffer2
	end

	local result = {}

	for i = 0, buffer.len(buffer2) / 8 - 1 do
		table.insert(result, (buffer.readf64(buffer2, i * 8)))
	end

	return result
end

Utility.default_bezier = buffer.tostring(Utility.serializePath({
	Path2DControlPoint.new(UDim2.fromScale(0, 1), UDim2.new(), UDim2.fromScale(0.215, -0.61)),
	Path2DControlPoint.new(UDim2.fromScale(1, 0), UDim2.fromScale(-0.645, 0), UDim2.new())
}))
Utility.linear_bezier = buffer.tostring(Utility.serializePath({
	Path2DControlPoint.new(UDim2.fromScale(0, 1)),
	Path2DControlPoint.new(UDim2.fromScale(1, 0))
}))
return Utility