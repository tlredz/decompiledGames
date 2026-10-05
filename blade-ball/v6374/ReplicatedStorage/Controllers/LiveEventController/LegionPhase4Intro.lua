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
		Title = "Fire Dragon",
		Text = "You guys have come a long way… But this treasure has been under my protection for a long time. IT’S MINE!",
		TitleColor = Color3.fromRGB(200, 60, 20),
		TextSpeed = 25,
		Duration = 3
	}
}
return {
	Start = function(_, maid, p)
		local folder = Instance.new("Folder")
		folder.Name = "CinematicContainer"
		folder.Parent = workspace
		local clone = script.FireDragon:Clone()
		clone:PivotTo(p.CameraLocations.FireDragonSpawn:GetPivot())
		clone.Parent = folder
		local animator = clone.AnimationController.Animator
		maid:GiveTask(v.Thread.Delay(6, function()
			v.Sounds:Play("LiveEventLegion_FireDragonRoarFlight")
		end))
		local clone2 = script.Chest:Clone()
		clone2:PivotTo(p.CameraLocations.ChestLocation:GetPivot())
		clone2.Parent = folder
		v3:SendText(v4.IntroductionA)
		local signal = v.Signal.new()
		maid:GiveTask(function()
			signal:Fire()
		end)
		local track = animator:LoadAnimation(script.DragonAnimation)
		local v5 = require3(script.CameraKeypointA)
		track:Play()
		maid.Track = v2:PlayPointsWithAnimationTrack(track, p.CameraLocations.DragonCamera:GetPivot(), v5).Removed:Connect(function()
			signal:Fire()
		end)
		signal:Wait()
		v2:Reset()
		folder:Destroy()
	end
}