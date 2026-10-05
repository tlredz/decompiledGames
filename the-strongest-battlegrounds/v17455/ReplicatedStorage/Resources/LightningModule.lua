local createVector = vector.create
local AssetService = game:GetService("AssetService")
local RunService = game:GetService("RunService")
local v = 0
local nows = {}

local function warnThrottled(p, value, p2)
	local now = os.clock()

	if ((type(value) ~= "number" or not (value > 0 and value)) and 0.2 or value) > now - (nows[p] or 0) then
		return
	end

	nows[p] = now
	warn("[LightningV2ModuleDiag] " .. tostring(p2))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fmtVec3(data)
	if typeof(data) == "Vector3" then
		return string.format("(%.2f, %.2f, %.2f)", data.X, data.Y, data.Z)
	end

	return (tostring(data))
end

local v2 = {
	Thickness = 0.35,
	JitterScale = 1,
	Generations = 5,
	Duration = 0.35,
	TravelTime = 0,
	DriftSpeed = 0.5,
	DriftAmp = 0.5,
	DriftFreq = 0.2,
	Color = Color3.fromRGB(158, 197, 238),
	TextureRes = 128,
	SparksEnabled = false,
	SparkCount = 6,
	SparkLength = 5,
	SparkThickness = 0.15
}
local v3 = nil

local function GetElectricTexture(p)
	if v3 then
		return v3
	end

	local success, result = pcall(function()
		return AssetService:CreateEditableImage({
			Size = Vector2.new(p, p)
		})
	end)

	if not success then
		return nil
	end

	local buf = buffer.create(p * p * 4)

	for i = 0, p - 1 do
		for i2 = 0, p - 1 do
			local v4 = math.floor(math.clamp(math.noise(i2 * 0.1, i * 0.5, 999) + 0.5, 0, 1) * (1 - (math.abs(i2 / p - 0.5) * 2) ^ 2) * 255)
			local v5 = (i * p + i2) * 4
			buffer.writeu8(buf, v5, 255)
			buffer.writeu8(buf, v5 + 1, 255)
			buffer.writeu8(buf, v5 + 2, 255)
			buffer.writeu8(buf, v5 + 3, v4)
		end
	end

	result:WritePixelsBuffer(Vector2.zero, Vector2.new(p, p), buf)
	v3 = result
	return result
end

local function GetCurrentPosition(instance)
	if typeof(instance) == "Vector3" then
		return instance
	end

	if typeof(instance) == "Instance" then
		if instance:IsA("Attachment") then
			return instance.WorldPosition
		end

		if instance:IsA("BasePart") then
			return instance.Position
		end
	end

	if typeof(instance) == "table" and instance.Part then
		return instance.Part.CFrame:PointToWorldSpace(instance.Position or createVector(0, 0, 0))
	end

	return createVector(0, 0, 0)
end

local function GenerateFractalPoints(p, p2, p3, p4)
	local v4 = { p, p2 }

	for i = 1, p4 do
		local v5 = {}
		table.insert(v5, v4[1])

		for i2 = 1, #v4 - 1 do
			local v6 = v4[i2]
			local v7 = v4[i2 + 1]
			local midpoint = (v6 + v7) / 2
			local v9 = v7 - v6

			if v9.Magnitude < 1e-6 then
				local v11 = fmtVec3(v6) -- equivalent call inferred; original call site unknown
				local v12 = string.format(
					"GenerateFractalPoints zero segment gen=%d idx=%d p1=%s p2=%s",
					i,
					i2,
					v11,
					fmtVec3(v7)
				)
				local now = os.clock()

				if not (now - (nows.fractal_zero_seg or 0) < 0.2) then
					nows.fractal_zero_seg = now
					warn("[LightningV2ModuleDiag] " .. tostring(v12))
				end
			end

			local unit = v9.Unit
			local cross = unit:Cross((Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)))

			if cross.Magnitude < 0.001 then
				cross = unit:Cross(createVector(0, 1, 0))
			end

			table.insert(v5, midpoint + cross.Unit * (math.random() - 0.5) * p3)
			table.insert(v5, v7)
		end

		p3 /= 2
		v4 = v5
	end

	return v4
end

return {
	Cast = function(p, p2, items)
		if v >= 16 then
			return
		end

		local object = setmetatable({}, {
			__index = v2
		})

		if items then
			for k, item in pairs(items) do
				object[k] = item
			end
		end

		local success, result = pcall(function()
			return AssetService:CreateEditableMesh()
		end)

		if not (success and result) then
			warn("Lightning: Memory limit reached, skipping bolt.")
			return
		end

		v += 1
		local flag = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function release()
			if flag then
				return
			end

			flag = true
			v -= 1
		end

		local currentPosition = GetCurrentPosition(p)
		local currentPosition2 = GetCurrentPosition(p2)
		local magnitude = (currentPosition2 - currentPosition).Magnitude

		if magnitude < 0.01 then
			local v7 = fmtVec3(currentPosition) -- equivalent call inferred; original call site unknown
			local v8 = fmtVec3(currentPosition2) -- equivalent call inferred; original call site unknown
			local v9 = string.format("Cast zero-length start=%s end=%s len=%.5f", v7, v8, magnitude)
			local now = os.clock()

			if not (now - (nows.cast_zero_len or 0) < 0.2) then
				nows.cast_zero_len = now
				warn("[LightningV2ModuleDiag] " .. tostring(v9))
			end
		end

		local points2 = GenerateFractalPoints(
			currentPosition,
			currentPosition2,
			magnitude / object.JitterScale,
			object.Generations
		)
		local v7 = {
			{
				points = points2,
				width = object.Thickness
			}
		}

		if object.SparksEnabled and object.SparkCount > 0 then
			for _ = 1, object.SparkCount do
				local v8 = points2[math.random(1, #points2)]
				local v9 = v8 + Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit * object.SparkLength
				table.insert(v7, {
					points = GenerateFractalPoints(v8, v9, object.SparkLength / 1.5, 3),
					width = object.SparkThickness
				})
			end
		end

		local v8 = {}
		local v9 = math.random() * 1000

		local function RenderStrip(points, width)
			local DISTANCE_EPSILON = 1e-6
			local v10 = {}

			for i, v11 in ipairs(points) do
				local ratio = (i - 1) / (#points - 1)
				local v13 = width < object.Thickness and i == #points and 0 or width
				local v14 = i < #points and points[i + 1] - v11 or v11 - points[i - 1]

				if v14.Magnitude < DISTANCE_EPSILON then
					local v15 = string.format("RenderStrip zero forward delta idx=%d pos=%s", i, fmtVec3(v11))
					local now = os.clock()

					if not (now - (nows.strip_zero_forward or 0) < 0.2) then
						nows.strip_zero_forward = now
						warn("[LightningV2ModuleDiag] " .. tostring(v15))
					end
				end

				local unit = v14.Unit
				local cross = unit:Cross(createVector(0, 1, 0))

				if cross.Magnitude < DISTANCE_EPSILON then
					local v15 = string.format("RenderStrip forward parallel to up idx=%d forward=%s", i, fmtVec3(unit))
					local now = os.clock()

					if not (now - (nows.strip_right_cross_zero or 0) < 0.2) then
						nows.strip_right_cross_zero = now
						warn("[LightningV2ModuleDiag] " .. tostring(v15))
					end
				end

				local unit2 = cross.Magnitude > DISTANCE_EPSILON and cross.Unit or createVector(1, 0, 0)
				local unit3 = unit2:Cross(unit).Unit
				local v15 = result:AddVertex(v11 + unit2 * v13)
				local v16 = result:AddVertex(v11 - unit2 * v13)
				local v17 = result:AddVertex(v11 + unit3 * v13)
				local v18 = result:AddVertex(v11 - unit3 * v13)
				local v19 = width == object.Thickness and (i == 1 or i == #points) and 0 or 1
				table.insert(v8, {
					node = {
						idx = i,
						w = v19,
						t = v13,
						ratio = ratio,
						c = v11,
						dir = unit2,
						dirUp = unit3
					},
					v1 = v15,
					v2 = v16,
					v3 = v17,
					v4 = v18
				})
				table.insert(v10, {
					v = {
						v15,
						v16,
						v17,
						v18
					},
					u = { result:AddUV(Vector2.new(0, ratio)), (result:AddUV(Vector2.new(1, ratio))) },
					c = result:AddColor(object.Color, 1)
				})
			end

			for i = 1, #v10 - 1 do
				local v11 = v10[i]
				local v12 = v10[i + 1]
				local c = v11.c
				local c2 = v12.c

				local function AddQ(list, list2, list3)
					local v13 = result:AddTriangle(list[1], list[2], list[3])
					result:SetFaceUVs(v13, { list2[1], list2[2], list2[3] })
					result:SetFaceColors(v13, { list3[1], list3[2], list3[1] })
					local v14 = result:AddTriangle(list[2], list[4], list[3])
					result:SetFaceUVs(v14, { list2[2], list2[4], list2[3] })
					result:SetFaceColors(v14, { list3[2], list3[2], list3[1] })
				end

				AddQ({
					v11.v[1],
					v12.v[1],
					v11.v[2],
					v12.v[2]
				}, {
					v11.u[1],
					v12.u[1],
					v11.u[2],
					v12.u[2]
				}, { c, c2 })
				AddQ({
					v11.v[2],
					v12.v[2],
					v11.v[1],
					v12.v[1]
				}, {
					v11.u[2],
					v12.u[2],
					v11.u[1],
					v12.u[1]
				}, { c, c2 })
				AddQ({
					v11.v[3],
					v12.v[3],
					v11.v[4],
					v12.v[4]
				}, {
					v11.u[1],
					v12.u[1],
					v11.u[2],
					v12.u[2]
				}, { c, c2 })
				AddQ({
					v11.v[4],
					v12.v[4],
					v11.v[3],
					v12.v[3]
				}, {
					v11.u[2],
					v12.u[2],
					v11.u[1],
					v12.u[1]
				}, { c, c2 })
			end
		end

		local success2, result2 = pcall(function()
			for _, v10 in ipairs(v7) do
				RenderStrip(v10.points, v10.width)
			end

			return AssetService:CreateMeshPartAsync(Content.fromObject(result))
		end)

		if success2 and typeof(result2) == "Instance" then
			result2.CanQuery = false
			result2.CanTouch = false
			result2.Name = "LightningBolt"
			task.delay(10, function()
				if result2 and result2.Parent then
					result2:Destroy()
				end

				release() -- equivalent call inferred; original call site unknown
			end)
			result2.Color = Color3.fromRGB(253, 250, 255)
			result2.Anchored = true
			result2.CanCollide = false
			result2.CastShadow = false
			result2.Material = Enum.Material.Neon
			result2.Parent = workspace.Terrain
			result2.CFrame = CFrame.new(0, 0, 0)
			local v10 = {
				Object = result2,
				TimeScale = 1,
				IsActive = true
			}
			task.spawn(function()
				local travelTime = object.TravelTime or 0
				local v11 = object.Duration + travelTime
				local total = 0

				while v10.IsActive and result2.Parent do
					total += RunService.Heartbeat:Wait() * v10.TimeScale

					if v11 <= total then
						break
					end

					local v12 = not (travelTime > 0) and 1 or math.clamp(total / travelTime, 0, 1)
					local v13 = not (travelTime < total) and 0 or (total - travelTime) / object.Duration
					local v14 = 1 - math.pow(v13, 0.5)
					local v15 = total * object.DriftSpeed

					for _, v16 in ipairs(v8) do
						local node = v16.node

						if v12 < node.ratio then
							result:SetPosition(v16.v1, node.c)
							result:SetPosition(v16.v2, node.c)
							result:SetPosition(v16.v3, node.c)
							result:SetPosition(v16.v4, node.c)
						else
							local v17 = node.idx * object.DriftFreq
							local v18 = Vector3.new(
								math.noise(v17, v15, v9),
								math.noise(v17, v15, v9 + 100),
								(math.noise(v17, v15, v9 + 200))
							) * object.DriftAmp * node.w * (1 - v13)
							local v19 = node.t * v14
							local v20 = node.c + v18
							result:SetPosition(v16.v1, v20 + node.dir * v19)
							result:SetPosition(v16.v2, v20 - node.dir * v19)
							result:SetPosition(v16.v3, v20 + node.dirUp * v19)
							result:SetPosition(v16.v4, v20 - node.dirUp * v19)
						end
					end
				end

				v10.IsActive = false

				if result2 then
					result2:Destroy()
				end

				if result then
					result:Destroy()
				end

				release() -- equivalent call inferred; original call site unknown
			end)
			return v10
		else
			warn("Lightning: build/mesh failed: " .. tostring(result2))

			if result then
				result:Destroy()
			end

			release() -- equivalent call inferred; original call site unknown
		end
	end
}