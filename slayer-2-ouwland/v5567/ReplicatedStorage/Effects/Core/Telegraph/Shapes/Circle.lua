local Look = require(script.Parent.Parent.Look)
return function(p, p2, data)
	local radius = p2.Radius

	if type(radius) ~= "number" then
		return nil
	end

	local v = radius * 2
	local part = Look.Part(
		p,
		Enum.PartType.Cylinder,
		Vector3.new(Look.Plate.Thickness, v, v),
		data.Color,
		Look.Plate.Material,
		Look.Plate.Transparency
	)
	local part2 = Look.Part(
		p,
		Enum.PartType.Cylinder,
		Vector3.new(Look.Glow.Thickness, Look.Seed, Look.Seed),
		data.Glow,
		Look.Glow.Material,
		data.Fill
	)
	local cframe = CFrame.Angles(0, 0, 1.5707963267948966)
	return { part, part2 }, function(cframe2: CFrame, p3: number)
		local v2 = math.max(v * p3, Look.Seed)
		part.CFrame = cframe2 * cframe
		part2.Size = Vector3.new(Look.Glow.Thickness, v2, v2)
		part2.CFrame = cframe2 * cframe
	end
end