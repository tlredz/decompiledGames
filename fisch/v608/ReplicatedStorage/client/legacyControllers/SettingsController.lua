local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.packages.Signal)
local Net = require(ReplicatedStorage.packages.Net)
local module = require("./DataController")
local playerDataReplicator = module.PlayerDataReplicator
local playerSettings = require(ReplicatedStorage.shared.playerSettings)
require(ReplicatedStorage.shared.playerSettings.Types)
local SettingsController = {
	SettingChanged = Signal.new(),
	SettingChangedSignals = {},
	LocalSettingsState = {}
}
local remoteEvent = Net:RemoteEvent("Settings/Edit", -1)
local v = false

function SettingsController.Start(_)
	playerDataReplicator:WaitForLoaded()
	SettingsController.LocalSettingsState = playerDataReplicator:Index({ "Settings" })
	v = true
	remoteEvent.OnClientEvent:Connect(function(p, p2)
		local v2 = SettingsController.LocalSettingsState[p]
		SettingsController.LocalSettingsState[p] = p2

		if v2 ~= p2 then
			SettingsController.SettingChanged:Fire(p, p2, v2)
		end
	end)
	local module2 = require("@self/Observers")

	for k, callback in module2 do
		SettingsController:GetSettingChangedSignal(k):Connect(callback)
		task.spawn(callback, SettingsController:GetSettingValue(k))
	end
end

function SettingsController.GetSettingMeta(_, p)
	return playerSettings[p]
end

function SettingsController:GetSettingValue(p)
	if not v then
		playerDataReplicator:WaitForLoaded()
		task.wait()
	end

	return SettingsController.LocalSettingsState[p]
end

function SettingsController:GetSettingChangedSignal(p)
	if SettingsController.SettingChangedSignals[p] then
		return SettingsController.SettingChangedSignals[p]
	end

	local v2 = Signal.new()
	SettingsController.SettingChanged:Connect(function(p2, p3, p4)
		if p2 == p then
			v2:Fire(p3, p4)
		end
	end)
	SettingsController.SettingChangedSignals[p] = v2
	return v2
end

function SettingsController.EditSetting(_, p, p2, flag: boolean?)
	local v2 = SettingsController.LocalSettingsState[p]
	SettingsController.LocalSettingsState[p] = p2
	SettingsController.SettingChanged:Fire(p, p2, v2)

	if not flag then
		remoteEvent:FireServer(p, p2)
	end
end

return SettingsController