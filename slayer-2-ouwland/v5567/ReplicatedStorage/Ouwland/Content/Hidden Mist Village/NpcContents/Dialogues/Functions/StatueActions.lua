local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local StatueActions = {}

function StatueActions.StatuesHeard(_, _)
	SignalEvent.ToServer("GauntletStatuesBegin")
	return "Statues_4"
end

function StatueActions.GauntletTakeSchematic(_, _)
	local data = Utility.GetData(Players.LocalPlayer)

	if data ~= nil and data.Inventory.Inventory:FindFirstChild("Nightfall Gauntlet Schematic") ~= nil then
		return "Statues_Done"
	end

	SignalEvent.ToServer("GauntletGiveSchematic")
	return "Statues_Given"
end

return StatueActions