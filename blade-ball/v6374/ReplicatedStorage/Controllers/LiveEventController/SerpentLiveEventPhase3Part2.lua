local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local v = require3(ReplicatedStorage2.Common.Utils)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v2 = require3(ReplicatedStorage2.Controllers.CinematicController)
return {
	Start = function(_, _, instance, p)
		instance:WaitForChild("AnimationController"):LoadAnimation(script.FallDown):Play()
		task.delay(1, function()
			for _, child in pairs(localPlayer.PlayerGui:GetChildren()) do
				if child.Name ~= "BlackScreen" then
					continue
				end

				local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
				TweenService:Create(child.Frame, tweenInfo, {
					BackgroundTransparency = 1
				}):Play()
				local v3 = child
				task.delay(1, function()
					v3:Destroy()
				end)
			end
		end)
		v2:CreateCinematicFromConfiguration(p.GoingDown.Section1).Removed:Wait()
		v.Sounds:Play("LiveEvent_SerpentRoar3")
		v2:Shake(5, 2, 2.5)
		local screenGui = Instance.new("ScreenGui")
		local frame = Instance.new("Frame")
		Debris:AddItem(screenGui, 10)
		screenGui.DisplayOrder = 99
		screenGui.Name = "BlackScreen"
		screenGui.ResetOnSpawn = false
		screenGui.Parent = localPlayer.PlayerGui
		frame.Size = UDim2.new(1, 0, 1, 36)
		frame.Position = UDim2.new(0, 0, 0, -36)
		frame.BackgroundColor3 = Color3.new(0, 0, 0)
		frame.BorderSizePixel = 0
		frame.BackgroundTransparency = 1
		frame.Parent = screenGui
		task.delay(1.5, function()
			TweenService:Create(frame, TweenInfo.new(1, Enum.EasingStyle.Linear), {
				BackgroundTransparency = 0
			}):Play()
		end)
		v2:CreateCinematicFromConfiguration(p.GoingDown.Section2).Removed:Wait()
		task.wait(3)
		v2:Reset()

		for _, child in pairs(localPlayer.PlayerGui:GetChildren()) do
			if child.Name ~= "BlackScreen" then
				continue
			end

			TweenService:Create(child.Frame, TweenInfo.new(1, Enum.EasingStyle.Linear), {
				BackgroundTransparency = 1
			}):Play()
			local v3 = child
			task.delay(1, function()
				v3:Destroy()
			end)
		end

		task.wait(4)
	end
}