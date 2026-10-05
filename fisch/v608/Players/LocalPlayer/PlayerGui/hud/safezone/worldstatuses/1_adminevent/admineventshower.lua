local _ = script.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local world = ReplicatedStorage:WaitForChild("world")

-- equivalent calls inferred from this helper; original call sites unknown
local function shouldBeVisible()
	if world:FindFirstChild("AdminEventIcon") and world:FindFirstChild("AdminEventText") then
		return true
	end

	return false
end

world.ChildAdded:Connect(function(child)
	if child.Name == "AdminEventIcon" then
		task.wait(1)
		script.Parent.Image = child.Value

		if shouldBeVisible() then
			script.Parent.Visible = true
		end
	elseif child.Name == "AdminEventText" then
		task.wait(1)
		local label = script.Parent.label

		if label then
			label.Text = child.Value
		end

		if shouldBeVisible() then
			script.Parent.Visible = true
		end
	end
end)
world.ChildRemoved:Connect(function(child)
	if (child.Name == "AdminEventIcon" or child.Name == "AdminEventText") and not (world:FindFirstChild("AdminEventIcon") and world:FindFirstChild("AdminEventText")) then
		script.Parent.Visible = false
	end
end)
task.wait(5)
script.Parent.MouseEnter:Connect(function()
	local label = script.Parent:WaitForChild("label")
	label.Visible = true
end)
script.Parent.MouseLeave:Connect(function()
	local label = script.Parent:WaitForChild("label")
	label.Visible = false
end)