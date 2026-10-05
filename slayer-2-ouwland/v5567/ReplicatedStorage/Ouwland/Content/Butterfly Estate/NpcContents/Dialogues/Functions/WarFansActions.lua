local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
return {
	WarFansClue1 = function(_, _)
		SignalEvent.ToServer("WarFansClue", 1)
		return "Shiori_Rumour2"
	end
}