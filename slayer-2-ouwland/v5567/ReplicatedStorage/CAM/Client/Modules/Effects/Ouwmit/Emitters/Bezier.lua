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
	local attribute = OuwmitUtility.GetAttribute(instance, "SyncPosition", false)
	local attribute2 = OuwmitUtility.GetAttribute(instance, "MirrorPaths", true)
	local attribute3 = OuwmitUtility.GetAttribute(instance, "MirrorRotation", createVector(0, 0, 180))
	local attribute4 = OuwmitUtility.GetAttribute(instance, "FacePath", false)
	local attribute5 = OuwmitUtility.GetAttribute(instance, "ArcSpace", false)
	local attribute6 = OuwmitUtility.GetAttribute(instance, "SpreadAngle", createVector(0, 0, 0))
	local rangeAttribute2 = OuwmitUtility.GetRangeAttribute(instance, "RotSpeed_Start", NumberRange.new(0, 0))
	local rangeAttribute3 = OuwmitUtility.GetRangeAttribute(instance, "RotSpeed_End", NumberRange.new(0, 0))
	local attribute7 = OuwmitUtility.GetAttribute(instance, "MinInitRot", createVector(0, 0, 0))
	local attribute8 = OuwmitUtility.GetAttribute(instance, "MaxInitRot", createVector(0, 0, 0))
	local attribute9 = OuwmitUtility.GetAttribute(instance, "Speed_Start", 1)
	local attribute10 = OuwmitUtility.GetAttribute(instance, "Speed_End", 1)
	local attribute11 = OuwmitUtility.GetAttribute(instance, "ProjectileEnabled", false)
	local attribute12 = OuwmitUtility.GetAttribute(instance, "MatchEndDirection", false)
	local attribute13 = OuwmitUtility.GetAttribute(instance, "ProjectileSpeed", 30)
	local rangeAttribute4 = OuwmitUtility.GetRangeAttribute(
		instance,
		"ProjectileLifetime",
		NumberRange.new(1, 1),
		NumberRange.new(0, 1e999)
	)
	local attribute14 = OuwmitUtility.GetAttribute(instance, "HitboxEnabled", false)
	local attribute15 = OuwmitUtility.GetAttribute(instance, "HitboxCollisionGroup", "Default")
	local attribute16 = OuwmitUtility.GetAttribute(instance, "HitboxFilterTag", "")
	local attribute17 = OuwmitUtility.GetAttribute(instance, "HitboxFilterType", "Exclude")
	local attribute18 = OuwmitUtility.GetAttribute(instance, "HitboxIgnoreCanCollide", false)
	local attribute19 = OuwmitUtility.GetAttribute(instance, "EmissionDirection", "Top")
	local top = Enum.NormalId.Top
	pcall(function()
		top = Enum.NormalId[attribute19]
	end)
	local attribute20 = OuwmitUtility.GetAttribute(instance, "Shape", "Box")
	local attribute21 = OuwmitUtility.GetAttribute(instance, "ShapeStyle", "Volume")
	local attribute22 = OuwmitUtility.GetAttribute(instance, "ShapeFace", "Outward")
	local attribute23 = OuwmitUtility.GetAttribute(instance, "ShapePartial", 1)
	local v5 = v[attribute20] and v[attribute20][attribute21]

	if not v5 then
		warn((`invalid bezier Shape/ShapeStyle '{tostring(attribute20)}/{tostring(attribute21)}' on {instance:GetFullName()}`))
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fallbackRotation()
		return Shape.getSurfaceCFrame(CFrame.identity, Vector3.FromNormalId(top), createVector(0, 0, 0)).Rotation
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
			if parent:IsA("BasePart") then
				return parent.CFrame
			end

			if parent:IsA("Attachment") then
				return parent.WorldCFrame
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
		local v6 = not attachment and Bezier.new(bezierPoints)
		local overlapParams

		if attribute14 then
			overlapParams = OverlapParams.new()
			overlapParams.MaxParts = 1

			if not pcall(function()
				overlapParams.FilterType = Enum.RaycastFilterType[attribute17]
			end) then
				overlapParams.FilterType = Enum.RaycastFilterType.Exclude
			end

			overlapParams.CollisionGroup = attribute15
			overlapParams.RespectCanCollide = not attribute18

			if attribute16 ~= "" then
				overlapParams:AddToFilter(CollectionService:GetTagged(attribute16))
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

		local parent2 = p and p.Parent or parent:IsA("BasePart") and parent.Parent or parent:IsA("Attachment") and parent:FindFirstAncestorWhichIsA("BasePart") and parent:FindFirstAncestorWhichIsA("BasePart").Parent or workspace.Terrain

		for _ = 1, scaled do
			local number = random:NextNumber(rangeAttribute2.Min, rangeAttribute2.Max)
			local number2 = random:NextNumber(rangeAttribute3.Min, rangeAttribute3.Max)
			local vector2 = vector.create(
				random:NextNumber(attribute7.x, attribute8.x),
				random:NextNumber(attribute7.y, attribute8.y),
				random:NextNumber(attribute7.z, attribute8.z)
			)
			local v7 = random:NextNumber(rangeAttribute.Min, rangeAttribute.Max) * durationScale
			local v8 = attribute11 and random:NextNumber(rangeAttribute4.Min, rangeAttribute4.Max) * durationScale
			local v9

			if parent:IsA("BasePart") then
				v9 = v5(nil, originCFrame, parent.Size, top, attribute23) or originCFrame * fallbackRotation()
			else
				v9 = originCFrame * fallbackRotation()
			end

			local vector3 = Vector3.FromNormalId(top)
			local cross = vector3:Cross(originCFrame.LookVector)

			if cross.Magnitude < 0.001 then
				cross = vector3:Cross(originCFrame.UpVector)
			end

			local v10 = v9 * (CFrame.fromAxisAngle(
				vector3,
				(math.rad((random:NextNumber(-attribute6.x, attribute6.x))))
			) * CFrame.fromAxisAngle(cross, (math.rad((random:NextNumber(-attribute6.y, attribute6.y))))))

			if attribute22 == "Inward" or attribute22 == "InAndOut" and random:NextInteger(0, 1) == 1 then
				v10 *= CFrame.fromOrientation(0, 3.141592653589793, 0)
			end

			if attachment and attribute2 and (v10.Position - attachment.WorldPosition).Unit:Dot(v10.RightVector) >= 0 then
				local v11 = attribute3 * OuwmitUtility.DEG_TO_RAD
				v10 *= CFrame.fromOrientation(v11.x, v11.y, v11.z)
			end

			local v11

			if attachment then
				local worldPositions = {}

				for k, bezierPoint in bezierPoints do
					local worldPosition

					if k == #bezierPoints - 1 then
						worldPosition = T1 and T1.WorldPosition or attachment.WorldPosition
					elseif k == #bezierPoints then
						worldPosition = attachment.WorldPosition
					else
						worldPosition = v10 * (bezierPoint - bezierPoints[1])
					end

					table.insert(worldPositions, worldPosition)
				end

				v11 = Bezier.new(worldPositions)
			else
				v11 = v6
			end

			local function getPos(p2: number)
				local v12 = attribute5 and v11:getPositionArcSpace(p2) or v11:getPosition(p2)

				if attachment then
					return v12
				end

				return v10 * (v12 - bezierPoints[1])
			end

			local clone = part:Clone()
			clone.Locked = true
			clone.Anchored = true
			local v12 = attribute5 and v11:getPositionArcSpace(0) or v11:getPosition(0)

			if not attachment then
				v12 = v10 * (v12 - bezierPoints[1])
			end

			clone.CFrame = CFrame.new(v12)
			clone.Parent = parent2
			local emitOnFinish = clone:FindFirstChild("EmitOnFinish")

			if emitOnFinish then
				emitOnFinish.Parent = nil
			end

			for _, child in ipairs(clone:GetChildren()) do
				callback(child, p)
			end

			local lerped = attribute9
			local lerped2 = number
			local cframe = CFrame.fromOrientation(vector2.x, vector2.y, vector2.z)
			local identity = CFrame.identity
			local v13 = createVector(0, 0, 0)
			local v14 = createVector(0, 0, 0)
			local v15 = false
			local flag = false

			local function onFinish()
				if flag then
					return
				end

				flag = true
				local children = emitOnFinish and emitOnFinish:GetChildren()
				local v18

				if children and #children > 0 and clone.Parent ~= nil then
					for k, v19 in children do
						v19.Parent = clone
					end

					callback(children, p)
					v18 = OuwmitUtility.GetAttribute(instance, "EmitOnFinishLifetime", 0) * durationScale
				else
					v18 = 0
				end

				if emitOnFinish then
					emitOnFinish:Destroy()
				end

				local v19 = v4 + v18

				if v19 > 0 then
					task.delay(v19, clone.Destroy, clone)
				else
					clone:Destroy()
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local parent3 = clone

			local function shapecast()
				if attribute14 and parent3.Parent ~= nil then
					return workspace:GetPartsInPart(parent3, overlapParams)[1] ~= nil
				end

				return false
			end

			local v19

			if attribute9 == attribute10 or instance:GetAttribute("SpeedOverride") then
				v19 = false
			else
				v19 = true
				Tween.new(
					OuwmitUtility.GetAttribute(instance, "Speed_Curve", OuwmitUtility.default_bezier),
					OuwmitUtility.GetAttribute(instance, "Speed_Duration", 0.1) * durationScale,
					function(p2, p3)
						lerped = OuwmitUtility.lerp(attribute9, attribute10, p2)
						return p3
					end,
					function()
						v19 = false
					end
				)
			end

			local function rampLive()
				return v19 or instance:GetAttribute("SpeedTweening") == true
			end

			if number ~= number2 then
				local parent4 = clone
				local v21 = number
				local v22 = number2
				Tween.new(
					OuwmitUtility.GetAttribute(instance, "RotSpeed_Curve", OuwmitUtility.default_bezier),
					v7,
					function(p2, p3)
						if parent4 and parent4:IsDescendantOf(game) then
							lerped2 = OuwmitUtility.lerp(v21, v22, p2)
							return p3 * (instance:GetAttribute("SpeedOverride") or lerped)
						else
							return nil
						end
					end
				)
			end

			local v20 = clone
			local onFinish2 = onFinish

			local function startProjectile()
				local lookVector

				if attribute12 and attachment then
					lookVector = attachment.WorldCFrame.LookVector
				else
					lookVector = v14.Unit
				end

				v14 = (lookVector ~= lookVector and createVector(0, 0, 0) or lookVector) * attribute13
				local position = v20.Position
				local originCFrame2 = getOriginCFrame() -- equivalent call inferred; original call site unknown
				Tween.new(OuwmitUtility.linear_bezier, v8, function(p2, p3, p4)
					if not (v20 and v20:IsDescendantOf(game)) then
						onFinish2()
						return nil
					end

					if attribute then
						local v22 = v20
						local originCFrame3 = getOriginCFrame() -- equivalent call inferred; original call site unknown
						v22.CFrame = originCFrame3 * originCFrame2:ToObjectSpace(CFrame.new(position + v14 * p4))
					else
						v20.CFrame = CFrame.new(position + v14 * p4) * v20.CFrame.Rotation
					end

					-- equivalent call inferred; original call site unknown
					if shapecast() then
						v15 = true
						onFinish2()
						return nil
					else
						local speedOverride = instance:GetAttribute("SpeedOverride") or lerped
						lerped = speedOverride

						if speedOverride ~= 0 or v19 or instance:GetAttribute("SpeedTweening") == true then
							return p3 * speedOverride
						end

						onFinish2()
						return nil
					end
				end, onFinish2)
			end

			local parent5 = clone
			local onFinish3 = onFinish
			local v25 = v8
			local startProjectile2 = startProjectile
			local onFinish4 = onFinish
			Tween.new(
				OuwmitUtility.GetAttribute(instance, "Easing_Curve", OuwmitUtility.linear_bezier),
				v7,
				function(p2, p3, p4)
					if not (parent5 and parent5:IsDescendantOf(game)) then
						onFinish3()
						return nil
					end

					local v26 = attribute5 and v11:getPositionArcSpace(p2) or v11:getPosition(p2)

					if not attachment then
						v26 = v10 * (v26 - bezierPoints[1])
					end

					local cframe2 = CFrame.new(v26)

					if attribute4 then
						local v27 = math.clamp((p4 + 0.016666666666666666) / v7, 0, 1)
						local v28 = attribute5 and v11:getPositionArcSpace(v27) or v11:getPosition(v27)

						if not attachment then
							v28 = v10 * (v28 - bezierPoints[1])
						end

						if v26 == v28 then
							cframe2 *= identity.Rotation
						else
							cframe2 = CFrame.lookAt(v26, v28)
						end
					end

					local v27 = vector2:Sign() * lerped2 * OuwmitUtility.DEG_TO_RAD * p3
					cframe *= CFrame.fromOrientation(v27.x, v27.y, v27.z)
					identity = cframe2
					local cFrame = cframe2 * cframe

					if attribute then
						local parent4 = parent5
						local originCFrame2 = getOriginCFrame() -- equivalent call inferred; original call site unknown
						parent4.CFrame = originCFrame2 * originCFrame:ToObjectSpace(cFrame)
					else
						parent5.CFrame = cFrame
					end

					v14 = (v26 - v13) / p3
					v13 = v26

					-- equivalent call inferred; original call site unknown
					if shapecast() then
						v15 = true
						onFinish3()
						return nil
					else
						local speedOverride = instance:GetAttribute("SpeedOverride") or lerped
						lerped = speedOverride

						if speedOverride == 0 and not v19 and instance:GetAttribute("SpeedTweening") ~= true then
							onFinish3()
							return nil
						end

						if not attribute11 then
							return p3 * speedOverride
						end

						if v25 <= p2 * v7 then
							onFinish3()
							return nil
						end

						return p3 * speedOverride
					end
				end,
				function()
					if attribute11 and not v15 then
						startProjectile2()
					else
						onFinish4()
					end
				end
			)
		end
	end

	local function doEmit()
		if not (v3 > 0) then
			emitBurst()
			return
		end

		if attribute9 ~= attribute10 then
			instance:SetAttribute("SpeedOverride", attribute9)
			instance:SetAttribute("SpeedTweening", true)
			Tween.new(
				OuwmitUtility.GetAttribute(instance, "Speed_Curve", OuwmitUtility.default_bezier),
				OuwmitUtility.GetAttribute(instance, "Speed_Duration", 0.1) * durationScale,
				function(p2, p3)
					instance:SetAttribute("SpeedOverride", OuwmitUtility.lerp(attribute9, attribute10, p2))
					return p3
				end,
				function()
					instance:SetAttribute("SpeedTweening", nil)
				end
			)
		end

		task.spawn(function()
			local v6 = 1 / (instance:GetAttribute("Rate") or 5)
			local lastTime = os.clock()

			while os.clock() - lastTime < v3 and instance:IsDescendantOf(game) do
				emitBurst()
				task.wait(v6)
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