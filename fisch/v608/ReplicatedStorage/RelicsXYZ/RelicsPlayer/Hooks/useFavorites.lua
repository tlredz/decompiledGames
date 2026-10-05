local parent = script.Parent
local usePlayerData = require(parent.usePlayerData)

local function useFavorites()
	return usePlayerData("Favorites").Favorites
end

return useFavorites