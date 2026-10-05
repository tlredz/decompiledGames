local Players = game:GetService("Players")

local function observePlayer(callback)
	local playerAddedConnection = nil
	local v = {}

	local function OnPlayerAdded(p)
		if not playerAddedConnection.Connected then
			return
		end

		task.spawn(function()
			local v2 = callback(p)

			if typeof(v2) == "function" then
				if playerAddedConnection.Connected and p.Parent then
					v[p] = v2
				else
					task.spawn(v2)
				end
			end
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function OnPlayerRemoving(p)
		local v2 = v[p]
		v[p] = nil

		if typeof(v2) == "function" then
			task.spawn(v2)
		end
	end

	playerAddedConnection = Players.PlayerAdded:Connect(OnPlayerAdded)
	local playerRemovingConnection = Players.PlayerRemoving:Connect(OnPlayerRemoving)
	task.defer(function()
		if not playerAddedConnection.Connected then
			return
		end

		for _, v2 in Players:GetPlayers() do
			task.spawn(OnPlayerAdded, v2)
		end
	end)
	return function()
		playerAddedConnection:Disconnect()
		playerRemovingConnection:Disconnect()
		local v2 = next(v)

		while v2 do
			OnPlayerRemoving(v2) -- equivalent call inferred; original call site unknown
			v2 = next(v)
		end
	end
end

return observePlayer