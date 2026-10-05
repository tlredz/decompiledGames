local parent = script.Parent
parent.Equipped:Connect(function()
	workspace.Gravity = 29.429999999999996
end)
parent.Unequipped:Connect(function()
	workspace.Gravity = 196.2
end)