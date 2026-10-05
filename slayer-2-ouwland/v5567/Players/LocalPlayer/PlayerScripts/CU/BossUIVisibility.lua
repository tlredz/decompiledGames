local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
local localPlayer = Players.LocalPlayer
local v = DataValue.new(SettingsKeys.BossUI.Path, SettingsKeys.BossUI.Default, SettingsKeys.Scope)

-- equivalent calls inferred from this helper; original call sites unknown
local function apply()
	localPlayer:SetAttribute(SettingsKeys.BossUIAttribute, v:Get() ~= true)
end

v.Changed:Connect(apply)
apply() -- equivalent call inferred; original call site unknown