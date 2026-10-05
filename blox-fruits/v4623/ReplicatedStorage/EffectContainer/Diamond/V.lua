local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(p)
	local root = p.Root

	if not root or (root.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
		return
	end

	Util.Sound:Play("DiamondCharge", root)
	local attachment = Instance.new("Attachment")
	attachment.Parent = root
	local clone = script.ParticleEmitter:Clone()
	clone.Parent = attachment
	local lastTime = tick()

	while tick() - lastTime < 0.3 - (masterClock:GetTime() - p.Timestamp) do
		for _ = 1, 6 do
			local color = math.random() > 0.5 and Color3.fromRGB(150, 255, 255) or Color3.fromRGB(190, 255, 255)
			local v = 25 + math.random() * 10
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.CFrame = CFrame.new(root.Position) * CFrame.Angles(
				3.141592653589793 * (math.random() - 0.5) * 2,
				3.141592653589793 * (math.random() - 0.5) * 2,
				3.141592653589793 * (math.random() - 0.5) * 2
			)
			part.Size = createVector(1, 1, 1)
			part.Color = color
			part.Transparency = 0
			part.Material = "Neon"
			local specialMesh = Instance.new("SpecialMesh")
			specialMesh.MeshType = "Sphere"
			specialMesh.Scale = createVector(0.1, 0.1, 1.2) * v
			specialMesh.Offset = Vector3.new(0, 0, -math.random(30, 50))
			specialMesh.Parent = part
			part.Parent = _WorldOrigin
			local tween = TweenService:Create(specialMesh, TweenInfo.new(0.1 + math.random() * 0.1), {
				Scale = Vector3.new(),
				Offset = Vector3.new()
			})
			tween.Completed:Connect(function()
				part:Destroy()
			end)
			tween:Play()
		end

		wait()
	end

	wait(0.1)
	Util.Sound:Play("DiamondFlare", root)
	wait(0.1)
	local clone2 = script.ActivationRing:Clone()
	clone2.Size = NumberSequence.new(0, 100)
	clone2.Parent = attachment
	clone2:Emit(1)

	for i = 1, 8 do
		clone.Size = NumberSequence.new(0, i * 14)

		for _ = 1, 6 do
			local color = math.random() > 0.5 and Color3.fromRGB(150, 255, 255) or Color3.fromRGB(190, 255, 255)
			local v = (25 + math.random() * 10) * 1.5
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.CFrame = CFrame.new(root.Position) * CFrame.Angles(
				3.141592653589793 * (math.random() - 0.5) * 2,
				3.141592653589793 * (math.random() - 0.5) * 2,
				3.141592653589793 * (math.random() - 0.5) * 2
			)
			part.Size = createVector(1, 1, 1)
			part.Color = color
			part.Transparency = 0
			part.Material = "Neon"
			local specialMesh = Instance.new("SpecialMesh")
			specialMesh.MeshType = "Sphere"
			specialMesh.Scale = createVector(0.1, 0.1, 1.5) * v
			specialMesh.Parent = part
			part.Parent = _WorldOrigin
			local tween = TweenService:Create(specialMesh, TweenInfo.new(0.25 + math.random() * 0.1), {
				Scale = Vector3.new(),
				Offset = Vector3.new(0, 0, -math.random(30, 50) * 2)
			})
			tween.Completed:Connect(function()
				part:Destroy()
			end)
			tween:Play()
		end

		RunService.RenderStepped:Wait()
	end

	clone.Enabled = false
	clone2.Enabled = false
	local lastTime2 = tick()

	while tick() - lastTime2 < 0.75 do
		clone.Size = NumberSequence.new(0, 112 - 102 * (tick() - lastTime2) / 0.75)
		RunService.RenderStepped:Wait()
	end

	wait(0.25)
	attachment:Destroy()
end