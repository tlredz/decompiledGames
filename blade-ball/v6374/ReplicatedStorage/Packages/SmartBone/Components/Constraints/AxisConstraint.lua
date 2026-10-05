local createVector = vector.create

-- equivalent calls inferred from this helper; original call sites unknown
local function SafeUnit(p)
	if p.Magnitude == 0 then
		return createVector(0, 0, 0)
	end

	return p.Unit
end

return function(object, p, p2, cframe)
	local v = cframe:Inverse() * p
	local X = v.X
	local Y = v.Y
	local Z = v.Z
	local xAxisLimits = object.XAxisLimits
	local yAxisLimits = object.YAxisLimits
	local zAxisLimits = object.ZAxisLimits
	local v2 = object.AxisLocked[1] and 0 or 1
	local v3 = object.AxisLocked[2] and 0 or 1
	local v4 = object.AxisLocked[3] and 0 or 1

	if xAxisLimits.Min == -1e999 and xAxisLimits.Max == 1e999 and yAxisLimits.Min == -1e999 and yAxisLimits.Max == 1e999 and zAxisLimits.Min == -1e999 and zAxisLimits.Max == 1e999 then
		if v2 == 1 and v3 == 1 and v4 == 1 then
			return p
		end

		return cframe * Vector3.new(X * v2, Y * v3, Z * v4)
	else
		local v5 = xAxisLimits.Min + object.Radius
		local v6

		if v5 <= xAxisLimits.Max - object.Radius then
			v6 = xAxisLimits.Max - object.Radius or v5
		else
			v6 = v5
		end

		local v7 = yAxisLimits.Min + object.Radius
		local v8

		if v7 <= yAxisLimits.Max - object.Radius then
			v8 = yAxisLimits.Max - object.Radius or v7
		else
			v8 = v7
		end

		local v9 = zAxisLimits.Min + object.Radius
		local v10

		if v9 <= zAxisLimits.Max - object.Radius then
			v10 = zAxisLimits.Max - object.Radius or v9
		else
			v10 = v9
		end

		if X < v5 and v5 then
			X = v5
		elseif v6 < X then
			X = v6 or X
		end

		if Y < v7 and v7 then
			Y = v7
		elseif v8 < Y then
			Y = v8 or Y
		end

		if Z < v9 and v9 then
			Z = v9
		elseif v10 < Z then
			Z = v10 or Z
		end

		local v11 = X * v2
		local v12 = Y * v3
		local v13 = Z * v4
		local v14 = cframe * Vector3.new(v11, v12, v13)
		local rightVector = cframe.RightVector
		local upVector = cframe.UpVector
		local lookVector = cframe.LookVector
		local safeUnit = SafeUnit(v14 - p2) -- equivalent call inferred; original call site unknown

		if v11 ~= v.X then
			if rightVector:Dot(safeUnit) < 0 then
				rightVector = -rightVector or rightVector
			end

			object:ClipVelocity(v14, rightVector)
		end

		if v12 ~= v.Y then
			if upVector:Dot(safeUnit) < 0 then
				upVector = -upVector or upVector
			end

			object:ClipVelocity(v14, upVector)
		end

		if v13 ~= v.Z then
			if lookVector:Dot(safeUnit) > 0 then
				lookVector = -lookVector or lookVector
			end

			object:ClipVelocity(v14, lookVector)
		end

		return v14
	end
end