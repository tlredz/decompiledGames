local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local gameSettings = require(script.Parent.gameSettings)
local Worlds = require(script.Parent.Parent.Worlds)

if RunService:IsServer() and workspace:GetAttribute("DayCycleAnchor") == nil then
	workspace:SetAttribute("DayCycleAnchor", workspace:GetServerTimeNow() - workspace.DistributedGameTime)
end

local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local DayAndNightHandler = {
	PhaseChanged = simplesignal.new()
}
local clockTime = Lighting.ClockTime

function DayAndNightHandler.GetCurrentTime()
	local studio = gameSettings.IsStudio and gameSettings.Day.DayTime.Studio or gameSettings.Day.DayTime.Game
	local studio2 = gameSettings.IsStudio and gameSettings.Day.NighTime.Studio or gameSettings.Day.NighTime.Game
	local dayCycleAnchor = workspace:GetAttribute("DayCycleAnchor")
	local v

	if dayCycleAnchor == nil then
		v = workspace.DistributedGameTime
	else
		v = workspace:GetServerTimeNow() - dayCycleAnchor
	end

	return v % (studio + studio2)
end

function DayAndNightHandler.IsNight()
	local currentTime = DayAndNightHandler.GetCurrentTime()

	if gameSettings.Day.Inversed then
		return currentTime < (gameSettings.IsStudio and gameSettings.Day.NighTime.Studio or gameSettings.Day.NighTime.Game)
	end

	return (gameSettings.IsStudio and gameSettings.Day.DayTime.Studio or gameSettings.Day.DayTime.Game) <= currentTime
end

function DayAndNightHandler.IsDay()
	return not DayAndNightHandler.IsNight()
end

function DayAndNightHandler.SecondsUntilPhaseChange()
	local studio = gameSettings.IsStudio and gameSettings.Day.DayTime.Studio or gameSettings.Day.DayTime.Game
	local studio2 = gameSettings.IsStudio and gameSettings.Day.NighTime.Studio or gameSettings.Day.NighTime.Game
	local currentTime = DayAndNightHandler.GetCurrentTime()
	local v = gameSettings.Day.Inversed and studio2 or studio

	if currentTime < v then
		return v - currentTime
	end

	return studio + studio2 - currentTime
end

function DayAndNightHandler.GetClockTime()
	local currentTime = DayAndNightHandler.GetCurrentTime()
	local inversed = gameSettings.Day.Inversed
	local studio = gameSettings.IsStudio and gameSettings.Day.DayTime.Studio or gameSettings.Day.DayTime.Game
	local studio2 = gameSettings.IsStudio and gameSettings.Day.NighTime.Studio or gameSettings.Day.NighTime.Game
	local v2 = inversed and 0 or studio

	if DayAndNightHandler.IsNight() then
		return (18 + (currentTime - v2) % (studio + studio2) / studio2 * 12) % 24
	end

	return 6 + (currentTime - (inversed and studio2 or 0)) % (studio + studio2) / studio * 12
end

function DayAndNightHandler.GetMinutesAfterMidnight()
	return DayAndNightHandler.GetClockTime() * 60
end

function DayAndNightHandler.IsEnabled()
	if gameSettings.IsStudio and gameSettings.Day.DisableInStudio then
		return false
	end

	local v = Worlds.ById[game.PlaceId]
	return v == nil or v.NoDayNight ~= true
end

function DayAndNightHandler.IsSunUp()
	return not (DayAndNightHandler.IsEnabled() and DayAndNightHandler.IsNight())
end

function DayAndNightHandler.Apply()
	if not DayAndNightHandler.IsEnabled() then
		return
	end

	Lighting.ClockTime = DayAndNightHandler.GetClockTime()
end

function DayAndNightHandler.Reset()
	Lighting.ClockTime = clockTime
end

return DayAndNightHandler