local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
return {
	MuzanGiveBell = function(_, _)
		local data = Utility.GetData(Players.LocalPlayer)

		if data ~= nil and data.Inventory.Inventory:FindFirstChild("Biwa Bell") ~= nil then
			return "Muzan_HasBell"
		end

		SignalEvent.ToServer("MuzanGiveBell")
		return ""
	end
}