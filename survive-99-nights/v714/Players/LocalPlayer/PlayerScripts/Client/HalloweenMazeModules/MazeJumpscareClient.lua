local MazeJumpscareClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {
	RunningDeer = function(p)
		local cFrame = p.Pos1.CFrame
		local cFrame2 = p.Pos2.CFrame
		local magnitude = (cFrame.Position - cFrame2.Position).Magnitude
		local clone = game.ReplicatedStorage.Assets.Halloween.Maze.DeerJumpscare:Clone()
		clone.PrimaryPart.Anchored = true
		local animator = clone:WaitForChild("NPC"):WaitForChild("Animator")
		local run = clone:WaitForChild("Animations"):WaitForChild("Run")
		clone.Parent = workspace.Particles
		animator:LoadAnimation(run):Play()
		local v2 = magnitude / 34
		local tweenModule = Client.TweenModule.new(function(p2)
			clone:PivotTo((cFrame:Lerp(cFrame2, p2)))
		end, v2)
		tweenModule:BindToComplete(function()
			clone:Destroy()
		end)
		tweenModule:Play()
	end
}

function MazeJumpscareAdded(instance)
	instance:WaitForChild("Trigger").Touched:Connect(function(otherPart)
		if instance:GetAttribute("Triggered") then
			return
		end

		if otherPart.Parent == localPlayer.Character then
			instance:SetAttribute("Triggered", true)
			v[instance:GetAttribute("AnimationType")](instance)
		end
	end)
end

function MazeJumpscareClient.Init()
	Client.Utility.ForAllTagged("MazeJumpscare", MazeJumpscareAdded)
end

return MazeJumpscareClient