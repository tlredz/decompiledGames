local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(instance)
	local origin = instance.Origin
	local holding = instance.Holding
	local caster = instance.Caster
	local humanoid = instance.Humanoid

	if (origin.p - workspace.CurrentCamera.CFrame.p).magnitude > 700 then
		return
	end

	local v = {
		workspace.Characters,
		workspace._WorldOrigin,
		workspace.Boats,
		workspace.Enemies
	}
	local v2 = Util.Sound:Play("GravityX", origin)
	local random = Random.new()
	local lastTime = tick()
	local lastTime2 = tick()
	local v3 = {}

	while tick() - lastTime2 < 5 and not (humanoid.Health <= 0) and caster.Parent and (not (tick() - lastTime2 > 1) or holding and holding.Value) do
		local v4 = math.min(1, (tick() - lastTime2) / 5) ^ 0.5 * 200 + 25

		if tick() - lastTime > 0.15 and (game.Players.LocalPlayer == caster or (origin.p - workspace.CurrentCamera.CFrame.p).magnitude < v4 / 2) then
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

		for _ = 1, v4 / 12 do
			local v5 = 0.1 + random:NextNumber(0, 0.05)
			local part = Instance.new("Part")
			part.Color = math.random(1, 2) == 1 and Color3.new() or Color3.fromRGB(155, 50, 255)
			part.TopSurface = 0
			part.BottomSurface = 0
			part.Material = "Neon"
			part.Transparency = 0
			part.Anchored = true
			part.CanCollide = false
			part.Size = createVector(1, 1, 1)
			part.CFrame = origin * CFrame.Angles(0, random:NextNumber(0, 6.283185307179586), 0) * CFrame.new(
				0,
				25,
				random:NextNumber(0, v4 / 2)
			)
			local specialMesh = Instance.new("SpecialMesh")
			specialMesh.Scale = createVector(1, 20, 1)
			specialMesh.MeshType = "Sphere"
			specialMesh.Parent = part
			part.Parent = _WorldOrigin
			local tween = TweenService:Create(specialMesh, TweenInfo.new(v5), {
				Scale = createVector(0, 0, 0),
				Offset = createVector(0, -30, 0)
			})
			tween.Completed:Connect(function()
				part:Destroy()
			end)
			tween:Play()
		end

		local count = 0

		for i = 0, 360, 360 / (v4 * 2) ^ 0.5 do
			count += 1
			local v5 = origin * CFrame.Angles(0, math.rad(i), 0) * Vector3.new(0, 10, v4 / 2)
			local ray, v6 = Util.Ray(v5, createVector(0, -20, 0), v)

			if ray and ray.Anchored and ray.Transparency <= 0 then
				local v7 = v3[count] or Instance.new("Part")
				v7.Color = ray.Color
				v7.Material = ray.Material
				v7.Transparency = ray.Transparency
				v7.Size = createVector(1, 0.3, 0.3) * (v4 / 2) ^ 0.5 * 3.141592653589793
				v7.CFrame = (CFrame.new(v6, (Vector3.new(origin.p.X, v6.Y, origin.p.Z))) - createVector(0, 0, 0)) * CFrame.Angles(
					-0.7853981633974483,
					0,
					0
				)

				if not v3[count] then
					v3[count] = v7
					v7.Anchored = true
					v7.CanCollide = false
					v7.TopSurface = 0
					v7.BottomSurface = 0
				end

				v7.Parent = _WorldOrigin
			elseif v3[count] then
				v3[count].Parent = nil
			end
		end

		wait()
	end

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
end