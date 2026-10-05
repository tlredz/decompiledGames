local ContextActionService = game:GetService("ContextActionService")
local module = require("../HudController")
local module2 = require("../SettingsController")
local JumpProtectController = {}
local flag = false
local now = 0

function JumpProtectController:CanJump()
	return not module2:GetSettingValue("consoleJumpProtection") or not (flag or tick() - now < 1)
end

function JumpProtectController.Start(_)
	local playerGui = module:GetPlayerGui()

	local function update()
		if playerGui:FindFirstChild("reel") or playerGui:FindFirstChild("stab") or playerGui:FindFirstChild("grab") or playerGui:FindFirstChild("harpoonMinigame") then
			flag = true
			now = tick()
		else
			if flag then
				now = tick()
			end

			flag = false
		end
	end

	ContextActionService:BindActionAtPriority("ConsoleJumpProtection", function(_, p, _)
		if p ~= Enum.UserInputState.Begin or JumpProtectController:CanJump() then
			return Enum.ContextActionResult.Pass
		end

		return Enum.ContextActionResult.Sink
	end, false, 2001, Enum.KeyCode.ButtonA)
	playerGui.ChildAdded:Connect(update)
	playerGui.ChildRemoved:Connect(update)
	update()
end

return JumpProtectController