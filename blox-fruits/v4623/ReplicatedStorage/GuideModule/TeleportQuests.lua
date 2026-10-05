local TeleportQuests = {}
local Realm = require(game.ReplicatedStorage.Util.Realm)
task.spawn(function()
	if Realm.getIfCurrentRealmHasTagAsync("IsSecondSea") then
		table.insert(
			TeleportQuests,
			{
				workspace.Map:WaitForChild("GhostShipInterior").TeleportSpawn.Position,
				workspace.Map:WaitForChild("GhostShip").TeleportSpawn.Position
			}
		)
	elseif Realm.getIfCurrentRealmHasTagAsync("IsFirstSea") then
		local teleportSpawn = workspace.Map:WaitForChild("TeleportSpawn")
		table.insert(TeleportQuests, { teleportSpawn.Entrance.Position, teleportSpawn.Exit.Position })
	end
end)
return TeleportQuests