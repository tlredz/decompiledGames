local SoundService = game:GetService("SoundService")
local Flags = require(game.ReplicatedStorage.Modules.Flags)
local Signal = require(game.ReplicatedStorage.Modules.Util.Signal)
local Groups = require(game.ReplicatedStorage.Util.Sound.Groups)
require(script.Parent.Types)
local EnvironmentUtilShared = require(game.ReplicatedStorage.Modules.Weather.EnvironmentUtilShared)
local soundGroup = Instance.new("SoundGroup")
soundGroup.Name = "Environment:Locations"
soundGroup.Parent = SoundService
Groups.registerSatellite(soundGroup, "LowPriority")
local getRegionEnteredSignal = Signal.new()
local getRegionExitedSignal = Signal.new()
local getRegionAddedSignal = Signal.new()
local getRegionRemovedSignal = Signal.new()
local EnvironmentUtil = {
	ClosestEnvironment = nil,
	Teleported = nil,
	WithinZonesByGroup = EnvironmentUtilShared.mapGroups(),
	Environments = {},
	Soundgroup = soundGroup,
	Signals = {
		GetRegionEnteredSignal = getRegionEnteredSignal,
		GetRegionExitedSignal = getRegionExitedSignal,
		GetRegionAddedSignal = getRegionAddedSignal,
		GetRegionRemovedSignal = getRegionRemovedSignal
	}
}

function EnvironmentUtil.localPlayerEnteredEnvironment(p)
	local uid = p.configuration.uid
	local group = p.configuration.group

	if table.find(EnvironmentUtil.WithinZonesByGroup[group], uid) then
		return false
	end

	debug.profilebegin("localPlayerEnteredEnvironment")
	table.insert(EnvironmentUtil.WithinZonesByGroup[group], uid)
	table.sort(EnvironmentUtil.WithinZonesByGroup[group], function(a, b)
		return (EnvironmentUtil.Environments[a] and EnvironmentUtil.Environments[a].configuration.timeIn or 1e999) < (EnvironmentUtil.Environments[b] and EnvironmentUtil.Environments[b].configuration.timeIn or 1e999)
	end)
	EnvironmentUtil.Signals.GetRegionEnteredSignal:Fire(uid, group)
	debug.profileend()
	return true
end

function EnvironmentUtil.localPlayerExitedEnvironment(p)
	local uid = p.configuration.uid
	local group = p.configuration.group
	local index = table.find(EnvironmentUtil.WithinZonesByGroup[group], uid)

	if not index then
		return false
	end

	debug.profilebegin("localPlayerExitedEnvironment")
	table.remove(EnvironmentUtil.WithinZonesByGroup[group], index)
	table.sort(EnvironmentUtil.WithinZonesByGroup[group], function(a, b)
		return (EnvironmentUtil.Environments[a] and EnvironmentUtil.Environments[a].configuration.timeIn or 1e999) < (EnvironmentUtil.Environments[b] and EnvironmentUtil.Environments[b].configuration.timeIn or 1e999)
	end)
	EnvironmentUtil.Signals.GetRegionExitedSignal:Fire(uid, group)
	debug.profileend()
	return true
end

function EnvironmentUtil.playClosestSound(_)
	if Flags.ENVIRONMENT_MUSIC_ENABLED == false then
	end
end

return EnvironmentUtil