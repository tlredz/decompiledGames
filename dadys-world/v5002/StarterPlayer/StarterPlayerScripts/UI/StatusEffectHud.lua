local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MyDataController = require(ReplicatedStorage.Modules.ClientUI.MyDataController)
local SettingsFlags = require(ReplicatedStorage.SharedUtils.SettingsFlags)
local StatusEffectController = require(ReplicatedStorage.Modules.ClientUI.StatusEffectController)
local StatusEffectTracker = require(ReplicatedStorage.Modules.ClientUI.StatusEffectTracker)
local v = { "Settings", "StatusHudToggle" }

local function safeStart(p, callback)
	local success, result = pcall(callback)

	if not success then
		warn(("[StatusEffectHud] %s failed to start: %s"):format(p, (tostring(result))))
	end

	return success
end

local success, result = pcall(function()
	StatusEffectController.init()
end)

if not success then
	warn(("[StatusEffectHud] %s failed to start: %s"):format("StatusEffectController", (tostring(result))))
end

local success2, result2 = pcall(function()
	StatusEffectTracker.start()
end)

if not success2 then
	warn(("[StatusEffectHud] %s failed to start: %s"):format("StatusEffectTracker", (tostring(result2))))
end

task.spawn(function()
	local v2 = MyDataController:waitForReplica()

	if not v2 then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refresh()
		local data = MyDataController:getDataFromPath("Settings.StatusHudToggle")
		StatusEffectTracker.setEnabled(SettingsFlags:GetEffective(data, "StatusHudToggle") ~= false)
	end

	v2:ListenToChange(v, refresh)
	SettingsFlags.Changed:Connect(refresh)
	refresh() -- equivalent call inferred; original call site unknown
end)