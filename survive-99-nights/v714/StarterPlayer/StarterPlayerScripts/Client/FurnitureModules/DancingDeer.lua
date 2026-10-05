local DancingDeer = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Random.new()

function LoadHalloweenGuy(instance)
	if not instance:IsDescendantOf(workspace.Structures) then
		return
	end

	instance:WaitForChild("NPC"):WaitForChild("Animator"):LoadAnimation(instance:WaitForChild("Animations"):WaitForChild("Dance")):Play()
end

function DancingDeer.Init()
	Client.Utility.ForAllTagged("DancingDeer", LoadHalloweenGuy)
end

return DancingDeer