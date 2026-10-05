local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(game.ReplicatedStorage.FX)
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

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 500 then
		return
	end

	local v = math.min(250, (cFrame.p - targetCFrame.p).magnitude)
	local cframe = CFrame.new(cFrame.p, targetCFrame.p)
	local v2 = cframe * CFrame.new(0, 0, -v)
	local clone = game.ReplicatedStorage.Assets.Models.DragonHead:Clone()
	local clone2 = FX:WaitForChild("Fire"):Clone()
	clone2.Parent = clone

	for _, trail in pairs(clone:GetChildren()) do
		if trail:IsA("Trail") then
			trail.Color = ColorSequence.new(Color3.new(1, 0.5, 0))
		end
	end

	clone.Color = Color3.new(1, 0.5, 0)
	clone.CFrame = cframe
	clone.Parent = workspace._WorldOrigin

	local function lerp(object, p, p2)
		return object:lerp(p, p2)
	end

	local v3 = v / 20
	local random = Random.new()
	local v4 = cframe:Lerp(v2, 0.3333333333333333) * CFrame.new(
		random:NextNumber(-5, 5) * v3,
		random:NextNumber(-1, 5) * v3,
		0
	)
	local v5 = cframe:Lerp(v2, 0.6666666666666666) * CFrame.new(
		random:NextNumber(-5, 5) * v3,
		random:NextNumber(-1, 5) * v3,
		0
	)

	local function cubicBezier(p, cframe2, object, object2, p2)
		local lerped = cframe2:lerp(object, p)
		local lerped2 = object:lerp(object2, p)
		local lerped3 = object2:lerp(p2, p)
		return (lerped:lerp(lerped2, p):lerp(lerped2:lerp(lerped3, p), p))
	end

	local v6 = masterClock:GetTime() - data.Timestamp
	local v7 = math.max(v / 200 - v6, 0)
	local lastTime = tick()

	while tick() - lastTime < v7 do
		local v8 = math.min(1, (tick() - lastTime) / v7)
		local now = tick()
		local v9 = cubicBezier(v8, cframe, v4, v5, v2) * CFrame.new(
			math.sin(now * 6 * 4) * 20 * (1 - v8 ^ 1.6),
			math.cos(now * 6 * 4) * 20 * (1 - v8 ^ 1.6),
			0
		)
		clone.CFrame = CFrame.new(v9.p, v9.p - (clone.CFrame.p - v9.p).unit)
		RunService.RenderStepped:Wait()
	end

	clone2.Enabled = false
	local tween = TweenService:Create(clone, TweenInfo.new(0.5), {
		Size = createVector(0.05, 0.05, 0.05)
	})
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
end