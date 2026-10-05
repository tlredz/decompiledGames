return function(instance)
	if instance == nil or not instance:IsDescendantOf(workspace.Humanoids) then
		return
	end

	local parent = instance.Parent

	for _ = 1, 5 do
		if parent ~= nil and parent:FindFirstChild("Humanoid") then
			break
		end

		if parent.Parent ~= nil then
			parent = parent.Parent
		end
	end

	if parent ~= nil and parent:FindFirstChild("Humanoid") == nil then
		parent = nil
	end

	return parent
end