local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Lightning = require(game.ReplicatedStorage.Util.Lightning)

-- equivalent calls inferred from this helper; original call sites unknown
local function invertCF(cFrame)
	local components, v, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11 = cFrame:components()
	return CFrame.new(components, v, v2, v3, v4, v5, v6, v7, v8, -v9, -v10, -v11)
end

return function(data)
	local part = data.Part
	local owner = data.Owner
	local duration = data.Duration
	local origin = data.Origin
	local size = data.Size
	local holding = data.Holding
	local clone = part:Clone()
	clone.Material = "Neon"
	clone.Color = Color3.fromRGB(115, 223, 255)
	clone.CanCollide = false
	clone.Anchored = false
	clone.CFrame = invertCF(part.CFrame)
	clone.Mesh.Scale += createVector(3, 3, 3)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = clone
	weldConstraint.Part1 = part
	weldConstraint.Parent = part
	clone.Parent = part
	local v = sound:Play("ElectricPowerField", part)
	local tween = TweenService:Create(clone.Mesh, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
		Scale = createVector(1, 1, 1) * size + createVector(3, 3, 3)
	})
	tween.Completed:Connect(function()
		sound:FadeOut(v, 1)
	end)
	tween:Play()
	TweenService:Create(part.Mesh, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
		Scale = createVector(1, 1, 1) * size
	}):Play()
	TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
		CFrame = origin - Vector3.new(0, size / 4, 0)
	}):Play()

	for i = 5, 14 do
		local clone2 = game.ReplicatedStorage.Assets.Models.ThorCloud:Clone()
		clone2.CFrame = CFrame.new(origin.p) * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) + Vector3.new(
			math.sin(i * 1.57) * i * 12,
			0,
			math.cos(i * 1.57) * i * 12
		)
		clone2.Mesh.Scale = Vector3.new()
		TweenService:Create(clone2.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
			Scale = Vector3.new(25, 14 + math.random() * 2, 30) * (1 + math.random() * 0.5) * 10
		}):Play()
		clone2.Parent = workspace._WorldOrigin
		local tween2 = TweenService:Create(clone2.Mesh, TweenInfo.new(0.75, Enum.EasingStyle.Quad), {
			Scale = Vector3.new()
		})
		tween2.Completed:Connect(function()
			clone2:Destroy()
		end)
		delay(duration, function()
			tween2:Play()
		end)
	end

	if (part.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
		return
	end

	local v2 = sound:Play("ElectricLoopable", owner.Position)
	local v3 = false
	local v4 = false
	part.ChildAdded:Connect(function(child)
		if child.Name == "Exploding" then
			v4 = true

			if v2 then
				sound:FadeOut(v2, 0.25)
				spawn(function()
					wait(0.3)
					pcall(function()
						v2:Stop()
						v2:Destroy()
					end)
				end)
				v2 = nil
			end

			local v5 = sound:Play("ElectricExplosionLong", part)
			spawn(function()
				local v6 = {
					workspace.Characters,
					workspace._WorldOrigin,
					workspace.Boats,
					workspace.Enemies
				}
				local cframe = CFrame.new(part.Position)
				local lastTime = tick()
				local v7 = {}

				while tick() - lastTime < 1.8333333333333333 do
					local v8 = math.min(1, (tick() - lastTime) / 1.8333333333333333) ^ 0.8
					local v9 = 20 + size + v8 * size * 0.5 + v8 * 45
					local count = 0

					for i = 0, 360, 360 / (v9 * 4) ^ 0.5 do
						count += 1
						local v10 = cframe * CFrame.Angles(0, math.rad(i), 0) * Vector3.new(0, 0, v9 / 2)
						local ray, v11 = Util.Ray(v10, createVector(0, -100, 0), v6)

						if ray and ray.Anchored and ray.Transparency <= 0 then
							local v12 = v7[count] or Instance.new("Part")
							v12.Color = ray.Color
							v12.Material = ray.Material
							v12.Transparency = ray.Transparency
							v12.Size = createVector(1, 1, 1) * (v9 / 4) ^ 0.5 * 3.141592653589793
							v12.CFrame = (CFrame.new(v11, (Vector3.new(cframe.p.X, v11.Y, cframe.p.Z))) - createVector(
								0,
								5,
								0
							)) * CFrame.Angles(-0.7853981633974483, 0, 0)

							if not v7[count] then
								v7[count] = v12
								v12.Anchored = true
								v12.CanCollide = false
								v12.TopSurface = 0
								v12.BottomSurface = 0
							end

							v12.Parent = _WorldOrigin
						elseif v7[count] then
							v7[count].Parent = nil
						end
					end

					if math.random() < 1.5 - v8 then
						local ray, v10 = Util.Ray(
							cframe.p + Vector3.new(math.random() - 0.5, 0, math.random() - 0.5).unit * v9 / 2,
							createVector(0, -100, 0),
							v6
						)

						if ray then
							local part2 = Instance.new("Part")
							Util.Debris:AddItem(part2, 5)
							part2.Color = ray.Color
							part2.Material = ray.Material
							part2.Transparency = ray.Transparency
							part2.Size = Vector3.new(
								1 + math.random() * 0.5,
								1 + math.random() * 0.5,
								1 + math.random() * 0.5
							) * (8 + math.random() * 6)
							part2.CFrame = (CFrame.new(v10, (Vector3.new(cframe.p.X, v10.Y, cframe.p.Z))) - createVector(
								0,
								4,
								0
							)) * CFrame.Angles(
								math.random() * 3.141592653589793 * 2,
								math.random() * 3.141592653589793 * 2,
								math.random() * 3.141592653589793 * 2
							)
							part2.Anchored = false
							part2.CanCollide = false
							part2.TopSurface = 0
							part2.BottomSurface = 0
							part2.Velocity = (part2.Position - cframe.p).unit * math.random(100, 180) * 1.6 + Vector3.new(
								0,
								math.random(180, 320),
								0
							) * 1.2
							part2.Parent = _WorldOrigin
						end
					end

					wait()
				end

				wait(4)

				for _, v8 in next, v7, nil do
					if v8.Parent then
						local tween2 = TweenService:Create(v8, TweenInfo.new(0.4 + math.random() * 0.6), {
							CFrame = v8.CFrame - Vector3.new(0, v8.Size.Y * 1.25, 0)
						})
						local v9 = v8
						tween2.Completed:Connect(function()
							v9:Destroy()
						end)
						tween2:Play()
					else
						v8:Destroy()
					end
				end
			end)
			local clone2 = clone:Clone()
			clone2.Material = "Neon"
			clone2.Color = Color3.fromRGB(255, 255, 255)
			clone2.CanCollide = false
			clone2.Transparency = 1
			clone2.Anchored = false
			clone2.CFrame = part.CFrame
			clone2.Mesh.Scale += createVector(1, 1, 1)
			local weldConstraint2 = Instance.new("WeldConstraint")
			weldConstraint2.Part0 = clone2
			weldConstraint2.Part1 = part
			weldConstraint2.Parent = clone2
			clone2.Parent = workspace._WorldOrigin
			TweenService:Create(clone2, TweenInfo.new(2, Enum.EasingStyle.Quad), {
				Transparency = 0
			}):Play()
			TweenService:Create(clone, TweenInfo.new(2, Enum.EasingStyle.Quad), {
				Color = Color3.fromRGB(110, 153, 202)
			}):Play()
			TweenService:Create(part.Mesh, TweenInfo.new(2, Enum.EasingStyle.Quad), {
				Scale = createVector(1, 1, 1) * size * 1.75
			}):Play()
			TweenService:Create(clone.Mesh, TweenInfo.new(2, Enum.EasingStyle.Quad), {
				Scale = createVector(1, 1, 1) * size * 1.75 + createVector(3, 3, 3)
			}):Play()
			TweenService:Create(clone2.Mesh, TweenInfo.new(2, Enum.EasingStyle.Quad), {
				Scale = createVector(1, 1, 1) * size * 1.75 + createVector(1, 1, 1)
			}):Play()
			wait(2)
			TweenService:Create(part.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Scale = Vector3.new()
			}):Play()
			TweenService:Create(clone.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Scale = Vector3.new()
			}):Play()
			local tween2 = TweenService:Create(clone2.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Scale = Vector3.new()
			})
			tween2.Completed:Connect(function()
				clone2:Destroy()
			end)
			tween2:Play()
			v3 = true
			sound:FadeOut(v5, 1)
		end
	end)
	local lastTime = tick()
	tick()
	local count = 0

	while part:IsDescendantOf(workspace) and v3 == false do
		count += 1

		if v4 and count % 4 == 0 then
			local clone2 = clone:Clone()
			clone2.Material = "ForceField"
			clone2.Color = Color3.new(0, 1, 1)
			clone2.CanCollide = false
			clone2.Transparency = 0
			clone2.Anchored = true
			clone2.CFrame = part.CFrame
			clone2.Mesh.Scale += createVector(1, 1, 1)
			clone2.Parent = workspace._WorldOrigin
			TweenService:Create(clone2.Mesh, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
				Scale = createVector(1, 1, 1) * size * 2.5
			}):Play()
			local tween2 = TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
				Transparency = 1
			})
			tween2.Completed:Connect(function()
				clone2:Destroy()
			end)
			tween2:Play()

			if (workspace.CurrentCamera.CFrame.p - part.Position).Magnitude < 350 then
				Effect.new("ShakeCam"):replicate({
					6,
					12,
					0.1,
					1.5,
					createVector(1, 1, 1),
					createVector(1, 1, 1)
				})
			end
		end

		Lightning.new({
			Lifetime = 0.1 + math.random() * 0.2,
			DrawType = "Singular",
			Colors = {
				ColorSequenceKeypoint.new(0, v4 and Color3.fromRGB(115, 223, 255) or Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, v4 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(115, 223, 255))
			},
			Sizes = {
				{
					Size = (v4 and 9 or 5) * 0.15,
					Time = 0
				},
				{
					Size = v4 and 9 or 5,
					Time = 0.5
				},
				{
					Size = 0,
					Time = 1
				}
			},
			Transparencies = {
				{
					Transparency = 0,
					Time = 0
				},
				{
					Transparency = 0,
					Time = 1
				}
			},
			Points = {
				Start = {
					Position = part.Position
				},
				End = {
					Position = part.Position + Vector3.new(
						math.random() - 0.5,
						math.random() - 0.5,
						math.random() - 0.5
					).unit * (part.Mesh.Scale.X * (1 + math.random() * 0.15))
				}
			},
			ArcSize = {
				Min = v4 and 130 or 20,
				Max = v4 and 160 or 60
			},
			ChangesSegmentOffset = true,
			OffsetChangePercent = {
				EqualOrBelow = 0.15,
				Bounds = { 0, 1 }
			}
		})

		if owner and count % 2 == 0 and (holding.Value or tick() - lastTime < duration) and not v4 then
			Lightning.new({
				Lifetime = 0.1 + math.random() * 0.1,
				DrawType = "Singular",
				Colors = {
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(115, 223, 255))
				},
				Sizes = {
					{
						Size = 0.22499999999999998,
						Time = 0
					},
					{
						Size = 1.5,
						Time = 0.5
					},
					{
						Size = 0,
						Time = 1
					}
				},
				Transparencies = {
					{
						Transparency = 0,
						Time = 0
					},
					{
						Transparency = 0,
						Time = 1
					}
				},
				Points = {
					Start = {
						Position = owner.Position
					},
					End = {
						Position = owner.Position + Vector3.new(
							math.random() - 0.5,
							math.random() - 0.5,
							math.random() - 0.5
						).unit * math.random(10, 20)
					}
				},
				ArcSize = {
					Min = 10,
					Max = 20
				},
				ChangesSegmentOffset = true,
				OffsetChangePercent = {
					EqualOrBelow = 0.15,
					Bounds = { 0, 1 }
				}
			})
		end

		wait()
	end

	wait()

	if v2 then
		sound:FadeOut(v2, 0.25)
		spawn(function()
			wait(0.3)
			pcall(function()
				v2:Stop()
				v2:Destroy()
			end)
		end)
		v2 = nil
	end
end