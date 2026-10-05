local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Debris = game:GetService("Debris")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3.Controllers.CinematicController)
local v2 = require3(ReplicatedStorage2.Common.Utils)
return {
	Start = function(_)
		v:Shake(3, 15, 5)
		v2.Sounds:Play("LiveEvent_SerpentRoarIntro")
		task.wait(3)
		local screenGui = Instance.new("ScreenGui")
		Debris:AddItem(screenGui, 10)
		screenGui.DisplayOrder = 99
		screenGui.Name = "BlackScreen"
		screenGui.ResetOnSpawn = false
		screenGui.Parent = localPlayer.PlayerGui
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 1, 36)
		frame.Position = UDim2.new(0, 0, 0, -36)
		frame.BackgroundColor3 = Color3.new(0, 0, 0)
		frame.BorderSizePixel = 0
		frame.BackgroundTransparency = 1
		frame.Parent = screenGui
		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
		local TweenService = game:GetService("TweenService")
		TweenService:Create(frame, tweenInfo, {
			BackgroundTransparency = 0
		}):Play()
		task.wait(1)
	end
}