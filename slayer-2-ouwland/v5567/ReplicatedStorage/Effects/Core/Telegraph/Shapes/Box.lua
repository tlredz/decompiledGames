local Look = require(script.Parent.Parent.Look)
return function(p, data, data2)
	local width = data.Width
	local length = data.Length

	if type(width) ~= "number" or type(length) ~= "number" then
		return nil
	end

	local live = data.Live == true
	local part = Look.Part(
		p,
		Enum.PartType.Block,
		Vector3.new(width, Look.Plate.Thickness, length),
		data2.Color,
		Look.Plate.Material,
		Look.Plate.Transparency
	)
	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Adornee = part
	selectionBox.Color3 = data2.Color
	selectionBox.LineThickness = Look.RimThickness
	selectionBox.Transparency = data2.Rim
	selectionBox.SurfaceTransparency = 1
	selectionBox.Parent = part
	local part2 = Look.Part(
		p,
		Enum.PartType.Block,
		Vector3.new(width, Look.Glow.Thickness, Look.Seed),
		data2.Glow,
		Look.Glow.Material,
		data2.Fill
	)
	local part3 = Look.Part(
		p,
		Enum.PartType.Block,
		Vector3.new(width, Look.Edge.Thickness, Look.Edge.Depth),
		data2.Glow,
		Look.Glow.Material,
		Look.Edge.Transparency
	)
	return { part, part2, part3 }, function(cFrame: CFrame, p2: number, p3: number?)
		local v

		if live then
			v = math.max(math.min(p3 or length, length), Look.Seed)
		else
			v = length
		end

		if live then
			cFrame *= CFrame.new(0, 0, -v / 2)
		end

		local v2 = math.max(v * p2, Look.Seed)
		part.Size = Vector3.new(width, Look.Plate.Thickness, v)
		part.CFrame = cFrame
		part2.Size = Vector3.new(width, Look.Glow.Thickness, v2)
		part2.CFrame = cFrame * CFrame.new(0, 0, (v - v2) / 2)
		part3.CFrame = cFrame * CFrame.new(0, 0, v / 2 - v2)
	end
end