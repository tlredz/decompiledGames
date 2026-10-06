return {
	clone = function(player, p)
		if p then
			game.ReplicatedStorage.Chest.Remotes.Events.PopupEvent:FireClient(player, "StatsPopup", p)
		end
	end
}