local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
return {
	WarFansClue2 = function(_, _)
		SignalEvent.ToServer("WarFansClue", 2)
		return "Sofen_Rumour2"
	end
}