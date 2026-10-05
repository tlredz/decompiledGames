local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local seaEvents = workspace.SeaEvents
local Util = require(game.ReplicatedStorage.Util)

-- equivalent calls inferred from this helper; original call sites unknown
local function applyCommon(clone, data)
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false

	if data.Color then
		clone.Color = data.Color
	end

	clone.Transparency = data.Transparency == nil and 0.4 or data.Transparency or 0.4
end

local function projectToGround(cframe)
	if typeof(cframe) ~= "CFrame" then
		if typeof(cframe) == "Vector3" then
			cframe = CFrame.new(cframe)
		elseif typeof(cframe) == "Instance" then
			if cframe:IsA("CFrameValue") then
				cframe = cframe.Value
			elseif cframe:IsA("Vector3Value") then
				cframe = CFrame.new(cframe.Value)
			else
				cframe = CFrame.new()
			end
		else
			cframe = CFrame.new()
		end
	end

	local position = cframe.Position
	local success, result, v = pcall(function()
		local ray = Util.Ray
		local v2 = position + createVector(0, 50, 0)
		local v3 = { workspace.Characters, workspace.Enemies }
		return ray(v2, createVector(-0, -500, -0), v3)
	end)

	if success then
		if typeof(result) == "Vector3" then
			v = result
		elseif typeof(v) ~= "Vector3" then
			if typeof(result) == "Instance" then
				if typeof(v) ~= "Vector3" then
					v = position
				end
			else
				v = position
			end
		end
	else
		v = position
	end

	local v2 = v + createVector(0, 0.05, 0)
	return CFrame.new(v2)
end

local function spawnCircle(data)
	local circle = script:FindFirstChild("Circle")
	assert(circle, "BossIndicators: CircleTemplate missing")
	local clone = circle:Clone()
	applyCommon(clone, data) -- equivalent call inferred; original call site unknown
	local radius = data.Radius or 20
	local chargeTime = data.ChargeTime or 0
	local holdTime = data.HoldTime or 0
	local fadeTime = data.FadeTime or 0.25
	local size = circle.Size
	local v = math.min(size.X, size.Z) * 0.5
	local v2 = v <= 0 and 1 or v
	local originCF = data.OriginCF or CFrame.new()
	local originPart = data.OriginPart
	local mousePosValue = data.MousePosValue
	local ray = data.Ray ~= false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function computeOriginCF()
		if mousePosValue and mousePosValue.Parent then
			return CFrame.new(mousePosValue.Value)
		end

		if originPart and originPart.Parent then
			return originPart.CFrame
		end

		return originCF
	end

	local originCF2 = computeOriginCF() -- equivalent call inferred; original call site unknown
	local endCF

	if data.EndCF then
		endCF = data.EndCF
	elseif ray then
		endCF = projectToGround(originCF2)
	else
		endCF = originCF2
	end

	local position = originCF2.Position
	local position2 = endCF.Position
	local v4 = math.abs(position.Y - position2.Y)
	local heightThreshold = data.HeightThreshold or 10

	if data.ForcePillar or ray and heightThreshold < v4 then
		local minHeight = data.MinHeight
		local v5 = radius / v2
		local v6 = size.X * v5
		local v7 = size.Z * v5

		local function computePillarHeightAndCenter()
			local originCF3 = computeOriginCF() -- equivalent call inferred; original call site unknown
			local endCF2

			if data.EndCF then
				endCF2 = data.EndCF
			elseif ray then
				endCF2 = projectToGround(originCF3)
			else
				endCF2 = originCF3
			end

			local position3 = originCF3.Position
			local position4 = endCF2.Position
			local v9 = math.abs(position3.Y - position4.Y)

			if typeof(minHeight) == "number" and v9 < minHeight then
				v9 = minHeight
			end

			local selected = v9 < 0.1 and 0.1 or v9
			local v11 = math.min(position3.Y, position4.Y)
			return selected, (Vector3.new(position4.X, v11 + selected * 0.5, position4.Z))
		end

		if mousePosValue and mousePosValue.Parent and data.DynamicHeight == true then
			clone.Parent = seaEvents

			-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
			local function quadOut(p: number)
				return 1 - (1 - p) * (1 - p)
			end

			local function updatePillar(p: number)
				if not clone.Parent then
					return
				end

				local v8, v9 = computePillarHeightAndCenter()
				local v10 = p * 0.99 + 0.01
				local v11 = math.max(v6 * v10, 0.05)
				local v12 = math.max(v7 * v10, 0.05)
				clone.Size = Vector3.new(v11, v8, v12)
				clone.CFrame = CFrame.new(v9)
			end

			if chargeTime > 0 then
				local total = 0

				if clone.Parent then
					local v8, v9 = computePillarHeightAndCenter()
					clone.Size = Vector3.new(math.max(v6 * 0.01, 0.05), v8, (math.max(v7 * 0.01, 0.05)))
					clone.CFrame = CFrame.new(v9)
				end

				while clone.Parent and total < chargeTime do
					total += RunService.Heartbeat:Wait()
					local v9 = quadOut(math.clamp(total / chargeTime, 0, 1))

					if not clone.Parent then
						continue
					end

					local v10, v11 = computePillarHeightAndCenter()
					local v12 = v9 * 0.99 + 0.01
					clone.Size = Vector3.new(math.max(v6 * v12, 0.05), v10, (math.max(v7 * v12, 0.05)))
					clone.CFrame = CFrame.new(v11)
				end
			elseif clone.Parent then
				local v8, v9 = computePillarHeightAndCenter()
				clone.Size = Vector3.new(math.max(v6 * 1, 0.05), v8, (math.max(v7 * 1, 0.05)))
				clone.CFrame = CFrame.new(v9)
			end

			if holdTime > 0 and clone.Parent then
				local total = 0

				while clone.Parent and total < holdTime do
					total += RunService.Heartbeat:Wait()

					if not clone.Parent then
						continue
					end

					local v8, v9 = computePillarHeightAndCenter()
					clone.Size = Vector3.new(math.max(v6 * 1, 0.05), v8, (math.max(v7 * 1, 0.05)))
					clone.CFrame = CFrame.new(v9)
				end
			end

			if fadeTime > 0 and clone.Parent then
				local tween = TweenService:Create(
					clone,
					TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Transparency = 1
					}
				)
				tween:Play()
				tween.Completed:Wait()
			end

			if clone.Parent then
				clone:Destroy()
			end
		else
			local v8, v9 = computePillarHeightAndCenter()
			local vector2 = Vector3.new(v6, v8, v7)
			clone.CFrame = CFrame.new(v9)
			clone.Parent = seaEvents
			local vector3 = Vector3.new(math.max(vector2.X * 0.01, 0.05), v8, (math.max(vector2.Z * 0.01, 0.05)))

			if chargeTime > 0 then
				clone.Size = vector3
				local tween = TweenService:Create(
					clone,
					TweenInfo.new(chargeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Size = vector2
					}
				)
				tween:Play()
				tween.Completed:Wait()
			else
				clone.Size = vector2
			end

			if holdTime > 0 then
				task.wait(holdTime)
			end

			if fadeTime > 0 then
				local tween = TweenService:Create(
					clone,
					TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Transparency = 1
					}
				)
				tween:Play()
				tween.Completed:Wait()
			end

			clone:Destroy()
		end
	else
		clone.CFrame = CFrame.new(position2)
		clone.Parent = seaEvents
		local thickness = data.Thickness or size.Y
		local v5 = radius / v2
		local vector2 = Vector3.new(size.X * v5, thickness, size.Z * v5)
		local vector3 = Vector3.new(math.max(vector2.X * 0.01, 0.05), thickness, (math.max(vector2.Z * 0.01, 0.05)))
		local heartbeatConnection = nil

		if mousePosValue or originPart then
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				if clone.Parent then
					local endCF2 = computeOriginCF() -- equivalent call inferred; original call site unknown

					if data.EndCF then
						endCF2 = data.EndCF
					elseif ray then
						endCF2 = projectToGround(endCF2)
					end

					clone.CFrame = CFrame.new(endCF2.Position)
				elseif heartbeatConnection then
					heartbeatConnection:Disconnect()
					heartbeatConnection = nil
				end
			end)
		end

		if chargeTime > 0 then
			clone.Size = vector3
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(chargeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Size = vector2
				}
			)
			tween:Play()
			tween.Completed:Wait()
		else
			clone.Size = vector2
		end

		if holdTime > 0 then
			task.wait(holdTime)
		end

		if fadeTime > 0 then
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					Transparency = 1
				}
			)
			tween:Play()
			tween.Completed:Wait()
		end

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end

		clone:Destroy()
	end
end

local function spawnBeam(data)
	local beam = script:FindFirstChild("Beam")
	assert(beam and beam:IsA("Model"), "BossIndicators: Beam model missing")
	local pathPoints = data.PathPoints
	local radius = data.Radius or 60
	local chargeTime = data.ChargeTime or 0
	local fadeTime = data.FadeTime or 0.25
	local v = radius <= 0 and 0.1 or radius

	if not (pathPoints and #pathPoints >= 2) then
		return
	end

	local clone = beam:Clone()
	clone.Parent = seaEvents
	local primaryPart = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)

	if not (primaryPart and primaryPart:IsA("BasePart")) then
		clone:Destroy()
		return
	end

	local size = primaryPart.Size
	local v2 = math.min(size.X, size.Z) * 0.5
	local v3 = v2 <= 0 and 1 or v2
	local scale = clone:GetScale()
	clone:ScaleTo(v * ((scale <= 0 or scale ~= scale) and 1 or scale) / v3)
	local primaryPart2 = clone.PrimaryPart or primaryPart
	local trails = {}

	for _, trail in ipairs(clone:GetDescendants()) do
		if not trail:IsA("Trail") then
			continue
		end

		trail.Color = data.Color
		trail.Enabled = true
		table.insert(trails, trail)
	end

	local magnitudes = {}
	local total = 0

	for i = 1, #pathPoints - 1 do
		local magnitude = (pathPoints[i + 1] - pathPoints[i]).Magnitude
		magnitudes[i] = magnitude
		total += magnitude
	end

	if total <= 0 then
		clone:Destroy()
	elseif chargeTime <= 0 then
		local pathPoint = pathPoints[#pathPoints - 1]
		local pathPoint2 = pathPoints[#pathPoints]
		local v4 = pathPoint2 - pathPoint
		local unit = (v4.Magnitude < 0.001 and createVector(0, 0, 1) or v4).Unit
		local v5 = (pathPoint + pathPoint2) * 0.5
		primaryPart2.CFrame = CFrame.lookAt(v5, v5 + unit)

		if fadeTime > 0 then
			task.delay(fadeTime, function()
				if clone.Parent then
					game.Debris:AddItem(clone, fadeTime + 10)
				end
			end)
		else
			clone:Destroy()
		end
	else
		local lastTime = os.clock()
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if clone.Parent then
				local v4 = (os.clock() - lastTime) / chargeTime
				local v5 = v4 >= 1 and 1 or v4
				local v6 = total * v5
				local v7 = 1
				local total2 = 0

				while v7 <= #magnitudes and total2 + magnitudes[v7] < v6 do
					total2 += magnitudes[v7]
					v7 += 1
				end

				local v8, unit

				if #magnitudes < v7 then
					v8 = pathPoints[#pathPoints]
					local v9 = pathPoints[#pathPoints] - pathPoints[#pathPoints - 1]
					unit = v9.Magnitude > 0.001 and v9.Unit or createVector(0, 0, 1)
				else
					local pathPoint = pathPoints[v7]
					local pathPoint2 = pathPoints[v7 + 1]
					local v9 = magnitudes[v7]
					v8 = pathPoint:Lerp(pathPoint2, (v6 - total2) / math.max(v9, 0.001))
					unit = (pathPoint2 - pathPoint).Magnitude > 0.001 and (pathPoint2 - pathPoint).Unit or createVector(
						0,
						0,
						1
					)
				end

				primaryPart2.CFrame = CFrame.lookAt(v8, v8 + unit)

				if v5 >= 1 then
					if heartbeatConnection then
						heartbeatConnection:Disconnect()
					end

					for _, v9 in ipairs(trails) do
						v9.Enabled = false
					end

					if fadeTime > 0 then
						task.delay(fadeTime, function()
							if clone.Parent then
								game.Debris:AddItem(clone, fadeTime + 10)
							end
						end)
					else
						clone:Destroy()
					end
				end
			elseif heartbeatConnection then
				heartbeatConnection:Disconnect()
			end
		end)
	end
end

local function spawnSphere(data)
	local sphere = script:FindFirstChild("Sphere")
	assert(sphere, "BossIndicators: SphereTemplate missing")
	local clone = sphere:Clone()
	applyCommon(clone, data) -- equivalent call inferred; original call site unknown
	clone.Anchored = false
	local originPart = data.OriginPart
	local originCF = data.OriginCF or originPart and originPart.CFrame or CFrame.new()

	if originPart and originPart.Parent then
		clone.CFrame = originPart.CFrame
	else
		clone.CFrame = originCF
	end

	clone.Parent = seaEvents
	local radius = data.Radius or sphere.Size.X * 0.5
	local chargeTime = data.ChargeTime or 0
	local holdTime = data.HoldTime or 0
	local fadeTime = data.FadeTime or 0.25
	local size = sphere.Size
	local _ = math.min(size.X, size.Y, size.Z) * 0.5 <= 0
	local v = radius * 2 / size.X
	local vector2 = Vector3.new(size.X * v, size.Y * v, size.Z * v)
	clone.Size = Vector3.new(
		math.max(vector2.X * 0.01, 0.05),
		math.max(vector2.Y * 0.01, 0.05),
		(math.max(vector2.Z * 0.01, 0.05))
	)

	if originPart and originPart.Parent then
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Name = "BossIndicatorSphereWeld"
		weldConstraint.Part0 = clone
		weldConstraint.Part1 = originPart
		weldConstraint.Parent = clone
	end

	if chargeTime > 0 then
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(chargeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = vector2
			}
		)
		tween:Play()
		tween.Completed:Wait()
	else
		clone.Size = vector2
	end

	if holdTime > 0 then
		task.wait(holdTime)
	end

	if fadeTime > 0 then
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				Transparency = 1
			}
		)
		tween:Play()
		tween.Completed:Wait()
	end

	clone:Destroy()
end

local function spawnCone(data)
	local DISTANCE_EPSILON = 0.001
	local cone = script:FindFirstChild("Cone")
	assert(cone, "BossIndicators: ConeTemplate missing")
	local clone = cone:Clone()
	applyCommon(clone, data) -- equivalent call inferred; original call site unknown
	local originCF = data.OriginCF or CFrame.new()
	local position = originCF.Position
	local direction

	if data.Direction then
		direction = data.Direction
	elseif data.Target then
		direction = data.Target - position
	else
		direction = originCF.LookVector
	end

	if direction.Magnitude < DISTANCE_EPSILON then
		direction = originCF.LookVector
	end

	local unit = direction.Unit
	local length = data.Length or data.Radius or 30
	local width = data.Width or length
	local size = cone.Size
	local baseLength = cone:GetAttribute("BaseLength")

	if typeof(baseLength) ~= "number" or baseLength <= 0 then
		baseLength = size.Y
	end

	local baseWidth = cone:GetAttribute("BaseWidth")

	if typeof(baseWidth) ~= "number" or baseWidth <= 0 then
		baseWidth = size.X
	end

	local Z = size.Z
	local height = data.Height or data.Thickness or Z
	local v = length / baseLength
	local v2 = width / baseWidth
	local v3 = height / Z
	local vector2 = Vector3.new(size.X * v2, size.Y * v, size.Z * v3)
	local v4 = -unit
	local upVector = originCF.UpVector
	local vector3 = upVector.Magnitude < DISTANCE_EPSILON and createVector(0, 1, 0) or upVector
	local cross = (math.abs((vector3:Dot(v4))) > 0.98 and createVector(1, 0, 0) or vector3):Cross(v4)
	local unit2 = (cross.Magnitude < DISTANCE_EPSILON and createVector(1, 0, 0) or cross).Unit
	local unit3 = unit2:Cross(v4).Unit
	local chargeTime = data.ChargeTime or 0
	local holdTime = data.HoldTime or 0
	local fadeTime = data.FadeTime or 0.25
	clone.Parent = seaEvents

	local function setProgress(value: number)
		local v5 = math.clamp(value, 0, 1) * 0.99 + 0.01
		local v6 = math.max(vector2.Y * v5, 0.05)
		local v7 = math.max(vector2.X * v5, 0.05)
		local Z2 = vector2.Z
		clone.Size = Vector3.new(v7, v6, Z2)
		local v8 = position + unit * (v6 * 0.5)
		clone.CFrame = CFrame.fromMatrix(v8, unit2, v4, unit3)
	end

	if chargeTime > 0 then
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 0
		numberValue.Parent = clone
		numberValue.Changed:Connect(setProgress)
		local tween = TweenService:Create(
			numberValue,
			TweenInfo.new(chargeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Value = 1
			}
		)
		tween:Play()
		tween.Completed:Wait()
		numberValue:Destroy()
	else
		setProgress(1)
	end

	if holdTime > 0 then
		task.wait(holdTime)
	end

	if fadeTime > 0 then
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				Transparency = 1
			}
		)
		tween:Play()
		tween.Completed:Wait()
	end

	clone:Destroy()
end

local function spawnSector(data)
	local sector = script:FindFirstChild("Sector")
	assert(sector, "BossIndicators: SectorTemplate missing")
	local clone = sector:Clone()
	applyCommon(clone, data) -- equivalent call inferred; original call site unknown
	local v = projectToGround(data.OriginCF)
	local position = v.Position
	local direction

	if data.Direction then
		direction = data.Direction
	elseif data.Target then
		direction = data.Target - position
	else
		direction = v.LookVector
	end

	local v2 = direction * createVector(1, 0, 1)
	local unit = (v2.Magnitude < 0.001 and createVector(0, 0, 1) or v2).Unit
	local radius = data.Radius or data.Length or 30
	local baseRadius = sector:GetAttribute("BaseRadius")

	if typeof(baseRadius) ~= "number" or baseRadius <= 0 then
		baseRadius = math.min(sector.Size.Y, sector.Size.Z) * 0.5
	end

	local v3 = radius / baseRadius
	local size = sector.Size
	local X = size.X
	local vector2 = Vector3.new(X, size.Y * v3, size.Z * v3)
	clone.CFrame = CFrame.new(position, position + unit)
	clone.Parent = seaEvents
	local chargeTime = data.ChargeTime or 0
	local holdTime = data.HoldTime or 0
	local fadeTime = data.FadeTime or 0.25
	clone.Size = Vector3.new(X, 0.001, 0.001)

	if chargeTime > 0 then
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(chargeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = vector2
			}
		)
		tween:Play()
		tween.Completed:Wait()
	else
		clone.Size = vector2
	end

	if holdTime > 0 then
		task.wait(holdTime)
	end

	if fadeTime > 0 then
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				Transparency = 1
			}
		)
		tween:Play()
		tween.Completed:Wait()
	end

	clone:Destroy()
end

local function spawnRect(data)
	local block = script:FindFirstChild("Block")
	assert(block, "BossIndicators: RectTemplate missing")
	local clone = block:Clone()
	applyCommon(clone, data) -- equivalent call inferred; original call site unknown
	local v = projectToGround(data.OriginCF)
	local position = v.Position
	local direction

	if data.Direction then
		direction = data.Direction
	elseif data.Target then
		direction = data.Target - position
	else
		direction = v.LookVector
	end

	local v2 = direction * createVector(1, 0, 1)
	local unit = (v2.Magnitude < 0.001 and createVector(0, 0, 1) or v2).Unit
	local X, Y

	if data.Size then
		X = data.Size.X
		Y = data.Size.Y
	else
		X = data.SizeX or data.Width or 20
		Y = data.SizeZ or data.Length or 20
	end

	local Y2 = block.Size.Y
	local cframe = CFrame.new(position, position + unit)
	clone.Parent = seaEvents
	local chargeTime = data.ChargeTime or 0
	local holdTime = data.HoldTime or 0
	local fadeTime = data.FadeTime or 0.25

	local function setLength(value: number)
		local v3 = math.clamp(value, 0, 1)
		local v4 = math.max(0.01, Y * v3)
		clone.Size = Vector3.new(X, Y2, v4)
		clone.CFrame = cframe + unit * (v4 * 0.5)
	end

	if chargeTime > 0 then
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 0
		numberValue.Parent = clone
		numberValue.Changed:Connect(setLength)
		local tween = TweenService:Create(
			numberValue,
			TweenInfo.new(chargeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Value = 1
			}
		)
		tween:Play()
		tween.Completed:Wait()
		numberValue:Destroy()
	else
		local v3 = math.max(0.01, Y * math.clamp(1, 0, 1))
		clone.Size = Vector3.new(X, Y2, v3)
		clone.CFrame = cframe + unit * (v3 * 0.5)
	end

	if holdTime > 0 then
		task.wait(holdTime)
	end

	if fadeTime > 0 then
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				Transparency = 1
			}
		)
		tween:Play()
		tween.Completed:Wait()
	end

	clone:Destroy()
end

local function spawnLinear(data)
	local linear = script:FindFirstChild("Linear")
	assert(linear, "BossIndicators: Linear template missing")
	local clone = linear:Clone()
	clone.Parent = seaEvents
	local main = clone:WaitForChild("Main")
	local charge = clone:WaitForChild("Charge")

	for _, part in ipairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
	end

	local originCF = data.OriginCF or CFrame.new()
	local v = projectToGround(originCF)
	local position = v.Position
	local direction

	if data.Direction then
		direction = data.Direction
	elseif data.Target then
		direction = data.Target - position
	else
		direction = v.LookVector
	end

	local v2 = direction * createVector(1, 0, 1)
	local unit = (v2.Magnitude < 0.001 and createVector(0, 0, 1) or v2).Unit
	local radius = data.Radius
	local length

	if data.Length then
		length = data.Length
	elseif data.Size then
		length = data.Size.X
	else
		length = data.SizeX or 20
	end

	local Y

	if radius and radius > 0 then
		Y = radius * 2
	elseif data.Size then
		Y = data.Size.Y
	else
		Y = data.SizeZ or data.Width or 20
	end

	local v3 = length <= 0 and 20 or length
	local v4 = Y <= 0 and 20 or Y
	local size = main.Size
	local X = size.X
	local Z = size.Z
	local v5 = X <= 0 and 0.001 or X
	local v6 = Z <= 0 and 0.001 or Z
	local v7 = v3 / v5
	local v8 = v4 / v6
	local v9 = v7 <= 0 and 0.01 or v7
	local v10 = v8 <= 0 and 0.01 or v8

	for _, part in ipairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local size2 = part.Size
		part.Size = Vector3.new(size2.X * v9, size2.Y, size2.Z * v10)
	end

	local v11 = position + createVector(0, 0.05, 0)
	local vector2 = -unit
	local vector3 = createVector(0, 1, 0)
	local cross = vector2:Cross(math.abs((vector3:Dot(vector2))) > 0.99 and createVector(0, 0, 1) or vector3)
	local unit2 = (cross.Magnitude < 0.001 and createVector(0, 0, 1) or cross).Unit
	local unit3 = unit2:Cross(vector2).Unit
	clone:PivotTo(CFrame.fromMatrix(v11, vector2, unit3, unit2) * clone:GetPivot():ToObjectSpace(charge.CFrame):Inverse())
	local chargeTime = data.ChargeTime or 0
	local holdTime = data.HoldTime or 0
	local fadeTime = data.FadeTime or 0.25
	local color = data.Color

	if color then
		for _, image in ipairs(clone:GetDescendants()) do
			if image:IsA("ImageLabel") then
				image.ImageColor3 = color
			end
		end
	end

	for _, image in ipairs(clone:GetDescendants()) do
		if image:IsA("ImageLabel") then
			image.ImageTransparency = 1
		end
	end

	if chargeTime > 0 then
		local v12 = math.min(chargeTime * 0.25, 0.35)
		local tweenInfo = TweenInfo.new(v12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		for _, image in ipairs(clone:GetDescendants()) do
			if image:IsA("ImageLabel") then
				TweenService:Create(image, tweenInfo, {
					ImageTransparency = 0
				}):Play()
			end
		end

		local cFrame = charge.CFrame
		local v13 = -cFrame.RightVector
		local size2 = charge.Size
		local rotation = cFrame.Rotation
		local v14 = cFrame.Position - v13 * (size2.X * 0.5)
		charge.Size = Vector3.new(0.01, size2.Y, size2.Z)
		charge.CFrame = CFrame.new(v14 + v13 * 0.005) * rotation
		local tweenInfo2 = TweenInfo.new(chargeTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
		local vector4 = Vector3.new(v3, size2.Y, size2.Z)
		local cFrame2 = CFrame.new(v14 + v13 * (v3 * 0.5)) * rotation
		TweenService:Create(charge, tweenInfo2, {
			Size = vector4
		}):Play()
		TweenService:Create(charge, tweenInfo2, {
			CFrame = cFrame2
		}):Play()
		task.wait(chargeTime)
	else
		local cFrame = charge.CFrame
		local v12 = -cFrame.RightVector
		local size2 = charge.Size
		local rotation = cFrame.Rotation
		local v13 = cFrame.Position - v12 * (size2.X * 0.5)
		charge.Size = Vector3.new(v3, size2.Y, size2.Z)
		charge.CFrame = CFrame.new(v13 + v12 * (v3 * 0.5)) * rotation

		for _, image in ipairs(clone:GetDescendants()) do
			if image:IsA("ImageLabel") then
				image.ImageTransparency = 0
			end
		end
	end

	if holdTime > 0 then
		task.wait(holdTime)
	end

	if fadeTime > 0 then
		local tweenInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

		for _, image in ipairs(clone:GetDescendants()) do
			if image:IsA("ImageLabel") then
				TweenService:Create(image, tweenInfo, {
					ImageTransparency = 1
				}):Play()
			end
		end

		task.wait(fadeTime)
	end

	clone:Destroy()
end

local function spawnControlCircle(data)
	local mouseArea = script:FindFirstChild("MouseArea")
	assert(mouseArea, "BossIndicators: MouseArea missing")
	local clone = mouseArea:Clone()
	local main = clone:FindFirstChild("Main")

	if not (main and main:IsA("BasePart")) then
		main = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)
	end

	assert(main and main:IsA("BasePart"), "BossIndicators: MouseArea.Main missing")

	if not clone.PrimaryPart then
		pcall(function()
			clone.PrimaryPart = main
		end)
	end

	local radius = data.Radius or 20
	local chargeTime = data.ChargeTime or 0
	local holdTime = data.HoldTime or 0
	local _ = data.FadeTime or 0.25
	local size = main.Size
	local v = math.min(size.X, size.Z) * 0.5
	local v2 = v <= 0 and 1 or v
	local originCF = data.OriginCF or CFrame.new()
	local originPart = data.OriginPart
	local mousePosValue = data.MousePosValue
	local ray = data.Ray ~= false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function computeOriginCF()
		if mousePosValue and mousePosValue.Parent then
			return CFrame.new(mousePosValue.Value)
		end

		if originPart and originPart.Parent then
			return originPart.CFrame
		end

		return originCF
	end

	local function computeGroundCF(cframe: CFrame)
		if data.EndCF then
			return data.EndCF
		end

		if ray then
			return projectToGround(cframe)
		end

		return cframe
	end

	local endCF = computeOriginCF() -- equivalent call inferred; original call site unknown

	if data.EndCF then
		endCF = data.EndCF
	elseif ray then
		endCF = projectToGround(endCF)
	end

	local rotation = clone:GetPivot().Rotation
	clone:PivotTo(CFrame.new(endCF.Position) * rotation)
	clone.Parent = seaEvents
	local scale = clone:GetScale()
	local v3 = (scale <= 0 or scale ~= scale) and 1 or scale
	local _ = radius / v2
	local v4 = v3 * (radius / v2)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setScaleAbs(p: number)
		if not clone.Parent then
			return
		end

		local v5 = math.max(p, 0.001)
		pcall(function()
			clone:ScaleTo(v5)
		end)
	end

	local heartbeatConnection = nil

	if mousePosValue or originPart then
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if clone.Parent then
				local endCF2 = computeOriginCF() -- equivalent call inferred; original call site unknown

				if data.EndCF then
					endCF2 = data.EndCF
				elseif ray then
					endCF2 = projectToGround(endCF2)
				end

				clone:PivotTo(CFrame.new(endCF2.Position) * rotation)
			else
				if heartbeatConnection then
					heartbeatConnection:Disconnect()
				end

				heartbeatConnection = nil
			end
		end)
	end

	if chargeTime > 0 then
		local v5 = math.max(v4 * 0.01, 0.001)

		if clone.Parent then
			local v6 = math.max(v5, 0.001)
			pcall(function()
				clone:ScaleTo(v6)
			end)
		end

		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 0
		numberValue.Parent = clone

		-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
		local function quadOut(p: number)
			return 1 - (1 - p) * (1 - p)
		end

		local changedConnection = nil
		changedConnection = numberValue.Changed:Connect(function(value)
			if clone.Parent then
				local v7 = quadOut(math.clamp(value, 0, 1))
				setScaleAbs(v5 + (v4 - v5) * v7) -- equivalent call inferred; original call site unknown
			elseif changedConnection then
				changedConnection:Disconnect()
			end
		end)
		local tween = TweenService:Create(
			numberValue,
			TweenInfo.new(chargeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Value = 1
			}
		)
		tween:Play()
		tween.Completed:Wait()

		if changedConnection then
			changedConnection:Disconnect()
		end

		numberValue:Destroy()
	else
		local v5 = v4

		if clone.Parent then
			local v6 = math.max(v5, 0.001)
			pcall(function()
				clone:ScaleTo(v6)
			end)
		end
	end

	if holdTime > 0 then
		task.wait(holdTime)
	end

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if clone.Parent then
		clone:Destroy()
	end
end

return function(state)
	if not state then
		warn("BossIndicators: missing data table")
		return
	end

	if not state.OriginCF and state.OriginPart and state.OriginPart:IsA("BasePart") then
		state.OriginCF = state.OriginPart.CFrame
	end

	if state.Type == "Circle" then
		spawnCircle(state)
	elseif state.Type == "Beam" then
		spawnBeam(state)
	elseif state.Type == "Cone" then
		spawnCone(state)
	elseif state.Type == "Linear" then
		spawnRect(state)
	elseif state.Type == "Linear2" then
		spawnLinear(state)
	elseif state.Type == "Sector" then
		spawnSector(state)
	elseif state.Type == "Sphere" then
		spawnSphere(state)
	elseif state.Type == "ControlBoss" then
		spawnControlCircle(state)
	else
		warn("BossIndicators: unknown Type", state.Type)
	end
end