local Players = game:GetService("Players")

local function observePlayer(callback)
	local playerAddedConnection = nil
	local v = {}
	local v2 = {}

	local function OnPlayerAdded(p)
		if not playerAddedConnection.Connected then
			return
		end

		task.spawn(function()
			v2[p] = Enum.PlayerExitReason.Unknown
			local v3 = callback(p)

			if typeof(v3) == "function" then
				if playerAddedConnection.Connected and p.Parent then
					v[p] = v3
				else
					task.spawn(v3, v2[p])
				end
			end

			v2[p] = nil
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function OnPlayerRemoving(p, p2)
		if v2[p] then
			v2[p] = p2
		end

		local v3 = v[p]
		v[p] = nil

		if typeof(v3) == "function" then
			task.spawn(v3, p2)
		end
	end

	playerAddedConnection = Players.PlayerAdded:Connect(OnPlayerAdded)
	local playerRemovingConnection = Players.PlayerRemoving:Connect(OnPlayerRemoving)
	task.defer(function()
		if not playerAddedConnection.Connected then
			return
		end

		for _, v3 in Players:GetPlayers() do
			task.spawn(OnPlayerAdded, v3)
		end
	end)
	return function()
		playerAddedConnection:Disconnect()
		playerRemovingConnection:Disconnect()
		local v3 = next(v)

		while v3 do
			OnPlayerRemoving(v3, v2[v3]) -- equivalent call inferred; original call site unknown
			v3 = next(v)
		end
	end
end

return observePlayer