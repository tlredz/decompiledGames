local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(p)
	local origin = p.Origin

	if (origin.p - workspace.CurrentCamera.CFrame.p).magnitude > 700 then
		return
	end

	local v = {
		workspace.Characters,
		workspace._WorldOrigin,
		workspace.Boats,
		workspace.Enemies
	}
	CFrame.Angles(-1.5707963267948966, 0, 0)
	local clone = script.Rings:Clone()
	clone.Size = createVector(32, 2, 32)
	clone.CFrame = CFrame.new(origin.p)
	clone.Parent = _WorldOrigin
	local tween = TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
		Transparency = 1,
		Size = createVector(320, 20, 320)
	})
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
	local part = Instance.new("Part")
	part.Material = Enum.Material.ForceField
	part.CFrame = origin
	part.Anchored = true
	part.CanCollide = false
	part.Color = Color3.new(1, 1, 1)
	part.Size = createVector(1, 1, 1)
	local specialMesh = Instance.new("SpecialMesh", part)
	specialMesh.MeshType = "Sphere"
	specialMesh.Scale = createVector(20, 20, 20)
	part.Parent = _WorldOrigin
	TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
		Transparency = 1
	}):Play()
	local tween2 = TweenService:Create(specialMesh, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
		Scale = createVector(200, 200, 200)
	})
	tween2.Completed:Connect(function()
		part:Destroy()
	end)
	tween2:Play()
	local lastTime = tick()
	local v2 = {}

	while tick() - lastTime < 0.2 do
		local v3 = math.min(1, (tick() - lastTime) / 0.2) ^ 0.5 * 180 + 20
		local count = 0

		for i = 0, 360, 360 / (v3 * 4) ^ 0.5 do
			count += 1
			local v4 = origin * CFrame.Angles(0, math.rad(i), 0) * Vector3.new(0, 0, v3 / 2)
			local ray, v5 = Util.Ray(v4, createVector(0, -40, 0), v)

			if ray and ray.Anchored and ray.Transparency <= 0 then
				local v6 = v2[count] or Instance.new("Part")
				v6.Color = ray.Color
				v6.Material = ray.Material
				v6.Transparency = ray.Transparency
				v6.Size = Vector3.new(1, 0.6 + math.random() * 0.4, 0.6 + math.random() * 0.4) * (v3 / 4) ^ 0.5 * 3.141592653589793
				v6.CFrame = (CFrame.new(v5, (Vector3.new(origin.p.X, v5.Y, origin.p.Z))) - createVector(0, 3, 0)) * CFrame.Angles(
					math.rad((math.random(-55, -35))),
					0,
					0
				)

				if not v2[count] then
					v2[count] = v6
					v6.Anchored = true
					v6.CanCollide = false
					v6.TopSurface = 0
					v6.BottomSurface = 0
				end

				v6.Parent = _WorldOrigin
			elseif v2[count] then
				v2[count].Parent = nil
			end
		end

		for _ = 1, math.random(3, 4) do
			local ray, v4 = Util.Ray(
				origin.p + Vector3.new(math.random(-v3 / 4, v3 / 4), 0, math.random(-v3 / 4, v3 / 4)),
				createVector(0, -40, 0),
				v
			)

			if not ray then
				continue
			end

			local part2 = Instance.new("Part")
			Util.Debris:AddItem(part2, 5)
			part2.Color = ray.Color
			part2.Material = ray.Material
			part2.Transparency = ray.Transparency
			part2.Size = Vector3.new(1 + math.random() * 0.5, 1 + math.random() * 0.5, 1 + math.random() * 0.5) * (6 + math.random() * 3)
			part2.CFrame = (CFrame.new(v4, (Vector3.new(origin.p.X, v4.Y, origin.p.Z))) - createVector(0, 4, 0)) * CFrame.Angles(
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2
			)
			part2.Anchored = false
			part2.CanCollide = false
			part2.TopSurface = 0
			part2.BottomSurface = 0
			part2.Velocity = (part2.Position - origin.p).unit * math.random(100, 180) + Vector3.new(
				0,
				math.random(180, 320),
				0
			)
			part2.Parent = _WorldOrigin
		end

		wait()
	end

	wait(2)

	for _, v3 in next, v2, nil do
		if v3.Parent then
			local tween3 = TweenService:Create(v3, TweenInfo.new(0.4 + math.random() * 0.6), {
				CFrame = v3.CFrame - Vector3.new(0, v3.Size.Y * 1.25, 0)
			})
			local v4 = v3
			tween3.Completed:Connect(function()
				v4:Destroy()
			end)
			tween3:Play()
		else
			v3:Destroy()
		end
	end
end