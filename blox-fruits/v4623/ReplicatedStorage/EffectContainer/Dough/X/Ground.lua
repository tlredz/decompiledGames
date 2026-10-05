local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Assets")
local FX = require(game.ReplicatedStorage.FX)
local dough = FX:WaitForChild("Dough")
local currentCamera = workspace.CurrentCamera
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Pool = require(ReplicatedStorage:WaitForChild("Pool"))
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage.Util)
local doughMiscFloor = Effect.new("Dough.Misc.Floor")
local doughExplosionsDripScatter = Effect.new("Dough.Explosions.DripScatter")
local doughShockwaves1 = Effect.new("Dough.Shockwaves.1")
local doughShockwaves2 = Effect.new("Dough.Shockwaves.2")
local doughMiscDebrisRadial = Effect.new("Dough.Misc.Debris.Radial")
local doughExplosionsCrackedFloor = Effect.new("Dough.Explosions.CrackedFloor")
local tweenModel = Util.TweenModel
local tween = Util.Tween
local _ = Util.Misc
local _ = Util.DistributedLoop
local rock2 = Util.Rock2
local Util2 = require(game.ReplicatedStorage.Util)
local FX2 = require(game.ReplicatedStorage.FX)
local misc = Util2.Misc

local function darkenColor(p, p2)
	return (p2 or Color3.new(0.1, 0.1, 0.1)):Lerp(p or Color3.new(1, 1, 1), 0.5):Lerp(Color3.new(), 0.575)
end

local function setupModel(folder)
	local v = {
		Object = folder,
		Particles = {},
		Attachments = {},
		Parts = {}
	}

	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			v.Parts[descendant] = {
				Size = descendant.Size,
				Offset = folder.PrimaryPart.CFrame:ToObjectSpace(descendant.CFrame)
			}
		elseif descendant:IsA("Attachment") then
			v.Attachments[descendant] = {
				Position = descendant.Position
			}
		elseif descendant:IsA("ParticleEmitter") then
			v.Particles[descendant] = {
				Size = descendant.Size.Keypoints,
				Speed = descendant.Speed,
				Acceleration = descendant.Acceleration,
				ZOffset = descendant.ZOffset
			}
		end
	end

	return v
end

local function scaleBlob(data, scale, p, p2)
	if not data then
		return
	end

	local Y = scale or 1
	local v = p or createVector(1, 1, 1)
	local v2 = p2 or createVector(1, 1, 1)
	local X

	if typeof(Y) == "Vector2" then
		X = Y.X
		Y = Y.Y
	else
		X = Y
	end

	local v3 = X * ((v.X + v.Z) / 2)
	local v4 = Y * v.Y
	local _ = (v3 + v4) / 2
	local vector2 = Vector3.new(v3, v4, v3)

	for k, part in pairs(data.Parts) do
		k.Size = part.Size * vector2 * v

		if k.Name == "Outline" then
			k.Size *= v2 * (k:GetAttribute("Scale") or 1)
		end

		k.CFrame = data.Object.PrimaryPart.CFrame * misc.scaleCF(part.Offset, nil, {
			X = v3,
			Y = v4,
			Z = v3
		})
	end

	for k, attachment in pairs(data.Attachments) do
		k.Position = attachment.Position * vector2 * v
	end
end

local v = Pool.new(string.format("Dough/%s/%s", script.Parent.Name, script.Name))
v:setAction(function(object, p)
	local now = tick()

	for _, v2 in pairs(object.Pool) do
		local v3 = math.min(1, (now - v2.Start) / v2.Duration)
		local scale = v2.Scale
		local cFrame = v2.CFrame
		local rotation = v2.Rotation
		local pulsateInfluence = v2.PulsateInfluence
		local animationSpeed = v2.AnimationSpeed
		local particles = v2.Particles
		local _ = v2.MotionParticles
		local model = v2.Model
		local _ = v2.Motion

		if model and model:IsDescendantOf(workspace) then
			v2.AngleX = v2.AngleX % 6.283185307179586 + animationSpeed * 3.141592653589793 * p
			v2.AngleY = v2.AngleY % 6.283185307179586 + animationSpeed * 3.141592653589793 * p
			local v4 = math.sin(v2.AngleX)
			local v5 = math.sin(v2.AngleY)
			local v6 = pulsateInfluence * v4
			local v7 = pulsateInfluence * v5

			if typeof(v2.Buso) == "Color3" then
				model.Outline.Color = v2.Buso
				model.Haki.Color = darkenColor(v2.Buso)
			elseif typeof(v2.Buso) == "Instance" then
				model.Outline.Color = v2.Buso.Color
				model.Haki.Color = darkenColor(v2.Buso.Color)
			else
				model.Outline.Color = Color3.new()
			end

			if v2.Method == "FadeIn" then
				local expo = tween.ease.inout.expo(v3, 0, 1, 1)
				local expo2 = tween.ease.inout.expo(v3, 1, -1, 1)
				local v8 = scale * expo
				scaleBlob(v2.ModelData, scale, (Vector3.new(1 + v6, expo + v7, 1 + v6)))
				model:SetPrimaryPartCFrame(cFrame * rotation * CFrame.new(
					0,
					v2.ModelData.Object.PrimaryPart.Size.Y / 2 - scale.Y / 2 * 0.25 * expo2,
					0
				))

				for _, particle in pairs(particles) do
					local enable = particle.Particle:GetAttribute("Enable")
					local emit = particle.Particle:GetAttribute("Emit")

					if not enable or emit then
						continue
					end

					local X = v8.Magnitude / 2

					if particle.Particle.Name == "ThickLines" or particle.Particle.Name == "Shockwave" or particle.Particle.Name == "" then
						X = v8.X
					end

					misc.ScaleParticle(particle.Particle, math.max(0.1, X), particle.Data)
				end
			elseif v2.Method == "Lifetime" then
				scaleBlob(v2.ModelData, scale, (Vector3.new(1 + v6, 1 + v7, 1 + v6)))
				model:SetPrimaryPartCFrame(cFrame * rotation * CFrame.new(
					0,
					v2.ModelData.Object.PrimaryPart.Size.Y / 2,
					0
				))
			elseif v2.Method == "FadeOut" then
				local v8 = 1 + v7
				local v9 = 1 + v6
				local circ = tween.ease.inout.circ(v3, v8, -v8, 1)
				local circ2 = tween.ease.inout.circ(v3, 0, 1, 1)
				local quint = tween.ease["in"].quint(v3, v9, -v9, 1)
				local _ = scale * circ
				scaleBlob(v2.ModelData, scale, (Vector3.new(quint, circ, quint)))
				model:SetPrimaryPartCFrame(cFrame * rotation * CFrame.new(
					0,
					v2.ModelData.Object.PrimaryPart.Size.Y / 2 - scale.Y / 2 * 0.25 * circ2,
					0
				))

				if v3 == 1 then
					object:remove(v2)
				end
			end
		else
			object:remove(v2)
		end
	end
end)
local now = 0
return function(data)
	local cFrame = data.CFrame
	local scale = data.Scale or Vector2.new(5, 5)
	local fadeIn = data.FadeIn or 0.5
	local fadeOut = data.FadeOut or 0.75
	local lifetime = data.Lifetime or 1
	local floorLifetime = data.FloorLifetime or 0
	local eruptDelay = data.EruptDelay
	local v2 = eruptDelay and eruptDelay / 2

	if 500 + scale.Magnitude * 4 < (currentCamera.CFrame.p - cFrame.p).Magnitude then
		return
	end

	local animationSpeed = data.AnimationSpeed or 1.5
	local pulsateInfluence = data.PulsateInfluence or 0.01
	local random = Random.new()
	local cframe = CFrame.Angles(0, 0, 0)
	local number = random:NextNumber(0, 3.141592653589793)
	local angleY = number + 1.5707963267948966
	local clone = dough.Models.Tentacle:Clone()
	local modelData = setupModel(clone)
	scaleBlob(modelData, scale, createVector(1, 0, 1))
	clone:SetPrimaryPartCFrame(cFrame * cframe)
	local v5 = 0
	local particles = {}

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		v5 = math.max(v5, emitter.Lifetime.Max)
		emitter.Enabled = false
		table.insert(particles, {
			Particle = emitter,
			Data = {
				Speed = emitter.Speed,
				Size = emitter.Size.Keypoints,
				Acceleration = emitter.Acceleration
			}
		})
	end

	if tick() - now > 0.1 then
		Util2.Sound:Play("Dough.DoughPastryRiverSpawn", cFrame, nil, 2.869 / (fadeIn * 2 + lifetime))
		now = tick()
	end

	doughMiscFloor:replicate({
		CFrame = cFrame,
		Scale = scale.X * 2,
		FadeIn = fadeIn * 2 / 3,
		FadeOut = fadeOut,
		Lifetime = lifetime + floorLifetime + fadeOut * 1.5 + (v2 or 0),
		Material = clone.Tentacle.Material,
		Color = clone.Tentacle.Color
	})

	if v2 then
		task.wait(v2)
	end

	local clone2 = FX2:WaitForChild("Dough").Models.MotionLines:Clone()
	clone2.Size = Vector3.new(scale.X * 2, scale.Y * modelData.Parts[clone.PrimaryPart].Size.Y * 1, scale.X * 2)
	clone2.CFrame = cFrame * CFrame.new(0, clone2.Size.Y / 2 - clone2.Size.Y / 4, 0)
	local emitters = {}

	for _, emitter in pairs(clone2:GetChildren()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		v5 = math.max(v5, emitter.Lifetime.Max)
		emitter.Rate *= 2
		emitter.Enabled = false
		table.insert(emitters, emitter)
	end

	clone2.Parent = _WorldOrigin
	clone.Parent = _WorldOrigin
	task.delay(fadeIn * 0.75 / 3, function()
		local color = data.Buso and typeof(data.Buso) == "Instance" and data.Buso.Color

		if not color then
			if typeof(data.Buso) == "Color3" then
				color = data.Buso
			else
				color = false
			end
		end

		local v7 = fadeIn * 0.75

		if color then
			for _, child in pairs(dough.Particles.Buso:GetChildren()) do
				local clone3 = child:Clone()
				Util2.Misc.ScaleParticle(clone3, scale.X / 4)
				clone3.EmissionDirection = Enum.NormalId.Top
				clone3.Color = ColorSequence.new(color)
				clone3.Lifetime = NumberRange.new(v7 * 2 * clone3.Lifetime.Min, v7 * 2 * clone3.Lifetime.Max)
				clone3.Parent = clone.PrimaryPart
				clone3:Emit((clone3:GetAttribute("Emit") or 10) + scale.X / 4)
				clone3.Enabled = true
				task.delay(v7, function()
					clone3.Enabled = false
					Util2.Debris:AddItem(clone3, clone3.Lifetime.Max + 0.1)
				end)
			end
		end

		local X = nil
		local Y = nil
		local typeName = typeof(scale)

		if typeName == "number" then
			X = scale
			Y = scale
		elseif typeName == "Vector2" then
			X = scale.X
			Y = scale.Y
		end

		local v8 = random:NextNumber(-1, 1) * 3.141592653589793

		for i = 1, 2 do
			local v9 = i == 1 and 2 or 1.5
			local _ = i % 2 == 0
			tweenModel(dough.Models.WindRings, {
				CFrame = cFrame * CFrame.new(0, -Y * 0.5, 0) * CFrame.Angles(
					0,
					(i == 1 and 0 or 3.141592653589793) + v8,
					0
				),
				Scale = 1,
				Size = Vector3.new(X, 0, X) / 4
			}, {
				Tween = TweenInfo.new(fadeIn * v9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				Size = Vector3.new(X / 4, Y * 0.4166666666666667, X / 4),
				Transparency = 1,
				CFrame = CFrame.new(0, Y * 1, 0) * CFrame.Angles(0, 3.14, 0)
			})
		end

		task.spawn(function()
			local v9 = fadeIn
			local random2 = Random.new()
			local v10 = math.floor(scale.X / 4)
			local v11 = math.max(4, v10 / 4)

			for i = 1, v10 do
				local v12 = 6.283185307179586 * (i / v10)
				local v13 = rock2.new({
					Type = "Flying",
					FadeOut = { v9 / 2, v9 },
					FadeIn = { v9 / 2, v9 },
					Lifetime = { v9 + 0.5, v9 * 4 + 0.5 },
					Size = Vector3.new(
						random2:NextNumber(0.5, 1.5),
						random2:NextNumber(0.5, 1.5),
						random2:NextNumber(0.5, 1.5)
					),
					Scale = { v11 / 5, v11 / 1.5 }
				})
				local unit = Vector3.new(
					math.sin(random2:NextNumber(-1, 1) * 2 * 3.141592653589793) * random2:NextNumber(0.125, 1),
					random2:NextNumber(0, 1) * random2:NextNumber(0.25, 1.25),
					math.cos(random2:NextNumber(-1, 1) * 2 * 3.141592653589793) * random2:NextNumber(0.125, 1)
				).Unit
				v13:Spawn(cFrame * CFrame.Angles(0, v12, 0) * CFrame.new(0, 0, -scale.X / 2))
				v13:Eject({
					Velocity = Util2.Misc.Physics.Velocity(
						Vector3.new(),
						unit * random2:NextNumber(scale.Y * 1, scale.Y * 2),
						Vector3.new(0, -workspace.Gravity * random2:NextNumber(0.25, 1), 0),
						0.25 + random2:NextNumber(0, 1.25)
					),
					AngularVelocity = Vector3.new(
						random2:NextNumber(-1, 1),
						random2:NextNumber(-1, 1),
						random2:NextNumber(-1, 1)
					) * 2 * 3.141592653589793 * (1 / v13.Scale)
				})
			end
		end)
		task.spawn(function()
			local v9 = fadeIn * 0.25 / 3
			local lastTime = tick()

			while true do
				local v10 = math.min(1, (tick() - lastTime) / v9)
				local magnitude = (cFrame.p - currentCamera.CFrame.p).Magnitude
				local v11 = 50 + scale.Magnitude * 1.5

				if magnitude < v11 then
					local v12 = math.min(1, magnitude / v11)
					Effect.new("ShakeCam"):replicate({
						Magnitude = 8,
						Roughness = 8,
						FadeIn = fadeIn / 2,
						FadeOut = fadeIn * 2,
						PosInfluence = createVector(0.25, 0.25, 0.25),
						RotInfluence = createVector(0, 0, 2),
						Power = 1 - magnitude / v11 * (v12 / 2)
					})
				end

				if v10 == 1 then
					break
				else
					task.wait(0.016666666666666666)
				end
			end
		end)

		for _, v9 in pairs(particles) do
			local emit = v9.Particle:GetAttribute("Emit")

			if not emit then
				continue
			end

			local X2 = scale.Magnitude / 2

			if v9.Particle.Name == "Shockwave" or v9.Particle.Name == "Shards" or v9.Particle.Name == "Lines" then
				X2 = scale.X

				if v9.Particle.Name == "Lines" then
					X2 = scale.X / 2
				end
			end

			misc.ScaleParticle(v9.Particle, X2, v9.Data)
			v9.Particle:Emit(emit)
		end

		for _, v9 in pairs(emitters) do
			local v10 = 2 * (60 * (scale.Y * modelData.Parts[clone.PrimaryPart].Size.Y / 2) / 21.2)
			v9.Lifetime = NumberRange.new(v9.Lifetime.Min / 1.5, v9.Lifetime.Max / 1.5)
			v9.Size = NumberSequence.new(0.2 * (scale.X * modelData.Parts[clone.PrimaryPart].Size.X))
			v9.Speed = NumberRange.new(v10 * 0.75, v10 * 1.5)
			v9.Acceleration = createVector(0, -50, 0) * (scale.Y * modelData.Parts[clone.PrimaryPart].Size.Y / 2) / 21.2
			v9.Enabled = true
		end

		task.delay(fadeIn * 1.5 / 3, function()
			for _, v9 in pairs(emitters) do
				v9.Enabled = false
			end
		end)
		doughExplosionsCrackedFloor:replicate({
			CFrame = cFrame,
			Scale = data.Scale.X * 5,
			Transparency = 0.5,
			FadeIn = math.min(0.1, fadeIn / 4 - 0.1),
			FadeOut = fadeOut + 0.5,
			Lifetime = lifetime + floorLifetime + fadeOut * 1.5
		})
		doughMiscDebrisRadial:replicate({
			CFrame = cFrame,
			Scale = data.Scale.X * 3,
			Mode = "Y",
			Duration = 4 + 4 * fadeIn
		})
		doughExplosionsDripScatter:replicate({
			CFrame = cFrame - cFrame.UpVector * scale.Y / 4,
			Scale = scale.X / 3,
			Spread = Vector2.new(45, 45),
			Drag = 5,
			Distance = 5 + 2.5 * scale.X,
			Gravity = 1.25,
			Influence = { 1, 2 },
			Time = fadeIn * 2,
			Rate = 6,
			DropLifetime = 2
		})

		for i = 1, 3 do
			doughShockwaves2:replicate({
				CFrame = cFrame,
				VectorOffset = cFrame.UpVector * i * scale.Y / 9,
				Duration = fadeIn / 3,
				Scale = 1.5 * scale.X * ((6 - i) / 3 * 0.75 + 1),
				Speed = i % 2 == 0 and 1 or -1,
				Color = Color3.fromRGB(555, 555, 555)
			})
			task.wait(0.1)
		end
	end)

	for _, v7 in pairs(particles) do
		local enable = v7.Particle:GetAttribute("Enable")

		if not enable then
			continue
		end

		v7.Particle.Enabled = true

		if typeof(enable) ~= "number" then
			continue
		end

		local v8 = v7
		task.delay(enable, function()
			v8.Particle.Enabled = false
		end)
	end

	local v7 = v:add({
		Start = tick(),
		Duration = fadeIn,
		Method = "FadeIn",
		AngleX = number,
		AngleY = angleY,
		Scale = scale,
		PulsateInfluence = pulsateInfluence,
		AnimationSpeed = animationSpeed,
		CFrame = cFrame,
		Rotation = cframe,
		Particles = particles,
		MotionParticles = emitters,
		Motion = clone2,
		Model = clone,
		ModelData = modelData,
		Buso = data.Buso
	})
	wait(fadeIn)
	v7.Start = tick()
	v7.Duration = lifetime
	v7.Method = "Lifetime"
	wait(lifetime)

	if tick() - now > 0.05 then
		Util2.Sound:Play("Dough.DoughPastryRiverDespawn", cFrame, nil, 1.317 / (fadeOut * 2.5))
		now = tick()
	end

	for _, v8 in pairs(particles) do
		v8.Particle.Enabled = false
	end

	clone2.Size = Vector3.new(scale.X * 2, scale.Y * modelData.Parts[clone.PrimaryPart].Size.Y * 1, scale.X * 2)
	clone2.CFrame = cFrame * CFrame.new(0, clone2.Size.Y / 2 + clone2.Size.Y / 4, 0)

	for _, v8 in pairs(emitters) do
		local v9 = 2 * (60 * (clone.PrimaryPart.Size.Y / 2) / 21.2)
		v8.Lifetime = NumberRange.new(v8.Lifetime.Min / 1.5, v8.Lifetime.Max / 1.5)
		v8.Size = NumberSequence.new(0.2 * scale.X)
		v8.Speed = NumberRange.new(v9 * 0.75, v9 * 1.5)
		v8.Acceleration = createVector(0, 50, 0) * (clone.PrimaryPart.Size.Y / 2) / 21.2
		v8.ShapeInOut = Enum.ParticleEmitterShapeInOut.Inward
		v8.Enabled = true
	end

	task.delay(fadeOut * 1 / 4, function()
		local X = nil
		local Y = nil
		local typeName = typeof(scale)

		if typeName == "number" then
			X = scale
			Y = scale
		elseif typeName == "Vector2" then
			X = scale.X
			Y = scale.Y
		end

		local v8 = random:NextNumber(-1, 1) * 3.141592653589793

		for i = 1, 2 do
			local v9 = i == 1 and 1.25 or 0.75
			local _ = i % 2 == 0
			tweenModel(dough.Models.WindRings, {
				CFrame = cFrame * CFrame.new(0, Y, 0) * CFrame.Angles(0, (i == 1 and 0 or 3.141592653589793) + v8, 0),
				Transparency = 0.25,
				Scale = 1,
				Size = Vector3.new(X / 4, Y * 0.4166666666666667, X / 4)
			}, {
				Tween = TweenInfo.new(fadeOut * v9, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
				CFrame = CFrame.new(0, -Y * 1, 0) * CFrame.Angles(0, -3.14, 0),
				Scale = 1,
				Size = Vector3.new(X, 0, X) / 4,
				Transparency = 1
			})
		end

		local magnitude = (cFrame.p - currentCamera.CFrame.p).Magnitude
		local v9 = 50 + scale.Magnitude * 1.5

		if magnitude < v9 then
			math.min(1, magnitude / v9)
			Effect.new("ShakeCam"):replicate({
				Magnitude = 8,
				Roughness = 8,
				FadeIn = fadeOut / 2,
				FadeOut = fadeOut * 2,
				PosInfluence = createVector(0.15, 0.15, 0.15),
				RotInfluence = createVector(0, 0, 1),
				Power = 1 - magnitude / v9 * 0.5
			})
		end

		task.delay(fadeOut * 1 / 5, function()
			for _, v10 in pairs(emitters) do
				v10.Enabled = false
			end
		end)

		for _, v10 in pairs(particles) do
			local emit = v10.Particle:GetAttribute("Emit")
			local enable = v10.Particle:GetAttribute("Enable")

			if not (v10.Particle.Name == "Shards" or v10.Particle.Name == "Blobs" or v10.Particle.Name == "Lines") then
				continue
			end

			local v11 = 0.75
			local X2 = scale.Magnitude / 2

			if v10.Particle.Name == "Shards" or v10.Particle.Name == "Shockwave" then
				X2 = scale.X

				if v10.Particle.Name == "Shockwave" then
					v11 = 1
				elseif v10.Particle.Name == "Lines" then
					X2 = scale.X / 2
				end
			end

			misc.ScaleParticle(v10.Particle, X2 * v11, v10.Data)

			if v10.Particle.Name == "Shards" then
				local lifetime2 = v10.Particle.Lifetime
				v10.Particle.Lifetime = NumberRange.new(lifetime2.Min / 3, lifetime2.Max / 1.5)
				v10.Particle.Drag *= 2
			end

			if typeof(enable) == "number" then
				v10.Particle.Enabled = true
				local v12 = v10
				task.delay(enable, function()
					v12.Particle.Enabled = false
				end)
			end

			v10.Particle:Emit(emit)
		end

		doughMiscDebrisRadial:replicate({
			CFrame = cFrame,
			Scale = data.Scale.X * 2.5,
			Mode = "Y",
			Duration = 4 + 4 * fadeOut
		})
		doughExplosionsDripScatter:replicate({
			CFrame = cFrame - cFrame.UpVector * scale.Y / 4,
			Scale = scale.X / 5,
			Spread = Vector2.new(45, 45) * 0.5,
			Drag = 5,
			Distance = 5 + 2.5 * scale.X,
			Gravity = 1.25,
			Influence = { 1, 2 },
			Time = fadeOut * 2,
			Rate = 6,
			DropLifetime = 2
		})

		for i = 1, 1 do
			doughShockwaves1:replicate({
				CFrame = cFrame,
				VectorOffset = cFrame.UpVector * i * scale.Y / 6,
				Duration = fadeOut * 0.75,
				Transparency = 0.8,
				Scale = 2 * scale.X * (i / 3 * 0.75 + 1),
				Speed = i % 2 == 0 and 1 or -1,
				Color = Color3.fromRGB(555, 555, 555)
			})
			task.wait(0.1)
		end
	end)
	v7.Start = tick()
	v7.Duration = fadeOut
	v7.Method = "FadeOut"
	wait(fadeOut + v5)
	clone:Destroy()
	clone2:Destroy()
end