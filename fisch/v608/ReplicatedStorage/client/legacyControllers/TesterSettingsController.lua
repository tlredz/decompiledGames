local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.packages.Signal)
local Net = require(ReplicatedStorage.packages.Net)
local testerSettings = require(ReplicatedStorage.shared.playerSettings.testerSettings)
local defaults = require(ReplicatedStorage.shared.playerSettings.testerSettings.defaults)
require(ReplicatedStorage.shared.playerSettings.Types)
local v = game.GameId ~= 5750914919
local TesterSettingsController = {
	SettingChanged = Signal.new(),
	SettingChangedSignals = {},
	LocalSettingsState = {}
}
local v2

if v then
	v2 = Net:RemoteEvent("TesterSettings/Edit", -1)
else
	v2 = nil
end

local v3 = false

function TesterSettingsController.Start(_)
	if v then
		v2.OnClientEvent:Connect(function(p, localSettingsState)
			if p == "_initial" then
				TesterSettingsController.LocalSettingsState = localSettingsState
				v3 = true
			else
				local v4 = TesterSettingsController.LocalSettingsState[p]
				TesterSettingsController.LocalSettingsState[p] = localSettingsState

				if v4 ~= localSettingsState then
					TesterSettingsController.SettingChanged:Fire(p, localSettingsState, v4)
				end
			end
		end)
		return
	end

	TesterSettingsController.LocalSettingsState = table.clone(defaults)
	v3 = true
end

function TesterSettingsController.GetSettingMeta(_, p)
	return testerSettings[p]
end

function TesterSettingsController.GetSettingValue(_, p)
	while not v3 do
		task.wait()
	end

	return TesterSettingsController.LocalSettingsState[p]
end

function TesterSettingsController.GetSettingChangedSignal(_, p)
	if not v then
		return TesterSettingsController.SettingChanged
	end

	if TesterSettingsController.SettingChangedSignals[p] then
		return TesterSettingsController.SettingChangedSignals[p]
	end

	local v4 = Signal.new()
	TesterSettingsController.SettingChanged:Connect(function(p2, p3, p4)
		if p2 == p then
			v4:Fire(p3, p4)
		end
	end)
	TesterSettingsController.SettingChangedSignals[p] = v4
	return v4
end

function TesterSettingsController.EditSetting(_, p, p2, flag: boolean?)
	if not v then
		return
	end

	local v4 = TesterSettingsController.LocalSettingsState[p]
	TesterSettingsController.LocalSettingsState[p] = p2
	TesterSettingsController.SettingChanged:Fire(p, p2, v4)

	if not flag then
		v2:FireServer(p, p2)
	end
end

return TesterSettingsController