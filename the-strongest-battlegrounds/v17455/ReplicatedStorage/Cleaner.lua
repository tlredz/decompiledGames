local Cleaner = {
	charKeyCleans = setmetatable({}, {
		__mode = "k"
	})
}
local Players = game:GetService("Players")

function Cleaner.autoCleanCharKeys(p)
	Cleaner.charKeyCleans[p] = true
end

local function newPlayer(p)
	p.CharacterRemoving:Connect(function(character)
		for k in Cleaner.charKeyCleans do
			k[character] = nil
		end
	end)
end

for _, v in Players:GetPlayers() do
	task.spawn(newPlayer, v)
end

Players.PlayerAdded:Connect(newPlayer)
Players.PlayerRemoving:Connect(function(player)
	for k in Cleaner.charKeyCleans do
		k[player] = nil
	end
end)
return Cleaner