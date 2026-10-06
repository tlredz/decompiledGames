local module = require("@game/ReplicatedStorage/Omni")
local lastInputType = module.Services.UserInputService:GetLastInputType()
local Platform = {
	CheckPlatform = function()
		if module.Services.UserInputService.GamepadEnabled and lastInputType.Name:match("Gamepad") then
			return "Console"
		end

		if module.Services.UserInputService.KeyboardEnabled then
			return "Computer"
		end

		if module.Services.UserInputService.TouchEnabled then
			return "Mobile"
		end

		return "Computer"
	end
}

function Platform.UpdatePlatform()
	module.Platform = Platform.CheckPlatform()
end

module.Services.UserInputService.LastInputTypeChanged:Connect(function(p)
	if lastInputType.Name:match("Gamepad") then
		if not p.Name:match("Gamepad") then
			lastInputType = p
			Platform.UpdatePlatform()
		end
	elseif p.Name:match("Gamepad") then
		lastInputType = p
		Platform.UpdatePlatform()
	end
end)
module.Services.UserInputService.GamepadConnected:Connect(function()
	Platform.UpdatePlatform()
end)
module.Services.UserInputService.GamepadDisconnected:Connect(function()
	Platform.UpdatePlatform()
end)
Platform.UpdatePlatform()
return Platform