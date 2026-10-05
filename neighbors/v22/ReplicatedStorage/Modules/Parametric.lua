local Parametric = {}

function Parametric.new(points)
	local self = setmetatable({}, {
		__index = Parametric
	})
	self.Points = points
	table.sort(self.Points, function(a, b)
		return a.X < b.X
	end)
	return self
end

function Parametric.GetPositionAt(p, p2: number)
	if #p.Points == 0 then
		return 0
	end

	if #p.Points == 1 then
		return p.Points[1].Y
	end

	local point = p.Points[1]
	local point2 = p.Points[#p.Points]

	if p2 < point.X then
		return point.Y
	end

	if point2.X < p2 then
		return point2.Y
	end

	for i = 2, #p.Points do
		local point3 = p.Points[i - 1]
		local point4 = p.Points[i]

		if point3.X <= p2 and p2 <= point4.X then
			return (math.lerp(point3.Y, point4.Y, (p2 - point3.X) / (point4.X - point3.X)))
		end
	end

	return 0
end

return Parametric