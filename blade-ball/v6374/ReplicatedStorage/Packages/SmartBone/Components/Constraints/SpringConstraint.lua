return function(data, total, p, p2, p3)
	local settings = p2.Settings
	local stiffness = settings.Stiffness
	local elasticity = settings.Elasticity
	local bone = p2.Bones[data.ParentIndex]

	if not bone then
		return total
	end

	local freeLength = data.FreeLength

	if stiffness > 0 or elasticity > 0 then
		local v = CFrame.new(bone.Position) * bone.TransformOffset.Rotation
		local v2 = p or (v * CFrame.new(data.LocalTransformOffset.Position)).Position
		total += (v2 - total) * (elasticity * p3)

		if stiffness > 0 then
			local v3 = v2 - total
			local magnitude = v3.Magnitude
			local v4 = freeLength * (1 - stiffness) * 2

			if v4 < magnitude then
				total += v3 * ((magnitude - v4) / magnitude)
			end
		end
	end

	local v = bone.Position - total
	local magnitude = v.Magnitude

	if magnitude > 0 then
		total += v * ((magnitude - freeLength) / magnitude)
	end

	return total
end