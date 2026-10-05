local createVector = vector.create
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local MeshEmit = {
	SPEED_SCALE = 1.35,
	DRAG_SCALE = 0.65
}

local function parseRange(value)
	local typeName = typeof(value)

	if typeName == "NumberRange" then
		return value
	elseif typeName == "number" then
		return NumberRange.new(value, value)
	end

	if typeName ~= "string" then
		return NumberRange.new(0, 0)
	end

	local v = {}

	for k in value:gmatch("[%-%d%.]+") do
		v[#v + 1] = tonumber(k)
	end

	return NumberRange.new(v[1] or 0, v[2] or v[1] or 0)
end

local function parseNumSeq(value)
	local typeName = typeof(value)

	if typeName == "NumberSequence" then
		return value
	elseif typeName == "number" then
		return NumberSequence.new(value)
	end

	if typeName ~= "string" or value == "" then
		return nil
	end

	local v = {}

	for k in value:gmatch("[%-%d%.]+") do
		v[#v + 1] = tonumber(k)
	end

	if #v < 2 then
		return nil
	end

	local numberSequenceKeypoints = {}

	for i = 1, #v, 3 do
		local v2 = v[i]
		local v3 = v[i + 1]

		if v2 and v3 then
			numberSequenceKeypoints[#numberSequenceKeypoints + 1] = NumberSequenceKeypoint.new(v2, v3, v[i + 2] or 0)
		end
	end

	if #numberSequenceKeypoints == 0 then
		return nil
	end

	if #numberSequenceKeypoints == 1 then
		numberSequenceKeypoints[#numberSequenceKeypoints + 1] = NumberSequenceKeypoint.new(
			1,
			numberSequenceKeypoints[1].Value,
			0
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local function parseColorSeq(color)
	local typeName = typeof(color)

	if typeName == "ColorSequence" then
		return color
	elseif typeName == "Color3" then
		return ColorSequence.new(color)
	end

	if typeName ~= "string" or color == "" then
		return nil
	end

	local v = {}

	for k in color:gmatch("[%-%d%.]+") do
		v[#v + 1] = tonumber(k)
	end

	if #v < 4 then
		return nil
	end

	local colorSequenceKeypoints = {}

	for i = 1, #v, 5 do
		local v2 = v[i]
		local v3 = v[i + 1]
		local v4 = v[i + 2]
		local v5 = v[i + 3]

		if v2 and v3 and v4 and v5 then
			colorSequenceKeypoints[#colorSequenceKeypoints + 1] = ColorSequenceKeypoint.new(v2, Color3.new(v3, v4, v5))
		end
	end

	if #colorSequenceKeypoints == 0 then
		return nil
	end

	if #colorSequenceKeypoints == 1 then
		colorSequenceKeypoints[#colorSequenceKeypoints + 1] = ColorSequenceKeypoint.new(
			1,
			colorSequenceKeypoints[1].Value
		)
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

local function parseVec3(value, vector2: Vector3?)
	local v = vector2 or createVector(0, 0, 0)
	local typeName = typeof(value)

	if typeName == "Vector3" then
		return value
	elseif typeName == "Vector2" then
		return (Vector3.new(value.X, value.Y, 0))
	end

	if typeName ~= "string" then
		return v
	end

	local v2 = {}

	for k in value:gmatch("[%-%d%.]+") do
		v2[#v2 + 1] = tonumber(k)
	end

	return (Vector3.new(v2[1] or v.X, v2[2] or v.Y, v2[3] or v.Z))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function asBool(value)
	return value == true or typeof(value) == "string" and value == "true"
end

local v = {
	Top = createVector(0, 1, 0),
	Bottom = createVector(0, -1, 0),
	Right = createVector(1, 0, 0),
	Left = createVector(-1, 0, 0),
	Front = createVector(0, 0, -1),
	Back = createVector(0, 0, 1)
}

local function parseEmissionDir(value)
	if typeof(value) == "Vector3" then
		return value
	end

	if typeof(value) == "string" and v[value] then
		return v[value]
	end

	return createVector(0, 1, 0)
end

local function alignVecToVec(unit: Vector3, unit2: Vector3)
	local v2 = math.clamp(unit:Dot(unit2), -1, 1)

	if v2 > 0.9999 then
		return CFrame.new()
	end

	if not (v2 < -0.9999) then
		return CFrame.fromAxisAngle(unit:Cross(unit2).Unit, (math.acos(v2)))
	end

	local cross = unit:Cross(createVector(1, 0, 0))

	if cross.Magnitude < 0.01 then
		cross = unit:Cross(createVector(0, 1, 0))
	end

	return CFrame.fromAxisAngle(cross.Unit, 3.141592653589793)
end

local function sampleNum(sequence, p: number, p2: number)
	if not sequence then
		return 0, p2
	end

	local keypoints = sequence.Keypoints
	local count = #keypoints

	if p <= keypoints[1].Time then
		return keypoints[1].Value, 1
	end

	if keypoints[count].Time <= p then
		return keypoints[count].Value, count - 1
	end

	if p2 >= 1 and p2 < count then
		local keypoint = keypoints[p2]
		local keypoint2 = keypoints[p2 + 1]

		if keypoint.Time <= p and p <= keypoint2.Time then
			local v2 = keypoint2.Time - keypoint.Time

			if v2 < 1e-6 then
				return keypoint.Value, p2
			end

			return keypoint.Value + (keypoint2.Value - keypoint.Value) * ((p - keypoint.Time) / v2), p2
		elseif p2 + 1 < count then
			local keypoint3 = keypoints[p2 + 1]
			local keypoint4 = keypoints[p2 + 2]

			if keypoint3.Time <= p and p <= keypoint4.Time then
				local v2 = keypoint4.Time - keypoint3.Time

				if v2 < 1e-6 then
					return keypoint3.Value, p2 + 1
				end

				return keypoint3.Value + (keypoint4.Value - keypoint3.Value) * ((p - keypoint3.Time) / v2), p2 + 1
			end
		end
	end

	for i = 1, count - 1 do
		local keypoint = keypoints[i]
		local keypoint2 = keypoints[i + 1]

		if not (keypoint.Time <= p and p <= keypoint2.Time) then
			continue
		end

		local v2 = keypoint2.Time - keypoint.Time

		if v2 < 1e-6 then
			return keypoint.Value, i
		end

		return keypoint.Value + (keypoint2.Value - keypoint.Value) * ((p - keypoint.Time) / v2), i
	end

	return keypoints[count].Value, count - 1
end

local function sampleColor(color, p: number, hintC: number)
	if not color then
		return Color3.new(1, 1, 1), hintC
	end

	local keypoints = color.Keypoints
	local count = #keypoints

	if p <= keypoints[1].Time then
		return keypoints[1].Value, 1
	end

	if keypoints[count].Time <= p then
		return keypoints[count].Value, count - 1
	end

	if hintC >= 1 and hintC < count then
		local keypoint = keypoints[hintC]
		local keypoint2 = keypoints[hintC + 1]

		if keypoint.Time <= p and p <= keypoint2.Time then
			local v2 = keypoint2.Time - keypoint.Time

			if v2 < 1e-6 then
				return keypoint.Value, hintC
			end

			return keypoint.Value:Lerp(keypoint2.Value, (p - keypoint.Time) / v2), hintC
		elseif hintC + 1 < count then
			local keypoint3 = keypoints[hintC + 1]
			local keypoint4 = keypoints[hintC + 2]

			if keypoint3.Time <= p and p <= keypoint4.Time then
				local v2 = keypoint4.Time - keypoint3.Time

				if v2 < 1e-6 then
					return keypoint3.Value, hintC + 1
				end

				return keypoint3.Value:Lerp(keypoint4.Value, (p - keypoint3.Time) / v2), hintC + 1
			end
		end
	end

	for i = 1, count - 1 do
		local keypoint = keypoints[i]
		local keypoint2 = keypoints[i + 1]

		if not (keypoint.Time <= p and p <= keypoint2.Time) then
			continue
		end

		local v2 = keypoint2.Time - keypoint.Time

		if v2 < 1e-6 then
			return keypoint.Value, i
		end

		return keypoint.Value:Lerp(keypoint2.Value, (p - keypoint.Time) / v2), i
	end

	return keypoints[count].Value, count - 1
end

local object = setmetatable({}, {
	__mode = "k"
})
local object2 = setmetatable({}, {
	__mode = "k"
})

local function populateSpec(p, instance)
	local attributes = instance:GetAttributes()
	local template = nil

	if instance:IsA("ObjectValue") then
		template = instance.Value
	elseif instance:IsA("BasePart") then
		template = instance
	end

	p.template = template
	p.lifetime = parseRange(attributes.Lifetime or "1 1")
	p.speed = parseRange(attributes.Speed or "0 0")
	p.drag = parseRange(attributes.Drag or "0 0")
	p.maxSize = parseRange(attributes.MaxSize or "1 1")
	p.maxSpin = parseRange(attributes.MaxSpin or "0 0")
	p.colorFactor = parseRange(attributes.ColorFactor or "1 1")
	p.rotX = parseRange(attributes.RotX or "0 0")
	p.rotY = parseRange(attributes.RotY or "0 0")
	p.rotZ = parseRange(attributes.RotZ or "0 0")
	p.sizeX = parseNumSeq(attributes.SizeX)
	p.sizeY = parseNumSeq(attributes.SizeY)
	p.sizeZ = parseNumSeq(attributes.SizeZ)
	p.transparency = parseNumSeq(attributes.Transparency)
	p.color = parseColorSeq(attributes.Color)
	p.spinX = parseNumSeq(attributes.SpinX)
	p.spinY = parseNumSeq(attributes.SpinY)
	p.spinZ = parseNumSeq(attributes.SpinZ)
	p.spreadAngle = parseVec3(attributes.SpreadAngle, createVector(0, 0, 0))
	p.frontVector = parseVec3(attributes.FRONT_VECTOR, createVector(0, 0, -1))
	local emissionDirection = attributes.EmissionDirection

	if typeof(emissionDirection) ~= "Vector3" then
		emissionDirection = (typeof(emissionDirection) ~= "string" or not v[emissionDirection]) and createVector(
			0,
			1,
			0
		) or v[emissionDirection]
	end

	p.emissionDirection = emissionDirection
	local faceVelocity = asBool(attributes.FaceVelocity) -- equivalent call inferred; original call site unknown
	p.faceVelocity = faceVelocity
	local lockedToPart = asBool(attributes.LockedToPart) -- equivalent call inferred; original call site unknown
	p.lockedToPart = lockedToPart
	local transferTransparency = asBool(attributes.TransferTransparency) -- equivalent call inferred; original call site unknown
	p.transferTransparency = transferTransparency
	local transferColor = asBool(attributes.TransferColor) -- equivalent call inferred; original call site unknown
	p.transferColor = transferColor
	p.material = attributes.Material
	p.emitCount = tonumber(attributes.EmitCount) or 1
	p.flipbookFrames = nil
	local bool = asBool(attributes.Flipbook) -- equivalent call inferred; original call site unknown

	if bool and template then
		local flipbook2 = template:FindFirstChild("Flipbook")

		if flipbook2 and flipbook2:IsA("ModuleScript") then
			local success, result = pcall(require, flipbook2)

			if success and type(result) == "table" and #result > 0 then
				p.flipbookFrames = result
			end
		end
	end
end

local function getSpec(instance)
	local v2 = object[instance]

	if v2 then
		return v2
	end

	local v3 = {}
	populateSpec(v3, instance)
	local connection = object2[instance]

	if connection then
		connection:Disconnect()
	end

	object2[instance] = instance.AttributeChanged:Connect(function()
		populateSpec(v3, instance)
	end)
	object[instance] = v3
	return v3
end

local v2 = {}
local heartbeatConnection = nil
local v3 = nil
local fn
local v4 = {}
local v5 = {}

local function getContainer()
	if v3 and v3.Parent then
		return v3
	end

	local parent = workspace:FindFirstChild("Thrown")

	if not parent then
		parent = Instance.new("Folder")
		parent.Name = "Thrown"
		parent.Parent = workspace
	end

	local meshEmitParticles = parent:FindFirstChild("MeshEmitParticles")

	if meshEmitParticles and meshEmitParticles:IsA("Folder") then
		v3 = meshEmitParticles
		return meshEmitParticles
	end

	local folder = Instance.new("Folder")
	folder.Name = "MeshEmitParticles"
	folder.Parent = parent
	v3 = folder
	return folder
end

-- equivalent calls inferred from this helper; original call sites unknown
local function randInRange(range: NumberRange)
	if range.Min == range.Max then
		return range.Min
	end

	return range.Min + (range.Max - range.Min) * math.random()
end

local function tickEmissions(p: number)
	local now = os.clock()

	for k, v6 in pairs(v4) do
		local v7

		if v6.duration > 0 then
			v7 = now - v6.startT >= v6.duration
		else
			v7 = false
		end

		local v8 = not k.Parent

		if v7 or v8 then
			v4[k] = nil
		else
			v6.accum += v6.rate * p

			while v6.accum >= 1 do
				v6.accum -= 1
				local anchorOverride = v6.anchorOverride

				if not anchorOverride then
					local parent = k.Parent

					if parent and parent:IsA("Attachment") then
						anchorOverride = parent.WorldCFrame
					elseif parent and parent:IsA("BasePart") then
						anchorOverride = parent.CFrame
					end
				end

				if anchorOverride then
					fn(v6.spec, anchorOverride, k)
				end
			end
		end
	end
end

local function tick(p: number)
	tickEmissions(p)
	local now = os.clock()
	local v6 = 1

	while v6 <= #v2 do
		local v7 = v2[v6]
		local v8 = (now - v7.t0) / v7.lifetime

		if v8 >= 1 or not v7.part.Parent or v7.lifetime <= 0 or v8 ~= v8 then
			local v9 = v7
			pcall(function()
				v9.part:Destroy()
			end)
			v7.part = nil
			v7.mesh = nil
			v7.cachedDecals = nil
			v7.spec = nil
			v7.sourceParent = nil
			v2[v6] = v2[#v2]
			v2[#v2] = nil
		else
			local spec = v7.spec
			local part = v7.part
			local v9 = math.exp(-v7.drag * p)
			v7.velocity *= v9
			local v10 = part.Position + v7.velocity * p

			if spec.lockedToPart and v7.sourceParent and v7.sourceParent.Parent then
				local sourceParent = v7.sourceParent
				local worldPosition = nil

				if sourceParent:IsA("Attachment") then
					worldPosition = sourceParent.WorldPosition
				elseif sourceParent:IsA("BasePart") then
					worldPosition = sourceParent.Position
				end

				if worldPosition then
					if v7.lastSourcePos then
						v10 += worldPosition - v7.lastSourcePos
					end

					v7.lastSourcePos = worldPosition
				end
			end

			local v11, hintSx = sampleNum(spec.sizeX, v8, v7.hintSx)
			v7.hintSx = hintSx
			local v13, hintSy = sampleNum(spec.sizeY, v8, v7.hintSy)
			v7.hintSy = hintSy
			local v15, hintSz = sampleNum(spec.sizeZ, v8, v7.hintSz)
			v7.hintSz = hintSz
			local v17 = v11 * v7.maxSize
			local v18 = v13 * v7.maxSize
			local v19 = v15 * v7.maxSize

			if v17 > 0.001 and v18 > 0.001 and v19 > 0.001 then
				local vector2 = Vector3.new(v17, v18, v19)

				if v7.mesh then
					v7.mesh.Scale = vector2
				end

				if v7.canSetSize then
					part.Size = vector2
				end
			end

			if spec.transparency then
				local transparency, hintTr = sampleNum(spec.transparency, v8, v7.hintTr)
				v7.hintTr = hintTr

				if spec.transferTransparency then
					if v7.cachedDecals then
						for _, cachedDecal in ipairs(v7.cachedDecals) do
							cachedDecal.Transparency = transparency
						end
					end
				else
					part.Transparency = transparency
				end
			end

			if spec.color then
				local v20, hintC = sampleColor(spec.color, v8, v7.hintC)
				v7.hintC = hintC
				local colorFactor = v7.colorFactor
				local color = Color3.new(v20.R * colorFactor, v20.G * colorFactor, v20.B * colorFactor)

				if spec.transferColor then
					if v7.cachedDecals then
						for _, cachedDecal in ipairs(v7.cachedDecals) do
							cachedDecal.Color3 = color
						end
					end
				else
					part.Color = color
				end
			end

			if spec.flipbookFrames and v7.cachedDecals then
				local flipbookFrames = spec.flipbookFrames
				local flipbookFrame = flipbookFrames[math.clamp(
					math.floor(v8 * #flipbookFrames) + 1,
					1,
					#flipbookFrames
				)]

				for _, cachedDecal in ipairs(v7.cachedDecals) do
					cachedDecal.Texture = flipbookFrame
				end
			end

			local v20, hintSpX = sampleNum(spec.spinX, v8, v7.hintSpX)
			v7.hintSpX = hintSpX
			local v22, hintSpY = sampleNum(spec.spinY, v8, v7.hintSpY)
			v7.hintSpY = hintSpY
			local v24, hintSpZ = sampleNum(spec.spinZ, v8, v7.hintSpZ)
			v7.hintSpZ = hintSpZ
			local v26 = v20 * (v7.maxSpin * p)
			local v27 = v22 * (v7.maxSpin * p)
			local v28 = v24 * (v7.maxSpin * p)

			if v26 ~= 0 or v27 ~= 0 or v28 ~= 0 then
				v7.rotAccum *= CFrame.Angles(math.rad(v26), math.rad(v27), (math.rad(v28)))
			end

			part.CFrame = CFrame.new(v10) * v7.baseRot * v7.rotAccum
			v6 += 1
		end
	end

	if #v2 == 0 and next(v4) == nil and heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureHeartbeat()
	if heartbeatConnection then
		return
	end

	heartbeatConnection = RunService.Heartbeat:Connect(tick)
end

fn = function(spec, cframe: CFrame, p)
	local DISTANCE_EPSILON = 0.001
	local template = spec.template

	if not (template and template:IsA("BasePart")) then
		return
	end

	local clone = template:Clone()
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone.CastShadow = false
	clone.Massless = true

	if spec.material then
		pcall(function()
			clone.Material = Enum.Material[spec.material]
		end)
	end

	local dataModelMesh = clone:FindFirstChildWhichIsA("DataModelMesh")
	local decals

	if spec.flipbookFrames or spec.transferColor or spec.transferTransparency then
		decals = {}

		for _, decal in ipairs(clone:GetChildren()) do
			if decal:IsA("Decal") then
				table.insert(decals, decal)
			end
		end

		if #decals == 0 then
			decals = nil
		end
	end

	local canSetSize = pcall(function()
		clone.Size = clone.Size
	end)
	local v7 = randInRange(spec.rotX) -- equivalent call inferred; original call site unknown
	local v8 = -math.rad(v7)
	local v9 = randInRange(spec.rotY) -- equivalent call inferred; original call site unknown
	local v10 = -math.rad(v9)
	local v11 = randInRange(spec.rotZ) -- equivalent call inferred; original call site unknown
	local cframe2 = CFrame.fromOrientation(v8, v10, -math.rad(v11))
	local cframe3 = CFrame.Angles(
		(math.random() - 0.5) * 2 * math.rad(spec.spreadAngle.X),
		(math.random() - 0.5) * 2 * math.rad(spec.spreadAngle.Y),
		0
	)
	local emissionDirection = spec.emissionDirection
	local lookVector = cframe:VectorToWorldSpace((cframe3:VectorToWorldSpace(emissionDirection.Magnitude < DISTANCE_EPSILON and createVector(
		0,
		1,
		0
	) or emissionDirection)))

	if lookVector.Magnitude < DISTANCE_EPSILON then
		lookVector = cframe.LookVector
	end

	local unit = lookVector.Unit
	local baseRot

	if spec.faceVelocity then
		local frontVector = spec.frontVector
		baseRot = alignVecToVec(
			(frontVector.Magnitude < DISTANCE_EPSILON and createVector(0, 0, -1) or frontVector).Unit,
			unit
		)
	else
		baseRot = cframe * cframe3 - cframe.Position
	end

	clone.CFrame = CFrame.new(cframe.Position) * baseRot * cframe2
	local v13 = {
		part = clone,
		mesh = dataModelMesh,
		cachedDecals = decals,
		canSetSize = canSetSize,
		spec = spec,
		sourceParent = p.Parent,
		t0 = os.clock(),
		lifetime = 0,
		velocity = 0,
		drag = 0,
		maxSize = 0,
		colorFactor = 0,
		maxSpin = 0,
		baseRot = 0,
		rotAccum = 0,
		hintSx = 1,
		hintSy = 1,
		hintSz = 1,
		hintTr = 1,
		hintC = 1,
		hintSpX = 1,
		hintSpY = 1,
		hintSpZ = 1
	}
	local v14 = randInRange(spec.lifetime) -- equivalent call inferred; original call site unknown
	v13.lifetime = math.max(v14, 0.001)
	local v15 = randInRange(spec.speed) -- equivalent call inferred; original call site unknown
	v13.velocity = unit * v15 * MeshEmit.SPEED_SCALE
	local v16 = randInRange(spec.drag) -- equivalent call inferred; original call site unknown
	v13.drag = v16 * MeshEmit.DRAG_SCALE
	local maxSize = randInRange(spec.maxSize) -- equivalent call inferred; original call site unknown
	v13.maxSize = maxSize
	local colorFactor = randInRange(spec.colorFactor) -- equivalent call inferred; original call site unknown
	v13.colorFactor = colorFactor
	local maxSpin = randInRange(spec.maxSpin) -- equivalent call inferred; original call site unknown
	v13.maxSpin = maxSpin
	v13.baseRot = baseRot
	v13.rotAccum = cframe2
	clone.Parent = getContainer()
	v2[#v2 + 1] = v13
	ensureHeartbeat() -- equivalent call inferred; original call site unknown
end

local function isEmitter(instance)
	if instance:GetAttribute("Lifetime") == nil then
		return CollectionService:HasTag(instance, "MeshEmitter")
	end

	return true
end

local function resolveAnchor(p, cframe: CFrame?)
	if cframe then
		return cframe
	end

	local parent = p.Parent

	if parent and parent:IsA("Attachment") then
		return parent.WorldCFrame
	end

	if parent and parent:IsA("BasePart") then
		return parent.CFrame
	end

	return nil
end

local function beginEmission(instance, spec, rate: number, duration: number, cframe: CFrame?)
	if rate <= 0 then
		return
	end

	v4[instance] = {
		spec = spec,
		emitter = instance,
		anchorOverride = cframe,
		rate = rate,
		duration = duration,
		startT = os.clock(),
		accum = 0
	}
	ensureHeartbeat() -- equivalent call inferred; original call site unknown
end

local function emitOne(instance, p: number?, cframe: CFrame?)
	local spec = getSpec(instance)

	if not spec.template then
		return
	end

	local emitDelay = tonumber(instance:GetAttribute("EmitDelay")) or 0
	local v6 = p or tonumber(instance:GetAttribute("EmitCount")) or 0
	local rate = p ~= nil and 0 or tonumber(instance:GetAttribute("Rate")) or 0
	local duration = p ~= nil and 0 or tonumber(instance:GetAttribute("EmitDuration")) or 0

	local function doFire()
		if not instance.Parent then
			return
		end

		local emitter = instance
		local worldCFrame = cframe

		if not worldCFrame then
			local parent = emitter.Parent

			if parent and parent:IsA("Attachment") then
				worldCFrame = parent.WorldCFrame
			elseif parent and parent:IsA("BasePart") then
				worldCFrame = parent.CFrame
			else
				worldCFrame = nil
			end
		end

		if not worldCFrame then
			return
		end

		for _ = 1, v6 do
			fn(spec, worldCFrame, instance)
		end

		if rate > 0 and duration > 0 then
			beginEmission(instance, spec, rate, duration, cframe)
		end
	end

	if not (emitDelay > 0) then
		doFire()
		return
	end

	local v9 = v5[instance]

	if not v9 then
		v9 = {}
		v5[instance] = v9
	end

	local v10 = {}
	v9[v10] = true
	task.delay(emitDelay, function()
		local v11 = v5[instance]

		if not (v11 and v11[v10]) then
			return
		end

		v11[v10] = nil

		if not next(v11) then
			v5[instance] = nil
		end

		doFire()
	end)
end

function MeshEmit.Emit(folder, p: number?, cframe: CFrame?)
	if folder:GetAttribute("Lifetime") ~= nil or CollectionService:HasTag(folder, "MeshEmitter") then
		emitOne(folder, p, cframe)
		return
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:GetAttribute("Lifetime") ~= nil or CollectionService:HasTag(descendant, "MeshEmitter") then
			emitOne(descendant, p, cframe)
		end
	end
end

function MeshEmit.Enable(instance, p: number?, cframe: CFrame?)
	local spec = getSpec(instance)

	if not spec.template then
		return
	end

	local rate = tonumber(instance:GetAttribute("Rate")) or 0
	beginEmission(instance, spec, rate, p or tonumber(instance:GetAttribute("EmitDuration")) or 0, cframe)
end

function MeshEmit.Disable(p)
	v4[p] = nil
	v5[p] = nil
end

function MeshEmit.Invalidate(p)
	object[p] = nil
	local connection = object2[p]

	if connection then
		connection:Disconnect()
	end

	object2[p] = nil
end

function MeshEmit.ClearCache()
	for k in pairs(object) do
		object[k] = nil
	end

	for k, connection in pairs(object2) do
		if connection then
			connection:Disconnect()
		end

		object2[k] = nil
	end
end

function MeshEmit.StopAll()
	for k in pairs(v4) do
		v4[k] = nil
	end

	for k in pairs(v5) do
		v5[k] = nil
	end

	for i = #v2, 1, -1 do
		local v6 = v2[i]

		if v6 and v6.part then
			local v7 = v6
			pcall(function()
				v7.part:Destroy()
			end)
		end

		v2[i] = nil
	end

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

return MeshEmit