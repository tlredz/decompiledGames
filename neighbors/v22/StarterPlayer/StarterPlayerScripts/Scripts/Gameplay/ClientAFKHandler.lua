local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Network = require(ReplicatedStorage.Modules.Network)
local Gamepad = require(ReplicatedStorage.Modules.Gamepad)
local localPlayer = Players.LocalPlayer
local v = true
local now = 0
local now2 = 0
local v2 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function setAFKStatus(playerAFK: boolean)
	if v2 ~= playerAFK then
		v2 = playerAFK
		Network:fire("AFK", playerAFK)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isPlayerAFK()
	if UserInputService.TouchEnabled or Gamepad.GamepadEnabled then
		return false
	end

	return not v and os.clock() - now2 > 120 or os.clock() - now > 300
end

UserInputService.WindowFocused:connect(function()
	v = true
end)
UserInputService.WindowFocusReleased:connect(function()
	v = false
	now2 = os.clock()
end)
localPlayer:GetMouse().Move:Connect(function()
	now = os.clock()
end)

while task.wait(0.1) do
	local playerAFK = isPlayerAFK() -- equivalent call inferred; original call site unknown
	setAFKStatus(playerAFK) -- equivalent call inferred; original call site unknown
end