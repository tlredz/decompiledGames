local Skills = {
	Performing = {},
	Holder = {},
	Cache = {},
	HoldStarted = {},
	LastStunBypass = 0,
	EndLagUntil = 0
}

function Skills.ClearCache()
	if Skills.Cache ~= nil then
		for k, connection in pairs(Skills.Cache) do
			local typeName = typeof(connection)

			if typeName == "RBXScriptConnection" then
				connection:Disconnect()
			end

			if typeName == "table" and connection.Destroy ~= nil or typeName == "Instance" then
				connection:Destroy()
			end

			Skills.Cache[k] = nil
		end

		Skills.Cache = {}
	end
end

return Skills