local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local spiralWind = script.SpiralWind
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(p)
	local HRP = p.HRP

	if (workspace.CurrentCamera.CFrame.p - HRP.Position).Magnitude > 300 then
		return
	end

	local clone = spiralWind:Clone()
	clone.Size = createVector(8, 8, 9)
	clone.Transparency = 1
	clone.Parent = _WorldOrigin
	clone.Color = Color3.new(1, 0.5, 0)
	local _ = HRP.CFrame
	TweenService:Create(clone, TweenInfo.new(0.1), {
		Transparency = 0
	}):Play()
	local lastTime = tick()
	tick()

	while tick() - lastTime < 0.75 do
		local v = tick() - lastTime
		local v2 = math.min(1, v / 0.1)
		local v3 = math.min(1, v / 1.75) + 1
		local cFrame = HRP.CFrame
		clone.Size = Vector3.new(9, math.sin(v * 20) * 4 + 11, 10) * v3 * v2
		clone.CFrame = cFrame * CFrame.Angles(0, v * 40, 0) * CFrame.Angles(-1.5707963267948966, 0, 1.5707963267948966)
		clone.Color = Color3.new(1, math.sin(v * 30) * 0.04 + 0.4, 0)
		RunService.RenderStepped:Wait()
	end

	TweenService:Create(clone, TweenInfo.new(0.09), {
		Size = createVector(0.05, 0.05, 0.05),
		Transparency = 1
	}):Play()
	wait(0.2)
	clone:Destroy()
end