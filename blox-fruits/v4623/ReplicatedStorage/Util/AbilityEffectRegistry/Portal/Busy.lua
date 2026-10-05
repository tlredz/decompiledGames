return function(player, p)
	local doorMode = player.Character:FindFirstChild("DoorMode")

	if p and doorMode then
		doorMode.Parent = nil
		task.delay(1, function()
			doorMode:Destroy()
		end)
	end

	return doorMode ~= nil
end