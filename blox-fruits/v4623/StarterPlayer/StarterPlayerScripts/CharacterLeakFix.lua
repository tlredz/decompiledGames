local function fix(instance)
	if instance.Parent then
		return
	end

	task.wait(10)

	if instance.Parent then
		return
	end

	pcall(function()
		instance:Destroy()
	end)
end

workspace.Characters.ChildRemoved:Connect(fix)
workspace.Enemies.ChildRemoved:Connect(fix)