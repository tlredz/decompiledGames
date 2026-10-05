local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local doughShockwavesSlash = Effect.new("Dough.Shockwaves.Slash")
local ringWind = Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local _ = Util.Sound
local currentCamera = workspace.CurrentCamera
return function(p)
	local cFrame = p.CFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 500 then
		return
	end

	Util.Sound:Play("WhipQuick", cFrame)
	Util.Sound:Play("StringShot", cFrame, nil, 0.75)

	if (currentCamera.CFrame.p - cFrame.p).Magnitude < 200 then
		local v = 1 - (currentCamera.CFrame.p - cFrame.p).Magnitude / 200
		Effect.new("ShakeCam"):replicate({
			Preset = "Explosion",
			Power = 0.25 + v * 0.5
		})
	end

	local v = {}

	for i = 1, 6 do
		local v2 = CFrame.new((math.random() - 0.5) * i * 2, 0, (math.random() - 0.5) * i * 2) * CFrame.Angles(
			0,
			math.random() * 3.141592653589793 * 2,
			0
		)
		local clone = FX:WaitForChild("String"):Clone()
		clone.Segments = 80
		clone.Color = ColorSequence.new(Color3.new(1, 1, 1))
		local attachment = Instance.new("Attachment")
		attachment.CFrame = cFrame * v2
		attachment.Parent = workspace.Terrain
		local clone2 = attachment:Clone()
		clone2.CFrame = cFrame * v2
		clone2.Parent = workspace.Terrain
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

	ringWind:replicate({
		Offset = cFrame.UpVector * 50 / 2,
		CFrame = cFrame * CFrame.new(0, -8.333333333333334, 0) * CFrame.new(0, 6, 0) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		),
		Duration = 0.4,
		Transparency = { 0.5, 1 },
		Radius = { 0, 30 }
	})
	ringWind:replicate({
		Offset = cFrame.UpVector * 50 / 2,
		CFrame = cFrame * CFrame.new(0, -8.333333333333334, 0) * CFrame.new() * CFrame.new(0, 12, 0) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		),
		Duration = 0.3,
		Transparency = { 0.5, 1 },
		Radius = { 0, 40 }
	})
	ringWind:replicate({
		Offset = cFrame.UpVector * 50 / 2,
		CFrame = cFrame * CFrame.new(0, -8.333333333333334, 0) * CFrame.new() * CFrame.new(0, 18, 0) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		),
		Duration = 0.2,
		Transparency = { 0.5, 1 },
		Radius = { 0, 60 }
	})
	task.spawn(function()
		for i = 1, 4 do
			local v2 = i / 4
			local v5 = math.sin(3.141592653589793 * v2)
			doughShockwavesSlash:replicate({
				CFrame = cFrame * CFrame.new(0, (5 - i) * 2, 0) * CFrame.new(0, v2 * 50, 0),
				Color = Color3.new(1, 1, 1),
				Brightness = 4,
				Transparency = 0.5,
				VectorOffset = -cFrame.UpVector * 50 * 6 * 1 / 10,
				RotationSpeed = v5 * 2 + 2,
				Scale = { Vector3.new(v2 * 6 + 12, 4.166666666666667, v2 * 6 + 12), createVector(0, 150, 0) },
				Duration = (1 - v2) * 0.1 + 0.15,
				Ease = { "out", "quad" }
			})
		end
	end)
	local lastTime = tick()
	local lastTime2 = tick()

	while tick() - lastTime < 0.4 do
		local v2 = tick() - lastTime2
		local v3 = math.min(1, (tick() - lastTime) / 0.4)
		local _ = v3 ^ 2

		for i = 1, #v do
			local v4 = v[i]
			v4[2].CFrame = cFrame * v4[4] * CFrame.new(0, 25, 0) * CFrame.Angles(0, v2, 0)
			v4[3].CFrame = cFrame * v4[4] * CFrame.new(0, (1 - v3 * 2) * 25, 0) * CFrame.Angles(0, v2, 0)

			if not (v3 > 0.5) then
				continue
			end

			local v5 = ((v3 - 0.5) / 0.5) ^ 0.75
			v4[1].Width0 = (1 - v5) * 0.2
			v4[1].Width1 = v4[1].Width0
			v4[1].CurveSize0 = v5 * 5
			v4[1].CurveSize1 = v5 * 5
		end

		lastTime2 = tick()
		local RunService = game:GetService("RunService")
		RunService.RenderStepped:Wait()
	end

	for _, v2 in next, v, nil do
		v2[1]:Destroy()
		v2[2]:Destroy()
		v2[3]:Destroy()
	end
end