local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Random.new()
Client.InteractionHandler.RegisterInteraction("RottenEgg", function(p)
	Client.Events.EatRottenEgg:FireServer(p)
end)

function EasterBunnyEggAdded(instance)
	if not instance:IsDescendantOf(workspace) then
		return
	end

	local eggHolder = instance:WaitForChild("EggHolder")

	if localPlayer.Character == instance.Parent.Parent.Parent then
		eggHolder.Enabled = false
	else
		task.spawn(function()
			while eggHolder.Parent do
				eggHolder.Enabled = (workspace.CurrentCamera.CFrame.Position - instance:GetPivot().Position).Magnitude > 150
				task.wait(1)
			end
		end)
	end
end

Client.Utility.ForAllTagged("EasterBunnyCarriedEgg", EasterBunnyEggAdded)
return {}