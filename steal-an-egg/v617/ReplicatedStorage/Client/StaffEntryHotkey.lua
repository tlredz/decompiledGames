local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Signal = require(ReplicatedStorage.Packages.Signal)
local rightBracket = Enum.KeyCode.RightBracket
local StaffEntryHotkey = {
	Changed = Signal.new()
}
local v = false

local function onInputBegan(p, flag: boolean)
	if flag or UserInputService:GetFocusedTextBox() or p.KeyCode ~= rightBracket then
		return
	end

	v = not v
	StaffEntryHotkey.Changed:Fire(v)
end

function StaffEntryHotkey.IsHidden()
	return v
end

UserInputService.InputBegan:Connect(onInputBegan)
return StaffEntryHotkey