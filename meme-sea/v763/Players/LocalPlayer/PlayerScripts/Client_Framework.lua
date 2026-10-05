for _, moduleScript in ipairs(script:GetChildren()) do
	if moduleScript:IsA("ModuleScript") then
		require(moduleScript)
	end
end