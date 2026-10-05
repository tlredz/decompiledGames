local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DayAndNightHandler = require(ReplicatedStorage.CAM.Global.DayAndNightHandler)
local PlayerStatResolver = require(ReplicatedStorage.CAM.Global.PlayerStatResolver)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)

local function owns(p)
	return p ~= nil and p.Inventory.Inventory:FindFirstChild("Mushroom Lit Lantern") ~= nil
end

local FoxfireActions = {}

function FoxfireActions.RetsuLanternEntry(_, _)
	local data = Utility.GetData(Players.LocalPlayer)
	local v

	if data == nil then
		v = false
	else
		v = data.Inventory.Inventory:FindFirstChild("Mushroom Lit Lantern") ~= nil
	end

	if v then
		return "Retsu_Lantern_Wearing"
	end

	return "Retsu_Lantern"
end

function FoxfireActions.RetsuTellFoxfire(_, _)
	local data = Utility.GetData(Players.LocalPlayer)

	if data == nil then
		return "Retsu_Lantern_Quiet"
	end

	local v

	if data == nil then
		v = false
	else
		v = data.Inventory.Inventory:FindFirstChild("Mushroom Lit Lantern") ~= nil
	end

	if v then
		return "Retsu_Lantern_Wearing"
	end

	if DayAndNightHandler.IsEnabled() and not DayAndNightHandler.IsNight() then
		return "Retsu_Lantern_Daylight"
	end

	if (PlayerStatResolver.GetStatExcept(Players.LocalPlayer, "Illumination", "Progression") or 0) > 0 then
		return "Retsu_Lantern_Lit"
	end

	if data.Wen.Value < 2500 then
		return "Retsu_Lantern_Broke"
	end

	SignalEvent.ToServer("RetsuTellFoxfire")
	return "Retsu_Lantern_Told"
end

return FoxfireActions