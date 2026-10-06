for _, moduleScript in script:GetChildren() do
	if moduleScript:IsA("ModuleScript") then
		require(moduleScript)
	end
end

return {
	Index = 3,
	Lighting = "Cursed Academy",
	Icon = "rbxassetid://85080504404379",
	UnlockMethod = "You need to complete Slayers Village Quest!"
}