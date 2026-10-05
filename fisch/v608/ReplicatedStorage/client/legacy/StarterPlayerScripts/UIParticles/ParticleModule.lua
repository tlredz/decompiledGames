local createVector = vector.create
local ParticleModule = {}
local random = Random.new()
local v = {}
local v2 = {}
local v3 = {}
local lastTime = tick()
local v4 = nil
local RunService = game:GetService("RunService")

local function lerpValue(p, p2, p3)
	return p + (p2 - p) * p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function randomNumber(min, max)
	return random:NextNumber(max and min or 0, max or min)
end

local function randomInteger(p, p2)
	return random:NextInteger(p2 and p or 0, p2 or p)
end

local function getRandomNumberSequence(sequence)
	local v5 = {
		Keypoints = {}
	}

	for _, keypoint in ipairs(sequence.Keypoints) do
		local keypoints = v5.Keypoints
		local v6 = {
			Time = keypoint.Time,
			Value = 0
		}
		local v7 = keypoint.Value - keypoint.Envelope
		local v8 = keypoint.Value + keypoint.Envelope
		v6.Value = random:NextNumber(v8 and v7 or 0, v8 or v7)
		table.insert(keypoints, v6)
	end

	return v5
end

local function getKeypointsFromTime(sequence, p)
	for i, keypoint in ipairs(sequence.Keypoints) do
		if not (p < keypoint.Time) then
			continue
		end

		local keypoint2 = sequence.Keypoints[i - 1]
		local keypoint3 = sequence.Keypoints[i]
		return keypoint2, keypoint3, (p - keypoint2.Time) / (keypoint3.Time - keypoint2.Time)
	end
end

local function addParticle(emitter, parent, scale)
	local v5 = nil

	if not (parent and parent.Parent) then
		return
	end

	for k, v7 in v3 do
		if not v7.UI.Archivable then
			v7.UI.Archivable = true
		end

		if not parent.Archivable then
			parent.Archivable = true
		end

		if not (v7.UI and parent and v5) then
			continue
		end

		v5 = v7.UI
		v5.Parent = parent
		table.remove(v3, k)
		break
	end

	local flag

	if v5 then
		flag = false
	else
		v5 = Instance.new("ImageLabel")
		v5.BackgroundTransparency = 1
		v5.AnchorPoint = Vector2.new(0.5, 0.5)
		v5.Interactable = false
		v5.AutoLocalize = false
		flag = true
	end

	local v7 = v5:FindFirstChildOfClass("UIGradient")

	if not v7 then
		v7 = Instance.new("UIGradient")
		v7.Parent = v5
	end

	v7.Color = emitter.Color
	v5.Image = emitter.Texture
	v5.ZIndex = emitter.ZOffset
	local keypoint = emitter.Size.Keypoints[1]
	local v8 = keypoint.Value - keypoint.Envelope
	local v9 = keypoint.Value + keypoint.Envelope
	local v10 = random:NextNumber(v9 and v8 or 0, v9 or v8) * 100 * scale
	v5.Size = UDim2.new(0, v10, 0, v10)
	v5.Position = UDim2.new(random:NextNumber(0, 1), 0, random:NextNumber(0, 1), 0)
	v5.ImageTransparency = emitter.Transparency.Keypoints[1].Value
	local min = emitter.Rotation.Min
	local max = emitter.Rotation.Max
	v5.Rotation = random:NextNumber(max and min or 0, max or min)
	local lifetime = randomNumber(emitter.Lifetime.Min, emitter.Lifetime.Max) -- equivalent call inferred; original call site unknown
	local randomNumberSequence = getRandomNumberSequence(emitter.Transparency)
	local randomNumberSequence2 = getRandomNumberSequence(emitter.Size)

	if flag then
		v5.Parent = parent
	end

	local v13 = {
		UI = v5,
		Emitter = emitter,
		Start = tick(),
		Lifetime = lifetime,
		Transparency = randomNumberSequence,
		Size = randomNumberSequence2,
		Speed = 0,
		RotSpeed = 0,
		SpreadAngle = 0,
		StartPos = 0,
		Scale = 0,
		Accel = createVector(0, 0, 0),
		SpeedDisplacement = 0
	}
	local min3 = emitter.Speed.Min
	local max3 = emitter.Speed.Max
	v13.Speed = random:NextNumber(max3 and min3 or 0, max3 or min3) * 100 * scale
	local min4 = emitter.RotSpeed.Min
	local max4 = emitter.RotSpeed.Max
	v13.RotSpeed = random:NextNumber(max4 and min4 or 0, max4 or min4)
	local v14 = -emitter.SpreadAngle.X
	local Y = emitter.SpreadAngle.Y
	v13.SpreadAngle = random:NextNumber(Y and v14 or 0, Y or v14)
	v13.StartPos = v5.Position
	v13.Scale = scale
	table.insert(v2, v13)
end

local function updateParticles(dt)
	local v5 = {}

	for i = #v2, 1, -1 do
		local v6 = v2[i]
		local v7 = tick() - v6.Start
		local v8 = v7 / v6.Lifetime

		if v6.Lifetime <= v7 then
			table.insert(v5, v6)
		else
			local keypointsFromTime, v9, v10 = getKeypointsFromTime(v6.Transparency, v8)
			local UI = v6.UI
			local value = keypointsFromTime.Value
			UI.ImageTransparency = value + (v9.Value - value) * v10
			local keypointsFromTime2, v11, v12 = getKeypointsFromTime(v6.Size, v8)
			local value2 = keypointsFromTime2.Value
			local v13 = (value2 + (v11.Value - value2) * v12) * 100 * v6.Scale
			v6.UI.Size = UDim2.new(0, v13, 0, v13)
			local v14 = 1 - math.min(1, v7 ^ 4 * (v6.Emitter.Drag / 10))
			local spreadAngle = v6.SpreadAngle
			v6.SpeedDisplacement += v6.Speed * dt * v14
			v6.Accel += v6.Emitter.Acceleration * 100 * v6.Scale * v7 ^ 2 * dt * v14
			local uDim = UDim2.new(
				0,
				math.sin((math.rad(spreadAngle))) * v6.SpeedDisplacement,
				0,
				-math.cos((math.rad(spreadAngle))) * v6.SpeedDisplacement
			)
			v6.UI.Position = v6.StartPos + uDim + UDim2.new(0, v6.Accel.X, 0, -v6.Accel.Y)
		end
	end

	for _, v6 in ipairs(v5) do
		v6.UI.ImageTransparency = 1
		table.insert(v3, {
			UI = v6.UI,
			RemoveAt = tick() + 3 * v6.Emitter.Rate ^ (-1)
		})
		table.remove(v2, table.find(v2, v6))
	end
end

local function updateGarbage()
	for i = #v3, 1, -1 do
		local v5 = v3[i]

		if not (tick() >= v5.RemoveAt) then
			continue
		end

		v5.UI:Destroy()
		table.remove(v3, i)
	end
end

function ParticleModule.AddEmitter(_, instance, value)
	local parent = instance.Parent
	local scrollingFrame = parent:FindFirstAncestorWhichIsA("ScrollingFrame")
	local v5 = {
		Emitter = instance,
		lastEmission = tick(),
		Scale = value or 1,
		connections = {}
	}

	if scrollingFrame and scrollingFrame.ClipsDescendants then
		v5.containerPosition = scrollingFrame.AbsolutePosition
		v5.containerSize = scrollingFrame.AbsoluteSize
		v5.emitterPosition = parent.AbsolutePosition
		v5.emitterSize = parent.AbsoluteSize
		table.insert(v5.connections, scrollingFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
			if not instance.Enabled then
				return
			end

			v5.containerPosition = scrollingFrame.AbsolutePosition
		end))
		table.insert(v5.connections, scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			if not instance.Enabled then
				return
			end

			v5.containerSize = scrollingFrame.AbsoluteSize
		end))
		table.insert(v5.connections, parent:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
			if not instance.Enabled then
				return
			end

			v5.emitterPosition = parent.AbsolutePosition
		end))
		table.insert(v5.connections, parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			if not instance.Enabled then
				return
			end

			v5.emitterSize = parent.AbsoluteSize
		end))
	end

	table.insert(v, v5)
end

function ParticleModule:RemoveEmitter(p)
	for i = #v, 1, -1 do
		if v[i].Emitter ~= p then
			continue
		end

		for _, connection in v[i].connections do
			connection:Disconnect()
		end

		table.remove(v, i)
		break
	end
end

function isPointVisible(point: Vector2, point2: Vector2, point3: Vector2)
	local v5 = point2 + point3
	return point.X >= point2.X and point.X <= v5.X and point.Y >= point2.Y and point.Y <= v5.Y
end

RunService.RenderStepped:Connect(function(dt)
	v4 = tick() - lastTime
	debug.profilebegin("UIParticles")

	for _, v5 in ipairs(v) do
		local emitter = v5.Emitter

		if emitter and emitter.Parent then
			if emitter.Enabled and tick() - v5.lastEmission >= 1 / emitter.Rate and (not (emitter.Parent:IsA("GuiBase2d") and v5.emitterSize) or isPointVisible(
				v5.emitterPosition,
				v5.containerPosition,
				v5.containerSize
			) or isPointVisible(v5.emitterPosition + v5.emitterSize, v5.containerPosition, v5.containerSize)) then
				v5.lastEmission = tick()
				addParticle(emitter, emitter.Parent, v5.Scale)
			end
		else
			ParticleModule:RemoveEmitter(emitter)
		end
	end

	debug.profileend()
	updateParticles(dt)
	updateGarbage()
end)
return ParticleModule