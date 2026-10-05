function observeChildren(folder, callback)
	local v = {}
	local descendantAddedConnection = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function OnInstanceRemoved(p)
		local v2 = v[p]
		v[p] = nil

		if typeof(v2) == "function" then
			task.spawn(v2)
		end
	end

	local function OnInstanceAdded(p)
		if not descendantAddedConnection.Connected then
			return
		end

		v[p] = callback(p)
	end

	descendantAddedConnection = folder.DescendantAdded:Connect(OnInstanceAdded)
	local descendantRemovingConnection = folder.DescendantRemoving:Connect(OnInstanceRemoved)
	task.defer(function()
		if not descendantAddedConnection.Connected then
			return
		end

		for _, descendant in folder:GetDescendants() do
			task.spawn(OnInstanceAdded, descendant)
		end
	end)
	return function()
		descendantAddedConnection:Disconnect()
		descendantRemovingConnection:Disconnect()
		local v2 = next(v)

		while v2 do
			OnInstanceRemoved(v2) -- equivalent call inferred; original call site unknown
			v2 = next(v)
		end
	end
end

return observeChildren