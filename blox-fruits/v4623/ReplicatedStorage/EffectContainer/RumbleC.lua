local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local _ = Util.Sound
local masterClock = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(data)
	local origin = data.Origin
	local target = data.Target

	if (target - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
		return
	end

	local v = masterClock:GetTime() - data.Timestamp

	if v > 4 then
		return
	end

	local v2 = Util.Sound:Play("Thunder", origin)
	local cframe = CFrame.new(origin, target)
	local magnitude = (origin - target).magnitude
	local tweens = {}

	for i = 0, 7 do
		local clone = game.ReplicatedStorage.Assets.Models.ThorCloud:Clone()
		clone.CFrame = CFrame.new(origin) * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) + Vector3.new(
			math.sin(i * 1.57) * i * 12,
			0,
			math.cos(i * 1.57) * i * 12
		)
		clone.Mesh.Scale = Vector3.new()
		TweenService:Create(clone.Mesh, TweenInfo.new(1, Enum.EasingStyle.Quad), {
			Scale = Vector3.new(25, 9 + math.random() * 2, 30) * (1 + math.random() * 0.5) * 5
		}):Play()
		clone.Parent = workspace._WorldOrigin
		local tween = TweenService:Create(clone.Mesh, TweenInfo.new(2, Enum.EasingStyle.Quad), {
			Scale = Vector3.new()
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		table.insert(tweens, tween)
	end

	wait(0.45 - v)
	Util.Sound:Play("BigBangFire", target)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Size = createVector(1, 1, 1)
	part.Color = Color3.fromRGB(128, 187, 219)
	part.Material = "Neon"
	part.CFrame = CFrame.new(origin)
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = "Sphere"
	specialMesh.Scale = Vector3.new()
	specialMesh.Parent = part
	part.Parent = workspace._WorldOrigin
	local part2 = Instance.new("Part")
	part2.Anchored = true
	part2.CanCollide = false
	part2.Size = createVector(1, 1, 1)
	part2.Color = Color3.fromRGB(128, 187, 219)
	part2.Material = "Neon"
	part2.CFrame = cframe * CFrame.Angles(0, -1.5707963267948966, 0)
	local specialMesh2 = Instance.new("SpecialMesh")
	specialMesh2.MeshType = "Cylinder"
	specialMesh2.Scale = Vector3.new()
	specialMesh2.Parent = part2
	part2.Parent = workspace._WorldOrigin
	local beamLayerTemplate = FX:WaitForChild("BeamLayerTemplate")
	local color = Color3.new(0, 1, 1)
	local v3 = {}

	for _ = 0, 360, 45 do
		local clone = beamLayerTemplate:Clone()
		clone.Color = ColorSequence.new(color)
		clone.Enabled = false
		clone.TextureLength = 10
		clone.TextureSpeed = 10
		clone.Width0 = 0
		clone.Width1 = 0
		clone.Transparency = NumberSequence.new(0)
		local attachment = Instance.new("Attachment")
		local attachment2 = Instance.new("Attachment")
		clone.Attachment0 = attachment
		clone.Attachment1 = attachment2
		attachment.Parent = part2
		attachment2.Parent = part2
		clone.Parent = part2
		table.insert(v3, {
			B = clone,
			a0 = attachment,
			a1 = attachment2
		})
	end

	for _, v4 in next, v3, nil do
		v4.B.Enabled = true
	end

	local lastTime = tick()
	local flag = false

	while tick() - lastTime < 4 do
		local v4 = math.min(1, (tick() - lastTime) / 4)
		local v5 = math.clamp(magnitude * 9 * v4, 0, magnitude)

		if v5 == magnitude and not flag then
			part.CFrame = CFrame.new(target)
			local clone = FX:WaitForChild("ThorDust"):Clone()
			clone.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 30), NumberSequenceKeypoint.new(1, 10) })
			clone.Parent = part
			Util.Sound:Play("GenericExplosion2", target)
			flag = true
		end

		if v4 > 0.75 then
			v4 = math.max(0, 0.75 - (v4 - 0.75) / 0.25 * 0.75)
			part.ThorDust.Lifetime = NumberRange.new(v4)
		end

		local v6 = v4 ^ 0.55 * 80
		specialMesh2.Scale = Vector3.new(v5, v6, v6)
		specialMesh2.Offset = Vector3.new(-v5 / 2, 0, 0)

		if flag then
			specialMesh.Scale = createVector(1, 1, 1) * v6 * (math.sin(elapsedTime() * 15) ^ 2 * 0.4 + 1.3)
		end

		local width = v6 * 3.141592653589793 * 2 / 8

		for k, v8 in next, v3, nil do
			local B = v8.B
			local a0 = v8.a0
			local a1 = v8.a1
			local v9 = math.rad(45 * (k - 1))
			local v10 = CFrame.Angles(0, 0, v9) * CFrame.new(0, v6 / 2 + 0.1, 0) * CFrame.Angles(0, 0, 1.57)
			B.Width0 = width
			B.Width1 = B.Width0
			a0.CFrame = CFrame.Angles(0, 1.57, 0) * v10
			a1.CFrame = CFrame.Angles(0, 1.57, 0) * CFrame.new(0, 0, -v5) * v10
		end

		RunService.RenderStepped:Wait()
	end

	part2:Destroy()

	for _, v4 in next, tweens, nil do
		v4:Play()
	end

	part.Transparency = 1
	part.ThorDust.Enabled = false
	Util.Sound:FadeOut(v2, 0.7)
	wait(0.7)
	part:Destroy()
end