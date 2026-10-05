local Platform = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")
local GuiService = game:GetService("GuiService")
local Signal = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Signal"))
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local v = true
local v2 = true
Platform.SuffixPrefix = "_"
Platform.Suffixes = {
	Mobile = {
		SuffixString = "Mobile"
	},
	Controller = {
		SuffixString = "Controller"
	},
	Keyboard = {
		SuffixString = "PC"
	}
}
GuiService.AutoSelectGuiEnabled = false
Platform.Mode = "Keyboard"
Platform.PlatformChangedSignal = Signal.new()

function Platform.IsMobile()
	return Platform.Mode == "Mobile"
end

function Platform.IsKeyboard()
	return Platform.Mode == "Keyboard"
end

function Platform.IsConsole()
	return Platform.Mode == "Controller"
end

function Platform:Select()
	if not v then
		return
	end

	if not (self and Platform.IsConsole() and self:IsA("GuiObject")) then
		GuiService.SelectedObject = nil
		return
	end

	if self.Selectable then
		GuiService.SelectedObject = self
	else
		GuiService:Select(self)
	end

	if GamepadService.GamepadCursorEnabled or not v2 then
		task.defer(function()
			local selectedObject = GuiService.SelectedObject

			if selectedObject then
				if selectedObject:FindFirstChild("GamepadCursorPosition") then
					GamepadService:EnableGamepadCursor(selectedObject.GamepadCursorPosition)
				else
					GamepadService:EnableGamepadCursor(selectedObject)
				end
			end
		end)
	end
end

function Platform.EndSelection()
	if Platform.IsConsole() then
		if GamepadService.GamepadCursorEnabled then
			GamepadService:DisableGamepadCursor()
		end

		GuiService.SelectedObject = nil
	end
end

function Platform.FrameworkInit()
	task.spawn(function()
		local v3, v4 = ABTest.GetExperimentVariable("console-controls", "enabled"):timeout(7):await()

		if v3 and typeof(v4) == "boolean" then
			v = v4
		end

		local v5, v6 = ABTest.GetExperimentVariable("console-controls", "dpadNavigation"):timeout(7):await()

		if v5 and typeof(v6) == "boolean" then
			v2 = v6
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ChangePlatform(mode)
	if Platform.Mode ~= mode then
		Platform.Mode = mode
		Platform.PlatformChangedSignal:Fire(mode)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GamepadChanged()
	if GuiService:IsTenFootInterface() or UserInputService.GamepadEnabled then
		ChangePlatform("Controller") -- equivalent call inferred; original call site unknown
	elseif UserInputService.TouchEnabled then
		ChangePlatform("Mobile") -- equivalent call inferred; original call site unknown
	else
		ChangePlatform("Keyboard") -- equivalent call inferred; original call site unknown
	end
end

GamepadChanged() -- equivalent call inferred; original call site unknown
UserInputService.GamepadConnected:Connect(GamepadChanged)
UserInputService.GamepadDisconnected:Connect(GamepadChanged)
UserInputService.InputBegan:Connect(function(input)
	if not UserInputService:GetFocusedTextBox() then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			ChangePlatform("Keyboard") -- equivalent call inferred; original call site unknown
		elseif input.UserInputType == Enum.UserInputType.Touch then
			ChangePlatform("Mobile") -- equivalent call inferred; original call site unknown
		elseif string.match(input.UserInputType.Name, "Gamepad") and Platform.Mode ~= "Controller" then
			Platform.Mode = "Controller"
			Platform.PlatformChangedSignal:Fire("Controller")
		end
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if not UserInputService:GetFocusedTextBox() and input.KeyCode == Enum.KeyCode.Thumbstick1 and Platform.Mode ~= "Controller" then
		Platform.Mode = "Controller"
		Platform.PlatformChangedSignal:Fire("Controller")
	end
end)
return Platform