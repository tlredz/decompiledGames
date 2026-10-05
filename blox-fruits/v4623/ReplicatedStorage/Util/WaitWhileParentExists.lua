return function(instance, childName)
	while instance and instance:IsDescendantOf(workspace) do
		local child = instance:FindFirstChild(childName)

		if child then
			return child
		else
			task.wait()
		end
	end
end