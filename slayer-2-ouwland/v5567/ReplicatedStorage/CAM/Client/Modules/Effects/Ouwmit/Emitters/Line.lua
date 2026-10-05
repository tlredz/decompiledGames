local createVector = vector.create
local utilities = script.Parent.Parent.Utilities
local OuwmitUtility = require(utilities.OuwmitUtility)
require(utilities.Types)
local Tween = require(utilities.Tween)
local Animator = require(utilities.Animator)
local Bezier = require(utilities.Bezier)
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
	local attribute7 = OuwmitUtility.GetAttribute(instance2, "Rate_Start", 30)
	local attribute8 = OuwmitUtility.GetAttribute(instance2, "Rate_End", 30)
	local attribute9 = OuwmitUtility.GetAttribute(instance2, "FixedAmount", 0)
	local attribute10 = OuwmitUtility.GetAttribute(instance2, "Scale_Start", 1)
	local attribute11 = OuwmitUtility.GetAttribute(instance2, "Scale_End", 1)
	local v2 = OuwmitUtility.GetAttribute(instance2, "Duration", 1) * durationScale
	local attribute12 = OuwmitUtility.GetAttribute(instance2, "Direction", createVector(0, 0, -1))
	local attribute13 = OuwmitUtility.GetAttribute(instance2, "Length", 50)
	local rangeAttribute = OuwmitUtility.GetRangeAttribute(instance2, "Rotation", NumberRange.new(-180, 180))
	local attribute14 = OuwmitUtility.GetAttribute(instance2, "PartOffset", createVector(0, 0, 0))
	local attribute15 = OuwmitUtility.GetAttribute(instance2, "BaseOffset", attribute14)
	local attribute16 = OuwmitUtility.GetAttribute(instance2, "Offset_Start", attribute14)
	local attribute17 = OuwmitUtility.GetAttribute(instance2, "Offset_End", attribute14)
	local v3 = OuwmitUtility.GetAttribute(instance2, "Offset_Start_Duration", 0.5) * durationScale
	local v4 = OuwmitUtility.GetAttribute(instance2, "Offset_End_Duration", 0.5) * durationScale
	local rangeAttribute2 = OuwmitUtility.GetRangeAttribute(
		instance2,
		"Lifetime",
		NumberRange.new(2, 3),
		NumberRange.new(0, 1e999)
	)
	local attribute18 = OuwmitUtility.GetAttribute(instance2, "SizeScaleStart", createVector(0, 0, 0))
	local attribute19 = OuwmitUtility.GetAttribute(instance2, "SizeScaleEnd", createVector(0, 0, 0))
	local attribute20 = OuwmitUtility.GetAttribute(instance2, "MinSize", createVector(2, 1, 2))
	local attribute21 = OuwmitUtility.GetAttribute(instance2, "MaxSize", createVector(3, 2, 3))
	local attribute22 = OuwmitUtility.GetAttribute(instance2, "Size_Curve", OuwmitUtility.default_bezier)
	local attribute23 = OuwmitUtility.GetAttribute(instance2, "Size_Duration", 0.5)
	local attribute24 = OuwmitUtility.GetAttribute(instance2, "Size_Start_Curve", attribute22)
	local attribute25 = OuwmitUtility.GetAttribute(instance2, "Size_End_Curve", attribute22)
	local v5 = OuwmitUtility.GetAttribute(instance2, "Size_Start_Duration", attribute23) * durationScale
	local v6 = OuwmitUtility.GetAttribute(instance2, "Size_End_Duration", attribute23) * durationScale
	local v7 = OuwmitUtility.GetAttribute(instance2, "Transparency_Duration", 0.5) * durationScale
	local attribute26 = OuwmitUtility.GetAttribute(instance2, "Transparency_Start", 0)
	local attribute27 = OuwmitUtility.GetAttribute(instance2, "Transparency_End", 0)
	local attribute28 = OuwmitUtility.GetAttribute(instance2, "SyncPosition", false)
	local v8 = math.max(v2, 0.001)

	if attribute9 > 0 then
		attribute7 = attribute9 / v8
		attribute8 = attribute7
	end

	local unit = attribute12.Unit
	local v9 = unit ~= unit and createVector(-0, -0, -1) or unit

	local function Do()
		if not instance:IsDescendantOf(game) then
			return
		end

		local configuration = Instance.new("Configuration", p ~= nil and p.Parent or getDebreeParent())
		configuration.Name = `{instance2.Name} - Line`
		local v10 = 0
		local worldCFrame = instance.WorldCFrame
		local v11 = 0
		local count = 0
		local total = 0
		local lerped = attribute7
		local lerped2 = attribute10
		local v12 = nil
		local v13

		if attribute10 == attribute11 then
			v13 = nil
		else
			v13 = Tween.new(
				OuwmitUtility.GetAttribute(instance2, "Scale_Curve", OuwmitUtility.default_bezier),
				v8,
				function(p2, p3)
					lerped2 = OuwmitUtility.lerp(attribute10, attribute11, p2)
					return p3
				end
			)
		end

		if attribute7 ~= attribute8 then
			v12 = Tween.new(
				OuwmitUtility.GetAttribute(instance2, "Rate_Curve", OuwmitUtility.default_bezier),
				v8,
				function(p2, p3)
					lerped = OuwmitUtility.lerp(attribute7, attribute8, p2)
					return p3
				end
			)
		end

		local success, result = pcall(
			OuwmitUtility.deserializePath,
			OuwmitUtility.GetAttribute(instance2, "Path_Curve", OuwmitUtility.linear_bezier)
		)

		if not success then
			warn((`Ouwmit Line: failed to decode bezier path data ({result})`))
			result = OuwmitUtility.deserializePath(OuwmitUtility.linear_bezier)
		end

		local v14 = Bezier.new(result, 0)
		local flag = false
		local fn

		-- equivalent calls inferred from this helper; original call sites unknown
		local function finishEmitter()
			if flag then
				return
			end

			flag = true
			Animator.Remove(fn)

			if v13 ~= nil then
				v13()
			end

			if v12 ~= nil then
				v12()
			end

			if v10 == 0 and configuration ~= nil then
				configuration:Destroy()
				configuration = nil
			end
		end

		fn = function(p2)
			if instance:IsDescendantOf(game) and not (v8 <= total) then
				total += p2
				v11 += p2
				local v15 = 1 / lerped
				local v16 = v8 * lerped

				if v11 < v15 or v16 <= count then
					return
				end

				for _ = 1, v11 // v15 do
					if v16 <= count then
						continue
					end

					count += 1
					local v18 = 1 - v14:getEase((math.clamp(count / v16, 0, 1))).y

					if attribute28 then
						worldCFrame = instance.WorldCFrame
					end

					local raycastResult = workspace:Raycast(
						worldCFrame.Position + worldCFrame:VectorToWorldSpace(v9) * attribute13 * v18,
						instance.WorldCFrame:VectorToWorldSpace(attribute),
						raycastParams
					)

					if not raycastResult then
						v11 = 0
						return
					end

					local number = random:NextNumber(attribute20.X, attribute21.X)
					local number2 = random:NextNumber(attribute20.Y, attribute21.Y)
					local number3 = random:NextNumber(attribute20.Z, attribute21.Z)
					local part = Instance.new("Part")
					local success2, result2 = pcall(function()
						OuwmitUtility.CopyProperties(instance2, part, OuwmitUtility.COPY_PART_PROPERTIES)
						OuwmitUtility.CopyProperties(instance2, part, OuwmitUtility.COPY_EXTENDED_PART_PROPERTIES)
					end)

					if success2 then
						v10 += 1
						local children = instance2:GetChildren()

						if #children ~= 0 then
							for _, v20 in ipairs(children) do
								local clone = v20:Clone()
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
							part.Transparency = attribute26
						end

						part.Size = createVector(0, 0, 0)
						local number4 = random:NextNumber(rangeAttribute.Min, rangeAttribute.Max)
						local v20 = -math.cos(number4)
						local v21 = -math.sin(number4)
						local unit2 = instance.WorldCFrame:VectorToWorldSpace((Vector3.new(v20, 0, v21))):Cross(raycastResult.Normal).Unit
						local v22 = CFrame.fromMatrix(raycastResult.Position, unit2, raycastResult.Normal) * CFrame.fromOrientation(
							-math.atan(number2 / number3),
							0,
							0
						)
						part.CFrame = CFrame.new(attribute16) * v22
						local v23 = attribute16
						local v24 = nil
						local v25 = nil

						if attribute16 == attribute15 then
							v23 = attribute15
						else
							local parent = part
							local v27 = v22
							v24 = Tween.new(
								OuwmitUtility.GetAttribute(
									instance2,
									"Offset_Start_Curve",
									OuwmitUtility.default_bezier
								),
								v3,
								function(p3, p4)
									v23 = attribute16:Lerp(attribute15, p3)
									parent.CFrame = CFrame.new(v23) * v27
									return p4
								end
							)
						end

						local v26 = Vector3.new(number, number2, number3) * lerped2

						if v26 * attribute18 == v26 then
							part.Size = v26 * attribute18
						else
							local parent = part
							local v28 = v26
							v25 = Tween.new(attribute24, v5, function(p3, p4)
								parent.Size = (v28 * attribute18):Lerp(v28, p3)
								return p4
							end)
						end

						if callback ~= nil and #part:GetChildren() ~= 0 then
							for _, child in ipairs(part:GetChildren()) do
								callback(child)
							end
						end

						local v27 = part
						task.delay(random:NextNumber(rangeAttribute2.Min, rangeAttribute2.Max), function()
							if v24 ~= nil then
								v24()
							end

							if v25 ~= nil then
								v25()
							end

							local size = v27.Size
							local transparency = v27.Transparency

							if size ~= v26 * attribute19 then
								Tween.new(attribute25, v6, function(p3, p4)
									v27.Size = size:Lerp(v26 * attribute19, p3)
									return p4
								end)
							end

							if v23 ~= attribute17 then
								Tween.new(
									OuwmitUtility.GetAttribute(
										instance2,
										"Offset_End_Curve",
										OuwmitUtility.default_bezier
									),
									v4,
									function(p3, p4)
										v27.CFrame = CFrame.new(v23:Lerp(attribute17, p3)) * v22
										return p4
									end
								)
							end

							if transparency == attribute27 then
								v27.Transparency = transparency
							else
								Tween.new(
									OuwmitUtility.GetAttribute(
										instance2,
										"Transparency_Curve",
										OuwmitUtility.default_bezier
									),
									v7,
									function(p3, p4)
										v27.Transparency = OuwmitUtility.lerp(transparency, attribute27, p3)
										return p4
									end
								)
							end

							local v30 = math.max(v6, v4, v7)
							v10 -= 1

							if v10 == 0 and flag then
								task.delay(v30, function()
									if configuration ~= nil then
										configuration:Destroy()
										configuration = nil
									end
								end)
							else
								task.delay(v30, v27.Destroy, v27)
							end
						end)
					else
						warn((`Ouwmit Line: template '{instance2.Name}' properties couldn't be copied ({result2})`))
						part:Destroy()

						if flag then
							return
						end

						flag = true
						Animator.Remove(fn)

						if v13 ~= nil then
							v13()
						end

						if v12 ~= nil then
							v12()
						end

						if v10 == 0 and configuration ~= nil then
							configuration:Destroy()
							configuration = nil
						end

						return
					end
				end

				v11 %= v15
			else
				finishEmitter() -- equivalent call inferred; original call site unknown
			end
		end

		Animator.Add(fn)
	end

	if v == nil or not (v > 0) then
		Do()
	else
		task.delay(v, Do)
	end
end