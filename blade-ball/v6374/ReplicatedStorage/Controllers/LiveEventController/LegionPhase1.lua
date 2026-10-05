local createVector = vector.create
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
		Text = "You still haven’t learned, have you? My master may have perished, but his legacy lives on.",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventLegion_Phase1_VA1",
		Duration = 2
	},
	IntroductionB = {
		Title = "Sentinel",
		Text = "His reign of terror will continue, and I will make sure of it.",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventLegion_Phase1_VA2",
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
		local track = clone.Humanoid.Animator:LoadAnimation(script.SentinelPhase1Intro)
		local v5 = require3(script.CameraKeypointA)
		track:Play()
		maid:GiveTask(v.Thread.Delay(5.5, function()
			v.Sounds:Play("LiveEventLegion_SuperJump")
		end))
		maid:GiveTask(v.Thread.Delay(8, function()
			v.Visual:PlayEffectsAt(
				CFrame.new(clone:GetPivot().Position + createVector(0, -2, 0)),
				script.FloorExplosion:Clone()
			)
		end))
		maid:GiveTask(v.Thread.Delay(12, function()
			v3:SendText(v4.IntroductionA)
		end))
		maid:GiveTask(v.Thread.Delay(16, function()
			v3:SendText(v4.IntroductionB)
		end))
		maid:GiveTask(v.Thread.Delay(30, function()
			for _, child in pairs(p.CameraLocations.Minions:GetChildren()) do
				local clone2 = script.RoyalGuard:Clone()
				clone2:PivotTo(child:GetPivot())
				clone2.Parent = folder
				clone2.Humanoid.Animator:LoadAnimation(script.RoyalGuardSpawns):Play()
				v.Sounds:PlayAt(child:GetPivot().Position, "LiveEventLegion_SummonGuards")
				task.wait(0.3)
			end
		end))
		local signal = v.Signal.new()
		maid.TrackA = v2:PlayPointsWithAnimationTrack(track, p.CameraLocations.SentinelPhaseCamera:GetPivot(), v5).Removed:Connect(function()
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