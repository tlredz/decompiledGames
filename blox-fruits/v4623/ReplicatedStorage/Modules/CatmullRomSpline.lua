local CatmullRomSpline = {}
CatmullRomSpline.__index = CatmullRomSpline

function CatmullRomSpline.new(items, value: number?)
	local self = setmetatable({}, CatmullRomSpline)
	self.Tension = value or 0.5
	self.Points = {}
	self.LengthIterations = 1000
	self.LengthIndeces = {}
	self.Length = 0
	self.ConnectedSplines = {}

	if items ~= nil then
		for _, item in pairs(items) do
			CatmullRomSpline.AddPoint(self, item)
		end
	end

	return self
end

function CatmullRomSpline:ChangeTension(tension: number)
	if type(tension) ~= "number" then
		error("CatmullRomSpline:ChangeTension() expected a number as an input, got " .. tostring(tension) .. "!")
	end

	self.Tension = tension
	CatmullRomSpline.UpdateLength(self)
end

function CatmullRomSpline:Destroy()
	for i = #self.Points, 1, -1 do
		local point = self.Points[i]

		if point and typeof(point) == "Instance" then
			point:Destroy()
		end

		self.Points[i] = nil
	end
end

function CatmullRomSpline.ChangeAllSplineTensions(p, value: number)
	if type(value) ~= "number" then
		error("CatmullRomSpline:ChangeAllSplineTensions() expected a number as an input, got " .. tostring(value) .. "!")
	end

	local splines = CatmullRomSpline.GetSplines(p)

	for _, spline in pairs(splines) do
		spline:ChangeTension(value)
	end
end

function CatmullRomSpline.AddPoint(p, part, p2: number?)
	local points = p.Points

	local function checkIfPointsMatch(p3)
		local points2 = CatmullRomSpline.GetPoints(p)

		for _, point in pairs(points2) do
			if typeof(point) ~= typeof(p3) then
				return false
			end
		end

		return true
	end

	if #points == 4 then
		if typeof(part) == "number" or typeof(part) == "Vector3" then
			if checkIfPointsMatch(part) then
				local splines = CatmullRomSpline.GetSplines(p)
				local spline = splines[#splines]
				local v = CatmullRomSpline.new({
					spline.Points[2],
					spline.Points[3],
					spline.Points[4],
					part
				}, spline.Tension)
				CatmullRomSpline.ConnectSpline(p, v)
			end
		elseif part:IsA("BasePart") and checkIfPointsMatch(part.Position) then
			local splines = CatmullRomSpline.GetSplines(p)
			local spline = splines[#splines]
			local v = CatmullRomSpline.new({
				spline.Points[2],
				spline.Points[3],
				spline.Points[4],
				part
			}, spline.Tension)
			CatmullRomSpline.ConnectSpline(p, v)
		end
	elseif typeof(part) == "number" then
		if checkIfPointsMatch(part) then
			table.insert(points, p2 or #points + 1, part)
		end
	elseif typeof(part) == "Vector3" then
		if checkIfPointsMatch(part) then
			table.insert(points, p2 or #points + 1, part)
		end
	elseif part:IsA("BasePart") then
		if checkIfPointsMatch(part.Position) then
			table.insert(points, p2 or #points + 1, part)
		end
	else
		error("Invalid input received for CatmullRomSpline:AddPoint(), expected Vector3 or BasePart, got " .. tostring(part) .. "!")
	end

	if #points == 4 then
		CatmullRomSpline.UpdateLength(p)
	end
end

function CatmullRomSpline.RemovePoint(p, value: number)
	if type(value) ~= "number" then
		error("CatmullRomSpline:RemovePoint() expected a number as the input, got " .. tostring(value) .. "!")
	end

	local points = p.Points
	table.remove(points, value)
end

function CatmullRomSpline.GetPoints(p)
	local positions = {}

	for i = 1, #p.Points do
		positions[i] = typeof(p.Points[i]) == "Instance" and p.Points[i].Position or p.Points[i]
	end

	return positions
end

function CatmullRomSpline.ConnectSpline(p, p2)
	local points = p2.Points
	local splines = CatmullRomSpline.GetSplines(p)
	local points2 = splines[#splines].Points

	local function checkIfPointsMatch(p3)
		local points3 = CatmullRomSpline.GetPoints(p)

		for _, point in pairs(points3) do
			if typeof(point) ~= typeof(p3) then
				return false
			end
		end

		return true
	end

	if not checkIfPointsMatch((typeof(points2[1]) == "number" or typeof(points2[1]) == "Vector3") and points2[1] or points2[1].Position) then
		error("Cannot connect the spline because the splines do not have the same types of points!")
	end

	if points2[2] ~= points[1] or points2[3] ~= points[2] or points2[4] ~= points[3] then
		error("Cannot connect the spline because the splines do not share 3 common points!")
		return
	end

	table.insert(p.ConnectedSplines, p2)
	CatmullRomSpline.UpdateLength(p)
end

function CatmullRomSpline.GetSplines(p)
	local result = { p }

	for i = 1, #p.ConnectedSplines do
		table.insert(result, p.ConnectedSplines[i])
	end

	return result
end

function CatmullRomSpline.GetSplineAt(p, value: number)
	local splines = CatmullRomSpline.GetSplines(p)

	local function percentage(p2: number, p3: number, p4: number)
		local v = 1 / (p4 - p3)
		return v * p2 - v * p4 + 1
	end

	if type(value) ~= "number" then
		error("CatmullRomSpline:GetSplineAt() expected a number as an input, got " .. tostring(value) .. "!")
	end

	if #splines == 1 then
		return p, value
	end

	local v = 1 / #splines

	if value <= 0 then
		return p, value * v
	end

	if value >= 1 then
		return splines[#splines], (value - 1) * v + 1
	end

	local v2 = math.ceil(value * #splines)
	local spline = splines[v2]
	local v3 = (v2 - 1) * v
	local v4 = v2 * v
	local v5 = 1 / (v4 - v3)
	return spline, v5 * value - v5 * v4 + 1
end

function CatmullRomSpline:UpdateLength()
	local splines = CatmullRomSpline.GetSplines(self)
	local points = {}
	local total = 0

	for k, spline in pairs(splines) do
		local points2 = spline:GetPoints()

		if #points2 ~= 4 then
			error("Cannot get the length of the CatmullRomSpline object, expected 4 control points for all splines, got " .. tostring(#points) .. " points for spline " .. tostring(k) .. "!")
		end

		for _, point in pairs(points2) do
			table.insert(points, point)
		end
	end

	local lengthIterations = self.LengthIterations
	local lengthIndeces = {}

	for i = 1, lengthIterations do
		local derivativeAt = CatmullRomSpline.CalculateDerivativeAt(self, (i - 1) / (lengthIterations - 1))
		total += derivativeAt.Magnitude * (1 / lengthIterations)
		table.insert(lengthIndeces, { (i - 1) / (lengthIterations - 1), total, derivativeAt })
	end

	self.Length = total
	self.LengthIndeces = lengthIndeces
end

function CatmullRomSpline.CalculatePositionAt(p, value: number)
	if type(value) ~= "number" then
		error("The given t value in CatmullRomSpline:CalculatePositionAt() was not between 0 and 1, got " .. tostring(value) .. "!")
	end

	local splineAt, v = CatmullRomSpline.GetSplineAt(p, value)
	local points = CatmullRomSpline.GetPoints(splineAt)

	if #points ~= 4 then
		error("The CatmullRomSpline object has an invalid number of points (" .. tostring(#points) .. "), expected 4 points!")
	end

	local tension = splineAt.Tension
	local point = points[2]
	local v2 = tension * (points[3] - points[1])
	local v3 = 3 * (points[3] - points[2]) - tension * (points[4] - points[2]) - 2 * tension * (points[3] - points[1])
	local v4 = -2 * (points[3] - points[2]) + tension * (points[4] - points[2]) + tension * (points[3] - points[1])
	return point + v2 * v + v3 * v ^ 2 + v4 * v ^ 3
end

function CatmullRomSpline.CalculatePositionRelativeToLength(data, value: number)
	if type(value) ~= "number" then
		error("CatmullRomSpline:CalculatePositionRelativeToLength() only accepts a number, got " .. tostring(value) .. "!")
	end

	local points = data.Points

	if #points ~= 4 then
		error("The CatmullRomSpline object has an invalid number of points (" .. tostring(#points) .. "), expected 4 points!")
		return
	end

	local length = data.Length
	local lengthIndeces = data.LengthIndeces
	CatmullRomSpline.GetPoints(data)
	local v = length * value
	local v2 = nil
	local v3 = nil

	for i, lengthIndece in ipairs(lengthIndeces) do
		if not (v - lengthIndece[2] <= 0 or i == #lengthIndeces) then
			continue
		end

		v3 = lengthIndece
		v2 = i
		break
	end

	local v5, v6

	if lengthIndeces[v2 - 1] then
		v5 = CatmullRomSpline.CalculatePositionAt(data, lengthIndeces[v2 - 1][1])
		v6 = CatmullRomSpline.CalculatePositionAt(data, v3[1])
	else
		v5 = CatmullRomSpline.CalculatePositionAt(data, v3[1])
		v6 = CatmullRomSpline.CalculatePositionAt(data, lengthIndeces[v2 + 1][1])
	end

	local v7 = (v3[2] - v) / (v6 - v5).Magnitude
	return v5 + (v6 - v5) * (1 - v7)
end

function CatmullRomSpline.CalculateDerivativeAt(p, value: number)
	if type(value) ~= "number" then
		error("The given t value in CatmullRomSpline:CalculateDerivativeAt() was not between 0 and 1, got " .. tostring(value) .. "!")
	end

	local splineAt, v = CatmullRomSpline.GetSplineAt(p, value)
	local points = CatmullRomSpline.GetPoints(splineAt)

	if #points ~= 4 then
		error("The CatmullRomSpline object has an invalid number of points (" .. tostring(#points) .. "), expected 4 points!")
	end

	local tension = splineAt.Tension
	local v2 = tension * (points[3] - points[1])
	local v3 = 3 * (points[3] - points[2]) - tension * (points[4] - points[2]) - 2 * tension * (points[3] - points[1])
	local v4 = -2 * (points[3] - points[2]) + tension * (points[4] - points[2]) + tension * (points[3] - points[1])
	return v2 + 2 * v3 * v + 3 * v4 * v ^ 2
end

function CatmullRomSpline.CalculateDerivativeRelativeToLength(data, value: number)
	if type(value) ~= "number" then
		error("CatmullRomSpline:CalculateDerivativeRelativeToLength() only accepts a number, got " .. tostring(value) .. "!")
	end

	local points = data.Points

	if #points ~= 4 then
		error("The CatmullRomSpline object has an invalid number of points (" .. tostring(#points) .. "), expected 4 points!")
		return
	end

	local length = data.Length
	local lengthIndeces = data.LengthIndeces
	CatmullRomSpline.GetPoints(data)
	local v = length * value
	local v2 = nil
	local v3 = nil

	for i, lengthIndece in ipairs(lengthIndeces) do
		if not (v - lengthIndece[2] <= 0 or i == #lengthIndeces) then
			continue
		end

		v3 = lengthIndece
		v2 = i
		break
	end

	local v5, v6

	if lengthIndeces[v2 - 1] then
		v5 = CatmullRomSpline.CalculateDerivativeAt(data, lengthIndeces[v2 - 1][1])
		v6 = CatmullRomSpline.CalculateDerivativeAt(data, v3[1])
	else
		v5 = CatmullRomSpline.CalculateDerivativeAt(data, v3[1])
		v6 = CatmullRomSpline.CalculateDerivativeAt(data, lengthIndeces[v2 + 1][1])
	end

	local v7 = (v3[2] - v) / (v6 - v5).Magnitude
	return v5 + (v6 - v5) * (1 - v7)
end

return CatmullRomSpline