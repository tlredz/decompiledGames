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
require3(ReplicatedStorage2.Controllers.UI.DialogueController)
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
		maid:GiveTask(v.Thread.Delay(0.5, function()
			v.Sounds:Play("LiveEventLegion_FrostDragonRoarDeath")
			v.Sounds:Play("LiveEventLegion_WingFlapStart")
		end))
		maid:GiveTask(v.Thread.Delay(3, function()
			v.Sounds:Play("LiveEventLegion_FrostDragonSlam")
		end))
		local signal = v.Signal.new()
		local track = animator:LoadAnimation(script.DragonAnimation)
		local v3 = require3(script.CameraKeypointA)
		track:Play()
		maid.Track = v2:PlayPointsWithAnimationTrack(track, p.CameraLocations.DragonCameraDeath:GetPivot(), v3).Removed:Connect(function()
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