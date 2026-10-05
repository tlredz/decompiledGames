local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local clone = script.Air:Clone()
clone:TranslateBy(createVector(0, 999999, 0))
clone.Parent = workspace._WorldOrigin
return function(data)
	if data.Mode == "Dash" then
		local cFrame = data.Root and data.Root.CFrame or data.CFrame

		if (cFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude > 800 then
			return
		end

		if data.Stage == 1 then
			for _ = 1, 3 do
				local clone2 = script.RedSlash:Clone()
				clone2:SetPrimaryPartCFrame(cFrame * CFrame.Angles(
					3.141592653589793 * math.random() * 2,
					3.141592653589793 * math.random() * 2,
					3.141592653589793 * math.random() * 2
				))

				for _, child in pairs(clone2:GetChildren()) do
					child.Size *= 2 + math.random() * 2
					local tween = TweenService:Create(
						child,
						TweenInfo.new(0.13 + (child == clone2.PrimaryPart and 0.05 or 0), Enum.EasingStyle.Bounce),
						{
							Size = createVector(0.05, 0.05, 0.05),
							CFrame = child.CFrame * CFrame.Angles(
								3.141592653589793,
								3.141592653589793,
								3.141592653589793
							)
						}
					)

					if child == clone2.PrimaryPart then
						local v = clone2
						tween.Completed:Connect(function()
							v:Destroy()
						end)
					end

					tween:Play()
				end

				clone2.Parent = _WorldOrigin
			end
		else
			local v = cFrame * CFrame.new(0, 3.3, 0)
			local length = data.Length
			local v2 = length * 0.45
			local clone2 = script.RedSpike:Clone()
			clone2:SetPrimaryPartCFrame(v * CFrame.Angles(0, 3.141592653589793, 0))

			for _, child in pairs(clone2:GetChildren()) do
				child.Size *= 4
				local tween = TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					Size = createVector(0.05, 0.05, 0.05),
					CFrame = child.CFrame * CFrame.new(0, 0, length + 40)
				})

				if child == clone2.PrimaryPart then
					tween.Completed:Connect(function()
						clone2:Destroy()
					end)
				end

				tween:Play()
			end

			clone2.Parent = _WorldOrigin
			task.wait(0.06)
			local v3 = Util.Sound:Play("WindFast", v, 80, 1.4, 0.35)
			local lastTime = tick()
			local count = 0

			while tick() - lastTime < 0.75 do
				local v4 = 0.25 + 0.75 * ((tick() - lastTime) / 0.75) ^ 3
				local v5 = v2 * (1.15 - v4)

				if count % 3 == 0 then
					Util.Sound:Play("SpinWoosh", v, 80, 1.5 + math.random(-42, 42) / 100, 0.25)
				end

				if not _G.FastMode and count % 6 == 0 then
					for i = math.max(0, length - 75), length - 25, 25 do
						local clone3 = script.Air:Clone()
						clone3:SetPrimaryPartCFrame(v * CFrame.new(0, 0, -length / 2 - i) * CFrame.Angles(0, 1.57, 1.57) * CFrame.Angles(
							0,
							math.random() * 3.141592653589793 * 2,
							0
						))

						for _, child in pairs(clone3:GetChildren()) do
							child.Transparency = 0.4
							local tween = TweenService:Create(
								child,
								TweenInfo.new(
									0.5 + math.random() + (child == clone3.PrimaryPart and -0.15 or 0),
									Enum.EasingStyle.Exponential
								),
								{
									Size = child.Size * 2 * createVector(5, 10, 5) * (1 + math.random()) * 0.8,
									CFrame = child.CFrame * CFrame.new(0, length / 1.5, 0) * CFrame.Angles(
										0,
										3.141592653589793,
										0
									),
									Transparency = 1
								}
							)

							if child == clone3.PrimaryPart then
								local v6 = clone3
								tween.Completed:Connect(function()
									v6:Destroy()
								end)
							end

							tween:Play()
						end

						clone3.Parent = _WorldOrigin
					end
				end

				count += 1
				local clone3 = script.RedTornado:Clone()
				clone3:SetPrimaryPartCFrame(v * CFrame.Angles(0, 1.57, 1.57) * CFrame.Angles(
					0,
					3.141592653589793 * math.random() * 2,
					0
				) * CFrame.new(0, -length / 3, 0))

				for _, child in pairs(clone3:GetChildren()) do
					child.Size *= Vector3.new(1.25 - v4, 1.5, 1.25 - v4) * (length * 0.05)
					local tween = TweenService:Create(child, TweenInfo.new(0.07, Enum.EasingStyle.Quad), {
						Size = createVector(0.1, 0.1, 0.1),
						CFrame = child.CFrame * CFrame.new(0, -clone3.PrimaryPart.Size.Y / 2, 0) * CFrame.Angles(
							0,
							3.141592653589793,
							0
						)
					})

					if child == clone3.PrimaryPart then
						local v6 = clone3
						tween.Completed:Connect(function()
							v6:Destroy()
						end)
					end

					tween:Play()
				end

				clone3.Parent = _WorldOrigin

				for i = 1, 8 do
					local part = Instance.new("Part")
					part.Material = "Neon"
					part.Anchored = true
					part.CastShadow = false
					part.CanCollide = false
					part.CFrame = v * CFrame.new(0, 0, -length - 10) * CFrame.Angles(
						v5 * 0.0215 * (math.random() - 0.5),
						v5 * 0.0215 * (math.random() - 0.5),
						v5 * 0.0215 * (math.random() - 0.5)
					)
					part.Size = createVector(1, 1, 1)
					part.Color = i % 2 == 0 and Color3.new(1, 0, 0) or Color3.new()
					local specialMesh = Instance.new("SpecialMesh", part)
					specialMesh.MeshType = "Sphere"
					specialMesh.Scale = Vector3.new(1, 1, length * 0.25) * 2
					local v6 = length * 0.1333 + length * 0.2 * math.random()
					part.Parent = _WorldOrigin
					local tween = TweenService:Create(
						specialMesh,
						TweenInfo.new(0.075 + math.random() * 0.05, Enum.EasingStyle.Quad),
						{
							Offset = Vector3.new(0, 0, v6 * 4),
							Scale = Vector3.new(0, 0, v6 / 2)
						}
					)
					tween.Completed:Connect(function()
						part:Destroy()
					end)
					tween:Play()
				end

				wait()
			end

			Util.Sound:FadeOut(v3, 1)
		end
	elseif data.Mode == "Projectile" then
		if data.Stage == 1 then
			local root = data.Root

			if (root.CFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude > 900 then
				return
			end

			local p = root.CFrame.p
			local finalPos = data.FinalPos
			local _ = CFrame.new(p, finalPos).LookVector
			local v = tick() - math.max(0, (masterClock:GetTime() - data.Timestamp) / 4 - 0.1)
			local count = 0

			while tick() - v < 0.25 do
				local v2 = CFrame.new(p, finalPos) * CFrame.new(0, 0, -400 * (tick() - v))
				local _, _ = Util.Ray(root.CFrame.p, v2.p - root.CFrame.p, { workspace.Characters, workspace.Enemies })
				count += 1

				if count % 2 == 0 and tick() - v < 0.233 then
					local v3 = CFrame.Angles(0, 0, 1.77) * CFrame.Angles(3.141592653589793 * math.random() * 2, 0, 0)
					local clone2 = script.RedSlash:Clone()
					clone2:SetPrimaryPartCFrame(root.CFrame * v3)

					for _, child in pairs(clone2:GetChildren()) do
						local tween = TweenService:Create(
							child,
							TweenInfo.new(0.1 + (child == clone2.PrimaryPart and 0.05 or 0), Enum.EasingStyle.Bounce),
							{
								Size = child.Size * 3
							}
						)

						if child == clone2.PrimaryPart then
							local v4 = clone2
							tween.Completed:Connect(function()
								v4:Destroy()
							end)
						end

						tween:Play()
					end

					clone2.Parent = _WorldOrigin
					coroutine.resume(coroutine.create(function()
						local lastTime = tick()

						while clone2:IsDescendantOf(_WorldOrigin) do
							clone2:SetPrimaryPartCFrame(root.CFrame * v3 * CFrame.Angles(
								-(tick() - lastTime) * 3.141592653589793 * 10,
								0,
								0
							))
							RunService.RenderStepped:Wait()
						end
					end))
				end

				RunService.Stepped:Wait()
			end
		else
			local v = data.CFrame * CFrame.new(-1, 0, 0) * CFrame.Angles(0, 0, 0.2)

			if (v.p - workspace.CurrentCamera.CFrame.p).Magnitude > 1200 then
				return
			end

			local speed = data.Speed
			local duration = data.Duration
			local v2 = CFrame.Angles(0, 0, 1.57) * CFrame.Angles(-2.25, 0, 0)
			local clone2 = script.RedSlash:Clone()
			clone2.Red.ParticleEmitter.Enabled = true
			clone2.Red.ParticleEmitter.Acceleration = -v.LookVector * speed

			for _, child in pairs(clone2:GetChildren()) do
				child.Size *= 3.5
			end

			clone2:SetPrimaryPartCFrame(v * v2)
			clone2.Parent = _WorldOrigin
			local lastTime = tick()
			local v3 = tick() - (masterClock:GetTime() - data.Timestamp) - 0.06

			while tick() - v3 < duration do
				local v4 = v * CFrame.new(0, 0, -(tick() - v3) * speed)

				if tick() - lastTime > 0.03333333333333333 then
					local clone3 = clone2.Black:Clone()
					clone3.CFrame += v4.LookVector * speed * 0.05
					clone3.Transparency = 0.97
					clone3.Color = Color3.new(1, 1, 1)
					local tween = TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
						Size = clone3.Size * 1.75,
						Transparency = 1
					})
					tween.Completed:Connect(function()
						clone3:Destroy()
					end)
					tween:Play()
					clone3.Parent = _WorldOrigin
					lastTime = tick()
				end

				clone2:SetPrimaryPartCFrame(v4 * v2)
				local clone3 = clone2.Red:Clone()
				local tween = TweenService:Create(clone3, TweenInfo.new(0.175), {
					Size = clone3.Size * 0.7,
					Transparency = 1
				})
				tween.Completed:Connect(function()
					clone3:Destroy()
				end)
				tween:Play()
				clone3.Parent = _WorldOrigin
				RunService.RenderStepped:Wait()
			end

			clone2.Red.ParticleEmitter.Enabled = false
			clone2.Red.Electric.Enabled = false

			for _, child in pairs(clone2:GetChildren()) do
				child.Transparency = 1
			end

			wait(1)
			clone2:Destroy()
		end
	end
end