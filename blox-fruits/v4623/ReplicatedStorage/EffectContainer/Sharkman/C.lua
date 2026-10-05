local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local RayCastWhitelist = require(game.ReplicatedStorage.Util.RayCastWhitelist)
require(game.ReplicatedStorage.Util.Particles.SpikyFlare)
require(game.ReplicatedStorage.Util.Particles.Rock)
require(game.ReplicatedStorage.Util.Particles.Dust)
local Rock = require(game.ReplicatedStorage.Util.Rock)

local function alignCF(data, p, _)
	local p2 = data.p
	local unit = data.LookVector:Cross(p).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(p).Unit.Unit
	return CFrame.fromMatrix(p2, unit2, p, unit3)
end

local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(p)
	local cFrame = p.CFrame
	local p2 = cFrame.p
	local lookVector = cFrame.LookVector
	local v = 0.5 - (masterClock:GetTime() - p.Timestamp)
	local color = Color3.fromRGB(110, 153, 202)

	if (p2 - workspace.CurrentCamera.CFrame.p).Magnitude > 500 then
		return
	end

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CFrame = CFrame.new(p2, p2 + lookVector)
	part.Size = createVector(1, 1, 1)
	part.Color = color
	part.Transparency = 0
	part.Material = "Neon"
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = "Sphere"
	specialMesh.Scale = Vector3.new()
	specialMesh.Parent = part
	part.Parent = _WorldOrigin
	local tween = TweenService:Create(specialMesh, TweenInfo.new(v * 0.3, Enum.EasingStyle.Linear), {
		Scale = createVector(31.2, 31.2, 75),
		Offset = createVector(0, 0, -37.5)
	})
	tween.Completed:Connect(function()
		local tween2 = TweenService:Create(specialMesh, TweenInfo.new(v * 0.7 * 0.85, Enum.EasingStyle.Linear), {
			Scale = createVector(13, 13, 250),
			Offset = createVector(0, 0, -125)
		})
		tween2.Completed:Connect(function()
			local tween3 = TweenService:Create(specialMesh, TweenInfo.new(v * 0.7 * 0.15, Enum.EasingStyle.Linear), {
				Scale = createVector(0, 0, 250),
				Offset = createVector(0, 0, -125)
			})
			tween3.Completed:Connect(function()
				part:Destroy()
			end)
			tween3:Play()
		end)
		tween2:Play()
	end)
	tween:Play()
	local lastTime = tick()
	local count = 0

	while tick() - lastTime < v do
		local v2 = (tick() - lastTime) / v
		local v3 = math.sin(v2 * 5 + v2 ^ 0.3 * 60) * 0.5
		part.Size = Vector3.new(v3 + 1, v3 + 1, 1)
		count += 1
		local v4 = 10 + math.random() * 5
		local v5 = 22 + math.random() * 12
		local v6 = v4 * (2.2 * (1 - v2))
		local v7 = v5 * (2.2 * (1 - v2))
		local part2 = Instance.new("Part")
		part2.Anchored = true
		part2.CanCollide = false
		part2.CFrame = cFrame * CFrame.new(0, 0, -5) * CFrame.Angles(
			3.141592653589793 * (math.random() - 0.5) * 0.8,
			3.141592653589793 * (math.random() - 0.5) * 0.8,
			0
		)
		part2.Size = createVector(1, 1, 1)
		part2.Color = color
		part2.Transparency = 0
		part2.Material = "Neon"
		local specialMesh2 = Instance.new("SpecialMesh")
		specialMesh2.MeshType = "Sphere"
		specialMesh2.Scale = Vector3.new(v6, v6, v7)
		specialMesh2.Parent = part2
		part2.Parent = _WorldOrigin
		local tween2 = TweenService:Create(specialMesh2, TweenInfo.new(0.1 + math.random() * 0.15), {
			Scale = Vector3.new(0, 0, v7 * 0.7),
			Offset = Vector3.new(0, 0, -math.random(50, 70))
		})
		tween2.Completed:Connect(function()
			part2:Destroy()
		end)
		tween2:Play()

		if count % 5 == 0 then
			local clone = script.Curvedring:Clone()
			clone.Size = createVector(1, 3, 1)
			clone.Transparency = 0.1
			clone.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			clone.Parent = _WorldOrigin
			local tween3 = TweenService:Create(
				clone,
				TweenInfo.new(0.3 * (0.5 + v2 * 0.5), Enum.EasingStyle.Circular),
				{
					Size = clone.Size + createVector(130, 0, 130),
					CFrame = clone.CFrame * CFrame.new(0, -30, 0),
					Transparency = 1
				}
			)
			tween3.Completed:Connect(function()
				clone:Destroy()
			end)
			tween3:Play()
		end

		if count % 2 == 0 then
			local v9 = cFrame * Vector3.new(0, 0, -250 * v2)
			local v10 = 22 * (0.75 + v2)
			local v11, v12, v13 = RayCastWhitelist(v9, -cFrame.UpVector * v10 * 1.05, { workspace.Map })

			if v11 then
				local v14 = alignCF(CFrame.new(Vector3.new(), cFrame.LookVector), v13 or createVector(0, 1, 0)) + v12

				for i = -1, 1, 2 do
					local v15 = v14 * Vector3.new(i * v10 / 2 * Random.new():NextNumber(0.9, 1.1), 0, 0) - v14.p
					local ground = Rock.new("Ground", {
						Scale = { v10 / 2 * 0.75, v10 / 2 * 0.8 },
						FadeIn = 0.1,
						FadeOut = 0.2,
						Lifetime = { 1, 1.1 }
					})
					ground:Spawn(v14)
					ground:TweenShift(v15, 0.13)
				end
			end
		end

		RunService.RenderStepped:Wait()
	end
end