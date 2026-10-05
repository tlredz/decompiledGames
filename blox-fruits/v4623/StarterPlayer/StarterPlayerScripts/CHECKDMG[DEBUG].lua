game.ReplicatedStorage.Remotes:WaitForChild("DMGDEBUG").OnClientEvent:Connect(function(p, p2, p3, p4)
	print(string.format(
		"[DMGDEBUG] %s -> %s | dmg=%.1f | %s",
		tostring(p2),
		tostring(p),
		tonumber(p3) or 0,
		(tostring(p4))
	))
end)