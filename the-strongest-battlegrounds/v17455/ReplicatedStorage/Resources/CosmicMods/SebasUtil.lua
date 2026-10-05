local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local thrown = workspace:WaitForChild("Thrown")
local SebasUtil = {}
local currentCamera = workspace.CurrentCamera
local random = Random.new()

function SebasUtil.CubicBezier(_, p: number, p2: number, p3: number, p4: number, p5: number)
	return (1 - p5) ^ 3 * p + p5 * 3 * (1 - p5) ^ 2 * p2 + p5 ^ 2 * 3 * (1 - p5) * p3 + p5 ^ 3 * p4
end

function SebasUtil.quadBezier(_, p, p2, p3, p4)
	return (1 - p4) ^ 2 * p + 2 * (1 - p4) * p4 * p2 + p4 ^ 2 * p3
end

function SebasUtil.QuadraticEaseOut(_, p: number)
	return (math.lerp(p * p, 1 - (1 - p) * (1 - p), p))
end

function SebasUtil.lerp(_, p, p2, p3)
	return p + (p2 - p) * p3
end

function SebasUtil.invLerp(_, p, p2, p3)
	return (p3 - p) / (p2 - p)
end

function SebasUtil.remap(_, _, p, p2, p3, p4)
	return SebasUtil:lerp(p2, p3, (math.clamp(SebasUtil:invLerp(p, p, p4), 0, 1)))
end

function SebasUtil:gaussianRandom(p, p2)
	local v, v2

	repeat
		v = 2 * math.random() - 1
		local v3 = 2 * math.random() - 1
		v2 = math.pow(v, 2) + math.pow(v3, 2)
	until v2 ~= 0 and v2 < 1

	local v3 = math.sqrt(math.log(v2) * -2 / v2)
	return p + p2 * v * v3
end

function SebasUtil.randomPointInSphere(_, p)
	local v = 6.283185307179586 * math.random()
	local v2 = math.acos(2 * math.random() - 1)
	local v3 = math.min(SebasUtil:gaussianRandom(0, p / 3), p)
	return v3 * math.sin(v2) * math.cos(v), v3 * math.sin(v2) * math.sin(v), v3 * math.cos(v2)
end

function SebasUtil.randomPointInAnnulus(_, p, p2)
	local v = 6.283185307179586 * math.random()
	local v2 = math.acos(2 * math.random() - 1)
	local v3 = p + (p2 - p) * math.sqrt((math.random()))
	return v3 * math.sin(v2) * math.cos(v), v3 * math.sin(v2) * math.sin(v), v3 * math.cos(v2)
end

function SebasUtil.randomPointInSphericalShell(_, p, p2)
	if p2 < p then
		p2, p = p, p2
	end

	local v = math.max(0, p)
	local v2 = 6.283185307179586 * math.random()
	local v3 = math.acos(2 * math.random() - 1)
	local v4 = v ^ 3
	local v5 = (v4 + (p2 ^ 3 - v4) * math.random()) ^ 0.3333333333333333
	return v5 * math.sin(v3) * math.cos(v2), v5 * math.sin(v3) * math.sin(v2), v5 * math.cos(v3)
end

function SebasUtil.flat(_, p)
	local result = {}
	local flatten

	flatten = function(list)
		for _, v in ipairs(list) do
			if typeof(v) == "table" then
				flatten(v)
			else
				table.insert(result, v)
			end
		end
	end

	flatten(p)
	return result
end

function SebasUtil:EmitAll(folder)
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

function SebasUtil.EmitOnce(_, instance, position: Vector3, value: number?)
	local clone = instance:Clone()
	Debris:AddItem(clone, value or 1)
	clone.Position = position
	clone.Parent = thrown
	SebasUtil:EmitAll(clone)
end

function SebasUtil.ToggleAllBeams(_, folder, enabled: boolean)
	for _, beam in pairs(folder:GetDescendants()) do
		if beam:IsA("Beam") then
			beam.Enabled = enabled
		end
	end
end

function SebasUtil:ToggleAllTrails(folder, enabled: boolean)
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

function SebasUtil.EnableAllTrails(_, p)
	SebasUtil:ToggleAllTrails(p, true)
end

function SebasUtil.DisableAllTrails(_, p)
	SebasUtil:ToggleAllTrails(p, false)
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
	part.Parent = thrown or workspace
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

function SebasUtil:RenderStepLoopFor(p: number, callback, p2, callback2)
	local time2 = RunService:IsRunning() and time or os.clock
	local v = time2()
	local v2 = false
	local v3 = "RenderStepLoop_" .. tostring(math.random(1000000000))
	RunService:BindToRenderStep(v3, p2, function(p3)
		local v4 = time2() - v

		if v4 < p then
			callback(v4, p3, v4 / p)
			return
		end

		if not v2 and callback2 then
			v2 = true
			callback2()
		end

		RunService:UnbindFromRenderStep(v3)
	end)
	return function()
		RunService:UnbindFromRenderStep(v3)
	end
end

function SebasUtil.randPointInHorizDisc(_, p, p2)
	local number = random:NextNumber(0, 6.283185307179586)
	local number2 = random:NextNumber(p, p2)
	return (Vector3.new(math.cos(number) * number2, 0, math.sin(number) * number2))
end

function SebasUtil.InvertedSpringQuadraticParticles(_, instance, position: Vector3, value: number)
	-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
	local function quadraticCurve(p, position2, p2, vector2)
		return position2 + p2 * p + vector2 * p ^ 2 / 2
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
		clone.Parent = thrown or workspace
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
				local vector2 = Vector3.new(0, -part.gravity, 0)
				local position3 = quadraticCurve(total, position2, v2, vector2)
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

function SebasUtil:OpenBeams(folder, duration: number, p: number)
	for _, beam in ipairs(folder:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		local v = beam
		task.spawn(function()
			TweenService:Create(v, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Width0 = v.Width0 * p,
				Width1 = v.Width1 * p
			}):Play()
			v.Width0 = 0
			v.Width1 = 0
			v.Enabled = true
		end)
	end
end

function SebasUtil:CloseBeams(folder, duration: number)
	for _, beam in ipairs(folder:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		local v = beam
		task.spawn(function()
			TweenService:Create(v, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end)
	end
end

function SebasUtil.playSlash(_, p, p2: number, value: number?, value2: number?)
	task.spawn(function()
		local cFrame = p.CFrame
		local v = math.rad(value or 125)
		SebasUtil:RenderStepLoopFor(p2, function(_, _, p3)
			p.CFrame = cFrame * CFrame.Angles(0, v * p3, 0)
		end, Enum.RenderPriority.Last.Value, function() end)
		SebasUtil:OpenBeams(p, 0.1, 1)
		task.wait(value2 or 0.1)
		SebasUtil:CloseBeams(p, 0.2)
	end)
end

function SebasUtil:GetRandomNormalCone(vector2: Vector3, p: number)
	local unit = vector2:Cross(vector2:Cross(createVector(0, 1, 0)).Magnitude > 0.01 and createVector(0, 1, 0) or createVector(
		1,
		0,
		0
	)).Unit
	local v = math.rad((random:NextNumber(0, p)))
	local vectorToWorldSpace = CFrame.fromAxisAngle(unit, v):VectorToWorldSpace(vector2)
	local v2 = math.rad((random:NextNumber(0, 360)))
	return CFrame.fromAxisAngle(vector2, v2):VectorToWorldSpace(vectorToWorldSpace)
end

function SebasUtil.GetReflectedDirection(_, vector2: Vector3, vector3: Vector3, p: number)
	return SebasUtil:GetRandomNormalCone((vector2 - 2 * vector2:Dot(vector3) * vector3).Unit, p)
end

function SebasUtil.CastToMouseCFrame(_, value: number?, p, flag: boolean?, data)
	local screenPointToRay = currentCamera:ScreenPointToRay(data.X, data.Y)
	local raycastResult = workspace:Raycast(screenPointToRay.Origin, screenPointToRay.Direction * (value or 1000), p)

	if not raycastResult then
		print("Raycast failed")
		return data.Hit
	end

	local cframe = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal)

	if flag then
		return cframe * CFrame.Angles(-1.5707963267948966, 0, 0)
	end

	return cframe
end

function SebasUtil.lockAndLookAtMouse(_, parent, p, p2: number?)
	local attachment = Instance.new("Attachment", parent)
	local vectorForce = Instance.new("VectorForce")
	vectorForce.Force = Vector3.new(0, workspace.Gravity * parent.AssemblyMass, 0)
	vectorForce.ApplyAtCenterOfMass = true
	vectorForce.Attachment0 = attachment
	vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	vectorForce.Parent = parent
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.RigidityEnabled = true
	alignOrientation.MaxTorque = 1e999
	alignOrientation.Responsiveness = 200
	alignOrientation.Attachment0 = attachment
	alignOrientation.Parent = parent
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition.MaxForce = 1e999
	alignPosition.Responsiveness = 200
	alignPosition.RigidityEnabled = true
	alignPosition.Attachment0 = attachment
	alignPosition.Position = parent.Position
	alignPosition.Parent = parent
	local lastTime = tick()
	local renderSteppedConnection = nil

	local function cancel()
		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
		end

		Debris:AddItem(attachment, 0)
		Debris:AddItem(vectorForce, 0)
		Debris:AddItem(alignOrientation, 0)
		Debris:AddItem(alignPosition, 0)
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		if not (parent and parent.Parent) then
			renderSteppedConnection:Disconnect()
			return
		end

		local unit = (p.Hit.Position - parent.Position).Unit
		alignOrientation.CFrame = CFrame.lookAt(parent.Position, parent.Position + unit)

		if p2 and p2 <= tick() - lastTime then
			cancel()
		end
	end)
	return cancel
end

function SebasUtil.ColorFrame(_, duration: number, duration2: number, color: Color3, vector2: Vector3, value: number, flag: boolean)
	local v = vector2 or currentCamera.CFrame.Position

	if (value or 99999) < (currentCamera.CFrame.Position - v).Magnitude then
		return
	end

	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.TintColor = Color3.new(1, 1, 1)
	colorCorrectionEffect.Parent = Lighting
	TweenService:Create(colorCorrectionEffect, TweenInfo.new(duration), {
		TintColor = color
	}):Play()

	if not flag then
		task.delay(duration, function()
			if colorCorrectionEffect then
				TweenService:Create(colorCorrectionEffect, TweenInfo.new(duration2), {
					TintColor = Color3.new(1, 1, 1)
				}):Play()
				task.wait(duration2 + 0.05)

				if colorCorrectionEffect then
					colorCorrectionEffect:Destroy()
				end
			end
		end)
	end

	return colorCorrectionEffect
end

function SebasUtil.ImpactFrame(_, duration: number, p: number, items, fillColor: Color3, color: Color3, vector2: Vector3, p2: number)
	if p2 < (currentCamera.CFrame.Position - vector2).Magnitude then
		return
	end

	task.defer(function()
		local v = {}

		for _, item in items do
			local highlight = Instance.new("Highlight")
			highlight.Name = "ImpactHighlight"
			highlight.FillColor = fillColor
			highlight.OutlineTransparency = 1
			highlight.Parent = item
			table.insert(v, highlight)
		end

		local v2 = Lighting:FindFirstChild("Impact")

		if not v2 then
			v2 = Instance.new("ColorCorrectionEffect")
			v2.Brightness = 0
			v2.Contrast = 0
			v2.Saturation = 0
			v2.Enabled = true
			v2.TintColor = Color3.fromRGB(255, 255, 255)
			v2.Name = "Impact"
			v2.Parent = script
		end

		local clone = v2:Clone()
		clone.Parent = game:GetService("Lighting")
		clone.TintColor = color or Color3.fromRGB(255, 255, 255)
		clone.Brightness = -1
		clone.Contrast = -100
		clone.Saturation = -1

		for _ = 1, p do
			clone.Contrast = -100
			task.wait(duration)
			clone.Contrast = 100
			task.wait(duration)
		end

		clone.Brightness = 0
		clone.Contrast = 0
		clone.Saturation = 0
		clone:Destroy()

		for _, v3 in ipairs(v) do
			if v3.Parent ~= nil then
				v3:Destroy()
			end
		end

		table.clear(v)
	end)
end

return SebasUtil