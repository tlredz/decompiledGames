local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
return {
	CleaverChallenge = function(_, _)
		SignalEvent.ToServer("CleaverDuel")
		return ""
	end
}