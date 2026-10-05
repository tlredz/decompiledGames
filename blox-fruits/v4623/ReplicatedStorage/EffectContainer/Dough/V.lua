local createVector = vector.create
local RunService = game:GetService("RunService")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local dough = FX:WaitForChild("Dough")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local doughTAP = Effect.new("Dough.TAP")
local currentCamera = workspace.CurrentCamera

local function calculatePoint(p, p2, p3)
	local v = p2 - p
	local magnitude = v.Magnitude

	if p3 < magnitude then
		magnitude = p3
	end

	return p + v.Unit * magnitude
end

return function(data)
	local random = Random.new()
	local cFrame = data.CFrame
	local width = data.Width
	local lengths = data.Lengths
	local scales = data.Scales
	local widthMultiplier = data.WidthMultiplier
	local buso = data.Buso
	local color = data.Color
	local physicalColor = data.PhysicalColor
	local minDuration = data.MinDuration
	local maxDuration = data.MaxDuration
	local startLag = data.StartLag
	local timestamp = data.Timestamp
	local v = 250 + data.ZoneRadius * 3

	if v < (currentCamera.CFrame.p - cFrame.p).Magnitude then
		return
	end

	local spherePoints = Util.Misc.GenerateSpherePoints(6.283185307179586, 3.141592653589793, 9)
	local v2 = {}

	for _, spherePoint in pairs(spherePoints) do
		local v3 = cFrame * (spherePoint.Unit * math.floor((Util.Misc.round(
			random:NextInteger(lengths[1], lengths[2]),
			0
		))))
		table.insert(v2, v3)
	end

	local v3 = {}
	local v4 = false
	local p = cFrame.p
	local value = data.Mouse.Value
	local zoneRadius = data.ZoneRadius
	local v5 = value - p
	local magnitude = v5.Magnitude

	if zoneRadius < magnitude then
		magnitude = zoneRadius
	end

	local v6 = p + v5.Unit * magnitude
	local now = 0

	local function direct(data2, data3, p2)
		if random:NextInteger(1, 2) == 1 then
			table.sort(v2, function(a, b)
				return (a - data.Mouse.Value).Magnitude < (b - data.Mouse.Value).Magnitude
			end)
		else
			table.sort(v2, function(a, b)
				return (a - data.Mouse.Value).Magnitude > (b - data.Mouse.Value).Magnitude
			end)
		end

		local v7 = nil

		for k, _ in pairs(v2) do
			if v3[k] then
				continue
			end

			local v9 = false

			for k2, _ in pairs(v3) do
				if (v2[k2] - v2[k]).Magnitude < data2.Scale then
					v9 = true
				end
			end

			if v9 then
				continue
			end

			v7 = k
			break
		end

		if not v7 then
			return
		end

		local lastTime = tick()
		v3[v7] = true
		local v9 = v2[v7]
		local side = random:NextInteger(1, 2) == 1 and "Right" or "Left"
		local v11 = v6
		local cframe = CFrame.new(v9, v11)
		local repetitions = data3.Repetitions or 0
		local delay = data2.Delay or 0
		local boolValue = Instance.new("BoolValue")
		boolValue:SetAttribute("Holding", true)
		boolValue.Parent = _WorldOrigin

		if data.Delay and data.Delay > 0 then
			task.wait(data.Delay)
		end

		doughTAP:replicate({
			Stage = 1,
			FastMode = true,
			LimitSound = true,
			Mouse = data.Mouse,
			Side = side,
			Scale = { 0, data2.Scale },
			CFrame = cframe,
			FadeIn = data2.FadeIn,
			Lifetime = boolValue,
			FadeOut = data2.FadeOut
		})
		task.wait(data2.FadeIn + delay)

		if p2 then
			local v12 = startLag - (tick() - lastTime)

			if v12 > 0 then
				task.wait(v12)
			end
		end

		boolValue:SetAttribute("Holding", false)
		local v12 = v6
		local cframe2 = CFrame.new(v9, v12)
		local magnitude2 = (v9 - v12).Magnitude
		local magnitude3 = math.floor((v9 - cFrame.p).Magnitude)
		local rayCastWhitelist, position, normal = Util.RayCastWhitelist(
			cframe2.p,
			cframe2.LookVector * magnitude2 * 1.1,
			{ workspace:FindFirstChild("Map") }
		)
		local magnitude4 = (v9 - position).Magnitude
		local cFrame2 = cframe2 * CFrame.new(0, 0, magnitude3 - magnitude4)
		boolValue:GetAttribute("ArmActive", true)
		boolValue:SetAttribute("Position", cFrame2.p)
		boolValue:SetAttribute("Goal", position)
		local v16 = v4 and 0 or repetitions
		doughTAP:replicate({
			Stage = 2,
			FastMode = true,
			LimitSound = true,
			Side = side,
			Buso = buso and (color or buso),
			BusoPart = physicalColor,
			CFrame = cFrame2,
			Scale = Vector2.new(data3.Scale or data3.Width, magnitude3),
			ExtendDuration = data3.ExtendDuration,
			RetractDuration = data3.RetractDuration,
			Repeat = v16,
			RayCastResult = rayCastWhitelist and {
				Hit = rayCastWhitelist,
				Position = position,
				Normal = normal
			}
		})

		for _ = 1, v16 + 1 do
			task.wait(data3.ExtendDuration)

			if tick() - now > 0.2 then
				local count = 0

				for _, _ in pairs(v3) do
					count += 1
				end

				Util.Sound:Play("Dough.DoughGroundHit", position, nil, 1.187 / (1.5 + random:NextNumber(-0.5, 0.5)))
				Effect.new("Dough.Misc.Hit.Generic"):replicate({
					Scale = data2.Scale * 2 + data2.Scale / 2 * (count / 5),
					CFrame = CFrame.new(position),
					Duration = 1
				})
				now = tick()
			end

			task.wait(data3.RetractDuration)
		end

		boolValue:GetAttribute("ArmActive", false)
		boolValue:SetAttribute("Destroy")
		boolValue:Destroy()
		v3[v7] = nil
	end

	Util.Sound:Play("Dough.DoughForm", cFrame, nil, 1.3665)
	Util.Sound:Play("Dough.DoughAppear", cFrame, nil, 1.466)
	local v7 = Util.MasterClock:GetTime() - timestamp
	local fadeIn = math.max(0, startLag - v7)

	for i = 1, 10 do
		local retractDuration = random:NextNumber(0.2, 0.3) / 2
		local scale = math.floor(random:NextNumber(scales[1], scales[2]) * widthMultiplier)
		local scale2 = math.floor(width * widthMultiplier / 4)
		local v12 = {
			Scale = scale,
			FadeIn = fadeIn,
			FadeOut = random:NextNumber(0.15, 0.3),
			Delay = (i - 1) * 0.1 * fadeIn
		}
		local extendDuration

		if i == 1 then
			extendDuration = fadeIn / 4 or retractDuration
		else
			extendDuration = retractDuration
		end

		if i == 1 then
			retractDuration = fadeIn / 4 or retractDuration
		end

		local v13 = {
			Scale = scale2,
			ExtendDuration = extendDuration,
			RetractDuration = retractDuration,
			MaximumFloorMultiplier = buso and 2 or 1,
			Repetitions = random:NextInteger(0, 2)
		}
		coroutine.resume(coroutine.create(direct), v12, v13, true)
	end

	if fadeIn > 0 and startLag - v7 > 0 then
		task.wait(fadeIn)
	end

	local v9 = Util.Sound:Play("Dough.DoughAmbienceLoop", cFrame, nil, 2.1148)
	local p2 = cFrame.p
	local value2 = data.Mouse.Value
	local zoneRadius2 = data.ZoneRadius
	local v10 = value2 - p2
	local magnitude2 = v10.Magnitude

	if zoneRadius2 < magnitude2 then
		magnitude2 = zoneRadius2
	end

	v6 = p2 + v10.Unit * magnitude2
	local clone = dough.V.DustBrick:Clone()
	clone.Size = createVector(1, 0.5, 1)
	clone.CFrame = CFrame.new(v6, cFrame.p)
	clone.Dust.Enabled = false
	clone.Attachment.Rocks.Enabled = false
	clone.Parent = _WorldOrigin
	local v11 = {
		Size = clone.Dust.Size.Keypoints,
		Speed = clone.Dust.Speed,
		Acceleration = clone.Dust.Acceleration,
		Transparency = clone.Dust.Transparency.Keypoints,
		Rate = clone.Dust.Rate
	}
	local v12 = {
		Size = clone.Attachment.Rocks.Size.Keypoints,
		Speed = clone.Attachment.Rocks.Speed,
		Acceleration = clone.Attachment.Rocks.Acceleration,
		Transparency = clone.Attachment.Rocks.Transparency.Keypoints,
		Rate = clone.Attachment.Rocks.Rate
	}
	local now2 = tick()
	local v13 = false
	local v14 = 0.016666666666666666
	local v15 = 0

	while true do
		local lastTime = tick()
		local v16 = lastTime - now2
		local v17 = math.min(1, v16 / maxDuration)
		local v18 = math.min(1, v16 / minDuration)
		v13 = not data.Holding.Value or v13

		if v13 and minDuration < v16 or maxDuration < v16 then
			break
		end

		local value3 = data.Mouse.Value
		local p3 = cFrame.p
		local zoneRadius3 = data.ZoneRadius
		local v19 = value3 - p3
		local magnitude3 = v19.Magnitude

		if zoneRadius3 < magnitude3 then
			magnitude3 = zoneRadius3
		end

		local _ = p3 + v19.Unit * magnitude3
		local v20 = value3 - v6
		local v21 = v6 + (v20.Magnitude > 0 and v20.Unit or createVector(0, 0, 0)) * data.DragSpeed * random:NextNumber(
			1,
			2
		) * v14

		if (v21 - cFrame.p).Magnitude > data.ZoneRadius then
			v21 = cFrame.p + (v21 - cFrame.p).Unit * data.ZoneRadius
		end

		v6 = v21

		if not v13 then
			local v22 = lastTime - v15

			if (1 - v18 * 0.5) * 0.1 * (v14 / 0.016666666666666666) < v22 and (currentCamera.CFrame.p - cFrame.p).Magnitude < v then
				local v23 = random:NextNumber(0.2, 0.4) / (v18 * 1 + 2)
				local scale = math.floor(random:NextNumber(scales[1], scales[2]) * widthMultiplier)
				local scale2 = math.floor(width * widthMultiplier / 4)
				local number = random:NextNumber(0.3, 0.5)

				if v16 + (number + v23) < maxDuration then
					local v26 = {
						Scale = scale,
						FadeIn = number,
						FadeOut = random:NextNumber(0.15, 0.3)
					}
					local v27 = {
						Scale = scale2,
						ExtendDuration = v23,
						RetractDuration = v23,
						Repetitions = math.floor(random:NextNumber(0, 1) * (1 - v18))
					}
					coroutine.resume(coroutine.create(direct), v26, v27)
				end

				v15 = lastTime
			end
		end

		local count = 0

		for _, _ in pairs(v3) do
			count += 1
		end

		local v22 = scales[2] * widthMultiplier + scales[2] / 5 * 2 * v17
		local rayMap, v23, v24 = Util.RayMap(cFrame.p, (v6 - cFrame.p) * 1.1)

		if rayMap then
			clone.Size = Vector3.new(2 * v22, 1, 2 * v22)
			clone.CFrame = Util.Misc.AlignCFrame(CFrame.new(v23), v24)
		end

		local v25 = v22 / 5

		if rayMap then
			local keypoints = Util.Misc.ScaleKeypoints(v11.Transparency, 1 - v17 * 0.25).Keypoints
			keypoints[#keypoints] = NumberSequenceKeypoint.new(keypoints[#keypoints].Time, 1)
			local numberSequence = NumberSequence.new(keypoints)
			clone.Dust.Acceleration = v11.Acceleration * v25
			clone.Dust.Transparency = numberSequence
			clone.Dust.Speed = NumberRange.new(v11.Speed.Min * v25, v11.Speed.Max * v25)
			clone.Dust.Size = Util.Misc.ScaleKeypoints(v11.Size, v25)
			clone.Dust.Rate = v11.Rate * math.min(1, v17 / 0.5)
			clone.Dust.Color = ColorSequence.new(rayMap.Color:Lerp(Color3.new(1, 1, 1), 0.1))
			local keypoints2 = Util.Misc.ScaleKeypoints(v12.Transparency, 1 - v17 * 0.25).Keypoints
			keypoints2[#keypoints2] = NumberSequenceKeypoint.new(keypoints2[#keypoints2].Time, 1)
			local numberSequence2 = NumberSequence.new(keypoints2)
			clone.Attachment.Rocks.Acceleration = v12.Acceleration * v25
			clone.Attachment.Rocks.Transparency = numberSequence2
			clone.Attachment.Rocks.Speed = NumberRange.new(v12.Speed.Min * v25, v12.Speed.Max * v25)
			clone.Attachment.Rocks.Size = Util.Misc.ScaleKeypoints(v12.Size, v25)
			clone.Attachment.Rocks.Rate = v12.Rate * math.min(1, v17 / 0.5)
			clone.Attachment.Rocks.Color = ColorSequence.new(rayMap.Color:Lerp(Color3.new(), 0.1))
		end

		local dust = clone.Dust
		dust.Enabled = count > 0 and rayMap
		local rocks = clone.Attachment.Rocks

		if not (count > 0) then
			rayMap = false
		end

		rocks.Enabled = rayMap
		RunService.RenderStepped:Wait()
		v14 = tick() - lastTime
	end

	v2 = {}
	v3 = {}
	v4 = true
	Util.Sound:FadeOut(v9, clone.Dust.Lifetime.Max * 2)
	clone.Dust.Enabled = false
	clone.Attachment.Rocks.Enabled = false
	task.delay(clone.Dust.Lifetime.Max + 0.1, function()
		clone:Destroy()
	end)
end