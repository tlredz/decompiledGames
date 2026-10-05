local _ = tick
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Combat_presets"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.cleanit)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Players = game:GetService("Players")
local clone = table.clone(Utility.Cancel_Values)
clone.pause_gameplay = true
clone.Swapping = true
clone.Blocking = true
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local RunHandlerSettings = require(script.RunHandlerSettings)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
RunHandlerSettings.ShiftLockChanged = Instance.new("BindableEvent")

function RunHandlerSettings.SetShiftLock(p: number)
	local shift_lock2 = p == 1 and 1 or 0

	if RunHandlerSettings.Shift_lock == shift_lock2 then
		return
	end

	RunHandlerSettings.Shift_lock = shift_lock2
	RunHandlerSettings.ShiftLockChanged:Fire(shift_lock2)
end

local v = nil
local shift_lock = nil

local function menuOpen()
	return v ~= nil and v.Value ~= ""
end

local function platformLock()
	if Platform_Handler.IsGamepad() then
		return 1
	end

	return 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyShiftLock(flag: boolean?)
	local v2

	if v == nil then
		v2 = false
	else
		v2 = v.Value ~= ""
	end

	if v2 then
		if shift_lock == nil then
			shift_lock = RunHandlerSettings.Shift_lock
		end

		if flag then
			shift_lock = Platform_Handler.IsGamepad() and 1 or 0
		end

		RunHandlerSettings.SetShiftLock(0)
	else
		if shift_lock ~= nil then
			RunHandlerSettings.SetShiftLock(shift_lock)
			shift_lock = nil
		end

		if flag then
			RunHandlerSettings.SetShiftLock(Platform_Handler.IsGamepad() and 1 or 0)
		elseif Platform_Handler.IsGamepad() then
			RunHandlerSettings.SetShiftLock(1)
		end
	end
end

applyShiftLock()
Platform_Handler.Platform.Changed.Event:Connect(function()
	applyShiftLock(true) -- equivalent call inferred; original call site unknown
end)
task.spawn(function()
	local menuDestination = Players.LocalPlayer:WaitForChild("MenuDestination", 99)

	if menuDestination == nil or not menuDestination:IsA("StringValue") then
		return
	end

	v = menuDestination
	menuDestination.Changed:Connect(function()
		applyShiftLock()
	end)
	applyShiftLock()
end)

function RunHandlerSettings.CanRun()
	return Checker.check(Players.LocalPlayer, "Run") == true
end

function RunHandlerSettings.check_can_run()
	return not RunHandlerSettings.IsWalking and RunHandlerSettings.CanRun()
end

RunHandlerSettings.RunningChanged = Instance.new("BindableEvent")
return RunHandlerSettings