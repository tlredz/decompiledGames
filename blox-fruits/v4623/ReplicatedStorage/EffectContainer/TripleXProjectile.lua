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

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
		return
	end

	local v = math.min(250, (cFrame.p - targetCFrame.p).magnitude)
	local cframe = CFrame.new(cFrame.p, targetCFrame.p)
	local v2 = cframe * CFrame.new(0, 0, -v)
	local clone = game.ReplicatedStorage.Assets.Models.DragonHeadBig:Clone()

	for _, trail in pairs(clone:GetChildren()) do
		if not trail:IsA("Trail") then
			continue
		end

		trail.Color = ColorSequence.new(Color3.fromRGB(128, 187, 219))
		trail.Lifetime *= 1.5
	end

	clone.Color = Color3.fromRGB(128, 187, 219)
	clone.CFrame = cframe
	clone.Parent = workspace._WorldOrigin

	local function lerp(object, p, p2)
		return object:lerp(p, p2)
	end

	Random.new()
	local v3 = masterClock:GetTime() - data.Timestamp
	local v4 = math.max(v / 300 - v3, 0)
	local lastTime = tick()

	while tick() - lastTime < v4 do
		local v5 = math.min(1, (tick() - lastTime) / v4)
		local now = tick()
		local v6 = cframe:Lerp(v2, v5) * CFrame.new(math.sin(now * 6 * 4) * 13.5, math.cos(now * 6 * 4) * 13.5, 0)
		clone.CFrame = CFrame.new(v6.p, v6.p - (clone.CFrame.p - v6.p).unit)
		RunService.RenderStepped:Wait()
	end

	local tween = TweenService:Create(clone, TweenInfo.new(0.5), {
		Size = createVector(0.05, 0.05, 0.05)
	})
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
end