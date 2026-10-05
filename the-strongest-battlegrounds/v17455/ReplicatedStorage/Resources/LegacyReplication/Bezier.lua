local Bezier = {}
Bezier.__index = Bezier

function B(p: number, p2: number, p3: number)
	local fact

	fact = function(p4: number)
		if p4 == 0 then
			return 1
		end

		return p4 * fact(p4 - 1)
	end

	local v = p == 0 and 1 or p * fact(p - 1)
	local v2 = p2 == 0 and 1 or p2 * fact(p2 - 1)
	local v3 = p - p2
	return v / (v2 * (v3 == 0 and 1 or v3 * fact(v3 - 1))) * p3 ^ p2 * (1 - p3) ^ (p - p2)
end

function Bezier.new(...)
	local self = setmetatable({}, Bezier)
	local positions = { ... }
	self.Points = {}
	self.LengthIterations = 1000
	self.LengthIndeces = {}
	self.Length = 0
	self._connections = {}

	for k, position in pairs(positions) do
		if typeof(position) == "CFrame" then
			position = position.Position
			positions[k] = position
		end

		if typeof(position) == "Vector3" or typeof(position) == "Instance" and position:IsA("BasePart") then
			self:AddBezierPoint(position)
		else
			error("The Bezier.new() constructor only takes in Vector3s and BaseParts as inputs!")
		end
	end

	return self
end

function Bezier:AddBezierPoint(part, value: number?)
	if (not part or typeof(part) ~= "Instance" or not part:IsA("BasePart")) and typeof(part) ~= "Vector3" then
		error("Bezier:AddBezierPoint() only accepts a Vector3 or BasePart as the first argument!")
		return
	end

	local v = {
		Type = typeof(part) == "Vector3" and "StaicPoint" or "BasePartPoint",
		Point = part
	}

	if v.Type == "BasePartPoint" then
		local changedConnection = part.Changed:Connect(function(p)
			if p == "Position" then
				self:UpdateLength()
			end
		end)
		local ancestryChangedConnection = part.AncestryChanged:Connect(function(_, parent)
			if parent == nil then
				local index = table.find(self.Points, v)

				if index then
					table.remove(self.Points, index)
				end

				changedConnection:Disconnect()
				changedConnection:Disconnect()
			end
		end)

		if not self._connections[part] then
			self._connections[part] = {}
		end

		table.insert(self._connections[part], changedConnection)
		table.insert(self._connections[part], ancestryChangedConnection)
	end

	if value and type(value) == "number" then
		table.insert(self.Points, value, v)
	elseif value then
		if type(value) ~= "number" then
			error("Bezier:AddBezierPoint() only accepts an integer as the second argument!")
		end
	else
		table.insert(self.Points, v)
	end

	self:UpdateLength()
end

function Bezier:ChangeBezierPoint(value: number, part)
	if type(value) ~= "number" then
		error("Bezier:ChangeBezierPoint() only accepts a number index as the first argument!")
	end

	if (not part or typeof(part) ~= "Instance" or not part:IsA("BasePart")) and typeof(part) ~= "Vector3" then
		error("Bezier:ChangeBezierPoint() only accepts a Vector3 or BasePart as the second argument!")
		return
	end

	local point = self.Points[value]

	if not point then
		error("Did not find BezierPoint at index " .. tostring(value))
		return
	end

	point.Type = typeof(part) == "Vector3" and "StaicPoint" or "BasePartPoint"
	point.Point = part
	self:UpdateLength()
end

function Bezier:GetAllPoints()
	local points = {}

	for i = 1, #self.Points do
		table.insert(points, self:GetPoint(i))
	end

	return points
end

function Bezier:GetPoint(p2: number)
	local points = self.Points

	if points[p2] then
		return typeof(points[p2].Point) == "Vector3" and points[p2].Point or points[p2].Point.Position
	end

	error("Did not find a BezierPoint at index " .. tostring(p2) .. "!")
end

function Bezier:RemoveBezierPoint(p: number)
	if self.Points[p] then
		local v = table.remove(self.Points, p)

		if typeof(v.Point) == "Instance" and v.Point:IsA("BasePart") then
			for _, connection in pairs(self._connections[v.Point]) do
				if connection.Connected then
					connection:Disconnect()
				end
			end

			self._connections[v.Point] = nil
		end

		self:UpdateLength()
	end
end

function Bezier:UpdateLength()
	local allPoints = self:GetAllPoints()
	local lengthIterations = self.LengthIterations

	if #allPoints < 2 then
		return 0, {
			{ 0, 0, 0 },
			{ 0, 0, 0 }
		}
	end

	local total = 0
	local lengthIndeces = {}

	for i = 1, lengthIterations do
		local derivativeAt = self:CalculateDerivativeAt((i - 1) / (lengthIterations - 1))
		total += derivativeAt.Magnitude * (1 / lengthIterations)
		table.insert(lengthIndeces, { (i - 1) / (lengthIterations - 1), total, derivativeAt })
	end

	self.Length = total
	self.LengthIndeces = lengthIndeces
end

function Bezier:CalculatePositionAt(value: number)
	if type(value) ~= "number" then
		error("Bezier:CalculatePositionAt() only accepts a number, got " .. tostring(value) .. "!")
	end

	if not (#self.Points > 0) then
		error("Bezier:CalculatePositionAt() only works if there is at least 1 BezierPoint!")
		return
	end

	local allPoints = self:GetAllPoints()
	local count = #allPoints
	local vector = Vector3.new()

	for i = 1, count do
		local allPoint = allPoints[i]
		vector += B(count - 1, i - 1, value) * allPoint
	end

	return vector
end

function Bezier:CalculatePositionRelativeToLength(value: number)
	if type(value) ~= "number" then
		error("Bezier:CalculatePositionRelativeToLength() only accepts a number, got " .. tostring(value) .. "!")
	end

	if not (#self.Points > 0) then
		error("Bezier:CalculatePositionRelativeToLength() only works if there is at least 1 BezierPoint!")
		return
	end

	local length = self.Length
	local lengthIndeces = self.LengthIndeces
	local _ = self.LengthIterations

	if not (#self:GetAllPoints() > 1) then
		return self:CalculatePositionAt(0)
	end

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
		v5 = self:CalculatePositionAt(lengthIndeces[v2 - 1][1])
		v6 = self:CalculatePositionAt(v3[1])
	else
		v5 = self:CalculatePositionAt(v3[1])
		v6 = self:CalculatePositionAt(lengthIndeces[v2 + 1][1])
	end

	local v7 = (v3[2] - v) / (v6 - v5).Magnitude
	return v5 + (v6 - v5) * (1 - v7)
end

function Bezier:CalculateDerivativeAt(value: number)
	if type(value) ~= "number" then
		error("Bezier:CalculateDerivativeAt() only accepts a number, got " .. tostring(value) .. "!")
	end

	if not (#self.Points > 1) then
		error("Bezier:CalculateDerivativeAt() only works if there are at least 2 BezierPoints!")
		return
	end

	local allPoints = self:GetAllPoints()
	local count = #allPoints
	local _ = count - 1
	local vector = Vector3.new()

	for i = 1, count - 1 do
		local allPoint = allPoints[i + 1]
		local allPoint2 = allPoints[i]
		local v = (count - 1) * (allPoint - allPoint2)
		vector += B(count - 2, i - 1, value) * v
	end

	return vector
end

function Bezier:CalculateDerivativeRelativeToLength(value: number)
	if type(value) ~= "number" then
		error("Bezier:CalculateDerivativeRelativeToLength() only accepts a number, got " .. tostring(value) .. "!")
	end

	if not (#self.Points > 1) then
		error("Bezier:CalculateDerivativeRelativeToLength() only works if there are at least 2 BezierPoints!")
		return
	end

	local length = self.Length
	local lengthIndeces = self.LengthIndeces
	local _ = self.LengthIterations
	self:GetAllPoints()
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
		v5 = self:CalculateDerivativeAt(lengthIndeces[v2 - 1][1])
		v6 = self:CalculateDerivativeAt(v3[1])
	else
		v5 = self:CalculateDerivativeAt(v3[1])
		v6 = self:CalculateDerivativeAt(lengthIndeces[v2 + 1][1])
	end

	local v7 = (v3[2] - v) / (v6 - v5).Magnitude
	return v5 + (v6 - v5) * (1 - v7)
end

function Bezier:CreateVector3Tween(value, items, p, flag: boolean?)
	if #self.Points == 0 then
		error("Bezier:CreateVector3Tween() only works if there is at least 1 BezierPoint in the Bezier!")
	end

	if typeof(value) ~= "Instance" and typeof(value) ~= "table" then
		error("Bezier:CreateVector3Tween() requires an Instance or a table as the first argument!")
	end

	if typeof(p) ~= "TweenInfo" then
		error("Bezier:CreateVector3Tween() requires a TweenInfo object as the third argument!")
	end

	local success, result = pcall(function()
		for _, item in pairs(items) do
			if typeof(value[item]) ~= "Vector3" and typeof(value[item]) ~= "nil" then
				return false
			end
		end

		return true
	end)

	if not (success and result) then
		error("Bezier:CreateVector3Tween() requires a matching property table with Vector3 or nil property names for the object as the second argument!")
		return
	end

	local TweenService = game:GetService("TweenService")
	local numberValue = Instance.new("NumberValue")
	local tween = TweenService:Create(numberValue, p, {
		Value = 1
	})
	local changedConnection = nil
	tween.Changed:Connect(function(p2)
		if p2 == "PlaybackState" then
			if tween.PlaybackState == Enum.PlaybackState.Playing then
				changedConnection = numberValue.Changed:Connect(function(p3)
					for _, item in pairs(items) do
						value[item] = flag and self:CalculatePositionRelativeToLength(p3) or self:CalculatePositionAt(p3)
					end
				end)
			elseif changedConnection then
				changedConnection:Disconnect()
				changedConnection = nil
			end
		end
	end)
	return tween
end

function Bezier:CreateCFrameTween(cframes, items, p, flag: boolean?)
	if #self.Points <= 1 then
		error("Bezier:CreateVector3Tween() only works if there are at least 2 BezierPoints in the Bezier!")
	end

	if typeof(cframes) ~= "Instance" and typeof(cframes) ~= "table" then
		error("Bezier:CreateCFrameTween() requires an Instance or a table as the first argument!")
	end

	if typeof(p) ~= "TweenInfo" then
		error("Bezier:CreateCFrameTween() requires a TweenInfo object as the third argument!")
	end

	local success, result = pcall(function()
		for _, item in pairs(items) do
			if typeof(cframes[item]) ~= "CFrame" and typeof(cframes[item]) ~= "nil" then
				return false
			end
		end

		return true
	end)

	if not (success and result) then
		error("Bezier:CreateCFrameTween() requires a matching property table with CFrame or nil property names for the object as the second argument!")
		return
	end

	local TweenService = game:GetService("TweenService")
	local numberValue = Instance.new("NumberValue")
	local tween = TweenService:Create(numberValue, p, {
		Value = 1
	})
	local changedConnection = nil
	tween.Changed:Connect(function(p2)
		if p2 == "PlaybackState" then
			if tween.PlaybackState == Enum.PlaybackState.Playing then
				changedConnection = numberValue.Changed:Connect(function(p3)
					for _, item in pairs(items) do
						local v = flag and self:CalculatePositionRelativeToLength(p3) or self:CalculatePositionAt(p3)
						local v2 = flag and self:CalculateDerivativeRelativeToLength(p3) or self:CalculateDerivativeAt(p3)
						cframes[item] = CFrame.new(v, v + v2)
					end
				end)
			elseif changedConnection then
				changedConnection:Disconnect()
				changedConnection = nil
			end
		end
	end)
	return tween
end

return Bezier