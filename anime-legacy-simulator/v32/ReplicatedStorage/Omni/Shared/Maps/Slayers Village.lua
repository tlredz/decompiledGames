for _, moduleScript in script:GetChildren() do
	if moduleScript:IsA("ModuleScript") then
		require(moduleScript)
	end
end

return {
	Index = 2,
	Lighting = "Slayers Village",
	Icon = "rbxassetid://131614497496948",
	UnlockMethod = "You need to complete Heaven Island Quest!"
}