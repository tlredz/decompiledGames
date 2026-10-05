local ReplicatedStorage = game:GetService("ReplicatedStorage")
local currentCamera = workspace.CurrentCamera
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Pool = require(ReplicatedStorage:WaitForChild("Pool"))
local sound = Util.Sound
local misc = Util.Misc
local distributedLoop = Util.DistributedLoop
local rock2 = Util.Rock2
local FX = require(game.ReplicatedStorage.FX)
ReplicatedStorage:WaitForChild("Assets")
local dough = FX:WaitForChild("Dough")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
game:GetService("TweenService")
local scaleParticle = misc.ScaleParticle
local shakeCam = Effect.new("ShakeCam")
local doughExplosionsBurntFloor = Effect.new("Dough.Explosions.BurntFloor")
local doughExplosionsDripScatter = Effect.new("Dough.Explosions.DripScatter")
local doughShockwaves1 = Effect.new("Dough.Shockwaves.1")
local doughShockwaves2 = Effect.new("Dough.Shockwaves.2")
local colorCorrection = Effect.new("ColorCorrection")
local depthOfField = Effect.new("DepthOfField")
local v = 0
local v2 = Pool.new(string.format("Dough/%s/%s", script.Parent.Name, script.Name))
v2:setAction(function(object, _)
	local now = tick()

	for _, v3 in pairs(object.Pool) do
		local part = v3.Part
		local v4 = now - v3.Start

		if part and part.Parent and part:IsDescendantOf(workspace) and v4 < v3.Lifetime then
			local position = v3:GetPosition(v4)
			part.CFrame = CFrame.new(v3.LastPosition, position)
			v3.LastPosition = position
		else
			v -= 1
			object:remove(v3)
		end
	end
end)
return function(data)
	local cFrame = data.CFrame
	local scale = data.Scale or 1
	local lifetime = data.Lifetime or data.Duration or 0.25
	local magnitude = (currentCamera.CFrame.p - cFrame.p).Magnitude

	if 200 + 4 * scale < magnitude then
		return
	end

	local clone = dough.Explosions.Generic:Clone()
	local effect = clone.PrimaryPart.Effect
	local pointLight = effect:FindFirstChildOfClass("PointLight")
	local v3 = {}

	for _, emitter in pairs(effect:GetChildren()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = false
		table.insert(v3, {
			Particle = emitter,
			Data = {
				Size = emitter.Size.Keypoints,
				Speed = emitter.Speed,
				Acceleration = emitter.Acceleration
			}
		})
	end

	pointLight.Brightness = 0
	pointLight.Range = 0
	clone:SetPrimaryPartCFrame(cFrame)
	clone.Parent = _WorldOrigin
	sound:Play("Dough.DoughExplode", cFrame)
	local magnitude2 = (cFrame.p - currentCamera.CFrame.p).Magnitude
	local v4 = 25 + scale * 2

	if magnitude2 <= v4 then
		local v5 = math.min(1, magnitude2 / v4)
		colorCorrection:replicate({
			TintColor = Color3.fromRGB(255, 85, 0):Lerp(Color3.new(1, 1, 1), v5),
			Saturation = -2,
			Brightness = 0.5,
			Contrast = 1,
			FadeIn = lifetime / 4,
			Lifetime = lifetime / 4,
			FadeOut = lifetime / 3
		})
		depthOfField:replicate({
			NearIntensity = 0.5,
			FarIntensity = 1,
			Lifetime = lifetime,
			FadeOut = 0.25,
			FocusDistance = scale / 2,
			InFocusRadius = scale
		})
		shakeCam:replicate({
			Preset = "Explosion",
			Power = 1 - v5 / 2
		})
	end

	if data.Grounded then
		local random = Random.new()
		local v5 = math.floor(scale / 1.8)
		local v6 = math.max(4, v5 / 4)

		for i = 1, v5 do
			local v7 = 6.283185307179586 * (i / v5)
			local v8 = rock2.new({
				Type = "Ground",
				FadeOut = { lifetime / 2, lifetime },
				FadeIn = { lifetime / 2, lifetime },
				Lifetime = { lifetime + 0.5, lifetime * 4 + 0.5 },
				Size = Vector3.new(
					random:NextNumber(0.5, 1.5),
					random:NextNumber(0.5, 1.5),
					random:NextNumber(0.5, 1.5)
				),
				Scale = { v6 / 7, v6 / 3 }
			})

			if random:NextInteger(1, 8) % 4 == 0 then
				local unit = Vector3.new(
					math.sin(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2,
					random:NextNumber(0, 1) * 1.25,
					math.cos(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2
				).Unit
				v8.Type = "Flying"
				v8:Spawn(cFrame * CFrame.Angles(0, v7, 0) * CFrame.new(0, 0, -scale / 4))
				v8:Eject({
					Velocity = Util.Misc.Physics.Velocity(
						Vector3.new(),
						unit * random:NextNumber(v6 * 2, v6 * 8),
						Vector3.new(0, -workspace.Gravity * random:NextNumber(0.25, 1), 0),
						0.25 + random:NextNumber(0, 2)
					),
					AngularVelocity = Vector3.new(
						random:NextNumber(-1, 1),
						random:NextNumber(-1, 1),
						random:NextNumber(-1, 1)
					) * 2 * 3.141592653589793 * (1 / v8.Scale)
				})
			else
				v8:Spawn(cFrame * CFrame.Angles(0, v7, 0) * CFrame.new(0, 0, -scale / 4))
				v8:TweenShift(
					(cFrame * CFrame.Angles(0, v7, 0)).LookVector * v6 * random:NextNumber(1, 2),
					lifetime / 2
				)
			end
		end

		doughExplosionsBurntFloor:replicate({
			CFrame = cFrame,
			Scale = scale * 1.25,
			FadeIn = lifetime,
			Lifetime = 1,
			Brightness = 2.5,
			ColorSequence = {
				Color3.new(1, 1, 0),
				Color3.new(1, 0.5, 0),
				Color3.new(1, 0, 0),
				Color3.new()
			}
		})
	end

	doughShockwaves1:replicate({
		CFrame = cFrame,
		Scale = scale * 1.25,
		Duration = lifetime
	})
	doughShockwaves2:replicate({
		CFrame = cFrame,
		Scale = scale * 1.55,
		Speed = -1.5,
		Duration = lifetime
	})
	distributedLoop:add(function(p, _)
		local v5 = math.min(1, p / lifetime)
		local sine = Util.Tween.ease.out.sine(v5, 0, 1, 1)
		pointLight.Range = scale * 0.75 * sine
		pointLight.Brightness = 20 * sine

		if v5 ~= 1 then
			return
		end

		distributedLoop:add(function(p2, _)
			local v6 = math.min(1, p2 / lifetime)
			local sine2 = Util.Tween.ease.out.sine(v6, 1, -1, 1)
			pointLight.Range = scale * 0.75 * sine2
			pointLight.Brightness = 20 * sine2

			if v6 == 1 then
				return true
			end
		end)
		return true
	end)
	doughExplosionsDripScatter:replicate({
		CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0),
		Spread = data.Grounded and Vector2.new(80, 80),
		Scale = scale * 0.1,
		Drag = 2,
		Distance = 10 + scale * 0.6,
		Rate = math.floor(scale * 0.1) + 6,
		Gravity = 0.9,
		Time = 0.5,
		Influence = { 0.5, 2 }
	})

	for _, v5 in pairs(v3) do
		lifetime = math.max(lifetime, v5.Particle.Lifetime.Max)
		scaleParticle(v5.Particle, 0.03333333333333333 * scale, v5.Data)
		local emit = v5.Particle:GetAttribute("Emit") or 1

		if data.Grounded then
			if v5.Particle.Name == "Rocks" then
				v5.Particle.Color = ColorSequence.new(data.Grounded.Color)
			end
		elseif v5.Particle.Name:find("Smoke") or v5.Particle.Name == "Burst" or v5.Particle.Name == "Specs" or v5.Particle.Name == "Blobs" then
			v5.Particle.SpreadAngle = Vector2.new(360, 360)
		end

		v5.Particle:Emit(emit)
	end

	local flying = clone.Flying
	local clone2 = flying:Clone()
	flying:Destroy()

	for _, child in pairs(clone2.Flying:GetChildren()) do
		local enable = child:GetAttribute("Enable") or 0
		local v5 = child.Lifetime.Max + enable
		lifetime = math.max(lifetime, v5)
	end

	local random = Random.new()

	local function flyingDebris(cFrame2, p, p2, p3)
		local clone3 = clone2:Clone()
		local number = Random.new():NextNumber(0.5, 1.5)
		local v5 = 0
		local v6 = {}

		for _, child in pairs(clone3.Flying:GetChildren()) do
			v5 = math.max(v5, child.Lifetime.Max)
			child.Enabled = false
			table.insert(v6, {
				Particle = child,
				Data = {
					Size = child.Size.Keypoints,
					Speed = child.Speed,
					Acceleration = child.Acceleration
				}
			})
		end

		for _, v7 in pairs(v6) do
			scaleParticle(v7.Particle, 0.03333333333333333 * scale * Random.new():NextNumber(0.2, 0.6), v7.Data)
			local _ = data.Grounded
		end

		clone3.CFrame = cFrame2
		clone3.Parent = clone
		local lifetime2 = 0

		for _, v8 in pairs(v6) do
			local enable = v8.Particle:GetAttribute("Enable")
			lifetime2 = math.max(lifetime2, 2 * lifetime + enable * number)

			if not enable then
				continue
			end

			v8.Particle.Enabled = true
			local v9 = v8
			task.delay(enable * number, function()
				v9.Particle.Enabled = false
			end)
		end

		local velocity = misc.Physics.Velocity(cFrame2.p, cFrame2 * Vector3.new(0, 0, p), p2, p3)
		clone3.CFrame = CFrame.new(Vector3.new(), velocity) + cFrame2.p
		Util.Debris:AddItem(clone3, lifetime2 + 1)
		v2:add({
			Part = clone3,
			GetPosition = function(self, p4)
				return misc.Physics.Trajectory(cFrame2.p, velocity, p2 * random:NextNumber(1, 1.25), p4)
			end,
			LastPosition = clone3.CFrame.p,
			Lifetime = lifetime2,
			Start = tick()
		})
	end

	local random2 = Random.new()
	local count = 0

	for _ = 1, 6 do
		if v >= 48 then
			return
		end

		count += 1
		local spreadAngleFromCFrame, _ = misc.SpreadAngleFromCFrame(
			cFrame * CFrame.Angles(-1.5707963267948966, 0, 0),
			data.Grounded and Vector2.new(75, 75) or Vector2.new(180, 180)
		)
		flyingDebris(
			spreadAngleFromCFrame,
			random2:NextNumber(0.75 * scale, 1.5 * scale),
			Vector3.new(0, -workspace.Gravity) * 0.75,
			0.5
		)
	end

	if count > 0 then
		v += count
	end

	task.wait(lifetime + 0.1)
	clone:Destroy()
end