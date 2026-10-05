local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Client.Events.SpawnParticles:Connect(function(...)
	Client.Utility.SpawnParticles(...)
end)
Client.Events.RunParticles:Connect(function(p, ...)
	if not p then
		while p == nil do
			task.wait()
		end
	end

	Client.Utility.RunParticles(p, ...)
end)
Client.Events.AddWeldParticles:Connect(function(...)
	Client.Utility.WeldParticle(...)
end)
return {
	Taunt = function(player)
		local pivot = player.Character and player.Character:GetPivot()

		if pivot then
			Client.Utility.SpawnParticles("Taunt", pivot)
		end
	end
}