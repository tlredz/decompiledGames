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

	if (origin.p - workspace.CurrentCamera.CFrame.p).magnitude > 600 then
		return
	end

	local v = {
		workspace.Characters,
		workspace._WorldOrigin,
		workspace.Boats,
		workspace.Enemies
	}
	CFrame.Angles(-1.5707963267948966, 0, 0)

	for i = 1, 4 do
		local v2 = i
		spawn(function()
			local lastTime = tick()
			local v3 = {}

			while tick() - lastTime < 0.5 do
				local v4 = math.min(1, (tick() - lastTime) / 0.5) * 240
				local count = 0

				for i2 = 0, 360, 360 / (v4 * 4) ^ 0.5 do
					count += 1
					local v5 = origin * CFrame.Angles(0, math.rad(i2), 0) * Vector3.new(0, 0, v4 / 2)
					local ray, v6 = Util.Ray(v5, createVector(0, -60, 0), v)

					if ray and ray.Anchored and ray.Transparency <= 0 then
						local v7 = v3[count] or Instance.new("Part")
						v7.Color = ray.Color
						v7.Material = ray.Material
						v7.Transparency = ray.Transparency
						v7.Size = Vector3.new(1, 0.6 + math.random() * 0.4, 0.6 + math.random() * 0.4) * (v4 / 4) ^ 0.5 * 3.141592653589793
						v7.CFrame = (CFrame.new(v6, (Vector3.new(origin.p.X, v6.Y, origin.p.Z))) - createVector(0, 3, 0)) * CFrame.Angles(
							math.rad((math.random(-55, -35))),
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

				local v5 = v2

				for i2 = 1, 360, 120 do
					local v6 = origin * CFrame.Angles(0, math.rad(i2) + v5 / 4 * 3.141592653589793 * 2, 0) * Vector3.new(
						0,
						0,
						v4 / 1.5
					)
					local ray, v7 = Util.Ray(v6, createVector(0, -60, 0), v)

					if not (ray and ray.Anchored and ray.Transparency <= 0) then
						continue
					end

					local part = Instance.new("Part")
					part.Color = ray.Color
					part.Material = ray.Material
					part.Transparency = ray.Transparency
					part.Size = Vector3.new(1, 0.6 + math.random() * 0.4, 0.6 + math.random() * 0.4) * (v4 / 4) ^ 0.5 * 3.141592653589793
					part.CFrame = (CFrame.new(v7, (Vector3.new(origin.p.X, v7.Y, origin.p.Z))) - createVector(0, 3, 0)) * CFrame.Angles(
						math.random() * 7,
						math.random() * 7,
						math.random() * 7
					)
					part.Anchored = true
					part.CanCollide = false
					part.TopSurface = 0
					part.BottomSurface = 0
					part.Parent = _WorldOrigin
					local tween = TweenService:Create(
						part,
						TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
						{
							CFrame = part.CFrame - Vector3.new(0, part.Size.Y * 1.25, 0)
						}
					)
					tween.Completed:Connect(function()
						part:Destroy()
					end)
					tween:Play()
				end

				local ray, v6 = Util.Ray(
					origin.p + Vector3.new(math.random(-v4 / 4, v4 / 4), 0, math.random(-v4 / 4, v4 / 4)),
					createVector(0, -40, 0),
					v
				)

				if ray then
					local part = Instance.new("Part")
					Util.Debris:AddItem(part, 5)
					part.Color = ray.Color
					part.Material = ray.Material
					part.Transparency = ray.Transparency
					part.Size = Vector3.new(1 + math.random() * 0.5, 1 + math.random() * 0.5, 1 + math.random() * 0.5) * (6 + math.random() * 3)
					part.CFrame = (CFrame.new(v6, (Vector3.new(origin.p.X, v6.Y, origin.p.Z))) - createVector(0, 4, 0)) * CFrame.Angles(
						math.random() * 3.141592653589793 * 2,
						math.random() * 3.141592653589793 * 2,
						math.random() * 3.141592653589793 * 2
					)
					part.Anchored = false
					part.CanCollide = false
					part.TopSurface = 0
					part.BottomSurface = 0
					part.Velocity = (part.Position - origin.p).unit * math.random(100, 180) + Vector3.new(
						0,
						math.random(180, 320),
						0
					) * 1.25
					part.Parent = _WorldOrigin
				end

				wait()
			end

			for k, v4 in next, v3, nil do
				if v4.Parent then
					local tween = TweenService:Create(v4, TweenInfo.new(0.15), {
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
		end)
		wait(0.1)
	end
end