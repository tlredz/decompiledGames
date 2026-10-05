local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local _ = Util.MasterClock
local Lightning = require(game.ReplicatedStorage.Util.Lightning)
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(data)
	local cFrame = data.CFrame
	local start = data.Start

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
		return
	end

	local color = data.Color
	local radius = data.Radius
	game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

	for _ = 1, 2 do
		Lightning.new({
			Lifetime = 0.1 + math.random() * 0.2,
			DrawType = "Singular",
			Colors = {
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, color)
			},
			Sizes = {
				{
					Size = 0.3,
					Time = 0
				},
				{
					Size = 2,
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
					Position = cFrame.p
				},
				End = {
					Position = start.p
				}
			},
			ArcSize = {
				Min = 20,
				Max = 30
			},
			ChangesSegmentOffset = true,
			OffsetChangePercent = {
				EqualOrBelow = 0.15,
				Bounds = { 0, 1 }
			}
		})
	end

	local v = sound:Play("ElectricExplosionLong3", cFrame)
	wait(0.15)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Color = Color3.new(1, 1, 1)
	part.Size = createVector(1, 1, 1)
	part.Material = "Neon"
	part.CFrame = cFrame
	part.Transparency = 0
	local specialMesh = Instance.new("SpecialMesh", part)
	specialMesh.MeshType = Enum.MeshType.Sphere
	specialMesh.Scale = Vector3.new()
	part.Parent = workspace._WorldOrigin
	TweenService:Create(specialMesh, TweenInfo.new(1.1332, Enum.EasingStyle.Circular), {
		Scale = createVector(1, 1, 1) * radius
	}):Play()
	local lastTime = tick()
	local count = 0

	while tick() - lastTime < 1.1332 do
		local origin = cFrame * CFrame.Angles(
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2
		)
		local v3 = origin * CFrame.new(0, 0, -radius - 10)
		count += 1

		if count % 3 == 0 then
			Effect.new("ExpandRing"):replicate({
				Origin = origin,
				Size = { createVector(1, 1, 0.02) * radius * 0.25, createVector(1, 1, 0.02) * radius * 2.5 },
				Duration = 0.2
			})
			Lightning.new({
				Lifetime = 0.1 + math.random() * 0.2,
				DrawType = "Singular",
				Colors = {
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, color)
				},
				Sizes = {
					{
						Size = 0.3,
						Time = 0
					},
					{
						Size = 2,
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
						Position = cFrame.p
					},
					End = {
						Position = v3.p
					}
				},
				ArcSize = {
					Min = 20,
					Max = 40
				},
				ChangesSegmentOffset = true,
				OffsetChangePercent = {
					EqualOrBelow = 0.15,
					Bounds = { 0, 1 }
				}
			})
		end

		RunService.RenderStepped:Wait()
	end

	sound:FadeOut(v, 0.5)
	TweenService:Create(specialMesh, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		Scale = Vector3.new()
	}):Play()
	wait(0.3)
	part:Destroy()
end