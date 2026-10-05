local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
local script2 = script
local volcanoRock = script2.VolcanoRock
local volcanoCrater = script2.VolcanoCrater

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

local function shoot(data)
	local startPosition = data.StartPosition
	local endPosition = data.EndPosition
	local duration = data.Duration or 4
	local craterAnywhere = data.CraterAnywhere
	local scale = data.Scale
	local v = scale or 1.75 + math.random() * 0.25
	local v2 = scale or 1.75
	local v3 = math.min(v2 / 1.75, 1)
	local arcScale = data.ArcScale or 1
	local simpleArc = data.SimpleArc
	local shakeDistance = data.ShakeDistance or 1500
	local shakeDistance2 = data.ShakeDistance or 200
	local soundRadius = data.SoundRadius

	if (workspace.CurrentCamera.CFrame.p - startPosition).Magnitude > 2500 then
		return
	end

	if (workspace.CurrentCamera.CFrame.p - startPosition).Magnitude < shakeDistance then
		Util.CameraShaker:ShakeOnce(v3 * 6, 8, 0.05, duration * 0.666)
	end

	local cframe = CFrame.new(startPosition, endPosition)
	Util.Sound:Play("Mera_FireFistLaunch", cframe, soundRadius or 60, 0.6)
	local model = Instance.new("Model", _WorldOrigin)
	local clone = volcanoRock:Clone()
	clone.CFrame = cframe
	clone.Parent = model
	model:ScaleTo(v)
	Util.Sound:Play("TrialSounds.BF_Trial_Rock_Falling_Loop_01", clone, soundRadius)
	local v4 = (startPosition - endPosition).Magnitude * 1.2 * arcScale
	local v5, v6

	if not simpleArc then
		local v7 = (startPosition - endPosition) / 2
		local position = CFrame.new(CFrame.new(startPosition) * (v7 / -1.5)).Position
		local position2 = CFrame.new(CFrame.new(endPosition) * (v7 / 1.5)).Position
		local v8 = math.random(-100, 100)
		local v9 = math.random(-100, 100)
		v5 = position + Vector3.new(v8, v4, v9)
		v6 = position2 + Vector3.new(v8, v4 / 1.2, v9)
	end

	local v7 = endPosition - startPosition
	local v8 = v4 * 0.6875
	local lastTime = tick()

	while tick() - lastTime < duration do
		local v9 = (tick() - lastTime) / duration

		if simpleArc then
			local v10 = startPosition:Lerp(endPosition, v9) + Vector3.new(0, 4 * v8 * v9 * (1 - v9), 0)
			local v11 = v7 + Vector3.new(0, 4 * v8 * (1 - 2 * v9), 0)
			local v12 = not (v11.Magnitude > 0.001) and createVector(0, 1, 0) or v11
			clone.CFrame = CFrame.new(v10, v10 + v12) * CFrame.Angles(0, 0, v9 * 8)
		else
			local v10 = cubicBezier(v9, startPosition, v5, v6, endPosition)
			clone.CFrame = clone.CFrame:Lerp(CFrame.new(v10, endPosition) * CFrame.Angles(0, 0, v9 * 8), v9)
		end

		task.wait()
	end

	clone.Transparency = 1

	for _, emitter in pairs(clone.Projectile:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	local v9, v10, v11

	if craterAnywhere then
		local v12 = { workspace.Enemies, workspace.Characters }
		v9, v10, v11 = Util.Ray(endPosition + createVector(0, 60, 0), createVector(-0, -400, -0), v12)
	else
		local ray = Ray.new(endPosition + createVector(0, 1, 0), createVector(-0, -10, -0))
		local prehistoricIsland = workspace.Map:FindFirstChild("PrehistoricIsland")
		local rockLandingZone = prehistoricIsland and prehistoricIsland.Core.RockLandingZone
		v9, v10, v11 = workspace:FindPartOnRayWithWhitelist(ray, { rockLandingZone }, true)
	end

	if v9 then
		if (workspace.CurrentCamera.CFrame.p - v10).Magnitude < shakeDistance2 then
			Util.CameraShaker:ShakeOnce(v3 * 8, 10, 0.1, 2, createVector(1, 1, 1), createVector(1, 1, 3))
		end

		local cFrame = CFrame.new(v10, v10 + v11) * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone.CFrame = cFrame

		for _, emitter in pairs(clone.Boom:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end

		Util.Sound:Play("BF_Trial_Rock_Fall_Impact_0" .. tostring(math.random(1, 4)), v10, soundRadius)
		local v13 = 30 * v2
		local v14 = cFrame * CFrame.new(0, 1, 0)
		local clone2 = volcanoCrater:Clone()
		clone2.CFrame = v14 * CFrame.Angles(0, 0, 1.5707963267948966)
		clone2.At0.Position = Vector3.new(0, 0, v13) / 6
		clone2.At1.Position = Vector3.new(0, 0, -v13) / 6
		clone2.Beam.Width0 = v13 * 2 / 6
		clone2.Beam.Width1 = v13 * 2 / 6
		clone2.Beam.Brightness = 3.333
		clone2.Parent = _WorldOrigin
		task.spawn(function()
			local lastTime2 = tick()

			while tick() - lastTime2 < 0.15 do
				local v15 = (tick() - lastTime2) / 0.15
				clone2.At0.Position = Vector3.new(0, 0, v13 - v13 / 6 * (1 - v15))
				clone2.At1.Position = Vector3.new(0, 0, -(v13 - v13 / 6 * (1 - v15)))
				clone2.Beam.Width0 = v13 * 2 - v13 * 2 / 6 * (1 - v15)
				clone2.Beam.Width1 = v13 * 2 - v13 * 2 / 6 * (1 - v15)
				task.wait()
			end

			task.wait(0.25)
			local lastTime3 = tick()

			while tick() - lastTime3 < 3 do
				local v15 = (tick() - lastTime3) / 3

				if v15 > 0.333 then
					clone2.Beam.Transparency = NumberSequence.new(0.333 + 0.666 * ((v15 - 0.333) / 0.666))
				else
					clone2.Beam.Brightness = 3.333 * (1 - v15 / 0.333) ^ 1.666
					clone2.Beam.Transparency = NumberSequence.new(v15 / 0.333 * 0.333)
				end

				task.wait()
			end

			clone2:Destroy()
		end)
	end

	task.wait(5)
	model:Destroy()
end

local function eruption(startPosition, endPosition)
	local DISTANCE_THRESHOLD = 2000

	if (workspace.CurrentCamera.CFrame.p - startPosition).Magnitude > 3000 then
		return
	end

	local flag = true
	task.delay(5, function()
		flag = false
	end)
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
	local tween = TweenService:Create(colorCorrectionEffect, TweenInfo.new(2), {
		TintColor = Color3.fromRGB(255, 125, 0)
	})
	tween.Completed:Connect(function()
		local tween2 = TweenService:Create(colorCorrectionEffect, TweenInfo.new(13), {
			Contrast = 1
		})
		tween2.Completed:Connect(function()
			local tween3 = TweenService:Create(colorCorrectionEffect, TweenInfo.new(2), {
				TintColor = Color3.fromRGB(255, 255, 255),
				Contrast = 0
			})
			tween3.Completed:Connect(function()
				colorCorrectionEffect:Destroy()
			end)
			tween3:Play()
		end)
		tween2:Play()
	end)
	tween:Play()
	local bloomEffect = Instance.new("BloomEffect", game.Lighting)
	local tween2 = TweenService:Create(bloomEffect, TweenInfo.new(2), {
		Threshold = 0.2
	})
	tween2.Completed:Connect(function()
		task.wait(15)
		local tween3 = TweenService:Create(bloomEffect, TweenInfo.new(2), {
			Threshold = 2
		})
		tween3.Completed:Connect(function()
			bloomEffect:Destroy()
		end)
		tween3:Play()
	end)
	tween2:Play()
	local v = Util.Sound:Play("VolcanoAmbience", startPosition, 300)

	while flag do
		if (workspace.CurrentCamera.CFrame.p - startPosition).Magnitude < DISTANCE_THRESHOLD then
			Util.CameraShaker:ShakeOnce(3, 4, 0.1, 2)
		end

		wait(0.25)
	end

	for i = 1, 25 do
		task.wait(0.1)

		if (workspace.CurrentCamera.CFrame.p - startPosition).Magnitude < DISTANCE_THRESHOLD then
			Util.CameraShaker:ShakeOnce(6, 8, 0.05, 4)
		end

		Util.Sound:Play("Mera_FireFistLaunch", startPosition, 60)
		local v2 = i
		task.spawn(function()
			local ray = Util.Ray
			local v3 = endPosition + Vector3.new(math.random(-250, 250), 500, math.random(-250, 250)) * 2
			local v4 = { workspace.Enemies, workspace.Characters }
			local v5, v6, v7 = ray(v3, createVector(-0, -2000, -0), v4)
			local v8 = v2 / 25 * 2 + 4
			local cframe = CFrame.new(startPosition, v6)
			local model = Instance.new("Model", _WorldOrigin)
			local clone = volcanoRock:Clone()
			clone.CFrame = cframe
			clone.Parent = model
			model:ScaleTo(1.75 + math.random() * 0.25)
			local v9 = (startPosition - v6).Magnitude * (1.6 + math.random() * 0.6)
			local v10 = (startPosition - v6) / 2
			local position = CFrame.new(CFrame.new(startPosition) * (v10 / -1.5)).Position
			local position2 = CFrame.new(CFrame.new(v6) * (v10 / 1.5)).Position
			local v11 = math.random(-100, 100)
			local v12 = math.random(-100, 100)
			local v13 = position + Vector3.new(v11, v9, v12)
			local v14 = position2 + Vector3.new(v11, v9 / 1.2, v12)
			local lastTime = tick()

			while tick() - lastTime < v8 do
				local v15 = (tick() - lastTime) / v8
				local v16 = cubicBezier(v15, startPosition, v13, v14, v6)
				clone.CFrame = clone.CFrame:Lerp(CFrame.new(v16, v6) * CFrame.Angles(0, 0, v15 * 8), v15)
				task.wait()
			end

			clone.Transparency = 1

			for i2, emitter in pairs(clone.Projectile:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			if v5 then
				if (workspace.CurrentCamera.CFrame.p - v6).Magnitude < 150 then
					Util.CameraShaker:ShakeOnce(8, 10, 0.1, 2, createVector(1, 1, 1), createVector(1, 1, 3))
				end

				local cFrame = CFrame.new(v6, v6 + v7) * CFrame.Angles(-1.5707963267948966, 0, 0)
				clone.CFrame = cFrame

				for i2, emitter in pairs(clone.Boom:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
					end
				end

				Util.Sound:Play("Mera_FireFistExplosion", v6, 80)
				local v16 = cFrame * CFrame.new(0, 1, 0)
				local clone2 = volcanoCrater:Clone()
				clone2.CFrame = v16 * CFrame.Angles(0, 0, 1.5707963267948966)
				clone2.At0.Position = createVector(0, 0, 8.75)
				clone2.At1.Position = createVector(0, 0, -8.75)
				clone2.Beam.Width0 = 17.5
				clone2.Beam.Width1 = 17.5
				clone2.Beam.Brightness = 3.333
				clone2.Parent = _WorldOrigin
				task.spawn(function()
					local lastTime2 = tick()

					while tick() - lastTime2 < 0.15 do
						local v17 = (tick() - lastTime2) / 0.15
						clone2.At0.Position = Vector3.new(0, 0, 52.5 - 8.75 * (1 - v17))
						clone2.At1.Position = Vector3.new(0, 0, -(52.5 - 8.75 * (1 - v17)))
						clone2.Beam.Width0 = 105 - 17.5 * (1 - v17)
						clone2.Beam.Width1 = 105 - 17.5 * (1 - v17)
						task.wait()
					end

					task.wait(0.25)
					local lastTime3 = tick()

					while tick() - lastTime3 < 3 do
						local v17 = (tick() - lastTime3) / 3

						if v17 > 0.333 then
							clone2.Beam.Transparency = NumberSequence.new(0.333 + 0.666 * ((v17 - 0.333) / 0.666))
						else
							clone2.Beam.Brightness = 3.333 * (1 - v17 / 0.333) ^ 1.666
							clone2.Beam.Transparency = NumberSequence.new(v17 / 0.333 * 0.333)
						end

						task.wait()
					end

					clone2:Destroy()
				end)
			end

			task.wait(5)
			model:Destroy()
		end)
	end

	for _ = 1, 15 do
		if (workspace.CurrentCamera.CFrame.p - startPosition).Magnitude < DISTANCE_THRESHOLD then
			Util.CameraShaker:ShakeOnce(6, 8, 0.05, 4)
		end

		task.wait(0.4)
	end

	Util.Sound:FadeOut(v, 2)
end

return function(data)
	if data.Mode == "Shoot" then
		shoot(data)
	elseif data.Mode == "Eruption" then
		eruption(data.StartPosition, data.EndPosition)
	end
end