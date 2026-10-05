local GamepadService = game:GetService("GamepadService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local PlatformController = require(ReplicatedStorage.Client.PlatformController)
local Preferences = require(ReplicatedStorage.Shared.Preferences)
local Signal = require(ReplicatedStorage.Packages.Signal)
local MenuNavigation = {
	Changed = Signal.new(),
	CursorChanged = Signal.new(),
	SaveFailed = Signal.new(),
	CursorFailed = Signal.new(),
	SwitchKey = Enum.KeyCode.ButtonR3
}
local isOn = Preferences.IsOn("VirtualCursor")
local flag = false
local v = false
local count = 0
local v2 = nil
local v3 = nil
local v4 = {}
local count2 = 0
local v5 = true
local v6 = {}

function MenuNavigation.IsSuspended()
	return not PlatformController.IsConsole() or not UserInputService.GamepadEnabled or UserInputService.VREnabled or GuiService.MenuIsOpen or not v5 or next(v6) ~= nil
end

function MenuNavigation.PrefersCursor()
	return isOn
end

function MenuNavigation.IsCursorActive()
	return v2 ~= nil
end

function MenuNavigation.Release()
	if v2 == nil then
		return
	end

	v2 = nil
	local success, result = pcall(function()
		GamepadService:DisableGamepadCursor()
	end)

	if not success then
		warn((`Could not release menu cursor: {result}`))
	end

	MenuNavigation.CursorChanged:Fire(false)
end

function MenuNavigation.SetContext(p, p2)
	if p == nil or not isOn or MenuNavigation.IsSuspended() then
		MenuNavigation.Release()
		v3 = nil
		return false
	else
		if p == v2 then
			return true
		end

		if p == v3 then
			return false
		end

		MenuNavigation.Release()
		local success, result = pcall(function()
			GamepadService:EnableGamepadCursor(p2)
		end)

		if success then
			v3 = nil
			v2 = p
			MenuNavigation.CursorChanged:Fire(true)
			return true
		else
			v3 = p
			MenuNavigation.CursorFailed:Fire()
			warn((`Could not enable menu cursor: {result}`))
			return false
		end
	end
end

function MenuNavigation.SetPreference(flag2: boolean)
	if isOn == flag2 and not (flag or v) then
		return
	end

	isOn = flag2
	v = true
	count += 1
	v3 = nil

	if not flag2 then
		MenuNavigation.Release()
	end

	MenuNavigation.Changed:Fire()

	if flag then
		return
	end

	flag = true
	task.spawn(function()
		local v7

		repeat
			local v8 = count
			local v9 = isOn
			v7 = Preferences.Set("VirtualCursor", v9)
		until v8 == count

		flag = false
		v = not v7

		if v7 then
			return
		end

		MenuNavigation.SaveFailed:Fire()
	end)
end

function MenuNavigation.Toggle()
	MenuNavigation.SetPreference(not isOn)
end

function MenuNavigation.Suspend(p: string, flag2: boolean)
	if v6[p] == true == flag2 then
		return
	end

	v6[p] = flag2 and true or nil

	if flag2 then
		MenuNavigation.Release()
	end

	MenuNavigation.Changed:Fire()
end

function MenuNavigation.SetOverride(p: string, root, initial, back, value: number?, flag2: boolean?, flag3: boolean?)
	if root == nil then
		v4[p] = nil
	else
		count2 += 1
		v4[p] = {
			Root = root,
			Initial = initial,
			Back = back,
			Priority = value or 0,
			Modal = flag2 == true,
			BackInButtons = flag3 == true,
			Order = count2
		}
	end

	MenuNavigation.Changed:Fire()
end

local function visible(parent)
	local screenGui = parent:FindFirstAncestorWhichIsA("ScreenGui")

	if screenGui == nil or not screenGui.Enabled then
		return false
	end

	while not parent:IsA("GuiObject") or parent.Visible do
		parent = parent.Parent

		if parent == screenGui then
			return true
		end
	end

	return false
end

function MenuNavigation.TopOverride()
	local v7 = nil

	for _, v8 in v4 do
		if not (v8.Root.Parent and visible(v8.Root)) then
			continue
		end

		if not (v7 == nil or v8.Priority > v7.Priority or v8.Priority == v7.Priority and v8.Order > v7.Order) then
			continue
		end

		v7 = v8
	end

	return v7
end

Preferences.Observe("VirtualCursor", function(flag2: boolean)
	if flag2 == isOn or flag or v then
		return
	end

	isOn = flag2
	v3 = nil
	MenuNavigation.Changed:Fire()
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function refresh()
	if MenuNavigation.IsSuspended() then
		MenuNavigation.Release()
	end

	MenuNavigation.Changed:Fire()
end

PlatformController.Changed:Connect(refresh)
GuiService.MenuOpened:Connect(refresh)
GuiService.MenuClosed:Connect(refresh)
UserInputService.GamepadConnected:Connect(refresh)
UserInputService.GamepadDisconnected:Connect(refresh)
UserInputService.WindowFocusReleased:Connect(function()
	v5 = false
	refresh() -- equivalent call inferred; original call site unknown
end)
UserInputService.WindowFocused:Connect(function()
	v5 = true
	refresh() -- equivalent call inferred; original call site unknown
end)
pcall(function()
	GamepadService:GetPropertyChangedSignal("GamepadCursorEnabled"):Connect(function()
		local success, result = pcall(function()
			return GamepadService.GamepadCursorEnabled
		end)

		if success and not result and v2 ~= nil then
			v2 = nil
			MenuNavigation.CursorChanged:Fire(false)
			MenuNavigation.Changed:Fire()
		end
	end)
end)
return MenuNavigation