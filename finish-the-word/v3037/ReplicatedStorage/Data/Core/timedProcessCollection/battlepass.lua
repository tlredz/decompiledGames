return {
	BpReset = {
		init = function(_, _, _) end,
		deinit = function(_, object, _)
			object:bpReset(true)
			task.defer(function()
				object:scheduleBpReset()
			end)
		end
	}
}