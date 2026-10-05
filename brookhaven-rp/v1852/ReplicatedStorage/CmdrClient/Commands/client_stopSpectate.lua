local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpectatingController = require(ReplicatedStorage.Modules.Client.Cmdr.SpectatingController)
return {
	Name = "client_stopSpectate",
	Aliases = {},
	Description = "Stop spectating a player",
	Group = "Client",
	Args = {},
	ClientRun = function(_, _)
		return SpectatingController.StopSpectating()
	end
}