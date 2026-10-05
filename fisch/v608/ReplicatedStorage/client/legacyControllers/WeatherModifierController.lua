return {
	Start = function(self)
		for _, moduleScript in script:GetChildren() do
			if not moduleScript:IsA("ModuleScript") then
				continue
			end

			local success, result = pcall(require, moduleScript)

			if success then
				if typeof(result) == "table" and typeof(result.Start) == "function" then
					local v = result
					local v2 = moduleScript
					task.spawn(function()
						local success2, result2 = pcall(function()
							v:Start()
						end)

						if not success2 then
							warn((`[WeatherModifierController] {v2.Name}: Start error: {result2}`))
						end
					end)
				end
			else
				warn((`[WeatherModifierController] failed to load {moduleScript.Name}: {result}`))
			end
		end
	end
}