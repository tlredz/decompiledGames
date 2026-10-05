local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local WarFansActions = {}

function WarFansActions.WarFansClue3(_, _)
	SignalEvent.ToServer("WarFansClue", 3)
	return "Retsu_Rumour2"
end

function WarFansActions.WarFansClue4(_, _)
	SignalEvent.ToServer("WarFansClue", 4)
	return "Lynx_Rumour2"
end

return WarFansActions