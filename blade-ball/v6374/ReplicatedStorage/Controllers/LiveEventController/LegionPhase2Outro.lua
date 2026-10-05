local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("Debris")
local Players = game:GetService("Players")
Players = Players.LocalPlayer
game:GetService("TweenService")
local v = require3(ReplicatedStorage2.Common.Utils)
local _ = workspace.CurrentCamera
local v2 = require3(ReplicatedStorage2.Controllers.CinematicController)
local v3 = require3(ReplicatedStorage2.Controllers.UI.DialogueController)
local v4 = {
	IntroductionA = {
		Title = "Sentinel",
		Text = "NOOOOOOOOOOOOOOOOOOOOOOOO",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventLegion_Phase1_VA8",
		Duration = 2
	}
}
return {
	Start = function(_, maid, p)
		local folder = Instance.new("Folder")
		folder.Name = "CinematicContainer"
		folder.Parent = workspace
		local clone = script.Sentinel:Clone()
		clone:PivotTo(p.CameraLocations.SentinelPhase1:GetPivot())
		clone.Parent = folder
		local animator = clone.Humanoid.Animator
		maid.Active = true
		maid:GiveTask(v.Thread.Delay(12, function()
			v3:SendText(v4.IntroductionA)
		end))
		maid:GiveTask(v.Thread.Delay(4, function()
			v.Sounds:Play("LiveEventLegion_StaffSlam")
			task.wait(1.25)

			if not maid.Active then
				return
			end

			v.Sounds:Play("LiveEventLegion_StaffSlam")
			task.wait(1)

			if not maid.Active then
				return
			end

			v.Sounds:Play("LiveEventLegion_StaffSlam")
			task.wait(0.75)

			if not maid.Active then
				return
			end

			v.Sounds:Play("LiveEventLegion_StaffCorruption")

			for _ = 1, 5 do
				task.wait(0.33)

				if not maid.Active then
					return
				end

				v.Sounds:Play("LiveEventLegion_StaffSlam")
			end

			task.wait(1)

			if not maid.Active then
				return
			end

			v.Sounds:Play("LiveEventLegion_StaffSlam")
		end))
		local signal = v.Signal.new()
		local track = animator:LoadAnimation(script.SentinelPhase1P1)
		local v5 = require3(script.CameraKeypointA)
		track:Play()
		maid:GiveTask(function()
			signal:Fire()
		end)
		v2:PlayPointsWithAnimationTrack(track, p.CameraLocations.SentinelPhaseCamera:GetPivot(), v5).Removed:Connect(function()
			signal:Fire()
		end)
		signal:Wait()
		v2:Reset()
		folder:Destroy()
	end
}