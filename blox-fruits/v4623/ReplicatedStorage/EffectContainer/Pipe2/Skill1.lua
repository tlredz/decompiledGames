local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local pipeSkill1 = FX:WaitForChild("Pipe").PipeSkill1
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

-- equivalent calls inferred from this helper; original call sites unknown
local function snapProjectileToFinalPos(part, p, p2)
	if not p2 then
		part.CFrame = part.CFrame.Rotation + p
		return
	end

	local position = part.Position
	heartbeatLoopFor2(0.1, function(_, _, p3)
		part.CFrame = part.CFrame.Rotation + position + (p - position) * p3
	end, function()
		part.CFrame = part.CFrame.Rotation + p
	end)
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
		destroyAfter(part, fliesFor + 7)
	end

	part.CFrame = CFrame.lookAt(fn(0.001), fn(0.002)) * fn2(0.001)
	local bindableEvent = Instance.new("BindableEvent")
	destroyAfter(bindableEvent, 7)
	local v = false
	local connection = nil
	connection = heartbeatLoopFor2(fliesFor, function(_, _, p3)
		if fXContainer:GetAttribute("ProjectileActive") == true or fXContainer:GetAttribute("ImpactPos") == nil or not (fXContainer:GetAttribute("DisabledInterp") < 0.9999) then
			part.CFrame = CFrame.lookAt(fn(p3), fn(p3 + 0.01)) * fn2(p3)
			return
		end

		connection:Disconnect()
		connection = nil
		local v2 = part
		local impactPos = fXContainer:GetAttribute("ImpactPos")
		local position = v2.Position
		heartbeatLoopFor2(0.1, function(_, _, p4)
			v2.CFrame = v2.CFrame.Rotation + position + (impactPos - position) * p4
		end, function()
			snapProjectileToFinalPos(v2, impactPos, false) -- equivalent call inferred; original call site unknown
		end)
		bindableEvent:Fire(fXContainer:GetAttribute("ImpactPos"), "Impact")
		v = true
	end, function()
		if v == true then
			return
		end

		snapProjectileToFinalPos(part, fn(1))
		bindableEvent:Fire(fn(1), "NonImpact")
	end)
	return bindableEvent, part, connection
end

local function cameraShakeAt(vector2: Vector3, value: number, value2: number, value3: number, value4: number, value5: number)
	local v = value2 or 8
	local v2 = value3 or 14
	local v3 = value4 or 0.2
	local v4 = value5 or 0.7

	if (value or 300) > (Workspace.CurrentCamera.CFrame.Position - vector2).Magnitude then
		Util.CameraShaker:ShakeOnce(v, v2, v3, v4)
	end
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function cubicBezier(p, position, p2, p3, position2)
	local v = position + (p2 - position) * p
	local v2 = p2 + (p3 - p2) * p
	local v3 = p3 + (position2 - p3) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local parent = hrp.Parent
	local currentCamera = Workspace.CurrentCamera
	local cFrame = hrp.CFrame

	if (cFrame.Position - currentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	local _ = data.origin
	local fireDir = data.fireDir

	if player == game.Players.LocalPlayer then
		Util.CameraShaker:ShakeOnce(10, 7, 0.2, 2, createVector(1, 1, 1), createVector(1, 1, 5))
	end

	local parent2 = _WorldOrigin
	local cframe = CFrame.new(hrp.Position, data.targetPos)
	Util.Sound:Play("PipeZFire", hrp)
	local cFrame2 = cframe * CFrame.new(0, 0, -3.5)
	local clone = pipeSkill1.StartImpact:Clone()
	clone.CFrame = cFrame2
	clone.Parent = parent2
	destroyAfter(clone, 2)

	for _, emitter in ipairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v3 = emitter
		coroutine.wrap(function()
			if v3:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v3:GetAttribute("EmitDelay"))
			end

			v3:Emit(v3:GetAttribute("EmitCount"))
		end)()
	end

	task.wait(0.05)
	local magnitude = (data.targetPos - data.origin).Magnitude
	local v3, _ = fireClientProjectile(data.fliesFor, 8, data.FXContainer, function(p)
		return data.origin + (data.targetPos - data.origin) * p * 1.1
	end)
	local clone2 = pipeSkill1.Start:Clone()
	clone2.CFrame = cFrame2
	clone2.Massless = true
	clone2.Parent = parent2
	destroyAfter(clone2, 7)
	clone2.Weld.Part0 = hrp

	for _, emitter in ipairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local clone3 = pipeSkill1.HitBox:Clone()
	clone3.Size = Vector3.new(15, 15, magnitude)
	clone3.CFrame = cFrame2 * CFrame.new(0, 0, -clone3.Size.Z / 2)
	clone3.Parent = parent2
	destroyAfter(clone3, 4)
	v3.Event:Once(function(_, p)
		if p == "Impact" then
			local part = data.FXContainer.VictimRootValue.Value

			if part ~= nil and part.Parent ~= nil then
				if player == game.Players.LocalPlayer then
					Util.Anims:Get(parent, "PipeZSuperBurst"):Play(nil, nil, 0.533)
				end

				Util.Sound:Play("PipeZHit", hrp)
				coroutine.wrap(function()
					task.wait(0.1)
					local clone4 = pipeSkill1.Dragon:Clone()
					clone4.PrimaryPart.CFrame = clone.CFrame
					clone4.PrimaryPart.Position = (CFrame.new(part.Position, cFrame2.Position) * CFrame.new(0, 0, -2.5)).Position
					clone4.Parent = parent2
					destroyAfter(clone4, 3)
					local tween = TweenService:Create(
						clone4.PrimaryPart,
						TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),
						{
							Size = createVector(20, 25, 27),
							Color = Color3.fromRGB(255, 128, 78)
						}
					)
					tween:Play()
					tween.Completed:Wait()
					TweenService:Create(clone4.PrimaryPart, TweenInfo.new(0.07), {
						Transparency = 1
					}):Play()
				end)()
				task.wait()
				task.delay(0.15, function()
					clone2.Weld:Destroy()
					clone2.Anchored = true

					for _, emitter in ipairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)
				task.wait(0.01)
				local clone4 = pipeSkill1.Impale:Clone()
				clone4.CFrame = hrp.CFrame * CFrame.new(0, 0, -3)
				clone4.Parent = parent2
				destroyAfter(clone4, 2)

				for _, emitter in ipairs(clone4:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v4 = emitter
					coroutine.wrap(function()
						if v4:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v4:GetAttribute("EmitDelay"))
						end

						v4:Emit(v4:GetAttribute("EmitCount"))
					end)()
				end

				local clone5 = pipeSkill1.Impale2:Clone()
				clone5.Massless = true
				clone5.CFrame = clone4.CFrame
				clone5.Weld.Part0 = part
				clone5.Parent = parent2
				destroyAfter(clone5, 2)

				for _, emitter in ipairs(clone5:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				coroutine.wrap(function()
					local lastTime = os.clock()
					local v4 = time()

					for _ = 1, 600 do
						coroutine.wrap(function()
							local position = clone5.Position
							local clone6 = pipeSkill1.Trail:Clone()
							clone6.CFrame = clone5.CFrame * CFrame.new(
								math.random(-25, 25),
								math.random(2, 10),
								math.random(-25, 25)
							)
							clone6.Parent = parent2
							local position2 = clone6.Position
							local magnitude2 = (position2 - position).Magnitude
							clone6.CFrame = CFrame.new(position2, position)
							local v5 = (position2 - position) / 2
							local position3 = CFrame.new(CFrame.new(position2) * (v5 / -1.5)).Position
							local position4 = CFrame.new(CFrame.new(position) * (v5 / 1.5)).Position
							local halfMagnitude2 = magnitude2 / 2
							local v7 = position3 + Vector3.new(
								math.random(-halfMagnitude2, halfMagnitude2),
								math.random(-3, 8) * 2,
								math.random(-halfMagnitude2, halfMagnitude2)
							)
							local v8 = position4 + Vector3.new(
								math.random(-halfMagnitude2, halfMagnitude2),
								math.random(-3, 8) * 2,
								math.random(-halfMagnitude2, halfMagnitude2)
							)
							local lastTime2 = tick()
							local v9 = magnitude2 / 1.35 / 60

							while tick() - lastTime2 < v9 do
								local v10 = (tick() - lastTime2) / v9
								local v11 = cubicBezier(v10, position2, v7, v8, position)
								clone6.CFrame = clone6.CFrame:Lerp(CFrame.new(v11, position), v10)
								task.wait()
							end

							for _, emitter in ipairs(clone6:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end

							destroyAfter(clone6, 1)
						end)()
						task.wait(0.05)

						if os.clock() - lastTime >= 0.35 or time() - v4 > 10 then
							break
						end
					end
				end)()
				local stunTime = data.stunTime
				local v4 = player == game.Players.LocalPlayer
				pcall(function()
					if part == game.Players.LocalPlayer.Character.HumanoidRootPart then
						v4 = true
					end
				end)

				if v4 then
					coroutine.wrap(function()
						local clone6 = pipeSkill1.ScreenColor:Clone()
						clone6.Parent = Lighting
						local tween = TweenService:Create(
							clone6,
							TweenInfo.new(stunTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Brightness = clone6.Brightness,
								Contrast = clone6.Contrast,
								Saturation = clone6.Saturation,
								TintColor = clone6.TintColor
							}
						)
						tween:Play()
						clone6.Brightness = 0
						clone6.Contrast = 0
						clone6.Saturation = 0
						clone6.TintColor = Color3.fromRGB(255, 255, 255)
						tween.Completed:Wait()
						local tween2 = TweenService:Create(clone6, TweenInfo.new(0.12), {
							Brightness = 0,
							Contrast = 0,
							Saturation = 0,
							TintColor = Color3.fromRGB(171, 121, 97)
						})
						tween2:Play()
						tween2.Completed:Wait()
						destroyAfter(clone6, 1)
						TweenService:Create(clone6, TweenInfo.new(0.125), {
							TintColor = Color3.fromRGB(255, 255, 255)
						}):Play()
					end)()
				end

				task.wait(stunTime)
				clone5.Weld:Destroy()
				clone5.Anchored = true

				for _, emitter in ipairs(clone5:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				local position = cFrame.Position
				local v5 = 8
				local v6 = 14
				local v7 = 0.2
				local v8 = 0.7

				if (80 or 300) > (Workspace.CurrentCamera.CFrame.Position - position).Magnitude then
					Util.CameraShaker:ShakeOnce(v5, v6, v7, v8)
				end

				local clone6 = pipeSkill1.Explosion:Clone()
				clone6.CFrame = hrp.CFrame * CFrame.new(0, 0, -2)
				clone6.Parent = parent2
				destroyAfter(clone6, 2)

				for _, emitter in ipairs(clone6:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v9 = emitter
					coroutine.wrap(function()
						if v9:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v9:GetAttribute("EmitDelay"))
						end

						v9:Emit(v9:GetAttribute("EmitCount"))
					end)()
				end
			end
		else
			if player == game.Players.LocalPlayer then
				Util.Anims:Get(parent, "PipeZBurst"):Play(nil, nil, 0.75)
			end

			clone2.Weld:Destroy()
			clone2.Anchored = true
			Util.Sound:Play("PipeZExplosion", hrp.Position)

			for _, emitter in ipairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			local clone4 = pipeSkill1.Explosion:Clone()
			clone4.CFrame = CFrame.new(hrp.Position, hrp.Position + fireDir) * CFrame.new(0, 0, -2)
			clone4.Parent = parent2
			destroyAfter(clone4, 2)

			for _, emitter in ipairs(clone4:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v4 = emitter
				coroutine.wrap(function()
					if v4:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v4:GetAttribute("EmitDelay"))
					end

					v4:Emit(v4:GetAttribute("EmitCount"))
				end)()
			end

			local position = cFrame.Position
			local v4 = 8
			local v5 = 14
			local v6 = 0.2
			local v7 = 0.7

			if (80 or 300) > (Workspace.CurrentCamera.CFrame.Position - position).Magnitude then
				Util.CameraShaker:ShakeOnce(v4, v5, v6, v7)
			end
		end
	end)
end