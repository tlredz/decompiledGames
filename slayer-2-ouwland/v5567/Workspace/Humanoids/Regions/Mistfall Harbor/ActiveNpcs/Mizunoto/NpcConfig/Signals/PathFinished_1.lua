return function(data)
	local pathRetries = data.Following.PathRetries

	if pathRetries.Current > 0 then
		pathRetries.Current -= 1
		local entity

		if data.Spawning ~= nil then
			entity = data.Spawning.Entity or nil
		end

		local humanoid

		if entity ~= nil then
			humanoid = entity:FindFirstChild("Humanoid") or nil
		end

		if humanoid ~= nil and humanoid.Health > 0 then
			humanoid.Jump = true
		end

		if pathRetries.Current == 0 then
			local settings = data.Settings

			if settings == nil or settings.LoseInterestOnExhaustion ~= true or settings.AutoTargetPlayer ~= nil then
				if data.Folder ~= nil then
					data.Folder:SetAttribute("PathExhausted", pathRetries.ExhaustedInterval)
				end
			else
				data.Following.Reset(data)
			end
		end
	elseif data.Folder ~= nil then
		local pathExhausted = data.Folder:GetAttribute("PathExhausted")

		if typeof(pathExhausted) == "number" then
			local v = math.min(pathExhausted * pathRetries.ExhaustedGrowth, pathRetries.ExhaustedIntervalMax)
			data.Folder:SetAttribute("PathExhausted", v)
		end
	end
end