local TrainTrackGeometry = {
	downsampleCorners = function(list, p: number)
		local count = #list

		if count <= 2 then
			return table.clone(list)
		end

		local result = { list[1] }
		local vector = nil

		for i = 2, count do
			local v = list[i] - list[i - 1]

			if not (v.Magnitude > 0.0001) then
				continue
			end

			local unit = v.Unit

			if vector == nil then
				vector = unit
			elseif p < math.deg((math.acos((math.clamp(vector:Dot(unit), -1, 1))))) then
				table.insert(result, list[i - 1])
				vector = unit
			end
		end

		table.insert(result, list[count])
		return result
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function rotateVector2(point: Vector2, p: number)
	local v = math.cos(p)
	local v2 = math.sin(p)
	return Vector2.new(point.X * v - point.Y * v2, point.X * v2 + point.Y * v)
end

function TrainTrackGeometry.roundCorners(list, p: number, p2: number)
	local count = #list

	if count <= 2 or p <= 0.001 or p2 < 1 then
		return list
	end

	local result = { list[1] }

	for i = 2, count - 1 do
		local v = list[i - 1]
		local v2 = list[i]
		local v3 = list[i + 1]
		local v4 = v2 - v
		local v5 = v3 - v2

		if v4.Magnitude <= 0.0001 or v5.Magnitude <= 0.0001 then
			table.insert(result, v2)
		else
			local unit = v4.Unit
			local unit2 = v5.Unit
			local v6 = math.acos((math.clamp(unit:Dot(unit2), -1, 1)))

			if v6 <= 0.001 then
				table.insert(result, v2)
			else
				local v7 = (3.141592653589793 - v6) * 0.5
				local v8 = math.min(p, v4.Magnitude * 0.5, v5.Magnitude * 0.5)
				local v9 = v8 * math.tan(v7)
				local v10 = -unit + unit2

				if v10.Magnitude <= 1e-6 or math.sin(v7) <= 1e-6 then
					table.insert(result, v2)
				else
					local v11 = v2 + v10.Unit * (v9 / math.sin(v7))
					local v12 = v2 - unit * v8 - v11
					local v13 = unit.X * unit2.Y - unit.Y * unit2.X >= 0 and 1 or -1
					local v14 = math.clamp(math.ceil(p2 * v6 / 3.141592653589793), 2, 32)

					for i2 = 0, v14 do
						local v15 = v13 * v6 * (i2 / v14)
						table.insert(result, v11 + rotateVector2(v12, v15))
					end
				end
			end
		end
	end

	table.insert(result, list[count])
	return result
end

function TrainTrackGeometry.smooth(p, data)
	return TrainTrackGeometry.roundCorners(
		TrainTrackGeometry.downsampleCorners(p, data.railAngleThresholdDeg or 5),
		data.railCornerRadius or 0,
		(math.max(1, (math.round(data.railCornerSegments or 1))))
	)
end

function TrainTrackGeometry.buildCumulativeLengths(items)
	local result = {}

	for k, item in items do
		result[k] = k == 1 and 0 or result[k - 1] + (item - items[k - 1]).Magnitude
	end

	return result
end

function TrainTrackGeometry.sample(list, p, value: number)
	local count = #list

	if count == 0 then
		return Vector2.zero, Vector2.new(1, 0)
	elseif count == 1 then
		return list[1], Vector2.new(1, 0)
	end

	local v = math.clamp(value, 0, p[count])
	local v2 = count - 1
	local v3 = 1

	while v3 < v2 do
		local v4 = (v3 + v2 + 1) // 2

		if p[v4] <= v then
			v3 = v4
		else
			v2 = v4 - 1
		end
	end

	local v4 = list[v3]
	local v5 = list[v3 + 1]
	local v6 = p[v3 + 1] - p[v3]
	local v7 = v6 <= 1e-6 and 0 or (v - p[v3]) / v6
	local v8 = v5 - v4
	local v9

	if v8.Magnitude <= 1e-6 then
		v9 = Vector2.new(1, 0)
	else
		v9 = v8.Unit
	end

	return v4 + v8 * v7, v9
end

function TrainTrackGeometry.buildRails(items, p: number)
	local result = {}
	local result2 = {}

	for _, item in items do
		local v = result[#result]

		if v == nil or (item - v).Magnitude > 0.0001 then
			table.insert(result, item)
		end
	end

	local count = #result

	if count < 2 or p <= 0 then
		return result2, result
	end

	local units = {}
	local vectors = {}

	for i = 1, count - 1 do
		local unit = (result[i + 1] - result[i]).Unit
		units[i] = unit
		vectors[i] = Vector2.new(-unit.Y, unit.X)
	end

	local units2 = {}
	local v = {}

	for i = 2, count - 1 do
		local v2 = vectors[i - 1] + vectors[i]

		if not (v2.Magnitude > 0.0001) then
			continue
		end

		local unit = v2.Unit
		local dot = unit:Dot(vectors[i])

		if not (dot >= 0.25) then
			continue
		end

		units2[i] = unit
		v[i] = 1 / dot
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function endpointFor(i: number, p2: number, p3: number)
		local v2 = units2[p2]

		if v2 then
			return result[p2] + v2 * (p * v[p2] * p3)
		end

		return result[p2] + vectors[i] * (p * p3)
	end

	for i = 1, count - 1 do
		for _, side in { 1, -1 } do
			local from = endpointFor(i, i, side) -- equivalent call inferred; original call site unknown
			local to = endpointFor(i, i + 1, side) -- equivalent call inferred; original call site unknown

			if (to - from):Dot(units[i]) > 1e-6 then
				table.insert(result2, {
					from = from,
					to = to,
					segmentIndex = i,
					side = side
				})
			end
		end
	end

	return result2, result
end

return TrainTrackGeometry