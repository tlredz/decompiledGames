local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpectatingController = require(ReplicatedStorage.Modules.Client.Cmdr.SpectatingController)
return {
	Name = "client_spectate",
	Aliases = {},
	Description = "Spectate a player",
	Group = "Client",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "The player to spectate"
		}
	},
	ClientRun = function(_, p)
		return SpectatingController.Spectate(p)
	end
}