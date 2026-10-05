local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)

local function trade(p: string, childName: string, childName2: string)
	local data = Utility.GetData(Players.LocalPlayer)
	local inventory

	if data ~= nil then
		inventory = data.Inventory.Inventory
	end

	if inventory == nil then
		return p .. "_NoPiece"
	end

	if inventory:FindFirstChild(childName2) ~= nil then
		return p .. "_Done"
	end

	if inventory:FindFirstChild(childName) == nil then
		return p .. "_NoPiece"
	end

	SignalEvent.ToServer("SeriesTrade", p)
	return p .. "_Given"
end

local SeriesTradeActions = {}

function SeriesTradeActions.CapeTrade(_, _)
	return (trade("Cape", "Lost Cape", "Nightfall Cape Schematic"))
end

function SeriesTradeActions.HaoriTrade(_, _)
	return (trade("Haori", "Lost Outfit", "Firstlight Haori Schematic"))
end

return SeriesTradeActions