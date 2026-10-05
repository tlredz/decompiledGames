local function scheduler(p: string, callback)
	local states = {}
	local v2 = 0
	local heartbeatConnection = nil

	local function remove(p2)
		local index = table.find(states, p2)

		if index then
			states[index] = states[v2]
			states[v2] = nil
			v2 -= 1
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function step(dt: number)
		for i = v2, 1, -1 do
			callback(states[i], dt, remove)
		end
	end

	return {
		states = states,
		update = function(p2, p3: number)
			return callback(p2, p3, remove)
		end,
		step = step,
		add = function(p2)
			if table.find(states, p2) then
				return
			end

			table.insert(states, p2)
			v2 += 1

			if game and not heartbeatConnection then
				local RunService = game:GetService("RunService")
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					debug.profilebegin((`Ripple{p}`))
					step(dt) -- equivalent call inferred; original call site unknown
					debug.profileend()

					if heartbeatConnection and v2 == 0 then
						heartbeatConnection:Disconnect()
						heartbeatConnection = nil
					end
				end)
			end
		end,
		remove = remove,
		clear = function()
			table.clear(states)
			v2 = 0
		end
	}
end

return scheduler