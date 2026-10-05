local Tasks = {
	Waiting = nil,
	Doing = nil,
	Cache = {}
}

function Tasks.ClearCache()
	if Tasks.Cache ~= nil then
		for k, connection in pairs(Tasks.Cache) do
			local typeName = typeof(connection)

			if typeName == "RBXScriptConnection" then
				connection:Disconnect()
			end

			if typeName == "table" and connection.Destroy ~= nil or typeName == "Instance" then
				connection:Destroy()
			end

			Tasks.Cache[k] = nil
		end

		Tasks.Cache = {}
	end
end

return Tasks