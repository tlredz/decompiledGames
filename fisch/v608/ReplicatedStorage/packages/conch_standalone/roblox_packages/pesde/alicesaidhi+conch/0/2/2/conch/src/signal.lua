require("./types")

local function create_signal()
	local v = {}
	return {
		connect = function(_, callback)
			local flag = false
			local v2 = {
				callback = callback
			}

			function v2.disconnect()
				if flag then
					return
				end

				flag = true
				v2.disconnected = true
				local index = table.find(v, v2)

				if not index then
					return
				end

				table.remove(v, index)
			end

			return v2
		end,
		fire = function(_, ...)
			for _, v2 in v do
				v2.callback(...)
			end
		end
	}
end

return create_signal