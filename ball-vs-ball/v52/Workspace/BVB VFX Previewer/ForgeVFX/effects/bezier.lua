local createVector = vector.create
local RunService = game:GetService("RunService")
local module = require("../mod/attributes")
local module2 = require("../mod/tween")
require("../types")
local module3 = require("../mod/utility")
local module4 = require("../mod/common/bezier")
local module5 = require("../obj/Bezier")
local module6 = require("../pkg/Promise")
require("../obj/ObjectCache")
local v = nil
local Bezier = {
	init = function(p)
		v = p
	end,
	deinit = function()
		v = nil
	end
}

local function readBezierAttributes(instance)
	return {
		facePath = module.get(instance, "FacePath", false),
		arcSpace = module.get(instance, "ArcSpace", false),
		rotSpeedStart = module.getRange(instance, "RotSpeed_Start", NumberRange.new(0, 0)),
		rotSpeedEnd = module.getRange(instance, "RotSpeed_End", NumberRange.new(0, 0)),
		minInitRot = module.get(instance, "MinInitRot", createVector(0, 0, 0)),
		maxInitRot = module.get(instance, "MaxInitRot", createVector(0, 0, 0)),
		speedCurve = module.get(instance, "Speed_Curve", module3.default_bezier),
		speedDuration = module.get(instance, "Speed_Duration", 0.1),
		easingCurve = module.get(instance, "Easing_Curve", module3.linear_bezier)
	}
end

function Bezier.emit(instance, instance2, list, flag: boolean?)
	local points = instance:FindFirstChild("Points")

	if not (points and points:IsA("Attachment") and v) then
		return
	end

	local commonAttributes = module4.readCommonAttributes(instance)
	local v2 = readBezierAttributes(instance)
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
			table.insert(list, module2.fromParams(v2.speedCurve, v2.speedDuration, function(p, p2)
				module.setState(
					instance,
					"SpeedOverride",
					module3.lerp(commonAttributes.speedStart, commonAttributes.speedEnd, p)
				)
				return p2
			end, nil, function()
				module.setState(instance, "SpeedTweening", nil)
			end))
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
		local hitboxParams = module4.createHitboxParams({
			enabled = commonAttributes.hitboxEnabled,
			collisionGroup = commonAttributes.hitboxCollisionGroup,
			filterTag = commonAttributes.hitboxFilterTag,
			filterType = commonAttributes.hitboxFilterType,
			ignoreCanCollide = commonAttributes.hitboxIgnoreCanCollide
		}, attachment, points)
		local v8 = {}

		for _ = 1, commonAttributes.emitCount do
			local number = random:NextNumber(v2.rotSpeedStart.Min, v2.rotSpeedStart.Max)
			local number2 = random:NextNumber(v2.rotSpeedEnd.Min, v2.rotSpeedEnd.Max)
			local v10 = vector.create(
				random:NextNumber(v2.minInitRot.x, v2.maxInitRot.x),
				random:NextNumber(v2.minInitRot.y, v2.maxInitRot.y),
				random:NextNumber(v2.minInitRot.z, v2.maxInitRot.z)
			)
			local v12 = random:NextNumber(commonAttributes.duration.Min, commonAttributes.duration.Max)
			local v14 = commonAttributes.projectileEnabled and random:NextNumber(
				commonAttributes.projectileLifetime.Min,
				commonAttributes.projectileLifetime.Max
			)
			table.insert(v8, module6.new(function(callback)
				local emissionCFrame = module4.calculateEmissionCFrame(transformedOriginExtents, v5, {
					face = commonAttributes.face,
					spreadAngle = commonAttributes.spreadAngle,
					mirror = commonAttributes.mirror,
					mirrorRot = commonAttributes.mirrorRot,
					partial = commonAttributes.partial,
					emissionDirection = commonAttributes.emissionDirection
				}, v3, random, endAttachments, attachment:IsA("Attachment"))
				local v15 = v7 or module4.createBezierWithEndpoint(bezierPoints, emissionCFrame, endAttachments, v6)
				local posGetter = module4.createPosGetter(
					v15,
					bezierPoints,
					emissionCFrame,
					endAttachments,
					v2.arcSpace
				)
				local randomId = module3.getRandomId()

				if not v then
					callback()
					return
				end

				local v16 = v:get(randomId)
				v16.CFrame = CFrame.new(posGetter(0))
				local _getReal = v16._getReal()
				module3.copyProperties(instance2, _getReal, module3.COPY_PART_PROPERTIES)
				module3.copyProperties(instance2, _getReal, module3.COPY_EXTENDED_PART_PROPERTIES)
				local clone = instance2:Clone()

				for i, child in clone:GetChildren() do
					child.Parent = _getReal
				end

				clone:Destroy()
				local v17 = list.effects.prepareEmitOnFinish(_getReal, list)
				local v18 = list.effects.emitNested(_getReal, list.depth + 1, list)
				table.insert(v8, v18.Finished)
				table.insert(list, function()
					if v then
						v:free(randomId)
					end
				end)
				local v19 = createVector(0, 0, 0)
				local v20 = createVector(0, 0, 0)
				local v21 = false
				local flag2 = false
				local identity = CFrame.identity
				local speedStart = commonAttributes.speedStart
				local cframe = CFrame.fromOrientation(v10.x, v10.y, v10.z)
				local v22 = number

				local function onFinish()
					if flag2 then
						return
					end

					if commonAttributes.syncPosition then
						local transformedOriginExtents2 = module3.getTransformedOriginExtents(attachment)
						local cFrame = v16.CFrame

						local function updatePos()
							v16.CFrame = module3.getTransformedOriginExtents(attachment) * transformedOriginExtents2:ToObjectSpace(cFrame)
						end

						local randomId2 = module3.getRandomId()
						RunService:BindToRenderStep(randomId2, module3.RENDER_PRIORITY + list.depth, updatePos)
						table.insert(list, function()
							RunService:UnbindFromRenderStep(randomId2)
						end)
					end

					flag2 = true
					list.effects.emitOnFinish(v17, _getReal, list.depth + 1, list).Finished:finally(function()
						callback()
					end)
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function shapecast()
					if commonAttributes.hitboxEnabled then
						return workspace:GetPartsInPart(_getReal, hitboxParams)[1] ~= nil
					end

					return false
				end

				local v23

				if commonAttributes.speedStart == commonAttributes.speedEnd or module.getState(
					instance,
					"SpeedOverride",
					nil
				) then
					v23 = nil
				else
					v23 = module2.fromParams(v2.speedCurve, v2.speedDuration, function(p, p2)
						speedStart = module3.lerp(commonAttributes.speedStart, commonAttributes.speedEnd, p)
						return p2
					end)
					table.insert(list, v23)
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function getEffectiveSpeed()
					return module.getState(instance, "SpeedOverride", speedStart)
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function isSpeedTweening()
					if v23 then
						return v23.Connected
					end

					return (module.getState(instance, "SpeedTweening", false))
				end

				module4.createPropertyTween(list, instance, "RotSpeed", v12, number, number2, function(p)
					v22 = p
				end, function()
					return getEffectiveSpeed()
				end, v23)
				table.insert(list, module2.fromParams(v2.easingCurve, v12, function(p, p2, p3)
					local v24 = posGetter(p)
					local cframe2 = CFrame.new(v24)

					if v2.facePath then
						local v25 = posGetter((math.clamp((p3 + 0.016666666666666666) / v12, 0, 1)))

						if v24 == v25 then
							cframe2 *= identity.Rotation
						else
							cframe2 = CFrame.lookAt(v24, v25)
						end
					end

					local v25 = v10:Sign() * v22 * module3.DEG_TO_RAD * p2
					cframe *= CFrame.fromOrientation(v25.x, v25.y, v25.z)
					identity = cframe2
					local cFrame = cframe2 * cframe

					if commonAttributes.syncPosition then
						v16.CFrame = module3.getTransformedOriginExtents(attachment) * transformedOriginExtents:ToObjectSpace(cFrame)
					else
						v16.CFrame = cFrame
					end

					v20 = (v24 - v19) / p2
					v19 = v24

					-- equivalent call inferred; original call site unknown
					if shapecast() then
						onFinish()
						v21 = true
						return nil
					else
						local effectiveSpeed = getEffectiveSpeed() -- equivalent call inferred; original call site unknown
						speedStart = effectiveSpeed

						if effectiveSpeed == 0 then
							-- equivalent call inferred; original call site unknown
							if not isSpeedTweening() then
								return nil
							end
						end

						if commonAttributes.projectileEnabled and p * v12 < v14 or not commonAttributes.projectileEnabled then
							return p2 * effectiveSpeed
						end

						onFinish()
						return nil
					end
				end, v23, function(p)
					if commonAttributes.projectileEnabled and not v21 then
						local lookVector

						if commonAttributes.projectileMatchEnd and endAttachments then
							lookVector = endAttachments.WorldCFrame.LookVector
						else
							lookVector = v20.Unit
						end

						v20 = (lookVector ~= lookVector and createVector(0, 0, 0) or lookVector) * commonAttributes.projectileSpeed
						local position = _getReal.Position
						local transformedOriginExtents2 = module3.getTransformedOriginExtents(attachment)
						module2.timer(v14, function(p2, p3)
							if commonAttributes.syncPosition then
								v16.CFrame = module3.getTransformedOriginExtents(attachment) * transformedOriginExtents2:ToObjectSpace(CFrame.new(position + v20 * p3))
							else
								v16.CFrame = CFrame.new(position + v20 * p3) * _getReal.CFrame.Rotation
							end

							-- equivalent call inferred; original call site unknown
							if shapecast() then
								onFinish()
								v21 = true
								return nil
							else
								local effectiveSpeed = getEffectiveSpeed() -- equivalent call inferred; original call site unknown
								speedStart = effectiveSpeed

								if effectiveSpeed > 0 then
									return p2 * effectiveSpeed
								end

								if p3 > 0 then
									-- equivalent call inferred; original call site unknown
									if isSpeedTweening() then
										return p2 * effectiveSpeed
									end
								end

								return nil
							end
						end, v23, list, module3.RENDER_PRIORITY + list.depth)

						if not v21 then
							onFinish()
						end
					elseif p then
						onFinish()
					end
				end, true, module3.RENDER_PRIORITY + list.depth))
			end))
		end

		module6.all(v8):await()
		task.wait(commonAttributes.destroyDelay)
	end
end

return Bezier