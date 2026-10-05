local parent = script.Parent
local frame = parent:WaitForChild("Frame")
local VR = parent:WaitForChild("VR")
local UserInputService = game:GetService("UserInputService")

if UserInputService.VREnabled then
	frame.Visible = false
	VR.Visible = true
end