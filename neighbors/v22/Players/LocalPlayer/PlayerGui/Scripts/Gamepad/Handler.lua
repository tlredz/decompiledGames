local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local GamepadService = game:GetService("GamepadService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local Gamepad = require(ReplicatedStorage.Modules.Gamepad)
local PlayerStates = require(ReplicatedStorage.Modules.PlayerStates)
local localPlayer = Players.LocalPlayer
local sidetab = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Neighbors"):WaitForChild("Sidetab")

local function setGamepadCursorActive(flag: boolean)
	if not (Gamepad.GamepadEnabled and GamepadService.GamepadCursorEnabled ~= flag) then
		return
	end

	if flag then
		GamepadService:EnableGamepadCursor(nil)
	else
		GamepadService:DisableGamepadCursor()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function shouldGamepadCursorBeEnabled()
	if sidetab.Visible then
		return false
	end

	local highestOrderVisibleContainer = Gamepad:GetHighestOrderVisibleContainer()

	if highestOrderVisibleContainer and highestOrderVisibleContainer.EnableCursorBehavior and highestOrderVisibleContainer:IsVisible() then
		return true
	end

	local _ = localPlayer:GetAttribute("State") == PlayerStates.Idle
	return false
end

local function updateGamepadCursor()
	if not Gamepad.GamepadEnabled or GuiService.MenuIsOpen then
		return
	end

	-- equivalent call inferred; original call site unknown
	if shouldGamepadCursorBeEnabled() then
		if not Gamepad.GamepadEnabled then
			return
		end

		if GamepadService.GamepadCursorEnabled == true then
			return
		else
			GamepadService:EnableGamepadCursor(nil)
		end
	end
end

localPlayer:GetAttributeChangedSignal("State"):Connect(function()
	if localPlayer:GetAttribute("State") ~= PlayerStates.Idle then
		Gamepad:Unselect()

		if not Gamepad.GamepadEnabled then
			return
		end

		if GamepadService.GamepadCursorEnabled == false then
			return
		else
			GamepadService:DisableGamepadCursor()
		end
	end
end)
Gamepad.ContainerDisabled:Connect(function(p)
	if p.EnableCursorBehavior then
		Gamepad:HideCursor()
	end
end)
UserInputService.InputBegan:Connect(function(input, _: boolean)
	if input.KeyCode == Enum.KeyCode.ButtonB and not Gamepad:IsAnyContainerVisible() and localPlayer:GetAttribute("State") ~= PlayerStates.Idle then
		Gamepad:Unselect()
	end
end)

while task.wait() do
	if not Gamepad.GamepadEnabled or GuiService.MenuIsOpen then
		continue
	end

	local v = shouldGamepadCursorBeEnabled() -- equivalent call inferred; original call site unknown

	if v and Gamepad.GamepadEnabled and GamepadService.GamepadCursorEnabled ~= true then
		GamepadService:EnableGamepadCursor(nil)
	end
end