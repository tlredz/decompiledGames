local Bezier = {}

function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function Bezier.Quad(p, p2, p3, p4)
	local lerped = Lerp(p, p2, p4)
	local lerped2 = Lerp(p2, p3, p4)
	return Lerp(lerped, lerped2, p4)
end

return Bezier