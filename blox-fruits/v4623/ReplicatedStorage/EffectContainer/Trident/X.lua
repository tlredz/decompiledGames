local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(data)
	local cFrame = data.CFrame
	local start = data.Start

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
		return
	end

	local radius = data.Radius
	local _ = masterClock:GetTime() - data.Timestamp
	game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

	for i = 0, 3.141592653589793, 1.0471975511965976 do
		local v = i
		spawn(function()
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.Color = Color3.new(0, 0.5, 1)
			part.Size = createVector(1, 1, 1)
			part.Material = "Neon"
			part.CFrame = start
			part.Transparency = 0.88
			local specialMesh = Instance.new("SpecialMesh", part)
			specialMesh.MeshType = Enum.MeshType.Sphere
			specialMesh.Scale = createVector(1, 1, 1)
			part.Parent = workspace._WorldOrigin
			TweenService:Create(specialMesh, TweenInfo.new(1.3332, Enum.EasingStyle.Back), {
				Scale = createVector(1, 1, 1) * radius * 2
			}):Play()
			TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
				CFrame = cFrame
			}):Play()
			wait(0.2)
			local clone = game.ReplicatedStorage.Assets.Models.DragonHeadBig:Clone()

			for i2, trail in pairs(clone:GetChildren()) do
				if not trail:IsA("Trail") then
					continue
				end

				trail.Color = ColorSequence.new(Color3.fromRGB(0, 130, 255))
				trail.Lifetime *= 1.5
				trail.Texture = ""
				trail.WidthScale = NumberSequence.new(0.5, 0)
				trail.Transparency = NumberSequence.new(0.1, 1)
			end

			clone.Color = Color3.fromRGB(0, 130, 255)
			clone.CFrame = cFrame
			clone.Parent = workspace._WorldOrigin
			local lastTime = tick()
			local count = 0

			while tick() - lastTime < 1.0332 do
				local v2 = math.min(1, (tick() - lastTime) / 1.3332) * 3.141592653589793 * 2 * 3
				local v3 = cFrame * CFrame.Angles(v, v2 + v, v) * CFrame.new(0, 0, -radius - 5)
				clone.CFrame = CFrame.new(v3.p, v3.p - (clone.CFrame.p - v3.p).unit)
				count += 1

				if count % 3 == 0 then
					local v4 = 6 + math.random() * 9
					local part2 = Instance.new("Part")
					part2.Anchored = true
					part2.CanCollide = false
					part2.CFrame = cFrame * CFrame.Angles(
						3.141592653589793 * (math.random() - 0.5) * 2,
						3.141592653589793 * (math.random() - 0.5) * 2,
						3.141592653589793 * (math.random() - 0.5) * 2
					)
					part2.Size = createVector(1, 1, 1)
					part2.Color = Color3.new(0, math.random() > 0.5 and 0.5 or 0.75, 1)
					part2.Transparency = 0
					part2.Material = "Neon"
					local specialMesh2 = Instance.new("SpecialMesh")
					specialMesh2.MeshType = "Sphere"
					specialMesh2.Scale = createVector(1, 1, 1) * v4
					specialMesh2.Parent = part2
					part2.Parent = workspace._WorldOrigin
					local tween = TweenService:Create(specialMesh2, TweenInfo.new(0.15 + math.random() * 0.15), {
						Scale = Vector3.new(),
						Offset = Vector3.new(0, 0, -math.random(37, 43))
					})
					tween.Completed:Connect(function()
						part2:Destroy()
					end)
					tween:Play()
				end

				RunService.RenderStepped:Wait()
			end

			TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			local tween = TweenService:Create(clone, TweenInfo.new(0.7), {
				Size = createVector(0.05, 0.05, 0.05),
				Transparency = 1
			})
			tween.Completed:Connect(function()
				clone:Destroy()
			end)
			tween:Play()
			wait(2)
			part:Destroy()
		end)
		wait(0.08)
	end
end