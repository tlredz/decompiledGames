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
local currentCamera = workspace.CurrentCamera
local v2 = require3(ReplicatedStorage2.Controllers.CinematicController)
local v3 = require3(ReplicatedStorage2.Controllers.UI.DialogueController)
local v4 = {
	IntroductionA = {
		Title = "Sentinel",
		Text = "First you prey on the sleeping. Then you TAKE WHAT WASN’T YOURS. Your luck ends now.",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventLegion_Phase1_VA4",
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
		local maid2 = v.Maid.new()

		for _, child in pairs(p.CameraLocations.MinionsPhase1P2:GetChildren()) do
			local clone2 = script.RoyalGuard:Clone()
			clone2:PivotTo(child:GetPivot())
			clone2.Parent = folder
			clone2.Humanoid.Animator:LoadAnimation(script.RoyalGuardDies):Play()
			maid2:GiveTask(clone2)
		end

		currentCamera.FieldOfView = 40
		local animator = clone.Humanoid.Animator
		maid:GiveTask(v.Thread.Delay(4, function()
			maid.FOVChange = v.Thread.LoopFor(1, function(p2)
				currentCamera.FieldOfView = 40 + 30 * p2
			end)
			maid2:Destroy()
		end))
		maid:GiveTask(v.Thread.Delay(12, function()
			v3:SendText(v4.IntroductionA)
		end))
		maid:GiveTask(function()
			currentCamera.FieldOfView = 70
		end)
		maid:GiveTask(v.Thread.Delay(5, function()
			v.Sounds:Play("LiveEventLegion_SuperJump")
		end))
		maid:GiveTask(v.Thread.Delay(7.5, function()
			v.Visual:PlayEffectsAt(
				CFrame.new(clone:GetPivot().Position + createVector(0, -2, 0)),
				script.FloorExplosion:Clone()
			)
		end))
		maid:GiveTask(v.Thread.Delay(23, function()
			v.Sounds:Play("LiveEventLegion_Roar1")
		end))
		local v5 = false
		local signal = v.Signal.new()
		maid:GiveTask(function()
			v5 = true
			signal:Fire()
		end)
		local track = animator:LoadAnimation(script.SentinelPhase1P1)
		local v6 = require3(script.CameraKeypointA)
		track:Play()
		maid.Track = v2:PlayPointsWithAnimationTrack(track, p.CameraLocations.SentinelPhaseCamera:GetPivot(), v6).Removed:Connect(function()
			signal:Fire()
		end)
		signal:Wait()

		if not v5 then
			local track2 = animator:LoadAnimation(script.SentinelPhase1P2)
			local v7 = require3(script.CameraKeypointB)
			track2:Play()
			maid.Track = v2:PlayPointsWithAnimationTrack(track2, p.CameraLocations.SentinelPhaseCamera:GetPivot(), v7).Removed:Connect(function()
				signal:Fire()
			end)
			signal:Wait()
		end

		v2:Reset()
		folder:Destroy()
	end
}