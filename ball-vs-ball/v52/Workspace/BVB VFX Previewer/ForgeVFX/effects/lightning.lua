local createVector = vector.create
local module = require("../mod/attributes")
local module2 = require("../mod/tween")
require("../types")
local module3 = require("../mod/utility")
local module4 = require("../mod/common/bezier")
local module5 = require("../obj/Bezier")
local module6 = require("../pkg/Promise")
require("../obj/ObjectCache")
local v = nil
local Lightning = {
	init = function(p)
		v = p
	end,
	deinit = function()
		v = nil
	end
}

local function readLightningAttributes(instance)
	return {
		segments = math.max(module.get(instance, "Segments", 8), 2),
		jaggedness = module.getRange(instance, "Jaggedness", NumberRange.new(0.5, 1), NumberRange.new(0, 1e999)),
		offsetScale = module.get(instance, "OffsetScale", 1),
		refreshRate = module.get(instance, "RefreshRate", 15),
		independentSegments = module.get(instance, "IndependentSegments", false),
		refreshDuringDissipate = module.get(instance, "RefreshDuringDissipate", false),
		nestedEffectMode = module.getEnum(instance, "NestedEffectMode", "None", {
			"None",
			"All",
			"Head",
			"Tail"
		}),
		colorSequence = module.get(instance, "Color", ColorSequence.new(Color3.new(1, 1, 1))),
		colorEasingData = module.get(instance, "Color_Curve", module3.linear_bezier),
		colorDuration = module.get(instance, "Color_Duration", 1),
		transparencyStart = module.get(instance, "Transparency_Start", 0),
		transparencyEnd = module.get(instance, "Transparency_End", 0),
		fillColorSequence = module.get(instance, "Fill_Color", ColorSequence.new(Color3.new(1, 1, 1))),
		fillColorEasingData = module.get(instance, "Fill_Color_Curve", module3.linear_bezier),
		fillColorDuration = module.get(instance, "Fill_Color_Duration", 1),
		fillTransparencyStart = module.get(instance, "Fill_Transparency_Start", 1),
		fillTransparencyEnd = module.get(instance, "Fill_Transparency_End", 1),
		fillDepthMode = module.getEnum(instance, "Fill_DepthMode", "Occluded", { "AlwaysOnTop", "Occluded" }),
		fadeInStart = module.get(instance, "Fade_In_Start", 1),
		fadeInDuration = module.get(instance, "Fade_In_Duration", 0),
		fadeInCurveData = module.get(instance, "Fade_In_Curve", module3.default_bezier),
		fadeOutEnd = module.get(instance, "Fade_Out_End", 1),
		fadeOutDuration = module.get(instance, "Fade_Out_Duration", 0),
		fadeOutCurveData = module.get(instance, "Fade_Out_Curve", module3.default_bezier),
		lengthStart = module.get(instance, "Length_Start", 1),
		lengthEnd = module.get(instance, "Length_End", 1),
		dissipateMode = module.getEnum(instance, "Dissipate_Mode", "None", { "None", "Retract", "Scale" }),
		dissipateDuration = module.get(instance, "Dissipate_Duration", 0.5),
		dissipateCurveData = module.get(instance, "Dissipate_Curve", module3.default_bezier),
		widthStart = module.get(instance, "Width_Start", 2),
		widthEnd = module.get(instance, "Width_End", 0.2)
	}
end

local function createSegmentStates(segments: number)
	local result = {}

	for i = 1, segments do
		result[i] = {
			birthTime = nil,
			initialWidth = nil,
			initialTransparency = nil,
			wasVisible = false
		}
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function computeJaggedOffset(object, range: NumberRange, p: number, p2: number, perpendicularVectors: Vector3, vector2: Vector3)
	local number = object:NextNumber(range.Min, range.Max)
	local v2 = p2 * 0.8
	local v3 = math.min(number * p * p2, v2)
	local number2 = object:NextNumber(0, 6.283185307179586)
	return (perpendicularVectors * math.cos(number2) + vector2 * math.sin(number2)) * v3
end

local function generateLightningPoints(random, segments: number, posGetter, jaggedness: NumberRange, offsetScale: number)
	local result = table.create(segments + 1)
	local v2 = 1 / segments
	result[1] = posGetter(0)
	local v3 = result[1]

	for i = 1, segments - 1 do
		local v4 = i * v2
		local v5 = posGetter(v4)
		local v6 = posGetter((math.min(v4 + 0.01, 1))) - v5
		local v7 = not (v6.Magnitude > 0.001) and createVector(0, 1, 0) or v6.Unit
		local perpendicularVectors, v8 = module4.getPerpendicularVectors(v7)
		v3 = v5 + computeJaggedOffset(random, jaggedness, offsetScale, (v5 - v3).Magnitude, perpendicularVectors, v8)
		result[i + 1] = v3
	end

	result[segments + 1] = posGetter(1)
	return result
end

local function generateProjectilePoints(random, segments: number, vector2: Vector3, vector3: Vector3, jaggedness: NumberRange, offsetScale: number, vector4: Vector3)
	local result = table.create(segments + 1)
	local v2 = 1 / segments
	local v3 = vector3 - vector2
	local magnitude = v3.Magnitude

	if magnitude > 0.001 then
		vector4 = v3 / magnitude
	end

	local perpendicularVectors, v4 = module4.getPerpendicularVectors(vector4)
	local v5 = magnitude * v2
	result[1] = vector2

	for i = 1, segments - 1 do
		local lerped = vector2:Lerp(vector3, i * v2)
		local jaggedOffset = computeJaggedOffset(random, jaggedness, offsetScale, v5, perpendicularVectors, v4) -- equivalent call inferred; original call site unknown
		result[i + 1] = lerped + jaggedOffset
	end

	result[segments + 1] = vector3
	return result
end

local function getBlendedPosition(p: number, callback, vector2: Vector3, vector3: Vector3, data)
	local v2 = (1 - p) * data.boltLength
	local v3 = math.clamp((data.distanceTraveled - v2) / data.transitionBuffer, 0, 1)
	local v4 = math.min(data.distanceTraveled / data.boltLength, 1) * data.curvedLengthT
	return callback((math.min(1, data.curvedTailT + p * data.curvedLengthT + v4))):Lerp(vector2:Lerp(vector3, p), v3)
end

local function generateTransitionPoints(random, segments: number, posGetter, vector2: Vector3, vector3: Vector3, jaggedness: NumberRange, offsetScale: number, vector4: Vector3, p)
	local result = table.create(segments + 1)
	local result2 = table.create(segments + 1)
	local v2 = 1 / segments
	local v3 = vector3 - vector2
	local magnitude = v3.Magnitude

	if magnitude > 0.001 then
		vector4 = v3 / magnitude
	end

	local perpendicularVectors, v4 = module4.getPerpendicularVectors(vector4)
	local v5 = magnitude * v2

	for i = 0, segments do
		local blendedPosition = getBlendedPosition(i * v2, posGetter, vector2, vector3, p)

		if i == 0 or i == segments then
			result[i + 1] = blendedPosition
			result2[i + 1] = createVector(0, 0, 0)
		else
			local jaggedOffset = computeJaggedOffset(random, jaggedness, offsetScale, v5, perpendicularVectors, v4) -- equivalent call inferred; original call site unknown
			result[i + 1] = blendedPosition + jaggedOffset
			result2[i + 1] = jaggedOffset
		end
	end

	return result, result2
end

local function updateTransitionPoints(segments: number, posGetter, vector2: Vector3, vector3: Vector3, p)
	local result = table.create(segments + 1)
	local v2 = 1 / segments
	local jaggedOffsets = p.jaggedOffsets

	for i = 0, segments do
		local blendedPosition = getBlendedPosition(i * v2, posGetter, vector2, vector3, p)
		result[i + 1] = blendedPosition + (not jaggedOffsets and createVector(0, 0, 0) or jaggedOffsets[i + 1])
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isTransitionComplete(data)
	return data.distanceTraveled >= data.boltLength + data.transitionBuffer
end

function Lightning.emit(instance, instance2, list, flag: boolean?)
	local points = instance:FindFirstChild("Points")

	if not (points and points:IsA("Attachment") and v) then
		return
	end

	local commonAttributes = module4.readCommonAttributes(instance)
	local v2 = readLightningAttributes(instance)
	local v3 = module4.drawFuncMap[commonAttributes.shapeType] and module4.drawFuncMap[commonAttributes.shapeType][commonAttributes.shapeStyle]

	if not v3 then
		return
	end

	local v4 = commonAttributes.emitDuration > 0
	task.wait(commonAttributes.emitDelay)

	if v4 and not flag then
		module3.forceEmit(instance, true)
		module.trigger(instance, "Enabled", true)
		module3.onCancel(list, function()
			local v5 = module3.stopEmitDuration(instance)

			if v5 then
				module3.cancelToken(v5)
			end
		end)

		if commonAttributes.speedStart ~= commonAttributes.speedEnd then
			module.setState(instance, "SpeedTweening", true)
			table.insert(
				list,
				module2.fromParams(
					module.get(instance, "Speed_Curve", module3.default_bezier),
					module.get(instance, "Speed_Duration", 0.1),
					function(p, p2)
						module.setState(
							instance,
							"SpeedOverride",
							module3.lerp(commonAttributes.speedStart, commonAttributes.speedEnd, p)
						)
						return p2
					end,
					nil,
					function()
						module.setState(instance, "SpeedTweening", nil)
					end
				)
			)
		end

		task.wait(commonAttributes.emitDuration)
		module3.awaitEmitDuration(module3.stopEmitDuration(instance))
	else
		if commonAttributes.emitCount <= 0 then
			return
		end

		local attachment = module4.validateParent(instance)

		if not attachment then
			return
		end

		local transformedOriginExtents, v5 = module3.getTransformedOriginExtents(attachment)

		if not transformedOriginExtents then
			return
		end

		local endAttachments, v6 = module4.findEndAttachments(instance)
		local bezierPoints = module3.getBezierPoints(points)
		local random = Random.new()
		local v7 = not endAttachments and module5.new(bezierPoints)
		local v8 = module5.new(module3.deserializePath(v2.colorEasingData), 0)
		local v9 = module5.new(module3.deserializePath(v2.fillColorEasingData), 0)
		local v10 = module5.new(module3.deserializePath(v2.fadeInCurveData), 0)
		local v11 = module5.new(module3.deserializePath(v2.fadeOutCurveData), 0)
		local hitboxParams = module4.createHitboxParams({
			enabled = commonAttributes.hitboxEnabled,
			collisionGroup = commonAttributes.hitboxCollisionGroup,
			filterTag = commonAttributes.hitboxFilterTag,
			filterType = commonAttributes.hitboxFilterType,
			ignoreCanCollide = commonAttributes.hitboxIgnoreCanCollide
		}, attachment, points)
		local v12 = {}

		for _ = 1, commonAttributes.emitCount do
			local v14 = random:NextNumber(commonAttributes.duration.Min, commonAttributes.duration.Max)
			local v15 = commonAttributes.projectileEnabled and random:NextNumber(
				commonAttributes.projectileLifetime.Min,
				commonAttributes.projectileLifetime.Max
			)
			table.insert(v12, module6.new(function(callback)
				local emissionCFrame = module4.calculateEmissionCFrame(transformedOriginExtents, v5, {
					face = commonAttributes.face,
					spreadAngle = commonAttributes.spreadAngle,
					mirror = commonAttributes.mirror,
					mirrorRot = commonAttributes.mirrorRot,
					partial = commonAttributes.partial,
					emissionDirection = commonAttributes.emissionDirection
				}, v3, random, endAttachments, attachment:IsA("Attachment"))
				local v16 = v7 or module4.createBezierWithEndpoint(bezierPoints, emissionCFrame, endAttachments, v6)
				local posGetter = module4.createPosGetter(v16, bezierPoints, emissionCFrame, endAttachments, true)
				local _getReals = table.create(v2.segments)
				local randomIds = table.create(v2.segments)
				local segmentStates = createSegmentStates(v2.segments)
				local v17 = 1 / v2.segments
				local v18 = table.create(v2.segments)

				for i = 1, v2.segments do
					v18[i] = {
						start = (i - 1) * v17,
						finish = i * v17
					}
				end

				if not v then
					callback()
					return
				end

				local v19 = v2.fillTransparencyStart < 1 or v2.fillTransparencyEnd < 1
				local model, highlight

				if v19 then
					model = Instance.new("Model")
					model.Name = "LightningContainer"
					model.Parent = workspace.Terrain
					highlight = Instance.new("Highlight")
					highlight.Adornee = model
					highlight.FillColor = module4.getColorWithEasingOklab(v2.fillColorSequence, 0, v9)
					highlight.FillTransparency = v2.fillTransparencyStart
					highlight.OutlineTransparency = 1
					highlight.DepthMode = Enum.HighlightDepthMode[v2.fillDepthMode]
					highlight.Parent = model
				else
					model = nil
					highlight = nil
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function shouldEmitNested(i: number)
					local nestedEffectMode = v2.nestedEffectMode

					if nestedEffectMode == "All" then
						return true
					elseif nestedEffectMode == "Head" then
						return i == v2.segments
					end

					return nestedEffectMode == "Tail" and i == 1
				end

				local v20

				if v2.nestedEffectMode == "None" then
					v20 = nil
				else
					v20 = list.effects.prepareEmitOnFinish(instance2, list)
				end

				local children = {}
				local v21 = {}

				for i = 1, v2.segments do
					local randomId = module3.getRandomId()
					local _getReal = v:get(randomId)._getReal()
					module3.copyProperties(instance2, _getReal, module3.COPY_PART_PROPERTIES)
					_getReal.Size = Vector3.new(v2.widthStart, v2.widthStart, 1)
					_getReal.Anchored = true
					_getReal.CanQuery = false
					_getReal.CanTouch = false
					_getReal.CanCollide = false

					if v19 and model then
						_getReal.Parent = model
					end

					-- equivalent call inferred; original call site unknown
					if shouldEmitNested(i) then
						local clone = instance2:Clone()

						for i2, child in clone:GetChildren() do
							child.Parent = _getReal

							if v2.nestedEffectMode == "Head" then
								table.insert(children, child)
							end
						end

						clone:Destroy()
						table.insert(v21, i)
					end

					_getReals[i] = _getReal
					randomIds[i] = randomId
				end

				local v22

				if v2.nestedEffectMode == "Head" and #children > 0 then
					for k, v23 in children do
						v23.Parent = _getReals[1]
					end

					v22 = 1
				else
					v22 = nil
				end

				table.insert(list, function()
					if v then
						for i = 1, v2.segments do
							v:free(randomIds[i])
						end

						if model then
							model:Destroy()
						end
					end
				end)
				local v23 = model or instance2
				local speedStart = commonAttributes.speedStart
				local widthStart = v2.widthStart
				local lengthStart = v2.lengthStart
				local transparencyStart = v2.transparencyStart
				local fillTransparencyStart = v2.fillTransparencyStart
				local v24 = generateLightningPoints(random, v2.segments, posGetter, v2.jaggedness, v2.offsetScale)
				local total = 0
				local v25 = 0
				local v26 = 0
				local flag2 = false

				for k, v27 in v21 do
					local v28 = v2.nestedEffectMode == "Head" and 1 or v27
					local v29 = list.effects.emitNested(_getReals[v28], list.depth + 1, list)
					table.insert(v12, v29.Finished)
				end

				local v27 = createVector(0, 0, 0)
				local v28 = createVector(0, 0, 0)
				local total2 = 0
				local flag3 = false
				local v29 = 0
				local v30 = 0
				local v31 = 0
				local widthStart2 = v2.widthStart
				local cframe = transformedOriginExtents
				local v32 = nil
				local v33 = nil
				local v34 = nil
				local v35 = nil
				local v36

				if commonAttributes.speedStart == commonAttributes.speedEnd or module.getState(
					instance,
					"SpeedOverride",
					nil
				) then
					v36 = nil
				else
					v36 = module2.fromParams(
						module.get(instance, "Speed_Curve", module3.default_bezier),
						module.get(instance, "Speed_Duration", 0.1),
						function(p, p2)
							speedStart = module3.lerp(commonAttributes.speedStart, commonAttributes.speedEnd, p)
							return p2
						end
					)
					table.insert(list, v36)
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function getEffectiveSpeed()
					return module.getState(instance, "SpeedOverride", speedStart)
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function isSpeedTweening()
					if v36 then
						return v36.Connected
					end

					return (module.getState(instance, "SpeedTweening", false))
				end

				local function getSpeedDelta(p: number, flag4: boolean?)
					local effectiveSpeed = getEffectiveSpeed() -- equivalent call inferred; original call site unknown
					speedStart = effectiveSpeed

					if effectiveSpeed > 0 then
						return p * effectiveSpeed
					end

					if not flag4 then
						-- equivalent call inferred; original call site unknown
						if not isSpeedTweening() then
							return nil
						end
					end

					return p * effectiveSpeed
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function getHeadSegmentIndex()
					return (math.clamp(math.ceil(v29 * v2.segments), 1, v2.segments))
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function shapecast()
					if not commonAttributes.hitboxEnabled then
						return false
					end

					local v37 = _getReals[math.clamp(math.ceil(v29 * v2.segments), 1, v2.segments)]

					if v37 and v37.Transparency < 1 and workspace:GetPartsInPart(v37, hitboxParams)[1] then
						return true
					end

					return false
				end

				local function refreshPoints()
					if v33 and v34 and v32 then
						if v35 and not isTransitionComplete(v35) then
							local v38 = v35
							local v39, jaggedOffsets = generateTransitionPoints(
								random,
								v2.segments,
								posGetter,
								v34,
								v33,
								v2.jaggedness,
								v2.offsetScale,
								v32,
								v35
							)
							v24 = v39
							v38.jaggedOffsets = jaggedOffsets
							return
						end

						v24 = generateProjectilePoints(
							random,
							v2.segments,
							v34,
							v33,
							v2.jaggedness,
							v2.offsetScale,
							v32
						)

						if v35 then
							v35.jaggedOffsets = nil
						end
					else
						v24 = generateLightningPoints(random, v2.segments, posGetter, v2.jaggedness, v2.offsetScale)
					end
				end

				local function updatePointsBetweenRefreshes(p: number)
					if v35 and not isTransitionComplete(v35) then
						if v35.jaggedOffsets then
							v24 = updateTransitionPoints(v2.segments, posGetter, v34, v33, v35)
							return
						end

						local v38 = v35
						local v39, jaggedOffsets = generateTransitionPoints(
							random,
							v2.segments,
							posGetter,
							v34,
							v33,
							v2.jaggedness,
							v2.offsetScale,
							v32,
							v35
						)
						v24 = v39
						v38.jaggedOffsets = jaggedOffsets
						return
					end

					local v37 = v32 * commonAttributes.projectileSpeed * p

					for i = 1, #v24 do
						v24[i] += v37
					end
				end

				local function updateSegments(p: number, p2: number?, p3: number, flag4: boolean?, p4: number?)
					local now = os.clock()
					v29 = p
					local v37 = p2 or math.max(0, p - lengthStart)
					local v38 = p4 or widthStart

					if flag4 ~= false and v2.refreshRate > 0 then
						local v39 = 1 / v2.refreshRate
						total += p3

						if v39 <= total then
							refreshPoints()
							total = 0
						end
					end

					for i = 1, v2.segments do
						local segmentState = segmentStates[i]
						local v39 = v18[i]
						local v40 = _getReals[i]
						local start = v39.start
						local finish = v39.finish
						local v41

						if v37 < finish then
							v41 = start < p
						else
							v41 = false
						end

						if v41 then
							if not segmentState.wasVisible then
								segmentState.wasVisible = true
								segmentState.birthTime = now
								segmentState.initialWidth = widthStart
								segmentState.initialTransparency = transparencyStart
							end

							v40.Color = module4.getColorWithEasingOklab(v2.colorSequence, v25, v8)
							local initialTransparency

							if v2.independentSegments and segmentState.initialTransparency then
								initialTransparency = segmentState.initialTransparency
							else
								initialTransparency = transparencyStart
							end

							local v42 = not (v2.fadeInDuration > 0) and 1 or math.clamp(
								total2 / v2.fadeInDuration,
								0,
								1
							)
							local v43 = 1 - v10:getEase(v42).y
							local lerped = module3.lerp(v2.fadeInStart, initialTransparency, v43)
							local lerped2

							if flag3 and v2.fadeOutDuration > 0 then
								local v45 = 1 - v11:getEase((math.clamp(v30 / v2.fadeOutDuration, 0, 1))).y
								lerped2 = module3.lerp(initialTransparency, v2.fadeOutEnd, v45)
							else
								lerped2 = initialTransparency
							end

							if v42 < 1 then
								initialTransparency = lerped
							elseif flag3 then
								initialTransparency = lerped2
							end

							v40.Transparency = initialTransparency
							local initialWidth

							if p4 then
								local v44

								if v2.independentSegments and segmentState.initialWidth then
									v44 = segmentState.initialWidth
								else
									v44 = widthStart
								end

								initialWidth = v44 * (not (widthStart > 0) and 0 or p4 / widthStart)
							elseif v2.independentSegments and segmentState.initialWidth then
								initialWidth = segmentState.initialWidth
							else
								initialWidth = v38
							end

							local v44 = v24[i]
							local v45 = v24[i + 1]

							if v44 and v45 then
								local v46

								if start < v37 then
									v46 = v44:Lerp(v45, (v37 - start) / (finish - start))
								else
									v46 = v44
								end

								if p < finish then
									v45 = v44:Lerp(v45, (p - start) / (finish - start))
								end

								local midpoint = (v46 + v45) / 2
								local magnitude = (v45 - v46).Magnitude

								if magnitude > 0.001 then
									v40.Size = Vector3.new(initialWidth, initialWidth, magnitude)
									v40.CFrame = CFrame.lookAt(midpoint, v45)
								end
							end
						else
							v40.Transparency = 1

							if segmentState.wasVisible then
								segmentState.wasVisible = false
								segmentState.birthTime = nil
								segmentState.initialWidth = nil
								segmentState.initialTransparency = nil
							end
						end
					end

					if highlight then
						highlight.FillColor = module4.getColorWithEasingOklab(v2.fillColorSequence, v26, v9)
						highlight.FillTransparency = fillTransparencyStart
					end

					if v22 then
						local headSegmentIndex = getHeadSegmentIndex() -- equivalent call inferred; original call site unknown

						if headSegmentIndex ~= v22 then
							local parent = _getReals[headSegmentIndex]

							for k, v40 in children do
								v40.Parent = parent
							end

							v22 = headSegmentIndex
						end
					end

					local v39 = posGetter((math.min(p, 1)))

					if p3 > 0 then
						v27 = (v39 - v28) / p3
					end

					v28 = v39
				end

				module4.createPropertyTween(list, instance, "Width", v14, v2.widthStart, v2.widthEnd, function(p)
					widthStart = p
				end, getEffectiveSpeed, v36)
				module4.createPropertyTween(
					list,
					instance,
					"Transparency",
					v14,
					v2.transparencyStart,
					v2.transparencyEnd,
					function(p)
						transparencyStart = p
					end,
					getEffectiveSpeed,
					v36
				)
				module4.createPropertyTween(list, instance, "Length", v14, v2.lengthStart, v2.lengthEnd, function(p)
					lengthStart = p
				end, getEffectiveSpeed, v36)

				if v19 then
					module4.createPropertyTween(
						list,
						instance,
						"FillTransparency",
						v2.fillColorDuration,
						v2.fillTransparencyStart,
						v2.fillTransparencyEnd,
						function(p)
							fillTransparencyStart = p
						end,
						getEffectiveSpeed,
						v36
					)
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function handleDissipation(p: number, p2: number, p3: number, dissipateCurveData: string, dissipateDuration: number, dissipateMode: string, onDissipationComplete)
					flag3 = true
					v31 = p2
					widthStart2 = p3
					module2.fromParams(dissipateCurveData, dissipateDuration, function(p4, p5, p6)
						v30 = p6
						local v37 = p5 * module.getState(instance, "SpeedOverride", speedStart)
						total2 += v37

						if v2.refreshDuringDissipate then
							v25 = (v25 + v37 / v2.colorDuration) % 1
							v26 = (v26 + v37 / v2.fillColorDuration) % 1
						end

						local lerped

						if dissipateMode == "Retract" then
							lerped = module3.lerp(v31, p, p4)
						end

						local v38

						if dissipateMode == "Scale" then
							v38 = module3.lerp(widthStart2, 0, p4)
						end

						updateSegments(p, lerped, v37, v2.refreshDuringDissipate, v38)
						local effectiveSpeed = getEffectiveSpeed() -- equivalent call inferred; original call site unknown
						speedStart = effectiveSpeed

						if effectiveSpeed > 0 then
						end

						return p5 * effectiveSpeed
					end, v36, onDissipationComplete, true, module3.RENDER_PRIORITY + list.depth)
				end

				local function startDissipation()
					if flag3 or flag2 then
						return
					end

					local v37 = v29
					local v38

					if v20 then
						v38 = list.effects.emitOnFinish(v20, v23, list.depth + 1, list)
					else
						v38 = nil
					end

					-- equivalent calls inferred from this helper; original call sites unknown
					local function onDissipationComplete()
						if flag2 then
							return
						end

						flag2 = true

						if v38 then
							v38.Finished:finally(function()
								callback()
							end)
						else
							callback()
						end
					end

					if v2.dissipateMode == "None" then
						if v2.fadeOutDuration > 0 then
							local v39 = math.max(0, v37 - lengthStart)
							local v40 = widthStart
							local fadeOutCurveData = v2.fadeOutCurveData
							local fadeOutDuration = v2.fadeOutDuration
							flag3 = true
							v31 = v39
							widthStart2 = v40
							local v41 = "None"
							module2.fromParams(fadeOutCurveData, fadeOutDuration, function(p, p2, p3)
								v30 = p3
								local v42 = p2 * module.getState(instance, "SpeedOverride", speedStart)
								total2 += v42

								if v2.refreshDuringDissipate then
									v25 = (v25 + v42 / v2.colorDuration) % 1
									v26 = (v26 + v42 / v2.fillColorDuration) % 1
								end

								local lerped

								if v41 == "Retract" then
									lerped = module3.lerp(v31, v37, p)
								end

								local v43

								if v41 == "Scale" then
									v43 = module3.lerp(widthStart2, 0, p)
								end

								updateSegments(v37, lerped, v42, v2.refreshDuringDissipate, v43)
								local effectiveSpeed = getEffectiveSpeed() -- equivalent call inferred; original call site unknown
								speedStart = effectiveSpeed

								if effectiveSpeed > 0 then
								end

								return p2 * effectiveSpeed
							end, v36, onDissipationComplete, true, module3.RENDER_PRIORITY + list.depth)
						else
							onDissipationComplete() -- equivalent call inferred; original call site unknown
						end
					else
						handleDissipation(
							v37,
							math.max(0, v37 - lengthStart),
							widthStart,
							v2.dissipateCurveData,
							v2.dissipateDuration,
							v2.dissipateMode,
							onDissipationComplete
						) -- equivalent call inferred; original call site unknown
					end
				end

				table.insert(
					list,
					module2.fromParams(
						module.get(instance, "Easing_Curve", module3.linear_bezier),
						v14,
						function(p, p2, p3)
							local v37 = p2 * module.getState(instance, "SpeedOverride", speedStart)
							total2 += v37
							v25 = (v25 + v37 / v2.colorDuration) % 1
							v26 = (v26 + v37 / v2.fillColorDuration) % 1

							if commonAttributes.syncPosition then
								local transformedOriginExtents2 = module3.getTransformedOriginExtents(attachment)
								local cframe2 = transformedOriginExtents2 * cframe:Inverse()

								for i = 1, #v24 do
									v24[i] = cframe2:PointToWorldSpace(cframe:PointToObjectSpace(v24[i]))
								end

								cframe = transformedOriginExtents2
							end

							updateSegments(p, nil, v37)

							-- equivalent call inferred; original call site unknown
							if shapecast() then
								startDissipation()
								return nil
							end

							local effectiveSpeed = getEffectiveSpeed() -- equivalent call inferred; original call site unknown
							speedStart = effectiveSpeed
							local v38

							if effectiveSpeed > 0 then
								v38 = p2 * effectiveSpeed
							else
								-- equivalent call inferred; original call site unknown
								if isSpeedTweening() then
									v38 = p2 * effectiveSpeed
								end
							end

							if v38 == nil then
								return nil
							end

							if commonAttributes.projectileEnabled and p * v14 < v15 or not commonAttributes.projectileEnabled then
								return v38
							end

							startDissipation()
							return nil
						end,
						v36,
						function()
							if flag3 or flag2 then
								return
							end

							if commonAttributes.projectileEnabled then
								local lookVector

								if commonAttributes.projectileMatchEnd and endAttachments then
									lookVector = endAttachments.WorldCFrame.LookVector
								else
									lookVector = v27.Unit
								end

								local v37 = (lookVector ~= lookVector or lookVector.Magnitude < 0.001) and createVector(
									0,
									0,
									1
								) or lookVector.Unit
								local v38 = posGetter(1)
								local magnitude = (v38 - posGetter((math.max(0, 1 - lengthStart)))).Magnitude
								local curvedTailT = math.max(0, 1 - lengthStart)
								local curvedLengthT = 1 - curvedTailT
								local transitionBuffer = magnitude * 0.3
								local jaggedOffsets = table.create(v2.segments + 1)

								for i = 0, v2.segments do
									local v44 = posGetter(curvedTailT + i / v2.segments * curvedLengthT)
									jaggedOffsets[i + 1] = v24[i + 1] - v44
								end

								local v43 = {
									curvedTailT = curvedTailT,
									curvedLengthT = curvedLengthT,
									boltLength = magnitude,
									transitionBuffer = transitionBuffer,
									distanceTraveled = 0,
									jaggedOffsets = jaggedOffsets
								}
								v35 = v43
								module2.timer(v15, function(p, p2)
									local v44 = p * module.getState(instance, "SpeedOverride", speedStart)
									total2 += v44
									v25 = (v25 + v44 / v2.colorDuration) % 1
									v26 = (v26 + v44 / v2.fillColorDuration) % 1
									local distanceTraveled = p2 * commonAttributes.projectileSpeed
									v43.distanceTraveled = distanceTraveled
									local v46 = v38 + v37 * distanceTraveled
									local v47 = v46 - v37 * magnitude
									v33 = v46
									v34 = v47
									v32 = v37

									if v2.refreshRate > 0 then
										total += v44

										if total >= 1 / v2.refreshRate then
											refreshPoints()
											total = 0
										else
											updatePointsBetweenRefreshes(p)
										end
									else
										updatePointsBetweenRefreshes(p)
									end

									updateSegments(1, nil, v44, false)

									-- equivalent call inferred; original call site unknown
									if shapecast() then
										startDissipation()
										return nil
									end

									if v15 <= p2 then
										return nil
									end

									local effectiveSpeed = getEffectiveSpeed() -- equivalent call inferred; original call site unknown
									speedStart = effectiveSpeed

									if effectiveSpeed > 0 then
									end

									return p * effectiveSpeed
								end, v36, list, module3.RENDER_PRIORITY + list.depth)
								startDissipation()
							elseif commonAttributes.destroyDelay > 0 then
								module2.fromParams(module3.linear_bezier, commonAttributes.destroyDelay, function(p, p2)
									local v37 = p2 * module.getState(instance, "SpeedOverride", speedStart)
									total2 += v37
									v25 = (v25 + v37 / v2.colorDuration) % 1
									v26 = (v26 + v37 / v2.fillColorDuration) % 1
									updateSegments(1, nil, v37, true)

									-- equivalent call inferred; original call site unknown
									if shapecast() then
										startDissipation()
										return nil
									end

									local effectiveSpeed = getEffectiveSpeed() -- equivalent call inferred; original call site unknown
									speedStart = effectiveSpeed

									if effectiveSpeed > 0 then
									end

									return p2 * effectiveSpeed
								end, v36, function()
									startDissipation()
								end, true, module3.RENDER_PRIORITY + list.depth)
							else
								startDissipation()
							end
						end,
						true,
						module3.RENDER_PRIORITY + list.depth
					)
				)
			end))
		end

		module6.all(v12):await()
	end
end

return Lightning