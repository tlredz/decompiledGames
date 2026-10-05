return function(onPlayerAdded)
	local playerAddedConnection = nil
	local flag = false

	local function fn()
		flag = true

		if playerAddedConnection then
			playerAddedConnection:Disconnect()
			playerAddedConnection = nil
		end
	end

	task.defer(function()
		if flag then
			return
		end

		for _, v in pairs(game.Players:GetPlayers()) do
			task.spawn(onPlayerAdded, v)
		end

		playerAddedConnection = game.Players.PlayerAdded:Connect(onPlayerAdded)
	end)
	return fn
end