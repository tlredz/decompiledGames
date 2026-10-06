local function getBeamArc(p)
	local v = 1 - math.pow(2 * p - 1, 2)
	local v2 = v * 165
	local v3 = v * 100
	return v2, v * 125, (p - 0.5) * 250, v3
end

return function(p)
	local v = 1 - math.pow(2 * p - 1, 2)
	local curveSize = v * 165
	local width = v * 100
	local v4 = v * 125
	local v5 = (p - 0.5) * 250
	script.Parent.AT0.Position = Vector3.new(v4, 0, 0)
	script.Parent.AT1.Position = Vector3.new(-v4, 0, 0)
	script.Parent.Beam.CurveSize0 = -curveSize
	script.Parent.Beam.CurveSize1 = curveSize
	script.Parent.Beam2.CurveSize0 = curveSize
	script.Parent.Beam2.CurveSize1 = -curveSize
	script.Parent.CFrame = workspace.Ships["Royal Galleon"].PrimaryPart.CFrame * CFrame.new(0, v5, 0)
	script.Parent.Beam.Width0 = width
	script.Parent.Beam.Width1 = width
	script.Parent.Beam2.Width0 = width
	script.Parent.Beam2.Width1 = width
end