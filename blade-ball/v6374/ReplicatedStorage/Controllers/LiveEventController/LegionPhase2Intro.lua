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
		Text = "THIS IS WHERE THE REAL CHALLENGE STARTS! FEEL THE WRATH OF A THOUSAND LEGIONS!",
		TitleColor = Color3.fromRGB(200, 60, 20),
		Sound = "LiveEventLegion_Phase1_VA6",
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
		maid:GiveTask(v.Thread.Delay(23, function()
			v.Sounds:Play("LiveEventLegion_Roar2")
		end))
		maid:GiveTask(v.Thread.Delay(3, function()
			v3:SendText(v4.IntroductionA)
		end))
		maid:GiveTask(v.Thread.Delay(9, function()
			local maid2 = v.Maid.new()

			for _, child in pairs(p.CameraLocations.MinionsPhase2Spawns:GetChildren()) do
				local child2 = script.GuardAnims:FindFirstChild(child.Name)

				if not child2 then
					continue
				end

				local clone2 = script.RoyalGuard:Clone()
				clone2:PivotTo(child:GetPivot())
				clone2.Parent = folder
				clone2.Humanoid.Animator:LoadAnimation(child2):Play()
				maid2:GiveTask(clone2)
				v.Sounds:PlayAt(child:GetPivot().Position, "LiveEventLegion_SummonGuards")
				task.wait(0.2)
			end

			task.wait(3)
			maid2:Destroy()
		end))
		local signal = v.Signal.new()
		local track = animator:LoadAnimation(script.SentinelPhase1P1)
		local v5 = require3(script.CameraKeypointA)
		track:Play()
		maid:GiveTask(function()
			signal:Fire()
		end)
		maid.Track = v2:PlayPointsWithAnimationTrack(track, p.CameraLocations.SentinelPhaseCamera:GetPivot(), v5).Removed:Connect(function()
			signal:Fire()
		end)
		signal:Wait()
		v2:Reset()
		folder:Destroy()
	end
}