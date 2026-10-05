for _, child in game.ReplicatedStorage:WaitForChild("Dialogue"):WaitForChild("Modules"):GetChildren() do
	local v = child
	task.spawn(function()
		require(v)
	end)
end