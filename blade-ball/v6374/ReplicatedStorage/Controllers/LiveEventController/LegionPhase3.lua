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
		Title = "Frost Dragon",
		Text = "WE END THIS NOW!",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventLegion_Phase1_VA9",
		Duration = 2
	}
}
return {
	Start = function(_, maid, p)
		local folder = Instance.new("Folder")
		folder.Name = "CinematicContainer"
		folder.Parent = workspace
		local clone = script.LegionDragon:Clone()
		clone:PivotTo(p.CameraLocations.DragonSpawn:GetPivot())
		clone.Parent = folder
		local animator = clone.AnimationController.Animator
		v.Sounds:Play("LiveEventLegion_WingFlapStart")
		maid:GiveTask(v.Thread.Delay(1, function()
			local WAIT_INTERVAL = 0.8
			v.Sounds:Play("LiveEventLegion_WingFlap")
			task.wait(WAIT_INTERVAL)
			v.Sounds:Play("LiveEventLegion_WingFlap")
			task.wait(WAIT_INTERVAL)
			v.Sounds:Play("LiveEventLegion_WingFlap")
			task.wait(WAIT_INTERVAL)
		end))
		maid:GiveTask(v.Thread.Delay(8, function()
			v.Sounds:Play("LiveEventLegion_SuperJump")
			task.wait(0.5)
			v.Sounds:Play("LiveEventLegion_WingFlap")
			task.wait(2)
			v.Sounds:Play("LiveEventLegion_FrostDragonRoar")
		end))
		maid:GiveTask(v.Thread.Delay(4, function()
			v.Sounds:Play("LiveEventLegion_FrostDragonSlam")
			v3:SendText(v4.IntroductionA)
		end))
		local signal = v.Signal.new()
		local track = animator:LoadAnimation(script.DragonAnimation)
		local v5 = require3(script.CameraKeypointA)
		track:Play()
		maid.Track = v2:PlayPointsWithAnimationTrack(track, p.CameraLocations.DragonCamera:GetPivot(), v5).Removed:Connect(function()
			signal:Fire()
		end)
		maid:GiveTask(function()
			signal:Fire()
		end)
		signal:Wait()
		v2:Reset()
		folder:Destroy()
	end
}