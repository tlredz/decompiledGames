local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fx = require(ReplicatedStorage.shared.modules:WaitForChild("fx"))
local parent = script.Parent

local function switchCategory(p)
	p.Visible = true

	for _, frame in pairs(parent:GetChildren()) do
		if not (frame ~= p and frame:IsA("Frame") and string.find(frame.Name, "catagory", 1, true)) then
			continue
		end

		frame.Visible = false
	end
end

for _, button in pairs(parent:WaitForChild("sections"):GetChildren()) do
	if not (button:IsA("ImageButton") and parent:FindFirstChild(button.Name)) then
		continue
	end

	local v = button
	button.Activated:Connect(function()
		switchCategory(parent:FindFirstChild(v.Name) or "catagory")
	end)
	button.MouseButton1Click:Connect(function()
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		fx:PlaySound(
			ReplicatedStorage2:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("player"):WaitForChild("bestiaryCatagory"),
			script.Parent,
			true
		)
	end)
	button.MouseEnter:Connect(function()
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		fx:PlaySound(
			ReplicatedStorage2:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("itemhover"),
			script.Parent,
			true
		)
	end)
end