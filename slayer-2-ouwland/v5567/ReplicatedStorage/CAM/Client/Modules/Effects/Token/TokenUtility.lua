local TokenUtility = {
	DelayDestruction = function(duration: number, instance)
		task.delay(duration, function()
			instance:Destroy()
		end)
	end
}

for _, moduleScript in ipairs(script:GetChildren()) do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)

	for k, v in pairs(module) do
		TokenUtility[k] = v
	end
end

return TokenUtility