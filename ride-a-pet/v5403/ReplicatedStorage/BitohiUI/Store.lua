return {
	new = function()
		local v = {}
		return (setmetatable({}, {
			__newindex = function(p, instance, p2)
				rawset(p, instance, p2)

				if p2 == nil or typeof(instance) ~= "Instance" or v[instance] then
					return
				end

				v[instance] = instance.Destroying:Connect(function()
					local connection = v[instance]
					v[instance] = nil

					if connection then
						connection:Disconnect()
					end

					rawset(p, instance, nil)
				end)
			end
		}))
	end
}