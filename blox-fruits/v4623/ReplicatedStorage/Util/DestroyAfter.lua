local function DestroyAfter(instance, duration)
	task.delay(duration, function()
		if instance ~= nil then
			instance:Destroy()
		end
	end)
end

return DestroyAfter