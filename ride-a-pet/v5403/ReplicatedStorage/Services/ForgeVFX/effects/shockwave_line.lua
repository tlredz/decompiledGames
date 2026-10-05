local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local module = require("../mod/tween")
local module2 = require("../mod/logger")
local module3 = require("../mod/utility")
local module4 = require("../obj/Bezier")
local module5 = require("../pkg/Promise")
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

	local attribute = module3.getAttribute(p, "RayDirection", createVector(0, -50, 0))
	local attribute2 = module3.getAttribute(p, "RayCollisionGroup", "Default")
	local attribute3 = module3.getAttribute(p, "FilterTag", "")
	local attribute4 = module3.getAttribute(p, "FilterType", "Exclude")
	local attribute5 = module3.getAttribute(p, "IgnoreWater", true)
	local attribute6 = module3.getAttribute(p, "IgnoreCanCollide", false)
	local raycastParams = RaycastParams.new()
	raycastParams.CollisionGroup = attribute2
	raycastParams.IgnoreWater = attribute5
	raycastParams.RespectCanCollide = not attribute6
	raycastParams.FilterType = Enum.RaycastFilterType[attribute4]
	raycastParams.FilterDescendantsInstances = CollectionService:GetTagged(attribute3)

	if attribute4 == "Exclude" then
		raycastParams:AddToFilter({ workspace.Terrain })
	end

	local attribute7 = module3.getAttribute(instance, "EmitDelay", 0)
	local attribute8 = module3.getAttribute(instance, "Rate_Start", 30)
	local attribute9 = module3.getAttribute(instance, "Rate_End", 30)
	local attribute10 = module3.getAttribute(instance, "FixedAmount", 0)
	local attribute11 = module3.getAttribute(instance, "Scale_Start", 1)
	local attribute12 = module3.getAttribute(instance, "Scale_End", 1)
	local attribute13 = module3.getAttribute(instance, "Duration", 1)
	local attribute14 = module3.getAttribute(instance, "Direction", createVector(0, 0, -1))
	local attribute15 = module3.getAttribute(instance, "Length", 50)
	local rangeAttribute = module3.getRangeAttribute(instance, "Rotation", NumberRange.new(-180, 180))
	local attribute16 = module3.getAttribute(instance, "PartOffset", createVector(0, 0, 0), true)
	local attribute17 = module3.getAttribute(instance, "BaseOffset", attribute16)
	local attribute18 = module3.getAttribute(instance, "Offset_Start", attribute16)
	local attribute19 = module3.getAttribute(instance, "Offset_End", attribute16)
	local attribute20 = module3.getAttribute(instance, "Offset_Start_Duration", 0.5)
	local attribute21 = module3.getAttribute(instance, "Offset_End_Duration", 0.5)
	local rangeAttribute2 = module3.getRangeAttribute(
		instance,
		"Lifetime",
		NumberRange.new(2, 3),
		NumberRange.new(0, 1e999)
	)
	local attribute22 = module3.getAttribute(instance, "SizeScaleStart", createVector(0, 0, 0))
	local attribute23 = module3.getAttribute(instance, "SizeScaleEnd", createVector(0, 0, 0))
	local attribute24 = module3.getAttribute(instance, "MinSize", createVector(2, 1, 2))
	local attribute25 = module3.getAttribute(instance, "MaxSize", createVector(3, 2, 3))
	local attribute26 = module3.getAttribute(instance, "Size_Curve", module3.default_bezier, true)
	local attribute27 = module3.getAttribute(instance, "Size_Duration", 0.5, true)
	local attribute28 = module3.getAttribute(instance, "Size_Start_Curve", attribute26)
	local attribute29 = module3.getAttribute(instance, "Size_End_Curve", attribute26)
	local attribute30 = module3.getAttribute(instance, "Size_Start_Duration", attribute27)
	local attribute31 = module3.getAttribute(instance, "Size_End_Duration", attribute27)
	local attribute32 = module3.getAttribute(instance, "Transparency_Duration", 0.5)
	local attribute33 = module3.getAttribute(instance, "Transparency_Start", 0)
	local attribute34 = module3.getAttribute(instance, "Transparency_End", 0)
	local attribute35 = module3.getAttribute(instance, "SyncPosition", false)
	local v2 = math.max(attribute13, 0.001)

	if attribute10 > 0 then
		attribute8 = attribute10 / v2
		attribute9 = attribute8
	end

	local unit = attribute14.Unit
	local v3 = unit ~= unit and createVector(-0, -0, -1) or unit
	task.wait(attribute7)
	local finisheds = {}
	local worldCFrame = p.WorldCFrame
	local v4 = 0
	local count = 0
	local lerped = attribute8
	local lerped2 = attribute11

	if attribute11 ~= attribute12 then
		table.insert(
			list,
			module.fromParams(
				module3.getAttribute(instance, "Scale_Curve", module3.default_bezier),
				v2,
				function(p2, p3)
					lerped2 = module3.lerp(attribute11, attribute12, p2)
					return p3
				end
			)
		)
	end

	if attribute8 ~= attribute9 then
		table.insert(
			list,
			module.fromParams(module3.getAttribute(instance, "Rate_Curve", module3.default_bezier), v2, function(p2, p3)
				lerped = module3.lerp(attribute8, attribute9, p2)
				return p3
			end)
		)
	end

	local attribute36 = module3.getAttribute(instance, "Path_Curve", module3.linear_bezier)
	local success, result = pcall(function()
		return module3.deserializePath(attribute36)
	end)

	if not success then
		module2.error((`failed to decode bezier path data with error: {result}`))
	end

	local v5 = module4.new(result, 0)
	table.insert(list, module.fromParams(module3.linear_bezier, v2, function(_, p2)
		v4 += p2
		local v6 = 1 / lerped
		local v7 = v2 * lerped

		if v4 < v6 or v7 <= count then
			return p2
		end

		for _ = 1, v4 // v6 do
			if v7 <= count then
				continue
			end

			count += 1
			local v9 = 1 - v5:getEase((math.clamp(count / v7, 0, 1))).y

			if attribute35 then
				worldCFrame = p.WorldCFrame
			end

			local raycastResult = workspace:Raycast(
				worldCFrame.Position + worldCFrame:VectorToWorldSpace(v3) * attribute15 * v9,
				p.WorldCFrame:VectorToWorldSpace(attribute),
				raycastParams
			)

			if not raycastResult then
				v4 = 0
				return p2
			end

			local number = random:NextNumber(attribute24.X, attribute25.X)
			local number2 = random:NextNumber(attribute24.Y, attribute25.Y)
			local number3 = random:NextNumber(attribute24.Z, attribute25.Z)
			local ranomId = module3.getRanomId()
			local v10 = v:get(ranomId)
			local _getReal = v10._getReal()
			module3.copyProperties(instance, _getReal, module3.COPY_PART_PROPERTIES)
			module3.copyProperties(instance, _getReal, module3.COPY_EXTENDED_PART_PROPERTIES)

			if #instance:GetChildren() ~= 0 then
				local clone = instance:Clone()

				for _, child in clone:GetChildren() do
					child.Parent = _getReal
				end

				clone:Destroy()
			end

			table.insert(list, function()
				if v then
					v:free(ranomId)
				end
			end)
			v10.Color = raycastResult.Instance.Color
			v10.Material = raycastResult.Material
			v10.Transparency = raycastResult.Instance.Transparency

			if v10.Transparency == 0 then
				v10.Transparency = attribute33
			end

			v10.Size = createVector(0, 0, 0)
			local number4 = random:NextNumber(rangeAttribute.Min, rangeAttribute.Max)
			local v12 = -math.cos(number4)
			local v13 = -math.sin(number4)
			local unit2 = p.WorldCFrame:VectorToWorldSpace((Vector3.new(v12, 0, v13))):Cross(raycastResult.Normal).Unit
			local v14 = CFrame.fromMatrix(raycastResult.Position, unit2, raycastResult.Normal) * CFrame.fromOrientation(
				-math.atan(number2 / number3),
				0,
				0
			)
			v10.CFrame = CFrame.new(attribute18) * v14
			local connection = nil
			local connection2 = nil
			local v15 = createVector(0, 0, 0)

			if attribute18 ~= attribute17 then
				local v16 = v10
				local v17 = v14
				connection2 = module.fromParams(
					module3.getAttribute(instance, "Offset_Start_Curve", module3.default_bezier),
					attribute20,
					function(p3, p4)
						v15 = attribute18:Lerp(attribute17, p3)
						v16.CFrame = CFrame.new(v15) * v17
						return p4
					end
				)
				table.insert(list, connection2)
			end

			local v16 = Vector3.new(number, number2, number3) * lerped2

			if v16 * attribute22 == v16 then
				v10.Size = v16 * attribute22
			else
				local v17 = v10
				local v18 = v16
				connection = module.fromParams(attribute28, attribute30, function(p3, p4)
					v17.Size = (v18 * attribute22):Lerp(v18, p3)
					return p4
				end)
				table.insert(list, connection)
			end

			if shared.vfx and #v10:GetChildren() ~= 0 then
				local v17 = shared.vfx.emit(_getReal)
				table.insert(finisheds, v17.Finished)
			end

			task.delay(random:NextNumber(rangeAttribute2.Min, rangeAttribute2.Max), function()
				if connection then
					connection:Disconnect()
				end

				if connection2 then
					connection2:Disconnect()
				end

				local size = v10.Size
				local transparency = v10.Transparency

				if size ~= v16 * attribute23 then
					table.insert(list, module.fromParams(attribute29, attribute31, function(p3, p4)
						v10.Size = size:Lerp(v16 * attribute23, p3)
						return p4
					end))
				end

				if v15 ~= attribute19 then
					table.insert(
						list,
						module.fromParams(
							module3.getAttribute(instance, "Offset_End_Curve", module3.default_bezier),
							attribute21,
							function(p3, p4)
								v10.CFrame = CFrame.new(v15:Lerp(attribute19, p3)) * v14
								return p4
							end
						)
					)
				end

				if transparency == attribute34 then
					v10.Transparency = transparency
				else
					table.insert(
						list,
						module.fromParams(
							module3.getAttribute(instance, "Transparency_Curve", module3.default_bezier),
							attribute32,
							function(p3, p4)
								v10.Transparency = module3.lerp(transparency, attribute34, p3)
								return p4
							end
						)
					)
				end
			end)
		end

		v4 %= v6
		return p2
	end, nil, nil, true, module3.RENDER_PRIORITY + list.depth))
	task.wait(rangeAttribute2.Max + v2 + math.max(attribute31, attribute21))
	module5.all(finisheds):await()
end

return ShockwaveLine