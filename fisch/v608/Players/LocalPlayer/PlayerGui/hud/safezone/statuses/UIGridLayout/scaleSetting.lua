local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SettingsController = require(ReplicatedStorage:WaitForChild("client"):WaitForChild("legacyControllers"):WaitForChild("SettingsController"))

-- equivalent calls inferred from this helper; original call sites unknown
local function update()
	local v = 50 * SettingsController:GetSettingValue("statusScale")
	script.Parent.CellSize = UDim2.fromOffset(v, v)
end

SettingsController:GetSettingChangedSignal("statusScale"):Connect(update)
update() -- equivalent call inferred; original call site unknown