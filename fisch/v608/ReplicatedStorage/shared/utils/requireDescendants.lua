return function(folder)
	local descendants = folder:GetDescendants()

	for _, moduleScript in descendants do
		if moduleScript:IsA("ModuleScript") then
			task.spawn(require, moduleScript)
		end
	end
end