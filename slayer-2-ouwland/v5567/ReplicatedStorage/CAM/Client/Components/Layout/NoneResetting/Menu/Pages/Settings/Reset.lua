local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local AutoLoadoutKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.AutoLoadoutKeys)
local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local localPlayer = Players.LocalPlayer
local v = {
	{
		Action = "RunToggle",
		Key = SettingsKeys.RunToggle
	},
	{
		Action = "ParticleQuality",
		Key = SettingsKeys.Particles
	},
	{
		Action = "ParticleQualityMine",
		Key = SettingsKeys.ParticlesMine
	},
	{
		Action = "ParticleQualityAllies",
		Key = SettingsKeys.ParticlesAllies
	},
	{
		Action = "ParticleQualityOthers",
		Key = SettingsKeys.ParticlesOthers
	},
	{
		Action = "MaterialQuality",
		Key = SettingsKeys.Materials
	},
	{
		Action = "ShadowQuality",
		Key = SettingsKeys.Shadows
	},
	{
		Action = "ScreenShakeStrength",
		Key = SettingsKeys.ScreenShake
	},
	{
		Action = "AimAssistStrength",
		Key = SettingsKeys.AimAssist
	},
	{
		Action = "AimAssistCombatStrength",
		Key = SettingsKeys.AimAssistCombat
	},
	{
		Action = "MobileButtonScale",
		Key = SettingsKeys.MobileScale
	},
	{
		Action = "MobileDirectionalDash",
		Key = SettingsKeys.MobileDirectionalDash
	},
	{
		Action = "MobileSkillDragTurnsCamera",
		Key = SettingsKeys.MobileSkillDragTurnsCamera
	},
	{
		Action = "MobileToolbarDrag",
		Key = SettingsKeys.MobileToolbarDrag
	},
	{
		Action = "StrictShiftLock",
		Key = SettingsKeys.StrictShiftLock
	},
	{
		Action = "AutoWaveSkip",
		Key = SettingsKeys.AutoWaveSkip
	},
	{
		Action = "PadDirectionalDash",
		Key = SettingsKeys.PadDirectionalDash
	},
	{
		Action = "ForcePlatformControls",
		Key = SettingsKeys.ForcePlatform
	},
	{
		Action = "BossUIVisible",
		Key = SettingsKeys.BossUI
	},
	{
		Action = "HealthStatsVisible",
		Key = SettingsKeys.HealthStats
	},
	{
		Action = "KeybindHelper",
		Key = SettingsKeys.KeybindHelper
	},
	{
		Action = "PvpSwitchVisible",
		Key = SettingsKeys.PvpSwitch
	},
	{
		Action = "TitlesVisible",
		Key = SettingsKeys.Titles
	},
	{
		Action = "TitleEffectsVisible",
		Key = SettingsKeys.TitleEffects
	},
	{
		Action = "ThemeVolume",
		Key = SettingsKeys.ThemeVolume
	},
	{
		Action = "AmbienceVolume",
		Key = SettingsKeys.AmbienceVolume
	}
}
local flag = false

local function stored(child, value: string)
	for childName in string.gmatch(value, "[^/]+") do
		if child == nil then
			return false
		else
			child = child:FindFirstChild(childName)
		end
	end

	return child ~= nil
end

return {
	All = function()
		if flag then
			return
		end

		flag = true

		if PopUpCreator.new({
			Type = "Question",
			Content = "Are you sure you want to put every setting back to its default?"
		}):WaitResult() ~= "Yes" then
			flag = false
			return
		end

		local data, v2 = Utility.GetData(localPlayer)

		for _, v3 in v do
			if stored(v2, v3.Key.Path) then
				SignalEvent.ToServer(v3.Action, v3.Key.Default)
			end
		end

		for k in AutoLoadoutKeys.ByKey do
			if stored(data, AutoLoadoutKeys.Path(k)) then
				SignalEvent.ToServer(AutoLoadoutKeys.Action, k, AutoLoadoutKeys.Default)
			end
		end

		for _, keybind in SettingsKeys.Keybinds do
			local keyBinding, v3 = InputHandler.KeyBinding(keybind.Name)

			if keyBinding ~= InputHandler.DefaultKey(keybind.Name) or v3 ~= nil then
				SignalEvent.ToServer("Keybind", keybind.Name)
			end

			local padBinding, v4 = InputHandler.PadBinding(keybind.Name)
			local padDefault, v5 = InputHandler.PadDefault(keybind.Name)

			if padBinding ~= padDefault or v4 ~= v5 then
				SignalEvent.ToServer("PadKeybind", keybind.Name)
			end
		end

		flag = false
	end
}