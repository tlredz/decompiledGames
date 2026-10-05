local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Environment = require(ReplicatedStorage.Shared.Modules.Environment)
local Signal = require(ReplicatedStorage.Packages.Signal)
local StaffEntryHotkey = require(ReplicatedStorage.Client.StaffEntryHotkey)
local F8 = Enum.KeyCode.F8
local keyboardEnabled = UserInputService.KeyboardEnabled
local touchEnabled = UserInputService.TouchEnabled
local v = keyboardEnabled and not touchEnabled
local v2 = touchEnabled and not keyboardEnabled
local AdminPanelEntry = {
	Changed = Signal.new()
}
local v3 = false
local v4 = false

local function isToggleHonoured()
	return v and v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function canShowPanel()
	if StaffEntryHotkey.IsHidden() then
		return false
	end

	return v4 or Environment.IsDevPlace() or Environment.IsTestPlace() or v2 or v and v3
end

local function onInputBegan(p, flag: boolean)
	if v and not flag and p.KeyCode == F8 then
		v3 = not v3
		local changed = AdminPanelEntry.Changed
		local v5 = canShowPanel() -- equivalent call inferred; original call site unknown
		changed:Fire(v5)
	end
end

function AdminPanelEntry.CanShowPanel()
	if StaffEntryHotkey.IsHidden() then
		return false
	end

	return v4 or Environment.IsDevPlace() or Environment.IsTestPlace() or v2 or v and v3
end

function AdminPanelEntry.SetAdminStatus(flag: boolean)
	if v4 == flag then
		return
	end

	v4 = flag
	local changed = AdminPanelEntry.Changed
	local v5 = canShowPanel() -- equivalent call inferred; original call site unknown
	changed:Fire(v5)
end

UserInputService.InputBegan:Connect(onInputBegan)
StaffEntryHotkey.Changed:Connect(function()
	local changed = AdminPanelEntry.Changed
	local v5 = canShowPanel() -- equivalent call inferred; original call site unknown
	changed:Fire(v5)
end)
return AdminPanelEntry