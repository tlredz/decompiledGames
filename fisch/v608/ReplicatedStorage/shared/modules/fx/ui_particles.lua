local createVector = vector.create
local UiParticles = {}
local random = Random.new()
local v = {}
local v2 = {}
local v3 = {}
local lastTime = tick()
local v4 = nil

function lerpValue(p, p2, p3)
	return p + (p2 - p) * p3
end

function r_num(p, p2)
	return random:NextNumber(p2 and p or 0, p2 or p)
end

function r_int(p, p2)
	return random:NextInteger(p2 and p or 0, p2 or p)
end

function addParticle(emitter, guiBase, scale)
	if guiBase == nil or not (guiBase and guiBase:IsA("GuiBase")) then
		return
	end

	local UI = nil

	for _, v7 in pairs(v3) do
		if not v7.UI then
			continue
		end

		UI = v7.UI
		pcall(function()
			UI.Parent = guiBase
		end)
		table.remove(v3, table.find(v3, v7))
		break
	end

	if not UI then
		UI = Instance.new("ImageLabel", guiBase)
		UI.BackgroundTransparency = 1
		UI.AnchorPoint = Vector2.new(0.5, 0.5)
	end

	UI.Image = emitter.Texture
	UI.ZIndex = emitter.ZOffset
	local uDim = UDim2.new(r_num(0, 1), 0, r_num(0, 1), 0)
	UI.Position = uDim
	UI.ImageColor3 = emitter.Color.Keypoints[1].Value
	local keypoint = emitter.Size.Keypoints[1]
	local v7 = r_num(keypoint.Value - keypoint.Envelope, keypoint.Value + keypoint.Envelope) * 100 * scale
	UI.Size = UDim2.new(0, v7, 0, v7)
	local keypoint2 = emitter.Transparency.Keypoints[1]
	UI.ImageTransparency = r_num(keypoint2.Value - keypoint2.Envelope, keypoint2.Value + keypoint2.Envelope)
	UI.Rotation = r_num(emitter.Rotation.Min, emitter.Rotation.Max)
	local speed = r_num(emitter.Speed.Min, emitter.Speed.Max) * 100 * scale
	local rotSpeed = r_num(emitter.RotSpeed.Min, emitter.RotSpeed.Max)
	local spreadAngle = r_num(-emitter.SpreadAngle.X, emitter.SpreadAngle.Y)
	local randomNumberSequence = getRandomNumberSequence(emitter.Transparency)
	local randomNumberSequence2 = getRandomNumberSequence(emitter.Size)
	table.insert(v2, {
		Emitter = emitter,
		UI = UI,
		Start = tick(),
		Lifetime = r_num(emitter.Lifetime.Min, emitter.Lifetime.Max),
		Transparency = randomNumberSequence,
		Size = randomNumberSequence2,
		Speed = speed,
		RotSpeed = rotSpeed,
		SpreadAngle = spreadAngle,
		StartPos = uDim,
		SpeedDisplacement = 0,
		Accel = createVector(0, 0, 0),
		Scale = scale
	})
end

function getRandomNumberSequence(sequence)
	local v5 = {
		Keypoints = {}
	}

	for _, keypoint in pairs(sequence.Keypoints) do
		table.insert(v5.Keypoints, {
			Time = keypoint.Time,
			Value = r_num(keypoint.Value - keypoint.Envelope, keypoint.Value + keypoint.Envelope)
		})
	end

	return v5
end

function getKeypointsFromTime(sequence, p)
	for k, keypoint in pairs(sequence.Keypoints) do
		if not (p < keypoint.Time) then
			continue
		end

		local keypoint2 = sequence.Keypoints[k - 1]
		local keypoint3 = sequence.Keypoints[k]
		return keypoint2, keypoint3, (p - keypoint2.Time) / (keypoint3.Time - keypoint2.Time)
	end
end

function UiParticles.AddEmitter(_, instance, value)
	task.defer(function()
		table.insert(v, {
			Emitter = instance,
			lastEmission = tick(),
			Scale = value or 1
		})
		instance:GetPropertyChangedSignal("Enabled"):Connect(runserviceLoop)

		if not instance.Enabled then
			task.spawn(runserviceLoop)
		end
	end)
end

function UiParticles.RemoveEmitter(_, p)
	task.defer(function()
		local v5 = {}

		for _, v6 in pairs(v) do
			if v6.Emitter ~= p then
				continue
			end

			table.insert(v5, v6)
			break
		end

		for _, v6 in pairs(v5) do
			table.remove(v, table.find(v, v6))
		end
	end)
end

local preRenderConnection = nil

function runserviceLoop()
	if preRenderConnection then
		return
	end

	local flag = false

	for _, v6 in v do
		if not (v6.Emitter.Enabled and tick() - v6.lastEmission >= v6.Emitter.Rate ^ (-1)) then
			continue
		end

		flag = true
		break
	end

	if flag then
		local RunService = game:GetService("RunService")
		preRenderConnection = RunService.PreRender:Connect(function(dt)
			v4 = tick() - lastTime
			local v6 = false

			for _, v7 in v do
				if not (v7.Emitter.Enabled and tick() - v7.lastEmission >= v7.Emitter.Rate ^ (-1)) then
					continue
				end

				v7.lastEmission = tick()
				addParticle(v7.Emitter, v7.Emitter.Parent, v7.Scale)
				v6 = true
			end

			local v7 = {}
			local v8 = {}

			for _, v9 in v2 do
				local v10 = tick() - v9.Start
				local v11 = v10 / v9.Lifetime

				if v9.Lifetime <= v10 then
					table.insert(v7, v9)
				else
					v8[v9] = {
						UI = {}
					}
					local keypointsFromTime, v12, v13 = getKeypointsFromTime(v9.Transparency, v11)
					v8[v9].UI.ImageTransparency = lerpValue(keypointsFromTime.Value, v12.Value, v13)
					local keypointsFromTime2, v14, v15 = getKeypointsFromTime(v9.Size, v11)
					local v16 = lerpValue(keypointsFromTime2.Value, v14.Value, v15) * 100 * v9.Scale
					v8[v9].UI.Size = UDim2.new(0, v16, 0, v16)
					local keypointsFromTime3, v17, v18 = getKeypointsFromTime(v9.Emitter.Color, v11)
					local lerped = keypointsFromTime3.Value:Lerp(v17.Value, v18)
					v8[v9].UI.ImageColor3 = lerped
					v8[v9].UI.Rotation = v9.UI.Rotation + v9.RotSpeed * dt

					if v9.UI.BackgroundTransparency ~= 1 then
						v8[v9].UI.BackgroundTransparency = 1
					end

					local _ = v9.UI.Position
					local speed = v9.Speed
					local v19 = 1 - math.min(1, v10 ^ 4 * (v9.Emitter.Drag / 10))
					local spreadAngle = v9.SpreadAngle
					v8[v9].SpeedDisplacement = v9.SpeedDisplacement + speed * dt * v19

					if v9.Emitter.EmissionDirection == Enum.NormalId.Bottom then
						spreadAngle += 180
					elseif v9.Emitter.EmissionDirection == Enum.NormalId.Right then
						spreadAngle += 90
					elseif v9.Emitter.EmissionDirection == Enum.NormalId.Left then
						spreadAngle += 270
					end

					local uDim = UDim2.new(
						0,
						math.sin((math.rad(spreadAngle))) * v9.SpeedDisplacement,
						0,
						-math.cos((math.rad(spreadAngle))) * v9.SpeedDisplacement
					)
					v8[v9].Accel = v9.Accel + v9.Emitter.Acceleration * 100 * v9.Scale * v10 ^ 2 * dt * v19
					v8[v9].UI.Position = v9.StartPos + uDim + UDim2.new(0, v9.Accel.X, 0, -v9.Accel.Y)
				end
			end

			for k, v9 in v8 do
				for k2, v10 in v9.UI do
					if k.UI[k2] ~= v10 then
						k.UI[k2] = v10
					end
				end

				v9.UI = nil

				for k2, v10 in v9 do
					if k[k2] ~= v10 then
						k[k2] = v10
					end
				end
			end

			for _, v9 in pairs(v7) do
				v9.UI.ImageTransparency = 1
				table.insert(v3, {
					UI = v9.UI,
					RemoveAt = tick() + 3 * v9.Emitter.Rate ^ (-1)
				})
				table.remove(v2, table.find(v2, v9))
			end

			local v9 = {}

			for _, v10 in pairs(v3) do
				if not (tick() >= v10.RemoveAt) then
					continue
				end

				v10.UI:Destroy()
				table.insert(v9, v10)
			end

			for _, v10 in pairs(v9) do
				table.remove(v3, table.find(v3, v10))
			end

			if not v6 and #v2 <= 0 then
				preRenderConnection:Disconnect()
				preRenderConnection = nil
			end
		end)
	end
end

task.spawn(runserviceLoop)
return UiParticles