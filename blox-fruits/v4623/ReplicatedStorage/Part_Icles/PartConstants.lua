local createVector = vector.create
local PartConstants = {
	resolveLinkCFrame = function(instance)
		if instance:IsA("Attachment") then
			return instance.WorldCFrame
		end

		if instance:IsA("Model") then
			return instance:GetPivot()
		end

		if instance:IsA("Bone") then
			return instance.TransformedWorldCFrame
		end

		return instance.CFrame
	end,
	getParentScaleFactor = function(parent, p, p2, p3)
		local v = 1

		while parent do
			local v2 = true

			if p3 == "motion" then
				v2 = parent.ScaleMotion ~= false
			elseif p3 == "rotation" then
				v2 = parent.ScaleRotation == true
			end

			if v2 then
				local v3

				if parent.StaticValue then
					v3 = math.max(0.001, parent.StaticValue)
				else
					local v4 = math.clamp((p - parent.StartTime) / parent.LifeTime, 0, 1)
					v3 = math.max(0.001, p2.QueryPointsWithTime(v4, parent.Graph, parent.Seed))
				end

				v *= v3
			end

			parent = parent.Parent
		end

		return v
	end,
	composeRotation = function(p, p2, p3, p4)
		local cframe = CFrame.Angles(math.rad(p2), 0, 0)
		local cframe2 = CFrame.Angles(0, math.rad(p3), 0)
		local cframe3 = CFrame.Angles(0, 0, (math.rad(p4)))

		if p == "LocalXYZ" then
			return cframe * cframe2 * cframe3
		elseif p == "LocalXZY" then
			return cframe * cframe3 * cframe2
		elseif p == "LocalYXZ" then
			return cframe2 * cframe * cframe3
		elseif p == "LocalYZX" then
			return cframe2 * cframe3 * cframe
		elseif p == "LocalZXY" then
			return cframe3 * cframe * cframe2
		elseif p == "LocalZYX" then
			return cframe3 * cframe2 * cframe
		end

		return cframe2 * cframe * cframe3
	end,
	DirectionVectors = {
		[Enum.NormalId.Top] = {
			vector = "UpVector",
			multiplier = 1
		},
		[Enum.NormalId.Bottom] = {
			vector = "UpVector",
			multiplier = -1
		},
		[Enum.NormalId.Front] = {
			vector = "LookVector",
			multiplier = 1
		},
		[Enum.NormalId.Back] = {
			vector = "LookVector",
			multiplier = -1
		},
		[Enum.NormalId.Left] = {
			vector = "RightVector",
			multiplier = -1
		},
		[Enum.NormalId.Right] = {
			vector = "RightVector",
			multiplier = 1
		}
	},
	shapeFunctions = {
		[Enum.ParticleEmitterShape.Box] = function(p, _)
			local vector2 = Vector3.new(
				(math.random() * 2 - 1) * p.Size.X / 2,
				(math.random() * 2 - 1) * p.Size.Y / 2,
				(math.random() * 2 - 1) * p.Size.Z / 2
			)
			local v3 = not (vector2.Magnitude > 0.0001) and createVector(0, 1, 0) or vector2.Unit or createVector(
				0,
				1,
				0
			)
			return vector2, vector2.Magnitude > 0.0001 and CFrame.lookAt(Vector3.new(), -v3) or CFrame.new(), v3
		end,
		[Enum.ParticleEmitterShape.Sphere] = function(p, p2)
			local v3 = p.Size.X / 2
			local v4 = v3 * p2.ShapePartial
			local v5 = (math.random() * (v3 ^ 3 - v4 ^ 3) + v4 ^ 3) ^ 0.3333333333333333
			local v6 = math.random() * 2 * 3.141592653589793
			local v7 = math.acos(math.random() * 2 - 1)
			local vector2 = Vector3.new(math.sin(v7) * math.cos(v6), math.sin(v7) * math.sin(v6), (math.cos(v7)))
			return vector2 * v5, CFrame.lookAt(Vector3.new(), -vector2), vector2
		end,
		[Enum.ParticleEmitterShape.Cylinder] = function(p, p2)
			local v3 = p.Size.X / 2
			local Y = p.Size.Y
			local v4 = math.clamp(p2.ShapePartial, 0, 1)
			local v5 = math.sqrt(math.random() * (1 - v4 * v4) + v4 * v4)
			local v6 = math.random() * 2 * 3.141592653589793
			local v7 = v5 * v3 * math.cos(v6)
			local v8 = (math.random() * 2 - 1) * (Y / 2)
			local v9 = v5 * v3 * math.sin(v6)
			local vector2 = Vector3.new(v7, v8, v9)
			local v10 = math.abs(v8)
			local vector3

			if Y / 2 - 0.01 < v10 then
				vector3 = Vector3.new(0, math.sign(v8), 0)
			else
				local vector4 = Vector3.new(v7, 0, v9)
				vector3 = vector4.Magnitude < 0.0001 and createVector(0, 1, 0) or vector4.Unit
			end

			return vector2, CFrame.lookAt(Vector3.new(), -vector3), vector3
		end,
		[Enum.ParticleEmitterShape.Disc] = function(p, p2)
			local v3 = p.Size.X / 2
			local v4 = math.clamp(p2.ShapePartial, 0, 1)
			local v5 = math.sqrt(math.random() * (1 - v4 * v4) + v4 * v4)
			local v6 = math.random() * 2 * 3.141592653589793
			local vector2 = Vector3.new(v5 * v3 * math.cos(v6), 0, v5 * v3 * math.sin(v6))

			if vector2.Magnitude < 0.0001 then
				return vector2, CFrame.new(), createVector(0, 1, 0)
			end

			local unit = vector2.Unit
			return vector2, CFrame.lookAt(Vector3.new(), -unit), unit
		end
	}
}

function PartConstants.applyPositionOffset(p, data, p2, instance, p3, p4, p5, cframe, p6)
	local posX, posY, posZ

	if p4 and data.AxisLinks then
		local rangeAxes = p4.sampleRangeAxes(data, data.AxisLinks, { "PosX", "PosY", "PosZ" }, p3, p5)
		posX = rangeAxes.PosX
		posY = rangeAxes.PosY
		posZ = rangeAxes.PosZ
	else
		posX = p3.RandomValueFromRange(data.PosX or NumberRange.new(0))
		posY = p3.RandomValueFromRange(data.PosY or NumberRange.new(0))
		posZ = p3.RandomValueFromRange(data.PosZ or NumberRange.new(0))
	end

	if p6 and p6 ~= 1 then
		posX *= p6
		posY *= p6
		posZ *= p6
	end

	if posX == 0 and posY == 0 and posZ == 0 then
		return p
	end

	local posMode = data.PosMode or "Local"

	if posMode == "Local" then
		return p * CFrame.new(posX, posY, posZ)
	end

	local vector2 = Vector3.new(posX, posY, posZ)

	if posMode ~= "Global" then
		local worldCFrame

		if p2 then
			worldCFrame = PartConstants.resolveLinkCFrame(p2)
		elseif instance:IsA("Attachment") then
			worldCFrame = instance.WorldCFrame
		elseif instance:IsA("Model") then
			worldCFrame = instance:GetPivot()
		else
			worldCFrame = instance.CFrame
		end

		vector2 = worldCFrame:VectorToWorldSpace(vector2)
	end

	if cframe then
		vector2 = cframe:VectorToObjectSpace(vector2) or vector2
	end

	return CFrame.new(p.Position + vector2) * p.Rotation
end

function PartConstants.resolveDisplacement(data, p, cframe, cframe2, p2, p3, p4)
	if p ~= "Global" then
		if p == "RigidLocal" then
			data = cframe2:VectorToWorldSpace(data)
		else
			data = cframe:VectorToWorldSpace(data)
		end
	end

	if p2 then
		return p2 * data.X + p3 * data.Y + p4 * data.Z
	end

	return data
end

function PartConstants.applyContactAccel(vector2, data, value)
	if not (data._settleEngaged and data._lastHitNormal) then
		return vector2
	end

	local _lastHitNormal = data._lastHitNormal

	if _lastHitNormal.Magnitude < 0.0001 then
		return vector2
	end

	local dot = vector2:Dot(_lastHitNormal)

	if dot >= 0 or math.abs(dot) < 10 then
		return vector2
	end

	local v3 = vector2 - dot * _lastHitNormal
	local v4 = not (data.Events and data.Events.OnHit) and 0.2 or data.Events.OnHit.Friction or 0.2
	local v5

	if data._accelVel then
		local _accelVel = data._accelVel
		v5 = _accelVel - _accelVel:Dot(_lastHitNormal) * _lastHitNormal
	else
		v5 = createVector(0, 0, 0)
	end

	local magnitude = v5.Magnitude
	local v6 = v4 * math.abs(dot)

	if magnitude > 0.0001 then
		local v7 = -v5.Unit * v6

		if magnitude < v6 * (value or 0.016666666666666666) then
			v7 = -v5 / (value or 0.016666666666666666)
		end

		return v3 + v7
	elseif v3.Magnitude <= v6 then
		return createVector(0, 0, 0)
	else
		return v3 - v3.Unit * v6
	end
end

return PartConstants