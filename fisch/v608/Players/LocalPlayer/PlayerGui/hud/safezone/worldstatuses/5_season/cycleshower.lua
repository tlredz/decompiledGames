local parent = script.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local world = ReplicatedStorage:WaitForChild("world")

function Check()
	if world:WaitForChild("season").Value == "Autumn" then
		parent.Image = "rbxassetid://17746816954"
	elseif world:WaitForChild("season").Value == "Summer" then
		parent.Image = "rbxassetid://17746817125"
	elseif world:WaitForChild("season").Value == "Spring" then
		parent.Image = "rbxassetid://17746816696"
	elseif world:WaitForChild("season").Value == "Winter" then
		parent.Image = "rbxassetid://17746816531"
	end

	local label = script.Parent:WaitForChild("label")
	label.Text = world:WaitForChild("season").Value
end

world:WaitForChild("season").Changed:Connect(function()
	Check()
end)
task.wait()
Check()
script.Parent.MouseEnter:Connect(function()
	local label = script.Parent:WaitForChild("label")
	label.Visible = true
end)
script.Parent.MouseLeave:Connect(function()
	local label = script.Parent:WaitForChild("label")
	label.Visible = false
end)