local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = workspace.CurrentCamera
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local _ = Util.Sound
local doughShockwavesSlash = Effect.new("Dough.Shockwaves.Slash")
local spiral = Effect.new("Spiral")
local ringWind = Effect.new("RingWind")
return function(data)
	local origin = data.Origin
	local position = data.Position
	local cframe = CFrame.new(origin, position)
	Util.Sound:Play("WhipStrong", cframe)
	Util.Sound:Play("Mera_FlameStartup", cframe)
	Util.Sound:Play("Mera_FireFistExplosion2", cframe)
	local v = {}

	for i = 1, 5 do
		local v2 = i / 5 * 3.141592653589793 * 2
		local clone = FX:WaitForChild("String"):Clone()
		local attachment = Instance.new("Attachment")
		attachment.CFrame = cframe * CFrame.Angles(0, v2, 0)
		attachment.Parent = workspace.Terrain
		local clone2 = attachment:Clone()
		clone2.CFrame = cframe * CFrame.Angles(0, v2, 0)
		clone2.Parent = workspace.Terrain
		clone.Width0 = 0.35
		clone.Width1 = 0.35
		clone.Parent = workspace.Terrain
		clone.Attachment0 = attachment
		clone.Attachment1 = clone2
		table.insert(v, {
			clone,
			attachment,
			clone2,
			v2
		})
	end

	local v2 = (origin - position).magnitude + 1
	local clone = script.stringline:Clone()
	clone.CFrame = cframe * CFrame.Angles(-1.5707963267948966, 0, 0)
	clone.Parent = workspace._WorldOrigin
	Util.Debris:AddItem(clone, 5)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter.Rate * 0.3)
		end
	end

	spiral:replicate({
		CFrame = cframe * CFrame.Angles(-1.5707963267948966, 0, 0),
		Duration = 1,
		Width = 0.07,
		Cycles = 2,
		Length = { 0, 12 },
		Radius = { 2, 4 },
		Direction = 1
	})
	spiral:replicate({
		CFrame = cframe * CFrame.Angles(-1.5707963267948966, 0, 0),
		Duration = 1,
		Width = 0.07,
		Cycles = 1.5,
		Length = { 0, 8 },
		Radius = { 4, 6 },
		Direction = -1
	})
	spiral:replicate({
		CFrame = cframe * CFrame.Angles(-1.5707963267948966, 0, 0),
		Duration = 1,
		Width = 0.07,
		Cycles = 1.75,
		Length = { 0, 20 },
		Radius = { 1, 3 },
		Direction = -1
	})
	ringWind:replicate({
		CFrame = cframe,
		Duration = 0.3,
		Radius = { 0, 25 }
	})
	task.spawn(function()
		for i = 0, 2 do
			local clone2 = game.ReplicatedStorage.Assets.Models.Crown1:Clone()
			clone2.Anchored = true
			clone2.Size = Vector3.new(i * 4 + 6, 4 - i * 1, i * 4 + 6) * 2
			clone2.Color = Color3.new(1, 0.6, 0):Lerp(Color3.new(1, 1, 1), i / 2)
			clone2.CFrame = cframe * CFrame.new(0, 0, i * 8 * 1 / 2) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Parent = workspace._WorldOrigin
			Util.ReplicatedTween:Create(clone2, TweenInfo.new(i * 0.15 + 0.3), {
				Transparency = 1,
				Size = Vector3.new(24 - i * 8, i * 8 + 4, 24 - i * 8)
			}):Play()
			task.delay(i * 0.15 + 0.3, function()
				clone2:Destroy()
			end)
		end
	end)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CFrame = cframe
	part.Size = createVector(1, 1, 1)
	part.Color = Color3.fromRGB(255, 85, 0)
	part.Transparency = 0
	part.Material = "Neon"
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = "Sphere"
	specialMesh.Scale = createVector(14, 14, 0)
	specialMesh.Parent = part
	part.Parent = workspace._WorldOrigin
	local duration = data.Duration or 1
	Util.Debris:AddItem(part, duration + 0.3)
	Util.ReplicatedTween:Create(specialMesh, TweenInfo.new((duration + 0.3) * 0.7), {
		Scale = Vector3.new(0, 0, v2),
		Offset = Vector3.new(0, 0, -v2 / 2)
	}):Play()
	Util.ReplicatedTween:Create(part, TweenInfo.new((duration + 0.3) * 0.7), {
		Color = Color3.new(1, 1, 1),
		Transparency = 1
	}):Play()
	local _ = v2 * duration
	local lastTime = tick()
	local lastTime2 = tick()
	local total = 0
	local total2 = 0

	while tick() - lastTime < duration do
		local _ = tick() - lastTime2
		local v3 = math.min(1, (tick() - lastTime) / duration)
		local v4 = v3 * v2
		local v5 = v3 ^ 1.6

		for i = 1, #v do
			local v6 = v[i]
			v6[2].CFrame = cframe * CFrame.Angles(0, 0, v6[4] + v3)
			v6[3].CFrame = cframe * CFrame.new(0, 0, -v4) * CFrame.Angles(0, 0, v6[4] + v3)
			v6[1].Color = ColorSequence.new(Color3.fromRGB(255, v5 * 170 + 85, v5 * 255))

			if not (v3 > 0.7) then
				continue
			end

			local v7 = ((v3 - 0.7) / 0.3) ^ 0.75
			v6[1].Width0 = (1 - v7) * 0.35
			v6[1].Width1 = v6[1].Width0
			v6[1].CurveSize0 = v7 * 50
			v6[1].CurveSize1 = v7 * 50
			v6[1].LightEmission = (1 - v7) * 0.75
		end

		local v6 = math.sin(3.141592653589793 * v3)

		if total <= v3 then
			ringWind:replicate({
				CFrame = cframe * CFrame.new(0, 0, -v2 / 2 * total),
				Color = Color3.fromRGB(255, v5 * 170 + 85, v5 * 255),
				Duration = 0.4,
				Radius = { 0, v6 * 10 + 24 }
			})
			total += 0.1
		end

		if total2 <= v3 then
			doughShockwavesSlash:replicate({
				CFrame = cframe * CFrame.new(0, 0, -v2 * v3 * 1.1) * CFrame.Angles(-1.5707963267948966, 0, 0),
				Color = Color3.fromRGB(255, v5 * 170 + 85, v5 * 255),
				Brightness = 2,
				Transparency = 0,
				VectorOffset = cframe.LookVector * v2 / 2 * 1 / 10,
				RotationSpeed = v6 * 2 + 1,
				Scale = { Vector3.new(v6 * 4 + 9, v2 / 6, v6 * 4 + 9), (Vector3.new(4, v2 / 2, 4)) },
				Duration = 0.6,
				Ease = { "out", "quad" }
			})
			total2 += 0.05
		end

		lastTime2 = tick()
		local RunService = game:GetService("RunService")
		RunService.RenderStepped:Wait()
	end

	for _, v3 in next, v, nil do
		v3[1]:Destroy()
		v3[2]:Destroy()
		v3[3]:Destroy()
	end
end