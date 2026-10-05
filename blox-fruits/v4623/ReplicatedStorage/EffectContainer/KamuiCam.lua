workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local _ = workspace._WorldOrigin
local _ = workspace.Map
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(_)
	local currentCamera = workspace.CurrentCamera
	sound:Play("ElectricBallShot", game.Players.LocalPlayer.Character.Head)
	TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.5), {
		FieldOfView = 1
	}):Play()
	local lastTime = tick()

	while tick() - lastTime < 0.5 do
		local RunService = game:GetService("RunService")
		RunService.RenderStepped:Wait()
		currentCamera.CFrame *= CFrame.Angles(0, 0, 12 * (tick() - lastTime))
	end

	TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.5), {
		FieldOfView = 70
	}):Play()
end