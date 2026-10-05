local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
return {
	LivGamble = function(_, _)
		local data = Utility.GetData(Players.LocalPlayer)

		if data == nil or data.Wen.Value <= 0 then
			return "Liv_GambleBroke"
		end

		SignalEvent.ToServer("LivGamble")
		return ""
	end
}