local createVector = vector.create
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local module = require("./attributes")
local module2 = require("./logger")
local module3 = require("../pkg/Promise")
local Utility = {
	PLUGIN_CONTEXT = script:FindFirstAncestorOfClass("Plugin") or RunService:IsStudio() and not RunService:IsRunning()
}
Utility.SERVER_CONTEXT = RunService:IsServer() or Utility.PLUGIN_CONTEXT
Utility.DEG_TO_RAD = 0.017453292519943295
Utility.BEZIER_TAG = "BezierParticle"
Utility.LIGHTNING_TAG = "LightningBolt"
Utility.SHOCKWAVE_TAG = "Shockwave"
Utility.SCREENSHAKE_TAG = "CameraShake"
Utility.PROPERTY_TWEENER_TAG = "PropertyTweener"
Utility.PROPERTY_RANDOMIZER_TAG = "PropertyRandomizer"
Utility.ATTRIBUTE_TWEENER_TAG = "AttributeTweener"
Utility.ATTRIBUTE_RANDOMIZER_TAG = "AttributeRandomizer"
Utility.ENABLED_VFX_TAG = "ConstantVFX"
Utility.TEXTURE_LOAD_TAG = "LoadVFXTextures"
Utility.CLEANUP_TAG = "__forge__cleanupOnExit"
Utility.EMIT_EXCLUDE_TAG = "__forge_excludeFromEmit"
Utility.RENDER_PRIORITY = Enum.RenderPriority.Camera.Value + 1
Utility.COLLISION_GROUPS = {
	StudioSelectable = {},
	ForgeDebris = {
		ForgeDebris = false
	},
	ForgeMouseIgnore = {
		StudioSelectable = false
	}
}
Utility.COPY_SPECIALMESH_PROPERTIES = {
	"MeshId",
	"MeshType",
	"Offset",
	"Scale",
	"TextureId",
	"VertexColor"
}
Utility.COPY_PART_PROPERTIES = {
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
}
Utility.COPY_EXTENDED_PART_PROPERTIES = {
	"Size",
	"Transparency",
	"CustomPhysicalProperties",
	"CanCollide",
	"CanQuery",
	"CanTouch",
	"CollisionGroup"
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
		module2.error("attempt to unlock an instance owned by a different thread")
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

function Utility.getRandomId()
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
			module2.warn(string.format(formatString, p))
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

function Utility.isSpinModelStatic(p)
	return module.get(p, "SpinRotation", createVector(0, 0, 0), true) == createVector(0, 0, 0) and module.get(
		p,
		"Scale_Start",
		1,
		true
	) == 1 and module.get(p, "Scale_End", 1, true) == 1 and module.get(p, "SyncPosition", false, true) == false
end

function Utility.shouldSkipNested(instance)
	return instance:IsA("Beam") or instance:HasTag(Utility.BEZIER_TAG) or instance:HasTag(Utility.LIGHTNING_TAG) or Utility.isMeshVFX(instance) or instance:IsA("BasePart") and Utility.findFirstClassWithTag(
		instance,
		"Attachment",
		Utility.SHOCKWAVE_TAG
	) ~= nil
end

function Utility.getTarget(instance)
	local objectValue = instance:FindFirstChildOfClass("ObjectValue")

	if objectValue and objectValue.Value then
		return objectValue.Value
	end

	local parent = instance.Parent

	if not parent then
		return nil
	end

	while parent:IsA("Folder") do
		parent = parent.Parent

		if not parent then
			return nil
		end
	end

	return parent
end

function Utility.createEmitPromise(effects, _, depth: number, callback, context)
	local v = module3.new(function(callback2, _, callback3)
		local v2 = {
			depth = depth,
			effects = effects,
			_context = context
		}
		callback3(function()
			if v2._onCancel then
				for _, v3 in v2._onCancel do
					v3()
				end
			end

			Utility.cleanupScope(v2)
		end)
		callback(v2)
		Utility.cleanupScope(v2)
		callback2()
	end)

	if context then
		table.insert(context._promises, v)
	end

	return v
end

function Utility:onCancel(callback)
	if not self._onCancel then
		self._onCancel = {}
	end

	table.insert(self._onCancel, callback)
end

local object2 = setmetatable({}, {
	__mode = "k"
})
local object3 = setmetatable({}, {
	__mode = "k"
})

function Utility.forceEmit(p, flag: boolean)
	object3[p] = flag and true or nil
end

function Utility.isForceEmitting(p)
	return object3[p] == true
end

function Utility.setEnabledCancelToken(p, p2)
	object2[p] = p2
end

function Utility.getEnabledCancelToken(p)
	return object2[p]
end

function Utility:cancelToken()
	for _, _promis in self._promises do
		_promis:cancel()
	end

	for _, _scope in self._scopes do
		Utility.cleanupScope(_scope, true)
	end

	table.clear(self._promises)
	table.clear(self._scopes)
end

function Utility.stopEmitDuration(p)
	local enabledCancelToken = Utility.getEnabledCancelToken(p)
	module.trigger(p, "Enabled", false)
	module.clearState(p)
	Utility.forceEmit(p, false)
	return enabledCancelToken
end

function Utility:awaitEmitDuration()
	if not self then
		return
	end

	local _promises = {}

	for _, _promis in self._promises do
		table.insert(_promises, _promis)
	end

	if #_promises > 0 then
		module3.all(_promises):await()
	end
end

function Utility:cleanupScope(flag: boolean?)
	local depth = self.depth
	local effects = self.effects
	local _context = self._context
	local _onCancel = self._onCancel

	for k, connection in self do
		if not (k ~= "depth" and k ~= "effects" and k ~= "_context" and k ~= "_onCancel") then
			continue
		end

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
			if flag then
				connection()
			else
				task.spawn(connection)
			end
		elseif typeName == "table" then
			Utility.cleanupScope(connection)
		end
	end

	table.clear(self)
	self.depth = depth
	self.effects = effects
	self._context = _context
	self._onCancel = _onCancel
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
			if not parent then
				return
			end

			if parent.Parent and (parent.Parent:IsA("BasePart") or parent.Parent:IsA("Attachment")) then
				parent = findAncestor(parent.Parent)
			end

			return parent
		end

		local recurse

		recurse = function(parent)
			if not parent then
				return
			end

			local v = instances[parent]

			if v then
				if parent == instance then
					return v, instances[parent.Parent]
				end

				local parent2 = parent.Parent

				if parent2 then
					if parent2.Parent and (parent2.Parent:IsA("BasePart") or parent2.Parent:IsA("Attachment")) then
						parent2 = findAncestor(parent2.Parent)
					end
				else
					parent2 = nil
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

function Utility.getTransformedOriginExtents(instance)
	local identity = CFrame.identity
	local vector2 = createVector(0, 0, 0)

	if instance:IsA("BasePart") then
		local size = instance.Size
		return instance.CFrame, size
	end

	if not instance:IsA("Attachment") then
		return identity, vector2
	end

	identity = instance.WorldCFrame
	local parent = instance.Parent
	local positionScale = module.get(instance, "PositionScale", createVector(0, 0, 0), true)

	if parent and parent:IsA("BasePart") and positionScale ~= createVector(0, 0, 0) then
		identity += parent.Size / 2 * positionScale
	end

	local overrideWorldRotation = module.get(instance, "OverrideWorldRotation", false, true)
	local worldRotation = module.get(instance, "WorldRotation", createVector(0, 0, 0), true)

	if overrideWorldRotation then
		local v = worldRotation * Utility.DEG_TO_RAD
		local position = identity.Position
		identity = CFrame.new(position) * CFrame.fromOrientation(v.X, v.Y, v.Z)
	end

	return identity, vector2
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

	if module.get(instance, "Flipbook", false, true) then
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

		if module.get(decal, "FlipbookEnabled", nil) then
			local flipbookTextures = module.get(decal, "FlipbookTextures", nil)

			if flipbookTextures then
				result[decal] = Utility.deserializeFlipbook(flipbookTextures)
			end
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
		module.set(decal, "FlipbookEnabled", true)
		module.set(decal, "FlipbookTextures", buffer.tostring(serializeFlipbook))
	end

	return decals, result, decalsByDecal
end

function Utility.assembleMeshVFX(part, list, object4)
	local randomId = Utility.getRandomId()

	if part:IsA("Part") then
		local v = object4:get(randomId)
		v.CFrame = part.CFrame
		local _getReal = v._getReal()
		Utility.copyProperties(part, _getReal, Utility.COPY_PART_PROPERTIES)
		Utility.copyProperties(part, _getReal, Utility.COPY_EXTENDED_PART_PROPERTIES)
		local clone = part:Clone()

		for _, child in clone:GetChildren() do
			child.Parent = _getReal
		end

		clone:Destroy()
		table.insert(list, function()
			object4:free(randomId)
		end)
		return v
	else
		local clone = part:Clone()
		clone.Archivable = false
		clone.Locked = true
		clone.Parent = workspace.Terrain
		clone:AddTag(Utility.CLEANUP_TAG)
		table.insert(list, clone)
		return clone
	end
end

function Utility.getBezierPoints(instance, flag: boolean?)
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

local module4 = require("./common/flipbook")
Utility.serializeFlipbook = module4.serialize
Utility.deserializeFlipbook = module4.deserialize
Utility.default_bezier = buffer.tostring(Utility.serializePath({
	Path2DControlPoint.new(UDim2.fromScale(0, 1), UDim2.new(), UDim2.fromScale(0.215, -0.61)),
	Path2DControlPoint.new(UDim2.fromScale(1, 0), UDim2.fromScale(-0.645, 0), UDim2.new())
}))
Utility.linear_bezier = buffer.tostring(Utility.serializePath({
	Path2DControlPoint.new(UDim2.fromScale(0, 1)),
	Path2DControlPoint.new(UDim2.fromScale(1, 0))
}))

function Utility.scaleAttribute(p, p2: number, p3: string)
	local v = module.get(p, p3, nil)

	if v ~= nil then
		if typeof(v) == "number" then
			module.set(p, p3, v * p2)
		elseif typeof(v) == "Vector3" then
			module.set(p, p3, v * p2)
		elseif typeof(v) == "NumberRange" then
			module.set(p, p3, NumberRange.new(v.Min * p2, v.Max * p2))
		end
	end
end

function Utility:scaleAttachmentDistance(p2, p3: number)
	if not (self and p2) then
		return
	end

	local midpoint = (self.Position + p2.Position) / 2
	self.Position = midpoint + (self.Position - midpoint) * p3
	p2.Position = midpoint + (p2.Position - midpoint) * p3
end

return Utility