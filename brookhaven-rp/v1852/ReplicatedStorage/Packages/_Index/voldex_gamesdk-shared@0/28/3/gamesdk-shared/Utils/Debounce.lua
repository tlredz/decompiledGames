local Players = game:GetService("Players")
local object = setmetatable({}, {
	__mode = "v"
})
Players.PlayerAdded:Connect(function(player)
	player.CharacterRemoving:Connect(function(character)
		for _, v in object do
			v.dbObjects[character] = nil
		end
	end)
end)
Players.PlayerRemoving:Connect(function(player)
	for _, v in object do
		v.dbObjects[player] = nil
		v.dbObjects[player.UserId] = nil
		v.dbObjects[tostring(player.UserId)] = nil
	end
end)
local Debounce = {
	__call = function(p, p2)
		if not p.dbObjects[p2] then
			p.dbObjects[p2] = 0
		end

		if tick() - p.dbObjects[p2] < p.dbTime then
			return p.dbTime - (tick() - p.dbObjects[p2])
		end

		p.dbObjects[p2] = tick()
		return false
	end
}

function Debounce.New(dbTime)
	local v = {}
	setmetatable(v, Debounce)
	v.__call = Debounce
	v.dbObjects = {}
	v.dbTime = dbTime
	table.insert(object, v)
	return v
end

return Debounce