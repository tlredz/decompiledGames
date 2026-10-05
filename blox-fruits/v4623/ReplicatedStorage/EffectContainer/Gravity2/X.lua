local createVector = vector.create
local resume = coroutine.resume
local create = coroutine.create
cr = resume
cc = create
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { workspace.Map }
TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo2 = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local TweenService = game:GetService("TweenService")
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Util = require(game.ReplicatedStorage.Util)
local Effect = require(game.ReplicatedStorage.Effect)
local _WorldOrigin = workspace._WorldOrigin
return function(instance)
	local _ = instance.Origin
	local holding = instance.Holding
	local caster = instance.Caster
	local root = instance.Root
	local humanoid = instance.Humanoid
	local cframe = CFrame.new(root.Position)

	if (cframe.p - workspace.CurrentCamera.CFrame.p).magnitude > 700 then
		return
	end

	local v = true
	local v2 = Util.Sound:Play("GravityX", cframe)
	Random.new()
	local clone = script.obisencelines:Clone()
	clone.CFrame = root.CFrame
	clone.Parent = workspace._WorldOrigin
	TweenService:Create(clone, TweenInfo.new(5), {
		Size = createVector(177.1835, 18.99625, 181.26875)
	}):Play()
	local raycastResult = workspace:Raycast(
		clone.CFrame * CFrame.new(0, -2.5, 0).Position,
		createVector(0, -15, 0),
		raycastParams
	)

	if raycastResult then
		local instance2 = raycastResult.Instance
		local _ = raycastResult.Position
		local grass2 = clone.Attachment.Grass2
		grass2.Color = ColorSequence.new(instance2.Color)
		local smoke = clone.Attachment.Smoke
		smoke.Color = ColorSequence.new(instance2.Color)
		task.delay(0.4, function()
			grass2.Enabled = false
			smoke.Enabled = false
		end)
	end

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		Util.ScaleParticle({
			Emitter = emitter,
			Scale = 5,
			Time = 5,
			EasingStyle = Enum.EasingStyle.Linear,
			EasingDirection = Enum.EasingDirection.Out
		})
		emitter.Rate *= 1.5
	end

	coroutine.wrap(function()
		for i = 1, 19 do
			if not v then
				break
			end

			local _ = root.CFrame * CFrame.new(0, math.rad((math.random(-4, 180))), 0) * CFrame.new(
				0,
				-0.5,
				math.random(-4, 20) * (i / 6 + 1)
			)
			coroutine.wrap(function()
				for i2 = 1, 9 do
					local clone2 = script.Sphere:Clone()

					if i2 % 2 == 0 then
						clone2.Color = Color3.fromRGB(118, 85, 219)
					else
						clone2.Color = Color3.fromRGB(17, 17, 17)
					end

					clone2.Size = createVector(1.223, 8.787, 1.327)
					clone2.CFrame = clone.CFrame * CFrame.new(
						math.random(-20, 20),
						math.random(-5, 9),
						math.random(-20, 20)
					)
					TweenService:Create(clone2, tweenInfo2, {
						CFrame = clone2.CFrame * CFrame.new(0, -math.random(25, 65), 0)
					}):Play()
					clone2.Parent = clone
					Util.Debris:AddItem(clone2, 0.5)
					TweenService:Create(clone2, TweenInfo.new(0.15), {
						Size = createVector(0.2, 3, 0.2),
						CFrame = clone2.CFrame * CFrame.new(0, -3, 0)
					}):Play()
					task.delay(0.2, function()
						TweenService:Create(clone2, TweenInfo.new(0.15), {
							Size = createVector(0.2, 0.2, 0.2),
							CFrame = clone2.CFrame * CFrame.new(0, -6, 0),
							Transparency = 1
						}):Play()
					end)
					wait()
				end
			end)()
			wait(0.25)
		end
	end)()
	coroutine.wrap(function()
		for i = 1, 24 do
			if not v then
				break
			end

			local clone2 = script.ring1:Clone()
			clone2.CFrame = clone.CFrame
			clone2.Orientation = clone2.Orientation
			clone2.Parent = _WorldOrigin
			TweenService:Create(clone2, tweenInfo, {
				Position = clone2.Position + createVector(0, 0, 0),
				Size = createVector(36.627, 0.001, 36.627) * (i / 6 + 1),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone2, 0.6)
			wait(0.2)
		end
	end)()
	coroutine.wrap(function()
		for i = 1, 24 do
			if not v then
				break
			end

			local clone2 = script.Circle:Clone()
			clone2.CFrame = clone.CFrame * CFrame.new(0, -2.5, 0)
			clone2.Orientation = clone2.Orientation
			clone2.Parent = _WorldOrigin
			TweenService:Create(clone2, TweenInfo.new(0.5), {
				Size = clone2.Size * 9 * (i / 6 + 1),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone2, 0.6)
			wait(0.2)
		end
	end)()
	coroutine.wrap(function()
		for i = 1, 24 do
			if not v then
				break
			end

			local clone2 = script.thang:Clone()
			clone2.CFrame = clone.CFrame
			clone2.Orientation += createVector(0, -90, 0)
			clone2.Parent = _WorldOrigin
			TweenService:Create(clone2, TweenInfo.new(0.5), {
				Size = clone2.Size * 7 * (i / 6 + 1),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone2, 0.6)
			wait(0.2)
		end
	end)()
	Debris:AddItem(clone, 6)
	local lastTime = tick()
	local lastTime2 = tick()
	local v3 = {}

	while tick() - lastTime2 < 5 and not (humanoid.Health <= 0) and caster.Parent and (not (tick() - lastTime2 > 1) or holding and holding.Value) do
		local v4 = math.min(1, (tick() - lastTime2) / 5) ^ 0.5 * 200 + 25

		if tick() - lastTime > 0.15 and (game.Players.LocalPlayer == caster or (cframe.p - workspace.CurrentCamera.CFrame.p).magnitude < v4 / 2) then
			lastTime = tick()
			Effect.new("ShakeCam"):replicate({
				2,
				15,
				0.3,
				0.3,
				createVector(1, 1, 1),
				createVector(1, 1, 4)
			})
		end

		local count = 0

		for i = 0, 360, 360 / (v4 * 2) ^ 0.5 do
			count += 1
			local v5 = cframe * CFrame.Angles(0, math.rad(i), 0) * Vector3.new(0, 10, v4 / 2)
			local ray = Util.Ray
			local v6 = { workspace.Characters, workspace.Enemies }
			local v7, v8 = ray(v5, createVector(0, -20, 0), v6)

			if v7 and v7.Anchored and v7.Transparency <= 0 then
				local v9 = v3[count] or Instance.new("Part")
				v9.Color = v7.Color
				v9.Material = v7.Material
				v9.Transparency = v7.Transparency
				v9.Size = createVector(1, 0.3, 0.3) * (v4 / 2) ^ 0.5 * 3.141592653589793
				v9.CFrame = (CFrame.new(v8, (Vector3.new(cframe.p.X, v8.Y, cframe.p.Z))) - createVector(0, 0, 0)) * CFrame.Angles(
					-0.7853981633974483,
					0,
					0
				)

				if not v3[count] then
					v3[count] = v9
					v9.Anchored = true
					v9.CanCollide = false
					v9.TopSurface = 0
					v9.BottomSurface = 0
				end

				v9.Parent = _WorldOrigin
			elseif v3[count] then
				v3[count].Parent = nil
			end
		end

		wait()
	end

	v = false

	for _, v4 in next, v3, nil do
		if v4.Parent then
			local tween = TweenService:Create(v4, TweenInfo.new(0.25), {
				CFrame = v4.CFrame - Vector3.new(0, v4.Size.Y * 1.25, 0)
			})
			local v5 = v4
			tween.Completed:Connect(function()
				v5:Destroy()
			end)
			tween:Play()
		else
			v4:Destroy()
		end
	end

	Util.Sound:FadeOut(v2, 0.25)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end
end