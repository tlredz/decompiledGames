local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.MasterClock
local boatTween = Util.BoatTween
local debris = Util.Debris
local _ = Util.Sound
local misc = Util.Luno.Misc
local partCache = Util.PartCache

local function flyingIceChunk(p, p2, scaler)
	local v = math.random(20, 200) / 10 * (scaler * 0.5)
	local clone = script.IceBlock:Clone()
	Util.Debris:AddItem(clone, 5)
	clone.Size = Vector3.new(v, v, v)
	clone.CFrame = CFrame.new(p, p + p2) * CFrame.Angles(
		math.rad((math.random(-35, 35))),
		math.rad((math.random(-35, 35))),
		(math.rad((math.random(-35, 35))))
	)
	clone.Anchored = false

	for _, emitter in pairs(clone:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			misc.scaleParticle(emitter, scaler, true)
		end

		if emitter:isA("Attachment") then
			emitter.Position *= scaler
		end
	end

	clone.Parent = _WorldOrigin
	clone.Velocity = clone.CFrame.lookVector.Unit * math.random(150, 250)
	clone.RotVelocity = Vector3.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15))
	clone.CFrame *= CFrame.Angles(
		math.rad((math.random(-180, 180))),
		math.rad((math.random(-180, 180))),
		(math.rad((math.random(-180, 180))))
	)
	local v2 = boatTween:Create(clone, {
		Time = math.random(10, 25) / 10,
		EasingStyle = "Sine",
		EasingDirection = "In",
		StepType = "Heartbeat",
		Reverses = false,
		Goal = {
			Size = createVector(0.1, 0.1, 0.1)
		}
	})
	v2.Completed:Connect(function()
		if clone then
			clone.Anchored = true
			clone.Transparency = 1

			for _, emitter in pairs(clone:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end

		task.delay(1, function()
			if clone then
				clone:Destroy()
			end
		end)
	end)
	v2:Play()
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function decalShockwave(cFrame, p, p2, _, scale, p3)
	task.spawn(function()
		local clone = script.DecWave:Clone()
		debris:AddItem(clone, p2 + 1)
		clone.CFrame = cFrame
		clone.Mesh.Scale = scale
		clone.Parent = _WorldOrigin
		local v = {
			"rbxassetid://13117093477",
			"rbxassetid://13117093094",
			"rbxassetid://13117092741",
			"rbxassetid://13117092522",
			"rbxassetid://13117092280",
			"rbxassetid://13117092086",
			"rbxassetid://13117091790"
		}
		local v2 = 1 / (60 / p2)

		for i = 1, #v do
			local transparency = i / #v
			clone.Mesh.Scale = clone.Mesh.Scale:Lerp(p3, transparency)
			clone.CFrame = clone.CFrame:Lerp(p, transparency)
			clone.Decal.Texture = v[i]
			clone.Decal.Transparency = transparency
			task.wait(v2)
		end

		clone.Decal.Texture = ""

		if clone then
			clone:Destroy()
		end
	end)
end

return function(data)
	if data.ID == 1 then
		local _ = data.Timestamp
		local lifetime = data.Lifetime
		local cFrame = data.CFrame
		local baseSize = data.BaseSize
		local scaler = data.Scaler
		local radius = data.Radius
		local onWater = data.OnWater
		local seed = data.Seed

		if misc.cameraInRange(cFrame.p, 3000) then
			math.randomseed(seed)

			if onWater then
				Effect.new("Leviathan.Splash"):replicate({
					CFrame = cFrame,
					Scale = 1
				})
			end

			local cframe = CFrame.Angles(0, math.rad((math.random(0, 360))), 0)
			local cFrame3 = CFrame.new(cFrame.p + Vector3.new(0, 15 * scaler, 0)) * cframe
			local v2 = CFrame.new(cFrame.p + createVector(0, 0, 0)) * cframe
			Color3.fromRGB(250, 350, 1000)
			decalShockwave(cFrame3, v2, 0.9, nil, createVector(0.2, 3, 0.2) * scaler, createVector(2, 0.6, 2) * scaler) -- equivalent call inferred; original call site unknown
			local cFrame4 = CFrame.new(cFrame.p + Vector3.new(0, 20 * scaler, 0)) * cframe
			local v7 = CFrame.new(cFrame.p + createVector(0, 0, 0)) * cframe
			Color3.fromRGB(150, 250, 1200)
			decalShockwave(cFrame4, v7, 1, nil, createVector(0.2, 5, 0.2) * scaler, createVector(4, 1.2, 4) * scaler) -- equivalent call inferred; original call site unknown
			Util.Sound:Play("IceSummon", cFrame.p, nil, 1.1, 0.4)
			Util.Sound:Play("DragonExplosion", cFrame.p, nil, 0.4, 0.6)
			Util.Sound:Play("IceShoot", cFrame.p, nil, math.random(4, 5), 0.7)
			local v11 = radius * 3.141592653589793 / ((baseSize.X + baseSize.Z) / 2 * 0.95)
			local clone = script.EruptParticles:Clone()
			debris:AddItem(clone, 5)
			clone.Position = cFrame.p
			clone.Size *= scaler
			clone.Parent = _WorldOrigin

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				misc.scaleParticle(emitter, scaler, true)
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			if (workspace.CurrentCamera.CFrame.Position - cFrame.p).Magnitude <= 350 then
				Util.CameraShaker:ShakeOnce(7, 11, 0.45, 0.55)
			end

			if onWater then
				for _ = 1, math.random(5, 7) do
					flyingIceChunk(cFrame.p, createVector(0, 1, 0), scaler)
				end
			end

			task.spawn(function()
				local clone2 = script.ForceParticles:Clone()
				debris:AddItem(clone2, 5)
				clone2.Size *= scaler

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						misc.scaleParticle(emitter, scaler, true)
					end
				end

				clone2.Parent = _WorldOrigin
				clone2.CFrame = cFrame * CFrame.new(0, 25, 0) * CFrame.Angles(-1.5707963267948966, 0, 0)
				clone2.LeftAttach.Puff:Emit(2)
				clone2.RightAttach.Puff:Emit(2)
				local lastTime = os.clock()
				local v12 = 0.016666666666666666

				for _ = 1, 30 do
					if os.clock() - lastTime > 0.01 then
						for _, emitter in pairs(clone2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") and emitter.Name ~= "Puff" then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						lastTime = os.clock()
					end

					clone2.CFrame *= CFrame.new(0, -0.4166 * scaler * v12 * 60, 0)
					v12 = RunService.Heartbeat:Wait()
				end
			end)
			local v12 = partCache.new(script.IceSpike, v11, _WorldOrigin)

			for _, folder in pairs(v12.Open) do
				debris:AddItem(folder, lifetime + 3)

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						misc.scaleParticle(emitter, scaler, true)
					end
				end
			end

			for i = 1, v11 do
				local v13 = math.rad(180 / v11) * (i - 1)
				local v14 = radius * math.random(90, 110) / 100
				local v15 = cFrame * CFrame.new(math.cos(v13) * v14, 0, math.sin(v13) * v14)
				local v16 = math.random(-baseSize.X * 3, baseSize.X * 5) / 10
				local v17 = math.random(-baseSize.X * 3, baseSize.X * 5) / 10
				local size = baseSize + Vector3.new(v16, math.random(0, baseSize.Y * 6) / 10, v17)
				local part = v12:GetPart()
				local v19 = math.rad((math.random(10, 50)))
				local v20 = size.X * math.tan(1.5707963267948966 - v19)
				part.CFrame = v15 * CFrame.Angles(v19, 0, 0) * CFrame.Angles(
					0,
					0,
					i < v11 / 2 and -v13 / 10 or v13 / 10
				) - Vector3.new(0, v20, 0)
				local cFrame2 = part.CFrame
				local v21 = size.Y / 2

				if i % 2 == 1 then
					local clone2 = script.IcePatch:Clone()
					debris:AddItem(clone2, lifetime + 3)
					local size2 = createVector(20, 4.5, 20) * Vector3.new(baseSize.X / 8.5, 1, baseSize.Z / 8.5)
					clone2.Size = createVector(1, 1, 1)
					clone2.CFrame = CFrame.new(v15.p) * CFrame.Angles(0, math.rad((math.random(0, 360))), 0)
					clone2.Parent = _WorldOrigin
					local v23 = boatTween:Create(clone2, {
						Time = math.random(15, 25) / 100,
						EasingStyle = "Sine",
						EasingDirection = "Out",
						StepType = "Heartbeat",
						Reverses = false,
						Goal = {
							Size = size2,
							Color = Color3.fromRGB(121, 161, 168)
						}
					})
					v23.Completed:Connect(function()
						task.delay(lifetime - 1, function()
							if clone2 then
								local v25 = boatTween:Create(clone2, {
									Time = math.random(5, 10) / 10,
									EasingStyle = "Sine",
									EasingDirection = "In",
									StepType = "Heartbeat",
									Reverses = false,
									Goal = {
										Size = createVector(1, 1, 1),
										Color = Color3.fromRGB(90, 120, 125)
									}
								})
								v25.Completed:Connect(function()
									if clone2 then
										clone2:Destroy()
									end

									v25 = nil
								end)
								v25:Play()
							end
						end)
					end)
					v23:Play()
				end

				local v22 = boatTween:Create(part, {
					Time = math.random(30, 45) / 100,
					EasingStyle = "Sine",
					EasingDirection = "Out",
					StepType = "Heartbeat",
					Reverses = false,
					Goal = {
						Size = size,
						CFrame = cFrame2 * CFrame.new(0, v21, 0),
						Color = Color3.fromRGB(121, 161, 168)
					}
				})
				v22.Completed:Connect(function()
					task.delay(lifetime - 1, function()
						if part then
							local v27 = boatTween:Create(part, {
								Time = math.random(5, 10) / 10,
								EasingStyle = "Sine",
								EasingDirection = "In",
								StepType = "Heartbeat",
								Reverses = false,
								Goal = {
									Size = Vector3.new(v16, 0.1, v17),
									CFrame = cFrame2,
									Color = Color3.fromRGB(96, 129, 134)
								}
							})
							v27.Completed:Connect(function()
								if part then
									part:Destroy()
								end

								v27 = nil
							end)
							v27:Play()
						end
					end)
				end)
				v22:Play()

				for _, emitter in pairs(part:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end

			task.delay(lifetime, function()
				if v12 then
					v12:Dispose()
				end
			end)
		end
	end
end