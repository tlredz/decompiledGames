local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local module = require("../mod/attributes")
local module2 = require("../mod/tween")
require("../types")
local module3 = require("../mod/logger")
local module4 = require("../mod/utility")
local module5 = require("../obj/Bezier")
local module6 = require("../pkg/Promise")
require("../obj/ObjectCache")
local random = Random.new()
local v = nil
local ShockwaveLine = {}

function ShockwaveLine.init(p)
	v = p
end

function ShockwaveLine.deinit()
	v = nil
end

function ShockwaveLine.emit(p, instance, list)
	if not v then
		return
	end

	local rayDirection = module.get(p, "RayDirection", createVector(0, -50, 0))
	local collisionGroup = module.get(p, "RayCollisionGroup", "Default")
	local v3 = module.get(p, "FilterTag", "")
	local v4 = module.get(p, "FilterType", "Exclude")
	local ignoreWater = module.get(p, "IgnoreWater", true)
	local ignoreCanCollide = module.get(p, "IgnoreCanCollide", false)
	local raycastParams = RaycastParams.new()
	raycastParams.CollisionGroup = collisionGroup
	raycastParams.IgnoreWater = ignoreWater
	raycastParams.RespectCanCollide = not ignoreCanCollide
	raycastParams.FilterType = Enum.RaycastFilterType[v4]
	raycastParams.FilterDescendantsInstances = CollectionService:GetTagged(v3)

	if v4 == "Exclude" then
		raycastParams:AddToFilter({ workspace.Terrain })
	end

	local emitDelay = module.get(instance, "EmitDelay", 0)
	local rateStart = module.get(instance, "Rate_Start", 30)
	local rateEnd = module.get(instance, "Rate_End", 30)
	local fixedAmount = module.get(instance, "FixedAmount", 0)
	local scaleStart = module.get(instance, "Scale_Start", 1)
	local scaleEnd = module.get(instance, "Scale_End", 1)
	local duration = module.get(instance, "Duration", 1)
	local direction = module.get(instance, "Direction", createVector(0, 0, -1))
	local length = module.get(instance, "Length", 50)
	local range = module.getRange(instance, "Rotation", NumberRange.new(-180, 180))
	local partOffset = module.get(instance, "PartOffset", createVector(0, 0, 0), true)
	local baseOffset = module.get(instance, "BaseOffset", partOffset)
	local offsetStart = module.get(instance, "Offset_Start", partOffset)
	local offsetEnd = module.get(instance, "Offset_End", partOffset)
	local offsetStartDuration = module.get(instance, "Offset_Start_Duration", 0.5)
	local offsetEndDuration = module.get(instance, "Offset_End_Duration", 0.5)
	local range2 = module.getRange(instance, "Lifetime", NumberRange.new(2, 3), NumberRange.new(0, 1e999))
	local sizeScaleStart = module.get(instance, "SizeScaleStart", createVector(0, 0, 0))
	local sizeScaleEnd = module.get(instance, "SizeScaleEnd", createVector(0, 0, 0))
	local minSize = module.get(instance, "MinSize", createVector(2, 1, 2))
	local maxSize = module.get(instance, "MaxSize", createVector(3, 2, 3))
	local sizeCurve = module.get(instance, "Size_Curve", module4.default_bezier, true)
	local sizeDuration = module.get(instance, "Size_Duration", 0.5, true)
	local sizeStartCurve = module.get(instance, "Size_Start_Curve", sizeCurve)
	local sizeEndCurve = module.get(instance, "Size_End_Curve", sizeCurve)
	local sizeStartDuration = module.get(instance, "Size_Start_Duration", sizeDuration)
	local sizeEndDuration = module.get(instance, "Size_End_Duration", sizeDuration)
	local transparencyDuration = module.get(instance, "Transparency_Duration", 0.5)
	local transparencyStart = module.get(instance, "Transparency_Start", 0)
	local transparencyEnd = module.get(instance, "Transparency_End", 0)
	local syncPosition = module.get(instance, "SyncPosition", false)
	local v5 = math.max(duration, 0.001)

	if fixedAmount > 0 then
		rateStart = fixedAmount / v5
		rateEnd = rateStart
	end

	local unit = direction.Unit
	local v6 = unit ~= unit and createVector(-0, -0, -1) or unit
	task.wait(emitDelay)
	local finisheds = {}
	local transformedOriginExtents = module4.getTransformedOriginExtents(p)
	local v7 = 0
	local count = 0
	local lerped = rateStart
	local lerped2 = scaleStart

	if scaleStart ~= scaleEnd then
		table.insert(
			list,
			module2.fromParams(module.get(instance, "Scale_Curve", module4.default_bezier), v5, function(p2, p3)
				lerped2 = module4.lerp(scaleStart, scaleEnd, p2)
				return p3
			end)
		)
	end

	if rateStart ~= rateEnd then
		table.insert(
			list,
			module2.fromParams(module.get(instance, "Rate_Curve", module4.default_bezier), v5, function(p2, p3)
				lerped = module4.lerp(rateStart, rateEnd, p2)
				return p3
			end)
		)
	end

	local pathCurve = module.get(instance, "Path_Curve", module4.linear_bezier)
	local success, result = pcall(function()
		return module4.deserializePath(pathCurve)
	end)

	if not success then
		module3.error((`failed to decode bezier path data with error: {result}`))
	end

	local v8 = module5.new(result, 0)
	table.insert(list, module2.fromParams(module4.linear_bezier, v5, function(_, p2)
		v7 += p2
		local v9 = 1 / lerped
		local v10 = v5 * lerped

		if v7 < v9 or v10 <= count then
			return p2
		end

		for _ = 1, v7 // v9 do
			if v10 <= count then
				continue
			end

			count += 1
			local v12 = 1 - v8:getEase((math.clamp(count / v10, 0, 1))).y

			if syncPosition then
				transformedOriginExtents = module4.getTransformedOriginExtents(p)
			end

			local transformedOriginExtents2 = module4.getTransformedOriginExtents(p)
			local raycastResult = workspace:Raycast(
				transformedOriginExtents.Position + transformedOriginExtents:VectorToWorldSpace(v6) * length * v12,
				transformedOriginExtents2:VectorToWorldSpace(rayDirection),
				raycastParams
			)

			if not raycastResult then
				v7 = 0
				return p2
			end

			local number = random:NextNumber(minSize.X, maxSize.X)
			local number2 = random:NextNumber(minSize.Y, maxSize.Y)
			local number3 = random:NextNumber(minSize.Z, maxSize.Z)
			local randomId = module4.getRandomId()
			local v13 = v:get(randomId)
			local _getReal = v13._getReal()
			module4.copyProperties(instance, _getReal, module4.COPY_PART_PROPERTIES)
			module4.copyProperties(instance, _getReal, module4.COPY_EXTENDED_PART_PROPERTIES)

			if #instance:GetChildren() ~= 0 then
				local clone = instance:Clone()

				for _, child in clone:GetChildren() do
					child.Parent = _getReal
				end

				clone:Destroy()
			end

			local v14 = list.effects.prepareEmitOnFinish(_getReal, list)
			table.insert(list, function()
				if v then
					v:free(randomId)
				end
			end)
			v13.Color = raycastResult.Instance.Color
			v13.Material = raycastResult.Material
			v13.Transparency = raycastResult.Instance.Transparency

			if v13.Transparency == 0 then
				v13.Transparency = transparencyStart
			end

			v13.Size = createVector(0, 0, 0)
			local number4 = random:NextNumber(range.Min, range.Max)
			local unit2 = transformedOriginExtents2:VectorToWorldSpace((Vector3.new(
				-math.cos(number4),
				0,
				-math.sin(number4)
			))):Cross(raycastResult.Normal).Unit
			local v16 = CFrame.fromMatrix(raycastResult.Position, unit2, raycastResult.Normal) * CFrame.fromOrientation(
				-math.atan(number2 / number3),
				0,
				0
			)
			v13.CFrame = CFrame.new(offsetStart) * v16
			local connection = nil
			local connection2 = nil
			local v17 = createVector(0, 0, 0)

			if offsetStart ~= baseOffset then
				local v18 = v13
				local v19 = v16
				connection2 = module2.fromParams(
					module.get(instance, "Offset_Start_Curve", module4.default_bezier),
					offsetStartDuration,
					function(p3, p4)
						v17 = offsetStart:Lerp(baseOffset, p3)
						v18.CFrame = CFrame.new(v17) * v19
						return p4
					end
				)
				table.insert(list, connection2)
			end

			local v18 = Vector3.new(number, number2, number3) * lerped2

			if v18 * sizeScaleStart == v18 then
				v13.Size = v18 * sizeScaleStart
			else
				local v19 = v13
				local v20 = v18
				connection = module2.fromParams(sizeStartCurve, sizeStartDuration, function(p3, p4)
					v19.Size = (v20 * sizeScaleStart):Lerp(v20, p3)
					return p4
				end)
				table.insert(list, connection)
			end

			local v19 = list.effects.emitNested(_getReal, list.depth + 1, list)
			table.insert(finisheds, v19.Finished)
			task.delay(random:NextNumber(range2.Min, range2.Max), function()
				if connection then
					connection:Disconnect()
				end

				if connection2 then
					connection2:Disconnect()
				end

				local size = v13.Size
				local transparency = v13.Transparency

				if size ~= v18 * sizeScaleEnd then
					table.insert(list, module2.fromParams(sizeEndCurve, sizeEndDuration, function(p3, p4)
						v13.Size = size:Lerp(v18 * sizeScaleEnd, p3)
						return p4
					end))
				end

				if v17 ~= offsetEnd then
					table.insert(
						list,
						module2.fromParams(
							module.get(instance, "Offset_End_Curve", module4.default_bezier),
							offsetEndDuration,
							function(p3, p4)
								v13.CFrame = CFrame.new(v17:Lerp(offsetEnd, p3)) * v16
								return p4
							end
						)
					)
				end

				if transparency ~= transparencyEnd then
					table.insert(
						list,
						module2.fromParams(
							module.get(instance, "Transparency_Curve", module4.default_bezier),
							transparencyDuration,
							function(p3, p4)
								v13.Transparency = module4.lerp(transparency, transparencyEnd, p3)
								return p4
							end
						)
					)
				end

				local v25 = list.effects.emitOnFinish(v14, _getReal, list.depth + 1, list)
				table.insert(finisheds, v25.Finished)
			end)
		end

		v7 %= v9
		return p2
	end, nil, nil, true, module4.RENDER_PRIORITY + list.depth))
	task.wait(range2.Max + v5 + math.max(sizeEndDuration, offsetEndDuration))
	module6.all(finisheds):await()
end

return ShockwaveLine