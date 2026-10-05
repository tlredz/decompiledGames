local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local utilities = script.Parent.Parent.Utilities
local OuwmitUtility = require(utilities.OuwmitUtility)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ParticleBudget = require(ReplicatedStorage.CAM.Client.Modules.Effects.ParticleBudget)
require(utilities.Types)
local Tween = require(utilities.Tween)
local Bezier = require(utilities.Bezier)
local Shape = require(utilities.Shape)
local Oklab = require(utilities.color.Oklab)
local v = {
	Box = {
		Volume = Shape.getPointWithinBox,
		Surface = Shape.getPointOnBox
	},
	Cylinder = {
		Volume = function(p, p2, p3, p4, p5)
			return Shape.getPointWithinCylinder(p, 0, p5, p2, p3, p4)
		end,
		Surface = function(p, p2, p3, p4, p5)
			return Shape.getPointWithinCylinder(p, 1, p5, p2, p3, p4)
		end
	},
	Sphere = {
		Volume = function(p, p2, p3, p4, p5)
			return Shape.getPointWithinSphere(p, 0, p5, p2, p3, p4)
		end,
		Surface = function(p, p2, p3, p4, p5)
			return Shape.getPointWithinSphere(p, 1, p5, p2, p3, p4)
		end
	},
	Disc = {
		Volume = function(p, p2, p3, p4, p5)
			return Shape.getPointWithinDisc(p, 0, p5, p2, p3, p4)
		end,
		Surface = function(p, p2, p3, p4, p5)
			return Shape.getPointWithinDisc(p, 1, p5, p2, p3, p4)
		end
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getDebreeParent()
	return workspace:FindFirstChild("Debree") or workspace.Terrain
end

local function enumAttribute(p, p2: string, p3: string, list)
	local attribute = OuwmitUtility.GetAttribute(p, p2, p3)

	if table.find(list, attribute) == nil then
		return p3
	end

	return attribute
end

-- equivalent calls inferred from this helper; original call sites unknown
local function curveBezier(attribute: string)
	return Bezier.new(OuwmitUtility.deserializePath(attribute), 0)
end

local function colorAtTimeOklab(sequence, p: number)
	local keypoints = sequence.Keypoints

	if p <= keypoints[1].Time then
		return keypoints[1].Value
	end

	if keypoints[#keypoints].Time <= p then
		return keypoints[#keypoints].Value
	end

	local v2 = nil
	local v3 = nil

	for i = 1, #keypoints do
		local keypoint = keypoints[i]

		if keypoint.Time == p then
			return keypoint.Value
		end

		if keypoint.Time < p then
			v2 = keypoint
		else
			v3 = keypoint
			break
		end
	end

	if v2 and v3 then
		local v4 = (p - v2.Time) / (v3.Time - v2.Time)
		return Oklab.toSRGB(Oklab.fromSRGB(v2.Value):Lerp(Oklab.fromSRGB(v3.Value), v4))
	else
		return keypoints[1].Value
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function colorWithEasing(p, value: number, object)
	local v2 = 1 - object:getEase((math.clamp(value, 0, 1))).y
	return colorAtTimeOklab(p, math.clamp(v2, 0, 1))
end

local function perpendicular(vector2: Vector3)
	local cross = vector2:Cross(createVector(0, 1, 0))

	if cross.Magnitude < 0.001 then
		cross = vector2:Cross(createVector(0, 0, 1))
	end

	local unit = cross.Unit
	return unit, vector2:Cross(unit).Unit
end

-- equivalent calls inferred from this helper; original call sites unknown
local function jaggedOffset(object, range: NumberRange, p: number, p2: number, unit: Vector3, unit2: Vector3)
	local v2 = math.min(object:NextNumber(range.Min, range.Max) * p * p2, p2 * 0.8)
	local number = object:NextNumber(0, 6.283185307179586)
	return (unit * math.cos(number) + unit2 * math.sin(number)) * v2
end

local function pathPoints(random, p: number, getPos, rangeAttribute: NumberRange, attribute: number)
	local result = table.create(p + 1)
	local v2 = 1 / p
	result[1] = getPos(0)
	local v3 = result[1]

	for i = 1, p - 1 do
		local v4 = i * v2
		local v5 = getPos(v4)
		local v6 = getPos((math.min(v4 + 0.01, 1))) - v5
		local vector2 = not (v6.Magnitude > 0.001) and createVector(0, 1, 0) or v6.Unit
		local cross = vector2:Cross(createVector(0, 1, 0))

		if cross.Magnitude < 0.001 then
			cross = vector2:Cross(createVector(0, 0, 1))
		end

		local unit = cross.Unit
		local unit2 = vector2:Cross(unit).Unit
		v3 = v5 + jaggedOffset(random, rangeAttribute, attribute, (v5 - v3).Magnitude, unit, unit2)
		result[i + 1] = v3
	end

	result[p + 1] = getPos(1)
	return result
end

local function projectilePoints(random, p: number, vector2: Vector3, vector3: Vector3, rangeAttribute: NumberRange, attribute: number, vector4: Vector3)
	local result = table.create(p + 1)
	local v2 = 1 / p
	local v3 = vector3 - vector2
	local magnitude = v3.Magnitude

	if magnitude > 0.001 then
		vector4 = v3 / magnitude
	end

	local cross = vector4:Cross(createVector(0, 1, 0))

	if cross.Magnitude < 0.001 then
		cross = vector4:Cross(createVector(0, 0, 1))
	end

	local unit = cross.Unit
	local unit2 = vector4:Cross(unit).Unit
	local v4 = magnitude * v2
	result[1] = vector2

	for i = 1, p - 1 do
		local v5 = i + 1
		result[v5] = vector2:Lerp(vector3, i * v2) + jaggedOffset(random, rangeAttribute, attribute, v4, unit, unit2)
	end

	result[p + 1] = vector3
	return result
end

local function blendedPosition(p: number, callback, vector2: Vector3, vector3: Vector3, data)
	local v2 = (1 - p) * data.boltLength
	local v3 = math.clamp((data.distanceTraveled - v2) / data.transitionBuffer, 0, 1)
	local v4 = math.min(data.distanceTraveled / data.boltLength, 1) * data.curvedLengthT
	return callback((math.min(1, data.curvedTailT + p * data.curvedLengthT + v4))):Lerp(vector2:Lerp(vector3, p), v3)
end

local function transitionPoints(random, p: number, getPos, vector2: Vector3, vector3: Vector3, rangeAttribute: NumberRange, attribute: number, vector4: Vector3, p2)
	local result = table.create(p + 1)
	local result2 = table.create(p + 1)
	local v2 = 1 / p
	local v3 = vector3 - vector2
	local magnitude = v3.Magnitude

	if magnitude > 0.001 then
		vector4 = v3 / magnitude
	end

	local cross = vector4:Cross(createVector(0, 1, 0))

	if cross.Magnitude < 0.001 then
		cross = vector4:Cross(createVector(0, 0, 1))
	end

	local unit = cross.Unit
	local unit2 = vector4:Cross(unit).Unit
	local v4 = magnitude * v2

	for i = 0, p do
		local v5 = blendedPosition(i * v2, getPos, vector2, vector3, p2)

		if i == 0 or i == p then
			result[i + 1] = v5
			result2[i + 1] = createVector(0, 0, 0)
		else
			local v6 = jaggedOffset(random, rangeAttribute, attribute, v4, unit, unit2) -- equivalent call inferred; original call site unknown
			result[i + 1] = v5 + v6
			result2[i + 1] = v6
		end
	end

	return result, result2
end

local function updateTransitionPoints(p: number, getPos, vector2: Vector3, vector3: Vector3, p2)
	local result = table.create(p + 1)
	local v2 = 1 / p
	local jaggedOffsets = p2.jaggedOffsets

	for i = 0, p do
		result[i + 1] = blendedPosition(i * v2, getPos, vector2, vector3, p2) + (not jaggedOffsets and createVector(
			0,
			0,
			0
		) or jaggedOffsets[i + 1])
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function transitionComplete(data)
	return data.distanceTraveled >= data.boltLength + data.transitionBuffer
end

return function(instance, p, callback)
	local points = instance:FindFirstChild("Points")

	if not (points and points:IsA("Attachment")) then
		return
	end

	local part = instance:FindFirstChildOfClass("Part")

	if not part then
		return
	end

	local durationScale = OuwmitUtility.DurationScale(p)
	local v2 = OuwmitUtility.GetAttribute(instance, "EmitDelay", 0) * durationScale
	local scaled = ParticleBudget.Scale(OuwmitUtility.GetAttribute(instance, "EmitCount", 1), p and p.Owner, instance) or 0
	local v3 = OuwmitUtility.GetAttribute(instance, "EmitDuration", 0) * durationScale
	local v4 = OuwmitUtility.GetAttribute(instance, "DestroyDelay", 0) * durationScale
	local rangeAttribute = OuwmitUtility.GetRangeAttribute(
		instance,
		"Duration",
		NumberRange.new(1, 1),
		NumberRange.new(0, 1e999)
	)
	local attribute = OuwmitUtility.GetAttribute(instance, "Shape", "Box")
	local v5 = table.find({
		"Box",
		"Cylinder",
		"Sphere",
		"Disc"
	}, attribute) == nil and "Box" or attribute
	local attribute2 = OuwmitUtility.GetAttribute(instance, "ShapeStyle", "Volume")
	local v6 = table.find({ "Volume", "Surface" }, attribute2) == nil and "Volume" or attribute2
	local attribute3 = OuwmitUtility.GetAttribute(instance, "ShapeFace", "Outward")
	local v7 = table.find({ "InAndOut", "Inward", "Outward" }, attribute3) == nil and "Outward" or attribute3
	local normalId = Enum.NormalId
	local attribute4 = OuwmitUtility.GetAttribute(instance, "EmissionDirection", "Top")
	local v8 = normalId[table.find({
		"Top",
		"Bottom",
		"Left",
		"Right",
		"Front",
		"Back"
	}, attribute4) == nil and "Top" or attribute4]
	local attribute5 = OuwmitUtility.GetAttribute(instance, "SpreadAngle", createVector(0, 0, 0))
	local attribute6 = OuwmitUtility.GetAttribute(instance, "ShapePartial", 1)
	local attribute7 = OuwmitUtility.GetAttribute(instance, "SyncPosition", false)
	local attribute8 = OuwmitUtility.GetAttribute(instance, "MirrorPaths", true)
	local attribute9 = OuwmitUtility.GetAttribute(instance, "MirrorRotation", createVector(0, 0, 180))
	local attribute10 = OuwmitUtility.GetAttribute(instance, "ProjectileEnabled", false)
	local attribute11 = OuwmitUtility.GetAttribute(instance, "MatchEndDirection", false)
	local attribute12 = OuwmitUtility.GetAttribute(instance, "ProjectileSpeed", 30)
	local rangeAttribute2 = OuwmitUtility.GetRangeAttribute(
		instance,
		"ProjectileLifetime",
		NumberRange.new(1, 1),
		NumberRange.new(0, 1e999)
	)
	local attribute13 = OuwmitUtility.GetAttribute(instance, "HitboxEnabled", false)
	local attribute14 = OuwmitUtility.GetAttribute(instance, "HitboxCollisionGroup", "Default")
	local attribute15 = OuwmitUtility.GetAttribute(instance, "HitboxFilterTag", "")
	local attribute16 = OuwmitUtility.GetAttribute(instance, "HitboxFilterType", "Exclude")
	local attribute17 = OuwmitUtility.GetAttribute(instance, "HitboxIgnoreCanCollide", false)
	local attribute18 = OuwmitUtility.GetAttribute(instance, "Speed_Start", 1)
	local attribute19 = OuwmitUtility.GetAttribute(instance, "Speed_End", 1)
	local v9 = math.max(OuwmitUtility.GetAttribute(instance, "Segments", 8), 2)
	local rangeAttribute3 = OuwmitUtility.GetRangeAttribute(
		instance,
		"Jaggedness",
		NumberRange.new(0.5, 1),
		NumberRange.new(0, 1e999)
	)
	local attribute20 = OuwmitUtility.GetAttribute(instance, "OffsetScale", 1)
	local attribute21 = OuwmitUtility.GetAttribute(instance, "RefreshRate", 15)
	local attribute22 = OuwmitUtility.GetAttribute(instance, "IndependentSegments", false)
	local attribute23 = OuwmitUtility.GetAttribute(instance, "RefreshDuringDissipate", false)
	local attribute24 = OuwmitUtility.GetAttribute(instance, "NestedEffectMode", "None")
	local v10 = table.find({
		"None",
		"All",
		"Head",
		"Tail"
	}, attribute24) == nil and "None" or attribute24
	local attribute25 = OuwmitUtility.GetAttribute(instance, "Color", ColorSequence.new(Color3.new(1, 1, 1)))
	local v11 = curveBezier(OuwmitUtility.GetAttribute(instance, "Color_Curve", OuwmitUtility.linear_bezier)) -- equivalent call inferred; original call site unknown
	local v12 = math.max(OuwmitUtility.GetAttribute(instance, "Color_Duration", 1) * durationScale, 0.001)
	local attribute27 = OuwmitUtility.GetAttribute(instance, "Transparency_Start", 0)
	local attribute28 = OuwmitUtility.GetAttribute(instance, "Transparency_End", 0)
	local attribute29 = OuwmitUtility.GetAttribute(instance, "Fill_Color", ColorSequence.new(Color3.new(1, 1, 1)))
	local v13 = curveBezier(OuwmitUtility.GetAttribute(instance, "Fill_Color_Curve", OuwmitUtility.linear_bezier)) -- equivalent call inferred; original call site unknown
	local v14 = math.max(OuwmitUtility.GetAttribute(instance, "Fill_Color_Duration", 1) * durationScale, 0.001)
	local attribute31 = OuwmitUtility.GetAttribute(instance, "Fill_Transparency_Start", 1)
	local attribute32 = OuwmitUtility.GetAttribute(instance, "Fill_Transparency_End", 1)
	local attribute33 = OuwmitUtility.GetAttribute(instance, "Fill_DepthMode", "Occluded")
	local v15 = table.find({ "AlwaysOnTop", "Occluded" }, attribute33) == nil and "Occluded" or attribute33
	local attribute34 = OuwmitUtility.GetAttribute(instance, "Fade_In_Start", 1)
	local v16 = OuwmitUtility.GetAttribute(instance, "Fade_In_Duration", 0) * durationScale
	local v17 = curveBezier(OuwmitUtility.GetAttribute(instance, "Fade_In_Curve", OuwmitUtility.default_bezier)) -- equivalent call inferred; original call site unknown
	local attribute36 = OuwmitUtility.GetAttribute(instance, "Fade_Out_End", 1)
	local v18 = OuwmitUtility.GetAttribute(instance, "Fade_Out_Duration", 0) * durationScale
	local attribute37 = OuwmitUtility.GetAttribute(instance, "Fade_Out_Curve", OuwmitUtility.default_bezier)
	local v19 = curveBezier(attribute37) -- equivalent call inferred; original call site unknown
	local attribute38 = OuwmitUtility.GetAttribute(instance, "Length_Start", 1)
	local attribute39 = OuwmitUtility.GetAttribute(instance, "Length_End", 1)
	local attribute40 = OuwmitUtility.GetAttribute(instance, "Dissipate_Mode", "None")
	local v20 = table.find({ "None", "Retract", "Scale" }, attribute40) == nil and "None" or attribute40
	local v21 = OuwmitUtility.GetAttribute(instance, "Dissipate_Duration", 0.5) * durationScale
	local attribute41 = OuwmitUtility.GetAttribute(instance, "Dissipate_Curve", OuwmitUtility.default_bezier)
	local attribute42 = OuwmitUtility.GetAttribute(instance, "Width_Start", 2)
	local attribute43 = OuwmitUtility.GetAttribute(instance, "Width_End", 0.2)
	local v22 = v[v5] and v[v5][v6]

	if not v22 then
		warn((`invalid lightning Shape/ShapeStyle '{tostring(v5)}/{tostring(v6)}' on {instance:GetFullName()}`))
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fallbackRotation()
		return Shape.getSurfaceCFrame(CFrame.identity, Vector3.FromNormalId(v8), createVector(0, 0, 0)).Rotation
	end

	local function emitBurst()
		if scaled <= 0 then
			return
		end

		local parent = instance.Parent

		if not parent then
			return
		end

		if not (parent:IsA("BasePart") or parent:IsA("Attachment")) then
			parent = instance
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getOriginCFrame()
			if parent:IsA("BasePart") or parent:IsA("Attachment") then
				return OuwmitUtility.OriginCFrame(parent)
			end

			return CFrame.identity
		end

		local originCFrame = getOriginCFrame() -- equivalent call inferred; original call site unknown
		local attachment = instance:FindFirstChild("End")
		local T1 = attachment and attachment:FindFirstChild("T1")

		if attachment and not attachment:IsA("Attachment") then
			attachment = nil
		end

		if T1 and not T1:IsA("Attachment") then
			T1 = nil
		end

		local bezierPoints = OuwmitUtility.getBezierPoints(points)
		local random = Random.new()
		local v23 = not attachment and Bezier.new(bezierPoints)
		local overlapParams

		if attribute13 then
			overlapParams = OverlapParams.new()
			overlapParams.MaxParts = 1

			if not pcall(function()
				overlapParams.FilterType = Enum.RaycastFilterType[attribute16]
			end) then
				overlapParams.FilterType = Enum.RaycastFilterType.Exclude
			end

			overlapParams.CollisionGroup = attribute14
			overlapParams.RespectCanCollide = not attribute17

			if attribute15 ~= "" then
				overlapParams:AddToFilter(CollectionService:GetTagged(attribute15))
			end

			if overlapParams.FilterType == Enum.RaycastFilterType.Exclude then
				local parts = { workspace.Terrain, parent }
				local part2 = points:FindFirstAncestorOfClass("Part")

				if part2 then
					table.insert(parts, part2)
				end

				overlapParams:AddToFilter(parts)
			end
		else
			overlapParams = nil
		end

		local parent2 = p and p.Parent or getDebreeParent()

		for _ = 1, scaled do
			local v24 = random:NextNumber(rangeAttribute.Min, rangeAttribute.Max) * durationScale
			local v25 = not attribute10 and 0 or random:NextNumber(rangeAttribute2.Min, rangeAttribute2.Max) * durationScale or 0
			local v26 = table.create(v9)
			local model = nil
			local success, result = pcall(function()
				local v30

				if parent:IsA("BasePart") then
					v30 = v22(nil, originCFrame, parent.Size, v8, attribute6) or originCFrame * fallbackRotation()
				else
					v30 = originCFrame * fallbackRotation()
				end

				local vector2 = Vector3.FromNormalId(v8)
				local cross = vector2:Cross(originCFrame.LookVector)

				if cross.Magnitude < 0.001 then
					cross = vector2:Cross(originCFrame.UpVector)
				end

				local v31 = v30 * (CFrame.fromAxisAngle(
					vector2,
					(math.rad((random:NextNumber(-attribute5.x, attribute5.x))))
				) * CFrame.fromAxisAngle(cross, (math.rad((random:NextNumber(-attribute5.y, attribute5.y))))))

				if v7 == "Inward" or v7 == "InAndOut" and random:NextInteger(0, 1) == 1 then
					v31 *= CFrame.fromOrientation(0, 3.141592653589793, 0)
				end

				if attachment and attribute8 and (v31.Position - attachment.WorldPosition).Unit:Dot(v31.RightVector) >= 0 then
					local v32 = attribute9 * OuwmitUtility.DEG_TO_RAD
					v31 *= CFrame.fromOrientation(v32.x, v32.y, v32.z)
				end

				local v32 = v23

				if attachment then
					local worldPositions = {}

					for k, bezierPoint in bezierPoints do
						local worldPosition

						if k == #bezierPoints - 1 then
							worldPosition = T1 and T1.WorldPosition or attachment.WorldPosition
						elseif k == #bezierPoints then
							worldPosition = attachment.WorldPosition
						else
							worldPosition = v31 * (bezierPoint - bezierPoints[1])
						end

						table.insert(worldPositions, worldPosition)
					end

					v32 = Bezier.new(worldPositions)
				end

				local function getPos(p2: number)
					local positionArcSpace = v32:getPositionArcSpace(p2)

					if attachment then
						return positionArcSpace
					end

					return v31 * (positionArcSpace - bezierPoints[1])
				end

				local v33 = attribute31 < 1 or attribute32 < 1
				local highlight

				if v33 then
					model = Instance.new("Model")
					model.Name = "LightningContainer"
					model.Parent = parent2
					highlight = Instance.new("Highlight")
					highlight.Adornee = model
					local v35 = 1 - v13:getEase(0).y
					highlight.FillColor = colorAtTimeOklab(attribute29, math.clamp(v35, 0, 1))
					highlight.FillTransparency = attribute31
					highlight.OutlineTransparency = 1
					highlight.DepthMode = Enum.HighlightDepthMode[v15]
					highlight.Parent = model
				else
					highlight = nil
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function shouldEmitNested(i: number)
					if v10 == "All" then
						return true
					elseif v10 == "Head" then
						return i == v9
					end

					return v10 == "Tail" and i == 1
				end

				local clone

				if v10 == "None" then
					clone = nil
				else
					local emitOnFinish = part:FindFirstChild("EmitOnFinish")
					clone = emitOnFinish and emitOnFinish:Clone()
				end

				local parent3 = model or parent2
				local children = {}
				local v35 = {}

				for i = 1, v9 do
					local part2 = Instance.new("Part")
					OuwmitUtility.CopyProperties(part, part2, OuwmitUtility.COPY_PART_PROPERTIES)
					part2.Name = "--"
					part2.Locked = true
					part2.Size = Vector3.new(attribute42, attribute42, 1)
					part2.Transparency = 1
					part2.Anchored = true
					part2.CanQuery = false
					part2.CanTouch = false
					part2.CanCollide = false
					part2.Parent = parent3

					-- equivalent call inferred; original call site unknown
					if shouldEmitNested(i) then
						local clone2 = part:Clone()

						for i2, child in ipairs(clone2:GetChildren()) do
							if child.Name == "EmitOnFinish" then
								continue
							end

							child.Parent = part2

							if v10 == "Head" then
								table.insert(children, child)
							end
						end

						clone2:Destroy()
						table.insert(v35, i)
					end

					v26[i] = part2
				end

				local v36

				if v10 == "Head" and #children > 0 then
					for k, v37 in children do
						v37.Parent = v26[1]
					end

					v36 = 1
				else
					v36 = nil
				end

				for k, v37 in v35 do
					local v38 = v10 == "Head" and 1 or v37

					for i, child in ipairs(v26[v38]:GetChildren()) do
						callback(child, p)
					end
				end

				local v37 = table.create(v9)
				local v38 = table.create(v9)
				local v39 = 1 / v9

				for i = 1, v9 do
					v37[i] = {
						wasVisible = false
					}
					v38[i] = {
						start = (i - 1) * v39,
						finish = i * v39
					}
				end

				local flag = false
				local v40 = {}

				-- equivalent calls inferred from this helper; original call sites unknown
				local function track(p2)
					if p2 ~= nil then
						table.insert(v40, p2)
					end
				end

				local lerped = attribute18
				local initialWidth2 = attribute42
				local v42 = attribute38
				local initialTransparency2 = attribute27
				local fillTransparency = attribute31
				local v45 = 0
				local v46 = 0
				local total = 0
				local total2 = 0
				local flag2 = false
				local v47 = 0
				local v48 = 0
				local v49 = attribute42
				local v50 = 0
				local v51 = createVector(0, 0, 0)
				local v52 = createVector(0, 0, 0)
				local cframe = originCFrame
				local v53 = nil
				local v54 = nil
				local v55 = nil
				local v56 = nil
				local v57 = pathPoints(random, v9, getPos, rangeAttribute3, attribute20)

				local function destroyAll()
					for i, v58 in ipairs(v40) do
						v58()
					end

					for i, v58 in ipairs(v26) do
						v58:Destroy()
					end

					if model then
						model:Destroy()
					end
				end

				local function onFinish()
					if flag then
						return
					end

					flag = true
					local v58 = 0
					local children2 = clone and clone:GetChildren()

					if children2 and #children2 > 0 then
						local parent4 = v26[math.clamp(math.ceil(v50 * v9), 1, v9)]

						if parent4 and parent4.Parent ~= nil then
							for k, v60 in children2 do
								v60.Parent = parent4
							end

							callback(children2, p)
							v58 = OuwmitUtility.GetAttribute(instance, "EmitOnFinishLifetime", 0) * durationScale
						end
					end

					if clone then
						clone:Destroy()
					end

					if v58 > 0 then
						task.delay(v58, destroyAll)
					else
						destroyAll()
					end
				end

				local function alive()
					local v58 = v26[1]
					return v58 ~= nil and v58:IsDescendantOf(game)
				end

				local v58

				if attribute18 == attribute19 or instance:GetAttribute("SpeedOverride") then
					v58 = false
				else
					v58 = true
					track(Tween.new(
						OuwmitUtility.GetAttribute(instance, "Speed_Curve", OuwmitUtility.default_bezier),
						OuwmitUtility.GetAttribute(instance, "Speed_Duration", 0.1) * durationScale,
						function(p2, p3)
							lerped = OuwmitUtility.lerp(attribute18, attribute19, p2)
							return p3
						end,
						function()
							v58 = false
						end
					)) -- equivalent call inferred; original call site unknown
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function rampLive()
					return v58 or instance:GetAttribute("SpeedTweening") == true
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function effectiveSpeed()
					return instance:GetAttribute("SpeedOverride") or lerped
				end

				local function speedDelta(p2: number, flag3: boolean?)
					local v59 = effectiveSpeed() -- equivalent call inferred; original call site unknown
					lerped = v59

					if v59 > 0 or flag3 or rampLive() then
						return p2 * v59
					end

					return nil
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function headSegmentIndex()
					return (math.clamp(math.ceil(v50 * v9), 1, v9))
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function shapecast()
					if not attribute13 then
						return false
					end

					local v59 = v26[math.clamp(math.ceil(v50 * v9), 1, v9)]

					if v59 and v59.Parent ~= nil and v59.Transparency < 1 then
						return workspace:GetPartsInPart(v59, overlapParams)[1] ~= nil
					end

					return false
				end

				local function refreshPoints()
					if v54 and v55 and v53 then
						if v56 and not transitionComplete(v56) then
							local v60 = v56
							local v61, jaggedOffsets = transitionPoints(
								random,
								v9,
								getPos,
								v55,
								v54,
								rangeAttribute3,
								attribute20,
								v53,
								v56
							)
							v57 = v61
							v60.jaggedOffsets = jaggedOffsets
							return
						end

						v57 = projectilePoints(random, v9, v55, v54, rangeAttribute3, attribute20, v53)

						if v56 then
							v56.jaggedOffsets = nil
						end
					else
						v57 = pathPoints(random, v9, getPos, rangeAttribute3, attribute20)
					end
				end

				local function slidePoints(p2: number)
					if v56 and not transitionComplete(v56) then
						if v56.jaggedOffsets then
							v57 = updateTransitionPoints(v9, getPos, v55, v54, v56)
							return
						end

						local v60 = v56
						local v61, jaggedOffsets = transitionPoints(
							random,
							v9,
							getPos,
							v55,
							v54,
							rangeAttribute3,
							attribute20,
							v53,
							v56
						)
						v57 = v61
						v60.jaggedOffsets = jaggedOffsets
						return
					end

					local v59 = v53 * attribute12 * p2

					for i = 1, #v57 do
						v57[i] += v59
					end
				end

				local function updateSegments(p2: number, p3: number?, p4: number, flag3: boolean?, p5: number?)
					local now = os.clock()
					v50 = p2
					local v59 = p3 or math.max(0, p2 - v42)
					local v60 = p5 or initialWidth2

					if flag3 ~= false and attribute21 > 0 then
						total += p4
						local v61 = total

						if 1 / attribute21 <= v61 then
							refreshPoints()
							total = 0
						end
					end

					for i = 1, v9 do
						local v61 = v37[i]
						local v62 = v38[i]
						local v63 = v26[i]
						local start = v62.start
						local finish = v62.finish
						local v64

						if v59 < finish then
							v64 = start < p2
						else
							v64 = false
						end

						if v64 then
							if not v61.wasVisible then
								v61.wasVisible = true
								v61.birthTime = now
								v61.initialWidth = initialWidth2
								v61.initialTransparency = initialTransparency2
							end

							v63.Color = colorWithEasing(attribute25, v45, v11)
							local initialTransparency

							if attribute22 and v61.initialTransparency then
								initialTransparency = v61.initialTransparency
							else
								initialTransparency = initialTransparency2
							end

							local v66 = not (v16 > 0) and 1 or math.clamp(total2 / v16, 0, 1)
							local lerped2 = OuwmitUtility.lerp(attribute34, initialTransparency, 1 - v17:getEase(v66).y)
							local lerped3

							if flag2 and v18 > 0 then
								local v67 = math.clamp(v47 / v18, 0, 1)
								lerped3 = OuwmitUtility.lerp(initialTransparency, attribute36, 1 - v19:getEase(v67).y)
							else
								lerped3 = initialTransparency
							end

							if v66 < 1 then
								initialTransparency = lerped2
							elseif flag2 then
								initialTransparency = lerped3
							end

							v63.Transparency = initialTransparency
							local initialWidth

							if p5 then
								local v67

								if attribute22 and v61.initialWidth then
									v67 = v61.initialWidth
								else
									v67 = initialWidth2
								end

								initialWidth = v67 * (not (initialWidth2 > 0) and 0 or p5 / initialWidth2)
							elseif attribute22 and v61.initialWidth then
								initialWidth = v61.initialWidth
							else
								initialWidth = v60
							end

							local v67 = v57[i]
							local v68 = v57[i + 1]

							if v67 and v68 then
								local v69

								if start < v59 then
									v69 = v67:Lerp(v68, (v59 - start) / (finish - start))
								else
									v69 = v67
								end

								if p2 < finish then
									v68 = v67:Lerp(v68, (p2 - start) / (finish - start))
								end

								local magnitude = (v68 - v69).Magnitude

								if magnitude > 0.001 then
									v63.Size = Vector3.new(initialWidth, initialWidth, magnitude)
									v63.CFrame = CFrame.lookAt((v69 + v68) / 2, v68)
								end
							end
						else
							v63.Transparency = 1

							if v61.wasVisible then
								v61.wasVisible = false
								v61.birthTime = nil
								v61.initialWidth = nil
								v61.initialTransparency = nil
							end
						end
					end

					if highlight then
						highlight.FillColor = colorWithEasing(attribute29, v46, v13)
						highlight.FillTransparency = fillTransparency
					end

					if v36 then
						local v61 = headSegmentIndex() -- equivalent call inferred; original call site unknown

						if v61 ~= v36 then
							local parent4 = v26[v61]

							for k, v63 in children do
								v63.Parent = parent4
							end

							v36 = v61
						end
					end

					local positionArcSpace = v32:getPositionArcSpace((math.min(p2, 1)))

					if not attachment then
						positionArcSpace = v31 * (positionArcSpace - bezierPoints[1])
					end

					if p4 > 0 then
						v51 = (positionArcSpace - v52) / p4
					end

					v52 = positionArcSpace
				end

				local function propertyTween(p2: string, p3: number, p4: number, p5: number, callback2)
					if p4 == p5 then
						return
					end

					track(Tween.new(
						OuwmitUtility.GetAttribute(instance, p2 .. "_Curve", OuwmitUtility.default_bezier),
						p3,
						function(p6, p7)
							local v60 = v26[1]
							local v61

							if v60 == nil then
								v61 = false
							else
								v61 = v60:IsDescendantOf(game)
							end

							if not v61 then
								return nil
							end

							callback2(OuwmitUtility.lerp(p4, p5, p6))
							return p7 * effectiveSpeed()
						end
					)) -- equivalent call inferred; original call site unknown
				end

				local v59 = v24
				local v60 = attribute42
				local v61 = attribute43

				local function fn(lerped2)
					initialWidth2 = lerped2
				end

				if v60 ~= v61 then
					track(Tween.new(
						OuwmitUtility.GetAttribute(instance, "Width_Curve", OuwmitUtility.default_bezier),
						v59,
						function(p2, p3)
							local v63 = v26[1]
							local v64

							if v63 == nil then
								v64 = false
							else
								v64 = v63:IsDescendantOf(game)
							end

							if not v64 then
								return nil
							end

							fn(OuwmitUtility.lerp(v60, v61, p2))
							return p3 * effectiveSpeed()
						end
					)) -- equivalent call inferred; original call site unknown
				end

				local v62 = v24
				local v63 = attribute27
				local v64 = attribute28

				local function fn2(lerped2)
					initialTransparency2 = lerped2
				end

				if v63 ~= v64 then
					track(Tween.new(
						OuwmitUtility.GetAttribute(instance, "Transparency_Curve", OuwmitUtility.default_bezier),
						v62,
						function(p2, p3)
							local v66 = v26[1]
							local v67

							if v66 == nil then
								v67 = false
							else
								v67 = v66:IsDescendantOf(game)
							end

							if not v67 then
								return nil
							end

							fn2(OuwmitUtility.lerp(v63, v64, p2))
							return p3 * effectiveSpeed()
						end
					)) -- equivalent call inferred; original call site unknown
				end

				local v65 = v24
				local v66 = attribute38
				local v67 = attribute39

				local function fn3(lerped2)
					v42 = lerped2
				end

				if v66 ~= v67 then
					track(Tween.new(
						OuwmitUtility.GetAttribute(instance, "Length_Curve", OuwmitUtility.default_bezier),
						v65,
						function(p2, p3)
							local v69 = v26[1]
							local v70

							if v69 == nil then
								v70 = false
							else
								v70 = v69:IsDescendantOf(game)
							end

							if not v70 then
								return nil
							end

							fn3(OuwmitUtility.lerp(v66, v67, p2))
							return p3 * effectiveSpeed()
						end
					)) -- equivalent call inferred; original call site unknown
				end

				if v33 then
					local v68 = v14
					local v69 = attribute31
					local v70 = attribute32

					local function fn4(lerped2)
						fillTransparency = lerped2
					end

					if v69 ~= v70 then
						track(Tween.new(
							OuwmitUtility.GetAttribute(instance, "FillTransparency_Curve", OuwmitUtility.default_bezier),
							v68,
							function(p2, p3)
								local v72 = v26[1]
								local v73

								if v72 == nil then
									v73 = false
								else
									v73 = v72:IsDescendantOf(game)
								end

								if not v73 then
									return nil
								end

								fn4(OuwmitUtility.lerp(v69, v70, p2))
								return p3 * effectiveSpeed()
							end
						)) -- equivalent call inferred; original call site unknown
					end
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function advanceColor(p2: number)
					v45 = (v45 + p2 / v12) % 1
					v46 = (v46 + p2 / v14) % 1
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function runDissipation(p2: number, p3: number, p4: number, p5: string, p6: number, p7: string)
					flag2 = true
					v48 = p3
					v49 = p4
					track(Tween.new(p5, p6, function(p8, p9, p10)
						local v69 = v26[1]
						local v70

						if v69 == nil then
							v70 = false
						else
							v70 = v69:IsDescendantOf(game)
						end

						if not v70 then
							onFinish()
							return nil
						end

						v47 = p10
						local v71 = p9 * effectiveSpeed()
						total2 += v71

						if attribute23 then
							advanceColor(v71) -- equivalent call inferred; original call site unknown
						end

						local lerped2

						if p7 == "Retract" then
							lerped2 = OuwmitUtility.lerp(v48, p2, p8)
						end

						local v72

						if p7 == "Scale" then
							v72 = OuwmitUtility.lerp(v49, 0, p8)
						end

						updateSegments(p2, lerped2, v71, attribute23, v72)
						local v73 = effectiveSpeed() -- equivalent call inferred; original call site unknown
						lerped = v73
						local v74 = v73 > 0
						return p9 * v73
					end, onFinish)) -- equivalent call inferred; original call site unknown
				end

				local function startDissipation()
					if flag2 or flag then
						return
					end

					local v68 = v50

					if v20 == "None" then
						if v18 > 0 then
							local v69 = math.max(0, v68 - v42)
							flag2 = true
							v48 = v69
							v49 = initialWidth2
							local v73 = "None"
							track(Tween.new(attribute37, v18, function(p2, p3, p4)
								local v75 = v26[1]
								local v76

								if v75 == nil then
									v76 = false
								else
									v76 = v75:IsDescendantOf(game)
								end

								if not v76 then
									onFinish()
									return nil
								end

								v47 = p4
								local v77 = p3 * effectiveSpeed()
								total2 += v77

								if attribute23 then
									advanceColor(v77) -- equivalent call inferred; original call site unknown
								end

								local lerped2

								if v73 == "Retract" then
									lerped2 = OuwmitUtility.lerp(v48, v68, p2)
								end

								local v78

								if v73 == "Scale" then
									v78 = OuwmitUtility.lerp(v49, 0, p2)
								end

								updateSegments(v68, lerped2, v77, attribute23, v78)
								local v79 = effectiveSpeed() -- equivalent call inferred; original call site unknown
								lerped = v79
								local v80 = v79 > 0
								return p3 * v79
							end, onFinish)) -- equivalent call inferred; original call site unknown
						else
							onFinish()
						end
					else
						runDissipation(v68, math.max(0, v68 - v42), initialWidth2, attribute41, v21, v20) -- equivalent call inferred; original call site unknown
					end
				end

				local function startProjectile()
					local lookVector

					if attribute11 and attachment then
						lookVector = attachment.WorldCFrame.LookVector
					else
						lookVector = v51.Unit
					end

					local v68 = (lookVector ~= lookVector or lookVector.Magnitude < 0.001) and createVector(0, 0, 1) or lookVector.Unit
					local positionArcSpace = v32:getPositionArcSpace(1)

					if not attachment then
						positionArcSpace = v31 * (positionArcSpace - bezierPoints[1])
					end

					local curvedTailT = math.max(0, 1 - v42)
					local positionArcSpace2 = v32:getPositionArcSpace(curvedTailT)

					if not attachment then
						positionArcSpace2 = v31 * (positionArcSpace2 - bezierPoints[1])
					end

					local magnitude = (positionArcSpace - positionArcSpace2).Magnitude
					local curvedLengthT = 1 - curvedTailT
					local jaggedOffsets = table.create(v9 + 1)

					for i = 0, v9 do
						local v72 = i + 1
						local v73 = v57[i + 1]
						local positionArcSpace3 = v32:getPositionArcSpace(curvedTailT + i / v9 * curvedLengthT)

						if not attachment then
							positionArcSpace3 = v31 * (positionArcSpace3 - bezierPoints[1])
						end

						jaggedOffsets[v72] = v73 - positionArcSpace3
					end

					v56 = {
						curvedTailT = curvedTailT,
						curvedLengthT = curvedLengthT,
						boltLength = magnitude,
						transitionBuffer = magnitude * 0.3,
						distanceTraveled = 0,
						jaggedOffsets = jaggedOffsets
					}
					track(Tween.new(OuwmitUtility.linear_bezier, v25, function(p2, p3, p4)
						local v73 = v26[1]
						local v74

						if v73 == nil then
							v74 = false
						else
							v74 = v73:IsDescendantOf(game)
						end

						if not v74 then
							onFinish()
							return nil
						end

						local v75 = p3 * effectiveSpeed()
						total2 += v75
						advanceColor(v75) -- equivalent call inferred; original call site unknown
						local distanceTraveled = p4 * attribute12
						v56.distanceTraveled = distanceTraveled
						v54 = positionArcSpace + v68 * distanceTraveled
						v55 = v54 - v68 * magnitude
						v53 = v68

						if attribute21 > 0 then
							total += v75
							local v77 = total

							if 1 / attribute21 <= v77 then
								refreshPoints()
								total = 0
							else
								slidePoints(p3)
							end
						else
							slidePoints(p3)
						end

						updateSegments(1, nil, v75, false)

						-- equivalent call inferred; original call site unknown
						if shapecast() then
							startDissipation()
							return nil
						end

						local v77 = effectiveSpeed() -- equivalent call inferred; original call site unknown
						lerped = v77
						local v78 = v77 > 0
						return p3 * v77
					end, startDissipation)) -- equivalent call inferred; original call site unknown
				end

				track(Tween.new(
					OuwmitUtility.GetAttribute(instance, "Easing_Curve", OuwmitUtility.linear_bezier),
					v24,
					function(p2, p3)
						local v69 = v26[1]
						local v70

						if v69 == nil then
							v70 = false
						else
							v70 = v69:IsDescendantOf(game)
						end

						if not v70 then
							onFinish()
							return nil
						end

						local v71 = p3 * effectiveSpeed()
						total2 += v71
						advanceColor(v71) -- equivalent call inferred; original call site unknown

						if attribute7 then
							local originCFrame2 = getOriginCFrame() -- equivalent call inferred; original call site unknown
							local cframe2 = originCFrame2 * cframe:Inverse()

							for i = 1, #v57 do
								v57[i] = cframe2:PointToWorldSpace(cframe:PointToObjectSpace(v57[i]))
							end

							cframe = originCFrame2
						end

						updateSegments(p2, nil, v71)

						-- equivalent call inferred; original call site unknown
						if shapecast() then
							startDissipation()
							return nil
						end

						local v72 = effectiveSpeed() -- equivalent call inferred; original call site unknown
						lerped = v72
						local v73

						if v72 > 0 or rampLive() then
							v73 = p3 * v72
						end

						if v73 == nil then
							onFinish()
							return nil
						end

						if not attribute10 then
							return v73
						end

						if v25 <= p2 * v24 then
							startDissipation()
							return nil
						end

						return v73
					end,
					function()
						if flag2 or flag then
							return
						end

						if attribute10 then
							startProjectile()
						elseif v4 > 0 then
							track(Tween.new(OuwmitUtility.linear_bezier, v4, function(p2, p3)
								local v70 = v26[1]
								local v71

								if v70 == nil then
									v71 = false
								else
									v71 = v70:IsDescendantOf(game)
								end

								if not v71 then
									onFinish()
									return nil
								end

								local v72 = p3 * effectiveSpeed()
								total2 += v72
								advanceColor(v72) -- equivalent call inferred; original call site unknown
								updateSegments(1, nil, v72, true)

								-- equivalent call inferred; original call site unknown
								if shapecast() then
									startDissipation()
									return nil
								end

								local v73 = effectiveSpeed() -- equivalent call inferred; original call site unknown
								lerped = v73
								local v74 = v73 > 0
								return p3 * v73
							end, startDissipation)) -- equivalent call inferred; original call site unknown
						else
							startDissipation()
						end
					end
				)) -- equivalent call inferred; original call site unknown
			end)

			if success then
				continue
			end

			warn((`Ouwmit failed to emit lightning '{instance:GetFullName()}': {result}`))

			for _, v30 in ipairs(v26) do
				if v30 ~= nil then
					v30:Destroy()
				end
			end

			if model then
				model:Destroy()
			end
		end
	end

	local function doEmit()
		if not (v3 > 0) then
			emitBurst()
			return
		end

		if attribute18 ~= attribute19 then
			instance:SetAttribute("SpeedOverride", attribute18)
			instance:SetAttribute("SpeedTweening", true)
			Tween.new(
				OuwmitUtility.GetAttribute(instance, "Speed_Curve", OuwmitUtility.default_bezier),
				OuwmitUtility.GetAttribute(instance, "Speed_Duration", 0.1) * durationScale,
				function(p2, p3)
					instance:SetAttribute("SpeedOverride", OuwmitUtility.lerp(attribute18, attribute19, p2))
					return p3
				end,
				function()
					instance:SetAttribute("SpeedTweening", nil)
				end
			)
		end

		task.spawn(function()
			local v23 = 1 / (instance:GetAttribute("Rate") or 5)
			local lastTime = os.clock()

			while os.clock() - lastTime < v3 and instance:IsDescendantOf(game) do
				emitBurst()
				task.wait(v23)
			end

			instance:SetAttribute("SpeedOverride", nil)
			instance:SetAttribute("SpeedTweening", nil)
		end)
	end

	if v2 > 0 then
		task.delay(v2, doEmit)
	else
		doEmit()
	end
end