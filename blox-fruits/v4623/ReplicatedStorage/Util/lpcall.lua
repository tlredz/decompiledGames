local function lpcall(callback, ...)
	local v = nil
	local v2, v3 = xpcall(callback, function(p)
		local parts = debug.traceback(""):split("\n")
		local TestService = game:GetService("TestService")
		TestService:Error(p)
		local TestService2 = game:GetService("TestService")
		TestService2:Message("Stack Begin")

		for i = 2, #parts do
			if i == #parts - 2 then
				continue
			end

			local v4, v5, v6, v7 = debug.info(i, "lsfn")
			local script

			if v6 then
				script = getfenv(v6).script
			end

			if v4 == nil or v4 < 1 then
				continue
			end

			local TestService3 = game:GetService("TestService")
			TestService3:Message((`{script.ClassName} '{v5}', Line {v4}{(v7 == "" or v7 == nil) and "" or " - function " .. v7}`))
		end

		local TestService3 = game:GetService("TestService")
		TestService3:Message("Stack End")
		v = p
	end, ...)
	return v2, v or v3
end

return lpcall