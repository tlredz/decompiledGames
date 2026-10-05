local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local gameSettings = UserSettings().GameSettings
local v = {}

while not Players.LocalPlayer do
	wait()
end

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()
localPlayer:WaitForChild("PlayerGui")
local inputBeganConnection = nil
local v2 = true
local v3 = false
local v4 = false
v.OnShiftLockToggled = Instance.new("BindableEvent")

local function isShiftLockMode()
	local devEnableMouseLock = localPlayer.DevEnableMouseLock

	if devEnableMouseLock then
		if gameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch and localPlayer.DevComputerMovementMode ~= Enum.DevComputerMovementMode.ClickToMove and gameSettings.ComputerMovementMode ~= Enum.ComputerMovementMode.ClickToMove then
			devEnableMouseLock = localPlayer.DevComputerMovementMode ~= Enum.DevComputerMovementMode.Scriptable
		else
			devEnableMouseLock = false
		end
	end

	return devEnableMouseLock
end

local devEnableMouseLock

if UserInputService.TouchEnabled then
	devEnableMouseLock = true
else
	devEnableMouseLock = localPlayer.DevEnableMouseLock

	if devEnableMouseLock then
		if gameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch and localPlayer.DevComputerMovementMode ~= Enum.DevComputerMovementMode.ClickToMove and gameSettings.ComputerMovementMode ~= Enum.ComputerMovementMode.ClickToMove then
			devEnableMouseLock = localPlayer.DevComputerMovementMode ~= Enum.DevComputerMovementMode.Scriptable
		else
			devEnableMouseLock = false
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onShiftLockToggled()
	v2 = not v2
	v.OnShiftLockToggled:Fire()
end

function v.IsShiftLocked(_)
	return devEnableMouseLock and v2
end

function v.SetIsInFirstPerson(_, p)
	v4 = p
end

local function mouseLockSwitchFunc(_, _, _)
	if devEnableMouseLock then
		onShiftLockToggled() -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disableShiftLock()
	devEnableMouseLock = false
	mouse.Icon = ""

	if inputBeganConnection then
		inputBeganConnection:disconnect()
		inputBeganConnection = nil
	end

	v3 = false
	v.OnShiftLockToggled:Fire()
end

local function fn(p, p2)
	if p2 then
		return
	end

	if p.UserInputType == Enum.UserInputType.Keyboard and p.KeyCode ~= Enum.KeyCode.LeftShift then
		local _ = p.KeyCode == Enum.KeyCode.RightShift
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function enableShiftLock()
	local devEnableMouseLock2 = localPlayer.DevEnableMouseLock

	if devEnableMouseLock2 then
		if gameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch and localPlayer.DevComputerMovementMode ~= Enum.DevComputerMovementMode.ClickToMove and gameSettings.ComputerMovementMode ~= Enum.ComputerMovementMode.ClickToMove then
			devEnableMouseLock2 = localPlayer.DevComputerMovementMode ~= Enum.DevComputerMovementMode.Scriptable
		else
			devEnableMouseLock2 = false
		end
	end

	devEnableMouseLock = devEnableMouseLock2

	if devEnableMouseLock then
		if v2 then
			v.OnShiftLockToggled:Fire()
		end

		if not v3 then
			inputBeganConnection = UserInputService.InputBegan:connect(fn)
			v3 = true
		end
	end
end

gameSettings.Changed:connect(function(p)
	if p == "ControlMode" then
		if gameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch then
			enableShiftLock() -- equivalent call inferred; original call site unknown
		else
			disableShiftLock() -- equivalent call inferred; original call site unknown
		end
	elseif p == "ComputerMovementMode" then
		if gameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove then
			disableShiftLock() -- equivalent call inferred; original call site unknown
		else
			enableShiftLock() -- equivalent call inferred; original call site unknown
		end
	end
end)
localPlayer.Changed:connect(function(p)
	if p == "DevEnableMouseLock" then
		if localPlayer.DevEnableMouseLock then
			enableShiftLock() -- equivalent call inferred; original call site unknown
		else
			disableShiftLock() -- equivalent call inferred; original call site unknown
		end
	elseif p == "DevComputerMovementMode" then
		if localPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.ClickToMove or localPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.Scriptable then
			disableShiftLock() -- equivalent call inferred; original call site unknown
		else
			enableShiftLock() -- equivalent call inferred; original call site unknown
		end
	end
end)
localPlayer.CharacterAdded:connect(function(_)
	local _ = UserInputService.TouchEnabled
end)

if not UserInputService.TouchEnabled then
	local devEnableMouseLock2 = localPlayer.DevEnableMouseLock

	if devEnableMouseLock2 then
		if gameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch and localPlayer.DevComputerMovementMode ~= Enum.DevComputerMovementMode.ClickToMove and gameSettings.ComputerMovementMode ~= Enum.ComputerMovementMode.ClickToMove then
			devEnableMouseLock2 = localPlayer.DevComputerMovementMode ~= Enum.DevComputerMovementMode.Scriptable
		else
			devEnableMouseLock2 = false
		end
	end

	if devEnableMouseLock2 then
		inputBeganConnection = UserInputService.InputBegan:connect(fn)
		v3 = true
	end
end

devEnableMouseLock = localPlayer.DevEnableMouseLock

if devEnableMouseLock then
	devEnableMouseLock = false

	if gameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch then
		devEnableMouseLock = false

		if localPlayer.DevComputerMovementMode ~= Enum.DevComputerMovementMode.ClickToMove then
			devEnableMouseLock = false

			if gameSettings.ComputerMovementMode ~= Enum.ComputerMovementMode.ClickToMove then
				if localPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.Scriptable then
					devEnableMouseLock = false
				else
					devEnableMouseLock = true
				end
			end
		end
	end
end

if not devEnableMouseLock then
	return v
end

if v2 then
	v.OnShiftLockToggled:Fire()
end

if not v3 then
	inputBeganConnection = UserInputService.InputBegan:connect(fn)
	v3 = true
end

return v