local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local mouseLocation = nil
local position = nil
local parent = script.Parent.Parent
script.Parent.MouseButton1Down:Connect(function()
	mouseLocation = UserInputService:GetMouseLocation()
	position = parent.Position
end)
UserInputService.InputChanged:Connect(function(input, _)
	if mouseLocation and input.UserInputType == Enum.UserInputType.MouseMovement then
		local v = UserInputService:GetMouseLocation() - mouseLocation
		parent.Position = UDim2.new(
			position.X.Scale,
			position.X.Offset + v.X,
			position.Y.Scale,
			position.Y.Offset + v.Y
		)
	end
end)
UserInputService.InputEnded:Connect(function(input, _)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and mouseLocation then
		mouseLocation = nil
	end
end)