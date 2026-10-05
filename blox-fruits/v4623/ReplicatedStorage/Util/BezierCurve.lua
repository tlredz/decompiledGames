local BezierCurve = {
	Lerp = function(position, position2, p)
		if typeof(position) ~= "Vector3" then
			position = position.Position
		end

		if typeof(position2) ~= "Vector3" then
			position2 = position2.Position
		end

		return position + (position2 - position) * p
	end,
	GetFrameByDistance = function(position, position2, p)
		if typeof(position) ~= "Vector3" then
			position = position.Position
		end

		if typeof(position2) ~= "Vector3" then
			position2 = position2.Position
		end

		local v = not p and 1 or 1 + p
		return (math.round((position - position2).Magnitude * 2 * v))
	end,
	GetMiddlePosition = function(position, position2, value, p)
		if typeof(position) ~= "Vector3" then
			position = position.Position
		end

		if typeof(position2) ~= "Vector3" then
			position2 = position2.Position
		end

		local v = not p and 1 or 1 + p
		local v2 = (position - position2) * 0.5
		local v3 = position - v2
		local v4 = CFrame.new(v3, position2) * CFrame.Angles(0, 0, (math.rad(value or 0)))
		local v5 = v2.Magnitude * v
		return v3 + v4.UpVector * v5
	end,
	Get2MiddlePosition = function(position, position2, value, p, value2, p2)
		if typeof(position) ~= "Vector3" then
			position = position.Position
		end

		if typeof(position2) ~= "Vector3" then
			position2 = position2.Position
		end

		local v = not p and 1 or 1 + p
		local v2 = not p2 and 1 or 1 + p2

		local function GetResultPosition(p3, p4, p5, p6, p7)
			local v3 = (p3 - p4) * p7
			local v4 = p3 - v3
			local v5 = CFrame.new(v4, p4) * CFrame.Angles(0, 0, (math.rad(p5)))
			local v6 = v3.Magnitude * p6
			local _ = v4 + v5.UpVector * v6
		end

		local v3 = (position - position2) * 0.3333333333333333
		local v4 = position - v3
		local v5 = CFrame.new(v4, position2) * CFrame.Angles(0, 0, (math.rad(value or 0)))
		local v6 = v3.Magnitude * v
		local _ = v4 + v5.UpVector * v6
		local v7 = (position - position2) * 0.6666666666666666
		local v8 = position - v7
		local v9 = CFrame.new(v8, position2) * CFrame.Angles(0, 0, (math.rad(value2 or 0)))
		local v10 = v7.Magnitude * v2
		local _ = v8 + v9.UpVector * v10
		return nil, nil
	end
}

function BezierCurve.QuadraticBezierCurves(p, p2, p3, p4, p5, p6)
	coroutine.resume(coroutine.create(function()
		for i = 0, p do
			local v = i / p
			local lerped = BezierCurve.Lerp(p4, p5, v)
			local lerped2 = BezierCurve.Lerp(p5, p6, v)
			p3.Position = BezierCurve.Lerp(lerped, lerped2, v)
			task.wait(1 / p2)
		end
	end))
end

return BezierCurve