return {
	AddResizeFunction = function(maid, callback)
		callback()
		maid:Add(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			task.delay(0.05, function()
				callback()
			end)
		end))
	end
}