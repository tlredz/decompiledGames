local GamepadState = {}
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("GuiService")
local FastSignal = require(ReplicatedStorage.Modules.FastSignal)
GamepadState.GamepadEnabled = false
GamepadState.GamepadConnected = FastSignal.new()
GamepadState.GamepadDisconnected = FastSignal.new()
GamepadState.GamepadChanged = FastSignal.new()

function isGamepadEnabled()
	return UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function update()
	local gamepadEnabled = isGamepadEnabled()

	if gamepadEnabled ~= GamepadState.GamepadEnabled then
		GamepadState.GamepadEnabled = gamepadEnabled

		if GamepadState.GamepadEnabled then
			GamepadState.GamepadConnected:Fire()
		else
			GamepadState.GamepadDisconnected:Fire()
		end

		GamepadState.GamepadChanged:Fire()
	end
end

UserInputService.LastInputTypeChanged:Connect(update)
UserInputService.GamepadConnected:Connect(update)
UserInputService.GamepadDisconnected:Connect(update)
update() -- equivalent call inferred; original call site unknown
return GamepadState