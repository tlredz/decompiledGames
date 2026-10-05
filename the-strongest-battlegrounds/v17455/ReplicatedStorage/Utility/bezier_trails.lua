local createVector = vector.create
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function clamp01(p)
	if p < 0 then
		return 0
	end

	if p > 1 then
		return 1
	end

	return p
end

local v = {
	linear = function(p)
		return p
	end,
	smooth = function(p)
		return p * p * (3 - 2 * p)
	end,
	easeIn = function(p)
		return p * p
	end,
	easeOut = function(p)
		return 1 - (1 - p) * (1 - p)
	end,
	easeInOut = function(p)
		local v2 = p * 2

		if v2 < 1 then
			return 0.5 * v2 * v2
		end

		local v3 = v2 - 1
		return 0.5 * (1 + (1 - v3) * (1 - v3) * -1 + 1)
	end,
	elastic = function(p)
		if p == 0 or p == 1 then
			return p
		end

		return math.pow(2, -10 * p) * math.sin((p - 0.075) * 6.283185307179586 / 0.3) + 1
	end
}

local function cubicBezier(p, p2, p3, p4, p5)
	local v2 = 1 - p5
	local v3 = v2 * v2
	local v4 = p5 * p5
	return v3 * v2 * p + 3 * v3 * p5 * p2 + 3 * v2 * v4 * p3 + v4 * p5 * p4
end

local function basisFromDir(p)
	local unit = p.Magnitude > 0.001 and p.Unit or createVector(0, 0, -1)
	local unit2 = unit:Cross(math.abs(unit.Y) > 0.9 and createVector(1, 0, 0) or createVector(0, 1, 0)).Unit
	return unit2, unit2:Cross(unit).Unit
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lookAt(position, p)
	if (p - position).Magnitude < 0.001 then
		return CFrame.new(position)
	end

	return CFrame.lookAt(position, p)
end

local function getPartFromTemplate(template)
	local clone = template:Clone()
	local v2 = clone:IsA("BasePart") and clone or clone:FindFirstChildWhichIsA("BasePart", true)

	if not v2 then
		clone:Destroy()
		error("Bezier: template must be or contain a BasePart with Trail")
	end

	v2.Anchored = true
	v2.CanCollide = false
	v2.CanQuery = false
	v2.CanTouch = false
	return clone, v2
end

local v2 = {
	front = "LookVector",
	forward = "LookVector",
	back = "LookVectorNeg",
	backward = "LookVectorNeg",
	right = "RightVector",
	left = "RightVectorNeg",
	up = "UpVector",
	down = "UpVectorNeg"
}

local function parseDirection(originCFrame, direction)
	if typeof(direction) == "Vector3" then
		return direction.Unit
	end

	if typeof(direction) == "string" then
		local v3 = string.lower(direction)
		local v4 = v2[v3]

		if v4 == "LookVector" then
			return originCFrame.LookVector
		elseif v4 == "LookVectorNeg" then
			return -originCFrame.LookVector
		elseif v4 == "RightVector" then
			return originCFrame.RightVector
		elseif v4 == "RightVectorNeg" then
			return -originCFrame.RightVector
		elseif v4 == "UpVector" then
			return originCFrame.UpVector
		elseif v4 == "UpVectorNeg" then
			return -originCFrame.UpVector
		end

		if v3 == "random" then
			local vector2 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)
			return (vector2.Magnitude < 0.001 and createVector(0, 0, -1) or vector2).Unit
		end
	end

	error("Bezier: 'direction' must be Vector3 or one of: front/back/left/right/up/down/random")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function numberOrRange(spreadAngle, p)
	if typeof(spreadAngle) == "number" then
		return spreadAngle
	end

	if typeof(spreadAngle) ~= "table" or not (#spreadAngle >= 2) then
		return p
	end

	local v3 = spreadAngle[1]
	local v4 = spreadAngle[2]

	if v4 < v3 then
		v3, v4 = v4, v3
	end

	return v3 + (v4 - v3) * math.random()
end

local function toNumberSequence(trailWidth)
	if typeof(trailWidth) == "NumberSequence" then
		return trailWidth
	end

	if typeof(trailWidth) == "number" then
		return NumberSequence.new(trailWidth)
	end

	if typeof(trailWidth) ~= "table" then
		return nil
	end

	local numberSequenceKeypoints = {}
	local count = #trailWidth

	if count > 0 and typeof(trailWidth[1]) == "table" and trailWidth[1].t ~= nil then
		for i = 1, count do
			local v3 = trailWidth[i]
			numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(v3.t or 0, v3.v or 1)
		end
	else
		for i = 1, count do
			numberSequenceKeypoints[i] = NumberSequenceKeypoint.new((i - 1) / (count - 1), trailWidth[i])
		end
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local function toColorSequence(trailColor)
	if typeof(trailColor) == "ColorSequence" then
		return trailColor
	end

	if typeof(trailColor) == "Color3" then
		return ColorSequence.new(trailColor)
	end

	if typeof(trailColor) ~= "table" then
		return nil
	end

	local count = #trailColor

	if count == 0 then
		return nil
	end

	local v3 = math.max(1, count - 1)
	local colorSequenceKeypoints = {}

	for i = 1, count do
		colorSequenceKeypoints[i] = ColorSequenceKeypoint.new((i - 1) / v3, trailColor[i])
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

local function computeControls(preset, position, _, unit, magnitude, options)
	local v3 = options or {}
	local unit2 = unit.Magnitude > 0.001 and unit.Unit or createVector(0, 0, -1)
	local unit3 = unit2:Cross(math.abs(unit2.Y) > 0.9 and createVector(1, 0, 0) or createVector(0, 1, 0)).Unit
	local unit4 = unit3:Cross(unit2).Unit
	local v4 = magnitude * (v3.along1 or 0.3)
	local v5 = magnitude * (v3.along2 or 0.7)
	local side = v3.side or 1
	local v6 = position + unit * v4
	local v7 = position + unit * v5

	if preset == "straight" then
		return v6, v7
	elseif preset == "arc" then
		local height = v3.height or 0.25 * magnitude
		return v6 + unit4 * height, v7 + unit4 * (height * 0.6)
	elseif preset == "s" then
		local sway = v3.sway or 0.3 * magnitude
		return v6 + unit3 * sway * side, v7 - unit3 * sway * side
	elseif preset == "loop" then
		local radius = v3.radius or math.max(6, magnitude * 0.25)
		return v6 + unit3 * radius * side, v7 - unit3 * radius * side
	elseif preset == "helix" then
		local radius = v3.radius or math.max(4, magnitude * 0.15)
		return v6 + unit3 * radius, v7 - unit3 * radius
	end

	if preset ~= "scatter" then
		return v6, v7
	end

	local spread = v3.spread or magnitude * 0.35
	local v8 = spread * 0.6
	return
		v6 + unit3 * (math.random() - 0.5) * 2 * spread + unit4 * (math.random() - 0.5) * 2 * v8,
		v7 + unit3 * (math.random() - 0.5) * 2 * v8 + unit4 * (math.random() - 0.5) * 2 * spread
end

return {
	Spawn = function(data)
		local DISTANCE_EPSILON = 0.001
		assert(data and typeof(data) == "table", "params table required")
		assert(typeof(data.originCFrame) == "CFrame", "originCFrame is required")
		assert(data.template, "Bezier: pass params.template (Part/Model with Trail)")

		if data.seed then
			math.randomseed(typeof(data.seed) == "number" and data.seed or tostring(data.seed):len())
		end

		local originCFrame = data.originCFrame
		local parent = data.parent or workspace.Thrown
		local template = data.template
		local count = data.count or 4
		local speed = data.speed or 120
		local lifetime = data.lifetime or 0.2
		local preset = string.lower(data.preset or "straight")
		local spreadAngle = data.spreadAngle
		local v3 = v[data.ease or "smooth"] or v.smooth
		local timeScale = data.timeScale or 1
		local delay = data.delay or 0
		local loops = data.loops or 1
		local pingpong = data.pingpong or false
		local reverse = data.reverse or false
		local alphaRange = data.alphaRange or {
			start = 0,
			finish = 1
		}
		local start = alphaRange.start or 0
		local finish = alphaRange.finish or 1
		local v4 = finish - start
		local v5 = math.max(1e-6, v4)
		local gravity = data.gravity or createVector(0, 0, 0)
		local v6 = gravity ~= createVector(0, 0, 0)
		local noiseType = string.lower(data.noiseType or "sine")
		local noiseAmplitude = data.noiseAmplitude or 1.5
		local noiseFrequency = data.noiseFrequency or 20
		local offsetFunction = data.offsetFunction
		local v7 = typeof(offsetFunction) == "function"
		local X, Y

		if typeof(noiseAmplitude) == "Vector2" then
			X = noiseAmplitude.X
			Y = noiseAmplitude.Y
		else
			Y = noiseAmplitude
			X = Y
			Y = X
		end

		local v8 = (data.trailColor or data.trailWidth or data.trailLifetime) ~= nil
		local color

		if v8 then
			color = toColorSequence(data.trailColor) or nil
		end

		local widthScale

		if v8 then
			widthScale = toNumberSequence(data.trailWidth) or nil
		end

		local trailLifetime = data.trailLifetime
		local numberRange = nil

		if typeof(trailLifetime) == "number" then
			numberRange = NumberRange.new(trailLifetime)
		elseif typeof(trailLifetime) == "NumberRange" then
			numberRange = trailLifetime
		end

		local endInstance = data.endInstance or typeof(data.endPositionProvider) == "function"
		local endInstance2 = data.endInstance
		local endPositionProvider = data.endPositionProvider
		local onStep = data.onStep
		local v11 = typeof(onStep) == "function"

		for _ = 1, count do
			local position = originCFrame.Position
			local endPosition, unit

			if data.endPosition then
				endPosition = data.endPosition
				local v12 = endPosition - position
				unit = v12.Magnitude > DISTANCE_EPSILON and v12.Unit or originCFrame.LookVector
			else
				assert(
					data.direction ~= nil or (data.endInstance or data.endPositionProvider),
					"Provide direction or end* to resolve end position"
				)

				if data.direction then
					unit = parseDirection(originCFrame, data.direction)
					local v12 = numberOrRange(spreadAngle, 0) -- equivalent call inferred; original call site unknown

					if v12 ~= 0 then
						local unit2 = Vector3.new(math.random(), math.random(), math.random()).Unit
						unit = CFrame.fromAxisAngle(unit2, (math.rad((math.random() - 0.5) * 2 * v12))):VectorToWorldSpace(unit)
					end

					local range = data.range or 60
					endPosition = position + unit.Unit * range
				else
					endPosition = endInstance2 and endInstance2.Position or endPositionProvider and endPositionProvider() or position + originCFrame.LookVector
					local v12 = endPosition - position
					unit = v12.Magnitude > DISTANCE_EPSILON and v12.Unit or originCFrame.LookVector
				end
			end

			local magnitude = (endPosition - position).Magnitude
			local control1 = data.control1
			local control2 = data.control2

			if not (control1 and control2) then
				control1, control2 = computeControls(preset, position, endPosition, unit, magnitude, data)
			end

			local v12 = 1 / (math.max(0.05, magnitude / math.max(0.001, speed)) / math.max(0.001, timeScale))
			local partFromTemplate, v13 = getPartFromTemplate(template)
			Debris:AddItem(v13, 14)
			partFromTemplate.Parent = parent
			v13.CFrame = CFrame.new(position)
			local trail = partFromTemplate:FindFirstChildOfClass("Trail")

			if v8 and trail then
				if color then
					trail.Color = color
				end

				if widthScale then
					trail.WidthScale = widthScale
				end

				if numberRange then
					trail.Lifetime = numberRange
				end
			end

			local v14 = unit
			local unit2 = v14.Magnitude > DISTANCE_EPSILON and v14.Unit or createVector(0, 0, -1)
			local unit3 = unit2:Cross(math.abs(unit2.Y) > 0.9 and createVector(1, 0, 0) or createVector(0, 1, 0)).Unit
			local unit4 = unit3:Cross(unit2).Unit
			local v15 = math.random() * 3.141592653589793 * 2
			local v16 = noiseFrequency * (0.85 + math.random() * 0.3)
			local v17 = X * (0.85 + math.random() * 0.3)
			local v18 = typeof(noiseAmplitude) == "Vector2" and Y or v17 * 0.6
			local v19 = v15 * 0.77
			local v20 = v16 * 3.141592653589793 * 2
			local v21 = v16 * 1.618 * 3.141592653589793 * 2
			local v22 = noiseType == "perlin"
			local total = 0
			local flag = false
			local v23 = not reverse
			local count2 = 0
			local heartbeatConnection = nil
			task.delay(15, function()
				if heartbeatConnection then
					heartbeatConnection:Disconnect()
				end

				if partFromTemplate and partFromTemplate.Parent then
					partFromTemplate:Destroy()
				end
			end)
			local v37 = partFromTemplate
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				if flag then
					local position2 = endInstance and (endInstance2 and endInstance2.Position or endPositionProvider and endPositionProvider())

					if position2 then
						endPosition = position2
						local v38 = endPosition - position

						if v38.Magnitude > 0.001 then
							unit = v38.Unit
						end
					end

					total += dt
					local v39 = clamp01(total * v12)
					local v41 = clamp01(((v23 and start + v4 * v39 or finish - v4 * v39) - start) / v5)
					local v43 = clamp01(v3(v41))
					local v47 = endPosition
					local v48 = 1 - v43
					local v49 = v48 * v48
					local v50 = v43 * v43
					local v51 = v49 * v48 * position + 3 * v49 * v43 * control1 + 3 * v48 * v50 * control2 + v50 * v43 * v47
					local v52

					if v22 then
						local v53 = noiseFrequency
						local v54 = math.noise(v43 * v53, v15, 0)
						local v55 = math.noise(v15, v43 * v53, 1)
						v52 = unit3 * v54 * X + unit4 * v55 * Y
					else
						local v53 = math.sin(v15 + v43 * v20) * v17
						local v54 = math.cos(v19 + v43 * v21) * v18
						v52 = unit3 * v53 + unit4 * v54
					end

					local position3 = v51 + v52

					if v6 then
						position3 += gravity * (total * total * 0.5)
					end

					if v7 then
						position3 += offsetFunction(v43)
					end

					local v54 = v13
					local cFrame = lookAt(v13.Position, position3) -- equivalent call inferred; original call site unknown
					v54.CFrame = cFrame
					v13.Position = position3

					if v11 then
						local success, result = pcall(onStep, v37, v43, position3, dt)

						if not success then
							warn("Bezier onStep error:", result)
						end
					end

					if v39 >= 1 then
						if pingpong then
							v23 = not v23
							total = 0
						else
							count2 += 1

							if loops == "inf" or loops == 0 or count2 < loops then
								total = 0
							else
								heartbeatConnection:Disconnect()
								Debris:AddItem(v37, lifetime)
							end
						end
					end
				else
					total += dt

					if delay <= total then
						flag = true
						total = 0
					end
				end
			end)
		end
	end
}