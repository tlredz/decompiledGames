function observeChildren(instance, callback)
	local v = {}
	local childAddedConnection = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function OnInstanceRemoved(p)
		local v2 = v[p]
		v[p] = nil

		if typeof(v2) == "function" then
			task.spawn(v2)
		end
	end

	local function OnInstanceAdded(p)
		if not childAddedConnection.Connected or v[p] then
			return
		end

		v[p] = true
		v[p] = callback(p)
	end

	childAddedConnection = instance.ChildAdded:Connect(OnInstanceAdded)
	local childRemovedConnection = instance.ChildRemoved:Connect(OnInstanceRemoved)
	task.defer(function()
		if not childAddedConnection.Connected then
			return
		end

		for _, child in instance:GetChildren() do
			task.spawn(OnInstanceAdded, child)
		end
	end)
	return function()
		childAddedConnection:Disconnect()
		childRemovedConnection:Disconnect()
		local v2 = next(v)

		while v2 do
			OnInstanceRemoved(v2) -- equivalent call inferred; original call site unknown
			v2 = next(v)
		end
	end
end

return observeChildren