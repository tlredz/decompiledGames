local createVector = vector.create
local Basis = {
	anyPerpendicular = function(vector2: Vector3)
		return vector2:Cross(math.abs(vector2.X) < 0.9 and createVector(1, 0, 0) or createVector(0, 1, 0)).Unit
	end
}

function Basis.rotationBetween(vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local dot = vector2:Dot(vector3)
	local cross = vector2:Cross(vector3)

	if not (dot < -0.99999) then
		return CFrame.new(0, 0, 0, cross.X, cross.Y, cross.Z, 1 + dot)
	end

	local v

	if vector4.Magnitude > 0.00001 then
		v = vector4.Unit
	else
		v = Basis.anyPerpendicular(vector2)
	end

	return CFrame.fromAxisAngle(v, 3.141592653589793)
end

function Basis.resolvePlanarDirection(items, vector2: Vector3)
	for _, item in items do
		local v = item - vector2 * item:Dot(vector2)

		if v.Magnitude > 0.05 then
			return v.Unit
		end
	end

	return Basis.anyPerpendicular(vector2)
end

function Basis.blendAlpha(p: number, p2: number)
	if p2 > 0 then
		return 1 - math.exp(-p / p2)
	end

	return 1
end

return Basis