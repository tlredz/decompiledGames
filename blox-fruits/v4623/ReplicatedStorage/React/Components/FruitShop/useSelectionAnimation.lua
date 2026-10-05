local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
return function(p, items, callback, callback2, p2: number, flag: boolean)
	local state, setState = React.useState((table.freeze({})))
	React.useEffect(function()
		if not flag or next(items) == nil then
			return
		end

		local function update()
			local now = tick()
			local v = {}
			local v2 = nil
			local v3 = nil
			local v4 = false

			for k, item in items do
				local v5 = math.clamp((now - item) / p2, 0, 1)
				local v6

				if p[k] then
					v6 = v5
				else
					v6 = 1 - v5
				end

				v[k] = v6

				if v5 < 1 then
					v4 = true
				elseif not p[k] then
					v2 = v2 or table.clone(items)
					v3 = v3 or table.clone(p)
					rawset(v2, k, nil)
					rawset(v3, k, nil)
				end
			end

			setState(table.freeze(v))

			if v2 then
				callback2(table.freeze(v2))
			end

			if v3 then
				callback(table.freeze(v3))
			end

			return v4
		end

		if not update() then
			return
		end

		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			if not update() then
				renderSteppedConnection:Disconnect()
			end
		end)
		return function()
			renderSteppedConnection:Disconnect()
		end
	end, {
		p,
		items,
		p2,
		flag
	})
	return state
end