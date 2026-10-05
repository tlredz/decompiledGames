local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local v = require3(ReplicatedStorage2.Common.Utils)
local currentCamera = workspace.CurrentCamera
local v2 = require3(ReplicatedStorage2.Controllers.CinematicController)
local v3 = require3(ReplicatedStorage2.Controllers.UI.DialogueController)
local v4 = {
	IntroductionA = {
		Title = "World Serpent",
		Text = v.ValueConvertor:FormatMarkupColor("[AAAAAARGH]", Color3.new(1, 0.8, 0)) .. " A mere speck in existence, coming to challenge me!?\nHow " .. v.ValueConvertor:FormatMarkupColor(
			"DAAARE",
			Color3.new(1, 0, 0)
		) .. " you trespass into my domain?",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventPart2_Phase1_VA1",
		Duration = 2
	},
	IntroductionB = {
		Title = "World Serpent",
		Text = "I hope you have brought more worthy warriors.",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventPart2_Phase1_VA2",
		Duration = 2
	},
	PreFight = {
		Title = "World Serpent",
		Text = " PAY WITH YOUR LIFE!",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventPart2_Phase1_VA3",
		Duration = 2
	}
}
return {
	Start = function(_, _, instance, p)
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
		TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
			BackgroundTransparency = 0
		}):Play()
		task.wait(1)
		local animationController = instance:WaitForChild("AnimationController")
		animationController:LoadAnimation(script.SpawnAnimation):Play()
		task.wait(1)

		for _, child in pairs(localPlayer.PlayerGui:GetChildren()) do
			if child.Name ~= "BlackScreen" then
				continue
			end

			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
			TweenService:Create(child.Frame, tweenInfo, {
				BackgroundTransparency = 1
			}):Play()
			local v5 = child
			task.delay(1, function()
				v5:Destroy()
			end)
		end

		currentCamera.FieldOfView = 20
		v2:CreateCinematicFromConfiguration(p.Awaken.Section1).Removed:Wait()
		v2:CreateCinematicFromConfiguration(p.Awaken.Section2).Removed:Wait()
		v.Thread.LoopFor(0.5, function(p2)
			currentCamera.FieldOfView = 20 + p2 * 20
		end)
		v2:CreateCinematicFromConfiguration(p.Awaken.Section3).Removed:Wait()
		v2:Shake(2, 2, 1)
		v3:SendText(v4.IntroductionA)
		v3:SendText(v4.IntroductionB)
		v3:SendText(v4.PreFight)
		v.Thread.LoopFor(1, function(p2)
			currentCamera.FieldOfView = 40 + p2 * -10
		end)
		v2:Shake(0.5, 0.2, 21)
		v2:CreateCinematicFromConfiguration(p.Awaken.Section4).Removed:Wait()
		task.wait(3)
		animationController:LoadAnimation(script.RiseAnimation):Play()
		currentCamera.FieldOfView = 20
		task.delay(1.5, function()
			v.Sounds:Play("LiveEventPart2_SerpentHeavyWingFlap")
			task.wait(1)
			v.Sounds:Play("LiveEvent_SerpentRoar3")
			v2:Shake(5, 10, 3)
			v.Thread.LoopFor(1.5, function(p2)
				currentCamera.FieldOfView = 20 + p2 * 20
			end)
			task.wait(1)
			local mouthJaw = instance:FindFirstChild("MouthJaw", true)

			if mouthJaw then
				local target = script.Beam.Target
				local origin = script.Beam.Origin
				target.Parent = mouthJaw
				origin.Parent = mouthJaw
				local position = target.Position
				v.Thread.LoopFor(0.5, function(p2)
					target.Position = (createVector(0, 0, 0)):Lerp(position, p2)
				end).Ended:Connect(function()
					task.wait(1.5)
					local turnOffVisuals = v.Visual:TurnOffVisuals(mouthJaw)
					task.delay(turnOffVisuals, function()
						target:Destroy()
						origin:Destroy()
					end)
				end)
			end
		end)
		v2:CreateCinematicFromConfiguration(p.FlyUpScene.Section1).Removed:Wait()
		v2:CreateCinematicFromConfiguration(p.FlyUpScene.Section2).Removed:Wait()
		v2:CreateCinematicFromConfiguration(p.FlyUpScene.Section3).Removed:Wait()
		v2:CreateCinematicFromConfiguration(p.FlyUpScene.Section4).Removed:Wait()
		v2:CreateCinematicFromConfiguration(p.FlyUpScene.Section5).Removed:Wait()
		task.wait(2)
		currentCamera.FieldOfView = 70
		v2:Reset()
		task.wait(3)
	end
}