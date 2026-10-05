local createVector = vector.create
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

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

return {
	Create = function(self: CFrame, options)
		local v = options or {}

		if typeof(self) ~= "CFrame" then
			warn("BezierChargeEffect.Create: 'targetCFrame' must be a CFrame value, but received " .. typeof(self))
			return
		end

		local count = v.Count or 30
		local spawnRadius = v.SpawnRadius or 20
		local minDuration = v.MinDuration or 0.8
		local maxDuration = v.MaxDuration or 1.5
		local lifetime = v.Lifetime or 2
		local particleTemplate = v.ParticleTemplate
		local controlPointHeight = v.ControlPointHeight or 15
		local randomControlOffset = math.abs(v.RandomControlOffset or 8)
		local parent = v.Parent or workspace:FindFirstChild("Effects") or workspace
		local easingStyle = v.EasingStyle or Enum.EasingStyle.Quart
		local easingDirection = v.EasingDirection or Enum.EasingDirection.Out
		local spawnDelay = v.SpawnDelay or 0.05
		local colorSequence = v.ColorSequence
		local transparencySequence = v.TransparencySequence
		local widthSequence = v.WidthSequence
		local swirlStrength = v.SwirlStrength or 0
		local v2 = math.max(v.Speed or 1, 0.001)
		local worldAcceleration = v.WorldAcceleration or createVector(0, 0, 0)
		local initialVelocity = v.InitialVelocity or createVector(0, 0, 0)
		local v3 = math.max(v.Drag or 0, 0)
		local noise = v.Noise or 0
		local noiseFrequency = v.NoiseFrequency or 1
		local _ = v.RandomRotation == nil
		local randomRotation = v.RandomRotation
		local rotationSpeed = v.RotationSpeed or NumberRange.new(-45, 45)
		local v4 = v.AlignToTangent == nil or v.AlignToTangent
		local loop = v.Loop or false
		local v5 = v.EmitOnCreate == nil or v.EmitOnCreate
		local spiralBeforeTravel = v.SpiralBeforeTravel or false
		local spiralTime = v.SpiralTime or 1
		local spiralRadius = v.SpiralRadius or 15
		local spiralSpeed = v.SpiralSpeed or 6.283185307179586
		local spiralHeight = v.SpiralHeight or 0
		local v6 = v.SpiralInward == nil or v.SpiralInward
		local trailTexture = v.TrailTexture
		local trailTextureLength = v.TrailTextureLength
		local trailTextureSpeed = v.TrailTextureSpeed
		local trailFaceCamera = v.TrailFaceCamera
		local trailLightEmission = v.TrailLightEmission
		local trailLightInfluence = v.TrailLightInfluence

		if particleTemplate and particleTemplate:IsA("BasePart") then
			for i = 1, count do
				local v7 = i
				task.spawn(function()
					local DISTANCE_EPSILON = 0.0001

					if spawnDelay > 0 then
						task.wait(v7 * spawnDelay)
					end

					local clone = particleTemplate:Clone()
					clone.Anchored = false
					clone.CanCollide = false
					clone.CanTouch = false
					clone.Massless = true
					clone.Parent = parent
					local v8 = randomUnitVector() * math.random(0, spawnRadius)
					clone.CFrame = CFrame.new(self.Position + v8)

					if spiralBeforeTravel then
						local lastTime = os.clock()

						while os.clock() - lastTime < spiralTime do
							local v9 = os.clock() - lastTime
							local v10 = math.clamp(v9 / spiralTime, 0, 1)
							local v11 = v6 and spiralRadius * (1 - v10) or spiralRadius
							local v12 = v9 * spiralSpeed
							local v13 = math.cos(v12) * v11
							local v14 = math.sin(v12) * v11
							local v15 = spiralHeight * v10
							local v16 = self.Position + Vector3.new(v13, v15, v14)
							local vector2 = Vector3.new(-math.sin(v12), 0, (math.cos(v12)))
							local v17 = vector2.Magnitude < DISTANCE_EPSILON and createVector(0, 0, 1) or vector2

							if v4 then
								clone.CFrame = CFrame.lookAt(v16, v16 + v17)
							else
								clone.CFrame = CFrame.new(v16)
							end

							RunService.Heartbeat:Wait()
						end
					end

					local v9 = math.random(minDuration * 100, maxDuration * 100) / 100 / v2
					local cframe2 = CFrame.new(clone.Position)
					local v10 = self
					local lerped = cframe2:Lerp(v10, 0.5)
					local v11 = randomUnitVector() * (math.random() * randomControlOffset)
					local v12 = randomUnitVector() * (math.random() * randomControlOffset)
					local v13 = v10.Position - cframe2.Position
					local unit = v13.Magnitude > DISTANCE_EPSILON and v13.Unit or createVector(0, 0, -1)
					local cross = unit:Cross(createVector(0, 1, 0))

					if cross.Magnitude < DISTANCE_EPSILON then
						cross = unit:Cross(createVector(0, 0, -1))
					end

					local unit2 = cross.Unit
					local v14 = unit2 * ((math.random() * 2 - 1) * swirlStrength)
					local v15 = unit2 * ((math.random() * 2 - 1) * swirlStrength)
					local v16 = cframe2.Position:Lerp(lerped.Position, 0.3) + Vector3.new(0, controlPointHeight, 0) + v11 + v14
					local v17 = lerped.Position:Lerp(v10.Position, 0.7) + Vector3.new(0, controlPointHeight, 0) + v12 + v15
					local cframe3 = CFrame.new(v16)
					local cframe4 = CFrame.new(v17)
					local numberValue = Instance.new("NumberValue")
					numberValue.Value = 0
					local tween = TweenService:Create(
						numberValue,
						TweenInfo.new(v9, easingStyle, easingDirection, 0, false, 0),
						{
							Value = 1
						}
					)
					local lastTime = os.clock()
					local now = lastTime
					local v18 = initialVelocity
					local total = 0
					local v19 = math.random(rotationSpeed.Min, rotationSpeed.Max)
					local trail = clone:FindFirstChildOfClass("Trail")

					if trail then
						if colorSequence then
							trail.Color = colorSequence
						end

						if transparencySequence then
							trail.Transparency = transparencySequence
						end

						if widthSequence then
							trail.WidthScale = widthSequence
						end

						if trailTexture then
							trail.Texture = trailTexture
						end

						if trailTextureLength then
							trail.TextureLength = trailTextureLength
						end

						if trailTextureSpeed then
							trail.TextureSpeed = trailTextureSpeed
						end

						if trailFaceCamera ~= nil then
							trail.FaceCamera = trailFaceCamera
						end

						if trailLightEmission then
							trail.LightEmission = trailLightEmission
						end

						if trailLightInfluence then
							trail.LightInfluence = trailLightInfluence
						end
					end

					local heartbeatConnection = nil
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						if clone and clone.Parent then
							local v20 = v18
							local v21 = v3

							if not (v21 <= 0) then
								v20 *= math.exp(-v21 * dt)
							end

							v18 = v20 + worldAcceleration * dt
							local bezierFrameAndBasis, v22, v23, v24 = getBezierFrameAndBasis(
								numberValue.Value,
								cframe2,
								cframe3,
								cframe4,
								v10
							)
							local v25 = os.clock() - lastTime
							local v26 = math.noise(v25 * noiseFrequency, v7, 0)
							local v27 = math.noise(v25 * noiseFrequency, 0, v7)
							local v28 = (v22 * v26 + v23 * v27) * noise
							local v29 = v18 * (os.clock() - now)
							now = os.clock()

							if randomRotation then
								total += math.rad(v19) * dt
								bezierFrameAndBasis *= CFrame.fromAxisAngle(v24, total)
							end

							local v30 = bezierFrameAndBasis.Position + v28 + v29

							if v4 then
								clone.CFrame = CFrame.lookAt(v30, v30 + v24)
							else
								clone.CFrame = CFrame.new(v30)
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

					if v5 then
						playOnce() -- equivalent call inferred; original call site unknown
					end

					tween.Completed:Connect(function()
						if loop and os.clock() - lastTime < lifetime then
							playOnce() -- equivalent call inferred; original call site unknown
						else
							cleanup() -- equivalent call inferred; original call site unknown
						end
					end)
					Debris:AddItem(clone, lifetime)
				end)
			end
		else
			warn("BezierChargeEffect.Create: ParticleTemplate is required and must be a BasePart.")
		end
	end
}