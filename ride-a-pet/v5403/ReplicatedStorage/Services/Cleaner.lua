return {
	Clean = function(_, items)
		for _, item in items do
			if typeof(item) == "thread" then
				task.cancel(item)
			elseif typeof(item) == "RBXScriptConnection" then
				item:Disconnect()
			end
		end
	end
}