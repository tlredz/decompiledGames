local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Client.Events.DestroyCorruptedTool:Connect(function(instance)
	if not instance then
		return
	end

	local v = instance:GetPivot() * CFrame.new(0, 0, -3)
	Client.Utility.SpawnParticles("CorruptedToolExplode", v)
	task.spawn(function()
		wait(0.75)

		if localPlayer.Character and localPlayer.Character == instance then
			Client.Events.SetPopUpMessage:Fire("your corrupted tool exploded", "purple")
		end
	end)
	Client.Sound.Play("CorruptedToolExplode", {
		Position = v.Position
	})
end)
return {}