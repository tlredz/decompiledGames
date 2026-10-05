local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(game.ReplicatedStorage.FX)
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(data)
	local origin = data.Origin
	local target = data.Target

	if (target - workspace.CurrentCamera.CFrame.p).magnitude > 1000 or masterClock:GetTime() - data.Timestamp > 2.5 then
		return
	end

	local cframe = CFrame.new(origin, target)
	local magnitude = (origin - target).magnitude
	Util.Sound:Play("FireFistBeam", origin)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Size = createVector(1, 1, 1)
	part.Color = Color3.new(1, 0.75, 0.35)
	part.Material = "Neon"
	part.CFrame = cframe
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = "Sphere"
	specialMesh.Scale = Vector3.new()
	specialMesh.Parent = part
	part.Parent = workspace._WorldOrigin
	local part2 = Instance.new("Part")
	part2.Anchored = true
	part2.CanCollide = false
	part2.Size = createVector(1, 1, 1)
	part2.Color = Color3.new(1, 0.75, 0.35)
	part2.Material = "Neon"
	part2.CFrame = cframe
	local specialMesh2 = Instance.new("SpecialMesh")
	specialMesh2.MeshType = "Sphere"
	specialMesh2.Scale = Vector3.new()
	specialMesh2.Parent = part2
	part2.Parent = workspace._WorldOrigin
	local part3 = Instance.new("Part")
	part3.Anchored = true
	part3.CanCollide = false
	part3.Size = createVector(1, 1, 1)
	part3.Color = Color3.new(1, 0.75, 0.35)
	part3.Material = "Neon"
	part3.CFrame = cframe * CFrame.Angles(0, -1.5707963267948966, 0)
	local specialMesh3 = Instance.new("SpecialMesh")
	specialMesh3.MeshType = "Cylinder"
	specialMesh3.Scale = Vector3.new()
	specialMesh3.Parent = part3
	part3.Parent = workspace._WorldOrigin
	local beamLayerTemplate = FX:WaitForChild("BeamLayerTemplate")
	local color = Color3.new(1, 0.1, 0.1)
	local v = {}

	for _ = 0, 360, 45 do
		local clone = beamLayerTemplate:Clone()
		clone.Color = ColorSequence.new(color)
		clone.Enabled = false
		clone.TextureLength = 22.5
		clone.TextureSpeed = 15
		clone.Width0 = 0
		clone.Width1 = 0
		clone.Transparency = NumberSequence.new(0)
		local attachment = Instance.new("Attachment")
		local attachment2 = Instance.new("Attachment")
		clone.Attachment0 = attachment
		clone.Attachment1 = attachment2
		attachment.Parent = part3
		attachment2.Parent = part3
		clone.Parent = part3
		table.insert(v, {
			B = clone,
			a0 = attachment,
			a1 = attachment2
		})
	end

	for _, v2 in next, v, nil do
		v2.B.Enabled = true
	end

	local lastTime = tick()

	while tick() - lastTime < 1.4 do
		local v2 = math.min(1, (tick() - lastTime) / 1.4)
		local v3 = math.clamp(magnitude * v2, 0, magnitude)
		local v4 = v2 * 26 + 8 + math.sin(v2 * 40) * 2.5

		if v2 > 0.8 then
			v4 = math.max(0, 0.8 - (v2 - 0.8) / 0.2 * 0.8) * 34
		end

		specialMesh.Scale = Vector3.new(v4, v4, v4)
		specialMesh.Offset = Vector3.new(0, 0, -v4 / 2)
		specialMesh2.Scale = specialMesh.Scale
		specialMesh2.Offset = Vector3.new(0, 0, -v3 - v4 / 2)
		specialMesh3.Scale = Vector3.new(v3, v4, v4)
		specialMesh3.Offset = Vector3.new(-v3 / 2 - v4 / 2, 0, 0)
		local width = v4 * 3.141592653589793 * 2 / 8

		for k, v6 in next, v, nil do
			local B = v6.B
			local a0 = v6.a0
			local a1 = v6.a1
			local v7 = math.rad(45 * (k - 1))
			local v8 = CFrame.new(0, 0, -v4 / 4) * CFrame.Angles(0, 0, v7) * CFrame.new(0, v4 / 2 + 0.1, 0) * CFrame.Angles(
				0,
				0,
				1.57
			)
			B.Width0 = width
			B.Width1 = B.Width0
			a0.CFrame = CFrame.Angles(0, 1.57, 0) * v8
			a1.CFrame = CFrame.Angles(0, 1.57, 0) * CFrame.new(0, 0, specialMesh3.Offset.X * 2 + v4 / 2) * v8
			B.TextureLength = v3 / 22.5
		end

		RunService.RenderStepped:Wait()
	end

	part3:Destroy()
	part:Destroy()
	part2:Destroy()
end