local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local currentCamera = workspace.CurrentCamera
local v = require3(ReplicatedStorage2.Common.Utils)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v2 = require3(ReplicatedStorage2.Controllers.CinematicController)
local v3 = require3(ReplicatedStorage2.Controllers.UI.DialogueController)
local v4 = {
	PreChange = {
		Title = "World Serpent",
		Text = "The audacity to challenge me further. Your arrogance will be your downfall.",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventPart2_Phase3_VA1",
		Duration = 2
	}
}
return {
	Start = function(_, _, instance, p)
		instance:WaitForChild("AnimationController"):LoadAnimation(script.RiseAnimation):Play()
		currentCamera.FieldOfView = 50
		task.delay(2.5, function()
			v.Sounds:Play("LiveEventPart2_SerpentHeavyWingFlap")
			v2:Shake(5, 10, 3)
			v.Thread.LoopFor(1.5, function(p2)
				currentCamera.FieldOfView = 50 - p2 * 30
			end).Ended:Connect(function()
				v.Thread.LoopFor(0.5, function(p2)
					currentCamera.FieldOfView = 20 + p2 * 50
				end)
			end)
		end)
		v2:CreateCinematicFromConfiguration(p.GoingUp.Section1).Removed:Wait()
		v2:CreateCinematicFromConfiguration(p.GoingUp.Section2).Removed:Wait()
		v2:CreateCinematicFromConfiguration(p.GoingUp.Section3).Removed:Wait()
		v.Thread.LoopFor(0.5, function(p2)
			currentCamera.FieldOfView = 70 - p2 * 40
		end)
		task.delay(1, function()
			v2:Shake(3, 15, 5)
			local screenGui = Instance.new("ScreenGui")
			Debris:AddItem(screenGui, 30)
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
			TweenService:Create(frame, TweenInfo.new(1, Enum.EasingStyle.Linear), {
				BackgroundTransparency = 0
			}):Play()
			task.wait(1)
			v.Sounds:Play("LiveEvent_SerpentRoarIntro")
			task.wait(1)
			v3:SendText(v4.PreChange)
		end)
		v2:CreateCinematicFromConfiguration(p.GoingUp.Section4).Removed:Wait()
		task.wait(7)
		v2:Reset()
		currentCamera.FieldOfView = 70
	end
}