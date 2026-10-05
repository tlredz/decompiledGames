local UserInputService = game:GetService("UserInputService")
local Signal2 = require(game.ReplicatedStorage.Util.Signal2)
local LastInput = {
	Changed = Signal2.new()
}
local v = nil
local v2 = nil

local function lastInputTypeChanged(lastInputType)
	v2 = v
	local RunService = game:GetService("RunService")

	if RunService:IsStudio() and UserInputService.TouchEnabled then
		v = "Touch"
	elseif UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not (UserInputService.MouseEnabled or UserInputService.GamepadEnabled) then
		v = "Touch"
	elseif string.match(lastInputType.Name, "Gamepad") then
		v = "Gamepad"
	elseif lastInputType.Name == "Keyboard" or string.match(lastInputType.Name, "Mouse") then
		v = "MouseKeyboard"
	elseif lastInputType.Name == "Touch" then
		v = "Touch"
	end

	if v2 ~= v then
		LastInput.Changed:Fire(v, v2)
	end
end

function LastInput.GetControllerType(_)
	local stringForKeyCode = UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonA)

	if stringForKeyCode == "ButtonA" then
		return "Xbox"
	elseif stringForKeyCode == "ButtonCross" then
		return "PlayStation"
	end

	return nil
end

function LastInput.GetScaleForPlatform(_)
	local v3 = LastInput:Get()

	if v3 == "MouseKeyboard" then
		return 0.9
	elseif v3 == "Gamepad" then
		return 1.2
	end

	return v3 == "Touch" and 0.7 or 1
end

function LastInput:Get()
	return v, v2
end

function LastInput.IsMobile()
	return v == "Touch"
end

lastInputTypeChanged(UserInputService:GetLastInputType())
UserInputService.LastInputTypeChanged:Connect(lastInputTypeChanged)
return LastInput