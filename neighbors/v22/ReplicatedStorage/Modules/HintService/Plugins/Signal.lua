return {
	Create = function()
		local bindableEvent = Instance.new("BindableEvent")
		local v2 = nil
		local v3 = nil
		return {
			Fire = function(self, ...)
				v2 = { ... }
				v3 = select("#", ...)
				bindableEvent:Fire()
			end,
			Connect = function(self, callback)
				if not callback then
					error("connect(nil)", 2)
				end

				return bindableEvent.Event:Connect(function()
					callback(unpack(v2, 1, v3))
				end)
			end,
			Wait = function(self)
				bindableEvent.Event:Wait()
				assert(v2, "Missing arg data, likely due to :TweenSize/Position corrupting threadrefs.")
				return unpack(v2, 1, v3)
			end
		}
	end
}