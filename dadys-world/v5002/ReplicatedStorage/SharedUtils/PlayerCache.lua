local PlayerCache = {}
local Players = game:GetService("Players")
local v = {
	[-1] = "Player1",
	[-2] = "Player2"
}

function PlayerCache.getPlayerFromCache(p: number)
	return v[p]
end

function PlayerCache.savePlayerToCache(p: number, p2: string)
	v[p] = p2
end

function PlayerCache.fetchPlayerNameFromCache(p: number)
	local playerFromCache = PlayerCache.getPlayerFromCache(p)

	if playerFromCache then
		return playerFromCache
	end

	local success, result = pcall(function()
		return Players:GetNameFromUserIdAsync(p)
	end)

	if success and result then
		PlayerCache.savePlayerToCache(p, result)
		return result
	else
		return "Player"
	end
end

return PlayerCache