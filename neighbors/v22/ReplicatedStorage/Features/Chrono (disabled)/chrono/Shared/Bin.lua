return function()
	local v = {}
	return function(p)
		table.insert(v, p)
		return p
	end, function()
		for _, connection in v do
			if typeof(connection) == "Instance" then
				connection:Destroy()
			elseif typeof(connection) == "RBXScriptConnection" then
				connection:Disconnect()
			elseif typeof(connection) == "function" then
				task.spawn(connection)
			elseif typeof(connection) == "thread" then
				pcall(task.cancel, connection)
			elseif typeof(connection) == "table" and connection._binCleanup and type(connection._binCleanup) == "function" then
				connection:_binCleanup()
			end
		end

		table.clear(v)
	end
end