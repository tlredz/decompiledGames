local createVector = vector.create
local _ = game.Players.LocalPlayer
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local skill2 = FX:WaitForChild("Rengoku").Skill2
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Debris
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = workspace.CurrentCamera

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function snapProjectileToFinalPos(p, p2)
	p.CFrame = p.CFrame.Rotation + p2
end

local function fireClientProjectile(fliesFor, p, fXContainer, fn, part, p2)
	local fn2 = p2 == nil and function(_)
		return CFrame.new()
	end or p2

	if part == nil then
		part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Shape = Enum.PartType.Ball
		part.Size = Vector3.new(p, p, p) * 2
		part.Transparency = 1
		part.Name = "Projectile"
		part.Parent = _WorldOrigin
		Util.Debris:AddItem(part, fliesFor + 7)
	end

	part.CFrame = CFrame.lookAt(fn(0.001), fn(0.002)) * fn2(0.001) * CFrame.Angles(
		0,
		0,
		fXContainer:GetAttribute("TwistAngle") or 0
	)
	local bindableEvent = Instance.new("BindableEvent")
	Util.Debris:AddItem(bindableEvent, 7)
	local v2 = false
	local connection = nil
	connection = heartbeatLoopFor2(fliesFor, function(_, _, p3)
		if fXContainer:GetAttribute("ProjectileActive") == true or fXContainer:GetAttribute("ImpactPos") == nil or not (fXContainer:GetAttribute("DisabledInterp") < 0.9999) then
			part.CFrame = CFrame.lookAt(fn(p3), fn(p3 + 0.01)) * fn2(p3) * CFrame.Angles(
				0,
				0,
				fXContainer:GetAttribute("TwistAngle") or 0
			)
			return
		end

		connection:Disconnect()
		connection = nil
		snapProjectileToFinalPos(part, fXContainer:GetAttribute("ImpactPos")) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(nil, "Disabled")
		bindableEvent:Fire(fXContainer:GetAttribute("ImpactPos"), "Impact")
		v2 = true
	end, function()
		if v2 == true then
			return
		end

		snapProjectileToFinalPos(part, fn(1)) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(nil, "Disabled")
		bindableEvent:Fire(fn(1), "NonImpact")
	end)
	return bindableEvent, part, connection
end

local function Stage1Projectile(cFrame, settings, player)
	local distance = settings.Distance

	if player == game.Players.LocalPlayer then
		Effect.new("ShakeCam"):replicate({
			Magnitude = 7,
			Roughness = 9,
			FadeIn = 0.15,
			FadeOut = 0.3,
			Power = 1
		})
	end

	local clone = skill2.Slash:Clone()
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	Util.Debris:AddItem(clone, 4)
	Util.Sound:Play("Mera_EnteiExplosion", clone, 30, 2, 0.3)

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v = emitter
		coroutine.wrap(function()
			if v:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v:GetAttribute("EmitDelay"))
			end

			v:Emit(v:GetAttribute("EmitCount"))
		end)()
	end

	task.wait(0.025)
	local clone2 = skill2.Explosion:Clone()
	clone2.CFrame = cFrame * CFrame.new(0, 0, -7)
	clone2.Parent = _WorldOrigin
	Util.Debris:AddItem(clone2, 4)

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v = emitter
		coroutine.wrap(function()
			if v:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v:GetAttribute("EmitDelay"))
			end

			v:Emit(v:GetAttribute("EmitCount"))
		end)()
	end

	local clone3 = skill2.SlashProjectile:Clone()
	clone3.CFrame = cFrame * CFrame.new(0, 3, -13) * CFrame.Angles(0, 0, 1.3962634015954636)
	clone3.Parent = _WorldOrigin
	Util.Debris:AddItem(clone3, 5)
	local v = {}

	for _, effect in pairs(clone3:GetDescendants()) do
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = true
			effect.Rate *= 0.666
			v[effect] = effect.Rate * 0.05
		elseif effect:IsA("Beam") then
			local tween = TweenService:Create(
				effect,
				TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					Width0 = effect.Width0,
					Width1 = effect.Width1
				}
			)
			effect.Width0 = 0
			effect.Width1 = 0
			tween:Play()
		end
	end

	local p = cFrame.p
	local v2 = p + cFrame.LookVector * distance
	local v4 = nil
	fireClientProjectile(settings.fliesFor, 20, settings.FXContainer, function(p2)
		return p + (v2 - p) * p2 * 1.1
	end, clone3).Event:Connect(function(_: Vector3, p2: string)
		if p2 == "Impact" then
			v4 = true
		elseif p2 == "Disabled" then
			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			local clone4 = skill2.ProjectileEnd:Clone()
			clone4.Position = clone3.Position
			clone4.Parent = _WorldOrigin
			Util.Debris:AddItem(clone4, 3)

			for _, emitter in pairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end
	end)
	coroutine.wrap(function()
		for _, beam in pairs(clone3:GetDescendants()) do
			if beam:IsA("Beam") then
				TweenService:Create(beam, TweenInfo.new(settings.fliesFor), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end
		end

		local lastTime = tick()

		while tick() - lastTime < settings.fliesFor - 0.1 do
			for k, v5 in pairs(v) do
				k:Emit(v5)
			end

			task.wait(0.15)
		end
	end)()
end

local function Stage2Explosion(cFrame, _, player)
	if player == game.Players.LocalPlayer then
		Effect.new("ShakeCam"):replicate({
			Magnitude = 12,
			Roughness = 18,
			FadeIn = 0.2,
			FadeOut = 0.8,
			Power = 1
		})
	end

	local clone = skill2.Slash2:Clone()
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	Util.Debris:AddItem(clone, 4)

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v = emitter
		coroutine.wrap(function()
			if v:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v:GetAttribute("EmitDelay"))
			end

			v:Emit(v:GetAttribute("EmitCount"))
		end)()
	end

	task.wait(0.025)
	local clone2 = skill2.Explosion2:Clone()
	clone2.CFrame = cFrame * CFrame.new(0, 0, -7)
	clone2.Parent = _WorldOrigin
	Util.Debris:AddItem(clone2, 4)

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v = emitter
		coroutine.wrap(function()
			if v:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v:GetAttribute("EmitDelay"))
			end

			v:Emit(v:GetAttribute("EmitCount"))
		end)()
	end

	local p = clone2.CFrame.p
	local rayMapCollidable, v, v2 = Util.RayMapCollidable(
		p + createVector(0, 1, 0),
		CFrame.new(p + createVector(0, 1, 0), p + createVector(0, -10, 0)).LookVector * 10
	)

	if rayMapCollidable then
		local v3 = Util.Misc.AlignCFrame(CFrame.new(createVector(0, 0, 0), cFrame.LookVector) + v, v2) + v2 * 0.5
		coroutine.wrap(function()
			task.wait(0.17)
			local clone3 = skill2.Burn:Clone()
			clone3.CFrame = v3 * CFrame.new(0, 0, -80)
			clone3.Parent = _WorldOrigin
			Util.Debris:AddItem(clone3, 4)

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			clone3.Attachment.Particle_1.Enabled = false
			clone3.Attachment.Particle_1.Lifetime = NumberRange.new(0.15, 0.15)
			coroutine.wrap(function()
				for _ = 1, 20 do
					clone3.Attachment.Particle_1:Emit(1)
					task.wait(0.1)
				end

				TweenService:Create(clone3, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					CFrame = clone3.CFrame * CFrame.new(0, 0, -clone3.Size.Z / 2),
					Size = clone3.Size * createVector(1, 1, 0)
				}):Play()

				for _, effect in pairs(clone3:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = false
					end
				end
			end)()
		end)()
		local clone3 = skill2.GroundBurn:Clone()
		clone3.CFrame = v3 * CFrame.new(0, 0, -47)
		clone3.Parent = _WorldOrigin
		Util.Debris:AddItem(clone3, 4)
		coroutine.wrap(function()
			for i = 100, 50, -1 do
				task.wait()

				for _, beam in pairs(clone3:GetDescendants()) do
					if beam:IsA("Beam") then
						beam.Transparency = NumberSequence.new(i / 100, i / 100)
					end
				end
			end

			task.wait(1.75)

			for i = 50, 100 do
				task.wait()

				for _, beam in pairs(clone3:GetDescendants()) do
					if beam:IsA("Beam") then
						beam.Transparency = NumberSequence.new(i / 100, i / 100)
					end
				end
			end
		end)()

		for i = 1, 2 do
			local v4 = i == 1 and 1 or -1
			local v6 = v3 * CFrame.new(v4 * 23, 0, 0) * CFrame.Angles(0, math.rad(-v4 * 40), 0)
			task.spawn(function()
				for i2 = 0, 130, 13 do
					local v7 = math.max(0.5, i2 / 130 * 0.5 + 0.5)
					local v8 = v6 * Vector3.new(0, 0, -i2)
					local rayMapCollidable2, v9, v10 = Util.RayMapCollidable(v8 + v2, -v2 * 10)

					if rayMapCollidable2 then
						local v11 = Util.Misc.AlignCFrame(CFrame.new(createVector(0, 0, 0), v6.LookVector) + v9, v10) + v10 * 0.5
						local clone4 = skill2.Rock:Clone()
						clone4.CFrame = v11 - v11.LookVector * 13
						clone4.Orientation = Vector3.new(
							math.random(-360, 360),
							math.random(-360, 360),
							math.random(-360, 360)
						)
						clone4.Color = rayMapCollidable2.Color
						clone4.Parent = _WorldOrigin
						TweenService:Create(
							clone4,
							TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = clone4.CFrame + v11.LookVector * 13,
								Size = createVector(25, 25, 25) * v7
							}
						):Play()
						local v13 = v10
						task.delay(2, function()
							TweenService:Create(
								clone4,
								TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									CFrame = clone4.CFrame - v13 * 12.5,
									Size = createVector(0, 0, 0)
								}
							):Play()
							task.wait(0.15)
							clone4:Destroy()
						end)
					end

					task.wait(0.01)
				end
			end)
		end
	end
end

return function(data)
	local cFrame = data.CFrame
	local stage = data.Stage
	local settings = data.Settings

	if stage == 1 then
		Stage1Projectile(cFrame, settings, data.Player)
	elseif stage == 2 then
		Util.Sound:Play("Mera_EnteiExplosion", cFrame, 40, 1.6, 0.5)
		Stage2Explosion(cFrame, settings, data.Player)
	end
end