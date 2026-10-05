local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return {
	WagasaTakeSchematic = function(_, _)
		local data = Utility.GetData(Players.LocalPlayer)

		if data == nil then
			return "Wagasa_Done"
		end

		local worldEvents = data:FindFirstChild("WorldEvents")

		if worldEvents ~= nil and worldEvents:FindFirstChild("FirstlightWagasa_Schematic") ~= nil then
			return "Wagasa_Done"
		end

		SignalEvent.ToServer("WagasaGiveSchematic")
		return "Wagasa_Given"
	end
}