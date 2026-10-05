local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.Utils)
local currentCamera = workspace.CurrentCamera
local v2 = require3(ReplicatedStorage2.Controllers.CinematicController)
local v3 = require3(ReplicatedStorage2.Controllers.UI.DialogueController)
local v4 = {
	IntroductionA = {
		Title = "World Serpent",
		Text = "You think your tiny collection of ‘warriors’ will do anything to ME!?",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventPart2_Phase2_VA1",
		Duration = 2
	},
	IntroductionB = {
		Title = "World Serpent",
		Text = "You FOOLS!! You don't know what you're doing!",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventPart2_Phase2_VA2",
		Duration = 2
	}
}
return {
	Start = function(_, p, instance, p2)
		instance:WaitForChild("AnimationController"):LoadAnimation(script.PhaseAnimation):Play()
		local _ = p or workspace.Map:FindFirstChild("Fantasy")
		currentCamera.FieldOfView = 20
		v.Thread.LoopFor(1, function(p3)
			currentCamera.FieldOfView = 20 + p3 * 10
		end)
		task.delay(2.5, function()
			v.Sounds:Play("LiveEvent_SerpentRoar4")
			v2:Shake(5, 10, 0.5)
			local mouthJaw = instance:FindFirstChild("MouthJaw", true)

			if mouthJaw then
				local target = script.Beam.Target
				local origin = script.Beam.Origin
				target.Parent = mouthJaw
				origin.Parent = mouthJaw
				local position = target.Position
				v.Thread.LoopFor(0.25, function(p3)
					target.Position = (createVector(0, 0, 0)):Lerp(position, p3)
				end).Ended:Connect(function()
					task.wait(0.4)
					local turnOffVisuals = v.Visual:TurnOffVisuals(mouthJaw)
					task.delay(turnOffVisuals, function()
						target:Destroy()
						origin:Destroy()
					end)
				end)
			end

			task.wait(2.2)
			v.Sounds:Play("LiveEventPart2_SerpentHeavyWingFlap")
			task.wait(0.8)
			v.Sounds:Play("LiveEvent_SerpentRoar3")
			v2:Shake(5, 10, 2)
			v.Thread.LoopFor(1, function(p3)
				currentCamera.FieldOfView = 30 + p3 * 80
			end)
			task.wait(1)
			v.Thread.LoopFor(1, function(p3)
				currentCamera.FieldOfView = 110 + p3 * -60
			end)
			task.wait(1)
			v.Thread.LoopFor(1, function(p3)
				currentCamera.FieldOfView = 50 + p3 * -30
			end)
			task.wait(2)
			v.Sounds:Play("LiveEvent_SerpentRoar5")
			v2:Shake(5, 10, 3)
		end)
		v2:CreateCinematicFromConfiguration(p2.Phase2.Section1).Removed:Wait()
		v2:CreateCinematicFromConfiguration(p2.Phase2.Section2).Removed:Wait()
		v2:CreateCinematicFromConfiguration(p2.Phase2.Section3).Removed:Wait()
		v2:CreateCinematicFromConfiguration(p2.Phase2.Section4).Removed:Wait()
		v2:CreateCinematicFromConfiguration(p2.Phase2.Section5).Removed:Wait()
		v2:CreateCinematicFromConfiguration(p2.Phase2.Section6).Removed:Wait()
		v2:CreateCinematicFromConfiguration(p2.Phase2.Section7).Removed:Wait()
		task.delay(2, function()
			v3:SendText(v4.IntroductionA)
			v3:SendText(v4.IntroductionB)
		end)
		task.wait(15)
		v2:Reset()
		currentCamera.FieldOfView = 70
		task.wait(3)
	end
}