workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(data)
	local cFrame = data.CFrame
	local targetCFrame = data.TargetCFrame
	local speed = data.Speed or 220

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 500 then
		return
	end

	Util.Sound:Play("Throw", cFrame)
	local v = math.min(300, (cFrame.p - targetCFrame.p).magnitude)
	local cframe = CFrame.new(cFrame.p, targetCFrame.p)
	local v2 = cframe * CFrame.new(0, 0, -v)
	local clone = game.ReplicatedStorage.Assets.Models.Shard:Clone()
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
	local v7 = math.max(v / speed - v6, 0)
	local lastTime = tick()

	while tick() - lastTime < v7 do
		local v8 = math.min(1, (tick() - lastTime) / v7)
		local _ = tick() - lastTime
		local v9 = cubicBezier(v8, cframe, v4, v5, v2)
		clone.CFrame = CFrame.new(v9.p, v9.p - (clone.CFrame.p - v9.p).unit)
		RunService.RenderStepped:Wait()
	end

	Util.Sound:Play("IceExplosion", v2.p)
	Effect.new("BasicExplosion"):replicate({
		Position = v2.p,
		Size = { 0, 27.5 },
		Color = {
			Inner = Color3.new(1, 1, 1),
			Outer = clone.Color
		},
		Quality = 1,
		Duration = 0.25
	})
	clone:Destroy()
end