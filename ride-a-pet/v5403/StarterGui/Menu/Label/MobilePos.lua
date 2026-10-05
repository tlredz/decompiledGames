local UserInputService = game:GetService("UserInputService")
local v = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local parent = script.Parent

if v == false then
	parent.Position = UDim2.new(0.5, 0, 0.5, 0)
end