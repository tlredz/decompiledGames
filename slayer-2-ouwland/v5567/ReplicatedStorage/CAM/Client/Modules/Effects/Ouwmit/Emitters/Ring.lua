local createVector = vector.create
local utilities = script.Parent.Parent.Utilities
local OuwmitUtility = require(utilities.OuwmitUtility)
require(utilities.Types)
local Tween = require(utilities.Tween)
local CollectionService = game:GetService("CollectionService")
local random = Random.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function getDebreeParent()
	return workspace:FindFirstChild("Debree") or workspace.Terrain
end

return function(instance, instance2, p, callback)
	if instance == nil or instance2 == nil then
		return
	end

	local attribute = OuwmitUtility.GetAttribute(instance, "RayDirection", createVector(0, -50, 0))
	local attribute2 = OuwmitUtility.GetAttribute(instance, "RayCollisionGroup", "Default")
	local attribute3 = OuwmitUtility.GetAttribute(instance, "FilterTag", "")
	local attribute4 = OuwmitUtility.GetAttribute(instance, "FilterType", "Exclude")
	local attribute5 = OuwmitUtility.GetAttribute(instance, "IgnoreWater", true)
	local attribute6 = OuwmitUtility.GetAttribute(instance, "IgnoreCanCollide", false)
	local raycastParams = RaycastParams.new()
	raycastParams.CollisionGroup = attribute2
	raycastParams.IgnoreWater = attribute5
	raycastParams.RespectCanCollide = not attribute6
	raycastParams.FilterType = Enum.RaycastFilterType[attribute4]
	raycastParams.FilterDescendantsInstances = CollectionService:GetTagged(attribute3)

	if attribute4 == "Exclude" then
		raycastParams:AddToFilter({ workspace.Terrain })
	end

	local durationScale = OuwmitUtility.DurationScale(p)
	local v = OuwmitUtility.GetAttribute(instance2, "EmitDelay", 0) * durationScale
	local attribute7 = OuwmitUtility.GetAttribute(instance2, "Radius", 5)
	local attribute8 = OuwmitUtility.GetAttribute(instance2, "Segments", 7)
	local rangeAttribute = OuwmitUtility.GetRangeAttribute(
		instance2,
		"Lifetime",
		NumberRange.new(2, 3),
		NumberRange.new(0, 1e999)
	)
	local attribute9 = OuwmitUtility.GetAttribute(instance2, "PartOffset", createVector(0, 0, 0))
	local attribute10 = OuwmitUtility.GetAttribute(instance2, "BaseOffset", attribute9)
	local attribute11 = OuwmitUtility.GetAttribute(instance2, "Offset_Start", attribute9)
	local attribute12 = OuwmitUtility.GetAttribute(instance2, "Offset_End", attribute9)
	local v2 = OuwmitUtility.GetAttribute(instance2, "Offset_Start_Duration", 0.5) * durationScale
	local v3 = OuwmitUtility.GetAttribute(instance2, "Offset_End_Duration", 0.5) * durationScale
	local attribute13 = OuwmitUtility.GetAttribute(instance2, "SizeScaleStart", createVector(0, 0, 0))
	local attribute14 = OuwmitUtility.GetAttribute(instance2, "SizeScaleEnd", createVector(0, 0, 0))
	local attribute15 = OuwmitUtility.GetAttribute(instance2, "MinSize", createVector(2, 1, 2))
	local attribute16 = OuwmitUtility.GetAttribute(instance2, "MaxSize", createVector(3, 2, 3))
	local attribute17 = OuwmitUtility.GetAttribute(instance2, "Size_Curve", OuwmitUtility.default_bezier)
	local attribute18 = OuwmitUtility.GetAttribute(instance2, "Size_Duration", 0.5)
	local attribute19 = OuwmitUtility.GetAttribute(instance2, "Size_Start_Curve", attribute17)
	local attribute20 = OuwmitUtility.GetAttribute(instance2, "Size_End_Curve", attribute17)
	local v4 = OuwmitUtility.GetAttribute(instance2, "Size_Start_Duration", attribute18) * durationScale
	local v5 = OuwmitUtility.GetAttribute(instance2, "Size_End_Duration", attribute18) * durationScale
	local v6 = OuwmitUtility.GetAttribute(instance2, "Transparency_Duration", 0.5) * durationScale
	local attribute21 = OuwmitUtility.GetAttribute(instance2, "Transparency_Start", 0)
	local attribute22 = OuwmitUtility.GetAttribute(instance2, "Transparency_End", 0)

	local function Do()
		if not instance:IsDescendantOf(game) then
			return
		end

		local configuration = Instance.new("Configuration", p ~= nil and p.Parent or getDebreeParent())
		configuration.Name = `{instance2.Name} - Ring`
		local count = 0
		local v7 = 0

		for i = 0, attribute8 - 1 do
			local v8 = i / attribute8 * 3.141592653589793 * 2
			local v9 = attribute7 * math.cos(v8)
			local v10 = attribute7 * math.sin(v8)
			local raycastResult = workspace:Raycast(
				(instance.WorldCFrame * CFrame.new(v9, 0, v10)).Position,
				instance.WorldCFrame:VectorToWorldSpace(attribute),
				raycastParams
			)

			if not raycastResult then
				continue
			end

			local number = random:NextNumber(attribute15.X, attribute16.X)
			local number2 = random:NextNumber(attribute15.Y, attribute16.Y)
			local number3 = random:NextNumber(attribute15.Z, attribute16.Z)
			local part = Instance.new("Part")
			local success, result = pcall(function()
				OuwmitUtility.CopyProperties(instance2, part, OuwmitUtility.COPY_PART_PROPERTIES)
				OuwmitUtility.CopyProperties(instance2, part, OuwmitUtility.COPY_EXTENDED_PART_PROPERTIES)
			end)

			if success then
				count += 1
				v7 += 1
				local children = instance2:GetChildren()

				if #children ~= 0 then
					for _, v12 in ipairs(children) do
						local clone = v12:Clone()
						clone.Parent = part
					end
				end

				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.CanTouch = false
				part.Parent = configuration
				part.Color = raycastResult.Instance.Color
				part.Material = raycastResult.Material
				part.Transparency = raycastResult.Instance.Transparency

				if part.Transparency == 0 then
					part.Transparency = attribute21
				end

				part.Size = createVector(0, 0, 0)
				local v12 = -math.cos(v8)
				local v13 = -math.sin(v8)
				local unit = instance.WorldCFrame:VectorToWorldSpace((Vector3.new(v12, 0, v13))):Cross(raycastResult.Normal).Unit
				local v14 = CFrame.fromMatrix(raycastResult.Position, unit, raycastResult.Normal) * CFrame.fromOrientation(
					-math.atan(number2 / number3),
					0,
					0
				)
				part.CFrame = CFrame.new(attribute11) * v14
				local v15 = attribute11
				local v16 = nil
				local v17 = nil

				if attribute11 == attribute10 then
					v15 = attribute10
				else
					local parent = part
					local v19 = v14
					v16 = Tween.new(
						OuwmitUtility.GetAttribute(instance2, "Offset_Start_Curve", OuwmitUtility.default_bezier),
						v2,
						function(p2, p3)
							v15 = attribute11:Lerp(attribute10, p2)
							parent.CFrame = CFrame.new(v15) * v19
							return p3
						end
					)
				end

				local vector2 = Vector3.new(number, number2, number3)

				if vector2 * attribute13 == vector2 then
					part.Size = vector2 * attribute13
				else
					local parent = part
					local v19 = vector2
					v17 = Tween.new(attribute19, v4, function(p2, p3)
						parent.Size = (v19 * attribute13):Lerp(v19, p2)
						return p3
					end)
				end

				if callback ~= nil and #part:GetChildren() ~= 0 then
					for _, child in ipairs(part:GetChildren()) do
						callback(child)
					end
				end

				local number4 = random:NextNumber(rangeAttribute.Min, rangeAttribute.Max)
				local v18 = part
				task.delay(number4, function()
					if v16 ~= nil then
						v16()
					end

					if v17 ~= nil then
						v17()
					end

					local size = v18.Size
					local transparency = v18.Transparency

					if size ~= vector2 * attribute14 then
						Tween.new(attribute20, v5, function(p2, p3)
							v18.Size = size:Lerp(vector2 * attribute14, p2)
							return p3
						end)
					end

					if v15 ~= attribute12 then
						Tween.new(
							OuwmitUtility.GetAttribute(instance2, "Offset_End_Curve", OuwmitUtility.default_bezier),
							v3,
							function(p2, p3)
								v18.CFrame = CFrame.new(v15:Lerp(attribute12, p2)) * v14
								return p3
							end
						)
					end

					if transparency == attribute22 then
						v18.Transparency = transparency
					else
						Tween.new(
							OuwmitUtility.GetAttribute(instance2, "Transparency_Curve", OuwmitUtility.default_bezier),
							v6,
							function(p2, p3)
								v18.Transparency = OuwmitUtility.lerp(transparency, attribute22, p2)
								return p3
							end
						)
					end

					local v21 = math.max(v5, v3, v6)
					v7 -= 1

					if v7 == 0 then
						task.delay(v21, function()
							if configuration ~= nil then
								configuration:Destroy()
								configuration = nil
							end
						end)
					else
						task.delay(v21, v18.Destroy, v18)
					end
				end)
			else
				warn((`Ouwmit Ring: template '{instance2.Name}' properties couldn't be copied ({result})`))
				part:Destroy()
				break
			end
		end

		if count == 0 and configuration ~= nil then
			configuration:Destroy()
			configuration = nil
		end
	end

	if v == nil or not (v > 0) then
		Do()
	else
		task.delay(v, Do)
	end
end