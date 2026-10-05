local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Series = require(ReplicatedStorage.CAM.Global.Series)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)

local function claim(p: string)
	local data = Utility.GetData(Players.LocalPlayer)
	local inventory

	if data ~= nil then
		inventory = data.Inventory.Inventory
	end

	if inventory == nil then
		return "Togane_SetsMissing"
	end

	for _, v in Series.Capstones(p) do
		if inventory:FindFirstChild(v .. " Schematic") ~= nil then
			return "Togane_SetsDone"
		end
	end

	for _, childName in Series.CapstoneGate(p) do
		if inventory:FindFirstChild(childName) == nil then
			return "Togane_SetsMissing"
		end
	end

	SignalEvent.ToServer("SeriesCapstone", p)
	return "Togane_SetsGiven"
end

local SeriesCapstoneActions = {}

function SeriesCapstoneActions.SeriesCapstoneFirstlight(_, _)
	return (claim("Firstlight"))
end

function SeriesCapstoneActions.SeriesCapstoneNightfall(_, _)
	return (claim("Nightfall"))
end

return SeriesCapstoneActions