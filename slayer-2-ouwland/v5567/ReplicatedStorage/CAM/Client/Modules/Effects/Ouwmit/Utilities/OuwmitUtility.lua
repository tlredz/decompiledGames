local createVector = vector.create
require(script.Parent.Types)
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local OuwmitUtility = {
	DEG_TO_RAD = 0.017453292519943295
}
local typeof2 = typeof
local new = ColorSequence.new

function OuwmitUtility.GetColor(instance, state)
	local v = nil

	if state ~= nil then
		if typeof(state) == "Color3" then
			new(state)
			return
		end

		local color = state.Color or state.color

		if color then
			local v2 = false
			local colorWhitelist = state.ColorWhitelist

			if colorWhitelist == nil then
				v2 = true
			elseif typeof(colorWhitelist) == "table" then
				for _, ancestorName in ipairs(colorWhitelist) do
					if not (instance.Name == ancestorName or instance:FindFirstAncestor(ancestorName) ~= nil) then
						continue
					end

					v2 = true
					break
				end
			else
				v2 = instance.Name == colorWhitelist or instance:FindFirstAncestor(colorWhitelist) ~= nil
			end

			if v2 then
				local v3 = false
				local colorBlacklist = state.ColorBlacklist

				if colorBlacklist ~= nil then
					if typeof(colorBlacklist) == "table" then
						for _, ancestorName in ipairs(colorBlacklist) do
							if not (instance.Name == ancestorName or instance:FindFirstAncestor(ancestorName) ~= nil) then
								continue
							end

							v3 = true
							break
						end
					else
						v3 = instance.Name == colorBlacklist or instance:FindFirstAncestor(colorBlacklist) ~= nil
					end
				end

				if not v3 then
					v = color
				end
			end
		end

		if v ~= nil then
			if state.ColorChosen == nil then
				state.ColorChosen = new(v)
			end

			return state.ColorChosen
		end
	end
end

function OuwmitUtility.serializePath(list)
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

function OuwmitUtility.lerp(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

function OuwmitUtility.deserializePath(buffer2)
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

function OuwmitUtility.GetImpulseForce(vector2: Vector3, vector3: Vector3, p: number)
	return (vector3 - vector2) / p + Vector3.new(0, workspace.Gravity * p * 0.5, 0)
end

function OuwmitUtility.getBezierPoints(instance, flag: boolean?)
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

function OuwmitUtility.RandomUnitVector(vector2: Vector3, vector3: Vector3, p)
	local v = p or Random.new()
	return (Vector3.new(
		v:NextNumber(vector2.X, vector3.X),
		v:NextNumber(vector2.Y, vector3.Y),
		v:NextNumber(vector2.Z, vector3.Z)
	))
end

function OuwmitUtility.CopyProperties(p, p2, items)
	for _, item in items do
		p2[item] = p[item]
	end
end

function OuwmitUtility.GetMeshDecals(instance, instance2)
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

	if OuwmitUtility.GetAttribute(instance, "Flipbook", false, true) then
		return filter(instance2:GetChildren()), result, decalsByDecal
	end

	local firstChild = instance:FindFirstChild("End")

	for _, decal in instance2:GetChildren() do
		if not decal:IsA("Decal") then
			continue
		end

		local decal2 = firstChild ~= nil and firstChild:FindFirstChild(decal.Name) or instance:FindFirstChild("End" .. decal.Name)

		if not (decal2 and decal2:IsA("Decal")) then
			continue
		end

		table.insert(decals, decal)
		decalsByDecal[decal] = decal2
		local children = decal:GetChildren()
		local count = 0

		for i = 1, #children do
			local v = i - count

			if children[v]:IsA("Decal") then
				continue
			end

			table.remove(children, v)
			count += 1
		end

		if #children ~= 0 then
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

			local serializeFlipbook = OuwmitUtility.serializeFlipbook(v)
			decal:SetAttribute("FlipbookEnabled", true)
			decal:SetAttribute("FlipbookTextures", buffer.tostring(serializeFlipbook))
		end

		if decal:GetAttribute("FlipbookEnabled") then
			result[decal] = OuwmitUtility.deserializeFlipbook(decal:GetAttribute("FlipbookTextures"))
		else
			table.insert(decals, decal)
		end
	end

	return decals, result, decalsByDecal
end

function OuwmitUtility.serializeFlipbook(list)
	local buf = buffer.create(#list * 8)

	for k, value in list do
		buffer.writef64(buf, (k - 1) * 8, value)
	end

	return buf
end

function OuwmitUtility.deserializeFlipbook(buffer2)
	if typeof(buffer2) == "string" then
		buffer2 = buffer.fromstring(buffer2) or buffer2
	end

	local result = {}

	for i = 0, buffer.len(buffer2) / 8 - 1 do
		table.insert(result, (buffer.readf64(buffer2, i * 8)))
	end

	return result
end

local object = setmetatable({}, {
	__mode = "k"
})

function OuwmitUtility.EstimateDurationCached(p)
	local v = object[p]

	if v == nil then
		v = OuwmitUtility.EstimateDuration(p)
		object[p] = v
	end

	return v
end

function OuwmitUtility.EstimateDuration(folder)
	local v = 0

	local function consider(p: number)
		if v < p then
			v = p
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function rangeMax(p, p2: string, p3: number)
		return OuwmitUtility.GetRangeAttribute(p, p2, NumberRange.new(p3, p3), NumberRange.new(0, 1e999)).Max
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function wallClock(p, p2: number)
		return p2 / math.max(
			OuwmitUtility.GetAttribute(p, "Speed_End", OuwmitUtility.GetAttribute(p, "Speed_Start", 1)),
			0.05
		)
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		local attribute = OuwmitUtility.GetAttribute(descendant, "EmitDelay", 0)

		if descendant:IsA("ParticleEmitter") then
			local attribute2 = OuwmitUtility.GetAttribute(
				descendant,
				"TimeScale_End",
				OuwmitUtility.GetAttribute(descendant, "TimeScale_Start", descendant.TimeScale)
			)
			local v2 = attribute + OuwmitUtility.GetAttribute(descendant, "EmitDuration", 0) + descendant.Lifetime.Max / math.max(
				attribute2,
				0.05
			)

			if v < v2 then
				v = v2
			end
		elseif descendant:IsA("Trail") then
			local v2 = attribute + descendant.Lifetime

			if v < v2 then
				v = v2
			end
		elseif descendant:IsA("Beam") then
			local attribute2 = OuwmitUtility.GetAttribute(descendant, "Duration", 1)
			local v2 = attribute + wallClock(descendant, rangeMax(descendant, "EffectDuration", attribute2))

			if v < v2 then
				v = v2
			end
		elseif descendant:IsA("Model") then
			if descendant:FindFirstChild("Start") ~= nil or descendant:FindFirstChild("SerializedMeshAnim") ~= nil then
				local v2 = attribute + (not descendant:HasTag("ConstantVFX") and 0 or OuwmitUtility.GetAttribute(
					descendant,
					"EmitDuration",
					0
				))
				local attribute2 = OuwmitUtility.GetAttribute(descendant, "Duration", 1)
				local v3 = v2 + wallClock(descendant, rangeMax(descendant, "EffectDuration", attribute2)) + OuwmitUtility.GetAttribute(
					descendant,
					"EmitOnFinishLifetime",
					0
				)

				if v < v3 then
					v = v3
				end
			end

			if OuwmitUtility.GetAttribute(descendant, "SpinRotation", createVector(0, 0, 0)) ~= createVector(0, 0, 0) or OuwmitUtility.GetAttribute(
				descendant,
				"Scale_Start",
				1
			) ~= OuwmitUtility.GetAttribute(descendant, "Scale_End", 1) then
				local v2 = attribute + OuwmitUtility.GetAttribute(descendant, "SpinDuration", 0.5)

				if v < v2 then
					v = v2
				end
			end
		elseif descendant:IsA("Attachment") and descendant:HasTag("BezierParticle") then
			local v2 = attribute + rangeMax(descendant, "Duration", 1) + OuwmitUtility.GetAttribute(
				descendant,
				"DestroyDelay",
				0
			) + rangeMax(descendant, "ProjectileLifetime", 0)

			if v < v2 then
				v = v2
			end
		elseif descendant.ClassName == "RayValue" then
			local v2 = attribute + wallClock(descendant, rangeMax(descendant, "Duration", 1))

			if v < v2 then
				v = v2
			end
		end
	end

	return v
end

function OuwmitUtility:GetFlipbookFrames()
	local v = "rbxassetid://"

	if RunService:IsStudio() then
		for _, v3 in CollectionService:GetTags(self) do
			if not v3:match("^_local_flipbook_") then
				continue
			end

			v = "rbxtemp://"
			break
		end
	end

	if not self:GetAttribute("FlipbookEnabled") then
		return nil, v
	end

	local flipbookTextures = self:GetAttribute("FlipbookTextures")

	if flipbookTextures == nil then
		return nil, v
	end

	local deserializeFlipbook = OuwmitUtility.deserializeFlipbook(flipbookTextures)

	if #deserializeFlipbook == 0 then
		return nil, v
	end

	return deserializeFlipbook, v
end

function OuwmitUtility.OriginCFrame(attachment)
	if not attachment:IsA("Attachment") then
		return attachment.CFrame
	end

	local worldCFrame = attachment.WorldCFrame
	local parent = attachment.Parent
	local attribute = OuwmitUtility.GetAttribute(attachment, "PositionScale", createVector(0, 0, 0))

	if parent ~= nil and parent:IsA("BasePart") and attribute ~= createVector(0, 0, 0) then
		worldCFrame += parent.Size / 2 * attribute
	end

	if OuwmitUtility.GetAttribute(attachment, "OverrideWorldRotation", false) then
		local v = OuwmitUtility.GetAttribute(attachment, "WorldRotation", createVector(0, 0, 0)) * OuwmitUtility.DEG_TO_RAD
		worldCFrame = CFrame.new(worldCFrame.Position) * CFrame.fromOrientation(v.x, v.y, v.z)
	end

	return worldCFrame
end

function OuwmitUtility.GetTarget(instance)
	local objectValue = instance:FindFirstChildOfClass("ObjectValue")

	if objectValue ~= nil and objectValue.Value ~= nil then
		return objectValue.Value
	end

	local parent = instance.Parent

	while parent ~= nil and parent:IsA("Folder") do
		parent = parent.Parent
	end

	return parent
end

function OuwmitUtility.DurationScale(p)
	if p == nil then
		return 1
	end

	local durationScalar = p.DurationScalar

	if durationScalar == nil then
		return 1
	end

	if typeof2(durationScalar) == "number" and durationScalar == durationScalar and durationScalar ~= 1e999 and not (durationScalar <= 0) then
		return durationScalar
	end

	return 1
end

function OuwmitUtility:ScaleLifetime(p: number)
	local ouwAuthoredLifetime = self:GetAttribute("OuwAuthoredLifetime")

	if typeof2(ouwAuthoredLifetime) ~= "NumberRange" then
		ouwAuthoredLifetime = self.Lifetime
		self:SetAttribute("OuwAuthoredLifetime", ouwAuthoredLifetime)
	end

	if p == 1 then
		self.Lifetime = ouwAuthoredLifetime
	else
		self.Lifetime = NumberRange.new(ouwAuthoredLifetime.Min * p, ouwAuthoredLifetime.Max * p)
	end
end

function OuwmitUtility:GetAttribute(attributeName: string, p)
	if self == nil or attributeName == nil then
		return
	end

	local attribute = self:GetAttribute(attributeName)

	if attribute == nil then
		return p
	end

	if p == nil then
		return attribute
	end

	local typeName = typeof2(attribute)
	local typeName2 = typeof2(p)

	if typeName ~= typeName2 and (typeName ~= "vector" and typeName ~= "Vector3" or typeName2 ~= "vector" and typeName2 ~= "Vector3") then
		return p
	end

	return attribute
end

function OuwmitUtility.scaleNumberSequence(sequence, callback)
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

local new2 = NumberRange.new

function OuwmitUtility:GetRangeAttribute(attributeName: string, range: NumberRange, range2: NumberRange)
	if self == nil or attributeName == nil then
		return
	end

	local attribute = self:GetAttribute(attributeName)

	if typeof2(attribute) == "number" then
		attribute = new2(attribute, attribute)
	end

	if typeof2(attribute) ~= "NumberRange" then
		return range or new2(0, 0)
	end

	if range2 == nil then
		return attribute
	end

	return NumberRange.new(
		math.clamp(attribute.Min, range2.Min, range2.Max),
		(math.clamp(attribute.Max, range2.Min, range2.Max))
	)
end

local random = math.random

function OuwmitUtility.GetRandomNumberInRange(p: number, p2: number)
	if p == nil or p2 == nil then
		return
	else
		return random() * (p2 - p) + p
	end
end

OuwmitUtility.default_bezier = buffer.tostring(OuwmitUtility.serializePath({
	Path2DControlPoint.new(UDim2.fromScale(0, 1), UDim2.new(), UDim2.fromScale(0.215, -0.61)),
	Path2DControlPoint.new(UDim2.fromScale(1, 0), UDim2.fromScale(-0.645, 0), UDim2.new())
}))
OuwmitUtility.linear_bezier = buffer.tostring(OuwmitUtility.serializePath({
	Path2DControlPoint.new(UDim2.fromScale(0, 1)),
	Path2DControlPoint.new(UDim2.fromScale(1, 0))
}))
OuwmitUtility.COPY_PART_PROPERTIES = {
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
	"BottomSurface",
	"CustomPhysicalProperties"
}
OuwmitUtility.COPY_EXTENDED_PART_PROPERTIES = {
	"Size",
	"Transparency",
	"CanCollide",
	"CanQuery",
	"CanTouch",
	"CollisionGroup"
}
return OuwmitUtility