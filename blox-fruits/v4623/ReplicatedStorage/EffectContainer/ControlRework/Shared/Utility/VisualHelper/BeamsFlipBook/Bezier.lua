local Bezier = {}

function Bezier.CubicBezier(_, p: number, vector: Vector3, vector2: Vector3, vector3: Vector3, vector4: Vector3)
	return (1 - p) ^ 3 * vector + (1 - p) ^ 2 * 3 * p * vector2 + (1 - p) * 3 * p ^ 2 * vector3 + p ^ 3 * vector4
end

function Bezier:GetMagnitude(vector: Vector3, vector2: Vector3, vector3: Vector3, vector4: Vector3, p: number)
	local v = vector
	local total = 0

	for i = 1, p do
		local cubicBezier = self:CubicBezier(i / p, vector, vector2, vector3, vector4)
		total += (v - cubicBezier).Magnitude
		v = cubicBezier
	end

	return total
end

function Bezier:GetBeamTotalTextureLength(data)
	local attachment0 = data.Attachment0
	local attachment1 = data.Attachment1
	local worldPosition = attachment0.WorldPosition
	local worldPosition2 = attachment1.WorldPosition

	if data.CurveSize0 + data.CurveSize1 == 0 then
		return (worldPosition - worldPosition2).Magnitude
	end

	return self:GetMagnitude(
		worldPosition,
		worldPosition + attachment0.WorldCFrame.RightVector * data.CurveSize0,
		worldPosition2 - attachment1.WorldCFrame.RightVector * data.CurveSize1,
		worldPosition2,
		data.Segments
	)
end

return Bezier