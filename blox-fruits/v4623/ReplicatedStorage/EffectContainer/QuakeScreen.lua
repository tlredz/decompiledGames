local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local _ = game.ReplicatedStorage.Util
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
return function(p)
	local clone = script.ColorCorrection:Clone()
	clone.Parent = game.Lighting
	local v = currentCamera.ViewportSize.X / currentCamera.ViewportSize.Y * 4
	local clone2 = script.TremorSpike:Clone()
	clone2.Size = createVector(1, 1, 1) * v
	clone2.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -v / 2)
	clone2.Parent = workspace._WorldOrigin
	local now = false
	coroutine.resume(coroutine.create(function()
		while RunService.RenderStepped:Wait() and clone.Parent ~= nil do
			clone2.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -v / 2)

			if now then
				clone2.Transparency = 0.98 - math.min(tick() - now, 0.2)
			end
		end

		clone2:Destroy()
	end))
	wait(p.Delay * 0.7)
	Util.Sound:Play("BrokenGlass")
	now = tick()
	TweenService:Create(clone, TweenInfo.new(p.Delay * 0.15), {
		TintColor = Color3.new(1, 0, 0)
	}):Play()
	wait(p.Delay * 0.3)
	clone:Destroy()
	Util.CameraShaker:ShakeOnce(16, 12, 0.2, 2, createVector(1, 1, 1), createVector(1, 1, 5))
end