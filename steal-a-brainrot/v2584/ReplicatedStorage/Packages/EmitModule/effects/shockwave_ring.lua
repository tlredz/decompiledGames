local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local module = require("../mod/tween")
local module2 = require("../mod/utility")
local module3 = require("../pkg/Promise")
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

	local attribute = module2.getAttribute(p, "RayDirection", createVector(0, -50, 0))
	local attribute2 = module2.getAttribute(p, "RayCollisionGroup", "Default")
	local attribute3 = module2.getAttribute(p, "FilterTag", "")
	local attribute4 = module2.getAttribute(p, "FilterType", "Exclude")
	local attribute5 = module2.getAttribute(p, "IgnoreWater", true)
	local attribute6 = module2.getAttribute(p, "IgnoreCanCollide", false)
	local raycastParams = RaycastParams.new()
	raycastParams.CollisionGroup = attribute2
	raycastParams.IgnoreWater = attribute5
	raycastParams.RespectCanCollide = not attribute6
	raycastParams.FilterType = Enum.RaycastFilterType[attribute4]
	raycastParams.FilterDescendantsInstances = CollectionService:GetTagged(attribute3)

	if attribute4 == "Exclude" then
		raycastParams:AddToFilter({ workspace.Terrain })
	end

	local attribute7 = module2.getAttribute(instance, "EmitDelay", 0)
	local attribute8 = module2.getAttribute(instance, "Radius", 5)
	local attribute9 = module2.getAttribute(instance, "Segments", 7)
	local rangeAttribute = module2.getRangeAttribute(
		instance,
		"Lifetime",
		NumberRange.new(2, 3),
		NumberRange.new(0, 1e999)
	)
	local attribute10 = module2.getAttribute(instance, "PartOffset", createVector(0, 0, 0), true)
	local attribute11 = module2.getAttribute(instance, "BaseOffset", attribute10)
	local attribute12 = module2.getAttribute(instance, "Offset_Start", attribute10)
	local attribute13 = module2.getAttribute(instance, "Offset_End", attribute10)
	local attribute14 = module2.getAttribute(instance, "Offset_Start_Duration", 0.5)
	local attribute15 = module2.getAttribute(instance, "Offset_End_Duration", 0.5)
	local attribute16 = module2.getAttribute(instance, "SizeScaleStart", createVector(0, 0, 0))
	local attribute17 = module2.getAttribute(instance, "SizeScaleEnd", createVector(0, 0, 0))
	local attribute18 = module2.getAttribute(instance, "MinSize", createVector(2, 1, 2))
	local attribute19 = module2.getAttribute(instance, "MaxSize", createVector(3, 2, 3))
	local attribute20 = module2.getAttribute(instance, "Size_Curve", module2.default_bezier, true)
	local attribute21 = module2.getAttribute(instance, "Size_Duration", 0.5, true)
	local attribute22 = module2.getAttribute(instance, "Size_Start_Curve", attribute20)
	local attribute23 = module2.getAttribute(instance, "Size_End_Curve", attribute20)
	local attribute24 = module2.getAttribute(instance, "Size_Start_Duration", attribute21)
	local attribute25 = module2.getAttribute(instance, "Size_End_Duration", attribute21)
	local attribute26 = module2.getAttribute(instance, "Transparency_Duration", 0.5)
	local attribute27 = module2.getAttribute(instance, "Transparency_Start", 0)
	local attribute28 = module2.getAttribute(instance, "Transparency_End", 0)
	task.wait(attribute7)
	local finisheds = {}

	for i = 0, attribute9 - 1 do
		local v2 = i / attribute9 * 3.141592653589793 * 2
		local v3 = attribute8 * math.cos(v2)
		local v4 = attribute8 * math.sin(v2)
		local raycastResult = workspace:Raycast(
			(p.WorldCFrame * CFrame.new(v3, 0, v4)).Position,
			p.WorldCFrame:VectorToWorldSpace(attribute),
			raycastParams
		)

		if not raycastResult then
			continue
		end

		local number = random:NextNumber(attribute18.X, attribute19.X)
		local number2 = random:NextNumber(attribute18.Y, attribute19.Y)
		local number3 = random:NextNumber(attribute18.Z, attribute19.Z)
		local ranomId = module2.getRanomId()
		local v5 = v:get(ranomId)
		local _getReal = v5._getReal()
		module2.copyProperties(instance, _getReal, module2.COPY_PART_PROPERTIES)
		module2.copyProperties(instance, _getReal, module2.COPY_EXTENDED_PART_PROPERTIES)

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
		v5.Color = raycastResult.Instance.Color
		v5.Material = raycastResult.Material
		v5.Transparency = raycastResult.Instance.Transparency

		if v5.Transparency == 0 then
			v5.Transparency = attribute27
		end

		v5.Size = createVector(0, 0, 0)
		local v7 = -math.cos(v2)
		local v8 = -math.sin(v2)
		local unit = p.WorldCFrame:VectorToWorldSpace((Vector3.new(v7, 0, v8))):Cross(raycastResult.Normal).Unit
		local v9 = CFrame.fromMatrix(raycastResult.Position, unit, raycastResult.Normal) * CFrame.fromOrientation(
			-math.atan(number2 / number3),
			0,
			0
		)
		v5.CFrame = CFrame.new(attribute12) * v9
		local connection = nil
		local connection2 = nil
		local v10 = createVector(0, 0, 0)

		if attribute12 ~= attribute11 then
			local v11 = v5
			local v12 = v9
			connection2 = module.fromParams(
				module2.getAttribute(instance, "Offset_Start_Curve", module2.default_bezier),
				attribute14,
				function(p2, p3)
					v10 = attribute12:Lerp(attribute11, p2)
					v11.CFrame = CFrame.new(v10) * v12
					return p3
				end
			)
			table.insert(list, connection)
		end

		local vector2 = Vector3.new(number, number2, number3)

		if vector2 * attribute16 == vector2 then
			v5.Size = vector2 * attribute16
		else
			local v11 = v5
			local v12 = vector2
			connection = module.fromParams(attribute22, attribute24, function(p2, p3)
				v11.Size = (v12 * attribute16):Lerp(v12, p2)
				return p3
			end)
			table.insert(list, connection)
		end

		if shared.vfx and #v5:GetChildren() ~= 0 then
			table.insert(finisheds, shared.vfx.emit(v5).Finished)
		end

		task.delay(random:NextNumber(rangeAttribute.Min, rangeAttribute.Max), function()
			if connection then
				connection:Disconnect()
			end

			if connection2 then
				connection2:Disconnect()
			end

			local size = v5.Size
			local transparency = v5.Transparency

			if size ~= vector2 * attribute17 then
				table.insert(list, module.fromParams(attribute23, attribute25, function(p2, p3)
					v5.Size = size:Lerp(vector2 * attribute17, p2)
					return p3
				end))
			end

			if v10 ~= attribute13 then
				table.insert(
					list,
					module.fromParams(
						module2.getAttribute(instance, "Offset_End_Curve", module2.default_bezier),
						attribute15,
						function(p2, p3)
							v5.CFrame = CFrame.new(v10:Lerp(attribute13, p2)) * v9
							return p3
						end
					)
				)
			end

			if transparency == attribute28 then
				v5.Transparency = transparency
			else
				table.insert(
					list,
					module.fromParams(
						module2.getAttribute(instance, "Transparency_Curve", module2.default_bezier),
						attribute26,
						function(p2, p3)
							v5.Transparency = module2.lerp(transparency, attribute28, p2)
							return p3
						end
					)
				)
			end
		end)
	end

	task.wait(rangeAttribute.Max + math.max(attribute25, attribute15))
	module3.all(finisheds):await()
end

return ShockwaveRing