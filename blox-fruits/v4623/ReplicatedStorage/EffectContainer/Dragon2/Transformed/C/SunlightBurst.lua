local RunService = game:GetService("RunService")
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local sunlightBurst = FX:WaitForChild("Dragon2").Transformed.C.SunlightBurst
Util.ResizeModel(sunlightBurst.Sunlight, 24, sunlightBurst.Sunlight.Position)
Util.ResizeModel(sunlightBurst.StarOrbModel.StarOrbSmall, 24, sunlightBurst.StarOrbModel.StarOrbSmall.Position)
return function(p, value, p2, p3, p4, p5)
	local clone = sunlightBurst.Sunlight:Clone()
	local v = {}
	local v2 = value or 12.5

	for _, emitter in pairs(clone.Sol:GetDescendants()) do
		if not (emitter:IsA("ParticleEmitter") and emitter.Name ~= "Glow" and emitter.Name ~= "Bubble_Impulse" and emitter.Parent ~= clone.Attachment) then
			continue
		end

		local numberSequenceKeypoints = {}

		for _, keypoint in pairs(emitter.Transparency.Keypoints) do
			table.insert(
				numberSequenceKeypoints,
				NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value ^ 0.25, keypoint.Envelope)
			)
		end

		emitter.Transparency = NumberSequence.new(numberSequenceKeypoints)
		v[emitter] = emitter.Transparency
	end

	clone.Point.Glow.Enabled = false
	local clones = { clone.Point }

	for i = 1, 9 do
		local clone2 = clone.Point:Clone()

		if i == 2 then
			local color3Constructor = Util.WrapColor3Constructor(
				Color3.fromRGB(255, 142, 97),
				p5,
				"DragonFruitVFXColor"
			)
			clone2.Glow.Color = ColorSequence.new(color3Constructor, color3Constructor)
		elseif i == 3 then
			local color3Constructor = Util.WrapColor3Constructor(
				Color3.fromRGB(194, 255, 115),
				p5,
				"DragonFruitVFXColor"
			)
			clone2.Glow.Color = ColorSequence.new(color3Constructor, color3Constructor)
		elseif i == 4 then
			local color3Constructor = Util.WrapColor3Constructor(
				Color3.fromRGB(138, 255, 251),
				p5,
				"DragonFruitVFXColor"
			)
			clone2.Glow.Color = ColorSequence.new(color3Constructor, color3Constructor)
		elseif i == 5 then
			local color3Constructor = Util.WrapColor3Constructor(
				Color3.fromRGB(134, 134, 255),
				p5,
				"DragonFruitVFXColor"
			)
			clone2.Glow.Color = ColorSequence.new(color3Constructor, color3Constructor)
		elseif i == 6 then
			local color3Constructor = Util.WrapColor3Constructor(
				Color3.fromRGB(204, 133, 255),
				p5,
				"DragonFruitVFXColor"
			)
			clone2.Glow.Color = ColorSequence.new(color3Constructor, color3Constructor)
		elseif i == 7 then
			local color3Constructor = Util.WrapColor3Constructor(
				Color3.fromRGB(255, 128, 234),
				p5,
				"DragonFruitVFXColor"
			)
			clone2.Glow.Color = ColorSequence.new(color3Constructor, color3Constructor)
		elseif i == 8 then
			local color3Constructor = Util.WrapColor3Constructor(
				Color3.fromRGB(255, 112, 162),
				p5,
				"DragonFruitVFXColor"
			)
			clone2.Glow.Color = ColorSequence.new(color3Constructor, color3Constructor)
		elseif i == 9 then
			local color3Constructor = Util.WrapColor3Constructor(
				Color3.fromRGB(255, 115, 124),
				p5,
				"DragonFruitVFXColor"
			)
			clone2.Glow.Color = ColorSequence.new(color3Constructor, color3Constructor)
		end

		Util.SetParentOverrideWithColor(clone2, clone, p5, "DragonFruitVFXColor")
		table.insert(clones, clone2)
	end

	Util.SetParentOverrideWithColor(clone, p2, p5, "DragonFruitVFXColor")
	local clone2 = nil
	local starOrbSmall = nil
	task.spawn(function()
		clone2 = sunlightBurst.StarOrbModel:Clone()
		starOrbSmall = clone2.StarOrbSmall
		starOrbSmall.CFrame = clone.CFrame
		starOrbSmall.Anchored = false
		Util.SetParentOverrideWithColor(clone2, p2, p5, "DragonFruitVFXColor")
		starOrbSmall.Weld.Part1 = clone
		task.spawn(function()
			return clone2
		end)

		for _, emitter in pairs(starOrbSmall:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			emitter.LockedToPart = true
			emitter:Emit(1)

			if not emitter:GetAttribute("Purple") then
				continue
			end

			local v3 = emitter
			task.delay(2.75, function()
				local color3Constructor = Util.WrapColor3Constructor(
					Color3.fromRGB(255, 93, 29),
					p5,
					"DragonFruitVFXColor"
				)

				for i = 1, 10 do
					local lerped = color3Constructor:Lerp(
						Util.WrapColor3Constructor(Color3.fromRGB(102, 56, 255), p5, "DragonFruitVFXColor"),
						i / 10
					)
					v3.Color = ColorSequence.new(lerped, lerped)
					task.wait(0.075)
				end
			end)
		end

		local TweenService = game:GetService("TweenService")
		TweenService:Create(p4, TweenInfo.new(p3 + 1, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut), {
			Value = 1
		}):Play()
		local v3 = tick() + p3 - 0.05

		repeat
			clone2:ScaleTo(p4.Value)
			task.wait()
		until v3 - tick() <= 0

		for _, emitter in pairs(starOrbSmall:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)

	for _, v3 in pairs(clones) do
		v3.Glow.Lifetime = NumberRange.new(6)
		v3.Glow:Emit(1)
		v3.Glow.Rate = 0
	end

	clone.Sol:GetChildren()
	local lastTime = tick()
	local v3 = p3 + tick()
	task.spawn(function()
		clone.Attachment.Particle_1.Enabled = false
		clone.Attachment.Particle_2.Enabled = false
		clone.Attachment.Particle_3.Enabled = false
		clone.Attachment.Particle_4.Enabled = false
		clone.Attachment.Particle_5.Enabled = false
		clone.Attachment.Particle_6.Enabled = false
		clone.Attachment.Particle_7.Enabled = false
		clone.Attachment.Particle_8.Enabled = false

		while true do
			local v4 = (tick() - lastTime) / 6

			if v4 > 1 then
				break
			end

			local v5 = math.min(v4 / 0.05)
			local TweenService = game:GetService("TweenService")
			local v6 = 1 - TweenService:GetValue(v5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

			if v3 - tick() <= 0 then
				v3 = tick() + 100000000000

				for _, emitter in pairs(clone.Sol:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.spawn(function()
					task.wait(0.15)

					for i = 1, 8 do
						clone.Attachment["Particle_" .. i].ZOffset += 15
						clone.Attachment["Particle_" .. i]:Emit(1)
					end
				end)
			end

			local v7 = v2
			local magnitude = (workspace.CurrentCamera.CFrame.p - p).Magnitude

			if v2 < magnitude then
				v7 = v2 + (magnitude - v2) * 0.05
			end

			clone.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.p, p) * CFrame.new(0, 0, -v7 - 900 * v6)
			starOrbSmall.CFrame = clone.CFrame * CFrame.new(0, 0, -0.5)

			for k, v8 in pairs(clones) do
				local v9 = math.min(1, (v4 / 0.8) ^ 0.4)

				if k > 5 then
					v9 *= -1
					k -= 5
				end

				local v10 = 50 * (k / 5 + k % 2 + k % 3) / 2
				v8.Glow.Size = NumberSequence.new(v10, v10)
				v8.WorldCFrame = clone.CFrame * CFrame.new(k * (150 + v10) * v9, k * (50 + v10 / 2) * v9, 0)
			end

			RunService.PreRender:Wait()
		end

		task.wait(1)
		clone:Destroy()
	end)
end