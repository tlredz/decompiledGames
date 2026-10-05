local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local yoruV2Skill1 = FX:WaitForChild("Yoru").YoruV2Skill1
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local sound = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt

local function putFolder(parent, name: string)
	local v = parent:FindFirstChild(name)

	if v == nil then
		v = Instance.new("Folder")
		v.Name = name
		v.Parent = parent
	end

	return v
end

local function putValueAsValueObject(parent, name: string, p, value: number)
	local v2 = {
		boolean = "BoolValue",
		CFrame = "CFrameValue",
		Color3 = "Color3Value",
		number = "NumberValue",
		Instance = "ObjectValue",
		Ray = "RayValue",
		string = "StringValue",
		Vector3 = "Vector3Value"
	}
	local instance = parent:FindFirstChild(name)

	if instance == nil then
		instance = Instance.new(v2[typeof(p)])
		instance.Name = name
		instance.Parent = parent
	end

	instance.Value = p
	destroyAfter(instance, value or 60)
end

local function getValueObject(instance, childName)
	return instance:FindFirstChild(childName)
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

local function safeSetRootCFrame(instance, cFrame: CFrame, flag: boolean)
	local v = flag == nil or flag

	if instance == nil then
		return
	end

	local bodyPosition = instance:FindFirstChildOfClass("BodyPosition")

	if bodyPosition and bodyPosition.MaxForce.Magnitude > 1000 or instance.Anchored == true then
		return
	end

	if not v then
		instance.CFrame = cFrame
		return
	end

	local raycastResult = Workspace:Raycast(instance.Position, cFrame.Position - instance.Position, raycastParams)

	if raycastResult then
		instance.CFrame = instance.CFrame.Rotation + raycastResult.Position - (cFrame.Position - instance.Position).Unit * 0.2
	else
		instance.CFrame = cFrame
	end
end

local function snapProjectileToFinalPos(folder, p)
	folder.CFrame = folder.CFrame.Rotation + p

	for _, effect in ipairs(folder:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = false
		end
	end

	folder.Transparency = 1
end

local function fireClientProjectile(p, p2, instance, callback, part, p3)
	local fn = p3 == nil and function(_)
		return CFrame.new()
	end or p3

	if part == nil then
		part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Shape = Enum.PartType.Ball
		part.Size = Vector3.new(p2, p2, p2) * 2
		part.Transparency = 1
		part.Name = "Projectile"
		part.Parent = _WorldOrigin
		destroyAfter(part, p + 7)
	end

	part.CFrame = CFrame.lookAt(callback(0.001), callback(0.002)) * fn(0.001)
	local bindableEvent = Instance.new("BindableEvent")
	destroyAfter(bindableEvent, 7)
	local v = false
	local connection = nil
	connection = heartbeatLoopFor2(p, function(_, _, p4)
		if instance:GetAttribute("ProjectileActive") == true then
			part.CFrame = CFrame.lookAt(callback(p4), callback(p4 + 0.01)) * fn(p4)
			return
		end

		connection:Disconnect()
		connection = nil
		snapProjectileToFinalPos(part, instance:GetAttribute("ImpactPos"))
		bindableEvent:Fire(instance:GetAttribute("ImpactPos"), "Impact")
		v = true
	end, function()
		if v == true then
			return
		end

		snapProjectileToFinalPos(part, callback(1))
		bindableEvent:Fire(callback(1), "NonImpact")
	end)
	return bindableEvent, part, connection
end

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function cubicBezier(sine, position, p, p2, p3)
	local v = position + (p - position) * sine
	local v2 = p + (p2 - p) * sine
	local v3 = p2 + (p3 - p2) * sine
	local v4 = v + (v2 - v) * sine
	return v4 + (v2 + (v3 - v2) * sine - v4) * sine
end

local function adjustDuration(p, p2)
	local v = math.max(0.01, p - p2)
	return v, p2 - (p - v)
end

local blastLayer = Effect.new("BlastLayer")
return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	local origin = data.origin
	local fireDir = data.fireDir
	local targetPos = data.targetPos
	local specialActivated = data.specialActivated
	local v = math.max(0, Util.MasterClock:GetTime() - data.ClockTime - 0.05)
	local fliesFor = data.fliesFor
	local v2 = math.max(0.01, fliesFor - v)
	local _ = v - (fliesFor - v2)

	if player == game.Players.LocalPlayer then
		Util.CameraShaker:ShakeOnce(16, 10, 0.2, 1)
	end

	local parent = _WorldOrigin
	local cFrame = CFrame.lookAt(createVector(0, 0, 0), fireDir) * CFrame.new(0, 0, -10) + origin
	local magnitude = (targetPos - cFrame.Position).Magnitude
	Util.Sound:Play("KiBlastFireShort", cFrame, 25)
	sound:Play("BigBangAttackFire", cFrame, 25)
	task.wait(adjustDuration(0.04, v))
	local clone = yoruV2Skill1.Slash:Clone()
	local attachment2 = not specialActivated and clone:FindFirstChild("Attachment2")

	if attachment2 then
		attachment2:Destroy()
	end

	clone.CFrame = cFrame
	clone.Parent = parent
	destroyAfter(clone, 2 + v2)

	if not specialActivated then
		for _, effect in ipairs(clone:GetDescendants()) do
			if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
				continue
			end

			if effect:IsA("ParticleEmitter") then
				effect.Lifetime = NumberRange.new(effect.Lifetime.Min * v2, effect.Lifetime.Max * v2)
			end

			effect.Enabled = false
		end
	end

	local tween = TweenService:Create(clone, TweenInfo.new(adjustDuration(0.1, v)), {
		Size = Vector3.new(clone.Size.X, clone.Size.Y, clone.Size.Z)
	})
	clone.Size = Vector3.new(clone.Size.X / 105, clone.Size.Y / 105, clone.Size.Z / 105)
	tween:Play()
	task.wait(tween.TweenInfo.Time)

	for _, effect in ipairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = true
		end
	end

	blastLayer:replicate({
		Anchor = clone,
		Transparency = 0,
		Rate = 0.1,
		Duration = 0.8,
		Color = clone.Color,
		Parent = parent
	})
	local tween2 = TweenService:Create(
		clone,
		specialActivated and TweenInfo.new(v2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut) or TweenInfo.new(
			v2,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.In
		),
		{
			CFrame = clone.CFrame * CFrame.new(0, 0, -magnitude)
		}
	)
	tween2:Play()
	coroutine.wrap(function()
		if not specialActivated then
			return
		end

		task.wait(0.035)

		for i = 1, 10 do
			local v5 = i
			coroutine.wrap(function()
				task.wait(0.005)
				local clone2 = yoruV2Skill1.Trail:Clone()
				clone2.CFrame = cFrame * CFrame.new(
					math.random(-20, 20) / 1,
					math.random(-15, 15) * 1.5,
					math.random(-1, 1)
				)
				clone2.Parent = parent
				local position = clone2.Position
				local v6 = cFrame * CFrame.new(math.random(-5, 5), math.random(-15, 15) * 1.5, -magnitude).Position
				local magnitude2 = (position - v6).Magnitude
				local cframe = CFrame.new(position, v6)
				clone2.CFrame = CFrame.new(position, v6)
				local v7 = (position - v6) / 2
				local position2 = CFrame.new(CFrame.new(position) * (v7 / -1.5)).Position
				local position3 = CFrame.new(CFrame.new(v6) * (v7 / 1.5)).Position
				local v8 = magnitude2 / 12
				local v9 = position2 + Vector3.new(math.random(-v8, v8), math.random(-3, 8) * 7, math.random(-v8, v8))
				local v10 = position3 + Vector3.new(math.random(-v8, v8), math.random(-3, 8) * 7, math.random(-v8, v8))
				local v11 = math.random(5, 20)

				for i2, effect in pairs(clone2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") then
						if specialActivated then
							effect.Rate *= 1 / v2
						else
							effect.Lifetime = NumberRange.new(effect.Lifetime.Min * v2, effect.Lifetime.Max * v2)
						end

						effect.Enabled = true
					end

					if not effect:IsA("Trail") or specialActivated then
						continue
					end

					effect.Lifetime *= v2
				end

				local lastTime = tick()
				local v12 = 0
				local v13 = 0.016666666666666666

				while true do
					local v14 = math.min(1, (tick() - lastTime) / v2)
					v12 = v12 % 6.283185307179586 + 0.7853981633974483 * v11 * v13
					local sine = Util.Tween.ease.inout.sine(v14, 0, 1, 1)
					local v15 = cframe.UpVector * (v5 % 2 == 0 and 1 or -1) * math.sin(v12) * v8 * (1.01 - sine)
					local v16 = cubicBezier(sine, position, v9, v10, v6)
					clone2.CFrame = clone2.CFrame:Lerp(CFrame.new(v16 + v15, v6), sine)

					if v14 == 1 then
						break
					end

					v13 = task.wait()
				end

				local v14 = 0

				for i2, emitter in pairs(clone2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					v14 = math.max(v14, emitter.Lifetime.Max)
					emitter.Enabled = false
				end

				destroyAfter(clone2, v14)
			end)()
		end
	end)()
	coroutine.wrap(function()
		task.wait(0.05)
		local position = cFrame.Position
		local v5 = 50
		local part, v6, v7 = Workspace:FindPartOnRayWithIgnoreList(
			Ray.new(
				position + Vector3.new(0, v5 / 10, 0),
				CFrame.new(position + Vector3.new(0, v5 / 10, 0), position + Vector3.new(0, -v5, 0)).LookVector * v5
			),
			raycastParams.FilterDescendantsInstances
		)

		if part then
			coroutine.wrap(function()
				local clone2 = yoruV2Skill1.GroundTrail:Clone()

				if not specialActivated then
					local attachment22 = clone2:FindFirstChild("Attachment2")
					local attachment3 = clone2:FindFirstChild("Attachment3")

					if attachment22 then
						attachment22:Destroy()
					end

					if attachment3 then
						attachment3:Destroy()
					end
				end

				clone2.CFrame = Util.Misc.AlignCFrame(cFrame - cFrame.p + v6, v7) * CFrame.new(0, 0, 2 * magnitude)
				clone2.Position = v6 + createVector(0, 0.001, 0)
				clone2.Parent = parent
				local tween3 = TweenService:Create(
					clone2,
					specialActivated and TweenInfo.new(v2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut) or TweenInfo.new(
						v2,
						Enum.EasingStyle.Linear,
						Enum.EasingDirection.In
					),
					{
						CFrame = clone2.CFrame * CFrame.new(0, 0, -magnitude)
					}
				)
				tween3:Play()
				v5 = 10

				for _, effect in ipairs(clone2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") then
						if specialActivated then
							effect.Rate *= 1 / v2
						else
							effect.Lifetime = NumberRange.new(effect.Lifetime.Min * v2, effect.Lifetime.Max * v2)
						end

						effect.Enabled = true
					end

					if not effect:IsA("Trail") or specialActivated then
						continue
					end

					effect.Lifetime *= v2
				end

				local lastTime = os.clock()
				local v8 = v7

				while true do
					task.wait(0.01)
					local position2 = clone.Position
					local part2, _, v9 = Workspace:FindPartOnRayWithIgnoreList(
						Ray.new(
							position2 + Vector3.new(0, v5 / 2, 0),
							CFrame.new(position2 + Vector3.new(0, v5 / 2, 0), position2 + Vector3.new(0, -v5, 0)).LookVector * v5 * 2
						),
						raycastParams.FilterDescendantsInstances
					)

					if not part2 then
						tween3:Pause()
						break
					end

					if v8 ~= nil and v8 ~= v9 then
						tween3:Pause()
						break
					end

					local v10 = os.clock() - lastTime
					local _ = v2 * 0.6 <= v10
					local v11 = os.clock() - lastTime

					if v2 * 0.8 <= v11 or os.clock() - lastTime > 10 then
						break
					else
						v8 = v9
					end
				end

				for _, emitter in ipairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				destroyAfter(clone2, 3)
			end)()
			coroutine.wrap(function()
				for i = 1, 2 do
					local clone2 = yoruV2Skill1.Rock:Clone()

					if i == 1 then
						clone2.CFrame = clone.CFrame * CFrame.new(-8, -0.5, -3) * CFrame.Angles(
							0,
							0.026179938779914945,
							0
						)
					else
						clone2.CFrame = clone.CFrame * CFrame.new(8, -0.5, -3) * CFrame.Angles(
							0,
							-0.026179938779914945,
							0
						)
					end

					clone2.CFrame *= CFrame.new(0, 0, -2)
					clone2.Transparency = 1
					rocks:ApplyCollision(clone2, nil, true)
					clone2.Parent = parent
					local tween3 = TweenService:Create(
						clone2,
						TweenInfo.new(v2 * 0.95, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = clone2.CFrame * CFrame.new(0, 0, -magnitude),
							Size = createVector(15, 15, 15)
						}
					)
					tween3:Play()
					local v8 = false
					local lastTime = os.clock()
					coroutine.wrap(function()
						while true do
							task.wait(v2 * 1.5 * 0.015)
							local clone3 = clone2:Clone()
							clone3.Position = clone2.Position
							local part2, position2 = Workspace:FindPartOnRayWithIgnoreList(
								Ray.new(
									clone3.Position + createVector(0, 20, 0),
									CFrame.new(
										clone3.Position + createVector(0, 4, 0),
										clone3.Position + createVector(0, -40, 0)
									).LookVector * 40
								),
								raycastParams.FilterDescendantsInstances
							)

							if part2 then
								clone3.Color = part2.Color
								clone3.Position = position2
								clone3.Transparency = 0
								destroyAfter(clone3, 1)
								clone3.Size = clone2.Size
								clone3.Parent = parent
								clone3.Orientation = Vector3.new(
									math.random(-360, 360),
									math.random(-360, 360),
									math.random(-360, 360)
								)
								local tween4 = TweenService:Create(
									clone3,
									TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Size = clone3.Size
									}
								)
								clone3.Size = createVector(0, 0, 0)
								tween4:Play()
								local v11 = clone3
								coroutine.wrap(function()
									task.wait(0.15)
									tween4 = TweenService:Create(
										v11,
										TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Size = createVector(0, 0, 0)
										}
									)
									tween4:Play()
								end)()

								if (specialActivated and 0.04 or 0.1) <= os.clock() - lastTime then
									lastTime = os.clock()
									local clone4 = clone2:Clone()
									clone4.Color = part2.Color
									clone4.Position = position2 + Vector3.new(0, math.random(5, 10) * 2, 0)
									clone4.Transparency = 0
									clone4.Size = createVector(0, 0, 0)
									clone4.Parent = parent
									clone4.Orientation = Vector3.new(
										math.random(-360, 360),
										math.random(-360, 360),
										math.random(-360, 360)
									)
									clone4.Anchored = false
									clone4.CanCollide = true
									local bodyVelocity = Instance.new("BodyVelocity")
									bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
									bodyVelocity.P = 700
									bodyVelocity.Parent = clone4
									bodyVelocity.Velocity = CFrame.new(
										clone4.Position,
										(CFrame.new(clone4.Position, cFrame.Position) * CFrame.new(0, 0, -5)).Position + Vector3.new(
											math.random(-150, 150) / 10,
											math.random(25, 150),
											0
										)
									).LookVector * math.random(50, 120)
									destroyAfter(bodyVelocity, 0.025)
									coroutine.wrap(function()
										TweenService:Create(
											clone4,
											TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
											{
												Size = Vector3.new(
													math.random(3, 9) / 1.5,
													math.random(3, 9) / 1.5,
													math.random(3, 9) / 1.5
												)
											}
										):Play()
										task.wait(2)
										destroyAfter(clone4, 1)
										TweenService:Create(
											clone4,
											TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
											{
												Size = createVector(0, 0, 0)
											}
										):Play()
									end)()
								end

								if v8 == true or os.clock() - lastTime > 10 then
									break
								end
							else
								clone3:Destroy()
							end
						end
					end)()
					local v11 = clone2
					coroutine.wrap(function()
						tween3.Completed:Wait()
						v8 = true
						v11:Destroy()
					end)()
				end
			end)()
		end

		coroutine.wrap(function()
			task.wait(adjustDuration(0.1, v))
			local clone2 = yoruV2Skill1.Smoke:Clone()
			local attachment3 = not specialActivated and clone2:FindFirstChild("Attachment3")

			if attachment3 then
				attachment3:Destroy()
			end

			clone2.CFrame = cFrame
			clone2.Parent = parent
			local lastTime = os.clock()
			local v8 = false

			while true do
				task.wait(0.01)
				local v9 = clone.CFrame * CFrame.new(0, 0, -10).Position
				local part2, v10 = Workspace:FindPartOnRayWithIgnoreList(
					Ray.new(
						v9 + createVector(0, 25, 0),
						CFrame.new(v9 + createVector(0, 5, 0), v9 + createVector(0, -50, 0)).LookVector * 50
					),
					raycastParams.FilterDescendantsInstances
				)

				if part2 then
					if v8 == false then
						v8 = true

						for _, effect in ipairs(clone2:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
								effect.Enabled = true
							end
						end
					end

					clone2.Position = v10 + createVector(0, 2, 0)
				elseif v8 == true then
					for _, effect in ipairs(clone2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							effect.Enabled = false
						end
					end

					v8 = false
				end

				local v11 = os.clock() - lastTime

				if not (v2 * 0.4 <= v11 or os.clock() - lastTime > 10) then
					continue
				end

				for _, effect in ipairs(clone2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = false
					end
				end

				destroyAfter(clone2, 4)
				break
			end
		end)()
	end)()
	coroutine.wrap(function()
		tween2.Completed:Wait()
		local clone2 = yoruV2Skill1.End:Clone()
		clone2.CFrame = clone.CFrame
		clone:Destroy()
		clone2.Parent = parent
		destroyAfter(clone2, 3)

		for _, emitter in ipairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end)()
end