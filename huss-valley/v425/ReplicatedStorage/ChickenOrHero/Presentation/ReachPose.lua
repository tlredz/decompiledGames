local createVector = vector.create
return {
	transform = function(p, p2, p3, p4)
		local v = p * p2.C0
		local v2 = p3 - v.Position

		if v2.Magnitude < 0.01 then
			return p4
		end

		local vector2 = Vector3.new(v2.X, 0, v2.Z)

		if vector2.Magnitude < 0.01 then
			return p4
		end

		local v3 = math.clamp(math.atan2(v2.Y, vector2.Magnitude), -0.4363323129985824, 0.5235987755982988)
		local v4 = vector2.Unit * math.cos(v3) + createVector(0, 1, 0) * math.sin(v3)
		local v5 = CFrame.lookAt(createVector(0, 0, 0), v4) * CFrame.Angles(1.5707963267948966, 0, 0)
		local v6 = v.Rotation:Inverse() * v5 * p2.C1.Rotation
		return CFrame.new(p4.Position) * v6
	end
}