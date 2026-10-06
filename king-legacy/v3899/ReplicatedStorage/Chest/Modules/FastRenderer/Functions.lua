return {
	Heartbeat = function(instance, p)
		if instance.Function then
			task.spawn(function()
				if instance.Function(instance.CurrentTime, p) and not instance.Finished then
					instance:Destroy()
				end
			end)
		end
	end
}