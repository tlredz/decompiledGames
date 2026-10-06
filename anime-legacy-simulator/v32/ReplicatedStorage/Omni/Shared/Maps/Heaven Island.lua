for _, moduleScript in script:GetChildren() do
	if moduleScript:IsA("ModuleScript") then
		require(moduleScript)
	end
end

return {
	Index = 1,
	Free = true,
	Lighting = "Heaven Island",
	Icon = "rbxassetid://80032705971710"
}