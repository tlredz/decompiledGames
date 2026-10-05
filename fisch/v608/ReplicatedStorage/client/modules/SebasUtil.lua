local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local vFXDebris = workspace:WaitForChild("VFXDebris")
local SebasUtil = {}
local random = Random.new()

function SebasUtil.EmitAll(_, folder)
	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")
		local emitDelay = emitter:GetAttribute("EmitDelay") or 0
		local emitDuration = emitter:GetAttribute("EmitDuration")
		-- equivalent calls inferred from this helper; original call sites unknown
		local v2 = emitter

		local function eparticle()
			if emitDuration and emitDuration ~= 0 then
				v2.Enabled = true
				task.delay(emitDuration, function()
					v2.Enabled = false
				end)
			end
		end

		if not emitCount then
			continue
		end

		if emitDelay == 0 then
			emitter:Emit(emitCount)

			if emitDuration and emitDuration ~= 0 then
				emitter.Enabled = true
				local v3 = emitter
				task.delay(emitDuration, function()
					v3.Enabled = false
				end)
			end
		else
			local v3 = emitter
			local v4 = emitCount
			local v5 = emitDuration
			task.delay(emitDelay, function()
				v3:Emit(v4)
				eparticle() -- equivalent call inferred; original call site unknown
			end)
		end
	end
end

function SebasUtil.ToggleAllBeams(_, folder, enabled: boolean)
	for _, beam in pairs(folder:GetDescendants()) do
		if beam:IsA("Beam") then
			beam.Enabled = enabled
		end
	end
end

function SebasUtil.ToggleAllTrails(_, folder, enabled: boolean)
	for _, trail in pairs(folder:GetDescendants()) do
		if trail:IsA("Trail") then
			trail.Enabled = enabled
		end
	end
end

function SebasUtil:ToggleAllParticles(folder, enabled: boolean)
	for _, emitter in pairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end

function SebasUtil.EnableAllParticles(_, p)
	SebasUtil:ToggleAllParticles(p, true)
end

function SebasUtil.DisableAllParticles(_, p)
	SebasUtil:ToggleAllParticles(p, false)
end

function SebasUtil.PlaySound(_, soundId, volume: number, parent, value: number?)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume
	sound.Parent = parent
	sound:Play()
	task.delay(value or 1, function()
		if sound ~= nil then
			local tween = TweenService:Create(sound, TweenInfo.new(0.2), {
				Volume = 0
			})
			tween:Play()
			tween.Completed:Connect(function()
				Debris:AddItem(sound, 0)
			end)
		end
	end)
	return sound
end

function SebasUtil.SetupBeam(_, p, attachment, attachment2)
	p.Attachment0 = attachment
	p.Attachment1 = attachment2
end

function SebasUtil:AppearBeam(state, value: number?)
	local tween = TweenService:Create(state, TweenInfo.new(value or 0.5), {
		Width0 = state.Width0,
		Width1 = state.Width1
	})
	tween:Play()
	state.Width0 = 0
	state.Width1 = 0
	state.Enabled = true
	return tween
end

function SebasUtil.AppearAllBeams(_, folder, p: number)
	for _, beam in ipairs(folder:GetDescendants()) do
		if beam:IsA("Beam") then
			SebasUtil:AppearBeam(beam, p)
		end
	end
end

function SebasUtil:DisableBeam(p, value: number?)
	local tween = TweenService:Create(p, TweenInfo.new(value or 0.4), {
		Width0 = 0,
		Width1 = 0
	})
	tween:Play()
	return tween
end

function SebasUtil.DisableAllBeams(_, folder, p: number)
	for _, beam in ipairs(folder:GetDescendants()) do
		if beam:IsA("Beam") then
			SebasUtil:DisableBeam(beam, p)
		end
	end
end

function SebasUtil.FloorImageCrack(_, raycastResult: RaycastResult, value: number?, value2: number?, color: Color3?, value3: string?)
	local part = Instance.new("Part")
	part.Parent = vFXDebris or workspace
	part.CanCollide = false
	part.CanTouch = false
	part.CastShadow = false
	part.CanQuery = false
	part.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
		-1.5707963267948966,
		math.rad((math.random(-180, 180))),
		0
	)
	part.Size = Vector3.new(value or 10, 0.1, value or 10)
	part.Anchored = true
	part.Transparency = 1
	local decal = Instance.new("Decal")
	decal.Parent = part
	decal.Texture = value3 or "rbxassetid://8260787883"
	decal.Face = "Top"
	decal.Color3 = color or raycastResult.Instance.Color
	task.delay(value2 or 1, function()
		local tween = TweenService:Create(decal, TweenInfo.new(0.5), {
			Transparency = 1
		})
		tween:Play()
		tween.Completed:Connect(function()
			Debris:AddItem(part, 0.1)
		end)
	end)
	return part
end

function SebasUtil.TimeScaleParticle(_, instance, p: number)
	instance.Drag *= p
	instance.Speed = NumberRange.new(instance.Speed.Min * p, instance.Speed.Max * p)
	instance.Lifetime = NumberRange.new(instance.Lifetime.Min / p, instance.Lifetime.Max / p)
	instance.Rate *= p
	instance.RotSpeed = NumberRange.new(instance.RotSpeed.Min * p, instance.RotSpeed.Max * p)
	instance.Acceleration *= p ^ 2

	if instance:GetAttribute("EmitDelay") then
		instance:SetAttribute("EmitDelay", instance:GetAttribute("EmitDelay") / p)
	end
end

function SebasUtil.ScaleParticle(_, state, p: number)
	local keypoints = state.Size.Keypoints
	local numberSequenceKeypoints = {}

	for k, keypoint in pairs(keypoints) do
		numberSequenceKeypoints[k] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	state.Size = NumberSequence.new(numberSequenceKeypoints)
	state.Drag *= p
	state.Speed = NumberRange.new(state.Speed.Min * p, state.Speed.Max * p)
	state.Lifetime = NumberRange.new(state.Lifetime.Min * p, state.Lifetime.Max * p)
	state.Rate *= p
	state.RotSpeed = NumberRange.new(state.RotSpeed.Min * p, state.RotSpeed.Max * p)
	state.Acceleration *= p
end

function SebasUtil.ScaleBeams(_, p, p2, list, p3: number)
	for _, v in ipairs(list) do
		v.TextureLength *= p3
		v.ZOffset *= p3
		v.CurveSize0 *= p3
		v.CurveSize1 *= p3
		v.Width0 *= p3
		v.Width1 *= p3
	end

	p.Position *= p3
	p2.Position *= p3
end

function SebasUtil.HeartbeatLoopFor(_, p: number, callback, callback2)
	local time2 = RunService:IsRunning() and time or os.clock
	local heartbeatConnection = nil
	local v = time2()
	local v2 = false
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		local v3 = time2() - v

		if v3 < p then
			callback(v3, dt, v3 / p)
		elseif v2 == true or callback2 == nil then
			if heartbeatConnection ~= nil then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end
		else
			v2 = true
			callback2()

			if heartbeatConnection ~= nil then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end
		end
	end)
	return heartbeatConnection
end

function SebasUtil.randPointInHorizDisc(_, p, p2)
	local number = random:NextNumber(0, 6.283185307179586)
	local number2 = random:NextNumber(p, p2)
	return (Vector3.new(math.cos(number) * number2, 0, math.sin(number) * number2))
end

function SebasUtil.InvertedSpringQuadraticParticles(_, instance, position: Vector3, value: number)
	-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
	local function quadraticCurve(p, position2, p2, vector)
		return position2 + p2 * p + vector * p ^ 2 / 2
	end

	local function spring(p, p2, p3)
		return math.exp(-p2 * p) * math.sin(p3 * p)
	end

	local v = {
		amount = value or 40,
		speed = 60,
		speedMinMultiplier = 0.5,
		speedMaxMultiplier = 1.5,
		gravity = -125,
		gravityMinMultiplier = 0.5,
		gravityMaXMultiplier = 1.5,
		lifetime = 0.8,
		lifetimeMinMultiplier = 1,
		lifetimeMaxMultiplier = 2,
		randomXZrotation = 40,
		randomYrotation = 180,
		parts = {}
	}

	for _ = 1, value do
		local clone = instance:Clone()
		clone.Parent = vFXDebris or workspace
		clone.Position = position
		clone.CFrame *= CFrame.Angles(
			random:NextNumber(-math.rad(v.randomXZrotation), math.rad(v.randomXZrotation) / 3),
			random:NextNumber(-math.rad(v.randomYrotation), (math.rad(v.randomYrotation))),
			random:NextNumber(-math.rad(v.randomXZrotation), math.rad(v.randomXZrotation) / 3)
		)
		table.insert(v.parts, {
			instance = clone,
			cframe = clone.CFrame,
			speed = v.speed * random:NextNumber(v.speedMinMultiplier, v.speedMaxMultiplier),
			gravity = v.gravity * random:NextNumber(v.gravityMinMultiplier, v.gravityMaXMultiplier),
			lifetime = v.lifetime * random:NextNumber(v.lifetimeMinMultiplier, v.lifetimeMaxMultiplier),
			springMultiplier = math.random(1, v.speedMaxMultiplier)
		})
	end

	local total = 0
	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt

		for _, part in pairs(v.parts) do
			if total <= part.lifetime then
				local position2 = part.cframe.Position
				local v2 = part.cframe.RightVector * part.speed
				local vector = Vector3.new(0, -part.gravity, 0)
				local position3 = quadraticCurve(total, position2, v2, vector)
				part.instance.Position = position3
				local v5 = total
				local v6 = math.exp(-0.1 * v5) * math.sin(20 * v5)
				part.speed += v6 * part.springMultiplier
			else
				Debris:AddItem(part.instance, 0.5)
			end
		end
	end)
	task.wait(v.lifetime * v.lifetimeMaxMultiplier + 0.1)
	heartbeatConnection:Disconnect()
	return v
end

function SebasUtil.ResizeParticles(_, p, p2: number)
	local model = Instance.new("Model")
	local parent = p.Parent
	p.Parent = model
	model:ScaleTo(p2)
	p.Parent = parent
	model:Destroy()
end

function SebasUtil:fadeLight(p, duration: number)
	TweenService:Create(p, TweenInfo.new(duration), {
		Brightness = 0
	}):Play()
end

function SebasUtil.fadeAllLights(_, folder, p: number)
	for _, light in ipairs(folder:GetDescendants()) do
		if light:IsA("Light") then
			SebasUtil:fadeLight(light, p)
		end
	end
end

function SebasUtil.FadeAllBeamsTransparency(_, folder, value: number)
	for _, beam in folder:GetDescendants() do
		if not beam:IsA("Beam") then
			continue
		end

		beam.Transparency = NumberSequence.new(0.6)
		beam.Enabled = true
		local v = value or 1
		TweenService:Create(beam, TweenInfo.new(v, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			TextureSpeed = 0.1
		}):Play()
		tick()
		local total = 0
		local heartbeatConnection = nil
		local v3 = beam
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			total += dt
			local v4 = math.min(total / v, 1)
			v3.Transparency = NumberSequence.new(v4 * 1)

			if v <= total then
				v3.Transparency = NumberSequence.new(1)
				heartbeatConnection:Disconnect()
			end
		end)
	end
end

return SebasUtil