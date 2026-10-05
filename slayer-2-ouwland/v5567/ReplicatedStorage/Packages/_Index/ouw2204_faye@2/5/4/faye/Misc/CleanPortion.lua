local typeof2 = typeof
return function(list, p: number?)
	for i = p or #list, 1, -1 do
		local connection = list[i]
		local typeName = typeof2(connection)
		list[i] = nil

		if typeName == "table" then
			if connection.Destroy ~= nil or connection.Clean ~= nil then
				if connection.__Destroying then
					list[i] = nil
				elseif connection.Destroy then
					connection:Destroy()
				elseif connection.Clean then
					connection:Clean()
				end
			end
		elseif typeName == "Instance" then
			connection:Destroy()
		elseif typeName == "function" then
			connection()
		elseif typeName == "RBXScriptConnection" then
			connection:Disconnect()
		elseif typeName == "thread" then
			task.cancel(connection)
		end
	end
end