local parent = script.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local world = ReplicatedStorage:WaitForChild("world")

function Check()
	if world:WaitForChild("cycle").Value == "Day" then
		parent.Image = "rbxassetid://16956671093"
	elseif world:WaitForChild("cycle").Value == "Night" then
		parent.Image = "rbxassetid://16956670840"
	end

	local label = script.Parent:WaitForChild("label")
	label.Text = world:WaitForChild("cycle").Value
end

world:WaitForChild("cycle").Changed:Connect(function()
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