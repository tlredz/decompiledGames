function observeDescendants(folder, callback)
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
		if descendantAddedConnection and descendantAddedConnection.Connected then
			v[p] = callback(p)
		end
	end

	descendantAddedConnection = folder.DescendantAdded:Connect(OnInstanceAdded)
	local descendantRemovingConnection = folder.DescendantRemoving:Connect(OnInstanceRemoved)
	task.defer(function()
		if not (descendantAddedConnection and descendantAddedConnection.Connected) then
			return
		end

		for _, descendant in folder:GetDescendants() do
			task.spawn(OnInstanceAdded, descendant)
		end

		local v2 = folder

		if descendantAddedConnection then
			if not descendantAddedConnection.Connected then
				return
			end

			v[v2] = callback(v2)
		end
	end)
	return function(p)
		if p == nil then
			if descendantAddedConnection then
				descendantAddedConnection:Disconnect()
			end

			if descendantRemovingConnection then
				descendantRemovingConnection:Disconnect()
			end

			local v2 = next(v)

			while v2 do
				OnInstanceRemoved(v2) -- equivalent call inferred; original call site unknown
				v2 = next(v)
			end
		elseif p == true then
			if descendantAddedConnection or descendantRemovingConnection then
				return
			end

			descendantAddedConnection = folder.DescendantAdded:Connect(OnInstanceAdded)
			descendantRemovingConnection = folder.DescendantRemoving:Connect(OnInstanceRemoved)
		elseif p == false then
			if descendantAddedConnection then
				descendantAddedConnection:Disconnect()
				descendantAddedConnection = nil
			end

			if descendantRemovingConnection then
				descendantRemovingConnection:Disconnect()
				descendantRemovingConnection = nil
			end
		end
	end
end

return observeDescendants