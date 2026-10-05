local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
local v = DataValue.new(SettingsKeys.ForcePlatform.Path, SettingsKeys.ForcePlatform.Default, SettingsKeys.Scope)

-- equivalent calls inferred from this helper; original call sites unknown
local function apply()
	local v2 = v:Get()
	Platform_Handler.Forced = not SettingsKeys.IsPlatformChoice(v2) and "" or v2
	Platform_Handler.Apply()
end

v.Changed:Connect(apply)
apply() -- equivalent call inferred; original call site unknown