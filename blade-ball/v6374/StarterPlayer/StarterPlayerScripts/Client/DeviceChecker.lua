local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local DeviceChecker = {
	GetDeviceType = function(self)
		local v = "Unknown"

		if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
			if UserInputService.KeyboardEnabled then
				return "Tablet"
			end

			return "Mobile"
		elseif UserInputService.GamepadEnabled then
			return "Console"
		else
			return UserInputService.MouseEnabled and UserInputService.KeyboardEnabled and "PC" or v
		end
	end
}

function DeviceChecker.IsMobile(_)
	local deviceType = DeviceChecker:GetDeviceType()
	return deviceType == "Mobile" or deviceType == "Tablet"
end

return DeviceChecker