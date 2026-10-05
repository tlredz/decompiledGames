local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
return {
	GetPlatform = function()
		local v = "pc"

		if UserInputService.TouchEnabled then
			v = (UserInputService.AccelerometerEnabled or UserInputService.GyroscopeEnabled) and "mobile" or RunService:IsStudio() and "mobile" or v
		end

		return UserInputService.GamepadEnabled and "console" or v
	end
}