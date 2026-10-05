local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Util = require(game.ReplicatedStorage.Util)
local _ = workspace.CurrentCamera
local _WorldOrigin = workspace:FindFirstChild("_WorldOrigin")
local FX = require(game.ReplicatedStorage.FX)
local effects = FX:WaitForChild("Dragon2").Misc.GroundTrail.Effects
local floorFire = effects.FloorFire
local floorTrail = effects.FloorTrail
local floorMark = effects.FloorMark
return function(data)
	local anchor = data.Anchor
	local width = data.Width or 10
	local lifetime = data.Lifetime or 1
	local duration = data.Duration or 10
	local player = data.player
	local clone = floorFire:Clone()
	local clone2 = floorTrail:Clone()
	local clone3 = floorMark:Clone()
	local v = typeof(width) ~= "Instance" and 10 or width:GetAttribute("Width") or 10
	local v2 = 0
	local v3 = {
		Particles = {},
		Attachments = {}
	}

	for _, descendant in pairs(clone2:GetDescendants()) do
		if descendant:IsA("Trail") then
			descendant.Lifetime *= lifetime
			v2 = math.max(v2, descendant.Lifetime)
		end

		if not descendant:IsA("Attachment") then
			continue
		end

		v3.Attachments[descendant] = {
			Position = descendant.Position
		}
		descendant.Position = v3.Attachments[descendant].Position * Vector3.new(v / 5, 1, 1)
	end

	for _, emitter in pairs(clone3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		v3.Particles[emitter] = {
			Size = emitter.Size.Keypoints,
			Speed = emitter.Speed,
			Acceleration = emitter.Acceleration
		}
		emitter.Enabled = false
	end

	Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "DragonFruitVFXColor")
	local position = anchor.Position
	local position2 = anchor.Position
	local now = tick()
	local v5 = 0

	while true do
		local now2 = tick()
		local v6 = now2 - now
		local position3 = anchor.Position
		local width2 = typeof(width) == "Instance" and width:GetAttribute("Width") or 10
		local magnitude = (position2 - position3).Magnitude
		local _ = (position - position3).Magnitude
		local v7, flag

		if math.min(100, width2 * 2) <= magnitude then
			v7 = position3
			flag = true
		else
			v7 = position2
			flag = false
		end

		local rayMap, v8, v9 = Util.RayMap(position3, createVector(-0, -1, -0) * width2 * 3)

		if typeof(anchor) == "Instance" and not rayMap then
			rayMap, v8, v9 = Util.RayMap(position3, anchor.CFrame.LookVector * width2 * 2)
		end

		if rayMap then
			local cFrame = Util.Misc.AlignCFrame(CFrame.new(v8, position2), v9) + v9 * 1

			for k, particle in pairs(v3.Particles) do
				Util.Misc.ScaleParticle(k, 1.5 * width2 / 5, particle)
				k.Enabled = true
			end

			for k, attachment in pairs(v3.Attachments) do
				k.Position = attachment.Position * Vector3.new(width2 / 5, 1, 1)
			end

			clone2.CFrame = cFrame
			clone3.CFrame = cFrame

			if flag then
				local clone4 = clone:Clone()
				clone4.Size = Vector3.new(width2, 1, magnitude)
				clone4.CFrame = cFrame * CFrame.new(0, 0, -magnitude / 2)
				local v11 = 0

				for _, emitter in pairs(clone4:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter.ZOffset *= width2 / 5
					Util.Misc.ScaleParticle(emitter, width2 / 5)
					v11 = math.max(v11, emitter.Lifetime.Max)
				end

				Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "DragonFruitVFXColor")

				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit((math.floor(emitter.Rate * 1 / 8)))
					end
				end

				local size = clone4.Size
				TweenService:Create(
					clone4,
					TweenInfo.new(v11 + v2 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Size = size * createVector(0, 1, 1)
					}
				):Play()
				local folder = clone4
				task.delay(v2 * 0.75, function()
					for i, emitter in pairs(folder:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					task.wait(v11)
					folder:Destroy()
				end)
				v5 = now2
			end
		else
			for k, _ in pairs(v3.Particles) do
				k.Enabled = false
			end
		end

		if v2 < now2 - v5 then
			Util.SetParentOverrideWithColor(clone2, nil, player, "DragonFruitVFXColor")
		else
			Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "DragonFruitVFXColor")
		end

		if typeof(duration) == "number" then
			if not (duration < v6) then
				RunService.RenderStepped:Wait()
				position = position3
				position2 = v7
				continue
			end
		elseif anchor:IsDescendantOf(workspace) and not (anchor:GetAttribute("Destroy") or v6 > 60) then
			RunService.RenderStepped:Wait()
			position = position3
			position2 = v7
			continue
		end

		task.wait(v2 - 0)

		for k, _ in pairs(v3.Particles) do
			k.Enabled = false
		end

		Util.Debris:AddItem(clone3, 1)
		Util.Debris:AddItem(clone2, v2 + 1)
		local _ = {
			Particles = {},
			Attachments = {}
		}
		break
	end
end