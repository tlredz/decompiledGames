_G.CmdrLog = {}
return function(registry)
	registry:RegisterHook("AfterRun", function(context)
		if context.Name == "logs" then
			return
		end

		table.insert(_G.CmdrLog, {
			PlayerName = context.Executor.Name,
			Context = context
		})

		if #_G.CmdrLog > 25 then
			table.remove(_G.CmdrLog, 1)
		end
	end)
end