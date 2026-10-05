local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fx = require(ReplicatedStorage.shared.modules:WaitForChild("fx"))
script.Parent.MouseEnter:Connect(function()
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	fx:PlaySound(
		ReplicatedStorage2:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("itemhover"),
		script.Parent,
		true
	)
end)
script.Parent.MouseButton1Click:Connect(function()
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	fx:PlaySound(
		ReplicatedStorage2:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("click" .. math.random(
			1,
			2
		)),
		script.Parent,
		true
	)
end)