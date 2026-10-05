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
	local targetCFrame = data.TargetCFrame
	local speed = data.Speed or 220

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
		return
	end

	Util.Sound:Play("IceExplosion", cFrame.p)
	local v = math.min(200, (cFrame.p - targetCFrame.p).magnitude)
	local cframe = CFrame.new(cFrame.p, targetCFrame.p)
	local v2 = cframe * CFrame.new(0, 0, -v)
	local clone = game.ReplicatedStorage.Assets.Models.Shard:Clone()
	clone.Color = Color3.new(0.75, 1, 1)

	for _, trail in pairs(clone:GetDescendants()) do
		if not trail:IsA("Trail") then
			continue
		end

		trail.Color = ColorSequence.new(Color3.new(0.6, 1, 1), Color3.new(1, 1, 1))
		trail.LightEmission = 1
		trail.Lifetime *= 0.5
	end

	clone.CFrame = cframe
	clone.Parent = workspace._WorldOrigin

	local function lerp(object, p, p2)
		return object:lerp(p, p2)
	end

	local v3 = v / 30 + 1
	Random.new()
	local v4 = cframe:Lerp(v2, 0.3333333333333333) * CFrame.new(
		math.sign(math.random() - 0.5) * (1 + math.random()) * v3,
		math.sign(math.random() - 0.5) * (1 + math.random()) * v3,
		0
	)
	local v5 = cframe:Lerp(v2, 0.6666666666666666) * CFrame.new(
		math.sign(math.random() - 0.5) * (1 + math.random()) * v3,
		math.sign(math.random() - 0.5) * (1 + math.random()) * v3,
		0
	)

	local function cubicBezier(p, cframe2, object, object2, p2)
		local lerped = cframe2:lerp(object, p)
		local lerped2 = object:lerp(object2, p)
		local lerped3 = object2:lerp(p2, p)
		return (lerped:lerp(lerped2, p):lerp(lerped2:lerp(lerped3, p), p))
	end

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CFrame = cFrame + cFrame.LookVector * 2
	part.Size = createVector(1, 1, 1)
	part.Color = Color3.fromRGB(190, 255, 255)
	part.Transparency = 0.1
	part.Material = "Neon"
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = "Sphere"
	specialMesh.Scale = Vector3.new()
	specialMesh.Parent = part
	part.Parent = workspace._WorldOrigin
	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
	TweenService:Create(part, tweenInfo, {
		Transparency = 1
	}):Play()
	local tween = TweenService:Create(specialMesh, tweenInfo, {
		Scale = createVector(10.400001, 10.400001, 10.400001)
	})
	tween.Completed:Connect(function()
		part:Destroy()
	end)
	tween:Play()
	local clone2 = script.ThinRing:Clone()
	clone2.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0)
	clone2.Parent = workspace._WorldOrigin
	local tween2 = TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
		Size = createVector(26, 0, 26),
		Transparency = 1,
		CFrame = clone2.CFrame + cFrame.LookVector * 7
	})
	tween2.Completed:Connect(function()
		clone2:Destroy()
	end)
	tween2:Play()
	local v6 = masterClock:GetTime() - data.Timestamp
	local v7 = math.max(v / speed - v6, 0.05)
	local lastTime = tick()

	while tick() - lastTime < v7 do
		local v8 = cubicBezier(math.clamp((tick() - lastTime) / v7, 0.001, 1), cframe, v4, v5, v2)
		clone.CFrame = CFrame.new(v8.p, v8.p - (clone.CFrame.p - v8.p).unit)
		RunService.RenderStepped:Wait()
	end

	Util.Sound:Play("DiamondBreak", v2.p)
	Effect.new("Diamond.Hit"):replicate({
		Position = v2.p,
		Explode = true
	})
	clone:Destroy()
end