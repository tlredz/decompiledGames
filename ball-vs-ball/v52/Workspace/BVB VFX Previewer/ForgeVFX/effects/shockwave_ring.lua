local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local module = require("../mod/attributes")
local module2 = require("../mod/tween")
require("../types")
local module3 = require("../mod/utility")
local module4 = require("../pkg/Promise")
require("../obj/ObjectCache")
local random = Random.new()
local v = nil
local ShockwaveRing = {}

function ShockwaveRing.init(p)
	v = p
end

function ShockwaveRing.deinit()
	v = nil
end

function ShockwaveRing.emit(p, instance, list)
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
	local radius = module.get(instance, "Radius", 5)
	local segments = module.get(instance, "Segments", 7)
	local range = module.getRange(instance, "Lifetime", NumberRange.new(2, 3), NumberRange.new(0, 1e999))
	local partOffset = module.get(instance, "PartOffset", createVector(0, 0, 0), true)
	local baseOffset = module.get(instance, "BaseOffset", partOffset)
	local offsetStart = module.get(instance, "Offset_Start", partOffset)
	local offsetEnd = module.get(instance, "Offset_End", partOffset)
	local offsetStartDuration = module.get(instance, "Offset_Start_Duration", 0.5)
	local offsetEndDuration = module.get(instance, "Offset_End_Duration", 0.5)
	local sizeScaleStart = module.get(instance, "SizeScaleStart", createVector(0, 0, 0))
	local sizeScaleEnd = module.get(instance, "SizeScaleEnd", createVector(0, 0, 0))
	local minSize = module.get(instance, "MinSize", createVector(2, 1, 2))
	local maxSize = module.get(instance, "MaxSize", createVector(3, 2, 3))
	local sizeCurve = module.get(instance, "Size_Curve", module3.default_bezier, true)
	local sizeDuration = module.get(instance, "Size_Duration", 0.5, true)
	local sizeStartCurve = module.get(instance, "Size_Start_Curve", sizeCurve)
	local sizeEndCurve = module.get(instance, "Size_End_Curve", sizeCurve)
	local sizeStartDuration = module.get(instance, "Size_Start_Duration", sizeDuration)
	local sizeEndDuration = module.get(instance, "Size_End_Duration", sizeDuration)
	local transparencyDuration = module.get(instance, "Transparency_Duration", 0.5)
	local transparencyStart = module.get(instance, "Transparency_Start", 0)
	local transparencyEnd = module.get(instance, "Transparency_End", 0)
	task.wait(emitDelay)
	local transformedOriginExtents = module3.getTransformedOriginExtents(p)
	local finisheds = {}

	for i = 0, segments - 1 do
		local v5 = i / segments * 3.141592653589793 * 2
		local v6 = radius * math.cos(v5)
		local v7 = radius * math.sin(v5)
		local raycastResult = workspace:Raycast(
			(transformedOriginExtents * CFrame.new(v6, 0, v7)).Position,
			transformedOriginExtents:VectorToWorldSpace(rayDirection),
			raycastParams
		)

		if not raycastResult then
			continue
		end

		local number = random:NextNumber(minSize.X, maxSize.X)
		local number2 = random:NextNumber(minSize.Y, maxSize.Y)
		local number3 = random:NextNumber(minSize.Z, maxSize.Z)
		local randomId = module3.getRandomId()
		local v8 = v:get(randomId)
		local _getReal = v8._getReal()
		module3.copyProperties(instance, _getReal, module3.COPY_PART_PROPERTIES)
		module3.copyProperties(instance, _getReal, module3.COPY_EXTENDED_PART_PROPERTIES)

		if #instance:GetChildren() ~= 0 then
			local clone = instance:Clone()

			for _, child in clone:GetChildren() do
				child.Parent = _getReal
			end

			clone:Destroy()
		end

		local v9 = list.effects.prepareEmitOnFinish(v8, list)
		table.insert(list, function()
			if v then
				v:free(randomId)
			end
		end)
		v8.Color = raycastResult.Instance.Color
		v8.Material = raycastResult.Material
		v8.Transparency = raycastResult.Instance.Transparency

		if v8.Transparency == 0 then
			v8.Transparency = transparencyStart
		end

		v8.Size = createVector(0, 0, 0)
		local unit = transformedOriginExtents:VectorToWorldSpace((Vector3.new(-math.cos(v5), 0, -math.sin(v5)))):Cross(raycastResult.Normal).Unit
		local v11 = CFrame.fromMatrix(raycastResult.Position, unit, raycastResult.Normal) * CFrame.fromOrientation(
			-math.atan(number2 / number3),
			0,
			0
		)
		v8.CFrame = CFrame.new(offsetStart) * v11
		local connection = nil
		local connection2 = nil
		local v12 = createVector(0, 0, 0)

		if offsetStart ~= baseOffset then
			local v13 = v8
			local v14 = v11
			connection2 = module2.fromParams(
				module.get(instance, "Offset_Start_Curve", module3.default_bezier),
				offsetStartDuration,
				function(p2, p3)
					v12 = offsetStart:Lerp(baseOffset, p2)
					v13.CFrame = CFrame.new(v12) * v14
					return p3
				end
			)
			table.insert(list, connection)
		end

		local vector2 = Vector3.new(number, number2, number3)

		if vector2 * sizeScaleStart == vector2 then
			v8.Size = vector2 * sizeScaleStart
		else
			local v13 = v8
			local v14 = vector2
			connection = module2.fromParams(sizeStartCurve, sizeStartDuration, function(p2, p3)
				v13.Size = (v14 * sizeScaleStart):Lerp(v14, p2)
				return p3
			end)
			table.insert(list, connection)
		end

		table.insert(finisheds, list.effects.emitNested(v8, list.depth + 1, list).Finished)
		task.delay(random:NextNumber(range.Min, range.Max), function()
			if connection then
				connection:Disconnect()
			end

			if connection2 then
				connection2:Disconnect()
			end

			local size = v8.Size
			local transparency = v8.Transparency

			if size ~= vector2 * sizeScaleEnd then
				table.insert(list, module2.fromParams(sizeEndCurve, sizeEndDuration, function(p2, p3)
					v8.Size = size:Lerp(vector2 * sizeScaleEnd, p2)
					return p3
				end))
			end

			if v12 ~= offsetEnd then
				table.insert(
					list,
					module2.fromParams(
						module.get(instance, "Offset_End_Curve", module3.default_bezier),
						offsetEndDuration,
						function(p2, p3)
							v8.CFrame = CFrame.new(v12:Lerp(offsetEnd, p2)) * v11
							return p3
						end
					)
				)
			end

			if transparency ~= transparencyEnd then
				table.insert(
					list,
					module2.fromParams(
						module.get(instance, "Transparency_Curve", module3.default_bezier),
						transparencyDuration,
						function(p2, p3)
							v8.Transparency = module3.lerp(transparency, transparencyEnd, p2)
							return p3
						end
					)
				)
			end

			local v17 = list.effects.emitOnFinish(v9, v8, list.depth + 1, list)
			table.insert(finisheds, v17.Finished)
		end)
	end

	task.wait(range.Max + math.max(sizeEndDuration, offsetEndDuration))
	module4.all(finisheds):await()
end

return ShockwaveRing