local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
return function(list, flag: boolean?, value: number?)
	local state, setState = React.useState(nil)
	local clone = table.clone(list)
	local v = value or 0.5
	assert(v, "bad fuzzyEq")
	table.insert(clone, 1, flag)
	table.insert(clone, 1, v)
	table.insert(clone, 1, state)
	React.useEffect(function()
		if not (#list > 0) then
			return function() end
		end

		local connections = {}
		local v2 = false
		local v3 = false

		local function calculateAbsoluteArea()
			local v4 = 1e999
			local v5 = 1e999
			local v6 = -1e999
			local v7 = -1e999

			for _, v8 in list do
				if not (v8 and v8.Parent) then
					continue
				end

				local absolutePosition = v8.AbsolutePosition
				local absoluteSize = v8.AbsoluteSize
				v4 = math.min(v4, absolutePosition.X)
				v5 = math.min(v5, absolutePosition.Y)
				v6 = math.max(v6, absolutePosition.X + absoluteSize.X)
				v7 = math.max(v7, absolutePosition.Y + absoluteSize.Y)
			end

			if v4 == 1e999 or v5 == 1e999 or v6 == -1e999 or v7 == -1e999 then
				setState(nil)
				return
			end

			if state and math.abs(state.Min.X - v4) < v and math.abs(state.Min.Y - v5) < v and math.abs(state.Max.X - v6) < v and math.abs(state.Max.Y - v7) < v then
				return
			end

			setState(Rect.new(v4, v5, v6, v7))
		end

		if not flag then
			table.insert(connections, RunService.RenderStepped:Connect(function()
				if v2 and not v3 then
					v2 = false
					v3 = true
					local success, result = pcall(function()
						calculateAbsoluteArea()
					end)

					if not success then
						warn("[useContainerAbsoluteArea] Failed to calculate absolute area: " .. tostring(result))
					end

					v3 = false
				end
			end))
		end

		for _, v4 in list do
			table.insert(connections, v4:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
				if flag then
					calculateAbsoluteArea()
				else
					v2 = true
				end
			end))
			table.insert(connections, v4:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				if flag then
					calculateAbsoluteArea()
				else
					v2 = true
				end
			end))
		end

		calculateAbsoluteArea()
		return function()
			for _, connection in connections do
				connection:Disconnect()
			end
		end
	end, clone)
	return state
end