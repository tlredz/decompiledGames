require(script.Parent.Types.Interface)
return {
	BindOnAdapterChanged = function(p, callback, callback2)
		local changedConnection = p.Changed:Connect(function()
			if callback(p) then
				callback2()
			end
		end)
		task.defer(function()
			if callback(p) then
				callback2()
			end
		end)
		return function()
			changedConnection:Disconnect()
		end
	end
}