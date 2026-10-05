local createVector = vector.create
local FusionDisplay = {
	Bounds = function(folder)
		local pivot = folder:GetPivot()
		local vector2 = nil
		local vector3 = nil

		for _, part in folder:GetDescendants() do
			if not (part:IsA("BasePart") and part.Transparency < 1) then
				continue
			end

			local objectSpace = pivot:ToObjectSpace(part.CFrame)
			local v = part.Size * 0.5
			local vector4 = Vector3.new(
				math.abs(objectSpace.XVector.X) * v.X + math.abs(objectSpace.YVector.X) * v.Y + math.abs(objectSpace.ZVector.X) * v.Z,
				math.abs(objectSpace.XVector.Y) * v.X + math.abs(objectSpace.YVector.Y) * v.Y + math.abs(objectSpace.ZVector.Y) * v.Z,
				math.abs(objectSpace.XVector.Z) * v.X + math.abs(objectSpace.YVector.Z) * v.Y + math.abs(objectSpace.ZVector.Z) * v.Z
			)
			local v2 = objectSpace.Position - vector4
			local v3 = objectSpace.Position + vector4

			if vector2 then
				vector2 = Vector3.new(math.min(vector2.X, v2.X), math.min(vector2.Y, v2.Y), (math.min(vector2.Z, v2.Z))) or v2
			else
				vector2 = v2
			end

			if vector3 then
				vector3 = Vector3.new(math.max(vector3.X, v3.X), math.max(vector3.Y, v3.Y), (math.max(vector3.Z, v3.Z))) or v3
			else
				vector3 = v3
			end
		end

		if vector2 then
			return (vector2 + vector3) * 0.5, vector3 - vector2
		end

		return nil
	end,
	FloatPivot = function(instance, p, p2, value, p3, p4)
		local fusionFitOffset = instance:GetAttribute("FusionFitOffset") or createVector(0, 3.6, 0)
		local fusionBobAmplitude = instance:GetAttribute("FusionBobAmplitude") or 0.25

		if p4 then
			fusionFitOffset = Vector3.new(
				fusionFitOffset.X,
				math.max(fusionFitOffset.Y, p4.Y / 2 + fusionBobAmplitude + 0.1),
				fusionFitOffset.Z
			)
		end

		local fusionRotationSpeed = instance:GetAttribute("FusionRotationSpeed") or 20
		local v = math.sin(p2 * 1.7951958020513104 + (value or 0)) * fusionBobAmplitude
		return instance.WorldCFrame * CFrame.new(fusionFitOffset + Vector3.new(0, v, 0)) * CFrame.Angles(
			0,
			math.rad(fusionRotationSpeed) * (p3 or p2),
			0
		) * CFrame.new(-p)
	end
}

function FusionDisplay.Fit(instance, instance2, p, p2)
	local bounds, v = FusionDisplay.Bounds(instance)

	if not bounds then
		return false
	end

	local fusionFitSize = instance2:GetAttribute("FusionFitSize") or createVector(4, 6, 4)
	local _ = instance2:GetAttribute("FusionFitOffset") or createVector(0, 3.6, 0)
	local v2 = math.max((tonumber(p) or 10) / 10, 0.001)
	local fusionBobAmplitude = instance2:GetAttribute("FusionBobAmplitude") or 0.25
	local v3 = math.min(
		v2,
		math.max(fusionFitSize.Y - 2 * fusionBobAmplitude, 0.1) / math.max(v.Y, 0.001),
		math.min(fusionFitSize.X, fusionFitSize.Z) / math.max(Vector2.new(v.X, v.Z).Magnitude, 0.001)
	)

	if p2 then
		v3 = v2
	end

	instance:ScaleTo(instance:GetScale() * v3)
	local bounds2, v4 = FusionDisplay.Bounds(instance)
	instance:PivotTo(FusionDisplay.FloatPivot(instance2, bounds2, 0, 0, nil, p2 and v4 or nil))
	return true, v4
end

return FusionDisplay