local createVector = vector.create
local RunService = game:GetService("RunService")

-- equivalent calls inferred from this helper; original call sites unknown
local function bezier2(p, p2, p3, value)
	local v = math.clamp(value, 0, 1)
	local v2 = 1 - v
	return v2 * v2 * p + 2 * v2 * v * p2 + v * v * p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bezier2Tangent(p, p2, p3, value)
	local v = math.clamp(value, 0, 1)
	return 2 * (1 - v) * (p2 - p) + 2 * v * (p3 - p2)
end

local function buildArcLengthLUT(position, p, position2, sampleCount)
	local v = math.max(8, sampleCount or 60)
	local result = table.create(v + 1)
	local result2 = table.create(v + 1)
	result[1] = 0
	result2[1] = 0
	local v2 = position
	local total = 0

	for i = 1, v do
		local v3 = i / v
		local v4 = bezier2(position, p, position2, v3) -- equivalent call inferred; original call site unknown
		total += (v4 - v2).Magnitude
		result[i + 1] = v3
		result2[i + 1] = total
		v2 = v4
	end

	return result, result2, total
end

local function invArc(arcLengthLUT, list, p, p2)
	if p2 <= 0 then
		return 0
	end

	if p2 >= 1 then
		return 1
	end

	local v = p2 * p
	local count = #list
	local v2 = 1

	while v2 < count do
		local v3 = math.floor((v2 + count) / 2)

		if list[v3] < v then
			v2 = v3 + 1
		else
			count = v3
		end
	end

	local v3 = math.max(2, v2)
	local v4 = list[v3 - 1]
	local v5 = list[v3]
	local v6 = arcLengthLUT[v3 - 1]
	local v7 = arcLengthLUT[v3]
	local v8 = v5 - v4

	if v8 <= 1e-6 then
		return v6
	end

	local v9 = (v - v4) / v8
	return v6 + (v7 - v6) * v9
end

local function scaleModelTo(folder, p)
	if folder.ScaleTo then
		folder:ScaleTo(p)
		return
	end

	local pivot = folder:GetPivot()

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Size *= p
			local v = pivot:PointToObjectSpace(descendant.Position) * p
			descendant.CFrame = pivot * CFrame.new(v)
		elseif descendant:IsA("Attachment") then
			descendant.Position *= p
		end
	end
end

local function getPivotWithOffset(instance, attachment)
	local pivot = instance:GetPivot()

	if typeof(attachment) == "Instance" and attachment:IsA("Attachment") then
		local worldCFrame = attachment.WorldCFrame
		return worldCFrame * worldCFrame:ToObjectSpace(pivot)
	end

	if typeof(attachment) == "Vector3" then
		return pivot * CFrame.new(attachment)
	end

	return pivot
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lookAlong(p, p2, p3)
	local unit = p2.Magnitude > 1e-6 and p2.Unit or createVector(0, 0, 1)
	local unit2 = (p3 or createVector(0, 1, 0)):Cross(unit).Unit
	local unit3 = unit:Cross(unit2).Unit
	return CFrame.fromMatrix(p, unit2, unit3, unit)
end

local function clampAssemblyVelocities(folder, maxEndVelocity, p)
	local v = {}
	local v2 = maxEndVelocity or 10

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local assemblyRootPart = part.AssemblyRootPart or part

		if v[assemblyRootPart] then
			continue
		end

		v[assemblyRootPart] = true
		local assemblyLinearVelocity = assemblyRootPart.AssemblyLinearVelocity

		if not (v2 < assemblyLinearVelocity.Magnitude) then
			continue
		end

		if p == false then
			assemblyRootPart.AssemblyLinearVelocity = assemblyLinearVelocity.Unit * v2
		else
			assemblyRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			assemblyRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
		end
	end
end

local function animateOne(clone, data)
	local random = Random.new()
	local startCF = data.startCF
	local position = startCF.Position
	local position2 = data.endCF.Position
	local v = (position + position2) * 0.5 + Vector3.new(0, math.max(0, data.apexHeight or 12), 0)
	local arcLengthLUT, v2, v3 = buildArcLengthLUT(position, v, position2, data.sampleCount or 60)
	local duration = data.duration or 0.9

	if typeof(data.durationRange) == "table" and data.durationRange.min and data.durationRange.max then
		local min = data.durationRange.min
		local max = data.durationRange.max

		if max < min then
			max, min = min, max
		end

		duration = random:NextNumber(min, max)
	end

	local v4 = time() + (data.delay or 0)
	local v5 = v4 + math.max(0.05, duration)
	local stopEarly = math.clamp(data.stopEarly == nil and 0.04 or data.stopEarly or 0.04, 0, 0.2)
	local stopLift = data.stopLift or 0.2
	local scaleFrom = data.scaleFrom or 0.2
	local scaleTo = data.scaleTo or 1
	local v7 = scaleFrom
	scaleModelTo(clone, scaleFrom)
	clone:PivotTo(startCF)
	local spin = data.spin or createVector(0, 0, 0)
	local cframe = CFrame.new()
	local v8 = time()
	local pivotOffset = data.pivotOffset
	local v9 = typeof(pivotOffset) == "Instance" and pivotOffset:IsA("Attachment") and "attachment" or typeof(pivotOffset) == "Vector3" and "vector3" or "none"
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v10 = time()

		if v10 < v4 then
			v8 = v10
			return
		end

		local v11 = (v10 - v4) / (v5 - v4)
		local v12 = math.min(v11, 1 - stopEarly)
		local v13 = 1 - stopEarly <= v11
		local v14 = invArc(arcLengthLUT, v2, v3, math.clamp(v12, 0, 1))
		local v18 = bezier2(position, v, position2, v14) + Vector3.new(0, stopLift, 0)
		local v19 = scaleFrom + (scaleTo - scaleFrom) * math.clamp(v11, 0, 1)

		if math.abs(v19 - v7) > 0.0001 then
			scaleModelTo(clone, v19 / v7)
			v7 = v19
		end

		local cframe2

		if data.faceDirection or spin.Magnitude > 1e-6 then
			local v23 = bezier2Tangent(position, v, position2, v14) -- equivalent call inferred; original call site unknown
			local cframe3

			if data.faceDirection then
				cframe3 = lookAlong(v18, v23, nil)

				if not cframe3 then
					cframe3 = CFrame.new(v18)
				end
			else
				cframe3 = CFrame.new(v18)
			end

			local v24 = math.max(0.004166666666666667, v10 - v8)
			cframe *= CFrame.fromOrientation(spin.X * v24, spin.Y * v24, spin.Z * v24)
			cframe2 = cframe3 * cframe
		else
			cframe2 = CFrame.new(v18)
		end

		if v9 == "attachment" then
			cframe2 *= clone:GetPivot():ToObjectSpace(pivotOffset.WorldCFrame)
		elseif v9 == "vector3" then
			cframe2 *= CFrame.new(pivotOffset)
		end

		clone:PivotTo(cframe2)
		v8 = v10

		if v13 then
			renderSteppedConnection:Disconnect()
			clampAssemblyVelocities(clone, data.maxEndVelocity or 10, data.zeroOnExceed ~= false)

			if typeof(data.onComplete) == "function" then
				local v20 = {
					itemIndex = data.itemIndex,
					finalCFrame = clone:GetPivot(),
					duration = duration,
					stopEarly = stopEarly,
					meta = data.meta
				}
				task.defer(function()
					local success, result = pcall(data.onComplete, clone, v20)

					if not success then
						warn("LootArc onComplete error:", result)
					end
				end)
			end
		end
	end)
end

return {
	Play = function(list, startCF, options)
		local v = options or {}
		local random = Random.new()
		local count = #list

		if count == 0 then
			if typeof(v.onAllComplete) == "function" then
				task.defer(function()
					local success, result = pcall(v.onAllComplete)

					if not success then
						warn("LootArc onAllComplete error:", result)
					end
				end)
			end
		else
			local count2 = 0

			-- equivalent calls inferred from this helper; original call sites unknown
			local function markDone()
				count2 += 1

				if count2 == count and typeof(v.onAllComplete) == "function" then
					task.defer(function()
						local success, result = pcall(v.onAllComplete)

						if not success then
							warn("LootArc onAllComplete error:", result)
						end
					end)
				end
			end

			local onItemComplete = v.onItemComplete

			local function wrappedOnItemComplete(p, p2)
				if typeof(onItemComplete) == "function" then
					onItemComplete(p, p2)
				end

				markDone() -- equivalent call inferred; original call site unknown
			end

			for i, clone in ipairs(list) do
				if v.clone ~= false then
					clone = clone:Clone()
					clone.Parent = workspace
				end

				if not clone.PrimaryPart then
					for _, part in ipairs(clone:GetDescendants()) do
						if not part:IsA("BasePart") then
							continue
						end

						clone.PrimaryPart = part
						break
					end
				end

				local position = startCF.Position
				local lookVector = startCF.LookVector
				local radius = v.radius or 10
				local forwardBias = v.forwardBias or 0
				local itemsSpreadAngle = math.rad(v.itemsSpreadAngle or 60)

				if itemsSpreadAngle > 0 then
					local number = random:NextNumber(-itemsSpreadAngle / 2, itemsSpreadAngle / 2)
					lookVector = CFrame.fromAxisAngle(createVector(0, 1, 0), number) * lookVector
				end

				local number = random:NextNumber(radius * 0.5, radius)
				local v2 = position + lookVector.Unit * (forwardBias + number)

				if itemsSpreadAngle > 0 then
					v2 += startCF.RightVector * random:NextNumber(-number * 0.35, number * 0.35)
				end

				local v3 = v2 + Vector3.new(0, v.landYOffset or 0, 0)
				local pivotOffset = v.pivotOffset

				if v.pivotAttachmentName then
					local attachment = clone:FindFirstChild(v.pivotAttachmentName, true)

					if attachment and attachment:IsA("Attachment") then
						pivotOffset = attachment
					end
				end

				animateOne(clone, {
					startCF = startCF,
					endCF = CFrame.new(v3),
					apexHeight = v.apexHeight or 12,
					duration = v.duration,
					durationRange = v.durationRange,
					delay = (i - 1) * (v.stagger or 0.07),
					stopEarly = v.stopEarly,
					stopLift = v.stopLift,
					scaleFrom = v.scaleFrom or 0.2,
					scaleTo = v.scaleTo or 1,
					faceDirection = v.faceDirection ~= false,
					spin = v.spin or createVector(0, 2.0943952, 0),
					pivotOffset = pivotOffset,
					sampleCount = v.sampleCount or 60,
					maxEndVelocity = v.maxEndVelocity or 10,
					zeroOnExceed = v.zeroOnExceed ~= false,
					onComplete = wrappedOnItemComplete,
					itemIndex = i,
					meta = v.meta
				})
			end
		end
	end
}