for _, moduleScript in script:GetChildren() do
	if moduleScript:IsA("ModuleScript") then
		require(moduleScript)
	end
end

return {
	Index = 0,
	Free = true,
	Lighting = "Heaven Island",
	SpecialName = "Lobby",
	Icon = "rbxassetid://139665916326215"
}