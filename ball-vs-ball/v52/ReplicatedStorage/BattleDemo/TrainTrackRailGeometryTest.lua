local TrainTrackGeometry = require(script.Parent:WaitForChild("TrainTrackGeometry"))
local TrainTrackRailGeometryTest = {}

local function toleranceFor(items)
	local v = 1

	for _, item in items do
		v = math.max(v, math.abs(item.X), (math.abs(item.Y)))
	end

	return v * 4.7683716e-7
end

local v = {
	railAngleThresholdDeg = 10,
	railCornerRadius = 1,
	railCornerSegments = 6
}

local function isFinite(p: number)
	return p == p and p ~= 1e999 and p ~= -1e999
end

-- equivalent calls inferred from this helper; original call sites unknown
local function distanceToSegment(point: Vector2, point2: Vector2, point3: Vector2)
	local vector = point3 - point2
	local dot = vector:Dot(vector)

	if dot <= 1e-12 then
		return (point - point2).Magnitude
	end

	return (point - (point2 + vector * math.clamp((point - point2):Dot(vector) / dot, 0, 1))).Magnitude
end

local function distanceToPolyline(point: Vector2, list)
	local v2 = 1e999

	for i = 1, #list - 1 do
		local v4 = distanceToSegment(point, list[i], list[i + 1]) -- equivalent call inferred; original call site unknown
		v2 = math.min(v2, v4)
	end

	return v2
end

local function makeCorner(p: number, p2: number)
	local v2 = math.rad(p)
	return { Vector2.new(-p2, 0), Vector2.zero, Vector2.new(math.cos(v2), (math.sin(v2))) * p2 }
end

local function makePath(items, p: number)
	local result = { Vector2.zero }
	local vector = Vector2.new(1, 0)
	local zero = Vector2.zero

	for _, item in items do
		zero += vector * p
		table.insert(result, zero)
		local v2 = math.rad(item)
		local v3 = math.cos(v2)
		local v4 = math.sin(v2)
		vector = Vector2.new(vector.X * v3 - vector.Y * v4, vector.X * v4 + vector.Y * v3)
	end

	table.insert(result, zero + vector * p)
	return result
end

local function buildCases()
	local result = {}

	for _, v2 in {
		5,
		30,
		60,
		90,
		120,
		150,
		170,
		179.3
	} do
		table.insert(result, {
			name = string.format("倒圆折角 %.1f°", v2),
			points = makeCorner(v2, 12),
			smooth = true,
			seamless = true,
			measureGap = false
		})
		table.insert(result, {
			name = string.format("硬折角 %.1f°（不倒圆）", v2),
			points = makeCorner(v2, 12),
			smooth = false,
			seamless = false,
			measureGap = false
		})
	end

	table.insert(result, {
		name = "S 弯（左 60° 接右 60°）",
		points = makePath({ 60, -60 }, 10),
		smooth = true,
		seamless = true,
		measureGap = false
	})
	table.insert(result, {
		name = "典型轨道（六种折角混排）",
		points = makePath({
			15,
			-45,
			75,
			-105,
			135,
			-165,
			90,
			-30
		}, 12),
		smooth = true,
		seamless = true,
		measureGap = true
	})
	table.insert(result, {
		name = "退化微段夹在两条长直线之间",
		points = {
			Vector2.zero,
			Vector2.new(20, 0),
			Vector2.new(20.000001, 1e-6),
			Vector2.new(20, 12)
		},
		smooth = false,
		seamless = false,
		measureGap = false
	})
	local vectors = { Vector2.new(-15, 0) }

	for i = 0, 6 do
		table.insert(vectors, Vector2.new(i * 1e-6, i * 1e-6))
	end

	table.insert(vectors, Vector2.new(-15, 0.4))
	table.insert(result, {
		name = "坍缩的倒角弧（7 个点挤在 1e-6 内）",
		points = vectors,
		smooth = false,
		seamless = false,
		measureGap = false
	})
	local points = {}

	for k, v3 in { Vector2.new(-12, 0), Vector2.zero, Vector2.new(-0.9999999847691291, 0.0001745329243134484) * 12 } do
		points[k] = v3 + Vector2.new(60, 60)
	end

	table.insert(result, {
		name = "远离原点的 179.99° 掉头（倒圆后弧半径趋于 0）",
		points = points,
		smooth = true,
		seamless = false,
		measureGap = false
	})
	table.insert(result, {
		name = "两点直线",
		points = { Vector2.zero, Vector2.new(10, 0) },
		smooth = false,
		seamless = true,
		measureGap = false
	})
	table.insert(result, {
		name = "三点共线",
		points = { Vector2.zero, Vector2.new(5, 0), Vector2.new(10, 0) },
		smooth = true,
		seamless = true,
		measureGap = false
	})
	table.insert(result, {
		name = "单点",
		points = { Vector2.zero },
		smooth = false,
		seamless = true,
		measureGap = false
	})
	table.insert(result, {
		name = "空点串",
		points = {},
		smooth = false,
		seamless = true,
		measureGap = false
	})
	table.insert(result, {
		name = "重复点",
		points = { Vector2.zero, Vector2.zero, Vector2.new(8, 0) },
		smooth = false,
		seamless = true,
		measureGap = false
	})
	table.insert(result, {
		name = "极短段（0.02 studs）",
		points = makePath({ 90 }, 0.02),
		smooth = false,
		seamless = false,
		measureGap = false
	})
	return result
end

function TrainTrackRailGeometryTest.runCase(data)
	local v2

	if data.smooth then
		v2 = TrainTrackGeometry.smooth(data.points, v)
	else
		v2 = data.points
	end

	local rails, v3 = TrainTrackGeometry.buildRails(v2, 1)
	local v4 = toleranceFor(v3)
	local failures = {}
	local worstGaugeError = 0
	local v7 = {
		[1] = {},
		[-1] = {}
	}

	for _, rail in rails do
		local v8 = v3[rail.segmentIndex]
		local unit = (v3[rail.segmentIndex + 1] - v8).Unit
		local vector = Vector2.new(-unit.Y, unit.X)

		for k, v9 in {
			from = rail.from,
			to = rail.to
		} do
			local X = v9.X
			local v10

			if X == X and X ~= 1e999 then
				v10 = X ~= -1e999
			else
				v10 = false
			end

			if v10 then
				local Y = v9.Y
				local v11

				if Y == Y and Y ~= 1e999 then
					v11 = Y ~= -1e999
				else
					v11 = false
				end

				if v11 then
					local dot = (v9 - v8):Dot(vector)
					local v12 = math.abs(dot - rail.side * 1)

					if worstGaugeError < v12 then
						worstGaugeError = v12
					end

					if v4 < v12 then
						table.insert(
							failures,
							string.format(
								"段 %d 侧 %d 的 %s 垂距 %.9f，应为 %.9f（差 %.3e）——轨距不再恒定",
								rail.segmentIndex,
								rail.side,
								k,
								dot,
								rail.side * 1,
								v12
							)
						)
					end

					continue
				end
			end

			table.insert(failures, string.format("段 %d 侧 %d 的 %s 出现 NaN/inf", rail.segmentIndex, rail.side, k))
		end

		if (rail.to - rail.from):Dot(unit) <= 0 then
			table.insert(failures, string.format("段 %d 侧 %d 的铁轨方向与中心线相反（倒着走的铁轨）", rail.segmentIndex, rail.side))
		end

		local v9 = data.smooth and 1.036 or 4.001

		for k, v10 in {
			from = rail.from,
			to = rail.to,
			mid = (rail.from + rail.to) * 0.5
		} do
			local v11 = distanceToPolyline(v10, v3)

			if v9 * 1 + v4 < v11 then
				table.insert(
					failures,
					string.format(
						"段 %d 侧 %d 的 %s 离中心线 %.4f studs（上界 %.4f）——铁轨甩到轨道外面了",
						rail.segmentIndex,
						rail.side,
						k,
						v11,
						v9 * 1
					)
				)
			end
		end

		v7[rail.side][rail.segmentIndex] = rail
	end

	if data.seamless then
		for k, v8 in v7 do
			for k2, v9 in v8 do
				local v10 = v8[k2 + 1]

				if v10 and v4 < (v10.from - v9.to).Magnitude then
					table.insert(
						failures,
						string.format("段 %d 与 %d 在侧 %d 之间开缝 %.6f studs", k2, k2 + 1, k, (v10.from - v9.to).Magnitude)
					)
				end
			end
		end
	end

	local total = 0
	local total2 = 0

	for i = 1, math.max(0, #v3 - 1) do
		local magnitude = (v3[i + 1] - v3[i]).Magnitude
		total += magnitude

		for _, v8 in { 1, -1 } do
			if not v7[v8][i] then
				total2 += magnitude
			end
		end
	end

	return {
		name = data.name,
		failures = failures,
		railCount = #rails,
		cornerCount = #v3,
		worstGaugeError = worstGaugeError,
		centerlineLength = total,
		gapLength = total2,
		measureGap = data.measureGap
	}
end

function TrainTrackRailGeometryTest.runAll()
	local cases = buildCases()
	local worstGaugeError = 0
	local total = 0
	local total2 = 0
	local count = 0
	local count2 = 0

	for _, cas in cases do
		local v2 = TrainTrackRailGeometryTest.runCase(cas)

		if worstGaugeError < v2.worstGaugeError then
			worstGaugeError = v2.worstGaugeError
		end

		if v2.measureGap then
			total += v2.gapLength
			total2 += v2.centerlineLength
		end

		if #v2.failures == 0 then
			count2 += 1
			print(string.format(
				"[PASS] %s  折点=%d 铁轨段=%d 最大轨距误差=%.2e",
				v2.name,
				v2.cornerCount,
				v2.railCount,
				v2.worstGaugeError
			))
		else
			count += 1
			print(string.format("[FAIL] %s  折点=%d 铁轨段=%d", v2.name, v2.cornerCount, v2.railCount))

			for _, failure in v2.failures do
				print("       " .. failure)
			end
		end
	end

	local v2 = not (total2 > 0) and 0 or total / total2

	if v2 > 0.1 then
		count += 1
		print(string.format("[FAIL] 内轨缺口占比 %.2f%% 超过上限 %.0f%%——退化判据可能又把正常直线段误判进去了", v2 * 100, 10))
	else
		print(string.format("[PASS] 内轨缺口占比 %.2f%%（上限 %.0f%%，实测真实轨道约 5.7%%）", v2 * 100, 10))
	end

	local v3 = count == 0 and "PASS" or "FAIL"
	local v4 = string.format(
		"SUMMARY total=%d passed=%d failed=%d 最大轨距误差=%.2e 缺口占比=%.2f%% status=%s",
		#cases + 1,
		count2 + (v2 > 0.1 and 0 or 1),
		count,
		worstGaugeError,
		v2 * 100,
		v3
	)
	print(v4)
	return v4
end

return TrainTrackRailGeometryTest