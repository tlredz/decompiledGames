local createVector = vector.create
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local module = require("../mod/tween")
local module2 = require("../mod/shape")
local module3 = require("../mod/utility")
local module4 = require("../obj/Bezier")
local module5 = require("../pkg/Promise")
require("../obj/ObjectCache")
local v = {
	Box = {
		Volume = module2.getPointWithinBox,
		Surface = module2.getPointOnBox
	},
	Cylinder = {
		Volume = function(p, p2, p3, p4, p5)
			return module2.getPointWithinCylinder(p, 0, p5, p2, p3, p4)
		end,
		Surface = function(p, p2, p3, p4, p5)
			return module2.getPointWithinCylinder(p, 1, p5, p2, p3, p4)
		end
	},
	Sphere = {
		Volume = function(p, p2, p3, p4, p5)
			return module2.getPointWithinSphere(p, 0, p5, p2, p3, p4)
		end,
		Surface = function(p, p2, p3, p4, p5)
			return module2.getPointWithinSphere(p, 1, p5, p2, p3, p4)
		end
	},
	Disc = {
		Volume = function(p, p2, p3, p4, p5)
			return module2.getPointWithinDisc(p, 0, p5, p2, p3, p4)
		end,
		Surface = function(p, p2, p3, p4, p5)
			return module2.getPointWithinDisc(p, 1, p5, p2, p3, p4)
		end
	}
}
local v2 = nil
local Bezier = {}

function Bezier.init(p)
	v2 = p
end

function Bezier.deinit()
	v2 = nil
end

function Bezier.emit(instance, instance2, list, flag: boolean?)
	local points = instance:FindFirstChild("Points")

	if not (points and points:IsA("Attachment") and v2) then
		return
	end

	local attribute = module3.getAttribute(instance, "EmitDelay", 0)
	local attribute2 = module3.getAttribute(instance, "EmitCount", 1)
	local attribute3 = module3.getAttribute(instance, "EmitDuration", 0)
	local attribute4 = module3.getAttribute(instance, "DestroyDelay", 0)
	local rangeAttribute = module3.getRangeAttribute(
		instance,
		"Duration",
		NumberRange.new(1, 1),
		NumberRange.new(0, 1e999)
	)
	local enumAttribute = module3.getEnumAttribute(
		instance,
		"ShapeFace",
		"Outward",
		{ "InAndOut", "Inward", "Outward" }
	)
	local attribute5 = module3.getAttribute(instance, "SpreadAngle", createVector(0, 0, 0))
	local attribute6 = module3.getAttribute(instance, "SyncPosition", false)
	local attribute7 = module3.getAttribute(instance, "MirrorPaths", true)
	local attribute8 = module3.getAttribute(instance, "MirrorRotation", createVector(0, 0, 180))
	local attribute9 = module3.getAttribute(instance, "FacePath", false)
	local attribute10 = module3.getAttribute(instance, "ArcSpace", false)
	local attribute11 = module3.getAttribute(instance, "ShapePartial", 1)
	local enumAttribute2 = module3.getEnumAttribute(instance, "Shape", "Box", {
		"Box",
		"Cylinder",
		"Sphere",
		"Disc"
	})
	local enumAttribute3 = module3.getEnumAttribute(instance, "ShapeStyle", "Volume", { "Volume", "Surface" })
	local v3 = Enum.NormalId[module3.getEnumAttribute(instance, "EmissionDirection", "Top", {
		"Top",
		"Bottom",
		"Left",
		"Right",
		"Front",
		"Back"
	})]
	local attribute12 = module3.getAttribute(instance, "ProjectileEnabled", false)
	local attribute13 = module3.getAttribute(instance, "MatchEndDirection", false)
	local attribute14 = module3.getAttribute(instance, "ProjectileSpeed", 30)
	local rangeAttribute2 = module3.getRangeAttribute(
		instance,
		"ProjectileLifetime",
		NumberRange.new(1, 1),
		NumberRange.new(0, 1e999)
	)
	local attribute15 = module3.getAttribute(instance, "HitboxEnabled", false)
	local attribute16 = module3.getAttribute(instance, "HitboxCollisionGroup", "Default")
	local attribute17 = module3.getAttribute(instance, "HitboxFilterTag", "")
	local attribute18 = module3.getAttribute(instance, "HitboxFilterType", "Exclude")
	local attribute19 = module3.getAttribute(instance, "HitboxIgnoreCanCollide", false)
	local rangeAttribute3 = module3.getRangeAttribute(instance, "RotSpeed_Start", NumberRange.new(0, 0))
	local rangeAttribute4 = module3.getRangeAttribute(instance, "RotSpeed_End", NumberRange.new(0, 0))
	local attribute20 = module3.getAttribute(instance, "MinInitRot", createVector(0, 0, 0))
	local attribute21 = module3.getAttribute(instance, "MaxInitRot", createVector(0, 0, 0))
	local attribute22 = module3.getAttribute(instance, "Speed_Start", 1)
	local attribute23 = module3.getAttribute(instance, "Speed_End", 1)
	local v4 = v[enumAttribute2] and v[enumAttribute2][enumAttribute3]

	if not v4 then
		return
	end

	local v5 = {}
	local v6 = attribute3 > 0
	task.wait(attribute)

	if v6 and not flag then
		instance:SetAttribute("Enabled", true)

		if attribute22 ~= attribute23 then
			instance:SetAttribute("SpeedTweening", true)
			table.insert(
				list,
				module.fromParams(
					module3.getAttribute(instance, "Speed_Curve", module3.default_bezier),
					module3.getAttribute(instance, "Speed_Duration", 0.1),
					function(p, p2)
						instance:SetAttribute("SpeedOverride", module3.lerp(attribute22, attribute23, p))
						return p2
					end,
					nil,
					function()
						instance:SetAttribute("SpeedTweening", nil)
					end
				)
			)
		end

		task.wait(attribute3)
		instance:SetAttribute("Enabled", false)
		instance:SetAttribute("SpeedOverride", nil)
	elseif attribute2 > 0 then
		local size = nil
		local cFrame = nil
		local parent = instance.Parent

		if not parent then
			return
		end

		if not (parent:IsA("BasePart") or parent:IsA("Attachment")) then
			parent = instance
		end

		if parent:IsA("BasePart") then
			size = parent.Size
			cFrame = parent.CFrame
		elseif parent:IsA("Attachment") then
			cFrame = parent.WorldCFrame
			size = createVector(0, 0, 0)
		end

		if not cFrame then
			return
		end

		local attachment = instance:FindFirstChild("End")
		local T1 = attachment and attachment:FindFirstChild("T1")

		if attachment and not attachment:IsA("Attachment") then
			attachment = nil
		end

		if T1 and not T1:IsA("Attachment") then
			T1 = nil
		end

		local bezierPoints = module3.getBezierPoints(points)
		local random = Random.new()
		local v7 = not attachment and module4.new(bezierPoints)
		local overlapParams = OverlapParams.new()
		overlapParams.MaxParts = 1
		overlapParams.FilterType = Enum.RaycastFilterType[attribute18]
		overlapParams.CollisionGroup = attribute16
		overlapParams.RespectCanCollide = not attribute19
		overlapParams:AddToFilter(CollectionService:GetTagged(attribute17))

		if attribute18 == "Exclude" then
			overlapParams:AddToFilter({ workspace.Terrain, parent, points:FindFirstAncestorOfClass("Part") })
		end

		for _ = 1, attribute2 do
			local number = random:NextNumber(rangeAttribute3.Min, rangeAttribute3.Max)
			local number2 = random:NextNumber(rangeAttribute4.Min, rangeAttribute4.Max)
			local v10 = vector.create(
				random:NextNumber(attribute20.x, attribute21.x),
				random:NextNumber(attribute20.y, attribute21.y),
				random:NextNumber(attribute20.z, attribute21.z)
			)
			local v12 = random:NextNumber(rangeAttribute.Min, rangeAttribute.Max)
			local v13 = attribute12 and random:NextNumber(rangeAttribute2.Min, rangeAttribute2.Max)
			table.insert(v5, module5.new(function(callback)
				local v14

				if parent:IsA("Attachment") then
					v14 = cFrame * CFrame.new(createVector(0, 0, 0), Vector3.FromNormalId(v3)).Rotation
				else
					v14 = v4(nil, cFrame, size, v3, attribute11)
				end

				local vector3 = Vector3.FromNormalId(v3)
				local cross = vector3:Cross(cFrame.LookVector)

				if cross.Magnitude < 0.001 then
					cross = vector3:Cross(cFrame.UpVector)
				end

				local v15 = v14 * (CFrame.fromAxisAngle(
					vector3,
					(math.rad((random:NextNumber(-attribute5.x, attribute5.x))))
				) * CFrame.fromAxisAngle(cross, (math.rad((random:NextNumber(-attribute5.y, attribute5.y))))))

				if enumAttribute == "Inward" or enumAttribute == "InAndOut" and random:NextInteger(0, 1) == 1 then
					v15 *= CFrame.fromOrientation(0, 3.141592653589793, 0)
				end

				if attachment and attribute7 and (v15.Position - attachment.WorldPosition).Unit:Dot(v15.RightVector) >= 0 then
					local v16 = attribute8 * module3.DEG_TO_RAD
					v15 *= CFrame.fromOrientation(v16.x, v16.y, v16.z)
				end

				local v16 = v7

				if attachment then
					local worldPositions = {}

					for k, bezierPoint in bezierPoints do
						local worldPosition

						if k == #bezierPoints - 1 then
							worldPosition = T1 and T1.WorldPosition or attachment.WorldPosition
						elseif k == #bezierPoints then
							worldPosition = attachment.WorldPosition
						else
							worldPosition = v15 * (bezierPoint - bezierPoints[1])
						end

						table.insert(worldPositions, worldPosition)
					end

					v16 = module4.new(worldPositions)
				end

				local function getPos(p: number)
					local v17 = attribute10 and v16:getPositionArcSpace(p) or v16:getPosition(p)

					if attachment then
						return v17
					end

					return v15 * (v17 - bezierPoints[1])
				end

				local GUID = HttpService:GenerateGUID(false)

				if not v2 then
					callback()
					return
				end

				local v17 = v2:get(GUID)
				local v18 = attribute10 and v16:getPositionArcSpace(0) or v16:getPosition(0)

				if not attachment then
					v18 = v15 * (v18 - bezierPoints[1])
				end

				v17.CFrame = CFrame.new(v18)
				local _getReal = v17._getReal()
				module3.copyProperties(instance2, _getReal, module3.COPY_PART_PROPERTIES)
				module3.copyProperties(instance2, _getReal, module3.COPY_EXTENDED_PART_PROPERTIES)
				local clone = instance2:Clone()

				for i, child in clone:GetChildren() do
					child.Parent = _getReal
				end

				clone:Destroy()
				local emitOnFinish = _getReal:FindFirstChild("EmitOnFinish")

				if emitOnFinish then
					emitOnFinish.Parent = nil
					table.insert(list, emitOnFinish)
				end

				if shared.vfx and #_getReal:GetChildren() ~= 0 then
					local v19 = shared.vfx.emit(_getReal)
					table.insert(v5, v19.Finished)
				end

				table.insert(list, function()
					if v2 then
						v2:free(GUID)
					end
				end)
				local v19 = createVector(0, 0, 0)
				local v20 = createVector(0, 0, 0)
				local flag2 = false

				local function onFinish()
					if flag2 then
						return
					end

					flag2 = true
					local children = emitOnFinish and emitOnFinish:GetChildren()

					if not children or #children == 0 then
						callback()
						return
					end

					for k, v21 in children do
						v21.Parent = _getReal
					end

					shared.vfx.emit(table.unpack(children)).Finished:finally(function()
						callback()
					end)
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function shapecast()
					if not attribute15 then
						return
					end

					if workspace:GetPartsInPart(_getReal, overlapParams)[1] then
						return true
					end

					return false
				end

				local function getOriginCFrame()
					local worldCFrame = cFrame

					if parent:IsA("BasePart") then
						return parent.CFrame
					end

					if parent:IsA("Attachment") then
						worldCFrame = parent.WorldCFrame
					end

					return worldCFrame
				end

				local v21 = false
				local identity = CFrame.identity
				local lerped = attribute22
				local lerped2 = number
				local cframe = CFrame.fromOrientation(v10.x, v10.y, v10.z)
				local v22

				if attribute22 == attribute23 or instance:GetAttribute("SpeedOverride") then
					v22 = nil
				else
					v22 = module.fromParams(
						module3.getAttribute(instance, "Speed_Curve", module3.default_bezier),
						module3.getAttribute(instance, "Speed_Duration", 0.1),
						function(p, p2)
							lerped = module3.lerp(attribute22, attribute23, p)
							return p2
						end
					)
					table.insert(list, v22)
				end

				if number ~= number2 then
					table.insert(
						list,
						module.fromParams(
							module3.getAttribute(instance, "RotSpeed_Curve", module3.default_bezier),
							v12,
							function(p, p2)
								lerped2 = module3.lerp(number, number2, p)
								return p2 * (instance:GetAttribute("SpeedOverride") or lerped)
							end,
							v22
						)
					)
				end

				table.insert(
					list,
					module.fromParams(
						module3.getAttribute(instance, "Easing_Curve", module3.linear_bezier),
						v12,
						function(p, p2, p3)
							local v23 = attribute10 and v16:getPositionArcSpace(p) or v16:getPosition(p)

							if not attachment then
								v23 = v15 * (v23 - bezierPoints[1])
							end

							local cframe2 = CFrame.new(v23)

							if attribute9 then
								local v24 = math.clamp((p3 + 0.016666666666666666) / v12, 0, 1)
								local v25 = attribute10 and v16:getPositionArcSpace(v24) or v16:getPosition(v24)

								if not attachment then
									v25 = v15 * (v25 - bezierPoints[1])
								end

								if v23 == v25 then
									cframe2 *= identity.Rotation
								else
									cframe2 = CFrame.lookAt(v23, v25)
								end
							end

							local v24 = v10:Sign() * lerped2 * module3.DEG_TO_RAD * p2
							cframe *= CFrame.fromOrientation(v24.x, v24.y, v24.z)
							identity = cframe2
							local cFrame3 = cframe2 * cframe

							if attribute6 then
								local v26 = v17
								local cFrame2 = cFrame

								if parent:IsA("BasePart") then
									cFrame2 = parent.CFrame
								elseif parent:IsA("Attachment") then
									cFrame2 = parent.WorldCFrame
								end

								v26.CFrame = cFrame2 * cFrame:ToObjectSpace(cFrame3)
							else
								v17.CFrame = cFrame3
							end

							v20 = (v23 - v19) / p2
							v19 = v23

							-- equivalent call inferred; original call site unknown
							if shapecast() then
								onFinish()
								v21 = true
								return nil
							else
								local speedOverride = instance:GetAttribute("SpeedOverride") or lerped
								lerped = speedOverride

								if speedOverride == 0 then
									local v26

									if v22 then
										v26 = not v22.Connected
									else
										v26 = not instance:GetAttribute("SpeedTweening")
									end

									if v26 then
										return nil
									end
								end

								if attribute12 and p * v12 < v13 or not attribute12 then
									return p2 * speedOverride
								end

								onFinish()
								return nil
							end
						end,
						v22,
						function(p)
							if attribute12 and not v21 then
								local lookVector

								if attribute13 and attachment then
									lookVector = attachment.WorldCFrame.LookVector
								else
									lookVector = v20.Unit
								end

								v20 = (lookVector ~= lookVector and createVector(0, 0, 0) or lookVector) * attribute14
								local position = _getReal.Position
								local cFrame2 = cFrame

								if parent:IsA("BasePart") then
									cFrame2 = parent.CFrame
								elseif parent:IsA("Attachment") then
									cFrame2 = parent.WorldCFrame
								end

								module.timer(v13, function(p2, p3)
									if attribute6 then
										local v23 = v17
										local cFrame3 = cFrame

										if parent:IsA("BasePart") then
											cFrame3 = parent.CFrame
										elseif parent:IsA("Attachment") then
											cFrame3 = parent.WorldCFrame
										end

										v23.CFrame = cFrame3 * cFrame2:ToObjectSpace(CFrame.new(position + v20 * p3))
									else
										v17.CFrame = CFrame.new(position + v20 * p3) * _getReal.CFrame.Rotation
									end

									-- equivalent call inferred; original call site unknown
									if shapecast() then
										onFinish()
										v21 = true
										return nil
									else
										local speedOverride = instance:GetAttribute("SpeedOverride") or lerped
										lerped = speedOverride

										if speedOverride > 0 then
											return p2 * speedOverride
										end

										if p3 > 0 then
											local v23

											if v22 then
												v23 = v22.Connected
											else
												v23 = instance:GetAttribute("SpeedTweening")
											end

											if v23 then
												return p2 * speedOverride
											end
										end

										return nil
									end
								end, v22, list, module3.RENDER_PRIORITY + list.depth)

								if not v21 then
									onFinish()
								end
							elseif p then
								onFinish()
							end
						end,
						true,
						module3.RENDER_PRIORITY + list.depth
					)
				)
			end))
		end

		module5.all(v5):await()
		task.wait(attribute4)
	end
end

return Bezier