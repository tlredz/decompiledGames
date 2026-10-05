local DancingHalloweenGuy = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local random = Random.new()

function LoadHalloweenGuy(instance)
	local animator = instance:WaitForChild("AnimationController"):WaitForChild("Animator")
	local track = animator:LoadAnimation(instance:WaitForChild("Animations"):WaitForChild("Idle"))
	local track2 = animator:LoadAnimation(instance.Animations.Dance)
	track:Play()

	while true do
		task.wait(random:NextInteger(40, 60))
		track2:Play(1)
		task.wait(15)
	end
end

function DancingHalloweenGuy.Init()
	Client.Utility.ForAllTagged("DancingHalloweenGuy", LoadHalloweenGuy)
end

return DancingHalloweenGuy