return {
	create_continue = function(options)
		local timeout = (options or {}).timeout or 1e999
		local bindableEvent = Instance.new("BindableEvent")

		if timeout < 1e999 then
			local v = false
			delay(timeout, function()
				if bindableEvent then
					v = true
					bindableEvent:Fire()
				end
			end)
		end

		local v2 = false
		local v3 = nil
		return {
			continue = function(...)
				if bindableEvent then
					v2 = true
					v3 = { ... }
					bindableEvent:Fire()
				end
			end,
			yield = function()
				if not v2 then
					bindableEvent.Event:Wait()
				end

				bindableEvent:Destroy()
				return unpack(v3 or {})
			end
		}
	end
}