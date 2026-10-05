local UserInputService = game:GetService("UserInputService")
require(script.Parent:WaitForChild("BaseScreenGui"))
local ScreenGui3D = require(script.Parent:WaitForChild("ScreenGui3D"))
local ScreenGui2D = require(script.Parent:WaitForChild("ScreenGui2D"))

if UserInputService.VREnabled then
	return ScreenGui3D
end

return ScreenGui2D