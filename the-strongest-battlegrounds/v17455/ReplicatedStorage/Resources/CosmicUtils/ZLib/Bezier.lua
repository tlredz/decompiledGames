local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local function getBezierFrameAndBasis(value: number, cframe: CFrame, cframe2: CFrame, cframe3: CFrame, cframe4: CFrame)
	local DISTANCE_EPSILON = 0.001
	local v = 1 - value
	local v2 = v * v
	local v3 = v2 * v
	local v4 = value * value
	local v5 = v4 * value
	local position = cframe.Position
	local position2 = cframe2.Position
	local position3 = cframe3.Position
	local position4 = cframe4.Position
	local v6 = position * v3 + position2 * (v2 * 3 * value) + position3 * (v * 3 * v4) + position4 * v5
	local v7 = (position2 - position) * (v2 * 3) + (position3 - position2) * (v * 6 * value) + (position4 - position3) * (v4 * 3)

	if v7.Magnitude < DISTANCE_EPSILON then
		if value < 0.5 then
			v7 = position2 - position
		else
			v7 = position4 - position3
		end

		if v7.Magnitude < DISTANCE_EPSILON then
			local v8 = position4 - position
			v7 = v8.Magnitude < DISTANCE_EPSILON and createVector(0, 0, -1) or v8
		end
	end

	local unit = v7.Unit
	local cross = unit:Cross(createVector(0, 1, 0))

	if cross.Magnitude < 0.0001 then
		cross = unit:Cross(createVector(0, 0, -1))
	end

	local unit2 = cross.Unit
	local unit3 = unit2:Cross(unit).Unit
	return CFrame.lookAt(v6, v6 + unit), unit2, unit3, unit
end

local function cubicBezier(p, p2, p3, p4, p5)
	local v = 1 - p5
	return v * v * v * p + 3 * (v * v) * p5 * p2 + 3 * v * (p5 * p5) * p3 + p5 * p5 * p5 * p4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function randomUnitVector()
	local vector2 = Vector3.new(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1)

	if vector2.Magnitude < 0.0001 then
		return createVector(0, 1, 0)
	end

	return vector2.Unit
end

local function expDamp(vector2: Vector3, p: number, p2: number)
	if p <= 0 then
		return vector2
	end

	return vector2 * math.exp(-p * p2)
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function parseDirection(originCFrame, direction)
	local typeName = typeof(direction)

	if typeName == "Vector3" then
		return direction.Unit
	end

	if typeName == "string" then
		local v = string.lower(direction)

		if v == "front" or v == "forward" then
			return originCFrame.LookVector
		end

		if v == "back" or v == "backward" then
			return -originCFrame.LookVector
		end

		if v == "right" then
			return originCFrame.RightVector
		elseif v == "left" then
			return -originCFrame.RightVector
		elseif v == "up" then
			return originCFrame.UpVector
		elseif v == "down" then
			return -originCFrame.UpVector
		elseif v == "random" then
			local vector2 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)
			return (vector2.Magnitude < 0.001 and createVector(0, 0, -1) or vector2).Unit
		end
	end

	error("BezierLightning: 'direction' must be Vector3 or one of: front, back, left, right, up, down, random")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveRangeDegrees(value)
	if typeof(value) ~= "table" or not (#value >= 2) then
		return value or 0
	end

	local v = value[1]
	local v2 = value[2]

	if v2 < v then
		v, v2 = v2, v
	end

	return v + (v2 - v) * math.random()
end

local function randomSpread(p, spreadAngle)
	local rangeDegrees = resolveRangeDegrees(spreadAngle) -- equivalent call inferred; original call site unknown

	if rangeDegrees <= 0 then
		return p.Unit
	end

	local unit = Vector3.new(math.random(), math.random(), math.random()).Unit
	local v = math.rad((math.random() - 0.5) * 2 * rangeDegrees)
	return CFrame.fromAxisAngle(unit, v):VectorToWorldSpace(p).Unit
end

local function perpendicular(p)
	local unit = p.Unit
	local unit2 = unit:Cross(math.abs(unit.Y) > 0.9 and createVector(1, 0, 0) or createVector(0, 1, 0)).Unit
	return unit2, unit2:Cross(unit).Unit
end

local function makeBoltInstance(template, parent, collide)
	local clone = template:Clone()
	clone.Parent = parent
	local v = clone:IsA("BasePart") and clone or clone:FindFirstChildWhichIsA("BasePart", true)

	if not v then
		clone:Destroy()
		error("BezierLightning: template must be a Part or contain a Part (with your Trail)")
	end

	v.Anchored = true
	v.CanCollide = collide and true or false
	v.CanQuery = false
	v.CanTouch = false
	return clone, v
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function warpTime(p)
	return p * p * (3 - 2 * p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lookAt(position, p)
	if (p - position).Magnitude < 0.001 then
		return CFrame.new(position)
	end

	return CFrame.lookAt(position, p)
end

local selected = {
	Charge = function(cframe: CFrame, p)
		local v2 = {
			Count = 30,
			SpawnRadius = 20,
			MinDuration = 0.8,
			MaxDuration = 1.5,
			Lifetime = 1,
			ParticleTemplate = "nil",
			ControlPointHeight = 15,
			RandomControlOffset = 8,
			Parent = workspace:FindFirstChild("Ignore") or workspace.Effects,
			EasingStyle = Enum.EasingStyle.Quart,
			EasingDirection = Enum.EasingDirection.Out,
			SpawnDelay = 0.05,
			SwirlStrength = 0,
			Speed = 1,
			WorldAcceleration = createVector(0, 0, 0),
			InitialVelocity = createVector(0, 0, 0),
			Drag = 0,
			Noise = 0,
			NoiseFrequency = 0,
			RandomRotation = false,
			RotationSpeedRange = NumberRange.new(-45, 45),
			AlignToTangent = true,
			Loop = false,
			EmitOnCreate = true,
			SpiralBeforeTravel = false,
			SpiralTime = 1,
			SpiralRadius = 15,
			SpiralSpeed = 6.283185307179586,
			SpiralHeight = 0,
			SpiralInward = true
		}
		assert(typeof(cframe) == "CFrame", "TargetCFrame Is Not A CFrame")
		assert(p.Parent, "Parent Required")
		assert(p.ParticleTemplate and p.ParticleTemplate:IsA("BasePart"), "Particle Template Nil Or Not A BasePart")

		for k, _ in v2 do
			if p[k] then
				v2[k] = p[k]
			end
		end

		for i = 1, v2.Count do
			local v3 = i
			task.spawn(function()
				local DISTANCE_EPSILON = 0.0001

				if v2.SpawnDelay > 0 then
					task.wait(v3 * v2.SpawnDelay)
				end

				local clone = v2.ParticleTemplate:Clone()
				clone.Anchored = false
				clone.CanCollide = false
				clone.CanTouch = false
				clone.Massless = true
				clone.Parent = v2.Parent
				local v4 = randomUnitVector() * math.random(0, v2.SpawnRadius)
				clone.CFrame = CFrame.new(cframe.Position + v4)

				if v2.SpiralBeforeTravel then
					local lastTime = os.clock()

					while os.clock() - lastTime < v2.SpiralTime do
						local v5 = os.clock() - lastTime
						local v6 = math.clamp(v5 / v2.SpiralTime, 0, 1)
						local v7 = v2.SpiralInward and v2.SpiralRadius * (1 - v6) or v2.SpiralRadius
						local v8 = v5 * v2.SpiralSpeed
						local v9 = math.cos(v8) * v7
						local v10 = math.sin(v8) * v7
						local v11 = v2.SpiralHeight * v6
						local v12 = cframe.Position + Vector3.new(v9, v11, v10)
						local vector2 = Vector3.new(-math.sin(v8), 0, (math.cos(v8)))
						local v13 = vector2.Magnitude < DISTANCE_EPSILON and createVector(0, 0, 1) or vector2

						if v2.AlignToTangent then
							clone.CFrame = CFrame.lookAt(v12, v12 + v13)
						else
							clone.CFrame = CFrame.new(v12)
						end

						RunService.Heartbeat:Wait()
					end
				end

				local v5 = math.random(v2.MinDuration * 100, v2.MaxDuration * 100) / 100 / v2.Speed
				local cframe2 = CFrame.new(clone.Position)
				local v6 = cframe
				local lerped = cframe2:Lerp(v6, 0.5)
				local v7 = randomUnitVector() * (math.random() * v2.RandomControlOffset)
				local v8 = randomUnitVector() * (math.random() * v2.RandomControlOffset)
				local v9 = v6.Position - cframe2.Position
				local unit = v9.Magnitude > DISTANCE_EPSILON and v9.Unit or createVector(0, 0, -1)
				local cross = unit:Cross(createVector(0, 1, 0))

				if cross.Magnitude < DISTANCE_EPSILON then
					cross = unit:Cross(createVector(0, 0, -1))
				end

				local unit2 = cross.Unit
				local v10 = unit2 * ((math.random() * 2 - 1) * v2.SwirlStrength)
				local v11 = unit2 * ((math.random() * 2 - 1) * v2.SwirlStrength)
				local v12 = cframe2.Position:Lerp(lerped.Position, 0.3) + Vector3.new(0, v2.ControlPointHeight, 0) + v7 + v10
				local v13 = lerped.Position:Lerp(v6.Position, 0.7) + Vector3.new(0, v2.ControlPointHeight, 0) + v8 + v11
				local cframe3 = CFrame.new(v12)
				local cframe4 = CFrame.new(v13)
				local numberValue = Instance.new("NumberValue")
				numberValue.Value = 0
				local tween = TweenService:Create(
					numberValue,
					TweenInfo.new(v5, v2.EasingStyle, v2.EasingDirection, 0, false, 0),
					{
						Value = 1
					}
				)
				local lastTime = os.clock()
				local now = lastTime
				local initialVelocity = v2.InitialVelocity
				local total = 0
				local v14 = math.random(v2.RotationSpeedRange.Min, v2.RotationSpeedRange.Max)
				local heartbeatConnection = nil
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					if clone and clone.Parent then
						local v15 = initialVelocity
						local drag = v2.Drag

						if not (drag <= 0) then
							v15 *= math.exp(-drag * dt)
						end

						initialVelocity = v15 + v2.WorldAcceleration * dt
						local bezierFrameAndBasis, v16, v17, v18 = getBezierFrameAndBasis(
							numberValue.Value,
							cframe2,
							cframe3,
							cframe4,
							v6
						)
						local v19 = os.clock() - lastTime
						local v20 = math.noise(v19 * v2.NoiseFrequency, v3, 0)
						local v21 = math.noise(v19 * v2.NoiseFrequency, 0, v3)
						local v22 = (v16 * v20 + v17 * v21) * v2.Noise
						local v23 = initialVelocity * (os.clock() - now)
						now = os.clock()

						if v2.RandomRotation then
							total += math.rad(v14) * dt
							bezierFrameAndBasis *= CFrame.fromAxisAngle(v18, total)
						end

						local v24 = bezierFrameAndBasis.Position + v22 + v23

						if v2.AlignToTangent then
							clone.CFrame = CFrame.lookAt(v24, v24 + v18)
						else
							clone.CFrame = CFrame.new(v24)
						end
					elseif heartbeatConnection then
						heartbeatConnection:Disconnect()
					end
				end)

				-- equivalent calls inferred from this helper; original call sites unknown
				local function cleanup()
					if heartbeatConnection then
						heartbeatConnection:Disconnect()
					end

					numberValue:Destroy()
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function playOnce()
					numberValue.Value = 0
					tween:Play()
				end

				if v2.EmitOnCreate then
					playOnce() -- equivalent call inferred; original call site unknown
				end

				tween.Completed:Connect(function()
					if v2.Loop and os.clock() - lastTime < v2.Lifetime then
						playOnce() -- equivalent call inferred; original call site unknown
					else
						cleanup() -- equivalent call inferred; original call site unknown
					end
				end)
				Debris:AddItem(clone, v2.Lifetime)
			end)
		end
	end,
	Projectile = function(data)
		local rootCF = data.RootCF
		local projectileTemplate = data.ProjectileTemplate
		local onHit = data.OnHit or function() end
		local count = data.Count or 1
		local spreadRadius = data.SpreadRadius or 5
		local startHeight = data.StartHeight or 5
		local duration = data.Duration or 1
		local arcHeight = data.ArcHeight or 10
		local evenlySpaced = data.EvenlySpaced or false
		local rotate = data.Rotate or false
		local spawnDelay = data.SpawnDelay or 0
		local lifetime = data.Lifetime or 1
		local v2 = rootCF.Position + Vector3.new(0, startHeight, 0)

		for i = 1, count do
			local vector2

			if evenlySpaced then
				local v3 = i / count * 3.141592653589793 * 2
				vector2 = Vector3.new(math.cos(v3) * spreadRadius, 0, math.sin(v3) * spreadRadius)
			else
				vector2 = Vector3.new(
					math.random(-spreadRadius, spreadRadius),
					0,
					math.random(-spreadRadius, spreadRadius)
				)
			end

			local v3 = rootCF.Position + vector2
			local v4 = math.random() * spawnDelay
			task.delay(v4, function()
				local clone = projectileTemplate:Clone()
				clone.CFrame = CFrame.new(v2)
				clone.Parent = workspace:FindFirstChild("Ignore") or workspace.Effects
				local v6 = (v2 + v3) / 2 + Vector3.new(0, arcHeight, 0)
				local v7 = duration / 30
				local total = 0

				-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
				local function bezierPoint(p, p2, p3, p4)
					return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
				end

				local heartbeatConnection = nil
				local RunService2 = game:GetService("RunService")
				heartbeatConnection = RunService2.Heartbeat:Connect(function(dt)
					total += dt / v7

					if total >= 30 then
						heartbeatConnection:Disconnect()

						if clone and clone.Parent then
							for i2, emitter in ipairs(clone:GetChildren()) do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(emitter:GetAttribute("EmitCount") or 30)
								end
							end

							onHit(clone.Position, clone)
							task.delay(lifetime, function()
								if clone and clone.Parent then
									clone:Destroy()
								end
							end)
						end
					else
						local v12 = bezierPoint(total / 30, v2, v6, v3)
						clone.CFrame = CFrame.new(v12)

						if rotate then
							local unit = (v3 - v12).Unit
							clone.CFrame = CFrame.new(v12, v12 + unit)
						end
					end
				end)
			end)
		end
	end
} or {}

function selected.Lightning(data)
	assert(data and typeof(data) == "table", "params table required")
	assert(typeof(data.originCFrame) == "CFrame", "originCFrame (CFrame) is required")
	assert(data.direction ~= nil, "direction is required (Vector3 or keyword)")
	local originCFrame = data.originCFrame
	local v2 = parseDirection(originCFrame, data.direction)
	local range = data.range or 60
	local count = data.count or 6
	local spreadAngle = data.spreadAngle or 6
	local speedMin = data.speedMin or 100
	local speedMax = data.speedMax or 140
	local amplitude = data.amplitude or 2.5
	local frequency = data.frequency or 24
	local lifetime = data.lifetime or 0.25
	local template = data.template
	local parent = data.parent or workspace:FindFirstChild("Ignore") or workspace.Effects
	local collide = data.collide or false
	assert(
		template,
		"BezierLightning: No template found. Pass params.template or create ReplicatedStorage.Assets.Skills.PunchOverdrive.BezierTrail"
	)
	local v3 = {
		_connections = {},
		_bolts = {},
		_alive = true,
		Destroy = function(self)
			if not self._alive then
				return
			end

			self._alive = false

			for _, _connection in ipairs(self._connections) do
				_connection:Disconnect()
			end

			for _, _bolt in ipairs(self._bolts) do
				if _bolt and _bolt.instance then
					Debris:AddItem(_bolt.instance, 0)
				end
			end

			self._connections = {}
			self._bolts = {}
		end
	}

	for _ = 1, count do
		local v4 = randomSpread(v2, spreadAngle)
		local position = originCFrame.Position
		local v5 = position + v4 * range
		local unit = v4.Unit
		local unit2 = unit:Cross(math.abs(unit.Y) > 0.9 and createVector(1, 0, 0) or createVector(0, 1, 0)).Unit
		local unit3 = unit2:Cross(unit).Unit
		local v6 = range * (0.1 + math.random() * 0.2)
		local v7 = range * (0.15 + math.random() * 0.25)
		local v8 = range * (0.5 + math.random() * 0.35)
		local v9 = unit2 * (v6 * (math.random() - 0.5) * 2) + unit3 * (v6 * (math.random() - 0.5) * 1.2)
		local v10 = unit2 * (v6 * (math.random() - 0.5) * 1.2) + unit3 * (v6 * (math.random() - 0.5) * 2)
		local v11 = position + v4 * v7 + v9
		local v12 = position + v4 * v8 + v10
		local boltInstance, v13 = makeBoltInstance(template, parent, collide)
		v13.CFrame = CFrame.new(position)
		local total = 0
		local v16 = position
		local heartbeatConnection = nil
		local v19 = math.max(
			0.05,
			range / (speedMin + math.random() * (speedMax - speedMin)) * (0.85 + math.random() * 0.3)
		)
		local v24 = math.random() * 3.141592653589793 * 2
		local v25 = frequency * (0.85 + math.random() * 0.3)
		local v26 = amplitude * (0.85 + math.random() * 0.3)
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			if not v3._alive then
				heartbeatConnection:Disconnect()
				return
			end

			total += dt / v19
			local v32 = warpTime(math.clamp(total, 0, 1))
			local v37 = 1 - v32
			local v38 = v37 * v37 * v37 * position + 3 * (v37 * v37) * v32 * v11 + 3 * v37 * (v32 * v32) * v12 + v32 * v32 * v32 * v5
			local v39 = math.sin(v24 + v32 * v25 * 3.141592653589793 * 2) * v26
			local v40 = math.cos(v24 * 0.77 + v32 * v25 * 1.618 * 3.141592653589793 * 2) * (v26 * 0.6)
			local position2 = v38 + unit2 * v39 + unit3 * v40
			local v42 = v13
			local cFrame = lookAt(v16, position2) -- equivalent call inferred; original call site unknown
			v42.CFrame = cFrame
			v13.Position = position2
			v16 = position2

			if v32 >= 1 then
				heartbeatConnection:Disconnect()
				Debris:AddItem(boltInstance, lifetime)
			end
		end)
		table.insert(v3._connections, heartbeatConnection)
		table.insert(v3._bolts, {
			instance = boltInstance
		})
	end

	return v3
end

return selected