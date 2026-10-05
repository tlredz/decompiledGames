local parent = script.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local world = ReplicatedStorage:WaitForChild("world")

function Check()
	if world:WaitForChild("event").Value == "None" then
		script.Parent.Visible = false
		return
	end

	script.Parent.Visible = true
	local label = script.Parent:WaitForChild("label")
	label.Text = world:WaitForChild("event").Value
	parent.ImageColor3 = Color3.fromRGB(255, 255, 255)
	parent.Image = "rbxassetid://18997116922"

	if world:WaitForChild("event").Value == "Night of the Fireflies" then
		parent.ImageColor3 = Color3.fromRGB(168, 133, 255)
	elseif world:WaitForChild("event").Value == "Night of the Luminous" then
		parent.ImageColor3 = Color3.fromRGB(162, 255, 184)
	elseif world:WaitForChild("event").Value == "Shiny Surge" then
		parent.ImageColor3 = Color3.fromRGB(255, 238, 143)
	elseif world:WaitForChild("event").Value == "Mutation Surge" then
		parent.ImageColor3 = Color3.fromRGB(88, 255, 102)
	end
end

world:WaitForChild("event").Changed:Connect(function()
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