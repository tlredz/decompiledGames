local UIEmitterModule = {}
local random = Random.new()
local v = {}
local v2 = 0
local v3 = {}
local v4 = 0
local v5 = {}
local v6 = 0
local sin = math.sin
local cos = math.cos
local rad = math.rad
local min = math.min
local new = UDim2.new

local function swapRemove(p, p2, p3)
	p[p2] = p[p3]
	p[p3] = nil
	return p3 - 1
end

local function lerpValue(p, p2, p3)
	return p + (p2 - p) * p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function r_num(p, p2)
	return random:NextNumber(p2 and p or 0, p2 or p)
end

local function getRandomNumberSequence(sequence)
	local keypoints = sequence.Keypoints
	local result = {}

	for i = 1, #keypoints do
		local keypoint = keypoints[i]
		local v7 = {
			Time = keypoint.Time,
			Value = 0
		}
		local v8 = keypoint.Value - keypoint.Envelope
		local v9 = keypoint.Value + keypoint.Envelope
		v7.Value = random:NextNumber(v9 and v8 or 0, v9 or v8)
		result[i] = v7
	end

	return result
end

local function isStaticSequence(list)
	if #list <= 2 then
		if not (#list ~= 1 and list[1].Value ~= list[2].Value) then
			return true
		end
	end

	return false
end

local function isStaticColorSequence(sequence)
	local keypoints = sequence.Keypoints

	if #keypoints <= 2 then
		if not (#keypoints ~= 1 and keypoints[1].Value ~= keypoints[2].Value) then
			return true
		end
	end

	return false
end

local function getKeypointsFromTime(list, p)
	for i = 1, #list - 1 do
		local v7 = list[i]
		local v8 = list[i + 1]

		if v7.Time <= p and p <= v8.Time then
			return v7, v8, (p - v7.Time) / (v8.Time - v7.Time)
		end
	end

	local v7 = list[#list]
	return v7, v7, 0
end

local function addParticle(emitter, parent, scale, now)
	if not (parent and parent.Parent) or v4 >= 500 then
		return
	end

	local v7 = v6
	local UI = nil

	while v7 >= 1 do
		local v8 = v5[v7]

		if v8.UI and v8.UI.Parent then
			UI = v8.UI

			if pcall(function()
				UI.Parent = parent
			end) then
				local v9 = v5
				local v10 = v6
				v9[v7] = v9[v10]
				v9[v10] = nil
				v6 = v10 - 1
				break
			else
				UI = nil
				local v9 = v5
				local v10 = v6
				v9[v7] = v9[v10]
				v9[v10] = nil
				v6 = v10 - 1
			end
		else
			local v9 = v5
			local v10 = v6
			v9[v7] = v9[v10]
			v9[v10] = nil
			v6 = v10 - 1
		end

		v7 -= 1
	end

	if not UI then
		local success, result = pcall(function()
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.BackgroundTransparency = 1
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.Parent = parent
			return imageLabel
		end)
		UI = result

		if not success then
			return
		end
	end

	UI.Image = emitter.Texture
	UI.ZIndex = emitter.ZOffset
	local startPosX = r_num(1) -- equivalent call inferred; original call site unknown
	local startPosY = r_num(1) -- equivalent call inferred; original call site unknown
	UI.Position = new(startPosX, 0, startPosY, 0)
	UI.ImageColor3 = emitter.Color.Keypoints[1].Value
	local keypoint = emitter.Size.Keypoints[1]
	local v10 = keypoint.Value - keypoint.Envelope
	local v11 = keypoint.Value + keypoint.Envelope
	local v12 = random:NextNumber(v11 and v10 or 0, v11 or v10) * 100 * scale
	UI.Size = new(0, v12, 0, v12)
	local keypoint2 = emitter.Transparency.Keypoints[1]
	local v13 = keypoint2.Value - keypoint2.Envelope
	local v14 = keypoint2.Value + keypoint2.Envelope
	UI.ImageTransparency = random:NextNumber(v14 and v13 or 0, v14 or v13)
	local min2 = emitter.Rotation.Min
	local max = emitter.Rotation.Max
	UI.Rotation = random:NextNumber(max and min2 or 0, max or min2)
	local min3 = emitter.Speed.Min
	local max2 = emitter.Speed.Max
	local speed = random:NextNumber(max2 and min3 or 0, max2 or min3) * 100 * scale
	local rotSpeed = r_num(emitter.RotSpeed.Min, emitter.RotSpeed.Max) -- equivalent call inferred; original call site unknown
	local v18 = r_num(-emitter.SpreadAngle.X, emitter.SpreadAngle.Y) -- equivalent call inferred; original call site unknown
	local randomNumberSequence = getRandomNumberSequence(emitter.Transparency)
	local randomNumberSequence2 = getRandomNumberSequence(emitter.Size)
	local keypoints = emitter.Color.Keypoints
	local emissionDirection = emitter.EmissionDirection

	if emissionDirection == Enum.NormalId.Bottom then
		v18 += 180
	elseif emissionDirection == Enum.NormalId.Right then
		v18 += 90
	elseif emissionDirection == Enum.NormalId.Left then
		v18 += 270
	end

	local v19 = rad(v18)
	local dirX = sin(v19)
	local dirY = -cos(v19)
	local staticTransparency

	if #randomNumberSequence <= 2 then
		staticTransparency = #randomNumberSequence == 1 or randomNumberSequence[1].Value == randomNumberSequence[2].Value
	else
		staticTransparency = false
	end

	local staticSize

	if #randomNumberSequence2 <= 2 then
		staticSize = #randomNumberSequence2 == 1 or randomNumberSequence2[1].Value == randomNumberSequence2[2].Value
	else
		staticSize = false
	end

	local keypoints2 = emitter.Color.Keypoints
	local staticColor

	if #keypoints2 <= 2 then
		staticColor = #keypoints2 == 1 or keypoints2[1].Value == keypoints2[2].Value
	else
		staticColor = false
	end

	v4 += 1
	local v25 = v3
	local v26 = v4
	local v27 = {
		Emitter = emitter,
		UI = UI,
		Start = now,
		Lifetime = 0,
		Transparency = 0,
		Size = 0,
		Speed = 0,
		RotSpeed = 0,
		StartPosX = 0,
		StartPosY = 0,
		SpeedDisplacement = 0,
		AccelX = 0,
		AccelY = 0,
		Scale = 0,
		DirX = 0,
		DirY = 0,
		Drag = 0,
		AccelSrcX = 0,
		AccelSrcY = 0,
		StaticTransparency = 0,
		StaticSize = 0,
		StaticColor = 0,
		ColorKeypoints = 0
	}
	local min5 = emitter.Lifetime.Min
	local max4 = emitter.Lifetime.Max
	v27.Lifetime = random:NextNumber(max4 and min5 or 0, max4 or min5)
	v27.Transparency = randomNumberSequence
	v27.Size = randomNumberSequence2
	v27.Speed = speed
	v27.RotSpeed = rotSpeed
	v27.StartPosX = startPosX
	v27.StartPosY = startPosY
	v27.Scale = scale
	v27.DirX = dirX
	v27.DirY = dirY
	v27.Drag = emitter.Drag
	v27.AccelSrcX = emitter.Acceleration.X * 100 * scale
	v27.AccelSrcY = emitter.Acceleration.Y * 100 * scale
	v27.StaticTransparency = staticTransparency
	v27.StaticSize = staticSize
	v27.StaticColor = staticColor
	v27.ColorKeypoints = keypoints
	v25[v26] = v27
end

local RunService = game:GetService("RunService")
RunService:BindToRenderStep("UI_ParticleModule", Enum.RenderPriority.First.Value + 1, function(p)
	local now = os.clock()
	local v7 = v2

	while v7 >= 1 do
		local v8 = v[v7]
		local emitter = v8.Emitter

		if emitter and emitter.Parent then
			if emitter.Enabled and now - v8.lastEmission >= 1 / emitter.Rate then
				v8.lastEmission = now
				addParticle(emitter, emitter.Parent, v8.Scale, now)
			end
		else
			local v9 = v
			local v10 = v2
			v9[v7] = v9[v10]
			v9[v10] = nil
			v2 = v10 - 1
		end

		v7 -= 1
	end

	local v8 = v4

	while v8 >= 1 do
		local v9 = v3[v8]
		local UI = v9.UI

		if UI and UI.Parent then
			local v10 = now - v9.Start
			local lifetime = v9.Lifetime

			if lifetime <= v10 then
				UI.ImageTransparency = 1
				v6 += 1
				v5[v6] = {
					UI = UI,
					RemoveAt = now + 3 / v9.Emitter.Rate
				}
				local v11 = v3
				local v12 = v4
				v11[v8] = v11[v12]
				v11[v12] = nil
				v4 = v12 - 1
			else
				local v11 = v10 / lifetime

				if not v9.StaticTransparency then
					local keypointsFromTime, v12, v13 = getKeypointsFromTime(v9.Transparency, v11)

					if keypointsFromTime then
						local value = keypointsFromTime.Value
						UI.ImageTransparency = value + (v12.Value - value) * v13
					end
				end

				if not v9.StaticSize then
					local keypointsFromTime, v12, v13 = getKeypointsFromTime(v9.Size, v11)

					if keypointsFromTime then
						local value = keypointsFromTime.Value
						local v14 = (value + (v12.Value - value) * v13) * 100 * v9.Scale
						UI.Size = new(0, v14, 0, v14)
					end
				end

				if not v9.StaticColor then
					local keypointsFromTime, v12, v13 = getKeypointsFromTime(v9.ColorKeypoints, v11)

					if keypointsFromTime then
						UI.ImageColor3 = keypointsFromTime.Value:Lerp(v12.Value, v13)
					end
				end

				UI.Rotation += v9.RotSpeed * p
				local v13 = 1 - min(1, v10 ^ 4 * (v9.Drag / 10))
				v9.SpeedDisplacement += v9.Speed * p * v13
				local v14 = v10 ^ 2 * p * v13
				v9.AccelX += v9.AccelSrcX * v14
				v9.AccelY += v9.AccelSrcY * v14
				local v15 = v9.DirX * v9.SpeedDisplacement + v9.AccelX
				local v16 = v9.DirY * v9.SpeedDisplacement - v9.AccelY
				UI.Position = new(v9.StartPosX, v15, v9.StartPosY, v16)
			end
		else
			local v10 = v3
			local v11 = v4
			v10[v8] = v10[v11]
			v10[v11] = nil
			v4 = v11 - 1
		end

		v8 -= 1
	end

	local v9 = v6

	while v9 >= 1 do
		local v10 = v5[v9]

		if v10.RemoveAt <= now then
			pcall(v10.UI.Destroy, v10.UI)
			local v11 = v5
			local v12 = v6
			v11[v9] = v11[v12]
			v11[v12] = nil
			v6 = v12 - 1
		end

		v9 -= 1
	end
end)

function UIEmitterModule.AddEmitter(_, emitter, value)
	v2 += 1
	v[v2] = {
		Emitter = emitter,
		lastEmission = os.clock(),
		Scale = value or 1
	}
end

function UIEmitterModule.RemoveEmitter(_, p)
	for i = v2, 1, -1 do
		if v[i].Emitter ~= p then
			continue
		end

		local v7 = v
		local v8 = v2
		v7[i] = v7[v8]
		v7[v8] = nil
		v2 = v8 - 1
		break
	end
end

return UIEmitterModule