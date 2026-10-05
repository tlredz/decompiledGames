local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Client.Events.ReplicateBullet:Connect(function(_, _, data)
	local projectileClass = Client.ProjectileClass.new(data, data.Origin, data.Velocity)

	if data.Explosive then
		projectileClass.Explosive = true
	end

	projectileClass.Replica = true
	projectileClass:Fire()
end)
return {}